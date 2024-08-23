
var ISIndex;
var docName;
var DocExt;
var docType;
var version;
var docAttrib;
var checkoutstatus;
var checkoutby;
var loggedinuser;
var queueType;
var lockstatus;
var viewmode;
var isConversation;
var NoOfPages;
var comments;
var extParam="";
var rs;
function downloadDoc(link,servlet,cfPanel,strDocIndex)
{
    var docIndex;
    strDocIndex = (typeof strDocIndex == 'undefined')? '': strDocIndex;
    if(cfPanel==true && link){
        var linkarr = link.id.split(':');
        docIndex = document.getElementById(linkarr[0]+':'+linkarr[1]+':'+linkarr[2]+':docIndex').value;
    } else if(strDocIndex && strDocIndex.length>0){
        docIndex = strDocIndex;
    } else {
        var objCombo = document.getElementById('wdesk:docCombo');            
        docIndex = objCombo.value;
    }
    docIndex = encode_ParamValue(docIndex);

    docProperty(docIndex,pid,wid,taskid);
    if(typeof isAllowDownload != 'undefined' && !isAllowDownload(strprocessname, stractivityName, docName)) {
        return false;
    }
    var downloadDisplay=""
    if(DocOrgName=="Y")
        downloadDisplay=docName+"("+comments+")"+'.'+DocExt;
    else
        downloadDisplay=docName+'.'+DocExt;
    var strIsIndex=decode_utf8(ISIndex);
    var ImgIndex = "";
    var VolIndex = "";
    if(strIsIndex.indexOf("#") == -1) {
        ImgIndex = strIsIndex;
        VolIndex = "1";
    } else {
        ImgIndex = strIsIndex.substring(0,strIsIndex.indexOf("#"));
        strIsIndex = strIsIndex.substring(strIsIndex.indexOf("#")+1,strIsIndex.length);

        if(strIsIndex.indexOf("#") != -1)
            VolIndex = strIsIndex.substring(0,strIsIndex.indexOf("#"));
        else
            VolIndex = strIsIndex;
    }

    var isDocCustomName = "N";
    if(typeof customDownloadedDocName != 'undefined') {
        var dldDispName = customDownloadedDocName(docName, comments, DocExt, pid, strprocessname, stractivityName);
        if(typeof dldDispName != 'undefined' && dldDispName != "") {
            downloadDisplay = dldDispName;
            isDocCustomName = "Y";
        }
    }

//    servlet = servlet + "/servlet/" + "downloaddoc?ImgIndex="+ImgIndex+"&VolIndex="+VolIndex+"&DocExt="+encode_utf8(DocExt)+ "&DocIndex="+docIndex+"&PageNo=1&DocumentName="+encode_utf8(downloadDisplay)+"&pid="+encode_utf8(pid)+"&wid="+wid+"&taskid="+taskid;
//   
//    servlet += "&DownloadFlag=Y";
//    if(typeof extParam != 'undefined' && extParam!=""){
//        servlet +="&ExtParam="+extParam;
//    }
//    var oIFrm = document.getElementById('dwnframe'); 
//    if(oIFrm == null)
//        oIFrm = window.parent.document.getElementById('svfrm');  
//    //  Bug ID 59905
//    servlet = appendUrlSession(servlet);                    // if cookies are disabled
    var reqToken = generateReqToken();
        servlet = servlet + "/servlet/downloaddoc";

        var oIFrm = document.getElementById('dwnframe');
        if (oIFrm == null)
            oIFrm = window.parent.document.getElementById('svfrm');
        if (oIFrm == null)
            oIFrm = document.getElementById('downloadfrm');
        servlet = appendUrlSession(servlet);  // if cookies are disabled  
        servlet = servlet + "&rid=" + Math.random();
        
        
    var isChrome = (typeof window.chrome != 'undefined')? true: false;
    var isIE =  (navigator.appName=='Netscape') && (window.navigator.userAgent.indexOf('Trident/') < 0) && (!isChrome)? false: true;
    //Bug 74316 Start
    /*
    if(DocExt=="pdf" && isIE && (typeof window.chrome =='undefined')){
        var screenwidth=500,screenheight=200;
        var left = (window.screen.width - screenwidth) / 2;
        var top = (window.screen.height - screenheight) / 2;
        var wFeatures = 'scrollbars=no,status=yes,width='+screenwidth+',height='+screenheight+',left=' + left + ',top=' + top;
        //var win = openNewWindow(servlet, 'downloadWin', wFeatures, true, "Ext1", "Ext2", "Ext3", "Ext4", '');
        var popup = window.open_('', 'downloadWin', wFeatures, true);
        if (popup == null || typeof popup == 'undefined') {
            return null;
        }
    }
    */
    //else{
//        oIFrm.src = servlet;	
        //Bug 74316 End
        var popup = (oIFrm.contentWindow) ? oIFrm.contentWindow : (oIFrm.contentDocument.document) ? oIFrm.contentDocument.document : oIFrm.contentDocument;
        // oIFrm.src = servlet;	

        //return false;
    //} //Bug 74316 
    
    popup.document.open();
    popup.document.write("<HTML><HEAD><TITLE></TITLE></HEAD><BODY>");
    popup.document.write("<form id='postSubmit' method='post' action='" + servlet + "' accept-charset='UTF-8' enctype='application/x-www-form-urlencoded'>");//Bug 74449
    popup.document.write("<input type='hidden' id='ImgIndex' name='ImgIndex' value='" + ImgIndex + "' />");
    popup.document.write("<input type='hidden' id='VolIndex' name='VolIndex' value='" + VolIndex + "' />");
    popup.document.write("<input type='hidden' id='DocExt' name='DocExt' value='" + encode_utf8(DocExt) + "' />");
    popup.document.write("<input type='hidden' id='DocIndex' name='DocIndex' value='" + docIndex + "' />");
    popup.document.write("<input type='hidden' id='PageNo' name='PageNo' value='1' />");
    popup.document.write('<input type="hidden" id="DocumentName" name="DocumentName" value="' + encode_utf8(downloadDisplay) + '" />');
    popup.document.write("<input type='hidden' id='pid' name='pid' value='" + pid + "' />");//Bug 74316
    popup.document.write("<input type='hidden' id='wid' name='wid' value='" + wid + "' />");
    popup.document.write("<input type='hidden' id='taskid' name='taskid' value='" + taskid + "' />");
    popup.document.write("<input type='hidden' id='ReqToken' name='ReqToken' value='" + reqToken + "' />");
    popup.document.write("<input type='hidden' id='WD_SID' name='WD_SID' value='" + WD_SID + "' />");
    popup.document.write("<input type='hidden' id='DownloadFlag' name='DownloadFlag' value='Y' />");
    popup.document.write("<input type='hidden' id='DocCustomName' name='DocCustomName' value=\"" + isDocCustomName + "\" />");
	popup.document.write("<input type='hidden' id='ArchivalMode' name='ArchivalMode' value='" + ArchivalMode + "' />");
    popup.document.write("<input type='hidden' id='ArchivalCabinet' name='ArchivalCabinet' value='" + ArchivalCabinet + "' />");
    if(typeof extParam != 'undefined' && extParam!="")
        popup.document.write("<input type='hidden' id='ExtParam' name='ExtParam' value='" + extParam + "' />");
    popup.document.write("</FORM></BODY></HTML>");
    popup.document.close();
    popup.document.forms[0].submit();
        
    return false;
}

function generateReqToken(){
    var xhReq;
    if (window.XMLHttpRequest)
        xhReq = new XMLHttpRequest();
    else{
        xhReq = new ActiveXObject("Microsoft.XMLHTTP");
    }
    var url='/webdesktop/ajaxReqToken.app';
    url = appendUrlSession(url);
     var wd_rid=getRequestToken(url);
         url+="&WD_RID="+wd_rid;
    xhReq.open("POST", url, false);
    xhReq.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
       xhReq.send('&CustomAjax=true&WD_SID='+WD_SID);
    var serverResponse ="";
    if (xhReq.status == 200 && xhReq.readyState == 4){
        var serverResponse = xhReq.responseText;
        return serverResponse;
    }
    else if(xhReq.status==250)
            {
                window.location= "/webdesktop/error/errorpage.app?msgID=-8002&HeadingID=8002";    
            }
    else{
          return serverResponse;
    }
}

function docProperty(docIndex,pid,wid,taskid)
{
    var xhReq;
    if (window.XMLHttpRequest) 
        xhReq = new XMLHttpRequest();
    else{
        xhReq = new ActiveXObject("Microsoft.XMLHTTP");
    }
    var url = '/webdesktop/ajaxdocProperty.app';
     var reqStr = 'docIndex='+docIndex+'&CustomAjax=true&pid='+encode_utf8(pid)+'&wid='+wid+'&taskid='+taskid+"&WD_SID="+WD_SID;
    url = appendUrlSession(url);
     var wd_rid=getRequestToken(url);
         url+="&WD_RID="+wd_rid;
    xhReq.open("POST", url, false);
    xhReq.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    xhReq.send(reqStr);
    if (xhReq.status == 200 && xhReq.readyState == 4){
        var serverResponse = xhReq.responseText;
        try{
            serverResponse = parseJSON("("+serverResponse+")");
            ISIndex = serverResponse.document[0].ISIndex ;
            DocExt = serverResponse.document[0].DocExt ;
            docName = serverResponse.document[0].DocumentName ;
            version = serverResponse.document[0].Version ;
            checkoutstatus = serverResponse.document[0].ChkOutStatus ;
            checkoutby = serverResponse.document[0].ChkOutBy ;
            docAttrib = serverResponse.document[0].DocAttrib ;
            docType = serverResponse.document[0].DocType ;
            loggedinuser = serverResponse.document[0].Loggedin ;
            queueType = serverResponse.document[0].QueueType ;
            lockstatus = serverResponse.document[0].lockstatus ;
            viewmode = serverResponse.document[0].viewmode ;
            comments = decode_utf8(serverResponse.document[0].comments);
            extParam=serverResponse.document[0].ExtParam;
            isConversation= (docName.substring(0,conv_name.length).toLowerCase()==conv_name.toLowerCase())?true:false;
            NoOfPages = serverResponse.document[0].NoOfPages ;
        }catch(e){}
    }
    else{
           if(xhReq.status == 599){
                //window.open(sContextPath+"/login/logout.jsp?"+"error=4020",reqSession);
                
                url = sContextPath+"/error/errorpage.app?msgID=4020";
                url = appendUrlSession(url);
                var width = 320;
                var height = 160;
                var left = (window.screen.availWidth-width)/2;
                var top = (window.screen.availHeight-height)/2;

                //window.open(url,reqSession);
                if (window.showModalDialog){
                    window.showModalDialog(url,'',"dialogWidth:"+width +"px;dialogHeight:"+height+"px;center:yes;dialogleft: "+left+"px;dialogtop: "+top+"px");
                }
           }
            else if(xhReq.status==250)
            {
                window.location= "/webdesktop/error/errorpage.app?msgID=-8002&HeadingID=8002";    
            }
            else if(xhReq.status==310)
            {
                window.location= "/webdesktop/error/errorpage.app?msgID=-8003&HeadingID=8003";    
            }
            else if(xhReq.status == 400)
                customAlert(INVALID_REQUEST_ERROR);
            else if(xhReq.status==12029){
                customAlert(ERROR_SERVER); 
            }
           else
                customAlert(ERROR_DATA);            
    }
}
function onCheckOutDivInterchange(){
    document.getElementById("wdesk:checkinDiv").style.display="inline";
    document.getElementById("wdesk:checkoutDiv").style.display="none";  
}
function checkOutDoc(documentIndex,cfPanel)
{
    cfPanel=(typeof cfPanel == 'undefined')? 'N': cfPanel;
    var docIndex = '';
    var objCombo = document.getElementById('wdesk:docCombo');  
    if(cfPanel=='Y'){
        docIndex = documentIndex;
    } else {
        docIndex = objCombo.value;
        var deleteDocShow=document.getElementById('wdesk:deletedoc').style.display;
        if(deleteDocShow=='inline') 
            document.getElementById('wdesk:deletedoc').style.display='inline';
    }

    
    
    docProperty(docIndex,pid,wid,taskid);
    checkOutDocHook(docIndex,docName.replace(/'/g,"\\'"));//Bug 66696
    var window_workdesk="";
    if(windowProperty.winloc=="T")
        window_workdesk=window.opener.opener;
    else
        window_workdesk=window.opener;
    if(window_workdesk){
        if(window_workdesk.SharingMode){     
                window_workdesk.broadcastCheckOutDocEvent(docName.replace(/'/g,"\\'"),docType);
        }
            
    }
    var url = sContextPath+'/components/workitem/document/checkout/checkout_main.app';
    url = appendUrlSession(url);
    var wFeatures = 'scrollbars=no,status=yes,resizable=yes,width='+window1W+',height='+window1H+',left='+window1Y+',top='+window1X;
//    docIndex = objCombo.options[objCombo.options.selectedIndex].value;
    var docInfoRef=document.getElementById('wdesk:docInfoJSON');
    var imgIndex,volIndex,docOrgName;
    if(docInfoRef){
        var tmpParsedDocJSON = parseJSON("(" + encode_ParamValue(document.getElementById('wdesk:docInfoJSON').value) + ")");
        var docInfoJSON = tmpParsedDocJSON[docIndex];
        imgIndex = docInfoJSON.document[0].ImgIndex;
        volIndex = docInfoJSON.document[0].VolIndex;
        docOrgName=typeof docInfoJSON.document[0].DocOrgName == 'undefined'?docInfoJSON.document[0].DocOrgName:docInfoJSON.document[0].DocOrgName.replace(/'/g,"\\'");//Bug 79374
    } else{
        var tmpISIndex = decode_utf8(ISIndex);
        if(tmpISIndex.indexOf("#") == -1) {
            imgIndex = tmpISIndex;
            volIndex = "1";
        } else {
            imgIndex = tmpISIndex.substring(0,tmpISIndex.indexOf("#"));
            tmpISIndex = tmpISIndex.substring(tmpISIndex.indexOf("#")+1,tmpISIndex.length);
            
            if(tmpISIndex.indexOf("#") != -1)
                volIndex = tmpISIndex.substring(0,tmpISIndex.indexOf("#"));
            else
                volIndex = tmpISIndex;
        }
        docOrgName = docName + "(" + comments + ")" + DocExt;
        docOrgName = docOrgName.replace(/'/g,"\\'");
    }
    var listParam=new Array();
    listParam.push(new Array("ISIndex",encode_ParamValue(decode_utf8(ISIndex))));
    listParam.push(new Array("Ext",encode_ParamValue(DocExt)));
    listParam.push(new Array("DocId",encode_ParamValue(docIndex)));
    listParam.push(new Array("DocName",encode_ParamValue(docName.replace(/'/g,"\\'"))));
    listParam.push(new Array("pid",encode_ParamValue(pid)));
    listParam.push(new Array("wid",encode_ParamValue(wid)));
    listParam.push(new Array("taskid",encode_ParamValue(taskid)));
    listParam.push(new Array("comments",encode_ParamValue(comments)));
    listParam.push(new Array('ImgIndex', encode_ParamValue(imgIndex)));
    listParam.push(new Array('VolIndex', encode_ParamValue(volIndex)));
    listParam.push(new Array("Panel",encode_ParamValue(cfPanel)));  
    listParam.push(new Array('DocOrgName',encode_ParamValue(docOrgName)));
    var win = openNewWindow(url,'Filter',wFeatures, true,"Ext1","Ext2","Ext3","Ext4",listParam);
        
    /*var url = "/webdesktop/faces/workitem/document/checkout/checkout_main.jsp?ISIndex="+encode_utf8(decode_utf8(ISIndex))+ "&Ext="+encode_utf8(DocExt)+"&DocId="+docIndex+"&DocName="+encode_utf8(docName)+"&pid="+encode_utf8(pid)+"&wid="+encode_utf8(wid)+"&comments="+encode_utf8(comments);
    url = appendUrlSession(url);    
    var win = window.open(url,'Filter','scrollbars=yes,resizable=yes,width='+windowW+',height='+windowH+',left='+windowY+',top='+windowX);*/
}

function checkOutToDrive(){
    var windowW = 690;
    var windowH = 444;
    var left = (window.opener.screen.width - windowW) / 2;
    var top = (window.opener.screen.availHeight - windowH) / 2;
    var url = '/webdesktop/components/workitem/document/savetogdriveoption.app';
    var wFeatures = 'status=yes,resizable=no,scrollbars=yes,width=' + windowW + ',height=' + windowH + ',left=' + left + ',top=' + top + ',resizable=yes,scrollbars=yes';
    var fileCommentsName = docInfoJSON.document[0].FileName;
    if (fileCommentsName.lastIndexOf(".")!= -1) {
        fileCommentsName = fileCommentsName.substring(0, fileCommentsName.lastIndexOf("."));
    }
    var listParam = new Array();
    listParam.push(new Array('Action', 1));
    listParam.push(new Array('ImgIndex', encode_ParamValue(imgIndex)));
    listParam.push(new Array('VolIndex', encode_ParamValue(volIndex)));
    listParam.push(new Array('DocOrgName', encode_ParamValue(docOrgName)));
    listParam.push(new Array('DocExt', encode_ParamValue(extension)));
    listParam.push(new Array('DocIndex', encode_ParamValue(docId)));
    var customDocName = "";
    if (typeof customDownloadedDocName != 'undefined') {
        customDocName = customDownloadedDocName(docName, fileCommentsName, extension, pid, processName, activityName);
        if (customDocName.lastIndexOf(".") != -1) {
            customDocName = customDocName.substring(0, customDocName.lastIndexOf("."));
        }
    }
    if (customDocName != "") {
        listParam.push(new Array('DocName', customDocName));
        listParam.push(new Array('DocCustomName',"Y"));
    } else {
        listParam.push(new Array('DocName', encode_ParamValue(docName.replace(/'/g, "\\'"))));
    }
    listParam.push(new Array('ISIndex', encode_ParamValue(isIndex)));
    listParam.push(new Array('Flag','S'));
    window.opener.openNewWindow(url, 'SaveToGoogleDriveOptions', wFeatures, true, "Ext1", "Ext2", "Ext3", "Ext4", listParam);
}

function checkInDoc(documentIndex,cfPanel)
{
    var windowW = 690;
    var windowH = 444;
    var left = (window.screen.width - windowW) / 2;
    var top = (document.documentElement.clientHeight - windowH) / 2;
    var objCombo = document.getElementById('wdesk:docCombo');
    var pid=document.getElementById('wdesk:pid').value;
    var wid=document.getElementById('wdesk:wid').value;
    var taskid=document.getElementById('wdesk:taskid').value;
    var docIndex = '';
    cfPanel=(cfPanel == undefined?'N':cfPanel);
    if(cfPanel=='Y'){
        docIndex = documentIndex;
    } else {          
        docIndex = objCombo.value;
    }
    docProperty(docIndex,pid,wid,taskid);
    var versionno=(version=='')?'1.0':version;

    var url = sContextPath+'/components/workitem/document/checkin/checkin.app';
    url = appendUrlSession(url);
    url += "&ISIndex="+encode_utf8(decode_utf8(ISIndex));
    url += "&DocName="+encode_utf8(docName.replace(/'/g,"\\'"));
    url += "&Extension="+encode_utf8(DocExt);
    url += "&VersionNo="+encode_utf8(versionno);
    url += "&DocId="+encode_utf8(docIndex);
    url += "&pid="+encode_utf8(pid);
    url += "&wid="+encode_utf8(wid);
    url += "&taskid="+encode_utf8(taskid);
    url += "&Panel="+encode_utf8(cfPanel);
    var wFeatures = 'scrollbars=no,status=yes,resizable=yes,width='+windowW+',height='+windowH+',left='+left+',top='+top;

//    var listParam=new Array();
//    listParam.push(new Array("ISIndex",encode_ParamValue(decode_utf8(ISIndex))));
//    listParam.push(new Array("DocName",encode_ParamValue(docName)));
//    listParam.push(new Array("Extension",encode_ParamValue(DocExt)));
//    listParam.push(new Array("VersionNo",encode_ParamValue(versionno)));
//    listParam.push(new Array("DocId",encode_ParamValue(docIndex)));    
//    listParam.push(new Array("pid",encode_ParamValue(pid)));
//    listParam.push(new Array("wid",encode_ParamValue(wid)));    
//alert(url+listParam)
    
    //var win = openNewWindow(url,'Filter',wFeatures, true,"Ext1","Ext2","Ext3","Ext4",listParam);
    var win = link_popup(url,'Filter',wFeatures,windowList,'',false);
    /*var url = "/webdesktop/faces/workitem/document/checkin/checkin.jsp?ISIndex="+encode_utf8(decode_utf8(ISIndex))+ "&DocName="+encode_utf8(docName)+ "&Extension="+encode_utf8(DocExt)+"&VersionNo="+versionno+"&DocId="+docIndex+"&pid="+encode_utf8(pid)+"&wid="+wid;
    url = appendUrlSession(url);
    var win = window.open(url,'Filter','scrollbars=yes,resizable=yes,width='+windowW+',height='+windowH+',left='+windowY+',top='+windowX);*/
}
function versionDoc(documentIndex,cfPanel)
{
    cfPanel=(typeof cfPanel == 'undefined')? 'N': cfPanel;
    var docIndex = '';
    var objCombo = document.getElementById('wdesk:docCombo');   
    if(cfPanel=='Y'){
        docIndex=documentIndex;
    } else {
        docIndex = objCombo.value;
    }
         
    var pid=document.getElementById('wdesk:pid').value;
    var wid=document.getElementById('wdesk:wid').value;
    var taskid=document.getElementById('wdesk:taskid').value;
    
    docProperty(docIndex,pid,wid,taskid);
    if(docAttrib==-1)
        var attachmentStatus ='a';
    else
        var attachmentStatus = Trim(docAttrib.toLowerCase());
       
    attachmentStatus = (attachmentStatus == 'm' || attachmentStatus == 't' )? true : false;
    var toUser = ((checkoutby.toLowerCase() == loggedinuser.toLowerCase()) || (viewmode.toUpperCase()=='W' && (checkoutby=='' || checkoutby == 'null')))?true:false;
    var allowDelete =   (attachmentStatus && toUser && queueType.toLowerCase()!='i' && !isConversation)? true : false;
    var allowDownloadVersionDoc = false;
    if(cfPanel=='Y'){
        allowDownloadVersionDoc=true;
    }else {
        allowDownloadVersionDoc=((document.getElementById('wdesk:downloadDiv') && document.getElementById('wdesk:downloadDiv').style.display != 'none') || (typeof enableDocDownloadFromVersion != 'undefined' && enableDocDownloadFromVersion(strprocessname,stractivityName,userName))) ? 'true' : 'false';
    }
    var disableDeleteForOldVersion = false;
           /* if(window.opener!=null){
           disableDeleteForOldVersion =  (typeof window.opener.disableDeleteForOldVersion !== 'undefined' && window.opener.disableDeleteForOldVersion(strprocessname,stractivityName,userName)) ? 'true' : 'false';
            }
            else
                {*/
                    disableDeleteForOldVersion =  (typeof window.disableDeleteForOldVersion !== 'undefined' && window.disableDeleteForOldVersion(strprocessname,stractivityName,userName)) ? 'true' : 'false';
//                }
        var url ='/webdesktop/components/workitem/document/version/docversionlist.app';
    url = appendUrlSession(url);
    var wFeatures = 'scrollbars=no,status=yes,resizable=yes,width='+window1W+',height='+window1H+',left='+window1Y+',top='+window1X;

    var listParam=new Array();
    listParam.push(new Array("ISIndex",encode_ParamValue(decode_utf8(ISIndex))));
    listParam.push(new Array("DocName",encode_ParamValue(docName.replace(/'/g,"\\'"))));
    listParam.push(new Array("DeleteFlag",encode_ParamValue(allowDelete)));    
    listParam.push(new Array("DocId",encode_ParamValue(docIndex)));    
    listParam.push(new Array("pid",encode_ParamValue(pid)));
    listParam.push(new Array("wid",encode_ParamValue(wid)));    
    listParam.push(new Array("taskid",encode_ParamValue(taskid)));   
    listParam.push(new Array("AllowDownloadVersionDoc",encode_ParamValue(allowDownloadVersionDoc)));
    listParam.push(new Array("DisableDeleteForOldVersion",encode_ParamValue(disableDeleteForOldVersion)));
    var win = openNewWindow(url,'Filter',wFeatures, true,"Ext1","Ext2","Ext3","Ext4",listParam);
    
    /*var url = "/webdesktop/faces/workitem/document/version/docversionlist.jsp?ISIndex="+encode_utf8(decode_utf8(ISIndex))+ "&DocName="+encode_utf8(docName)+ "&DeleteFlag="+allowDelete+"&DocId="+docIndex+"&pid="+encode_utf8(pid)+"&wid="+wid;
    url = appendUrlSession(url);
    var win = window.open(url,'Filter','scrollbars=no,resizable=yes,width='+windowW+',height='+windowH+',left='+windowY+',top='+windowX);*/
}
function getSaveTransformation()
{
    var operation =0;
    if(isOpAll=='N' && document.IVApplet)
        operation = IVApplet.getSaveActions();
    else{
        operation = opall_toolkit.getSaveActions();
        annotData = opall_toolkit.getAnnotationData();
        if(annotData != null && annotData.indexOf("TotalGroups=0")==-1){
            if(!confirm("Annotations will not be saved on Transformed Image"))
                return false;
        }
    }
    if (operation != '' && (operation.indexOf("2") !=-1 || operation.indexOf("1") !=-1 || operation.indexOf("5") !=-1|| operation.indexOf("6") !=-1 || operation.indexOf("3") !=-1))
    {   
        var objCombo = document.getElementById('wdesk:docCombo');    
        
        
        var docIndex = objCombo.value;
        docProperty(docIndex,pid,wid,taskid);
        var xbReq;
        if (window.XMLHttpRequest){
            xbReq = new XMLHttpRequest();
        } else if (window.ActiveXObject){
           xbReq = new ActiveXObject("Microsoft.XMLHTTP");
        }
          
        var url=sContextPath+'/servlet/SAVEImageOperations';
        
        if(isOpAll=='N' && document.IVApplet)
            param = 'DocExt='+encode_utf8(DocExt)+'&ImgTransfrm='+operation+'&ISIndex='+encode_utf8(decode_utf8(ISIndex))+'&DocIndex='+docIndex+'&versionno='+version+'&CurrentPage='+IVApplet.getCurrentPage()+'&NoOfPages='+NoOfPages+'&pid='+encode_utf8(pid)+'&wid='+wid+'&taskid='+taskid;
        else 
            param = 'DocExt='+encode_utf8(DocExt)+'&ImgTransfrm='+operation+'&ISIndex='+encode_utf8(decode_utf8(ISIndex))+'&DocIndex='+docIndex+'&versionno='+version+'&CurrentPage='+opall_toolkit.getCurrentPage()+'&NoOfPages='+NoOfPages+'&pid='+encode_utf8(pid)+'&wid='+wid+'&taskid='+taskid;
        url = appendUrlSession(url); 
          var divx= document.createElement("div");
                                var imgx=document.createElement("img");
                                imgx.src=sContextPath+"/resources/images/indicator_hypnotize.gif";

                                divx.appendChild(imgx);
                                divx.style.position="absolute";
                                divx.style.right=20;
                                //divx.style.top=7;
                                divx.style.top=31;
                                divx.style.left=document.body.clientWidth/2;

                                document.body.appendChild(divx);
                                divx.id="msgdiv"
                                param=param+"&WD_SID="+WD_SID+"&WD_RID="+getRequestToken('/webdesktop/servlet/SAVEImageOperations');
        if (xbReq != null) {
            xbReq.open("POST", url, false);
            xbReq.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            xbReq.send(param);
            var response = xbReq.responseText;
        }
             setTimeout('fn()',4000);
         // save transformation not working on pdf
        if ((operation.indexOf("4") !=-1 || operation.indexOf("5") !=-1 || operation.indexOf("6") !=-1) && (DocExt=='pdf')){
         customAlert(SAVE_TRANSFORMATION_MESSAGE_PDF);   
        }
        else{
         customAlert(SAVE_TRANSFORMATION_MESSGAE);   
        }
         reloadapplet(docIndex,false,'getdocument');
         var window_workdesk="";
         if(windowProperty.winloc == 'M')
            window_workdesk = window;
         else if(windowProperty.winloc == 'T')
            window_workdesk = window.opener.opener;
         else
            window_workdesk = window.opener;
         if(window_workdesk.SharingMode)
            window_workdesk.broadcastTransformationEvent(docIndex,docName.replace(/'/g,"\\'"));
        return false;
    }
    else{
         if ((operation.indexOf("4") !=-1 || operation.indexOf("5") !=-1 || operation.indexOf("6") !=-1) && (DocExt=='pdf')){
         customAlert(SAVE_TRANSFORMATION_MESSAGE_PDF);   
        }
        return false;
    }
        
}

 function fn(){
            var divy=document.getElementById("msgdiv");
                 if(divy) 
                  document.body.removeChild(divy);
        }
function setDefaultDocName()
{
    var objCombo = document.getElementById('wdesk:docCombo');        
    var pid=document.getElementById('wdesk:pid').value;
    var wid=document.getElementById('wdesk:wid').value;
    var taskid=document.getElementById('wdesk:taskid').value;
    var docName = objCombo[objCombo.selectedIndex].text;
    var selDocTypeName = '';
    selDocTypeName = docName;
    var xbReq;
    if (window.XMLHttpRequest){
        xbReq = new XMLHttpRequest();
    } else if (window.ActiveXObject){
       xbReq = new ActiveXObject("Microsoft.XMLHTTP");
    }
    var url = '/webdesktop/ajaxsetDefaultDoc.app';
    var wd_rid=getRequestToken(url);
    url += "?WD_RID="+wd_rid;
    url = url + '&GetSetOpr=S&pid='+encode_utf8(pid)+'&wid='+wid+'&taskid='+taskid+'&DocType='+encode_utf8(selDocTypeName);
    url = appendUrlSession(url);
    if (xbReq != null) {
    xbReq.open("GET",url,false);
    xbReq.send(null);
    selDocTypeName = xbReq.responseText;    
    }
     var showDefaultImg =document.getElementById('wdesk:defaultImg');
     var showNonDefaultImg =document.getElementById('wdesk:nonDefaultImg');
      showDefaultImg.style.display="inline";
      showNonDefaultImg.style.display="none";
    var window_workdesk="";
    if(windowProperty.winloc == 'M')
        window_workdesk = window;
    else if(windowProperty.winloc == 'T')
        window_workdesk = window.opener.opener;
    else
        window_workdesk = window.opener;
    if(window_workdesk.SharingMode){
        window_workdesk.broadcastSetAsDefaultEvent(docName, selDocTypeName);
    }
    setmessageinDivSuccess(DEFAULT_DOCTYPE,"true",3000);
    setDefaultDocTypeColor(selDocTypeName);
}
function findDocType(DocName)
{
	if ((DocName.lastIndexOf("(") != -1) && (DocName.lastIndexOf(")")==(DocName.length-1)))
		DocName = DocName.substring(0,DocName.lastIndexOf("("));
	return DocName;
}
function downloadClick(openDocFromPlugin)
{
    openDocFromPlugin = (typeof openDocFromPlugin == 'undefined')? 'N': openDocFromPlugin;
    var calledFrom = (typeof window.parent.calledFrom == 'undefined')? 'N': window.parent.calledFrom;
    var strDocIndex = (typeof window.parent.strDocIndex == 'undefined')? '': window.parent.strDocIndex;
    var loc=window.location.href;
    // Bug Id: 28897
    //window.location.href=window.location.href+'&DownloadFlag=Y';
    //--------------------
       var urlValue;
    if (typeof window.parent.document.getElementById('wdesk:docFrameURL') != 'undefined' && window.parent.document.getElementById('wdesk:docFrameURL') != null) {
        urlValue = window.parent.document.getElementById('wdesk:docFrameURL').value;
    } else {
        urlValue = window.parent.document.getElementById('docFrameURL').value;
    }

    if (urlValue.indexOf("#") > -1) {
        urlValue = urlValue.substring(0, urlValue.lastIndexOf("#")) + '&DownloadFlag=Y' + urlValue.substring(urlValue.lastIndexOf("#"));
    }
    if(openDocFromPlugin == 'Y'){        
        var windowW = window.screen.availWidth-10.1;
        var windowH = window.screen.availHeight-60.01;		
		var url= urlValue+'&DownloadFlag=Y&OpenDocFromPlugin=Y';
        window.open(url,'PluginViewer','scrollbars=yes,width='+windowW+',height='+windowH+',left='+0+',top='+0+',resize=yes');
    } else {
        if(calledFrom==="P"||calledFrom==="D"){
          window.parent.opener.downloadDoc("",window.parent.sContextPath,"",strDocIndex);   
        } else {
          window.parent.downloadDoc("",window.parent.sContextPath);  
        }
        
		
    }
}
function editDoc()
{var objCombo = document.getElementById('wdesk:docCombo');
    var pid=document.getElementById('wdesk:pid').value;
    var wid=document.getElementById('wdesk:wid').value;
    var taskid=document.getElementById('wdesk:taskid').value;
    var deleteDocShow=document.getElementById('wdesk:deletedoc').style.display;
    if(deleteDocShow=='inline')
        document.getElementById('wdesk:deletedoc').style.display='inline';
    var docIndex = objCombo.value;
    docProperty(docIndex,pid,wid,taskid);

    var url = '/webdesktop/components/workitem/document/editdocument.app';
    url = appendUrlSession(url);
    var wFeatures = 'scrollbars=yes,resizable=yes,status=yes,width='+windowW+',height='+windowH+',left='+windowY+',top='+windowX;
    var listParam=new Array();
    if(encode_ParamValue(DocExt).indexOf("doc")!=-1 || encode_ParamValue(DocExt).indexOf("xls")!=-1 || encode_ParamValue(DocExt).indexOf("ppt")!=-1 || encode_ParamValue(DocExt).indexOf("txt")!=-1){
        listParam.push(new Array("ISIndex",encode_ParamValue(decode_utf8(ISIndex))));
        listParam.push(new Array("Ext",encode_ParamValue(DocExt)));
        listParam.push(new Array("DocId",encode_ParamValue(docIndex)));
        listParam.push(new Array("DocName",encode_ParamValue(docName.replace(/'/g,"\\'"))));
        listParam.push(new Array("pid",encode_ParamValue(pid)));
        listParam.push(new Array("wid",encode_ParamValue(wid)));
        listParam.push(new Array("taskid",encode_ParamValue(taskid)));
        listParam.push(new Array("comments",encode_ParamValue(comments)));
    }
    else
    {
        customAlert(encode_ParamValue(DocExt)+" document extension is not supported for editing using Edit functionality");
        return false;
    }
    var win = openNewWindow(url,'Filter',wFeatures, true,"Ext1","Ext2","Ext3","Ext4",listParam);
}

function reloadDocument(docIndex,pid,wid,taskid)
{
    if (window.XMLHttpRequest)
        xhReq = new XMLHttpRequest();
    else{
        xhReq = new ActiveXObject("Microsoft.XMLHTTP");
    }
    var url = '/webdesktop/ajaxsetdocproperty.app';
    var requestStr = 'docIndex='+docIndex+'&CustomAjax=true&pid='+encode_utf8(pid)+'&wid='+wid+'&taskid='+taskid;
    url = appendUrlSession(url);
     var wd_rid=getRequestToken(url);
         url+="&WD_RID="+wd_rid;
    xhReq.open("POST", url, false);
    xhReq.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    xhReq.send(requestStr);
    if (xhReq.status == 200 && xhReq.readyState == 4){
        reloadapplet(docIndex,'saveTransform');
    }
    else{
           if(xhReq.status == 599)
                window.open("/omniapp/pages/login/logout.app?"+"error=4020",reqSession);
           else if(xhReq.status==310)
            {
                window.location= "/webdesktop/error/errorpage.app?msgID=-8003&HeadingID=8003";    
            }
            else if(xhReq.status==250)
            {
                window.location= "/webdesktop/error/errorpage.app?msgID=-8002&HeadingID=8002";    
            }
           else if(xhReq.status == 400)
                customAlert(INVALID_REQUEST_ERROR);
           else
                customAlert(ERROR_DATA);
    }
}

function PrintDoc()
{
    var url="";
    try {
        var objCombo = document.getElementById('wdesk:docCombo');
        var docName = objCombo[objCombo.selectedIndex].text;
        var pid=document.getElementById('wdesk:pid').value;
        var wid=document.getElementById('wdesk:wid').value;
        var taskid=document.getElementById('wdesk:taskid').value;
        var docIndex = objCombo.value;
        docProperty(docIndex,pid,wid,taskid);
        if(typeof isAllowPrint != 'undefined' && !isAllowPrint(strprocessname, stractivityName, docName)) {
            return false;
        }
        if(docType=="I"){
            if(isOpAll=='N' && document.IVApplet)
            {
                url = '/webdesktop/components/workitem/view/printdialogfinal.app?DocId='+docIndex+'&VersionNo='+version+'&DocExt='+DocExt+'&pages='+NoOfPages+'&ISIndex='+ISIndex+'&docName='+docName+"&pid="+encode_utf8(pid)+"&wid="+wid+"&taskid="+taskid;
            } else {
                // Print issue with IE.
                var docViewerPaneId = getDocViewerPaneId(docIndex, 'docviewer');
                var ifrm2=document.getElementById(docViewerPaneId);
                if(ifrm2){
                    if(ifrm2.contentWindow && ifrm2.contentWindow.focus){
                        ifrm2.contentWindow.focus();
                    } else if(ifrm2.focus){                     
                           ifrm2.focus();
                    }
                }
                
                opall_toolkit.print(); 
            }
        } else {
            url = '/webdesktop/components/workitem/view/print.app';
            url=url+"?docName="+docName;
        }
    } catch(e){
        customAlert('An error has occurred: '+e.message);
    }
   if(isOpAll=='N')
    {
        url = appendUrlSession(url);
        var win = link_popup(url, 'printWin', 'resizable=no,scrollbars=no,width='+windowW+',height='+windowH+',left='+windowY+',top='+windowX,windowList,false);
    }
}

function getPrintUrl()
{
   var objCombo = document.getElementById('wdesk:docCombo');
   var pid=document.getElementById('wdesk:pid').value;
   var wid=document.getElementById('wdesk:wid').value;
   var taskid=document.getElementById('wdesk:taskid').value;
   var docIndex = objCombo.value;
   var downloadDisplay=""
   docProperty(docIndex,pid,wid);
    if(DocOrgName=="Y")
        downloadDisplay=docName+"("+comments+")"+'.'+DocExt;
    else
      downloadDisplay=docName+'.'+DocExt;
   var printUrl="/webdesktop/servlet/getdocument?ISIndex="+ISIndex+"&DocExt="+DocExt+"&DocIndex="+docIndex+"&DocumentName="+encode_utf8(downloadDisplay)+"&WD_SID="+WD_SID+"&DownloadFlag=Y&pid="+encode_utf8(pid)+"&wid="+wid+"&taskid="+taskid+"&isPrint=Y"+"&WD_RID="+getRequestToken('/webdesktop/servlet/getdocument');
   return printUrl;
}
function togglePop(ref,act){
    if(ref!=null && typeof ref!=undefined){
       var rfPop = ref.lastElementChild.lastElementChild; 
       if(rfPop){
           /*if(hasCSS(rfPop, 'dn')){
              removeCSS(rfPop, 'dn');
              addCSS(rfPop, 'db');
           } else{
              removeCSS(rfPop, 'db');
              addCSS(rfPop, 'dn');
           }*/
            if(act == 'H') {
                rfPop.style.display = 'none';
            } else if(act == 'S') {
                rfPop.style.display = '';
            }
       }
    }
    return true;
}

function openDocPopup(event,documentIndex,documentType,ISIndex,documentName,docOrgName,docExt){
    var listParam=new Array();
    listParam.push(new Array("wid",encode_ParamValue(wid)));
    listParam.push(new Array("pid",encode_ParamValue(pid)));
    listParam.push(new Array("taskid",encode_ParamValue(taskid)));
    listParam.push(new Array("WD_SID",encode_ParamValue(WD_SID)));
    listParam.push(new Array("docIndex",encode_ParamValue(documentIndex)));
    listParam.push(new Array("docType",encode_ParamValue(documentType)));
    listParam.push(new Array("ISIndex",encode_ParamValue(ISIndex)));
    listParam.push(new Array("docName",encode_ParamValue(documentName.replace(/'/g,"\\'"))));
    listParam.push(new Array("docOrgName",encode_ParamValue(docOrgName.replace(/'/g,"\\'")) ));
    listParam.push(new Array("docExt",encode_ParamValue(docExt)));
    listParam.push(new Array("rid",encode_ParamValue(MakeUniqueNumber())));
    listParam.push(new Array("calledFrom",encode_ParamValue("P")));
    
    var wFeatures = 'scrollbars=no,status=yes,width='+650+',height='+580+',left='+(window.screen.width - 650)/2+',top='+(window.screen.height - 650)/2+',resizable=yes';

    var url = '/webdesktop/components/workitem/view/doclistview.app';
    url = appendUrlSession(url);
    var win;
    var winName = "docpopup_"+pid+"_"+documentIndex;
    win = openNewWindow(url,winName,wFeatures, true,"Ext1","Ext2","Ext3","Ext4",listParam);
    win.focus();
    if(typeof keepDocListSideBarOpen != 'undefined' && !keepDocListSideBarOpen(strprocessname, stractivityName, pid, wid, taskid, 'docPopUp')){
		hideWdeskSidebar('H');
    }
    cancelBubble(event);
} 
function docBatch(op){
    var cb = document.getElementById('wdesk:curBatch');
    var temp=0;
    if(cb){
        var val = parseInt(cb.value);
        temp=val;
        if(op=='P'){
            cb.value=val-1;
        }          
        else if(op=='N'){
            cb.value=val+1;
        }
        getFilterOptions();
        rs = getRequestString();
        try{
            
            loadWdSidebar('Documents', getParentSidebar('Documents'), null, 'opt=1'+rs, 'wdesk:scrolldocdiv',"navCallBack()");
        } catch(e){
            cb.value=temp;
        }  
    }   
}

function navCallBack(){
    var le = document.getElementById('wdesk:ltpg');
    var ld = document.getElementById('wdesk:lftarrdis');
    var re = document.getElementById('wdesk:rtpg');
    var rd = document.getElementById('wdesk:rtarrdis');
    var bprv = document.getElementById('wdesk:bPrev');
    var bnxt = document.getElementById('wdesk:bNext');
    if(bprv.value=='true') {
        if(hasCSS(le,'dn')) {removeCSS(le,'dn');addCSS(le,'db')}
        if(hasCSS(ld,'db')) {removeCSS(ld,'db');addCSS(ld,'dn')}
    } else {
        if(hasCSS(le,'db')) {removeCSS(le,'db');addCSS(le,'dn')}
        if(hasCSS(ld,'dn')) {removeCSS(ld,'dn');addCSS(ld,'db')}
    }
    if(bnxt.value=='true') {
        if(hasCSS(re,'dn')) {removeCSS(re,'dn');addCSS(re,'db')}
        if(hasCSS(rd,'db')) {removeCSS(rd,'db');addCSS(rd,'dn')}
    } else {
        if(hasCSS(re,'db')) {removeCSS(re,'db');addCSS(re,'dn')}
        if(hasCSS(rd,'dn')) {removeCSS(rd,'dn');addCSS(rd,'db')}
    }
    var noSrchDoc = document.getElementById('wdesk:noSrchDocpg');
    if(noSrchDoc){
        if(hasCSS(le,'db')) {removeCSS(le,'db');addCSS(le,'dn')}
        if(hasCSS(ld,'dn')) {removeCSS(ld,'dn');addCSS(ld,'db')}
        if(hasCSS(re,'db')) {removeCSS(re,'db');addCSS(re,'dn')}
        if(hasCSS(rd,'dn')) {removeCSS(rd,'dn');addCSS(rd,'db')}
    }    
    searchCallBack();
    filterCallBack();
}
function clearSrch(){
    var se = document.getElementById('wdesk:bSEnabled');
    var sp = document.getElementById("wdesk:searchPrefix");
    var pf = document.getElementById("wdesk:Prefix");
    var cl = document.getElementById('wdesk:RenderClrSrch');
    document.getElementById("wdesk:curBatch").value="0";
    if(se)
        se.value='false';
    if(sp) sp.value='';
    if(pf) pf.value=OP_SEARCH_DOCUMENT;
    if(cl) cl.value='false';
    rs = getRequestString();
    loadWdSidebar('Documents', getParentSidebar('Documents'), null, 'opt=0&cls=0'+rs, 'wdesk:scrolldocdiv',"navCallBack()");
}

function showavailfilters(op){
    var fdref = document.getElementById('wdesk:filterDiv');
    
    
    if(fdref){
        if(op==='S'){
            if(hasCSS(fdref,'dn')) {removeCSS(fdref,'dn');addCSS(fdref,'db')}
            getFilterOptions();
        }else if(op==='H' && fdref){
            if(hasCSS(fdref,'db')) {removeCSS(fdref,'db');addCSS(fdref,'dn')}
        } else if(op==='F'){
            rs = getRequestString();
            loadWdSidebar('Documents', getParentSidebar('Documents'), null, 'opt=1'+rs, 'wdesk:scrolldocdiv',"navCallBack()");
        } else if(op==='C') {
            clearFilter();
        }
    } 
}


function getFilterOptions(){
    var uTable,rc;
    var iCount = 0;
    var upWithinRef = document.getElementById('wdesk:UpWithin');
    var DTypeFilRef = document.getElementById('wdesk:DTypeFil');
    var ownerFilRef = document.getElementById('wdesk:docOwners');
    var tmpDt=upWithinRef.value;
    var tmpType=DTypeFilRef.value;
    var tmpOwner= ownerFilRef.value.substring(0,ownerFilRef.value.lastIndexOf(",")).split(",");
    uTable = document.getElementById('wdesk:dtypef');
    rc = uTable.rows[0].cells.length;   
    for(iCount = 0; iCount < rc;iCount++){
        if(tmpType.charAt(iCount)=='1')
            document.getElementById('wdesk:dtypef:'+iCount).checked=true;
        else
            document.getElementById('wdesk:dtypef:'+iCount).checked=false;
    }
    uTable= document.getElementById('wdesk:updtf');
    rc = uTable.rows.length;   
    
    for(iCount = 0; iCount < rc;iCount++){
        if(tmpDt.charAt(iCount)=='1')
            document.getElementById('wdesk:updtf:'+iCount).checked=true;
        else
            document.getElementById('wdesk:updtf:'+iCount).checked=false;
    }
    
    uTable=document.getElementById('wdesk:lstOwnr');
    rc = uTable.rows.length;
    for(iCount = 0; iCount < rc;iCount++){
        if(tmpOwner.contains(document.getElementById('wdesk:lstOwnr:'+iCount+':OName').innerHTML.trim())){
            document.getElementById('wdesk:lstOwnr:'+iCount+':OId').checked=true;
        } else {
            document.getElementById('wdesk:lstOwnr:'+iCount+':OId').checked=false;
        }
    }
}
function setFilterOptions(){
    var tmpType='',tmpDt='',tmpUpl='';
    var uTable,rc;
    var iCount = 0;
    var fnum= 0 ;
    uTable = document.getElementById('wdesk:dtypef');
    rc = uTable.rows[0].cells.length;   
    for(iCount = 0; iCount < rc;iCount++){
        if(document.getElementById('wdesk:dtypef:'+iCount).checked){
            tmpType+='1';
        } else {
            tmpType+='0';
        }
    }
    uTable= document.getElementById('wdesk:updtf');
    rc = uTable.rows.length;   
    for(iCount = 0; iCount < rc;iCount++){
        if(document.getElementById('wdesk:updtf:'+iCount).checked){
            tmpDt+='1';
        } else {
            tmpDt+='0';
        }
    }
    uTable= document.getElementById('wdesk:lstOwnr');
    rc = uTable.rows.length;   
    for(iCount = 0; iCount < rc;iCount++){
        if(document.getElementById('wdesk:lstOwnr:'+iCount+':OId').checked){
            tmpUpl+=document.getElementById('wdesk:lstOwnr:'+iCount+':OName').innerHTML.trim()+',';
            fnum++;
        } 
    }
    fnum+=getFrequency(tmpDt,'1')+getFrequency(tmpType,'1');
    var fRef = document.getElementById('wdesk:FNum');
    if(fRef)
        fRef.value=fnum;
    var upWithinRef = document.getElementById('wdesk:UpWithin');
    if(upWithinRef)
        upWithinRef.value=tmpDt;
    var DTypeFilRef = document.getElementById('wdesk:DTypeFil');
    if(DTypeFilRef)
        DTypeFilRef.value=tmpType;
    var selOwners = document.getElementById('wdesk:docOwners');
    if(selOwners)
        selOwners.value = tmpUpl;
    var result = [tmpType,tmpDt,tmpUpl];
    if(tmpType.indexOf('1')>-1||tmpDt.indexOf('1')>-1||tmpUpl.length>0)
        document.getElementById('wdesk:bFEnabled').value=true;
    else if(!(tmpType.indexOf('1')>-1||tmpDt.indexOf('1')>-1||tmpUpl.length>0))
        document.getElementById('wdesk:bFEnabled').value=false;
    return result;
}
function getFrequency(str,chr){
    var f=0;
    for(var i=0;i<str.length;i++)
        if(chr==str.charAt(i))
            f++;
    return f;
}
function clearFilter(){
    var uTable,rc;
    var iCount = 0;
    uTable = document.getElementById('wdesk:dtypef');
    rc = uTable.rows[0].cells.length;   
    for(iCount = 0; iCount < rc;iCount++){
        document.getElementById('wdesk:dtypef:'+iCount).checked=false;
    }
    uTable= document.getElementById('wdesk:updtf');
    rc = uTable.rows.length;   
    
    for(iCount = 0; iCount < rc;iCount++){
        document.getElementById('wdesk:updtf:'+iCount).checked=false;
    }
    uTable= document.getElementById('wdesk:lstOwnr');
    rc = uTable.rows.length; 
    for(iCount = 0; iCount < rc;iCount++){
        document.getElementById('wdesk:lstOwnr:'+iCount+':OId').checked=false;
    }
}
function changePrefix(event,flag){

    var searchPrefix = document.getElementById("wdesk:searchPrefix");
    var prefix = document.getElementById("wdesk:Prefix");
    
    if(flag ==1)
    {
        if(searchPrefix.value=="" && prefix.value == OP_SEARCH_DOCUMENT)
            prefix.value="";
        else{
            if(prefix.value != searchPrefix.value && prefix.value == OP_SEARCH_DOCUMENT){
                prefix.value=searchPrefix.value;
            }
        }
    }
    else
    {
        if(searchPrefix.value=="")
            prefix.value=OP_SEARCH_DOCUMENT;
        else{
            if(prefix.value != searchPrefix.value){
                prefix.value=searchPrefix.value;
            } else if(prefix.value == OP_SEARCH_DOCUMENT){
                searchPrefix.value="";
            }
        }
    }
    
    cancelBubble(event);
}
function docSrchOnChange(event, ref)
{
    var ref2 = document.getElementById("wdesk:searchPrefix");
    ref2.value= ref.value;
    
    cancelBubble(event);
}
function searchDocs(event){
    document.getElementById("wdesk:bSEnabled").value=true;
    document.getElementById("wdesk:curBatch").value="0";
    showavailfilters('C');
    rs = getRequestString();
    loadWdSidebar('Documents', getParentSidebar('Documents'), null, 'opt=1'+rs, 'wdesk:scrolldocdiv',"navCallBack()");
    cancelBubble(event);
}
function searchCallBack(){
    var clrRef = document.getElementById('wdesk:clearSrch');
    var se = document.getElementById('wdesk:bSEnabled');
    var rnum = document.getElementById('wdesk:SrchResNum');
    var rt = document.getElementById('wdesk:SrchResTotal');
    var txt = document.getElementById('wdesk:SrchTxt');
    txt.innerHTML=encode_ParamValue(SHOWING+' '+ rnum.value+' '+OF+' '+ rt.value+' '+RESULTS);
    if(rnum.value=='0') {
        if(hasCSS(txt,'db')) {removeCSS(txt,'db');addCSS(txt,'dn')}
    } else{
        if(hasCSS(txt,'dn')) {removeCSS(txt,'dn');addCSS(txt,'db')}
    }
        
    if(se.value=='true'){
        if(hasCSS(clrRef,'dn')) {removeCSS(clrRef,'dn');addCSS(clrRef,'db')}
    } else{
        if(hasCSS(clrRef,'db')) {removeCSS(clrRef,'db');addCSS(clrRef,'dn')}
    }  
}
function filterCallBack(){
    showavailfilters('H');
    var fRef = document.getElementById('wdesk:FNum');
    var fNlbl = document.getElementById('wdesk:fNumlbl');
    if(fRef && fNlbl){
        fNlbl.innerHTML=encode_ParamValue('('+ fRef.value+')');
    }
}
function HandleEnterSD(e){
    var browser=navigator.appName;
    var ref,ref2;
    if(browser=="Netscape")
    {
        if(e.which == 13)
        {
            ref = document.getElementById("wdesk:searchPrefix");            
            ref2 = document.getElementById("wdesk:Prefix");
            ref.value=ref2.value;       
            searchDocs();     
            cancelBubble(e);
        }
    }
    else
    {
        e=window.event;
        if(e.keyCode == 13)
        {
            ref = document.getElementById("wdesk:searchPrefix");            
            ref2 = document.getElementById("wdesk:Prefix");
            ref.value=ref2.value;       
            searchDocs();     
            cancelBubble(e);
        }
    }
}
function getRequestString(){
    var fe = document.getElementById('wdesk:bFEnabled');
    var se = document.getElementById('wdesk:bSEnabled');
    var cb = document.getElementById('wdesk:curBatch');
    var sp = document.getElementById("wdesk:searchPrefix");
    var fn = document.getElementById("wdesk:FNum");
    var filter = setFilterOptions();
	
	if(sp.value == ""){

		se.value = false;

	}
	
    var requeststring = '&BN='+cb.value+'&BSearch='+se.value+'&BFilter='+fe.value;
    requeststring+='&sval='+encode_utf8(sp.value);
    requeststring+='&DTypeF='+filter[0]+'&UPW='+filter[1]+'&UPB='+filter[2];
    requeststring+='&FNum='+fn.value;

    return requeststring;
}
function showmoreoptdiv(event,link){
    event = event || window.event;
    var source = event.target || event.srcElement;  
    var divRef;
    if(link){
        var linkarr = link.id.split(':');
        divRef = document.getElementById(linkarr[0]+':'+linkarr[1]+':'+linkarr[2]+':MoreOptDiv');
    }
    hideAllOAPMenu(divRef);
    if(hasCSS(divRef,'dn')) {
        removeCSS(divRef,'dn');
        addCSS(divRef,'db');
        divRef.style.display = 'block';
    }
    else {
        removeCSS(divRef,'db');
        addCSS(divRef,'dn');
        divRef.style.display = 'none';
    }
    var ref = document.getElementById('wdesk:scrolldocdiv');
    
    var rd =  getRealDimension(source);
    var left = findAbsPosX(source)-findAbsPosX(document.getElementById("DocumentsDiv"));
    if(left <= 0) {
        left = Math.abs(findAbsPosX(source)-findAbsPosX(document.getElementById("DocumentsDiv")));
    } else {
        left = (findAbsPosX(source)-findAbsPosX(document.getElementById("DocumentsDiv")) - getRealDimension(divRef).Width + 10);
        if(left < 0){
            left = findAbsPosX(source) - rd.Width;
        }
    }
    
    divRef.style.left = left + "px";
    divRef.style.top =(source.offsetTop + rd.Height - ref.scrollTop) + "px";
    cancelBubble(event);
}