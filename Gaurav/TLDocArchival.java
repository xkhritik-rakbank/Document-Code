package com.newgen.TLDocArchival;

import java.io.File;
import java.io.FileInputStream;
import java.io.FilenameFilter;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.io.Writer;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.text.Format;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;

import org.apache.commons.io.FileUtils;
import org.apache.log4j.Logger;

import com.newgen.common.CommonConnection;
import com.newgen.common.CommonMethods;
import com.newgen.omni.jts.cmgr.XMLParser;
import com.newgen.omni.wf.util.app.NGEjbClient;
import com.newgen.omni.wf.util.excp.NGException;
import com.newgen.wfdesktop.xmlapi.WFCallBroker;

import ISPack.CPISDocumentTxn;
import ISPack.ISUtil.JPDBRecoverDocData;
import ISPack.ISUtil.JPISException;
import ISPack.ISUtil.JPISIsIndex;

public class TLDocArchival implements Runnable{
	
	static Map<String, String> DocArchivalConfigParamMap = new HashMap<String, String>();
	static String sessionID = "";
	static String cabinetName = "";
	static String jtsIP ="";
	static String jtsPort ="";
	static String SMSPort ="";
	static String volumeID ="";
	int sleepIntervalInMin = 0;
	public static int sessionCheckInt=0;
	public static int loopCount=50;
	public static int waitLoop=50;
	public static String sdate="";
	public static String SourceDiectoryPath="";
	public static String TempDirectoryPath="";
	public static String SuccessDirectorypath="";
	public static String ErrorDirectoryPath="";
	public static String DataClassName="";
	public static String deleteSuccessDataBeforeDays;
	public static String DocName="";
	public static String datadefId="";
	public static String indexId="";
	public static String strLookInFolder="";
	public static String fromMailID="";
	public static String toMailID="";
	public static String updatedFolderName = "";
	
	private static NGEjbClient ngEjbClientConnection;

	static
	{
		try
		{
			ngEjbClientConnection = NGEjbClient.getSharedInstance();
		}
		catch (NGException e)
		{
			e.printStackTrace();
		}
	}

	

	@Override
	public void run() {
		// TODO Auto-generated method stub

		
		try
		{
			TLDocArchivalLog.setLogger();

			int configReadStatus = readConfig();

			TLDocArchivalLog.TLDocArchivalLogger.debug("configReadStatus " + configReadStatus);
			if (configReadStatus != 0) 
			{
				TLDocArchivalLog.TLDocArchivalLogger.error("Could not Read Config Properties [TLDocArchival_Config.properties]");
				return;
			}
			else
			{
				
				SourceDiectoryPath= DocArchivalConfigParamMap.get("INPUTPATH");
			    TempDirectoryPath= DocArchivalConfigParamMap.get("TEMPPATH");
			    SuccessDirectorypath= DocArchivalConfigParamMap.get("OUTPUTPATH");
			    ErrorDirectoryPath= DocArchivalConfigParamMap.get("ERRORPATH");
			    deleteSuccessDataBeforeDays= DocArchivalConfigParamMap.get("DeleteSuccessDataBeforeDays");
			    DataClassName=DocArchivalConfigParamMap.get("DATACLASSNAME");
			    indexId=DocArchivalConfigParamMap.get("INDEXID");
			    datadefId=DocArchivalConfigParamMap.get("DATADEFID");
			    strLookInFolder=DocArchivalConfigParamMap.get("PARENTFOLDERINDEX");
			    fromMailID=DocArchivalConfigParamMap.get("FromMailId");
				toMailID=DocArchivalConfigParamMap.get("ToMailId");
			}
			cabinetName = CommonConnection.getCabinetName();
			TLDocArchivalLog.TLDocArchivalLogger.debug("Cabinet Name: " + cabinetName);

			jtsIP = CommonConnection.getJTSIP();
			TLDocArchivalLog.TLDocArchivalLogger.debug("JTSIP: " + jtsIP);

			jtsPort = CommonConnection.getJTSPort();
			TLDocArchivalLog.TLDocArchivalLogger.debug("JTSPORT: " + jtsPort);
			
			volumeID = CommonConnection.getsVolumeID();
			TLDocArchivalLog.TLDocArchivalLogger.debug("VOLUME ID: " + volumeID);
			
			SMSPort = CommonConnection.getsSMSPort();
			TLDocArchivalLog.TLDocArchivalLogger.debug("SMSPORT: " + SMSPort);

			sleepIntervalInMin = Integer.parseInt(DocArchivalConfigParamMap.get("SleepIntervalInMin"));
			TLDocArchivalLog.TLDocArchivalLogger.debug("SleepIntervalInMin: " + sleepIntervalInMin);

			sessionID = CommonConnection.getSessionID(TLDocArchivalLog.TLDocArchivalLogger, false);

			if (sessionID.trim().equalsIgnoreCase(""))
			{
				TLDocArchivalLog.TLDocArchivalLogger.debug("Could Not Connect to Server!");
			} 
			else
			{
				TLDocArchivalLog.TLDocArchivalLogger.debug("Session ID found: " + sessionID);

				while (true) 
				{
					TLDocArchivalLog.setLogger();
					TLDocArchivalLog.TLDocArchivalLogger.debug("TlDocArchival Doc In OD..");
					sessionID = CommonConnection.getSessionID(TLDocArchivalLog.TLDocArchivalLogger, false);
					startProcessing();
					TLDocArchivalLog.TLDocArchivalLogger.debug("No More document to Process, Sleeping!");
					System.out.println("No More document to Process, Sleeping!");
					Thread.sleep(sleepIntervalInMin * 60 * 1000);
				}
			}
		}
		catch (Exception e) 
		{
			e.printStackTrace();
			TLDocArchivalLog.TLDocArchivalLogger.error("Exception Occurred in TLDocArchival: " + e);
			final Writer result = new StringWriter();
			final PrintWriter printWriter = new PrintWriter(result);
			e.printStackTrace(printWriter);
			TLDocArchivalLog.TLDocArchivalLogger.error("Exception Occurred in TLDocArchival..: " + result);
		}
	
		
	}
	private int readConfig() 
	{
		Properties p = null;
		try 
		{
			p = new Properties();
			p.load(new FileInputStream(new File(System.getProperty("user.dir") + File.separator + "ConfigFiles"
					+ File.separator + "TLDocArchival_Config.properties")));

			Enumeration<?> names = p.propertyNames();

			while (names.hasMoreElements()) 
			{
				String name = (String) names.nextElement();
				DocArchivalConfigParamMap.put(name, p.getProperty(name));
			}
		}
		catch (Exception e)
		{
			return -1;
		}
		return 0;
	}
	
	private void startProcessing()
	{
		try
		{

			Format formatter = new SimpleDateFormat("dd-MMM-yy");
			Date now = new Date();
			sdate = formatter.format(now);
	    	File root = new File(SourceDiectoryPath);
	    	if(root.exists())
	    	{
	    		String[] foldersToBeProcesed=root.list();
	    		if(foldersToBeProcesed.length>0)
	    		{
	    			for(String f:foldersToBeProcesed)
	    			{
		    			try{
		    				updatedFolderName ="";
		    				String QueryString="select CIF_ID from USR_0_TL_CIF_ARCHIVE_MAPPING with (nolock) where TL_Number='"+f+"'";
	
							String sInputXML =CommonMethods.apSelectWithColumnNames(QueryString, cabinetName, sessionID);
							TLDocArchivalLog.TLDocArchivalLogger.debug("Input XML for Apselect from USR_0_TL_CIF_ARCHIVE_MAPPING Table "+sInputXML);
	
							String sOutputXML=TLDocArchival.WFNGExecute(sInputXML, jtsIP, jtsPort,1);
							TLDocArchivalLog.TLDocArchivalLogger.debug("Output XML for USR_0_TL_CIF_ARCHIVE_MAPPING Table select "+sOutputXML);
	
							XMLParser sXMLParser= new XMLParser(sOutputXML);
						    String sMainCode = sXMLParser.getValueOf("MainCode");
						    TLDocArchivalLog.TLDocArchivalLogger.debug("SMainCode: "+sMainCode);
	
						    int sTotalRecords = Integer.parseInt(sXMLParser.getValueOf("TotalRetrieved"));
						    TLDocArchivalLog.TLDocArchivalLogger.debug("STotalRecords: "+sTotalRecords);
	
							if (sMainCode.equals("0") && sTotalRecords > 0)
							{
								TLDocArchivalLog.TLDocArchivalLogger.debug("Inside If block");
								updatedFolderName=sXMLParser.getValueOf("CIF_ID");
								TLDocArchivalLog.TLDocArchivalLogger.debug("updatedFolderName "+updatedFolderName);
							}else{
								String errorFolderWithDate = ErrorDirectoryPath+System.getProperty("file.separator")+sdate;
		    					TLDocArchivalLog.TLDocArchivalLogger.info("CIF_ID for this TL_Number Details: Not Found --"+f);
		    					sendMail("CIF_ID for this TL_Number Details: Not Found ",f,"");
		    					Move(SourceDiectoryPath,errorFolderWithDate,f);
							}
		    			}
		    			catch (Exception e)
		    			{
		    				TLDocArchivalLog.TLDocArchivalLogger.error("Exception in getting CIF_ID for this TL_Number Details: "+e.getMessage());
		    				System.out.println("Exception in getting CIF_ID for this TL_Number Details: "+e.getMessage());
		    			}
	    			
	    				String currFolderPath = SourceDiectoryPath + File.separator +f;
	    				File currFolder = new  File(currFolderPath);
	    				if(currFolder.isDirectory())
	    				{
	    					currFolderPath=moveFile(SourceDiectoryPath,TempDirectoryPath,f);
	    					TLDocArchivalLog.TLDocArchivalLogger.info("Temp path of current folder processing- "+currFolderPath);
	    					if(!"".equalsIgnoreCase(currFolderPath))
	    					{
	    						currFolder = new  File(currFolderPath);
	    						String docListToadd[] = currFolder.list();
	    						if(docListToadd.length>0)
	    						{
	    							String indexTag="<Field>"+
		    		    					"<IndexId>"+indexId+"</IndexId>"+
		    		    					"<IndexValue>"+updatedFolderName+"</IndexValue>"+
		    		    					"<IndexType>S</IndexType>"+
		    		    					"</Field>";
			    					String folderIndex=addFolderInODIfNotExist(updatedFolderName,indexTag);
			    					TLDocArchivalLog.TLDocArchivalLogger.info("Parent folder index of document- "+folderIndex);
			    					if(!"".equalsIgnoreCase(folderIndex))
			    					{
			    						
			    						TLDocArchivalLog.TLDocArchivalLogger.info("No of document in the current folder- "+docListToadd.length);
			    						for(String doc:docListToadd)
			    						{
			    							
			    					    	String outputFolderWithDate = SuccessDirectorypath+System.getProperty("file.separator")+sdate+System.getProperty("file.separator")+f;
			    					    	String errorFolderWithDate = ErrorDirectoryPath+System.getProperty("file.separator")+sdate+System.getProperty("file.separator")+f;
			    							String docFullPath = currFolderPath+File.separator+doc;
			    							String status=addDocumentToOD(docFullPath,folderIndex,indexTag,doc);
			    							if("0".equalsIgnoreCase(status))
			    							{
			    								Move(currFolderPath,outputFolderWithDate,doc);
			    							}
			    							else
			    							{
			    								Move(currFolderPath,errorFolderWithDate,doc);
			    								TLDocArchivalLog.TLDocArchivalLogger.info("Some error occured in adding document--"+doc);
			    		    					sendMail("Doc Add Error",f,doc);
			    							}
			    						}
			    					}
			    					else
			    					{
			    						String errorFolderWithDate = ErrorDirectoryPath+System.getProperty("file.separator")+sdate;
			    						TLDocArchivalLog.TLDocArchivalLogger.info("Error in creating/searching parent folder in OD--"+f);
				    					sendMail("Folder Add Error",f,"");
				    					Move(TempDirectoryPath,errorFolderWithDate,f);
			    					}
	    						}
	    						else // when empty folder is received
	    						{
	    							String errorFolderWithDate = ErrorDirectoryPath+System.getProperty("file.separator")+"EmptyFolderReceived"+System.getProperty("file.separator")+sdate;
		    						TLDocArchivalLog.TLDocArchivalLogger.info("Empty Folder moving to Error Folder--"+f);
			    					Move(TempDirectoryPath,errorFolderWithDate,f);
			    					continue;
	    						}
	    						
	    						currFolder = new  File(currFolderPath);
	    						docListToadd = currFolder.list();
	    						if(docListToadd.length==0)
	    						{
	    							deleteFile(currFolder);
	    						}
	    						else
	    						{
	    							String errorFolderWithDate = ErrorDirectoryPath+System.getProperty("file.separator")+sdate;
		    						TLDocArchivalLog.TLDocArchivalLogger.info("Error in creating/searching parent folder in OD--"+f);
			    					sendMail("Folder Add Error",f,"");
			    					Move(TempDirectoryPath,errorFolderWithDate,f);
	    						}
	    					}
	    					else
	    					{
	    						TLDocArchivalLog.TLDocArchivalLogger.info("Error in moving the directory in temp folder--"+f);
		    				}
	    					
	    				}
	    				else
	    				{
	    					String errorFolderWithDate = ErrorDirectoryPath+System.getProperty("file.separator")+sdate;
	    					TLDocArchivalLog.TLDocArchivalLogger.info("Cuurent File is not a dirctory--"+f);
	    					sendMail("Not a Directory",f,"");
	    					Move(SourceDiectoryPath,errorFolderWithDate,f);
	    				}
	    			}
	    			File fileSuccessPath = new File(SuccessDirectorypath);
					deleteFolder(fileSuccessPath);
	    		}
	    		else
	    		{
	    			TLDocArchivalLog.TLDocArchivalLogger.info("Input Directory is Empty!.. directory location is- "+SourceDiectoryPath);
	    			
	    		}
	    	}
	    	else
    		{
    			TLDocArchivalLog.TLDocArchivalLogger.info("Input Directory not Exist.. directory location is- "+SourceDiectoryPath);
    			
    		}
		}
		catch(Exception e)
		{
			TLDocArchivalLog.TLDocArchivalLogger.info("Exception in processing cases- "+e.toString());
			
		}
	}
	
	public String moveFile(String src, String destinationPath,String file) 
	   {
		 
	       File source = new File(src +File.separator+ file); // "H:\\work-temp\\file"
	       File directory = new File(destinationPath); 
	       if (! directory.exists()){
	    	   directory.mkdirs();
	 	        // If you require it to make the entire directory path including parents,
	 	        // use directory.mkdirs(); here instead.
	 	    }
	       File dest = new File(destinationPath +  File.separator + file);
	      Path result = null;
	      try 
	      {
	         result = Files.move(Paths.get(source.toString()), Paths.get(dest.toString()));
	      } 
	      catch (IOException e) 
	      {
	    	  TLDocArchivalLog.TLDocArchivalLogger.error("Inside CommonFunctions.moveFile--Exception while moving file: -- "+ e.toString());
	    	
	      }
	      if(result != null) 
	      {
	    	  TLDocArchivalLog.TLDocArchivalLogger.info("Inside CommonFunctions.moveFile--File moved successfully.");
	    	  return result.toString();
	      }
	      else
	      {
	    	  TLDocArchivalLog.TLDocArchivalLogger.info("Inside CommonFunctions.moveFile--File movement failed.");
	    	  return "";
	      }
	   }
	
	public String Move(String srcFolderPath, String destFolderPath, String file)
	{
		String newFilename = null;
		try
		{
			String append=get_timestamp();
			File objDestFolder = new File(destFolderPath);
			if (!objDestFolder.exists())
			{
				objDestFolder.mkdirs();
			}
			TLDocArchivalLog.TLDocArchivalLogger.info("Move Source path - "+srcFolderPath +File.separator+ file);
			File objsrcFolderPath = new File(srcFolderPath +File.separator+ file);
			newFilename = objsrcFolderPath.getName();
			TLDocArchivalLog.TLDocArchivalLogger.info("Move Destination path - "+destFolderPath + File.separator + newFilename);
			File lobjFileTemp = new File(destFolderPath + File.separator + newFilename);
			if (lobjFileTemp.exists())
			{
				if (!lobjFileTemp.isDirectory())
				{
					lobjFileTemp.delete();
				}
				else
				{
					deleteDir(lobjFileTemp);
				}
			}
			else
			{
				lobjFileTemp = null;
			}
			File lobjNewFolder = new File(objDestFolder, newFilename +"_"+ append);

			boolean lbSTPuccess = false;
			try
			{
				lbSTPuccess = objsrcFolderPath.renameTo(lobjNewFolder);
				TLDocArchivalLog.TLDocArchivalLogger.info("Inside Move--File moved successfully.");
			}
			catch (SecurityException lobjExp)
			{
				TLDocArchivalLog.TLDocArchivalLogger.info("Inside Move- SecurityException- "+lobjExp.getMessage());
			}
			catch (NullPointerException lobjNPExp)
			{
				TLDocArchivalLog.TLDocArchivalLogger.info("Inside Move- NullPointerException- "+lobjNPExp.getMessage());
			}
			catch (Exception lobjExp)
			{
				TLDocArchivalLog.TLDocArchivalLogger.info("Inside Move-Exception- "+lobjExp.getMessage());
			}
			if (!lbSTPuccess)
			{
				TLDocArchivalLog.TLDocArchivalLogger.info("Inside Move- lbSTPuccess");
			}
			else
			{
				TLDocArchivalLog.TLDocArchivalLogger.info("Inside Move- else");
			}
			objDestFolder = null;
			objsrcFolderPath = null;
			lobjNewFolder = null;
		}
		catch (Exception lobjExp)
		{
			TLDocArchivalLog.TLDocArchivalLogger.info("Exception in Move- "+lobjExp.getMessage());
		}

		return newFilename;
	}
	
	public static String get_timestamp()
	{
		Date present = new Date();
		Format pformatter = new SimpleDateFormat("dd-MM-yyyy-hhmmss");
		String TimeStamp=pformatter.format(present);
		return TimeStamp;
	}
	public static boolean deleteDir(File dir) throws Exception {
		if (dir.isDirectory()) {
			String[] lstrChildren = dir.list();
			for (int i = 0; i < lstrChildren.length; i++) {
				boolean success = deleteDir(new File(dir, lstrChildren[i]));
				if (!success) {
					return false;
				}
			}
		}
		return dir.delete();
	}
	
	public String addFolderInODIfNotExist(String folderName,String indexTag)
	{	
		TLDocArchivalLog.TLDocArchivalLogger.info("Inside addOrUpdateFolderIfExist..! ");
		String parentFolderIndex = "";
		String statusCode="";
		XMLParser xmlparser;
		String  strAddFolderInXML="";
		String strAddFolderOutXML="";
		
		sessionCheckInt=0;
		while(sessionCheckInt<loopCount)
		{
			try
			{
				TLDocArchivalLog.TLDocArchivalLogger.info("search folder lookinfolder is--"+strLookInFolder);
				String strSearchFolderInXML=getSearchFolderInput(cabinetName,sessionID,strLookInFolder,folderName);
		        String strSearchFolderOutXML = WFNGExecute(strSearchFolderInXML,jtsIP,jtsPort, 1);
		        TLDocArchivalLog.TLDocArchivalLogger.info("search folder output xml--"+strSearchFolderOutXML);
				xmlparser = new XMLParser(strSearchFolderOutXML);
                statusCode=xmlparser.getValueOf("Status");
				if (statusCode.equalsIgnoreCase("0"))
				{
					String error=xmlparser.getValueOf("Error");
					if(error==null)
						error="";
					if(error.length()==0 && !"0".equalsIgnoreCase(xmlparser.getValueOf("NoOfRecordsFetched"))) 
					{  
						parentFolderIndex = xmlparser.getValueOf("FolderIndex");
						TLDocArchivalLog.TLDocArchivalLogger.info("inside search folder else condition and folder is already exist with folder id--"+parentFolderIndex);
						return parentFolderIndex;
					}
					else
					{
						sessionCheckInt=0;
						while(sessionCheckInt<loopCount)
						{
							try
							{
								strAddFolderInXML = getAddFolderInputSIB(indexTag,sessionID, strLookInFolder ,folderName,cabinetName,DataClassName,datadefId);
								strAddFolderOutXML = WFNGExecute(strAddFolderInXML, jtsIP,jtsPort, 1);
								xmlparser = new XMLParser(strAddFolderOutXML);
							    TLDocArchivalLog.TLDocArchivalLogger.info("output xml for add folder call when executed for the first time ############# "+strAddFolderOutXML);
							    statusCode=xmlparser.getValueOf("Status");
								
								if (statusCode.equalsIgnoreCase("0"))
								{
									parentFolderIndex = xmlparser.getValueOf("FolderIndex");
									TLDocArchivalLog.TLDocArchivalLogger.info("value of folder index after execution of add folder call for FIRST TIME ################# "+parentFolderIndex);
									return parentFolderIndex;
								}
								else
								{
									TLDocArchivalLog.TLDocArchivalLogger.info("Error in executing add folder inxml..");
									
								}
								int mainCode=Integer.parseInt(statusCode);
								if (mainCode == -50146)
								{
									sessionID=CommonConnection.getSessionID(TLDocArchivalLog.TLDocArchivalLogger, false);
								}
								else
								{
									sessionCheckInt++;
									break;
								}
							}
							catch(Exception e)
							{
								TLDocArchivalLog.TLDocArchivalLogger.info("Error while adding the first new folder of the hierachy--"+e.toString());
							}
						}
						
					}
				
				}
				else
				{
					TLDocArchivalLog.TLDocArchivalLogger.info("Error while searching the folder..");
					
				}
				int mainCode=Integer.parseInt(statusCode);
				if (mainCode == -50146)
				{
					sessionID=CommonConnection.getSessionID(TLDocArchivalLog.TLDocArchivalLogger, false);
				}
				else
				{
					sessionCheckInt++;
					break;
				}
			}
			catch(Exception e)
			{
				TLDocArchivalLog.TLDocArchivalLogger.info("Error while searching the first  folder of the hierachy--"+e.toString());
			}
		}

		return parentFolderIndex;
        }
	public  String getAddFolderInputwithoutdc(String sUserDBID , String sParentFolderIndex , String sFolderName,String sCabinetName){

		String inputXml = "<?xml version=\"1.0\"?>" 
				+	"<NGOAddFolder_Input>" 
				+	"<Option>NGOAddFolder</Option>" 
				+	"<CabinetName>"+ sCabinetName + "</CabinetName>"
				+	"<UserDBId>" + sUserDBID + "</UserDBId><Folder>"
				+	"<ParentFolderIndex>" + sParentFolderIndex + "</ParentFolderIndex>"
				+	"<FolderName>"+ sFolderName +"</FolderName>"
				+	"<CreationDateTime></CreationDateTime>"
				+	"<ExpiryDateTime></ExpiryDateTime>"
				+	"<AccessType>I</AccessType>"
				+	"<ImageVolumeIndex>1</ImageVolumeIndex>"
				+	"<Location></Location>"
				+	"<Comment></Comment>"
				+	"<NoOfDocuments></NoOfDocuments>"
				+	"<NoOfSubFolders></NoOfSubFolders>"
				+	"<DataDefinition>"
				+	"<DataDefName></DataDefName>"
				+ 	"</DataDefinition>" 
				+ 	"</Folder>"
				+ 	"</NGOAddFolder_Input>";
		TLDocArchivalLog.TLDocArchivalLogger.info("inputXml for getAddFolderInputwithoutdc:::: "+inputXml);
		return	inputXml;
	}
	public String getSearchFolderInput(String sCabinetName, String sUserDBID, String sParentFolderIndex,
			String sFolderName) {
		
		
		
		String inputXml = "<?xml version=\"1.0\"?>" 
				+ "<NGOSearchFolder_Input>" 
				+ "<Option>NGOSearchFolder</Option>"
				+ "<CabinetName>" + sCabinetName + "</CabinetName>" 
				+ "<UserDBId>" + sUserDBID + "</UserDBId>"
				+ "<LookInFolder>" + sParentFolderIndex + "</LookInFolder>" 
				+ "<IncludeSubFolder>N</IncludeSubFolder>"
				+ "<Name>" + sFolderName + "</Name>" 
				+ "<StartFrom>1</StartFrom>"
				+ "<NoOfRecordsToFetch>10</NoOfRecordsToFetch>" 
				+ "</NGOSearchFolder_Input>";
		TLDocArchivalLog.TLDocArchivalLogger.info("inputXml for getSearchFolderInput:::: "+inputXml);
		return inputXml;
	}
	public String getAddFolderInputSIB(String indexTag,String sUserDBID,String sParentFolderIndex , String sFolderName,String sCabinetName,String dataClassName_Folder,String strDataclassId)
	{	
		

		TLDocArchivalLog.TLDocArchivalLogger.info("indexTag:: "+indexTag);
		String inputXml = "<?xml version=\"1.0\"?>" 
				+ "<NGOAddFolder_Input>" 
				+ "<Option>NGOAddFolder</Option>" 
				+ "<CabinetName>" + sCabinetName + "</CabinetName>" 
				+ "<UserDBId>" + sUserDBID + "</UserDBId>" 
				+ "<Folder>"
				+ "<ParentFolderIndex>" + sParentFolderIndex + "</ParentFolderIndex>" 
				+ "<FolderName>" + sFolderName+ "</FolderName>" 
				+ "<CreationDateTime></CreationDateTime>" 
				+ "<ExpiryDateTime></ExpiryDateTime>"
				+ "<AccessType>I</AccessType>" 
				+ "<ImageVolumeIndex>1</ImageVolumeIndex>" 
				+ "<Location></Location>"
				+ "<Comment></Comment>" 
				+ "<NoOfDocuments></NoOfDocuments>" 
				+ "<NoOfSubFolders></NoOfSubFolders>"
				+ "<DataDefinition>" 
				+ "<DataDefName>"+dataClassName_Folder+"</DataDefName>" 
				+ "<DataDefIndex>" + strDataclassId+ "</DataDefIndex>"
				+ "<Fields>" 
				+ indexTag
				+ "</Fields>"
				+ "</DataDefinition>" 
				+ "</Folder>"
				+ "</NGOAddFolder_Input>";
		TLDocArchivalLog.TLDocArchivalLogger.info("inputXml for getAddFolderInputSIB:::: "+inputXml);
		return inputXml;
	}
	protected static String WFNGExecute(String ipXML, String jtsServerIP, String serverPort,
			int flag) throws IOException, Exception
	{
		TLDocArchivalLog.TLDocArchivalLogger.debug("In WF NG Execute : " + serverPort);
		try
		{
			if (serverPort.startsWith("33"))
				return WFCallBroker.execute(ipXML, jtsServerIP,
						Integer.parseInt(serverPort), 1);
			else
				return ngEjbClientConnection.makeCall(jtsServerIP, serverPort,
						"WebSphere", ipXML);
		}
		catch (Exception e)
		{
			TLDocArchivalLog.TLDocArchivalLogger.debug("Exception Occured in WF NG Execute : "
					+ e.getMessage());
			e.printStackTrace();
			return "Error";
		}
	}
	
	public String addDocumentToOD(String docFullPath,String parentFolderIndex,String indexTag,String docName)
	{
		String status="";
		XMLParser xmlparser;
		int pageCount=1;
		JPISIsIndex IsIndex = new JPISIsIndex();
		JPDBRecoverDocData docDBData= new JPDBRecoverDocData();
		//docDBData.m_cDocumentType ='N';
		//docDBData.m_sVolumeId = Short.parseShort("volumeID");
		
		
		

		//uploading
		try
		{
			
			File file = new File(docFullPath);
			TLDocArchivalLog.TLDocArchivalLogger.info("Document which going to add in OD--------->"+docName);
			TLDocArchivalLog.TLDocArchivalLogger.info("Document Path------->"+file.getAbsoluteFile());
			TLDocArchivalLog.TLDocArchivalLogger.info("Is File Exist"+file.exists());
			TLDocArchivalLog.TLDocArchivalLogger.info("Lengthof document---->"+file.length());
			
			if(SMSPort.startsWith("33"))
			{
				CPISDocumentTxn.AddDocument_MT(null, jtsIP , Short.parseShort(SMSPort), cabinetName, Short.parseShort(volumeID), docFullPath, docDBData, "",IsIndex);
			}
			else
			{
				CPISDocumentTxn.AddDocument_MT(null, jtsIP , Short.parseShort(SMSPort), cabinetName, Short.parseShort(volumeID), docFullPath, docDBData, null,"JNDI", IsIndex);
			}
			
			//CPISDocumentTxn.AddDocument_MT(null,CommonConnection.getJTSIP(),
					//Short.parseShort(CommonConnection.getJTSPort()),CommonConnection.getCabinetName(), Short.parseShort("volumeID"),docFullPath, docDBData, "", IsIndex);
		        
	        /*CPISDocumentTxn.AddDocument_MT(null,CommonFields.sJtsAddress,(short)(Integer.parseInt("1099")),CommonFields.sCabinetName,Short.parseShort("1"), docFullPath, docDBData, "","JNDI" ,IsIndex);*/
	        TLDocArchivalLog.TLDocArchivalLogger.info(IsIndex.toString());
		}
		
		catch (NumberFormatException e) 
		{
			// TODO Auto-generated catch block
			TLDocArchivalLog.TLDocArchivalLogger.info("NumberFormatException----"+e.toString());
			e.printStackTrace();
		} catch (JPISException e) 
		{
			// TODO Auto-generated catch block
			TLDocArchivalLog.TLDocArchivalLogger.info("Error encountere while adding document to the server---"+e.toString());
			e.printStackTrace();
		}
		if (IsIndex.m_nDocIndex == -1) 
		{
			TLDocArchivalLog.TLDocArchivalLogger.info(new Date().toString() + ": Unable to add file to SMS.");
		}
		else
		{
	    TLDocArchivalLog.TLDocArchivalLogger.info("Uploaded Document to Image Server.....");
					
		}
		
		int intISIndex = (int) IsIndex.m_nDocIndex;
		int intVolumeId = (int) IsIndex.m_sVolumeId;					
		String noOfPages = String.valueOf(pageCount);
		if(intISIndex <= 0) 
		{
			TLDocArchivalLog.TLDocArchivalLogger.info("Error");
		}
		else
		{
			try
				{
				String intISIndexVolId = Integer.toString(intISIndex) + "#" + intVolumeId + "#";
				
				TLDocArchivalLog.TLDocArchivalLogger.info("Document with extension which is going to for upload in OD--"+docName);
			    String s1[]=docName.split("\\.");//dot is a regex character in java therefore need to be escaped 
			    docName=s1[0];
			    TLDocArchivalLog.TLDocArchivalLogger.info("Document Name in OD--"+docName);
			    String strExtension=s1[1];
			    String DocumentType="";
			    TLDocArchivalLog.TLDocArchivalLogger.info("Extension of the uploaded doc--"+strExtension);
			    if(strExtension.equalsIgnoreCase("JPG") || strExtension.equalsIgnoreCase("TIF") || strExtension.equalsIgnoreCase("JPEG") || strExtension.equalsIgnoreCase("TIFF"))
				{
					DocumentType = "I";
				}
				else
				{
					DocumentType = "N";
				}
				File file = new File(docFullPath);
	            String strInputXml = getAddDocumentInputXML(cabinetName,sessionID,docName,strExtension,DocumentType,parentFolderIndex,intISIndexVolId,noOfPages,String.valueOf(file.length()),indexTag,datadefId);
	            TLDocArchivalLog.TLDocArchivalLogger.info("Input Xml------------------------>"+strInputXml);
	            String strOutputXml="";
	            sessionCheckInt=0;
				while(sessionCheckInt<loopCount)
				{
					try
					{
						strOutputXml =WFNGExecute(strInputXml, jtsIP,jtsPort, 1);
						xmlparser= new XMLParser(strOutputXml);
						TLDocArchivalLog.TLDocArchivalLogger.info("Output Xml------------------------>"+strOutputXml);
				        TLDocArchivalLog.TLDocArchivalLogger.info(strOutputXml);
						status= xmlparser.getValueOf("Status");
						if (!status.equalsIgnoreCase("0"))
						{
							TLDocArchivalLog.TLDocArchivalLogger.info("Error in Add document call");
						}
						int mainCode=Integer.parseInt(status);
						if (mainCode == -50146)
						{
							sessionID=CommonConnection.getSessionID(TLDocArchivalLog.TLDocArchivalLogger, false);
						}
						else
						{
							sessionCheckInt++;
							break;
						}
					}
					catch(Exception e)
					{
						TLDocArchivalLog.TLDocArchivalLogger.info("Error in adding document ---"+e.toString());
					}
				}
			}
			catch(Exception e)
			{
				TLDocArchivalLog.TLDocArchivalLogger.info("Error in adding document(metadata generation) ---"+e.toString());
			}
		}
		return status;         
      }
	public  String getAddDocumentInputXML(String sCabinetName,String sSessionID,String docName,String strdocExtension,String DocumentType,String parentFolderIndex,String intISIndexVolId,String nofpages,String docSize,String dataDefFieldsXml,String dataDefId )
	{
		
		String strInputXml =
				"<?xml version=\"1.0\"?><NGOAddDocument_Input>" +
				        "<Option>NGOAddDocument</Option>" +
				        "<CabinetName>"+sCabinetName+"</CabinetName>" +
				        "<UserDBId>"+sSessionID+"</UserDBId>" +
				        "<GroupIndex>0</GroupIndex>" +
				        "<Document>" +
				        "<ParentFolderIndex>"+parentFolderIndex+"</ParentFolderIndex>" +
				        "<NoOfPages>"+nofpages+"</NoOfPages>" +
				        "<AccessType>I</AccessType>" +
				        "<DocumentName>"+docName+"</DocumentName>" +
				        "<CreationDateTime></CreationDateTime>" +
				        "<DocumentType>"+DocumentType+"</DocumentType>" +
				        "<DocumentSize>"+docSize+"</DocumentSize>" +
				        "<CreatedByAppName>"+strdocExtension+"</CreatedByAppName>" +
				        "<ISIndex>"+intISIndexVolId+"</ISIndex>" +
				        "<ODMADocumentIndex></ODMADocumentIndex>" +
				        "<Comment></Comment>" +
				        "<EnableLog>Y</EnableLog>" +
				        "<FTSFlag>PP</FTSFlag>" +
				        "<DataDefinition>"+
				        "<DataDefIndex>"+dataDefId+"</DataDefIndex>"+
				        "<Fields>"+dataDefFieldsXml+"</Fields>"+
				        "</DataDefinition>" +
				        "<Keywords></Keywords>" +
				        "</Document>" +
				        "</NGOAddDocument_Input>";
		
          return strInputXml;
	}
	
	public static void sendMail(String failedEvent,String FolderName,String docName )throws Exception
	{
		XMLParser objXMLParser = new XMLParser();
		String sInputXML="";
		String sOutputXML="";
		String mainCodeforAPInsert=null;
		sessionCheckInt=0;
		while(sessionCheckInt<loopCount)
		{
			try
			{
				String mailSubject = "";
				String MailStr = "";
				
				if ("Doc Add Error".equalsIgnoreCase(failedEvent))
				{
					mailSubject = "Error in TLDoc Archival";
					MailStr = "<html><body>Dear BPM Support Team,<br><br>Some internal server error has occured while adding the TL document " +docName+" of directory "+FolderName+". Kindly verify the document in Error folder.<br><br>Regards,<br>RAKBANK<br>* This is an automated email, please do not reply.</body></html>";
				} 
				else if ("Not a Directory".equalsIgnoreCase(failedEvent))
				{
					mailSubject = "Error in TLDoc Archival";
					MailStr = "<html><body>Dear BPM Support Team,<br><br>If TL document with name " +FolderName+" need to be archived, it suppose to be within a directory. Kindly verify the document in Error folder.<br><br>Regards,<br>RAKBANK<br>* This is an automated email, please do not reply.</body></html>";
				}
				else if ("Folder Add Error".equalsIgnoreCase(failedEvent))
				{
					mailSubject = "Error in TLDoc Archival";
					MailStr = "<html><body>Dear BPM Support Team,<br><br>Some internal server error has occured while creating the hierachy of directory "+FolderName+". Kindly verify the TL document in Error folder.<br><br>Regards,<br>RAKBANK<br>* This is an automated email, please do not reply.</body></html>";
				}
				
				String columnName = "mailFrom,mailTo,mailSubject,mailMessage,mailContentType,mailPriority,mailStatus,mailActionType,insertedTime,processDefId,workitemId,activityId,noOfTrials,zipFlag";
				String strValues = "'"+fromMailID+"','"+toMailID+"','"+mailSubject+"','"+MailStr+"','text/html;charset=UTF-8','1','N','TRIGGER','"+CommonMethods.getdateCurrentDateInSQLFormat()+"','0','1','0','0','N'";
				
				sInputXML = "<?xml version=\"1.0\"?>" +
						"<APInsert_Input>" +
						"<Option>APInsert</Option>" +
						"<TableName>WFMAILQUEUETABLE</TableName>" +
						"<ColName>" + columnName + "</ColName>" +
						"<Values>" + strValues + "</Values>" +
						"<EngineName>" + cabinetName + "</EngineName>" +
						"<SessionId>" + sessionID + "</SessionId>" +
						"</APInsert_Input>";

				TLDocArchivalLog.TLDocArchivalLogger.info("Mail Insert InputXml::::::::::\n"+sInputXML);
				sOutputXML =WFNGExecute(sInputXML, jtsIP, jtsPort, 0);
				TLDocArchivalLog.TLDocArchivalLogger.info("Mail Insert OutputXml::::::::::\n"+sOutputXML);
				objXMLParser.setInputXML(sOutputXML);
				mainCodeforAPInsert=objXMLParser.getValueOf("MainCode");
			}
			catch(Exception e)
			{
				e.printStackTrace();
				TLDocArchivalLog.TLDocArchivalLogger.error("Exception in Sending mail", e);
				sessionCheckInt++;
				waiteloopExecute(waitLoop);
				continue;
			}
			if (mainCodeforAPInsert.equalsIgnoreCase("11")) 
			{
				TLDocArchivalLog.TLDocArchivalLogger.info("Invalid session in Sending mail");
				sessionCheckInt++;
				sessionID=CommonConnection.getSessionID(TLDocArchivalLog.TLDocArchivalLogger, false);
				continue;
			}
			else
			{
				sessionCheckInt++;
				break;
			}
		}
		if(mainCodeforAPInsert.equalsIgnoreCase("0"))
		{
			TLDocArchivalLog.TLDocArchivalLogger.info("mail Insert Successful");
		}
		else
		{
			TLDocArchivalLog.TLDocArchivalLogger.info("mail Insert Unsuccessful");
		}
	}
	public static void waiteloopExecute(long wtime) 
	{
		try 
		{
			for (int i = 0; i < 10; i++) 
			{
				Thread.yield();
				Thread.sleep(wtime / 10);
			}
		} 
		catch (InterruptedException e) 
		{
		}
	}
	private static void deleteFolder(File file){
		SimpleDateFormat dateFormat = new SimpleDateFormat("dd-MMM-yy");
		for (File subFile : file.listFiles()) 
		{
			boolean isOld = false;
			String strModifiedDate = dateFormat.format(subFile.lastModified());
			TLDocArchivalLog.TLDocArchivalLogger.info("File Name: "+subFile.getName()+", last modified: "+strModifiedDate);
			try {
				Date parsedModifiedDate=new SimpleDateFormat("dd-MMM-yy").parse(strModifiedDate);
				isOld = olderThanDays(parsedModifiedDate, Integer.parseInt(deleteSuccessDataBeforeDays));
			} catch (ParseException e) {
				e.printStackTrace();
			}
			if (isOld)
			{
				TLDocArchivalLog.TLDocArchivalLogger.info("Deleting: "+subFile.getName());	
				deleteFile(subFile);
			}
		}
	}
	private static boolean olderThanDays(Date givenDate, int numDays)
	{   
		final long MILLIS_PER_DAY = 24 * 60 * 60 * 1000;
		long currentMillis = new Date().getTime();
	    long millisInDays = numDays * MILLIS_PER_DAY;
	    boolean result = givenDate.getTime() < (currentMillis - millisInDays);
	    return result;
	}
	
	private static void deleteFile(File f)
	{
		if(f.isDirectory()) 
		{
			try {
				FileUtils.deleteDirectory(f);
			} catch (IOException e) {
				e.printStackTrace();
			}
		} else {
			f.delete();
		}
	}

}
