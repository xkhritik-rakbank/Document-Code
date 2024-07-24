package com.newgen.KYC.CustOutreach;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.io.Writer;
import java.net.Socket;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.Set;

import org.apache.commons.io.FilenameUtils;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellType;
import org.apache.poi.ss.usermodel.DataFormatter;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import com.newgen.KYC.KYCodDownload.KYCodDownloadLog;
import com.newgen.KYC.KYCodDownload.MapXML;
import com.newgen.KYC.KYCreadExcel.KYCreadExcelLog;
import com.newgen.ODDD.ODDocDownload.ExcelData;
import com.newgen.common.CommonConnection;
import com.newgen.common.CommonMethods;
import com.newgen.omni.jts.cmgr.NGXmlList;
import com.newgen.omni.jts.cmgr.XMLParser;
import com.newgen.omni.wf.util.app.NGEjbClient;
import com.newgen.omni.wf.util.excp.NGException;

import ISPack.CPISDocumentTxn;
import ISPack.ISUtil.JPDBRecoverDocData;
import ISPack.ISUtil.JPISException;
import ISPack.ISUtil.JPISIsIndex;


public class CustOutreach implements Runnable{

	private static NGEjbClient ngEjbClientOutreach;
	private static String sessionID = "";
	private static String cabinetName = "";
	private static String jtsIP = "";
	private static String jtsPort = "";
	private static String queueID = "";
	private static String OutreachDocPath = "";
	private static String SMSPort = "";
	private static String volumeID = "";
	private static String DocTypes = "";
	private static String SuccessPath = "";
	private static String ErrorPath = "";
	private static int sleepIntervalInMin=0;
	static Map<String, String> KYCcustOutreachParaMap= new HashMap<String, String>();
	List<String> DocsList = new ArrayList<>();
	@Override
	public void run()
	{
		try
		{
			CustOutreachLog.setLogger();
			ngEjbClientOutreach = NGEjbClient.getSharedInstance();

			CustOutreachLog.KYCcustOutreachLogger.debug("Connecting to Cabinet.");

			int configReadStatus = readConfig();

			CustOutreachLog.KYCcustOutreachLogger.debug("configReadStatus "+configReadStatus);
			if(configReadStatus !=0)
			{
				CustOutreachLog.KYCcustOutreachLogger.error("Could not Read Config Properties [ODDDStatus]");
				return;
			}

			volumeID = CommonConnection.getsVolumeID();
			CustOutreachLog.KYCcustOutreachLogger.debug("volumeID: " + volumeID);
			
			cabinetName = CommonConnection.getCabinetName();
			CustOutreachLog.KYCcustOutreachLogger.debug("Cabinet Name: " + cabinetName);

			jtsIP = CommonConnection.getJTSIP();
			CustOutreachLog.KYCcustOutreachLogger.debug("JTSIP: " + jtsIP);

			jtsPort = CommonConnection.getJTSPort();
			CustOutreachLog.KYCcustOutreachLogger.debug("JTSPORT: " + jtsPort);			

			queueID = KYCcustOutreachParaMap.get("queueID");
			CustOutreachLog.KYCcustOutreachLogger.debug("QueueID: " + queueID);
			
			SMSPort = CommonConnection.getsSMSPort();
			CustOutreachLog.KYCcustOutreachLogger.debug("SMSPort: " + SMSPort);
			
			OutreachDocPath = KYCcustOutreachParaMap.get("OutreachDocPath");
			CustOutreachLog.KYCcustOutreachLogger.debug("OutreachDocPath: " + OutreachDocPath);
			
			SuccessPath = KYCcustOutreachParaMap.get("SuccessPath");
			CustOutreachLog.KYCcustOutreachLogger.debug("SuccessPath: " + SuccessPath);
			
			ErrorPath = KYCcustOutreachParaMap.get("ErrorPath");
			CustOutreachLog.KYCcustOutreachLogger.debug("ErrorPath: " + ErrorPath);

			DocTypes = KYCcustOutreachParaMap.get("DocTypes");
			CustOutreachLog.KYCcustOutreachLogger.debug("DocTypes from config files: " + DocTypes);
			
			sleepIntervalInMin=Integer.parseInt(KYCcustOutreachParaMap.get("SleepIntervalInMin"));
			CustOutreachLog.KYCcustOutreachLogger.debug("SleepIntervalInMin: "+sleepIntervalInMin);
						
 			sessionID = CommonConnection.getSessionID(CustOutreachLog.KYCcustOutreachLogger, false);

 			if(sessionID.trim().equalsIgnoreCase(""))
			{
				CustOutreachLog.KYCcustOutreachLogger.debug("Could Not Connect to Server!");
			}
			else
			{
 				CustOutreachLog.KYCcustOutreachLogger.debug("Session ID found: " + sessionID);
				//HashMap<String, String> socketDetailsMap= socketConnectionDetails(cabinetName, jtsIP, jtsPort,sessionID);
				while(true)
				{
					sessionID = CommonConnection.getSessionID(CustOutreachLog.KYCcustOutreachLogger, false);
					CustOutreachLog.setLogger();
 					CustOutreachLog.KYCcustOutreachLogger.debug("ODDD Utility...123");
 					startUtilityCustOutreach(cabinetName, sessionID,jtsIP, jtsPort);
					System.out.println("No More workitems to Process, Sleeping!");
					Thread.sleep(sleepIntervalInMin*60*1000);
				}
			}
		}
		catch(Exception e)
		{
			e.printStackTrace();
			CustOutreachLog.KYCcustOutreachLogger.error("Exception Occurred in outreach : "+e);
			final Writer result = new StringWriter();
			final PrintWriter printWriter = new PrintWriter(result);
			e.printStackTrace(printWriter);
			CustOutreachLog.KYCcustOutreachLogger.error("Exception Occurred in outreach : "+result);
		}
	}
	
	
	private int readConfig()
	{
		Properties p = null;
		try {

			p = new Properties();
			p.load(new FileInputStream(new File(System.getProperty("user.dir")+ File.separator + "ConfigFiles"+ File.separator+ "KYC_CustOutreach_Config.properties")));

			Enumeration<?> names = p.propertyNames();

			while (names.hasMoreElements())
			{
			    String name = (String) names.nextElement();
			    KYCcustOutreachParaMap.put(name, p.getProperty(name));
			}
		}
		catch (Exception e)
		{
			return -1 ;
		}
		return 0;
	}

	
	private void startUtilityCustOutreach(String cabinetName, String sessionID, String jtsIP, String jtsPort) {
		try{
		System.out.println("Inside startUtilityCustOutreach method");
		CustOutreachLog.KYCcustOutreachLogger.debug("Inside startUtilityCustOutreach");
		
		String Query = "Select WINAME,OutreachStatusUpdateDateTime from RB_KYC_REM_EXTTABLE with (nolock) where CustomerOutreachFlag = 'Completed' AND CURRENT_WS = 'RM_Vendor'";
		List<Map<String, String>> DataFromDB = new ArrayList<Map<String, String>>();
		DataFromDB = getDataFromDBMap(Query, cabinetName, sessionID, jtsIP, jtsPort);
		CustOutreachLog.KYCcustOutreachLogger.debug("DataFromDB : OF_DATA_DEF_ID "+DataFromDB);
		
		for (Map<String, String> entry : DataFromDB) {
			String WINAME = entry.get("WINAME");
			String OutreachupdateDateTime = entry.get("OutreachStatusUpdateDateTime");
			CustOutreachLog.KYCcustOutreachLogger.debug("WINAME FETCHED-->"+WINAME);			
			String Path = OutreachDocPath+File.separator+WINAME;
			Path targetDirectory = Paths.get(Path);
			if(Files.exists(targetDirectory)){
			File directory = new File(Path);
			File[] files = directory.listFiles();
			int length = files.length;
			System.out.println("Length - "+length);
			if(length!=0){
				for(File file:files)
				{
					if(file.isFile())
					{
						String fileName = file.getName();
						String fileNameWithoutExt = fileName.substring(0,fileName.lastIndexOf("."));
						CustOutreachLog.KYCcustOutreachLogger.debug("Document processing-->"+file.getName());
						String size = String.valueOf(file.length());
						String ext = fileName.substring(fileName.lastIndexOf("."),fileName.length());
						String createdByAppName = ext.replaceFirst(".", "");
						String DocumentType = "Others";
						if(DocTypes.contains(fileName.substring(0,fileName.lastIndexOf(".")))){
							DocumentType = fileName.substring(0,fileName.lastIndexOf("."));
						}
						String FullPath = Path+File.separator+fileName;
						JPISIsIndex ISINDEX = new JPISIsIndex();
						JPDBRecoverDocData JPISDEC = new JPDBRecoverDocData();
						CustOutreachLog.KYCcustOutreachLogger.debug("trying to add doc on image server");
						try{
						CustOutreachLog.KYCcustOutreachLogger.debug("Values passed -- >jtsip-"+jtsIP+" , jtsPort->"+jtsPort+",cabinetName->"+cabinetName+",volumeID->"+volumeID+", File path-->"+FullPath);
						CPISDocumentTxn.AddDocument_MT(null, jtsIP , Short.parseShort(SMSPort), cabinetName, Short.parseShort(volumeID), FullPath.toString(),JPISDEC,"",ISINDEX);
						
						CustOutreachLog.KYCcustOutreachLogger.debug("after CPISDocumentTxn AddDocument MT: ");
						String sISIndex = ISINDEX.m_nDocIndex + "#" + ISINDEX.m_sVolumeId;
						CustOutreachLog.KYCcustOutreachLogger.debug("sISIndex after adding on SMS - "+sISIndex);
						String parentFolderIndex = getFolderIndex(WINAME);
						
						StringBuffer ipXMLBuffer=new StringBuffer();

						ipXMLBuffer.append("<?xml version=\"1.0\"?>\n");
						ipXMLBuffer.append("<NGOAddDocument_Input>\n");
						ipXMLBuffer.append("<Option>NGOAddDocument</Option>");
						ipXMLBuffer.append("<CabinetName>");
						ipXMLBuffer.append(cabinetName);
						ipXMLBuffer.append("</CabinetName>\n");
						ipXMLBuffer.append("<UserDBId>");
						ipXMLBuffer.append(sessionID);
						ipXMLBuffer.append("</UserDBId>\n");
						ipXMLBuffer.append("<GroupIndex>0</GroupIndex>\n");
						ipXMLBuffer.append("<Document>\n");
						ipXMLBuffer.append("<VersionFlag>Y</VersionFlag>\n");
						ipXMLBuffer.append("<ParentFolderIndex>");
						ipXMLBuffer.append(parentFolderIndex);
						ipXMLBuffer.append("</ParentFolderIndex>\n");
						ipXMLBuffer.append("<DocumentName>");
						ipXMLBuffer.append(DocumentType);
						ipXMLBuffer.append("</DocumentName>\n");
						ipXMLBuffer.append("<VolumeIndex>");
						ipXMLBuffer.append(volumeID);
						ipXMLBuffer.append("</VolumeIndex>\n");
						ipXMLBuffer.append("<ISIndex>");
						ipXMLBuffer.append(sISIndex);
						ipXMLBuffer.append("</ISIndex>\n");
						/*ipXMLBuffer.append("<NoOfPages>");
						ipXMLBuffer.append(NoOfPages);
						ipXMLBuffer.append("</NoOfPages>\n");*/
						ipXMLBuffer.append("<DocumentType>");
						ipXMLBuffer.append("N");
						ipXMLBuffer.append("</DocumentType>\n");
						ipXMLBuffer.append("<DocumentSize>");
						ipXMLBuffer.append(size);
						ipXMLBuffer.append("</DocumentSize>\n");
						ipXMLBuffer.append("<CreatedByAppName>");
						ipXMLBuffer.append(createdByAppName);
						ipXMLBuffer.append("</CreatedByAppName>\n");
						ipXMLBuffer.append("</Document>\n");
						ipXMLBuffer.append("</NGOAddDocument_Input>\n");
						String NGOaddDocInputXML =  ipXMLBuffer.toString();
						CustOutreachLog.KYCcustOutreachLogger.debug("NGOaddDocInputXML--- " + NGOaddDocInputXML);
						String NGOaddDocOutXml = CommonMethods.WFNGExecute(NGOaddDocInputXML,jtsIP, jtsPort, 1);
						CustOutreachLog.KYCcustOutreachLogger.debug("NGOaddDocOutXml--- " + NGOaddDocOutXml);
						
						XMLParser xmlParserAddDoc = new XMLParser(NGOaddDocOutXml);
						CustOutreachLog.KYCcustOutreachLogger.debug("xmlParserAddDoc--- " + xmlParserAddDoc);
						String addDocMainCode = xmlParserAddDoc.getValueOf("Status");
						CustOutreachLog.KYCcustOutreachLogger.debug("addDocMainCode--- " + addDocMainCode);
						if (addDocMainCode.equalsIgnoreCase("0")) 
						{
							CustOutreachLog.KYCcustOutreachLogger.debug("Document "+fileName+" added successfully");
							updateUploadFlag(WINAME,"Y",fileNameWithoutExt);
							Date d = new Date();
							SimpleDateFormat dateFormat = new SimpleDateFormat("dd-MM-yyyy");
							String strDate = dateFormat.format(d);
							strDate = strDate.replaceAll("-", "");
							String targetPath = SuccessPath+File.separator+WINAME+strDate;
							moveFile(FullPath,targetPath,fileName);
						}
						else
						{
							CustOutreachLog.KYCcustOutreachLogger.debug("Error in adding Document--> "+fileName+" in AddDocument Call.");
							updateUploadFlag(WINAME,"N",fileNameWithoutExt);
							Date d = new Date();
							SimpleDateFormat dateFormat = new SimpleDateFormat("dd-MM-yyyy");
							String strDate = dateFormat.format(d);
							strDate = strDate.replaceAll("-", "");
							String targetPath = ErrorPath+File.separator+WINAME+File.separator+strDate;
							moveFile(FullPath,targetPath,fileName);
						}
						}catch(JPISException e){
							CustOutreachLog.KYCcustOutreachLogger.debug("Inside exception--"+e);
							final Writer result1 = new StringWriter();
							final PrintWriter printWriter = new PrintWriter(result1);
							e.printStackTrace(printWriter);
							String msg=e.getMessage();
							boolean status=false;
							e.printStackTrace();
						}
					}
				}
				DoneWI(WINAME,"",OutreachupdateDateTime);
				DocsList.clear();
			}else{
				CustOutreachLog.KYCcustOutreachLogger.debug("Documents not found in "+WINAME+"folder");
				 boolean status = HoursPassed(OutreachupdateDateTime);
				 if(status)
					 DoneWI(WINAME,"NoDocument",OutreachupdateDateTime);
				 		DocsList.clear();
			}
		  }else{
			  CustOutreachLog.KYCcustOutreachLogger.debug("Directory does not exist for --"+WINAME);
			  boolean status = HoursPassed(OutreachupdateDateTime);
			  if(status)
				  DoneWI(WINAME,"FolderNotPresent",OutreachupdateDateTime);
			  			DocsList.clear();
		  }
		}
		}catch(Exception e){
			CustOutreachLog.KYCcustOutreachLogger.debug("Exception occured in startUtilityCustOutreach --"+e.getMessage());
		}
	}

	private void DoneWI(String WINAME,String flag,String OutreachupdateDateTime) {
		try{
			String decision = "";
			String Remark = "";
			//String Status = "";
			getListDocsToBeAttachedUploadFlagStatus(WINAME, DocsList);
			if(DocsList.isEmpty()){
				decision = "Submit to Maker";
				Remark = "Outreach complete through Online Portal";
				//Status = "Complete";
				CompleteWI(WINAME,decision,Remark);
			}
			else{
				decision = "Error";
				if("NoDocument".equalsIgnoreCase(flag))
					Remark = "Documents not found at location";
				else if("FolderNotPresent".equalsIgnoreCase(flag))
					Remark = "Folder not present with name-->"+WINAME+"at location";
				else
					Remark = "Not all Outreach Docs Attached or received";
				boolean hours48 = HoursPassed(OutreachupdateDateTime);
				if(hours48)
					CompleteWI(WINAME,decision,Remark);
				else
					CustOutreachLog.KYCcustOutreachLogger.debug("Waiting for 48 hours to receive docs for - "+WINAME);
			}
		}catch(Exception e){
			CustOutreachLog.KYCcustOutreachLogger.debug("Exception in DoneWI ");
		}
	}

	private void CompleteWI(String WINAME,String decision,String Remark) {
		try{
		String WorkItemID = "";
		String ActivityID = "";
		String ProcessDefID = "";
		String EntryDateTime = "";
		String query = "select Workitemid,ActivityId,ProcessDefID,EntryDateTime from WFINSTRUMENTTABLE where ProcessInstanceID = '"+WINAME+"'";
		String dataInputXML = CommonMethods.apSelectWithColumnNames(query, cabinetName, sessionID);
		String dataOutputXML = CommonMethods.WFNGExecute(dataInputXML, jtsIP, jtsPort, 1);
		XMLParser dataxmlParserAPSelect = new XMLParser(dataOutputXML);
		String dataMainCode = dataxmlParserAPSelect.getValueOf("MainCode");
		int dataTotalRecords = Integer.parseInt(dataxmlParserAPSelect.getValueOf("TotalRetrieved"));
		if (dataMainCode.equals("0") && dataTotalRecords > 0) {
			WorkItemID = dataxmlParserAPSelect.getValueOf("Workitemid");
			ActivityID = dataxmlParserAPSelect.getValueOf("ActivityID");
			ProcessDefID =  dataxmlParserAPSelect.getValueOf("ProcessDefID");
			EntryDateTime = dataxmlParserAPSelect.getValueOf("EntryDateTime");
			
		String getWorkItemInputXML = CommonMethods.getWorkItemInput(cabinetName, sessionID, WINAME,WorkItemID);
		String getWorkItemOutputXml = CommonMethods.WFNGExecute(getWorkItemInputXML,jtsIP,jtsPort,1);
		CustOutreachLog.KYCcustOutreachLogger.debug("Output XML For WmgetWorkItemCall: "+ getWorkItemOutputXml);
		
		XMLParser xmlParserGetWorkItem = new XMLParser(getWorkItemOutputXml);
		String getWorkItemMainCode = xmlParserGetWorkItem.getValueOf("MainCode");
		CustOutreachLog.KYCcustOutreachLogger.debug("WmgetWorkItemCall Maincode:  "+ getWorkItemMainCode);
		if (getWorkItemMainCode.trim().equals("0")){
			
			String assignInputXML = "<?xml version=\"1.0\"?><WMAssignWorkItemAttributes_Input>"
                    + "<Option>WMAssignWorkItemAttributes</Option>"
                    + "<EngineName>"+cabinetName+"</EngineName>"
                    + "<SessionId>"+sessionID+"</SessionId>"
                    + "<ProcessInstanceId>"+WINAME+"</ProcessInstanceId>"
                    + "<WorkItemId>"+WorkItemID+"</WorkItemId>"
                    + "<ActivityId>"+ActivityID+"</ActivityId>"
                    + "<ProcessDefId>"+ProcessDefID+"</ProcessDefId>"
                    + "<LastModifiedTime></LastModifiedTime>"
                    + "<ActivityType></ActivityType>"
                    + "<complete>D</complete>"
                    + "<AuditStatus></AuditStatus>"
                    + "<Comments></Comments>"
                    + "<UserDefVarFlag>Y</UserDefVarFlag>"
                    + "<Attributes><DECISION>"+decision+"</DECISION></Attributes>"
                    + "</WMAssignWorkItemAttributes_Input>";


			CustOutreachLog.KYCcustOutreachLogger.debug("assignInputXML--- "+assignInputXML);
			String assignOutXml = CommonMethods.WFNGExecute(assignInputXML, jtsIP, jtsPort, 1);
			CustOutreachLog.KYCcustOutreachLogger.debug("assignOutXml--- "+assignOutXml);
			XMLParser xmlParserAPSelectFinal = new XMLParser(assignOutXml);
			String xmlParserAPSelectFinalMaincode = xmlParserAPSelectFinal.getValueOf("MainCode");
			if (xmlParserAPSelectFinalMaincode.equalsIgnoreCase("0")){
				
				Date d = new Date();
				SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
				String strDate = dateFormat.format(d);
				
				String tableName = "NG_KYC_REM_GR_HISTORY";
				String columnName = "DateTime,Workstep,Decision,UserName,Remarks,WI_Name,Entry_Date_Time";
				String values = "'"+strDate+"','RM_Vendor','"+decision+"','rakBPMutility','"+Remark+"','"+WINAME+"','"+EntryDateTime+"'";
				
				String apInsertInputXML=CommonMethods.apInsert(cabinetName, sessionID, columnName,values,tableName);
				CustOutreachLog.KYCcustOutreachLogger.debug("APInsertInputXML: "+apInsertInputXML);

				String apInsertOutputXML =CommonMethods.WFNGExecute(apInsertInputXML, jtsIP, jtsPort, 1);
				CustOutreachLog.KYCcustOutreachLogger.debug("APInsertOutputXML: "+ apInsertOutputXML);

				XMLParser xmlParserAPInsert = new XMLParser(apInsertOutputXML);
				String apInsertMaincode = xmlParserAPInsert.getValueOf("MainCode");
				CustOutreachLog.KYCcustOutreachLogger.debug("Status of apInsertMaincode  "+ apInsertMaincode);
				if(apInsertMaincode.equalsIgnoreCase("0"))
				{
					CustOutreachLog.KYCcustOutreachLogger.debug("ApInsert successful: "+apInsertMaincode);
					CustOutreachLog.KYCcustOutreachLogger.debug("Data Inserted in history table successfully.");
				}
			}
		}
		}
		}catch(Exception e){
			CustOutreachLog.KYCcustOutreachLogger.debug("Exception in Complete WI ");
		}
	}
	
	private boolean HoursPassed(String outreachDateTime) {
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
		try {
			Date date = sdf.parse(outreachDateTime) ;
			Calendar calender = Calendar.getInstance();
			calender.setTime(date);
			calender.add(Calendar.HOUR_OF_DAY,48);
			Date date48 = calender.getTime();
			Date now = new Date();
			if(now.after(date48)){
				CustOutreachLog.KYCcustOutreachLogger.debug("48 hours have passed");
				return true;
			}
			else{
				CustOutreachLog.KYCcustOutreachLogger.debug("48 hours have not passed");
			}
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return false;
	}


	public static boolean moveFile(String sourcePath,String targetPath,String FileName)
	{
		boolean fileMoved = true;
		Path targetDirecoty = null;
		Path targetDirectory = Paths.get(targetPath);
		if(!Files.exists(targetDirectory)){
				File f1 = new File(targetPath);
				f1.mkdirs();
		}
		try{
			Files.move(Paths.get(sourcePath),Paths.get(targetPath+File.separator+FileName), StandardCopyOption.REPLACE_EXISTING);
		}
		catch(Exception e){
			CustOutreachLog.KYCcustOutreachLogger.debug("exception in moving file"+e.getMessage());
			fileMoved = false;
		}
		return fileMoved;
	}
	
	public String updateUploadFlag(String processinstanceID,String flag,String DocumentName){
		/*//indexes += "'"+index+"|'";
		indexes = "'"+indexes+index+"|'";*/
		try{
		String columnName = "UploadFlag,UploadDateTime";
		Date d = new Date();
		SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		String strDate = dateFormat.format(d);
		String values = "'"+flag+"','"+strDate+"'";
		String whereClause = "WINAME = '"+processinstanceID+"' AND DocName = '"+DocumentName+"'";
		String apUpdateInputXML = CommonMethods.apUpdateInput(cabinetName, sessionID,"NG_KYC_REM_Outreach_Docs_GRID",columnName,values, whereClause);
		CustOutreachLog.KYCcustOutreachLogger.debug("apUpdateInputXML: "+apUpdateInputXML);
		String apUpdateOutputXML = CommonMethods.WFNGExecute(apUpdateInputXML, jtsIP, jtsPort, 1);
		CustOutreachLog.KYCcustOutreachLogger.debug("apUpdateOutputXML: "+apUpdateOutputXML);
		XMLParser xmlParserAPUpdate = new XMLParser(apUpdateOutputXML);
		String apUpdateMaincode = xmlParserAPUpdate.getValueOf("MainCode");
		if (apUpdateMaincode.equalsIgnoreCase("0")) 
		{
			CustOutreachLog.KYCcustOutreachLogger.debug("apUpdateOutputXML for Upload Flag: "+apUpdateOutputXML);
		}
		}catch(Exception e){
			
		}
		return "";
	}
	
	private String getFolderIndex(String WINAME) {
		try{
		String query = "Select folderindex from pdbfolder with(nolock) where name = '"+ WINAME + "'";
		String apSelectInputXML = CommonMethods.apSelectWithColumnNames(query,cabinetName, sessionID);
		CustOutreachLog.KYCcustOutreachLogger.debug("apSelectInputXML--- " + apSelectInputXML);
		String apSelectOutXml = CommonMethods.WFNGExecute(apSelectInputXML, jtsIP,jtsPort, 1);
		CustOutreachLog.KYCcustOutreachLogger.debug("apSelectOutXml--- " + apSelectOutXml);
		XMLParser xmlParserAPSearchfolderIndex = new XMLParser(apSelectOutXml);
		CustOutreachLog.KYCcustOutreachLogger.debug("xmlParserAPSearchfolderIndex--- " + xmlParserAPSearchfolderIndex);
		String apSearchMaincodefolderIndex = xmlParserAPSearchfolderIndex.getValueOf("MainCode");
		CustOutreachLog.KYCcustOutreachLogger.debug("apSearchMaincodefolderIndex--- " + apSearchMaincodefolderIndex);
		String parentFolderIndex = "";
		if (apSearchMaincodefolderIndex.equalsIgnoreCase("0")) 
		{
			CustOutreachLog.KYCcustOutreachLogger.debug("inside if of apSearchMaincodefolderIndex");
			parentFolderIndex = xmlParserAPSearchfolderIndex.getValueOf("folderindex");
			CustOutreachLog.KYCcustOutreachLogger.debug("parentFolderIndex--- "+parentFolderIndex);
			return parentFolderIndex;
		}
		}catch(Exception e){
			CustOutreachLog.KYCcustOutreachLogger.debug("Exception occured in getting parent Folder Index");
		}
		return "Error";
	}


	private List<String> getListDocsToBeAttachedUploadFlagStatus(String WINAME,List<String> DocsList) {
		try{
		String Query1 = "SELECT DocType FROM NG_KYC_REM_Outreach_Docs_GRID with (nolock) WHERE WINAME = '"+WINAME+"' AND UploadFlag IS NULL OR UploadFlag = '' OR UploadFlag = 'N'";
		String ApSelectInputXML = CommonMethods.apSelectWithColumnNames(Query1, cabinetName,sessionID);
		String ApSelectOutputXML = CommonMethods.WFNGExecute(ApSelectInputXML, jtsIP, jtsPort, 1);
		XMLParser xmlParserAPSelect = new XMLParser(ApSelectOutputXML);
		String apSelectMaincode = xmlParserAPSelect.getValueOf("MainCode");
		int TotalRecords = Integer.parseInt(xmlParserAPSelect.getValueOf("TotalRetrieved"));
		if (apSelectMaincode.equals("0") && TotalRecords > 0) {
			//start from here
			NGXmlList objWorkList = xmlParserAPSelect.createList("Records","Record");
			CustOutreachLog.KYCcustOutreachLogger.debug("objWorkList " + objWorkList);
			for (; objWorkList.hasMoreElements(true); objWorkList.skip(true)) 
			{
				String docDetail = xmlParserAPSelect.getNextValueOf("Record");
				XMLParser xmlDocDetail = new XMLParser(docDetail);
				String DocType = xmlDocDetail.getValueOf("DocType");
				CustOutreachLog.KYCcustOutreachLogger.debug("DocType from outreach grid is --> " + DocType);
				DocsList.add(DocType);
			}
		}
		}catch(Exception e){
			CustOutreachLog.KYCcustOutreachLogger.debug("Exception occured in getDocsToBeAttached method --"+e.getMessage());
		}
		return DocsList;
		
	}


	private static List<Map<String, String>> getDataFromDBMap(String query, String cabinetName, String sessionID,
			String jtsIP, String jtsPort) {
		List<Map<String, String>> temp = new ArrayList<Map<String, String>>();
		try {
			CustOutreachLog.KYCcustOutreachLogger.debug("Inside function getDataFromDB");
			CustOutreachLog.KYCcustOutreachLogger.debug("getDataFromDB query is: " + query);
			String InputXML = CommonMethods.apSelectWithColumnNames(query, cabinetName, sessionID);
			String OutXml = CommonMethods.WFNGExecute(InputXML, jtsIP, jtsPort, 1);
			OutXml = OutXml.replaceAll("&", "#andsymb#");
			Document recordDoc1 = MapXML.getDocument(OutXml);
			NodeList records1 = recordDoc1.getElementsByTagName("Record");
			if (records1.getLength() > 0) {
				for (int i = 0; i < records1.getLength(); i++) {
					Node n = records1.item(i);
					Map<String, String> t = new HashMap<String, String>();
					if (n.hasChildNodes()) {
						NodeList child = n.getChildNodes();
						for (int j = 0; j < child.getLength(); j++) {
							Node n1 = child.item(j);
							String column = n1.getNodeName();
							String value = n1.getTextContent().replaceAll("#andsymb#", "&");
							if (null != value && !"null".equalsIgnoreCase(value) && !"".equals(value)) {
								//CustOutreachLog.KYCcustOutreachLogger.debug("getDataFromDBMap Setting value of " + column + " as " + value);
								t.put(column, value);
							} else {
								//CustOutreachLog.KYCcustOutreachLogger.debug("getDataFromDBMap Setting value of " + column + " as blank");
								t.put(column, "");
							}
						}
					}
					temp.add(t);
				}
			}

		} catch (Exception e) {
			CustOutreachLog.KYCcustOutreachLogger.debug("Exception occured in getDataFromDBMap method" + e.getMessage());
		}
		return temp;
	}
	
}
