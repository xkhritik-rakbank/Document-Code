<%@ page import="java.util.*"%>
<%@ page import="java.io.*"%>
<%@ page import="java.text.*"%>
<%@ page import="java.net.*"%>
<%@ page import="com.newgen.wfdesktop.xmlapi.*" %>
<%@ page import="com.newgen.wfdesktop.util.*" %>
<%@ page import="com.newgen.wfdesktop.util.xmlapi.*" %>
<%@ page import="com.newgen.custom.wfdesktop.exception.*" %>
<%@ page import="com.newgen.custom.*" %>
<%@ page import="java.io.UnsupportedEncodingException" %>
<%@ page import="com.newgen.omni.wf.util.app.NGEjbClient"%>
<%@ page import="com.newgen.omni.wf.util.excp.NGException"%>
<%@ page import="com.newgen.custom.wfdesktop.xmlapi.*" %>
<%@ page import="com.newgen.custom.wfdesktop.util.*" %>
<%@ page import="com.newgen.custom.wfdesktop.util.xmlapi.*" %>
<%@ page import="com.newgen.custom.wfdesktop.exception.*" %>
<%@ page import="com.newgen.custom.*" %>
<%@ page import="java.util.Properties"%>
<%@ page import="java.io.FileInputStream"%>
<%@ page import="java.io.FileNotFoundException"%>
<%@ page import="java.sql.Clob"%>
<%@ page import="java.sql.Connection"%>
<%@ page import="java.sql.DriverManager"%>
<%@ page import="java.sql.PreparedStatement"%>
<%@ page import="java.sql.SQLException"%>
<%@ page import="adminclient.OSASecurity" %>
<%@ page import="java.io.IOException,java.sql.Connection,java.sql.ResultSet,java.sql.Statement,javax.naming.Context,javax.naming.InitialContext,javax.servlet.Servlet,javax.servlet.ServletException,javax.servlet.http.HttpServlet,javax.servlet.http.HttpServletRequest,javax.servlet.http.HttpServletResponse,javax.sql.DataSource" %>
<%@ include file="../TWC_Specific/Log.process"%>
<jsp:useBean id="customSession" class="com.newgen.custom.wfdesktop.session.WFCustomSession" scope="session"/>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
	createLogFile("TWC_Copy_Profile");
	try
	{
		String EventType= request.getParameter("EventType");
		logger.info("Event for this call of JSP is :-->"+EventType);
		
		/* String username = request.getParameter("LoggedInUSER");
		if (username != null) {username=username.replace("'","");}	
		logger.info("String copy Profile--Logged in user is :-->"+username); */
		
		String username ="";
		String WI_NUMBER= request.getParameter("WI_NAME");
		if (WI_NUMBER != null) {WI_NUMBER=WI_NUMBER.replace("'","");}	
		
		String CIF_ID= request.getParameter("CIF_ID");
		if (CIF_ID != null) {CIF_ID=CIF_ID.replace("'","");}
		
		String TL_NUMBER= request.getParameter("TL_NUMBER");
		if (TL_NUMBER != null) {TL_NUMBER=TL_NUMBER.replace("'","");}
		
		String srchOption=request.getParameter("srchOption");
		String srchInput=request.getParameter("srchInput");
		if (srchInput != null) {srchInput=srchInput.replace("'","");}
		
		String ReferenceNo=request.getParameter("ReferenceNo");
		if (ReferenceNo != null) {ReferenceNo=ReferenceNo.replace("'","");}
				
		String sessionID = request.getParameter("sessionID");
		if (sessionID != null) {sessionID=sessionID.replace("'","");}	
		logger.info(" copy Profile--session :-->"+sessionID);
		
		logger.info("srchOption123 -->"+srchOption);
		logger.info("srchInput123 -->"+srchInput);
		logger.info("WI_NUMBER123 -->"+WI_NUMBER);
		logger.info("CIF_ID123 -->"+CIF_ID);
		logger.info("TL_NUMBER123 -->"+TL_NUMBER);
		
		String strPropFilePath= System.getProperty("user.dir") + File.separator + "CustomConfig" + File.separator + "TWC_Config.properties";
		logger.info("Inside strPropFilePath: "+strPropFilePath);
		Properties p =  new Properties();
		p.load(new FileInputStream(strPropFilePath));
		
		String OFcabinetName = p.getProperty("OFCabinetName");
				
		String sSessionId = sessionID;
		String sCabName= p.getProperty("iBPSCabinetName");	
		String sJtsIp = p.getProperty("iBPSAppServerIP");
		int iJtsPort = Integer.parseInt(p.getProperty("iBPSAppServerPort"));
		
		
		//logger.info("Starting Copy Profile Page for sessionID:-->"+sSessionId123);
		//logger.info("debug_TWC_CP--sCabName maincode-->"+sCabName);
		//logger.info("debug_TWC_CP--sJtsIp maincode-->"+sJtsIp);			
		//logger.info("debug_TWC_CP--iJtsPort -->"+iJtsPort);
		
		//logger.info("OFcabinetName :-->"+OFcabinetName);		
		
		if(!"getHeaderDtls".equals(EventType))
		{
			if(!("".equalsIgnoreCase(sessionID) || sessionID == null) )
			{
				//String sessionID_Query = "select SessionID from WFSESSIONVIEW with(nolock) where UserID = (select userindex from WFUSERVIEW with(nolock) where username='"+username+"')";
				String sessionID_Query = "select username from WFUSERVIEW with(nolock) where userindex=(select UserID from WFSESSIONVIEW with(nolock) where  SessionID='"+sessionID+"') and userindex in(select UserIndex from PDBGroupMember where GroupIndex in (select Userid from QUEUEUSERTABLE with(nolock) where AssociationType=1 and QueueId in (select QueueID from  QUEUEDEFTABLE with(nolock) where QueueName = 'TWC_Initiation')))";
				logger.info("Query to get userName fro current session:-->"+sessionID_Query);
				String sessionID_sOutputXML="";
				String sessionID_sInputXML="";
				WFCustomXmlResponse xmlParserData1=null; 
				sessionID_sInputXML = "<?xml version='1.0'?><APSelectWithColumnNames_Input><Option>APSelectWithColumnNames</Option><Query>" + sessionID_Query + "</Query><EngineName>" + sCabName + "</EngineName></APSelectWithColumnNames_Input>";
				logger.info("historyDet_sInputXML -->"+sessionID_sInputXML);	
				if(String.valueOf(iJtsPort).contains("33"))
				{
					sessionID_sOutputXML = WFCustomCallBroker.execute(sessionID_sInputXML, sJtsIp, iJtsPort, 1);
				}
				else
				{
					sessionID_sOutputXML = NGEjbClient.getSharedInstance().makeCall(sJtsIp,String.valueOf(iJtsPort),"WebSphere", sessionID_sInputXML);
				}
				
				xmlParserData1=new WFCustomXmlResponse();
				xmlParserData1.setXmlString((sessionID_sOutputXML));
				int iTotalrec1=0;
				if(sessionID_sOutputXML.contains("TotalRetrieved"))
				{
					String TotalRetrievedvalue1 = xmlParserData1.getVal("TotalRetrieved");	
					logger.info("TotalRetrievedvalue1 -->"+TotalRetrievedvalue1);
					iTotalrec1=Integer.parseInt(TotalRetrievedvalue1);
					logger.info("iTotalrec1 -->"+iTotalrec1);
				}
				
				if (xmlParserData1.getVal("MainCode").equalsIgnoreCase("0") && iTotalrec1 > 0)
				{
					username=xmlParserData1.getVal("username");
					logger.info("Starting Copy Profile Page for sessionID:-->"+sSessionId);
				}
				else
				{
					out.println("invalidSession");
				}
			}
			else
			{
				out.println("invalidSession");
			}
		}
		
		if("getHeaderDtls".equals(EventType))
		{
			try
			{
				String refNo=getServerDateTime();
				Random randno= new Random();
				if(refNo.contains(" "))
				{
					logger.info(refNo);
					refNo=refNo.replace(" ", String.valueOf(randno.nextInt(9)));
					logger.info(refNo);
				}
				String refNoEncrypted=encrypt(refNo);
				out.println(refNo+"|#|"+refNoEncrypted);
			}
			catch(Exception e)
			{
				out.println("Exception");
			}
		}
		if("onLoad".equals(EventType))
		{
			String historyDet_Query = "select Top 10  Sel_WI_No,Reference_No,Sub_User_Name,Sub_Date_Time,CIF_Id,TL_Number,Customer_Name,RAK_Track_Number,New_WI_Number,New_WI_Created_DT,New_WI_Creation_Flag,Case_Status,Searched_WI_Environment from USR_0_TWC_Copy_Profile_Details with(nolock) where Sub_User_Name='"+username+"' order by Sub_Date_Time desc";
			String historyDet_sOutputXML="";
			String historyDet_sInputXML="";
			WFCustomXmlResponse xmlParserData1=null; 
			String historyDet_returnValues="";
			historyDet_sInputXML = "<?xml version='1.0'?><APSelectWithColumnNames_Input><Option>APSelectWithColumnNames</Option><Query>" + historyDet_Query + "</Query><EngineName>" + sCabName + "</EngineName><SessionId>" + sSessionId + "</SessionId></APSelectWithColumnNames_Input>";
			logger.info("historyDet_sInputXML -->"+historyDet_sInputXML);	
			if(String.valueOf(iJtsPort).contains("33"))
			{
				historyDet_sOutputXML = WFCustomCallBroker.execute(historyDet_sInputXML, sJtsIp, iJtsPort, 1);
			}
			else
			{
				historyDet_sOutputXML = NGEjbClient.getSharedInstance().makeCall(sJtsIp,String.valueOf(iJtsPort),"WebSphere", historyDet_sInputXML);
			}
			
			logger.info("historyDet_sOutputXML -->"+historyDet_sOutputXML);
			
			xmlParserData1=new WFCustomXmlResponse();
			xmlParserData1.setXmlString((historyDet_sOutputXML));
			String subxml1 ="";
			int iTotalrec1=0;
			if(historyDet_sOutputXML.contains("TotalRetrieved"))
			{
				String TotalRetrievedvalue1 = xmlParserData1.getVal("TotalRetrieved");	
				logger.info("TotalRetrievedvalue1 -->"+TotalRetrievedvalue1);
				iTotalrec1=Integer.parseInt(TotalRetrievedvalue1);
				logger.info("iTotalrec1 -->"+iTotalrec1);
			}
			
			if (xmlParserData1.getVal("MainCode").equalsIgnoreCase("0") && iTotalrec1 > 0)
			{
				logger.info("inisde if main code 0 and records are more than 3 -->");
				WFCustomXmlList objWorkList=null;
				objWorkList = xmlParserData1.createList("Records","Record"); 
				for(objWorkList.reInitialize(true);objWorkList.hasMoreElements(true);objWorkList.skip(true))
				{	
					//subxml1 = xmlParserData1.getNextValueOf("Record");				 
					//ObjXMLParser1=new XMLParser(subxml1);
					
					//logger.info("inisde for loop " );
					
					String Reference_No = objWorkList.getVal("Reference_No");
					historyDet_returnValues=historyDet_returnValues+Reference_No+"#~#";
					//logger.info("Reference_No -->"+Reference_No);
					
					String Sub_User_Name = objWorkList.getVal("Sub_User_Name");
					historyDet_returnValues=historyDet_returnValues+Sub_User_Name+"#~#";
					//logger.info("Sub_User_Name -->"+Sub_User_Name);
					
					String Sub_Date_Time = objWorkList.getVal("Sub_Date_Time");
					historyDet_returnValues=historyDet_returnValues+Sub_Date_Time+"#~#";
					//logger.info("Sub_Date_Time -->"+Sub_Date_Time);
					
					String CIF_Id = objWorkList.getVal("CIF_Id");
					historyDet_returnValues=historyDet_returnValues+CIF_Id+"#~#";
					//logger.info("CIF_Id -->"+CIF_Id);
					
					String TL_Number = objWorkList.getVal("TL_Number");
					historyDet_returnValues=historyDet_returnValues+TL_Number+"#~#";
					//logger.info("TL_Number -->"+TL_Number);
					
					String Customer_Name = objWorkList.getVal("Customer_Name");
					historyDet_returnValues=historyDet_returnValues+Customer_Name+"#~#";
					//logger.info("Customer_Name -->"+Customer_Name);
					
					String RAK_Track_Number = objWorkList.getVal("RAK_Track_Number");
					historyDet_returnValues=historyDet_returnValues+RAK_Track_Number+"#~#";
					//logger.info("RAK_Track_Number -->"+RAK_Track_Number);
					
					String Sel_WI_No = objWorkList.getVal("Sel_WI_No");
					historyDet_returnValues=historyDet_returnValues+Sel_WI_No+"#~#";
					//logger.info("Sel_WI_No -->"+Sel_WI_No);
					
					String New_WI_Number = objWorkList.getVal("New_WI_Number");
					historyDet_returnValues=historyDet_returnValues+New_WI_Number+"#~#";
					//logger.info("New_WI_Number -->"+New_WI_Number);
					
					String New_WI_Created_DT = objWorkList.getVal("New_WI_Created_DT");
					historyDet_returnValues=historyDet_returnValues+New_WI_Created_DT+"#~#";
					//logger.info("New_WI_Created_DT -->"+New_WI_Created_DT);
					
					String New_WI_Creation_Flag = objWorkList.getVal("New_WI_Creation_Flag");
					historyDet_returnValues=historyDet_returnValues+New_WI_Creation_Flag+"#~#";
					//logger.info("New_WI_Creation_Flag -->"+New_WI_Creation_Flag);
					
					String Case_Status = objWorkList.getVal("Case_Status");
					historyDet_returnValues=historyDet_returnValues+Case_Status+"#~#";
					//logger.info("Case_Status -->"+Case_Status);
					
					String Searched_WI_Environment = objWorkList.getVal("Searched_WI_Environment");
					historyDet_returnValues=historyDet_returnValues+Searched_WI_Environment+"|#|";				
					//logger.info("Searched_WI_Environment -->"+Searched_WI_Environment);
			
					//logger.info("historyDet_returnValues -->"+historyDet_returnValues);
					
				}
				
					
			}
			out.clear();
			out.println(historyDet_returnValues);	
			logger.info("username--historyDet_returnValues -->"+username+"#~#"+historyDet_returnValues);
			
			
			
		}
		else if(EventType.equals("onSearch"))
		{
			logger.info("EventTypewi_number -->"+EventType);
			logger.info("srchOptionwi_number -->"+srchOption);
			logger.info("srchInputwi_number -->"+srchInput);
			
			String IBPS_Query="select WI_NAME,CIF_Id,TL_Number,Customer_Name,RAK_Track_Number,IntoducedAt,Current_WS,entryat,channel,'IBPS' as Environment from RB_TWC_EXTTABLE with(nolock) where (WI_NAME='"+srchInput+"' or CIF_Id='"+srchInput+"' or TL_Number='"+srchInput+"' or Customer_Name='"+srchInput+"' or RAK_Track_Number='"+srchInput+"') and Current_WS='Exit' order by IntoducedAt desc";
			
			logger.info("IBPS_Query -->"+IBPS_Query);
			
			String ibps_sOutputXML="";
			String ibps_sInputXML="";
			String FinalSearchresult="";
			String iBPS_returnValues="";
			WFCustomXmlResponse xmlParserData=null; 
			
					
			ibps_sInputXML = "<?xml version='1.0'?><APSelectWithColumnNames_Input><Option>APSelectWithColumnNames</Option><Query>" + IBPS_Query + "</Query><EngineName>" + sCabName + "</EngineName><SessionId>" + sSessionId + "</SessionId></APSelectWithColumnNames_Input>";
			
			
			logger.info("WIName_sInputXML -->"+ibps_sInputXML);	
			
			if(String.valueOf(iJtsPort).contains("33"))
			{
				//ibps_sOutputXML = WFCallBroker.execute(ibps_sInputXML, sJtsIp, iJtsPort, 1);
				ibps_sOutputXML = WFCustomCallBroker.execute(ibps_sInputXML, sJtsIp, iJtsPort, 1);
			}
			else
			{
				ibps_sOutputXML = NGEjbClient.getSharedInstance().makeCall(sJtsIp, String.valueOf(iJtsPort),"WebSphere", ibps_sInputXML);
			}
				
			
				
			logger.info("ibps_sOutputXML -->"+ibps_sOutputXML);
			
			xmlParserData=new WFCustomXmlResponse();
			xmlParserData.setXmlString((ibps_sOutputXML));
			
			//XMLParser ObjXMLParser=null;
			int iTotalrec=0;
			if(ibps_sOutputXML.contains("TotalRetrieved"))
			{
				String TotalRetrievedvalue = xmlParserData.getVal("TotalRetrieved");	
				iTotalrec=Integer.parseInt(TotalRetrievedvalue);
			}
			if (xmlParserData.getVal("MainCode").equalsIgnoreCase("0") && iTotalrec > 0)
			{
								
				WFCustomXmlList objWorkList=null;
				objWorkList = xmlParserData.createList("Records","Record"); 
				for(objWorkList.reInitialize(true);objWorkList.hasMoreElements(true);objWorkList.skip(true))
				{
					String iBPS_WI_NAME = objWorkList.getVal("WI_NAME");
					iBPS_returnValues=iBPS_returnValues+iBPS_WI_NAME+"#~#";
					String iBPS_CIF_Id = objWorkList.getVal("CIF_Id");
					iBPS_returnValues=iBPS_returnValues+iBPS_CIF_Id+"#~#";
					String iBPS_TL_Number = objWorkList.getVal("TL_Number");
					iBPS_returnValues=iBPS_returnValues+iBPS_TL_Number+"#~#";
					String iBPS_Customer_Name = objWorkList.getVal("Customer_Name");
					iBPS_returnValues=iBPS_returnValues+iBPS_Customer_Name+"#~#";
					String iBPS_RakTrackNO = objWorkList.getVal("RAK_Track_Number");
					iBPS_returnValues=iBPS_returnValues+iBPS_RakTrackNO+"#~#";
					String iBPS_createdDateTime = objWorkList.getVal("IntoducedAt");
					iBPS_returnValues=iBPS_returnValues+iBPS_createdDateTime+"#~#";
					String iBPS_Current_WS = objWorkList.getVal("Current_WS");
					iBPS_returnValues=iBPS_returnValues+iBPS_Current_WS+"#~#";
					String iBPS_entryat = objWorkList.getVal("entryat");
					iBPS_returnValues=iBPS_returnValues+iBPS_entryat+"#~#";
					String iBPS_channel = objWorkList.getVal("channel");
					iBPS_returnValues=iBPS_returnValues+iBPS_channel+"#~#";
					String environment = objWorkList.getVal("Environment");
					iBPS_returnValues=iBPS_returnValues+environment+"#~#";
					String iBPS_WI_NAME_enc = encrypt(iBPS_WI_NAME);
					iBPS_returnValues=iBPS_returnValues+iBPS_WI_NAME_enc+"|#|";
					
				}
				logger.info("iBPS_returnValues -->"+iBPS_returnValues);
			
			} 
			else{
				iBPS_returnValues = "";
			}
			Connection conn = null;
			Statement stmt =null;
			ResultSet result=null;
			String OF_returnValues="";
			
			try{			
					Context aContext = new InitialContext();
					DataSource aDataSource = (DataSource)aContext.lookup("jdbc/"+OFcabinetName);
					conn = (Connection)(aDataSource.getConnection());
					logger.info("got data source");
					stmt = conn.createStatement();
					String OF_Query="select WI_NAME,CIF_Id,TL_Number,Customer_Name,RAK_Track_Number,IntoducedAt,Current_WS,entryat,channel,'omniflow' as Environment from RB_TWC_EXTTABLE with(nolock) where (WI_NAME='"+srchInput+"' or CIF_Id='"+srchInput+"' or TL_Number='"+srchInput+"' or Customer_Name='"+srchInput+"' or RAK_Track_Number='"+srchInput+"') and Current_WS='Exit' order by IntoducedAt desc";
					
					logger.info("OmniFlow Query..."+OF_Query);
					result = stmt.executeQuery(OF_Query);
					logger.info("OmniFlow,result: "+result);
					
					if(result != null)
					{
						//logger.info("OF_returnValues result test 1-->");
						while(result.next())
						{ 
							//logger.info("OF_returnValues result test 1- -->");
							String OF_WI_NAME = result.getString("WI_NAME");
							OF_returnValues=OF_returnValues+OF_WI_NAME+"#~#";
							String OF_CIF_Id = result.getString("CIF_Id");
							OF_returnValues=OF_returnValues+OF_CIF_Id+"#~#";
							String OF_TL_Number = result.getString("TL_Number");
							OF_returnValues=OF_returnValues+OF_TL_Number+"#~#";
							String OF_Customer_Name = result.getString("Customer_Name");
							OF_returnValues=OF_returnValues+OF_Customer_Name+"#~#";
							String OF_RakTrackNO = result.getString("RAK_Track_Number");
							OF_returnValues=OF_returnValues+OF_RakTrackNO+"#~#";
							String OF_CreatedDateTime = result.getString("IntoducedAt");
							OF_returnValues=OF_returnValues+OF_CreatedDateTime+"#~#";
							String OF_Current_WS = result.getString("Current_WS");
							OF_returnValues=OF_returnValues+OF_Current_WS+"#~#";
							String OF_entryat = result.getString("entryat");
							OF_returnValues=OF_returnValues+OF_entryat+"#~#";
							String OF_channel = result.getString("channel");
							OF_returnValues=OF_returnValues+OF_channel+"#~#";
							String OF_environment = result.getString("Environment");
							OF_returnValues=OF_returnValues+OF_environment+"#~#";
							String OF_WI_NAME_enc = encrypt(OF_WI_NAME);
							OF_returnValues=OF_returnValues+OF_WI_NAME_enc+"|#|";
					
						}
						logger.info("OF_returnValues -->"+OF_returnValues);
					
					}
					else
					{
							OF_returnValues="";
				
					}
					if(result != null)
					{
						result.close();
						result=null;
						logger.info("resultset Successfully closed"); 
					}
					if(stmt != null)
					{
						stmt.close();
						stmt=null;						
						logger.info("Stmt Successfully closed"); 
					}
					if(conn != null)
					{
						conn.close();
						conn=null;	
						logger.info("Conn Successfully closed"); 
					}
					//logger.info("iBPS_returnValues -->"+iBPS_returnValues);
					//logger.info("OF_returnValues -->"+OF_returnValues);
					
			}
			catch (java.sql.SQLException e)
			{
				logger.info("SQLException -->"+e.toString());
			}
			catch(Exception e)
			{
				logger.info("Exception -->"+e.toString());
			}
			finally
			{
				if(result != null)
				{
					result.close();
					result=null;
					logger.info("resultset Successfully closed"); 
				}
				if(stmt != null)
				{
					stmt.close();
					stmt=null;						
					logger.info("Stmt Successfully closed"); 
				}
				if(conn != null)
				{
					conn.close();
					conn=null;	
					logger.info("Conn Successfully closed"); 
				}
			}
			
			out.println(iBPS_returnValues+OF_returnValues);
		}
		/*else if(EventType.equals("onSubbmit"))
		{
			logger.info("EventType_submit -->"+EventType);
			String radioButtonData=request.getParameter("rowData");
			logger.info("radioButtonData :-->"+radioButtonData);
			radioButtonData=radioButtonData.replace("'","''");
			String[] radioButtonDatavalue= radioButtonData.split(",");
			logger.info("radioButtonDatavalue :-->"+radioButtonDatavalue[0]);
			logger.info("radioButtonDatavalue :-->"+radioButtonDatavalue[1]);
			logger.info("radioButtonDatavalue :-->"+radioButtonDatavalue[2]);
			String Hist_InsertInputxml="";
			logger.info("EventType -->"+EventType);
			
			
			String hist_tableName="USR_0_TWC_Copy_Profile_Details";
			logger.info("hist_tableName -->"+hist_tableName);
			String columnnames="Sel_WI_No,CIF_Id,TL_Number,Customer_Name,RAK_Track_Number,Searched_WI_Created_DT,Searched_WI_Stage,Searched_WI_Actioned_DT,Searched_WI_Init_Channel,Searched_WI_Environment,Sub_User_Name,Reference_No";
			logger.info("columnnames -->"+columnnames);

			Hist_InsertInputxml = "<?xml version=\"1.0\"?>" +
				"<APInsert_Input>" +
				"<Option>APInsert</Option>" +
				"<TableName>"+ hist_tableName +"</TableName>" +
				"<ColName>" + columnnames + "</ColName>" +
				"<Values>" + "'"+radioButtonDatavalue[0]+"','"+radioButtonDatavalue[1]+"','"+radioButtonDatavalue[2]+"','"+ radioButtonDatavalue[3]+"','"+radioButtonDatavalue[4]+"','"+radioButtonDatavalue[5]+"','"+radioButtonDatavalue[6]+"','"+radioButtonDatavalue[7]+"','"+radioButtonDatavalue[8]+"','"+radioButtonDatavalue[9]+"','"+username+"','"+ReferenceNo+"'" + "</Values>" +
				"<EngineName>" + sCabName + "</EngineName>" +
				"<SessionId>" + sSessionId + "</SessionId>" +
				"</APInsert_Input>";

			logger.info("Hist_InsertInputxml -->"+Hist_InsertInputxml);
			String Hist_InsertOutputxml="";
			if(String.valueOf(iJtsPort).contains("33"))
			{
				//Hist_InsertOutputxml = WFCallBroker.execute(Hist_InsertInputxml, sJtsIp, iJtsPort, 1);
				Hist_InsertOutputxml = WFCustomCallBroker.execute(Hist_InsertInputxml, sJtsIp, iJtsPort, 1);
			}
			else
			{
				Hist_InsertOutputxml = NGEjbClient.getSharedInstance().makeCall(sJtsIp, String.valueOf(iJtsPort),"WebSphere", Hist_InsertInputxml);
			}
				
			WFCustomXmlResponse xmlParserData=new WFCustomXmlResponse();
			xmlParserData.setXmlString((Hist_InsertOutputxml));
			
			
			
			if (!xmlParserData.getVal("MainCode").equalsIgnoreCase("0"))
			{
				out.println("Error");
			}
			

			//Hist_InsertOutputxml= WFCallBroker.execute(Hist_InsertInputxml,sJtsIp,iJtsPort,1);
			logger.info("Hist_InsertOutputxml -->"+Hist_InsertOutputxml);
		
			
		} */
		else if(EventType.equals("onSubbmit"))
		{
			logger.info("EventType_submit -->"+EventType);
			String radioButtonData=request.getParameter("rowData");
			logger.info("radioButtonData :-->"+radioButtonData);
			radioButtonData=radioButtonData.replace("'","''");
			String[] radioButtonDatavalue= radioButtonData.split(",");
			
			String Hist_InsertInputxml="";
			logger.info("EventType -->"+EventType);
			
			String selWINo =radioButtonDatavalue[0].trim();
			String selWINoSource =radioButtonDatavalue[1].trim();
			String selWINoEnc =radioButtonDatavalue[2].trim();
			
			
			logger.info("selWINo :-->"+selWINo);
			logger.info("selWINoSource :-->"+selWINoSource);
			logger.info("selWINoEnc :-->"+selWINoEnc);
			
			String HiddenReferenceNo=request.getParameter("HiddenReferenceNo");
			if (HiddenReferenceNo != null) {HiddenReferenceNo=HiddenReferenceNo.replace("'","");}
			
			String decryptedReferenceNo = decrypt(HiddenReferenceNo.trim());
			if(!decryptedReferenceNo.equalsIgnoreCase(ReferenceNo.trim()))
			{
				out.println("Error");
			}
			String selWINodec = decrypt(selWINoEnc);
			if(!selWINodec.equalsIgnoreCase(selWINo))
			{
				out.println("Error");
			}
			
			String CIF_Id = "" ;
			String TL_Number = "" ;
			String Customer_Name = "" ;
			String RAK_Track_Number = "" ;
			String Searched_WI_Created_DT = ""; 
			String Searched_WI_Stage = "" ;
			String Searched_WI_Actioned_DT = "" ;
			String Searched_WI_Init_Channel = "" ;
			if("omniflow".equals(selWINoSource))
			{
				Connection conn = null;
				Statement stmt =null;
				ResultSet result=null;
				String OF_returnValues="";
				
				try{			
						Context aContext = new InitialContext();
						DataSource aDataSource = (DataSource)aContext.lookup("jdbc/"+OFcabinetName);
						conn = (Connection)(aDataSource.getConnection());
						logger.info("got data source");
						stmt = conn.createStatement();
						String OF_Query="select CIF_Id,TL_Number,Customer_Name,RAK_Track_Number,IntoducedAt,Current_WS,entryat,channel from RB_TWC_EXTTABLE with(nolock) where WI_NAME='"+selWINo+"'";
						
						logger.info("OmniFlow Query..."+OF_Query);
						result = stmt.executeQuery(OF_Query);
						logger.info("OmniFlow,result: "+result);
						
						if(result != null)
						{
							//logger.info("OF_returnValues result test 1-->");
							while(result.next())
							{ 
								CIF_Id = result.getString("CIF_Id");
								TL_Number = result.getString("TL_Number");
								Customer_Name = result.getString("Customer_Name");
								RAK_Track_Number = result.getString("RAK_Track_Number");
								Searched_WI_Created_DT = result.getString("IntoducedAt") ;
								Searched_WI_Stage = result.getString("Current_WS");
								Searched_WI_Actioned_DT = result.getString("entryat");
								Searched_WI_Init_Channel = result.getString("channel");
							}
						
						}
						if(result != null)
						{
							result.close();
							result=null;
							logger.info("resultset Successfully closed"); 
						}
						if(stmt != null)
						{
							stmt.close();
							stmt=null;						
							logger.info("Stmt Successfully closed"); 
						}
						if(conn != null)
						{
							conn.close();
							conn=null;	
							logger.info("Conn Successfully closed"); 
						}
						
				}
				catch (java.sql.SQLException e)
				{
					logger.info("SQLException -->"+e.toString());
				}
				catch(Exception e)
				{
					logger.info("Exception -->"+e.toString());
				}
				finally
				{
					if(result != null)
					{
						result.close();
						result=null;
						logger.info("resultset Successfully closed"); 
					}
					if(stmt != null)
					{
						stmt.close();
						stmt=null;						
						logger.info("Stmt Successfully closed"); 
					}
					if(conn != null)
					{
						conn.close();
						conn=null;	
						logger.info("Conn Successfully closed"); 
					}
				}
			}
			else
			{
				String IBPS_Query="select CIF_Id,TL_Number,Customer_Name,RAK_Track_Number,IntoducedAt,Current_WS,entryat,channel from RB_TWC_EXTTABLE with(nolock) where WI_NAME='"+selWINo+"';";
				
					logger.info("IBPS_Query -->"+IBPS_Query);
					
					String ibps_sOutputXML="";
					String ibps_sInputXML="";
					String FinalSearchresult="";
					String iBPS_returnValues="";
					WFCustomXmlResponse xmlParserData=null; 
					
							
					ibps_sInputXML = "<?xml version='1.0'?><APSelectWithColumnNames_Input><Option>APSelectWithColumnNames</Option><Query>" + IBPS_Query + "</Query><EngineName>" + sCabName + "</EngineName><SessionId>" + sSessionId + "</SessionId></APSelectWithColumnNames_Input>";
					
					
					logger.info("WIName_sInputXML -->"+ibps_sInputXML);	
					
					if(String.valueOf(iJtsPort).contains("33"))
					{
						ibps_sOutputXML = WFCustomCallBroker.execute(ibps_sInputXML, sJtsIp, iJtsPort, 1);
					}
					else
					{
						ibps_sOutputXML = NGEjbClient.getSharedInstance().makeCall(sJtsIp, String.valueOf(iJtsPort),"WebSphere", ibps_sInputXML);
					}
					logger.info("ibps_sOutputXML -->"+ibps_sOutputXML);
					
					xmlParserData=new WFCustomXmlResponse();
					xmlParserData.setXmlString((ibps_sOutputXML));
					
					//XMLParser ObjXMLParser=null;
					int iTotalrec=0;
					if(ibps_sOutputXML.contains("TotalRetrieved"))
					{
						String TotalRetrievedvalue = xmlParserData.getVal("TotalRetrieved");	
						iTotalrec=Integer.parseInt(TotalRetrievedvalue);
					}
					if (xmlParserData.getVal("MainCode").equalsIgnoreCase("0") && iTotalrec > 0)
					{
						WFCustomXmlList objWorkList=null;
						objWorkList = xmlParserData.createList("Records","Record"); 
						for(objWorkList.reInitialize(true);objWorkList.hasMoreElements(true);objWorkList.skip(true))
						{
							CIF_Id = objWorkList.getVal("CIF_Id");
							TL_Number = objWorkList.getVal("TL_Number");
							Customer_Name = objWorkList.getVal("Customer_Name");
							RAK_Track_Number = objWorkList.getVal("RAK_Track_Number");
							Searched_WI_Created_DT = objWorkList.getVal("IntoducedAt") ;
							Searched_WI_Stage = objWorkList.getVal("Current_WS");
							Searched_WI_Actioned_DT = objWorkList.getVal("entryat");
							Searched_WI_Init_Channel = objWorkList.getVal("channel");
						}
					} 
			}
			String hist_tableName="USR_0_TWC_Copy_Profile_Details";
			logger.info("hist_tableName -->"+hist_tableName);
			String columnnames="Sel_WI_No,CIF_Id,TL_Number,Customer_Name,RAK_Track_Number,Searched_WI_Created_DT,Searched_WI_Stage,Searched_WI_Actioned_DT,Searched_WI_Init_Channel,Searched_WI_Environment,Sub_User_Name,Reference_No";
			logger.info("columnnames -->"+columnnames);

			Hist_InsertInputxml = "<?xml version=\"1.0\"?>" +
				"<APInsert_Input>" +
				"<Option>APInsert</Option>" +
				"<TableName>"+ hist_tableName +"</TableName>" +
				"<ColName>" + columnnames + "</ColName>" +
				"<Values>" + "'"+selWINo+"','"+CIF_Id+"','"+TL_Number+"','"+ Customer_Name+"','"+RAK_Track_Number+"','"+Searched_WI_Created_DT+"','"+Searched_WI_Stage+"','"+Searched_WI_Actioned_DT+"','"+Searched_WI_Init_Channel+"','"+selWINoSource+"','"+username+"','"+ReferenceNo+"'" + "</Values>" +
				"<EngineName>" + sCabName + "</EngineName>" +
				"<SessionId>" + sSessionId + "</SessionId>" +
				"</APInsert_Input>";

			logger.info("Hist_InsertInputxml -->"+Hist_InsertInputxml);
			String Hist_InsertOutputxml="";
			if(String.valueOf(iJtsPort).contains("33"))
			{
				//Hist_InsertOutputxml = WFCallBroker.execute(Hist_InsertInputxml, sJtsIp, iJtsPort, 1);
				Hist_InsertOutputxml = WFCustomCallBroker.execute(Hist_InsertInputxml, sJtsIp, iJtsPort, 1);
			}
			else
			{
				Hist_InsertOutputxml = NGEjbClient.getSharedInstance().makeCall(sJtsIp, String.valueOf(iJtsPort),"WebSphere", Hist_InsertInputxml);
			}
				
			WFCustomXmlResponse xmlParserData=new WFCustomXmlResponse();
			xmlParserData.setXmlString((Hist_InsertOutputxml));
			
			
			
			if (!xmlParserData.getVal("MainCode").equalsIgnoreCase("0"))
			{
				out.println("Error");
			}
			

			//Hist_InsertOutputxml= WFCallBroker.execute(Hist_InsertInputxml,sJtsIp,iJtsPort,1);
			logger.info("Hist_InsertOutputxml -->"+Hist_InsertOutputxml);
		
			
		} 
		
		 
	}
	catch (Exception e)
	{
		logger.info("Exception occured  -->"+e.toString());
		e.printStackTrace();
		//out.println("Exception");
	}
%>

<%!
	String getServerDateTime ()
	{
		 Date date = new Date();
		 DateFormat dateFormatScanDateTime = new SimpleDateFormat("yyyyMdd HHmmssSSS");		   
		 String tempScanDate = dateFormatScanDateTime.format(date);
		 
		 return tempScanDate;
	}
	private static final char[] HEX = { 
    '0', '1', '2', '3', '4', '5', '6', '7', 
    '8', '9', 'A', 'B', 'C', 'D', 'E', 'F' };

	public static String encrypt(String text) throws Exception
	{
		byte[] byteArray = OSASecurity.encode(text.getBytes("UTF-8"));
		StringBuffer hexBuffer = new StringBuffer(byteArray.length * 2);
		for (int i = 0; i < byteArray.length; ++i)
		  for (int j = 1; j >= 0; --j)
			hexBuffer.append(HEX[(byteArray[i] >> j * 4 & 0xF)]);
		return hexBuffer.toString();
	}
	private String decrypt(String pass)
	{
		int len = pass.length();
		byte[] data = new byte[len / 2];
		for (int i = 0; i < len; i += 2) {
			data[i / 2] = (byte) ((Character.digit(pass.charAt(i), 16) << 4)
					+ Character.digit(pass.charAt(i+1), 16));
		}
		String password=OSASecurity.decode(data,"UTF-8");
		return password;
	}
%>


