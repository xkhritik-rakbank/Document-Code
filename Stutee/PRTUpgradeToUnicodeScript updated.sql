/*-------------------------------------------------------------------------
		CHANGE HISTORY
---------------------------------------------------------------------------
 Date		Change By		Change Description (Bug No. If Any)
  27/11/2008	Pranay Tiwari		Changes in datatypes of variables to support larger userindex 
12/06/2009	Pranay Tiwari		Bug corrected (PRC1944)
01/09/2009	Sneh			By default, Passwords will be case sensitive
12/12/2017  Shubham Mittal  Constraint removed in PDBStringGlobalIndex as it is dropped later in PRTUpdateScript if exists.
15/12/2017  Shubham Mittal  Added Check for NVARCHAR datatype and Existing NVARCHAR datatype fields assigned length 
19/12/2017  Shubham Mittal  Removed Constraint ck_globalind_gOrDflag from PDBGlobalIndex
---------------------------------------------------------------------------*/
IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBDocument'
	AND COLUMN_NAME = 'Name'
	AND DATA_TYPE = 'NVARCHAR')
BEGIN
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDocument Trimming and Converting to Unicode', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	DECLARE	@TableName		varchar(128)
	DECLARE @ColumnName		nvarchar(128)
	DECLARE @DataType		nvarchar(128)
	DECLARE @PrimaryKey		varchar(128)
	DECLARE @UniqueKey		varchar(128)
	DECLARE @KeyColumnName		varchar(128)
	DECLARE @KeyColumnType		varchar(128)
	DECLARE @TabColumnScript	varchar(8000)
	DECLARE @InsColumnScript	varchar(8000)
	DECLARE @SelColumnScript	varchar(8000)
	DECLARE @IdentityFlag		char(1)

	SELECT	@TableName		= 'PDBDocument'
	SELECT	@ColumnName		= 'Name'
	SELECT	@DataType		= 'NVARCHAR'
	SELECT	@PrimaryKey		= 'pk_dindex'
	SELECT	@UniqueKey		= NULL
	SELECT	@KeyColumnName		= 'DocumentIndex'
	SELECT	@KeyColumnType		= 'int'
	SELECT	@TabColumnScript	= '
			DocumentIndex		int
			IDENTITY(1,1) CONSTRAINT   pk_dindex      	PRIMARY KEY  Clustered,
			VersionNumber		decimal(7,2),
			VersionComment		NVARCHAR(255) NULL,
			Name				NVARCHAR(255),
			Owner				int,
			CreatedDateTime		datetime,
			RevisedDateTime	      datetime,
			AccessedDateTime		datetime,
			DataDefinitionIndex	int,
			Versioning			CHAR CONSTRAINT ck_doc_ver check (Versioning in (''Y'',''N'',''I'')),
			AccessType			CHAR CONSTRAINT ck_doc_atype check (AccessType in (''S'',''P'',''I'')),
			DocumentType		CHAR(5),
			CreatedbyApplication	int,
			CreatedbyUser		int,	
			ImageIndex			int,
			VolumeId			int,
			NoOfPages			int,
			DocumentSize		int,
			FTSDocumentIndex		int,
			ODMADocumentIndex		VARCHAR(128),
			HistoryEnableFlag		CHAR,
			DocumentLock		CHAR CONSTRAINT ck_doc_doclock check (DocumentLock in (''Y'',''N'')),
			LockByUser			VARCHAR(1020) NULL,
			Comment               nvarchar(255) NULL,
			Author			NVARCHAR(64),
			TextImageIndex		int,
			TextVolumeId		int,
			FTSFlag 		CHAR(2),
			DocStatus		CHAR,
			ExpiryDateTime		datetime,
			FinalizedFlag		CHAR CONSTRAINT ck_doc_fflag check (FinalizedFlag IN (''Y'',''N'')),
			FinalizedDateTime		datetime,
			FinalizedBy			int,
			CheckOutstatus		CHAR,
			CheckOutbyUser		int,
			UseFulData			nvarchar(255) null,
			ACL                   varchar(255) null,
			PhysicalLocation      varchar(512),
			ACLMoreFlag 		char null CONSTRAINT ck_doc_aclmflag CHECK (ACLMoreFlag IN (''Y'',''N'')),
			AppName			char(10),
			MainGroupId			int CONSTRAINT df_doc_mgpid default 0 not null,
			PullPrintFlag         CHAR(1) CONSTRAINT df_doc_ppflag default ''N'',
			ThumbNailFlag		CHAR(1) CONSTRAINT df_doc_tflag default ''N'',
			LockMessage		NVARCHAR(255) NULL
	'
		
	SELECT	@InsColumnScript	= ' DocumentIndex, VersionNumber, VersionComment, Name, Owner, CreatedDateTime, RevisedDateTime, AccessedDateTime, DataDefinitionIndex, ' +
					  ' Versioning, AccessType, DocumentType, CreatedbyApplication, CreatedbyUser, ImageIndex, VolumeId, NoOfPages, DocumentSize, FTSDocumentIndex, ' +
					  ' ODMADocumentIndex, HistoryEnableFlag, DocumentLock, LockByUser, Comment, Author, TextImageIndex, TextVolumeId, FTSFlag, DocStatus, ExpiryDateTime, ' +
					  ' FinalizedFlag, FinalizedDateTime, FinalizedBy, CheckOutstatus, CheckOutbyUser, UseFulData, ACL, PhysicalLocation, ACLMoreFlag, AppName, MainGroupId, ' +
					  ' PullPrintFlag,  ThumbNailFlag, LockMessage ' 

	SELECT	@SelColumnScript	= 
					' DocumentIndex, VersionNumber, RTRIM(VersionComment) VersionComment, RTRIM(Name) Name, Owner, CreatedDateTime, RevisedDateTime, AccessedDateTime, DataDefinitionIndex, ' +
					' Versioning, AccessType, DocumentType, CreatedbyApplication, CreatedbyUser, ImageIndex, VolumeId, NoOfPages, DocumentSize, FTSDocumentIndex, ' +
					' RTRIM(ODMADocumentIndex) ODMADocumentIndex, HistoryEnableFlag, DocumentLock, RTRIM(LockByUser) LockByUser, RTRIM(Comment) Comment, RTRIM(Author) Author, ' +
					' TextImageIndex, TextVolumeId, FTSFlag, DocStatus, ExpiryDateTime, FinalizedFlag, FinalizedDateTime, FinalizedBy, ' +
					' CheckOutstatus, CheckOutbyUser, RTRIM(UseFulData) UseFulData, RTRIM(ACL) ACL, RTRIM(PhysicalLocation) PhysicalLocation, ' +
					' ACLMoreFlag, AppName, MainGroupId, PullPrintFlag, ThumbNailFlag, RTRIM(LockMessage) LockMessage '


	SELECT	@IdentityFlag		= 'Y'

	DECLARE @Status			int
	EXEC ConvertTableToUnicode
		@TableName,
		@ColumnName,
		@DataType,
		@PrimaryKey,
		@UniqueKey,
		@KeyColumnName,
		@KeyColumnType,
		@TabColumnScript,
		@InsColumnScript,
		@SelColumnScript,
		@IdentityFlag,
		@StepNo,
		@Status OUT

	IF @Status <> 0
		RETURN
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDocument Trimming and Converting to Unicode', GETDATE(), NULL, 'Already Updated')
END
;
IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBFolder'
	AND COLUMN_NAME = 'Name'
	AND DATA_TYPE = 'NVARCHAR')
BEGIN
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBFolder Trimming and Converting to Unicode', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	DECLARE	@TableName		varchar(128)
	DECLARE @ColumnName		nvarchar(128)
	DECLARE @DataType		nvarchar(128)
	DECLARE @PrimaryKey		varchar(128)
	DECLARE @UniqueKey		varchar(128)
	DECLARE @KeyColumnName		varchar(128)
	DECLARE @KeyColumnType		varchar(128)
	DECLARE @TabColumnScript	varchar(8000)
	DECLARE @InsColumnScript	varchar(8000)
	DECLARE @SelColumnScript	varchar(8000)
	DECLARE @IdentityFlag		char(1)


	DECLARE @HeirarchyColExists	char(1)
	DECLARE @OwnerInhColExists	char(1)

	SELECT	@TableName		= 'PDBFolder'
	SELECT	@ColumnName		= 'Name'
	SELECT	@DataType		= 'NVARCHAR'
	SELECT	@PrimaryKey		= 'pk_findex'
	SELECT	@UniqueKey		= 'uk_pindex_name'
	SELECT	@KeyColumnName		= 'FolderIndex'
	SELECT	@KeyColumnType		= 'int'
	SELECT	@TabColumnScript	= '
			FolderIndex			int
			IDENTITY(1,1) CONSTRAINT   pk_findex      PRIMARY KEY  Clustered,
			ParentFolderIndex		int,
			Name				NVARCHAR(255),
			Owner				int,
			CreatedDatetime		datetime,
			RevisedDateTime		datetime,
			AccessedDateTime		datetime,
			DataDefinitionIndex		int,
			AccessType			CHAR CONSTRAINT ck_folder_atype check (AccessType IN (''S'',''I'',''P'')),
			ImageVolumeIndex		int,
			FolderType			CHAR CONSTRAINT ck_folder_ftype check (FolderType IN (''S'',''I'',''T'',''G'',''A'',''H'',''K'',''W'')),
			FolderLock			CHAR,
			LockByUser			VARCHAR(1020) NULL,
			Location			CHAR CONSTRAINT ck_folder_loc check (Location IN (''S'',''I'',''T'',''G'',''R'',''A'',''H'',''K'',''W'')),
			DeletedDateTime		datetime,
			EnableVersion		CHAR CONSTRAINT ck_folder_enablever check (EnableVersion IN (''Y'',''N'',''I'')),
			ExpiryDateTime		datetime,
			Comment			NVARCHAR(255) NULL,
			UseFulData			nvarchar(255) NULL,
			ACL                   varchar(255) NULL,
			FinalizedFlag		CHAR(1) CONSTRAINT ck_folder_fflag check (FinalizedFlag IN (''Y'',''N'')),
			FinalizedDateTime		datetime,
			FinalizedBy			int,
			ACLMoreFlag 			char(1) null CONSTRAINT ck_folder_aclmflag check (ACLMoreFlag IN (''Y'',''N'')),
			MainGroupId			smallint CONSTRAINT df_folder_mgpid default 0 not null,
			EnableFTS			CHAR(1) CONSTRAINT ck_folder_enablefts check (EnableFTS IN (''Y'',''N'')),
			LockMessage			NVARCHAR(255) NULL,
			FolderLevel			int NULL,
			Hierarchy			varchar(2500) NULL,
			OwnerInheritance		CHAR(1) CONSTRAINT df_folder_owni DEFAULT ''N''
			CONSTRAINT   uk_pindex_name     UNIQUE (ParentFolderIndex,Name,MainGroupId)
	'
		
	SELECT	@InsColumnScript	= ' FolderIndex, ParentFolderIndex, Name, Owner, CreatedDatetime, RevisedDateTime, AccessedDateTime, DataDefinitionIndex, AccessType, ImageVolumeIndex, FolderType, FolderLock, LockByUser, Location, DeletedDateTime, EnableVersion, ExpiryDateTime, Comment, UseFulData, ACL, FinalizedFlag, FinalizedDateTime, FinalizedBy, ACLMoreFlag, MainGroupId, EnableFTS, LockMessage, FolderLevel, Hierarchy, OwnerInheritance '

	SELECT	@SelColumnScript	=  ' FolderIndex, ParentFolderIndex, RTRIM(Name) Name, Owner, CreatedDatetime, RevisedDateTime, AccessedDateTime, DataDefinitionIndex, AccessType, ImageVolumeIndex, FolderType, FolderLock, RTRIM(LockByUser) LockByUser, Location, DeletedDateTime, EnableVersion, ExpiryDateTime, RTRIM(Comment) Comment, RTRIM(UseFulData) UseFulData, RTRIM(ACL) ACL, FinalizedFlag, FinalizedDateTime, FinalizedBy, ACLMoreFlag, MainGroupId, EnableFTS, RTRIM(LockMessage) LockMessage, FolderLevel, '


	IF EXISTS(
		SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'PDBFolder'
		AND COLUMN_NAME = 'OwnerInheritance'
	)
		SELECT @OwnerInhColExists = 'Y'
	ELSE
		SELECT @OwnerInhColExists = 'N'
	

	IF EXISTS(
		SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'PDBFolder'
		AND COLUMN_NAME = 'Hierarchy'
	)
		SELECT @HeirarchyColExists = 'Y'
	ELSE
		SELECT @HeirarchyColExists = 'N'
	IF @HeirarchyColExists = 'N'
	BEGIN
		SELECT @SelColumnScript = RTRIM(@SelColumnScript) + 'NULL, ''N'''
	END
	ELSE IF @OwnerInhColExists = 'N'
	BEGIN
		SELECT @SelColumnScript = RTRIM(@SelColumnScript) + 'RTRIM(Hierarchy) Hierarchy, ''N'''
	END
	ELSE
	BEGIN
		SELECT @SelColumnScript = RTRIM(@SelColumnScript) + 'RTRIM(Hierarchy) Hierarchy, OwnerInheritance'
	END

	SELECT	@IdentityFlag		= 'Y'

	DECLARE @Status			int
	EXEC ConvertTableToUnicode

		@TableName,
		@ColumnName,
		@DataType,
		@PrimaryKey,
		@UniqueKey,
		@KeyColumnName,
		@KeyColumnType,
		@TabColumnScript,
		@InsColumnScript,
		@SelColumnScript,
		@IdentityFlag,
		@StepNo,
		@Status OUT

	IF @Status <> 0
		RETURN
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBFolder Trimming and Converting to Unicode', GETDATE(), NULL, 'Already Updated')
END
;
IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBConstant'
	AND COLUMN_NAME = 'Type'
	AND DATA_TYPE = 'VARCHAR'
)
BEGIN
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBConstant, Converting to Unicode and Reinserting Data', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	DROP TABLE PDBConstant
	CREATE TABLE PDBConstant
	(
		Id	int
		CONSTRAINT	PK_CONS    PRIMARY KEY CLUSTERED,
		message	    	varchar(255)
		CONSTRAINT   uk_cONS1      	UNIQUE   NONCLUSTERED,
		Type	   		VarChar(25)
	)

	Insert into PDBConstant values(50001,  'PRT_WARN_Invalid_New_Version_Number', 'Warning')
	Insert into PDBConstant values(50002,  'PRT_WARN_Data_Exists_With_Fields', 'Warning')
	Insert into PDBConstant values(50003,  'PRT_WARN_Index_Already_Exists', 'Warning')
	Insert into PDBConstant values(50004,  'PRT_WARN_Index_Associated_With_Document', 'Warning')
	Insert into PDBConstant values(50005,  'PRT_WARN_Field_Associated_With_DDI', 'Warning')
	Insert into PDBConstant values(50006,  'PRT_WARN_Not_All_Reminders_Set', 'Warning')
	Insert into PDBConstant values(50007,  'PRT_WARN_Not_All_Alarms_Set', 'Warning')
	Insert into PDBConstant values(50008,  'PRT_WARN_Cannot_CopyDDI', 'Warning')
	Insert into PDBConstant values(50009,  'PRT_WARN_Not_All_Folders_Deleted', 'Warning')
	Insert into PDBConstant values(50010,  'PRT_WARN_Not_All_Documents_Deleted', 'Warning')
	Insert into PDBConstant values(50011,  'PRT_WARN_Not_All_Documents_Checked_Out', 'Warning')
	Insert into PDBConstant values(50012,  'PRT_WARN_Not_All_Documents_Checked_In', 'Warning')
	Insert into PDBConstant values(50013,  'PRT_WARN_Not_All_Documents_Undo_Checked_Out', 'Warning')
	Insert into PDBConstant values(50014,  'PRT_WARN_Not_All_Documents_Copied', 'warning') 
	Insert into PDBConstant values(50015,  'PRT_WARN_Not_All_Documents_Moved' , 'warning ')
	Insert into PDBConstant values(50016,  'PRT_WARN_Not_All_Users_Found', 'Warning')
	Insert into PDBConstant values(50017,  'PRT_WARN_Not_All_Users_Added', 'Warning')
	Insert into PDBConstant values(50018,  'PRT_WARN_User_Table_Not_Deleted', 'Warning')
	Insert into PDBConstant values(50019,  'PRT_WARN_Not_All_ReferencesAdded', 'Warning')
	INSERT INTO PDBConstant VALUES (50020,  'PRT_WARN_Not_All_Annotations_Modified_Or_Deleted', 'Warning')
	INSERT INTO PDBConstant VALUES (50021,  'PRT_WARN_Post_No_Right', 'Warning')
	INSERT INTO PDBConstant VALUES (50022,  'PRT_WARN_Not_All_Roles_Deleted', 'Warning')
	INSERT INTO PDBConstant VALUES(50023, 'PRT_WARN_Not_All_Requests_Deleted', 'Warning')
	Insert into PDBConstant values(-50001,  'PRT_ERR_Cabinet_Not_Exist', 'Error')
	Insert into PDBConstant values(-50002,  'PRT_ERR_Invalid_Rights_OnCabinet', 'Error')
	Insert into PDBConstant values(-50003, 'PRT_ERR_User_Not_Exist', 'Error')
	Insert into PDBConstant values(-50004, 'PRT_ERR_User_Not_Login', 'Error')
	Insert into PDBConstant values(-50005, 'PRT_ERR_User_Already_Login', 'Error')
	Insert into PDBConstant values(-50006, 'PRT_ERR_User_Expired', 'Error')
	Insert into PDBConstant values(-50007, 'PRT_ERR_Invalid_UserIndex', 'Error')
	Insert into PDBConstant values(-50008, 'PRT_ERR_InvalidRights_On_User', 'Error')
	Insert into PDBConstant values(-50009, 'PRT_ERR_User_Name_Already_Exists', 'Error')
	Insert into PDBConstant values(-50010, 'PRT_ERR_User_Not_Alive', 'Error')
	Insert into PDBConstant values(-50011, 'PRT_ERR_User_Invalid_Privilege_OnGroup', 'Error')
	Insert into PDBConstant values(-50012, 'PRT_ERR_Invalid_Privilege_OnTargetUser','Error')
	Insert into PDBConstant values(-50013, 'PRT_ERR_Group_Not_Found','Error')
	Insert into PDBConstant values(-50014, 'PRT_ERR_Group_Name_Already_Exists','Error')
	Insert into PDBConstant values(-50015, 'PRT_ERR_Invalid_Privilages_OnGroup','Error')
	Insert into PDBConstant values(-50016, 'PRT_ERR_Invalid_GroupIndex','Error')
	Insert into PDBConstant values(-50017, 'PRT_ERR_Folder_Not_Exist', 'Error')
	Insert into PDBConstant values(-50018, 'PRT_ERR_Invalid_Rights_OnFolder', 'Error')
	Insert into PDBConstant values(-50019, 'PRT_ERR_Finalised_Folder', 'Error')
	Insert into PDBConstant values(-50020, 'PRT_ERR_Folder_Already_Referenced', 'Error')
	Insert into PDBConstant values(-50021, 'PRT_ERR_Folder_Locked', 'Error')
	Insert into PDBConstant values(-50022, 'PRT_ERR_Invalid_Rights_OnDocument', 'Error')
	Insert into PDBConstant values(-50023, 'PRT_ERR_Document_Not_Found', 'Error')
	Insert into PDBConstant values(-50024, 'PRT_ERR_UnOrdered_Docs', 'Error')
	Insert into PDBConstant values(-50025, 'PRT_ERR_Invalid_DocumentIndex', 'Error')
	Insert into PDBConstant values(-50026, 'PRT_ERR_Document_Locked', 'Error')
	Insert into PDBConstant values(-50027, 'PRT_ERR_Document_Finalized', 'Error')
	Insert into PDBConstant values(-50028, 'PRT_ERR_DDI_Not_Exist', 'Error')
	Insert into PDBConstant values(-50029, 'PRT_ERR_DDI_Associated_With_Folder', 'Error')
	Insert into PDBConstant values(-50030, 'PRT_ERR_DDI_Associated_With_Document', 'Error')
	Insert into PDBConstant values(-50031, 'PRT_ERR_DataDefinition_Name_Already_Exists', 'Error')
	Insert into PDBConstant values(-50032, 'PRT_ERR_InvalidRights_On_DDI', 'Error')
	Insert into PDBConstant values(-50033, 'PRT_ERR_DDI_Contains_Data', 'Error')
	Insert into PDBConstant values(-50034, 'PRT_ERR_Annotation_Not_Exist', 'Error')
	Insert into PDBConstant values(-50035, 'PRT_ERR_Invalid_AnnotationIndex', 'Error')
	Insert into PDBConstant values(-50036, 'PRT_ERR_Some_Keywords_Not_Exists', 'Error')
	Insert into PDBConstant values(-50037, 'PRT_ERR_Some_Keywords_Already_Exist', 'Error')
	Insert into PDBConstant values(-50038, 'PRT_ERR_Keywords_Index_Not_Exists', 'Error')
	Insert into PDBConstant values(-50039, 'PRT_ERR_All_Keyword_Index_Not_Exists', 'Error')
	Insert into PDBConstant values(-50040, 'PRT_ERR_All_Keyword_Index_Already_Exists', 'Error')
	Insert into PDBConstant values(-50041, 'PRT_ERR_Keywords_Already_Exists', 'Error')
	Insert into PDBConstant values(-50042, 'PRT_ERR_Cannot_Generate_AuditTrail', 'Error')
	Insert into PDBConstant values(-50043, 'PRT_ERR_GlobalIndex_Not_Exist', 'Error')
	Insert into PDBConstant values(-50044, 'PRT_ERR_GlobalIndex_Already_Exists', 'Error')
	Insert into PDBConstant values(-50045, 'PRT_ERR_Field_Does_Not_Exists', 'Error')
	Insert into PDBConstant values(-50046, 'PRT_ERR_Invalid_Field_Type', 'Error')
	Insert into PDBConstant values(-50047, 'PRT_ERR_Invalid_Field_Length', 'Error')
	Insert into PDBConstant values(-50048, 'PRT_ERR_Field_Is_Not_Associated_With_DDI', 'Error')
	Insert into PDBConstant values(-50049, 'PRT_ERR_Some_Keywords_Not_Exists_InAlias', 'Error')
	Insert into PDBConstant values(-50050, 'PRT_ERR_Alias_Index_Not_Exists', 'Error')
	Insert into PDBConstant values(-50051, 'PRT_ERR_Invalid_Action', 'Error')
	Insert into PDBConstant values(-50052, 'PRT_ERR_Primary_Key_Attribute_Not_Allowed', 'Error')
	Insert into PDBConstant values(-50053, 'PRT_ERR_CheckRights_Failed', 'Error')
	Insert into PDBConstant values(-50054, 'PRT_ERR_Invalid_ObjectType', 'Error')
	Insert into PDBConstant values(-50055, 'PRT_ERR_Create_TempTable_Failed', 'Error')
	Insert into PDBConstant values(-50056, 'PRT_ERR_Page_Not_Exist', 'Error')
	Insert into PDBConstant values(-50057, 'PRT_ERR_Invalid_Privilege', 'Error')
	Insert into PDBConstant values(-50058, 'PRT_ERR_Target_User_Not_Exist','Error')      
	Insert into PDBConstant values(-50059,'PRT_ERR_Invalid_Priveledge_On_User','ERROR')
	Insert into PDBConstant values(-50060, 'PRT_ERR_AnnotationIndex_Not_Exists','Error')      
	Insert into PDBConstant values(-50061, 'PRT_ERR_InvalidRights_On_Annotation','Error')  
	Insert into PDBConstant values(-50062, 'PRT_ERR_Target_User_Already_Login','Error') 
	Insert into PDBConstant values(-50063, 'PRT_ERR_Target_User_Expired','Error') 
	Insert into PDBConstant values(-50064, 'PRT_ERR_Target_User_Not_Alive','Error') 
	Insert into PDBConstant values(-50065, 'PRT_ERR_ObjectId_Not_Exists','Error')      				    
	INSERT INTO PDBCONSTANT VALUES (-50066,'PRT_ERR_Group_Expired','Error')
	Insert into PDBConstant values(-50067, 'PRT_ERR_Cannot_Move_Folder','Error') 
	Insert into PDBConstant values(-50068, 'PRT_ERR_Cannot_Move_Document','Error') 
	Insert into PDBConstant values(-50069, 'PRT_ERR_Cannot_Copy_Folder','Error') 
	Insert into PDBConstant values(-50070, 'PRT_ERR_Cannot_Copy_Document','Error') 
	Insert into PDBConstant values(-50071, 'PRT_ERR_Document_Check_Out','Error') 
	Insert into PDBConstant values(-50072, 'PRT_ERR_Document_Already_Exist','Error') 
	Insert into PDBConstant values(-50073, 'PRT_ERR_Cannot_Assign_Rights_ToAdmin','Error')      
	Insert into PDBConstant values(-50074, 'PRT_ERR_Invalid_Parameter','Error') 
	Insert into PDBConstant values(-50075, 'PRT_ERR_CreateVersion_Failed','Error')      
	Insert into PDBConstant values(-50076, 'PRT_ERR_Invalid_Object_AccessType','Error')      
	Insert into PDBConstant values(-50077, 'PRT_ERR_Field_Already_Associated_With_DDI','ERROR')      
	Insert into PDBConstant values(-50078, 'PRT_ERR_User_Not_Admin','Error')      
	Insert into PDBConstant values(-50079, 'PRT_ERR_Target_User_Not_Login','Error')      
	Insert into PDBConstant values(-50080, 'PRT_ERR_Admin_Not_Login','Error')      
	Insert into PDBConstant values(-50081, 'PRT_ERR_Data_Not_Available','Error')      
	Insert into PDBConstant values(-50082, 'PRT_ERR_GlobalIndex_Associated_With_DDI','Error')
	Insert into PDBConstant values(-50083, 'PRT_ERR_Fieldname_Already_Exists','Error')
	Insert into PDBConstant values(-50084, 'PRT_ERR_Cannot_Delete_Supervisor','Error')
	Insert into PDBConstant values(-50085, 'PRT_ERR_Cannot_Delete_System_Group','Error')
	Insert into PDBConstant values(-50086, 'PRT_ERR_Document_Is_Expired','Error')
	Insert into PDBConstant values(-50087, 'PRT_ERR_Invalid_Owner','Error')
	Insert into PDBConstant values(-50088,  'PRT_ERR_Invalid_Flag','Error')
	Insert into PDBConstant values(-50089,  'PRT_ERR_AnnotationName_Not_Exists','Error')
	Insert into PDBConstant values(-50090,  'PRT_ERR_AnnotationName_Already_Exist','Error')
	Insert into PDBConstant values(-50091,  'PRT_ERR_Versioning_NotAllowed','Error')
	Insert into PDBConstant values(-50092,  'PRT_ERR_Invalid_Application','Error')
	Insert into PDBConstant values(-50093,  'PRT_ERR_Cannot_Change_Owner','Error')
	Insert into PDBConstant values(-50094,  'PRT_ERR_No_GlobalIndex_Associated','Error')
	Insert into PDBConstant values(-50095,  'PRT_ERR_Service_Already_Exists_OnHost','Error')
	Insert into PDBConstant values(-50096,  'PRT_ERR_Invalid_Priviledge_On_GlobalIndex','Error')
	Insert into PDBConstant values(-50097,  'PRT_ERR_Folder_Dynamic_Table_Already_Exists','Error')
	Insert into PDBConstant values(-50098,  'PRT_ERR_Document_Dynamic_Table_Already_Exists','Error')
	Insert into PDBConstant values(-50099,  'PRT_ERR_Service_Not_Exists','Error')                     
	Insert into PDBConstant values(-50100,	'PRT_ERR_GlobalIndex_Associated_With_Document','Error')
	insert into PDBConstant values(-50101,'PRT_ERR_Application_Already_Registered','Error')
	insert into PDBConstant values(-50102,'PRT_ERR_Application_Not_Found','Error')
	insert into PDBconstant values(-50103,'PRT_ERR_Invalid_GlobalOrDataFlag','Error')
	insert into PDBconstant values(-50104,'PRT_ERR_Invalid_FolderType','Error')
	insert into PDBconstant values(-50105,'PRT_ERR_PrimaryKey_Already_Exists','Error')
	insert into PDBconstant values(-50106,'PRT_ERR_Invalid_Attribute','Error')
	insert into PDBconstant values(-50107,'PRT_ERR_Invalid_Priviledge_On_DDI','Error')
	insert into PDBconstant values(-50108,'PRT_ERR_DataDefIndex_DoesNot_Exists','Error')
	insert into PDBconstant values(-50109,'PRT_ERR_Duplicate_FieldName_For_DDI','Error')
	insert into PDBconstant values(-50110,'PRT_ERR_InvalidRights_On_Cabinet','Error')
	insert into PDBconstant values(-50111,'PRT_ERR_InvalidVersion_ForDoc','Error')
	insert into PDBconstant values(-50112,'PRT_ERR_Cursor_Fails','Error')
	insert into PDBconstant values(-50113,'PRT_ERR_Version_Already_Exists','Error')
	insert into PDBconstant values(-50114,'PRT_ERR_User_Already_In_Group','Error')
	insert into PDBconstant values(-50115,'PRT_ERR_DDI_Contains_No_Fields','Error')
	insert into PDBconstant values (-50116,'PRT_ERR_Invalid_Priviledge','Error')
	insert into PDBconstant values (-50117,'PRT_ERR_Invalid_Oper_On_EveryOneGroup','Error')
	insert into PDBconstant values (-50118,'PRT_ERR_Cannot_AddFolder','Error')
	insert into PDBconstant values (-50119,'PRT_ERR_Folder_Not_Exist_InEditableArea','Error')
	INSERT INTO PDBCONSTANT VALUES(-50120,'PRT_ERR_Invalid_Name','Error')
	INSERT INTO PDBCONSTANT VALUES(-50121,'PRT_ERR_Doc_Not_Referenced','Error')
	INSERT INTO PDBCONSTANT VALUES(-50122,'PRT_ERR_Doc_Already_Referenced','Error')
	INSERT INTO PDBCONSTANT VALUES(-50123,'PRT_ERR_Folder_Not_Referenced','Error')
	INSERT INTO PDBCONSTANT VALUES(-50124,'PRT_ERR_Name_Already_Exists','Error')
	INSERT INTO PDBCONSTANT VALUES(-50125,'PRT_ERR_Cabinet_Locked','Error')
	INSERT INTO PDBCONSTANT VALUES(-50126,'PRT_ERR_User_Not_Able_Unlock','Error')
	INSERT INTO PDBCONSTANT VALUES(-50127,'PRT_ERR_Invalid_Password','Error')
	INSERT INTO PDBCONSTANT VALUES(-50128,'PRT_ERR_Member_Cannot_Modify_Priv','Error')
	insert into PDBconstant values(-50129,'PRT_ERR_Member_Cannot_Assign_Rights','Error')
	insert into PDBconstant values(-50130,'PRT_ERR_User_Cannot_Assign_Rights_ToHimself','Error')
	insert into PDBconstant values(-50131,'PRT_ERR_Form_Name_Already_Exists','Error')
	insert into PDBconstant values(-50132,'PRT_ERR_Document_Has_Been_Deleted','Error')
	insert into PDBconstant values(-50133,'PRT_ERR_Folder_Has_Been_Deleted','Error')
	Insert into PDBConstant values(-50134,'PRT_ERR_Folder_Is_Expired','Error')
	Insert into PDBConstant values(-50135,'PRT_ERR_Member_Cannot_Delete_Group','Error')
	Insert into PDBConstant values(-50136,'PRT_ERR_Document_Referance_Already_Exist','Error')
	Insert into PDBConstant values(-50137,'PRT_ERR_Value_Already_Exists','Error')
	Insert into PDBConstant values(-50138,'PRT_ERR_User_Not_OwnerOrAdmin','Error')
	Insert into PDBConstant values(-50139,'PRT_ERR_Invalid_ExpiryDate','Error')
	Insert into PDBConstant values(-50140,'PRT_ERR_Member_Cannot_Modify_ExpiryDate','Error')
	Insert into PDBConstant values(-50141,'PRT_ERR_Cannot_Connect','Error')
	Insert into PDBConstant values(-50142, 'PRT_ERR_Invalid_Alarm_Type','Error')
	Insert into PDBConstant values(-50143, 'PRT_ERR_Invalid_Alarm_Object','Error')
	Insert into PDBConstant values(-50144, 'PRT_ERR_Invalid_Alarm_Action','Error')
	Insert into PDBConstant values(-50145, 'PRT_ERR_Alarm_Already_Set','Error')
	Insert into PDBConstant values(-50146, 'PRT_ERR_Invalid_Session','Error')
	Insert into PDBConstant values(-50147, 'PRT_ERR_Version_Locked','Error')
	Insert into PDBConstant values(-50148, 'PRT_ERR_Form_Not_Exist','Error')
	INSERT INTO PDBCONSTANT VALUES(-50149,'PRT_ERR_Reminder_Already_Set','Error')
	INSERT INTO PDBCONSTANT VALUES(-50150,'PRT_ERR_Invalid_Reminder_Date','Error')
	INSERT INTO PDBCONSTANT VALUES(-50151,'PRT_ERR_Reminder_Date_Already_Past','Error')
	INSERT INTO PDBCONSTANT VALUES(-50152,'PRT_ERR_Index_Already_Exists','Error')
	INSERT INTO PDBCONSTANT VALUES(-50153,'PRT_ERR_Rights_Already_Exist','Error')
	INSERT INTO PDBCONSTANT VALUES(-50154,'PRT_ERR_DDI_Not_Associated_With_Document','Error')
	INSERT INTO PDBConstant values(-50155,'PRT_ERR_Object_Not_Locked', 'Error')
	INSERT INTO PDBCONSTANT VALUES(-50156,'PRT_ERR_Rights_Does_Not_Exist','Error')
	INSERT INTO PDBCONSTANT VALUES(-50157,	'PRT_ERR_PickList_NotAvailable_For_TextType','Error')
	INSERT INTO PDBCONSTANT VALUES(-50158,	'PRT_ERR_Document_Already_Checked_Out',	'Error')
	INSERT INTO PDBCONSTANT VALUES(-50159,	'PRT_ERR_Document_Not_Checked_Out',	'Error')
	INSERT INTO PDBCONSTANT VALUES(-50160,	'PRT_ERR_FTS_Population_In_Progress',	'Error')
	INSERT INTO PDBCONSTANT VALUES(-50161,	'PRT_ERR_FTS_Paused',	'Error')
	INSERT INTO PDBCONSTANT VALUES(-50162,	'PRT_ERR_FTS_Throttled',	'Error')
	INSERT INTO PDBCONSTANT VALUES(-50163,	'PRT_ERR_FTS_Recovering',	'Error')
	INSERT INTO PDBCONSTANT VALUES(-50164,	'PRT_ERR_FTS_Shutdown',	'Error')
	INSERT INTO PDBCONSTANT VALUES(-50165,	'PRT_ERR_FTS_Incremental_Population_In_Progress',	'Error')
	INSERT INTO PDBCONSTANT VALUES(-50166,	'PRT_ERR_FTS_Updating_Index',	'Error')
	INSERT INTO PDBCONSTANT VALUES(-50167,	'PRT_ERR_User_Already_Logged_In', 'Error') 
	INSERT INTO PDBCONSTANT VALUES(-50168,	'PRT_ERR_User_Cannot_Assign_Rights_He_Doesnt_Have', 'Error') 
	INSERT INTO PDBConstant VALUES(-50169, 'PRT_ERR_Alarm_Not_Found','Error')
	INSERT INTO PDBCONSTANT VALUES(-50170,	'PRT_ERR_Document_Deleted_Or_Moved', 'Error') 
	INSERT INTO PDBCONSTANT VALUES(-50171,	'PRT_ERR_Folder_Deleted_Or_Moved', 'Error') 
	INSERT INTO PDBCONSTANT VALUES(-50172,	'PRT_ERR_Keyword_Cannot_have_its_own_alias', 'Error') 
	INSERT INTO PDBCONSTANT VALUES(-50173,	'PRT_ERR_Max_Folder_Count_Reached', 'Error') 
	INSERT INTO PDBCONSTANT VALUES(-50174,	'PRT_ERR_Max_Version_Count_Reached', 'Error') 
	INSERT INTO PDBCONSTANT VALUES(-50175,	'PRT_ERR_Max_DataClass_Count_Reached', 'Error') 
	INSERT INTO PDBCONSTANT VALUES(-50176,	'PRT_ERR_Max_Field_Count_Reached', 'Error') 
	INSERT INTO PDBCONSTANT VALUES(-50177,	'PRT_ERR_Max_User_Count_Reached', 'Error') 
	INSERT INTO PDBCONSTANT VALUES(-50178,	'PRT_ERR_Max_Group_Count_Reached', 'Error') 
	INSERT INTO PDBCONSTANT VALUES(-50179,	'PRT_ERR_List_Already_Exists', 'Error') 
	INSERT INTO PDBCONSTANT VALUES(-50180,	'PRT_ERR_List_Not_Found', 'Error') 
	INSERT INTO PDBCONSTANT VALUES(-50181,	'PRT_ERR_User_Table_Already_Exists', 'Error') 
	INSERT INTO PDBCONSTANT VALUES(-50182,	'PRT_ERR_User_Table_Not_Exists', 'Error') 
	INSERT INTO PDBCONSTANT VALUES(-50183,	'PRT_ERR_Finalized_Object', 'Error') 
	INSERT INTO PDBCONSTANT VALUES(-50184,	'PRT_ERR_Object_not_exists', 'Error') 
	INSERT INTO PDBCONSTANT VALUES(-50185,	'PRT_ERR_Cannot_Delete_DDI', 'Error') 
	INSERT INTO PDBCONSTANT VALUES(-50186,	'PRT_ERR_Route_Already_Exists', 'Error') 
	INSERT INTO PDBCONSTANT VALUES(-50187,	'PRT_ERR_Route_Not_Found', 'Error') 
	INSERT INTO PDBCONSTANT VALUES(-50188,	'PRT_ERR_No_Routes_For_User', 'Error') 
	INSERT INTO PDBCONSTANT VALUES(-50189,	'PRT_ERR_Max_Level_Count_Reached', 'Error') 
	INSERT INTO PDBCONSTANT VALUES(-50190,	'PRT_ERR_Form_Locked', 'Error') 
	INSERT INTO PDBCONSTANT VALUES(-50191,	'PRT_ERR_Reminder_Not_Set', 'Error') 
	INSERT INTO PDBCONSTANT VALUES(-50192,	'PRT_ERR_Object_Locked_By_SameUser', 'Error') 
	INSERT INTO PDBCONSTANT VALUES(-50193,	'PRT_ERR_Link_Note_Already_Exists', 'Error') 
	INSERT INTO PDBCONSTANT VALUES(-50194,	'PRT_ERR_Annotation_Not_Latest', 'Error') 
	INSERT INTO PDBCONSTANT VALUES(-50195,	'PRT_ERR_Volume_Associated_With_Document', 'Error') 
	INSERT INTO PDBCONSTANT VALUES(-50196,	'PRT_ERR_Cannot_Copy_SubFolder', 'Error') 
	INSERT INTO PDBCONSTANT VALUES(-50197,	'PRT_ERR_Cannot_Move_SubFolder', 'Error') 
	INSERT INTO PDBCONSTANT VALUES(-50198,	'PRT_ERR_Max_Login_User_Count_Reached', 'Error') 
	INSERT INTO PDBCONSTANT VALUES(-50199,	'PRT_ERR_Max_Login_User_Licenses_Reached', 'Error') 
	INSERT INTO PDBCONSTANT VALUES(-50200,	'PRT_ERR_FTS_Error', 'Error') 
	INSERT INTO PDBCONSTANT VALUES(-50201,	'PRT_ERR_Role_Already_Exists', 'Error') 
	INSERT INTO PDBCONSTANT VALUES(-50202,	'PRT_ERR_Role_Not_Exist', 'Error') 
	INSERT INTO PDBCONSTANT VALUES(-50203,	'PRT_ERR_User_Associated_With_Role', 'Error') 
	INSERT INTO PDBCONSTANT VALUES(-50204,	'PRT_ERR_Multi_Users_Associated_With_Role', 'Error') 
	INSERT INTO PDBCONSTANT VALUES(-50205,	'PRT_ERR_No_User_Associated_With_Role', 'Error') 
	INSERT INTO PDBCONSTANT VALUES(-50206,	'PRT_ERR_User_Not_Associated_With_Role', 'Error') 
	INSERT INTO PDBCONSTANT VALUES(-50207,	'PRT_ERR_Cannot_Add_Multi_Users_To_Role', 'Error') 
	INSERT INTO PDBCONSTANT VALUES(-50208,	'PRT_ERR_LoggedInAttempts_Exceded', 'Error') 
	INSERT INTO PDBCONSTANT VALUES(-50209,	'PRT_ERR_User_already_used_this_password', 'Error') 
	INSERT INTO PDBCONSTANT VALUES(-50210,	'PRT_ERR_Password_Cannot_blank', 'Error') 
	INSERT INTO PDBCONSTANT VALUES(-50211,	'PRT_ERR_Password_Length_must_be_Eight', 'Error') 
	INSERT INTO PDBCONSTANT VALUES(-50212,	'PRT_ERR_AtLeast_one_Leeter_one_Digit_required', 'Error') 
	INSERT INTO PDBCONSTANT VALUES(-50213,	'PRT_ERR_No_Repeatation', 'Error')
	INSERT INTO PDBCONSTANT VALUES(-50214,	'PRT_ERR_Passwd_Not_be_User_Family_PersonalName', 'Error')
	INSERT INTO PDBConstant VALUES (-50215,'PRT_ERR_Invalid_Transaction','Error')
	INSERT INTO PDBConstant VALUES (-50216,'PRT_ERR_Document_Not_Signed','Error')
	INSERT INTO PDBCONSTANT VALUES(-50217,	'PRT_ERR_Invalid_ImageVolumeIndex', 'Error')
	INSERT INTO PDBCONSTANT VALUES(-50218,	'PRT_ERR_Invalid_DocumentSize', 'Error')
	INSERT INTO PDBCONSTANT VALUES(-50219,	'PRT_ERR_Invalid_Image_Server_Doc', 'Error')
	INSERT INTO PDBCONSTANT VALUES(-50220,	'PRT_ERR_Supervisor_User_Can_not_be_Deleted', 'Error')
	INSERT INTO PDBCONSTANT VALUES(-50221,	'PRT_ERR_MaxNoOfFixedUsers_Exceeded', 'Error')
	INSERT INTO PDBCONSTANT VALUES(-50222,	'PRT_ERR_First_Time_Login', 'Error')
	INSERT INTO PDBConstant VALUES(-50223, 'PRT_ERR_User_Password_Expired', 'Error')
	INSERT INTO PDBConstant VALUES(-50224, 'PRT_ERR_Passwd_Should_Have_Min_Special_Character', 'Error')
	INSERT INTO PDBConstant VALUES(-50225, 'PRT_ERR_Special_Character_Not_Allowed', 'Error')
	INSERT INTO PDBConstant VALUES(-50226, 'PRT_ERR_Maker_Checker_Are_Same', 'Error')
	INSERT INTO PDBConstant VALUES(-50227, 'PRT_ERR_Reject_Comments_Not_Given', 'Error')
	INSERT INTO PDBConstant VALUES(-50228, 'PRT_ERR_Request_Not_Exists', 'Error')
	INSERT INTO PDBConstant VALUES(-50229, 'PRT_ERR_Req_Not_Found_For_User', 'Error')
	INSERT INTO PDBConstant VALUES(-50230, 'PRT_ERR_Cant_Approve_Own_Request', 'Error')

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBConstant, Converting to Unicode and Reinserting Data', GETDATE(), NULL, 'Already Updated')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBAuditAction'
	AND COLUMN_NAME = 'Comment'
	AND DATA_TYPE = 'nvarchar'
)
BEGIN
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBAuditAction, Converting to Unicode and Reinserting Data', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	IF EXISTS(
		SELECT 1 FROM INFORMATION_SCHEMA.TABLES
		WHERE TABLE_NAME = 'PDBAuditAction')
	BEGIN
		EXECUTE ('DROP TABLE PDBAuditAction')
	END
	CREATE TABLE PDBAuditAction(
		ActionId     int
			CONSTRAINT   pk_aduitactionid      PRIMARY KEY  Clustered,
		Category	char(1),
		ActionName	varchar(1020), 
		EnableLog       char(1), 
		Comment         nvarchar(255) NULL
	)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (101, 'C', 'Log In',	'Y', 'To see all the login operations that has been done for any User ID. Both the successful and unsuccessful attempts are recorded')
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (102, 'C', 'Log Out', 'Y', 'To see all the logout operations done for any user id')
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (103, 'C', 'Change Password Attempts', 'Y', NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (104, 'C', 'User Created', 'Y' , NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (105, 'C', 'User Deleted', 'Y', NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (106, 'C', 'Group Created', 'Y',NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (107, 'C', 'Group Deleted', 'Y', NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (108, 'C', 'User Added To Group', 'Y', NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (109, 'C', 'User Deleted From Group', 'Y', NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (110, 'C', 'DataClass Created', 'Y', NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (111, 'C', 'DataClass Deleted', 'Y', NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (112, 'C', 'Modify Data Class', 'Y', NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (113, 'C', 'Global Index Created', 'Y', NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (114, 'C', 'Global Index Deleted', 'Y', NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (115, 'C', 'Modify Global Index', 'Y', NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (116, 'C', 'Manage Cabinet', 'Y', 'To get the report of folder/cabinet managed')
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (117, 'C', 'Privilege Changed', 'Y', NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (118, 'C', 'Cabinet Properties Changed', 'Y', NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (119, 'C', 'User Properties Modified', 'Y', NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (120, 'C', 'Group Properties Modified', 'Y', NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (121, 'C', 'Error In Retrieveing Image Of Document', 'Y', NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (201, 'F', 'Create Folder1', 'Y', 'To get the report what all folders have been created inside the folder - X')
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (202, 'F', 'Delete Folder', 'Y', 'To get the report of what all folder have been deleted from the folder - X')
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (203, 'F', 'Add Document', 'Y', 'To get the report what all documents have been added to the Folder - X. this will include the case of importing documents and scanning documents')
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (204, 'F', 'Folder Properties Modified', 'Y', 'To get a list of all the instances when the Folder properties were modified of the folder - X')
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (205, 'F', 'Folder Exported', 'Y', 'TO get a report of all the instances when the folder X was Exported')
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (206, 'F', 'Folder Contents Printed', 'Y', 'TO get a report of all the instances when the contents of this folder X were printed.')
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (207, 'F', 'Search Folder', 'Y', 'To get a report when search was performed on this folder')
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (208, 'F', 'Move Folder1', 'Y', 'To get the report of what all folders have been moved out from the folder - X')
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (209, 'F', 'Move Folder2', 'Y', 'To get the report what all folders have been moved into the Folder - X')
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (210, 'F', 'Move Folder3', 'Y', 'To get the report whether the folder X was moved to some other folder in the past???')
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (211, 'F', 'Move Document1', 'Y', 'To get the report what all documents have been moved out of this folder in the past??')
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (212, 'F', 'Move Document2', 'Y', 'To get the report what all documents have been moved into the folder X')
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (213, 'F', 'Copy Folder1', 'Y', 'To get the report what all folders have been copied to the folder - X')
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (214, 'F', 'Copy Folder2', 'Y', 'To get the report at what instances the folder X was copied to what all  folder')
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (215, 'F', 'Copy Document1', 'Y', 'To get a report of all instances when any document is copied to the folder - X')
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (216, 'F', 'Create Folder Reference1', 'Y', 'To get a report of what all folder references have been created inside this folder - X')
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (217, 'F', 'Create Folder Reference2', 'Y', 'At what all instances any reference is created of this folder - X')
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (218, 'F', 'Delete Folder Reference1', 'Y', 'To get a report of what all folder references have been Deleted inside this folder - X')
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (219, 'F', 'Delete Document', 'Y', 'What all documents are deleted from this folder - X')
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (220, 'F', 'Note Added On Folder', 'Y', 'what all notes have been added on this folder - X')
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (221, 'F', 'Search Document', 'Y', 'What all Document search queries have  been performed over this Folder ID')
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (222, 'F', 'Create Document Reference2', 'Y', 'What all document references have been created in this folder.')
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (223, 'F', 'Duplicate Document1', 'Y', 'Toget a report  What all documents have been duplicated into this folder')
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (224, 'F', 'Create Folder2', 'Y', 'To get the report for a particular folder. This tells when this particular folder was created')
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (225, 'F', 'Delete FolderReference2', 'Y', 'At what all instances any reference is deleted of this folder - X')
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (301, 'D', 'Open Document', 'Y', 'TO get a report when the document is opened by whom')
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (302, 'D', 'Document Printed', 'Y', NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (303, 'D', 'Document Annotated', 'Y', NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (304, 'D', 'Document Modified ', 'Y', 'This includes the modification of both properties/data class field values/Global Indexes/Document Name')
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (305, 'D', 'Document Notes Added ', 'Y', NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (306, 'D', 'Document Exported', 'Y', NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (307, 'D', 'Document Version Created', 'Y', NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (308, 'D', 'Document Version Deleted', 'Y', NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (309, 'D', 'Document Set As Latest Version', 'Y', NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (310, 'D', 'Document Linked', 'Y', NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (311, 'D', 'Document Delinked', 'Y', NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (312, 'D', 'Post Document', 'Y', NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (313, 'D', 'Duplicate Document2', 'Y', NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (314, 'D', 'Document Check Out', 'Y', NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (315, 'D', 'Document Check In', 'Y', NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (316, 'D', 'Create Document Reference1', 'Y', 'what all references are created of this document??')
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (317, 'D', 'Move Document', 'Y', 'To get the report when the document X has been moved from one folder to another in the past')
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (318, 'D', 'Copy Document2', 'Y', 'to get a report when the Document X has been copied to some other folderr')
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (319, 'D', 'Document Undo CheckOut', 'Y', NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (320, 'D', 'Modify Document Image', 'Y', 'Modify document -change docPageImage.')
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (321, 'D', 'Create Document', 'Y', 'To get the report for a particular document creation.')
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (322, 'D', 'Document Forwarded', 'Y', 'To get the report for a particular document forwarded.')
/*	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (401, 'A', 'ActionItem Initiated', 'Y', NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (402, 'A', 'ActionItem Forwarded', 'Y', NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (403, 'A', 'ActionItem Returned', 'Y', NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (404, 'A', 'ActionItem Referred', 'Y', NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (405, 'A', 'ActionItem Completed', 'Y', NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (406, 'A', 'ActionItem ReInitiated', 'Y', NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (407, 'A', 'ActionItem Acknowledged', 'Y', NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (408, 'A', 'ActionItem Viewed', 'Y', NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (409, 'A', 'ActionItem Attachment Added', 'Y', NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (410, 'A', 'ActionItem Attachment Viewed', 'Y', NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (411, 'A', 'ActionItem Attachment Deleted', 'Y', NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (412, 'A', 'ActionItem Stage Changed', 'Y', NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (413, 'A', 'ActionItem Route Changed', 'Y', NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (414, 'A', 'ActionItem Secure Note Added ', 'Y', NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (415, 'A', 'ActionItem Response Added', 'Y', NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (416, 'A', 'ActionItem Forwarding Note Added', 'Y', NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (417, 'A', 'ActionItem Saved', 'Y', NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (418, 'A', 'ActionItem PickedUp', 'Y', NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (419, 'A', 'ActionItem UserAdded In The Route', 'Y', NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (420, 'A', 'ActionItem User Deleted In The Route', 'Y', NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (421, 'A', 'ActionItem Dead Line Changed', 'Y', NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (422, 'A', 'ActionItem Request For Increasing Deadline', 'Y', NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (423, 'A', 'ActionItem Save As RTF File', 'Y', NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (424, 'A', 'ActionItem Printed', 'Y', NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (425, 'A', 'ActionItem Closed', 'Y', NULL)*/
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (601, 'C', 'Request to Create User', 'Y' , NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (602, 'C', 'Create User Request Accepted', 'Y' , NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (603, 'C', 'Create User Request Rejected', 'Y' , NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (604, 'C', 'Create User Failed', 'Y' , NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (605, 'C', 'Request to Delete User', 'Y' , NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (606, 'C', 'Delete User Request Accepted', 'Y' , NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (607, 'C', 'Delete User Request Rejected', 'Y' , NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (608, 'C', 'Delete User Failed', 'Y' , NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (609, 'C', 'Request to Modify User Properties', 'Y' , NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (610, 'C', 'Request to Modify User Properties Accepted', 'Y' , NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (611, 'C', 'Request to Modify User Properties Rejected', 'Y' , NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (612, 'C', 'Modify User Properties Failed', 'Y' , NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (613, 'C', 'Request to Create Group', 'Y' , NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (614, 'C', 'Create Group Request Accepted', 'Y' , NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (615, 'C', 'Create Group Request Rejected', 'Y' , NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (616, 'C', 'Create Group Failed', 'Y' , NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (617, 'C', 'Request to Delete Group', 'Y' , NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (618, 'C', 'Delete Group Request Accepted', 'Y' , NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (619, 'C', 'Delete Group Request Rejected', 'Y' , NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (620, 'C', 'Delete Group Failed', 'Y' , NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (621, 'C', 'Request to Modify Group Properties', 'Y' , NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (622, 'C', 'Request to Modify Group Properties Accepted', 'Y' , NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (623, 'C', 'Request to Modify Group Properties Rejected', 'Y' , NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (624, 'C', 'Modify Group Properties Failed', 'Y' , NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (625, 'C', 'Request to Delete User From Group', 'Y' , NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (626, 'C', 'Request to Delete User From Group Accepted', 'Y' , NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (627, 'C', 'Request to Delete User From Group Rejected', 'Y' , NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (628, 'C', 'Delete User From Group Failed', 'Y' , NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (629, 'C', 'Request to Add User To Group', 'Y' , NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (630, 'C', 'Request to Add User To Group Accepted', 'Y' , NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (631, 'C', 'Request to Add User To Group Rejected', 'Y' , NULL)
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (632, 'C', 'Add User To Group Failed', 'Y' , NULL)

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBAuditAction, Converting to Unicode and Reinserting Data', GETDATE(), NULL, 'Already Updated')
END
;
IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBTraceError'
	AND COLUMN_NAME = 'errorvalue'
	AND DATA_TYPE = 'nvarchar'
)
BEGIN
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBTraceError, Converting to Unicode and Reinserting Data', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	IF EXISTS(
		SELECT 1 FROM INFORMATION_SCHEMA.TABLES
		WHERE TABLE_NAME = 'PDBTraceError')
	BEGIN
		EXECUTE ('DROP TABLE PDBTraceError')
	END
	CREATE TABLE PDBTraceError(
		i int,
		errorvalue nvarchar(255)
	)
	INSERT INTO PDBTraceError VALUES(0,'Success')
	INSERT INTO PDBTraceError VALUES(1,'Unknown error.')
	INSERT INTO PDBTraceError VALUES(2,'The trace is currently running. Changing the trace at this time will result in an error.')
	INSERT INTO PDBTraceError VALUES(3,'The specified Event is not valid. The Event may not exist or it is not an appropriate one for the store procedure.')
	INSERT INTO PDBTraceError VALUES(4,'The specified Column is not valid.')
	INSERT INTO PDBTraceError VALUES(5,'The specified Column is not allowed for filtering. This value is returned only from sp_trace_setfilter.')
	INSERT INTO PDBTraceError VALUES(6,'The specified Comparison Operator is not valid.')
	INSERT INTO PDBTraceError VALUES(7,'The specified Logical Operator is not valid.')
	INSERT INTO PDBTraceError VALUES(8,'The specified Status is not valid.')
	INSERT INTO PDBTraceError VALUES(9,'The specified Trace Handle is not valid.')
	INSERT INTO PDBTraceError VALUES(10,'Invalid options. Returned when options specified are incompatible.')
	INSERT INTO PDBTraceError VALUES(11,'The specified Column is used internally and cannot be removed.')
	INSERT INTO PDBTraceError VALUES(12,'File not created.')
	INSERT INTO PDBTraceError VALUES(13,'Out of memory. Returned when there is not enough memory to perform the specified action.')
	INSERT INTO PDBTraceError VALUES(14,'Invalid stop time. Returned when the stop time specified has already happened.')
	INSERT INTO PDBTraceError VALUES(15,'Invalid parameters. Returned when the user supplied incompatible parameters.')
	INSERT INTO PDBTraceError VALUES(16,'The function is not valid for this trace.')
	INSERT INTO PDBTraceError VALUES(18,'The process cannot access the file because it is being used by another process.')

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBTraceError, Converting to Unicode and Reinserting Data', GETDATE(), NULL, 'Already Updated')
END
;
IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'PDBFOLDDOCLOCKSTATUS')
BEGIN
	SET NOCOUNT ON
	declare @stepNo int
	declare @quote char
	select @quote = char(39)
	insert into PDBUpdateStatus values ('CREATE & INSERT ', 'CREATING & INSERTING VALUES IN TABLE PDBFOLDDOCLOCKSTATUS' , getdate(), NULL, 'UPDATING')
	SELECT @StepNo = @@IDENTITY

	CREATE TABLE PDBFoldDocLockStatus(
	FoldDocFlag		char(1),
	FoldDocIndex 		int,
	LockedDateTime		datetime
	)
CREATE NONCLUSTERED INDEX IDX_DOCUMENT_LOCKBYUSER ON PDBDOCUMENT(LOCKBYUSER)
CREATE NONCLUSTERED INDEX IDX_FOLDER_LOCKBYUSER ON PDBFOLDER(LOCKBYUSER)
CREATE NONCLUSTERED INDEX IDX_PDBFoldDocLockStatus_FlgId ON PDBFoldDocLockStatus(FoldDocFlag, FoldDocIndex)
	
	EXEC('INSERT INTO PDBFOLDDOCLOCKSTATUS (FoldDocFlag, FoldDocIndex, LockedDateTime) SELECT ' 
	+ @quote + 'F' + @quote + 
	', A.Folderindex, A.AccessedDatetime FROM PDBFolder A, PDBUser B  WHERE A.FolderLock 	= ' 
	+ @quote + 'Y' + @quote +  
	' And  A.FolderIndex = CONVERT(int, SUBSTRING(A.LockByUser, CHARINDEX(' 
	+ @quote + '#' + @quote + 
	', A.LockByUser) + 1,  CHARINDEX(' 
	+ @quote + ',' + @quote 
	+ ', A.LockByUser) - CHARINDEX(' 
	+ @quote + '#' + @quote + 
	', A.LockByUser) - 1)) AND	B.UserIndex = CONVERT(int, RTRIM(SUBSTRING(A.LockByUser, 1, CHARINDEX(' 
	+ @quote + '#' + @quote + 
	', A.LockByUser) - 1)))')

	EXEC('INSERT INTO PDBFOLDDOCLOCKSTATUS (FoldDocFlag, FoldDocIndex, LockedDateTime) 
		SELECT ' + @quote + 'D' + @quote + ', A.Documentindex, A.AccessedDatetime
		FROM PDBDocument A, PDBUser B 
		WHERE A.DocumentLock = ' + @quote + 'Y'+ @quote + ' 
		and  -1 = CONVERT(int, SUBSTRING(A.LockByUser, CHARINDEX(' + @quote + '#'+ @quote + ', A.LockByUser) + 1,  CHARINDEX(' + @quote + ',' + @quote + ', A.LockByUser) - CHARINDEX(' + @quote + '#' + @quote + ', A.LockByUser) - 1)) 
		AND B.UserIndex = CONVERT(int, RTRIM(SUBSTRING(A.LockByUser, 1, CHARINDEX(' + @quote + '#'+ @quote + ', A.LockByUser) - 1)))')
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN

	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('CREATE & INSERT ', 'CREATING & INSERTING VALUES IN  TABLE PDBFOLDDOCLOCKSTATUS' , getdate(), NULL, 'ALREADY UPDATED')
END
;
IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBAlarm'
	AND COLUMN_NAME = 'ObjectName'
	AND DATA_TYPE = 'NVARCHAR')
BEGIN
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBAlarm, Trimming and Converting to Unicode', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	DECLARE	@TableName		varchar(128)
	DECLARE @ColumnName		nvarchar(128)
	DECLARE @DataType		nvarchar(128)
	DECLARE @PrimaryKey		varchar(128)
	DECLARE @UniqueKey		varchar(128)
	DECLARE @KeyColumnName		varchar(128)
	DECLARE @KeyColumnType		varchar(128)
	DECLARE @TabColumnScript	varchar(8000)
	DECLARE @InsColumnScript	varchar(8000)
	DECLARE @SelColumnScript	varchar(8000)
	DECLARE @IdentityFlag		char(1)

	SELECT	@TableName		= 'PDBAlarm'
	SELECT	@ColumnName		= 'ObjectName'
	SELECT	@DataType		= 'NVARCHAR'
	SELECT	@PrimaryKey		= 'pk_AlarmIndex'
	SELECT	@UniqueKey		= NULL
	SELECT	@KeyColumnName		= 'AlarmIndex'
	SELECT	@KeyColumnType		= 'int'
	SELECT	@TabColumnScript	= '
			AlarmIndex		int IDENTITY (1,1) CONSTRAINT pk_AlarmIndex PRIMARY KEY,
			AlarmType		char(1) Constraint ck_alarm_alarmtype check (AlarmType in (''S'',''U'')),
			ObjectType		char(1) null,
			ObjectId		int null,
			ObjectName		nvarchar(255) NULL,
			UserIndex		int,
			ActionType		smallint,
			AlarmGenerated		char(1) Constraint ck_alarm_alarmgen check (AlarmGenerated in (''Y'',''N'')),
			AlarmDateTime		datetime,
			UserGenerated		nvarchar(64) NULL,
			SetByUser		int,
			DocumentType		char(1) NULL,
			InformMode 		char(1) ,
			Comment			nvarchar(255) NULL
	'
		
	SELECT	@InsColumnScript	= ' AlarmIndex, AlarmType, ObjectType, ObjectId, ObjectName, UserIndex, ActionType, AlarmGenerated, AlarmDateTime, UserGenerated, SetByUser, DocumentType, InformMode, Comment '
	SELECT	@SelColumnScript	= ' AlarmIndex, AlarmType, ObjectType, ObjectId, RTRIM(ObjectName) ObjectName, UserIndex, ActionType, AlarmGenerated, AlarmDateTime, RTRIM(UserGenerated) UserGenerated, SetByUser, DocumentType, InformMode, RTRIM(Comment) Comment '

	SELECT	@IdentityFlag		= 'Y'

	DECLARE @Status			int
	EXEC ConvertTableToUnicode
		@TableName,
		@ColumnName,
		@DataType,
		@PrimaryKey,
		@UniqueKey,
		@KeyColumnName,
		@KeyColumnType,
		@TabColumnScript,
		@InsColumnScript,
		@SelColumnScript,
		@IdentityFlag,
		@StepNo,
		@Status OUT

	IF @Status <> 0
		RETURN

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBAlarm, Trimming and Converting to Unicode', GETDATE(), NULL, 'Already Updated')
END
;
IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBReminder'
	AND COLUMN_NAME = 'DocName'
	AND DATA_TYPE = 'NVARCHAR')
BEGIN
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBReminder, Trimming and Converting to Unicode', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	DECLARE	@TableName		varchar(128)
	DECLARE @ColumnName		nvarchar(128)
	DECLARE @DataType		nvarchar(128)
	DECLARE @PrimaryKey		varchar(128)
	DECLARE @UniqueKey		varchar(128)
	DECLARE @KeyColumnName		varchar(128)
	DECLARE @KeyColumnType		varchar(128)
	DECLARE @TabColumnScript	varchar(8000)
	DECLARE @InsColumnScript	varchar(8000)
	DECLARE @SelColumnScript	varchar(8000)
	DECLARE @IdentityFlag		char(1)

	SELECT	@TableName		= 'PDBReminder'
	SELECT	@ColumnName		= 'DocName'
	SELECT	@DataType		= 'NVARCHAR'
	SELECT	@PrimaryKey		= 'pk_RemIndex'
	SELECT	@UniqueKey		= NULL
	SELECT	@KeyColumnName		= 'RemIndex'
	SELECT	@KeyColumnType		= 'int'
	SELECT	@TabColumnScript	= '
			RemIndex		int IDENTITY (1,1) CONSTRAINT pk_RemIndex PRIMARY KEY,
			UserIndex		int,
			DocIndex		int,
			DocName			nvarchar(255) NULL,
			RemDateTime		DateTime,	
			Comment			nvarchar(255) NULL,
			SetByUser		int,
			InformMode 		char(1),
			ReminderType		char(1) CONSTRAINT df_reminder_remtype DEFAULT ''U'',
			MailFlag		char(1) CONSTRAINT df_reminder_mailflag DEFAULT ''N'',
			FaxFlag			char(1) CONSTRAINT df_reminder_faxflag DEFAULT ''N''
	'
		
	SELECT	@InsColumnScript	= ' RemIndex, UserIndex, DocIndex, DocName, RemDateTime, Comment, SetByUser, InformMode, ReminderType, MailFlag, FaxFlag '
	SELECT	@SelColumnScript	= ' RemIndex, UserIndex, DocIndex, RTRIM(DocName) DocName, RemDateTime, RTRIM(Comment) Comment, SetByUser, InformMode, ReminderType, MailFlag, FaxFlag '

	SELECT	@IdentityFlag		= 'Y'

	DECLARE @Status			int
	EXEC ConvertTableToUnicode
		@TableName,
		@ColumnName,
		@DataType,
		@PrimaryKey,
		@UniqueKey,
		@KeyColumnName,
		@KeyColumnType,
		@TabColumnScript,
		@InsColumnScript,
		@SelColumnScript,
		@IdentityFlag,
		@StepNo,
		@Status OUT

	IF @Status <> 0
		RETURN

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBReminder, Trimming and Converting to Unicode', GETDATE(), NULL, 'Already Updated')
END
;
IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBAnnotation'
	AND COLUMN_NAME = 'AnnotationName'
	AND DATA_TYPE = 'NVARCHAR')
BEGIN
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBAnnotation, Trimming and Converting to Unicode', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	DECLARE	@TableName		varchar(128)
	DECLARE @ColumnName		nvarchar(128)
	DECLARE @DataType		nvarchar(128)
	DECLARE @PrimaryKey		varchar(128)
	DECLARE @UniqueKey		varchar(128)
	DECLARE @KeyColumnName		varchar(128)
	DECLARE @KeyColumnType		varchar(128)
	DECLARE @TabColumnScript	varchar(8000)
	DECLARE @InsColumnScript	varchar(8000)
	DECLARE @SelColumnScript	varchar(8000)
	DECLARE @IdentityFlag		char(1)

	SELECT	@TableName		= 'PDBAnnotation'
	SELECT	@ColumnName		= 'AnnotationName'
	SELECT	@DataType		= 'NVARCHAR'
	SELECT	@PrimaryKey		= 'pk_AnnotationIndex'
	SELECT	@UniqueKey		= 'uk_Annotation'
	SELECT	@KeyColumnName		= 'AnnotationIndex'
	SELECT	@KeyColumnType		= 'int'
	SELECT	@TabColumnScript	= '
			DocumentIndex			int
			CONSTRAINT FK_annotation_docid References  PDBDocument(DocumentIndex),
			PageNumber                     int,
			AnnotationIndex			 int
			IDENTITY(1,1) CONSTRAINT   pk_AnnotationIndex      PRIMARY KEY  Clustered,
			AnnotationName			nvarchar(64),
			AnnotationAccessType		char CONSTRAINT ck_annotation_atype check (AnnotationAccessType IN (''S'',''P'',''I'')),
			ACL                         varchar(255) null,
			Owner					int,
			AnnotationBuffer		ntext null,
			ACLMoreFlag 			char null CONSTRAINT ck_annotation_aclmflag CHECK (ACLMoreFlag IN (''Y'',''N'')),
			AnnotationType			char(4),
			CreationDateTime		datetime,
			RevisedDateTime 		DateTime,
			FinalizedFlag			CHAR CONSTRAINT ck_annotation_fflag check (FinalizedFlag IN (''Y'',''N'')),
			FinalizedDateTime		datetime,
			FinalizedBy			int,
			MainGroupId			smallint CONSTRAINT df_annotation_mgpid DEFAULT 0,
			CONSTRAINT   uk_Annotation      UNIQUE   (DocumentIndex,PageNumber,AnnotationName)
	'
		
	SELECT	@InsColumnScript	= ' DocumentIndex, PageNumber, AnnotationIndex, AnnotationName, AnnotationAccessType, ACL, Owner, AnnotationBuffer, ACLMoreFlag, AnnotationType, CreationDateTime, RevisedDateTime, FinalizedFlag, FinalizedDateTime, FinalizedBy, MainGroupId '
	SELECT	@SelColumnScript	= ' DocumentIndex, PageNumber, AnnotationIndex, RTRIM(AnnotationName) AnnotationName, AnnotationAccessType, RTRIM(ACL) ACL, Owner, AnnotationBuffer, ACLMoreFlag, AnnotationType, CreationDateTime, RevisedDateTime, FinalizedFlag, FinalizedDateTime, FinalizedBy, MainGroupId '

	SELECT	@IdentityFlag		= 'Y'

	DECLARE @Status			int
	EXEC ConvertTableToUnicode
		@TableName,
		@ColumnName,
		@DataType,
		@PrimaryKey,
		@UniqueKey,
		@KeyColumnName,
		@KeyColumnType,
		@TabColumnScript,
		@InsColumnScript,
		@SelColumnScript,
		@IdentityFlag,
		@StepNo,
		@Status OUT

	IF @Status <> 0
		RETURN

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBAnnotation, Trimming and Converting to Unicode', GETDATE(), NULL, 'Already Updated')
END
;
IF EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
		WHERE TABLE_NAME = 'PDBAnnotationObject'
		AND CONSTRAINT_NAME = 'uk_AttachmentName'
)
AND 
NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBAnnotationObject'
	AND COLUMN_NAME = 'Notes'
	AND DATA_TYPE = 'NVARCHAR')
BEGIN
	SET NOCOUNT ON
	
	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBAnnotationObject DROP Unique Key Constraints to Notes column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	ALTER TABLE PDBAnnotationObject DROP CONSTRAINT uk_AttachmentName
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBAnnotationObject DROP Unique Key Constraints to Notes column', GETDATE(), NULL, 'Already Updated')
END
;
IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBAnnotationObject'
	AND COLUMN_NAME = 'Notes'
	AND DATA_TYPE = 'NVARCHAR')
BEGIN
	SET NOCOUNT ON
	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBAnnotationObject, Trimming and Converting to Unicode', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	BEGIN TRANSACTION TranUniUp
	UPDATE PDBAnnotationObject SET Notes = RTRIM(Notes)
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRANSACTION TranUniUp
		RETURN
	END
	ALTER TABLE PDBAnnotationObject ALTER COLUMN Notes NVARCHAR(255) NOT NULL
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRANSACTION TranUniUp
		RETURN
	END
	COMMIT TRANSACTION TranUniUp

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBAnnotationObject, Trimming and Converting to Unicode', GETDATE(), NULL, 'Already Updated')
END
;
IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
		WHERE TABLE_NAME = 'PDBAnnotationObject'
		AND CONSTRAINT_NAME = 'uk_AttachmentName'
)
BEGIN
	SET NOCOUNT ON
	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBAnnotationObject ADD Unique Key Constraints to Notes column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	ALTER TABLE PDBAnnotationObject ADD CONSTRAINT uk_AttachmentName UNIQUE (DocumentIndex,PageNumber,Notes )
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBAnnotationObject ADD Unique Key Constraints to Notes column', GETDATE(), NULL, 'Already Updated')
END
;
IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBAnnotationObjectVersion'
	AND COLUMN_NAME = 'Notes'
	AND DATA_TYPE = 'NVARCHAR')
BEGIN
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBAnnotationObjectVersion, Trimming and Converting to Unicode', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	BEGIN TRANSACTION TranUniUp
	UPDATE PDBAnnotationObjectVersion SET Notes = RTRIM(Notes)
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRANSACTION TranUniUp
		RETURN
	END
	ALTER TABLE PDBAnnotationObjectVersion ALTER COLUMN Notes NVARCHAR(255) NOT NULL
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRANSACTION TranUniUp
		RETURN
	END
	COMMIT TRANSACTION TranUniUp

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBAnnotationObjectVersion, Trimming and Converting to Unicode', GETDATE(), NULL, 'Already Updated')
END
;
IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBApplicationInfo'
	AND COLUMN_NAME = 'CreatedBy'
	AND DATA_TYPE = 'VARCHAR')
BEGIN
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBApplicationInfo, Trimming and Changing CreatedBy column to VARCHAR ', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	BEGIN TRANSACTION TranUniUp
	ALTER TABLE PDBApplicationInfo DROP CONSTRAINT uk_created1
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRANSACTION TranUniUp
		RETURN
	END

	UPDATE PDBApplicationInfo SET CreatedBy = RTRIM(CreatedBy)
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRANSACTION TranUniUp
		RETURN
	END

	ALTER TABLE PDBApplicationInfo ALTER COLUMN CreatedBy varchar(128) NOT NULL
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRANSACTION TranUniUp
		RETURN
	END

	ALTER TABLE PDBApplicationInfo ADD CONSTRAINT uk_created1 UNIQUE NONCLUSTERED (CreatedBy) 
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRANSACTION TranUniUp
		RETURN
	END

	COMMIT TRANSACTION TranUniUp

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBApplicationInfo, Trimming and Changing CreatedBy column to VARCHAR ', GETDATE(), NULL, 'Already Updated')
END
;
IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBDictionary'
	AND COLUMN_NAME = 'Keyword'
	AND DATA_TYPE = 'NVARCHAR')
BEGIN
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDictionary, Trimming and Converting to Unicode', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	DECLARE	@TableName		varchar(128)
	DECLARE @ColumnName		nvarchar(128)
	DECLARE @DataType		nvarchar(128)
	DECLARE @PrimaryKey		varchar(128)
	DECLARE @UniqueKey		varchar(128)
	DECLARE @KeyColumnName		varchar(128)
	DECLARE @KeyColumnType		varchar(128)
	DECLARE @TabColumnScript	varchar(8000)
	DECLARE @InsColumnScript	varchar(8000)
	DECLARE @SelColumnScript	varchar(8000)
	DECLARE @IdentityFlag		char(1)

	SELECT	@TableName		= 'PDBDictionary'
	SELECT	@ColumnName		= 'Keyword'
	SELECT	@DataType		= 'NVARCHAR'
	SELECT	@PrimaryKey		= 'pk_keywordindex'
	SELECT	@UniqueKey		= 'uk_Dictionary'
	SELECT	@KeyColumnName		= 'KeywordIndex'
	SELECT	@KeyColumnType		= 'int'
	SELECT	@TabColumnScript	= '
			KeywordIndex			 int
			IDENTITY(1,1)	CONSTRAINT   pk_keywordindex      PRIMARY KEY  Clustered,
			GroupIndex			 smallint ,
			Keyword	 			NVarChar(255),
			AuthorizationFlag		Char Constraint ck_dict_authflag CHECK (AuthorizationFlag IN (''A'',''U'')),
				CONSTRAINT uk_Dictionary UNIQUE (GroupIndex,Keyword)
	'
		
	SELECT	@InsColumnScript	= ' KeywordIndex, GroupIndex, Keyword, AuthorizationFlag '
	SELECT	@SelColumnScript	= ' KeywordIndex, GroupIndex, RTRIM(Keyword) Keyword, AuthorizationFlag '

	SELECT	@IdentityFlag		= 'Y'

	DECLARE @Status			int
	EXEC ConvertTableToUnicode
		@TableName,
		@ColumnName,
		@DataType,
		@PrimaryKey,
		@UniqueKey,
		@KeyColumnName,
		@KeyColumnType,
		@TabColumnScript,
		@InsColumnScript,
		@SelColumnScript,
		@IdentityFlag,
		@StepNo,
		@Status OUT

	IF @Status <> 0
		RETURN

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDictionary, Trimming and Converting to Unicode', GETDATE(), NULL, 'Already Updated')
END
;
IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBConnection'
	AND COLUMN_NAME = 'HostName'
	AND DATA_TYPE = 'NVARCHAR')
BEGIN
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBConnection, Trimming and Converting to Unicode, and Removing all existing connections', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	BEGIN TRANSACTION TranUniUp
		
	DROP TABLE PDBConnection	
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRANSACTION TranUniUp
		RETURN
	END

	CREATE TABLE PDBConnection
	(
		RandomNumber	int CONSTRAINT pk_RandomNumber PRIMARY KEY,
		UserIndex	int ,
		HostName	nvarchar(30),
		UserLoginTime	datetime,
		MainGroupId	smallint,
		UserType	char(1)  Constraint ck_connection_utype CHECK ( UserType IN ('S','U')),
		AccessDateTime  datetime,
		StatusFlag	char(1),
		Locale		char(5) NULL,
		ApplicationName	nvarchar(32) NULL,
		ApplicationInfo varchar(20) NULL
	)
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRANSACTION TranUniUp
		RETURN
	END
	COMMIT TRANSACTION TranUniUp

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBConnection, Trimming and Converting to Unicode, and Removing all existing connections', GETDATE(), NULL, 'Already Updated')
END
;
IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBDataDefinition'
	AND COLUMN_NAME = 'DataDefName'
	AND DATA_TYPE = 'NVARCHAR')
BEGIN
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDataDefinition, Trimming and Converting to Unicode', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	DECLARE	@TableName		varchar(128)
	DECLARE @ColumnName		nvarchar(128)
	DECLARE @DataType		nvarchar(128)
	DECLARE @PrimaryKey		varchar(128)
	DECLARE @UniqueKey		varchar(128)
	DECLARE @KeyColumnName		varchar(128)
	DECLARE @KeyColumnType		varchar(128)
	DECLARE @TabColumnScript	varchar(8000)
	DECLARE @InsColumnScript	varchar(8000)
	DECLARE @SelColumnScript	varchar(8000)
	DECLARE @IdentityFlag		char(1)

	SELECT	@TableName		= 'PDBDataDefinition'
	SELECT	@ColumnName		= 'DataDefName'
	SELECT	@DataType		= 'NVARCHAR'
	SELECT	@PrimaryKey		= 'pk_datadefindex'
	SELECT	@UniqueKey		= 'uk_dtatadefname'
	SELECT	@KeyColumnName		= 'DataDefIndex'
	SELECT	@KeyColumnType		= 'int'
	SELECT	@TabColumnScript	= '
			DataDefIndex		int
			IDENTITY(1,1) 	CONSTRAINT   	pk_datadefindex      PRIMARY KEY  Clustered,
			DataDefName			nvarchar(64),
			DataDefComment		nvarchar(255) NULL,
			ACL                   varchar(255) NULL,
			EnableLogflag		char(1),
			ACLMoreFlag 		char(1) NULL CONSTRAINT ck_ddt_aclmflag CHECK (ACLMoreFlag IN (''Y'',''N'')),
			Type				char(5) NULL,
			GroupId			int NULL,
			Unused			nvarchar(255) NULL,
			FDFlag 			char(1) NULL,
			AccessType		char(1) NULL,
			CONSTRAINT   uk_dtatadefname	UNIQUE (DataDefName,GroupId)
	'
		
	SELECT	@InsColumnScript	= ' DataDefIndex, DataDefName, DataDefComment, ACL, EnableLogflag, ACLMoreFlag, Type, GroupId, Unused, FDFlag, AccessType '
	SELECT	@SelColumnScript	= ' DataDefIndex, RTRIM(DataDefName) DataDefName, RTRIM(DataDefComment) DataDefComment, RTRIM(ACL) ACL, EnableLogflag, ACLMoreFlag, RTRIM(Type) Type, GroupId, RTRIM(Unused) Unused, FDFlag, AccessType '

	SELECT	@IdentityFlag		= 'Y'

	DECLARE @Status			int
	EXEC ConvertTableToUnicode
		@TableName,
		@ColumnName,
		@DataType,
		@PrimaryKey,
		@UniqueKey,
		@KeyColumnName,
		@KeyColumnType,
		@TabColumnScript,
		@InsColumnScript,
		@SelColumnScript,
		@IdentityFlag,
		@StepNo,
		@Status OUT

	IF @Status <> 0
		RETURN

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDataDefinition, Trimming and Converting to Unicode', GETDATE(), NULL, 'Already Updated')
END
;
IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBDocumentVersion'
	AND COLUMN_NAME = 'Name'
	AND DATA_TYPE = 'NVARCHAR')
BEGIN
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDocumentVersion, Trimming and Converting to Unicode', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	DECLARE	@TableName		varchar(128)
	DECLARE @ColumnName		nvarchar(128)
	DECLARE @DataType		nvarchar(128)
	DECLARE @PrimaryKey		varchar(128)
	DECLARE @UniqueKey		varchar(128)
	DECLARE @KeyColumnName		varchar(128)
	DECLARE @KeyColumnType		varchar(128)
	DECLARE @TabColumnScript	varchar(8000)
	DECLARE @InsColumnScript	varchar(8000)
	DECLARE @SelColumnScript	varchar(8000)
	DECLARE @IdentityFlag		char(1)

	SELECT	@TableName		= 'PDBDocumentVersion'
	SELECT	@ColumnName		= 'Name'
	SELECT	@DataType		= 'NVARCHAR'
	SELECT	@PrimaryKey		= 'pk_DocumentVersion'
	SELECT	@UniqueKey		= NULL
	SELECT	@KeyColumnName		= 'DocumentIndex'
	SELECT	@KeyColumnType		= 'int'
	SELECT	@TabColumnScript	= '
		      DocumentIndex         	int
		CONSTRAINT fk_docver_docind references  PDBDocument (DocumentIndex) ,
		      ParentFolderIndex     	int,
		      VersionNumber         	decimal(7,1),
		      VersionComment        	nvarchar(255) NULL,
		      CreatedDateTime		datetime Constraint df_docver_createdDT default getdate(),
		      Name                  	nvarchar(255),
		      Owner                 	int,
		      CreatedByUserIndex    	int,
		      ImageIndex            	int,
		      VolumeIndex		int,
		      NoOfPages             	int,
		      LockFlag			char(1),
		      LockByUser		int,
		      AppName			char(4),
		      DocumentSize		int,
		      FTSFlag			char(2),
		      PullPrintFlag		char(1),	
		      DocumentType		char(5),
		      LockMessage		nvarchar(255) NULL		
		      CONSTRAINT pk_DocumentVersion PRIMARY KEY (DocumentIndex,VersionNumber)
	'
		
	SELECT	@InsColumnScript	= ' DocumentIndex, ParentFolderIndex, VersionNumber, VersionComment, CreatedDateTime, Name, Owner, CreatedByUserIndex, ImageIndex, VolumeIndex, NoOfPages, LockFlag, LockByUser, AppName, DocumentSize, FTSFlag, PullPrintFlag, DocumentType, LockMessage'
	SELECT	@SelColumnScript	= ' DocumentIndex, ParentFolderIndex, VersionNumber, RTRIM(VersionComment) VersionComment, CreatedDateTime, RTRIM(Name) Name, Owner, CreatedByUserIndex, ImageIndex, VolumeIndex, NoOfPages, LockFlag, LockByUser, AppName, DocumentSize, FTSFlag, PullPrintFlag, DocumentType, RTRIM(LockMessage) LockMessage '
	SELECT	@IdentityFlag		= 'N'
	DECLARE @Status			int
	EXEC ConvertTableToUnicode
		@TableName,
		@ColumnName,
		@DataType,
		@PrimaryKey,
		@UniqueKey,
		@KeyColumnName,
		@KeyColumnType,
		@TabColumnScript,
		@InsColumnScript,
		@SelColumnScript,
		@IdentityFlag,
		@StepNo,
		@Status OUT

	IF @Status <> 0
		RETURN

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDocumentVersion, Trimming and Converting to Unicode', GETDATE(), NULL, 'Already Updated')
END
;
IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBForm'
	AND COLUMN_NAME = 'FormName'
	AND DATA_TYPE = 'NVARCHAR')
BEGIN
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBForm, Trimming and Converting to Unicode', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	DECLARE	@TableName		varchar(128)
	DECLARE @ColumnName		nvarchar(128)
	DECLARE @DataType		nvarchar(128)
	DECLARE @PrimaryKey		varchar(128)
	DECLARE @UniqueKey		varchar(128)
	DECLARE @KeyColumnName		varchar(128)
	DECLARE @KeyColumnType		varchar(128)
	DECLARE @TabColumnScript	varchar(8000)
	DECLARE @InsColumnScript	varchar(8000)
	DECLARE @SelColumnScript	varchar(8000)
	DECLARE @IdentityFlag		char(1)

	SELECT	@TableName		= 'PDBForm'
	SELECT	@ColumnName		= 'FormName'
	SELECT	@DataType		= 'NVARCHAR'
	SELECT	@PrimaryKey		= 'pk_foindex'
	SELECT	@UniqueKey		= NULL
	SELECT	@KeyColumnName		= 'FormIndex'
	SELECT	@KeyColumnType		= 'int'
	SELECT	@TabColumnScript	= '
			FormIndex			int IDENTITY(1,1)
			 CONSTRAINT   pk_foindex    PRIMARY KEY  Clustered,
			FormName			NVARCHAR(255),
			FormType			CHAR,
			Owner				int,
			CreatedDatetime			datetime,
			RevisedDateTime			datetime,
			AccessedDateTime		datetime,
			DataDefinitionIndex		int Constraint fk_form_ddind references  PDBDataDefinition(DataDefIndex),
			Comment				NVARCHAR(255) NULL,
			FormBuffer			image,
			MainGroupId			smallint,
			FormLock			char(1),
			LockByUser			int,
			LockMessage			nvarchar(255) NULL
	'

	SELECT	@InsColumnScript	= ' FormIndex, FormName, FormType, Owner, CreatedDatetime, RevisedDateTime, AccessedDateTime, DataDefinitionIndex, Comment, FormBuffer, MainGroupId, FormLock, LockByUser, LockMessage '
	SELECT	@SelColumnScript	= ' FormIndex, RTRIM(FormName) FormName, FormType, Owner, CreatedDatetime, RevisedDateTime, AccessedDateTime, DataDefinitionIndex, RTRIM(Comment) Comment, FormBuffer, MainGroupId, FormLock, LockByUser, RTRIM(LockMessage) LockMessage '
	SELECT	@IdentityFlag		= 'Y'
	DECLARE @Status			int
	EXEC ConvertTableToUnicode
		@TableName,
		@ColumnName,
		@DataType,
		@PrimaryKey,
		@UniqueKey,
		@KeyColumnName,
		@KeyColumnType,
		@TabColumnScript,
		@InsColumnScript,
		@SelColumnScript,
		@IdentityFlag,
		@StepNo,
		@Status OUT

	IF @Status <> 0
		RETURN
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBForm, Trimming and Converting to Unicode', GETDATE(), NULL, 'Already Updated')
END
;
IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBFTSData'
	AND COLUMN_NAME = 'DataCoordinate')
BEGIN
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBFTSData, Adding new column - DataCoordinate Image NULL ', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	ALTER TABLE PDBFTSData ADD DataCoordinate Image NULL

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBFTSData, Adding new column - DataCoordinate Image NULL ', GETDATE(), NULL, 'Already Updated')
END
;
IF DatabaseProperty(db_name(), 'IsFulltextEnabled') = 0
BEGIN
	exec sp_fulltext_database 'enable'
END

IF EXISTS (SELECT * FROM SysFulltextCatalogs WHERE Name = 'FtsCatalog')
BEGIN
	exec sp_fulltext_catalog 'FtsCatalog', 'Rebuild'
END

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBFTSData'
	AND COLUMN_NAME = 'Data'
	AND DATA_TYPE = 'ntext')
BEGIN
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBFTSData, Converting to Unicode', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	declare @dropped int
	SELECT @dropped = 0

	IF ObjectProperty(object_id('PDBFTSData'), 'TableFulltextCatalogId') <> 0
	BEGIN
		exec sp_fulltext_table 'PDBFTSData', 'drop'
		SELECT @dropped = 1
	END

	EXEC('ALTER TABLE PDBFTSData ADD temp_col ntext')
	EXEC('UPDATE PDBFTSData SET temp_col = Data')
	EXEC('ALTER TABLE PDBFTSData DROP COLUMN Data')	
	EXEC sp_rename 'PDBFTSData.temp_col', Data, 'COLUMN'
	
	IF @dropped = 1
	BEGIN
		exec sp_fulltext_table 'PDBFTSData', 'create', 'FtsCatalog', 'pk_FTSIndex'
	END	
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBFTSData, Converting to Unicode', GETDATE(), NULL, 'Already Updated')
END
;
IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBFTSDataVersion'
	AND COLUMN_NAME = 'DataCoordinate')
BEGIN
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBFTSDataVersion, Adding new column - DataCoordinate Image NULL ', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	ALTER TABLE PDBFTSDataVersion ADD DataCoordinate Image NULL
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBFTSDataVersion, Adding new column - DataCoordinate Image NULL ', GETDATE(), NULL, 'Already Updated')
END
;
IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBFTSDataVersion'
	AND COLUMN_NAME = 'Data'
	AND DATA_TYPE = 'ntext')
BEGIN
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBFTSData, Converting to Unicode', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	SET NOCOUNT ON
	declare @dropped int
	SELECT @dropped = 0
	IF ObjectProperty(object_id('PDBFTSDataVersion'), 'TableFulltextCatalogId') <> 0
	BEGIN
		exec sp_fulltext_table 'PDBFTSDataVersion', 'drop'
		SELECT @dropped = 1
	END

	EXEC('ALTER TABLE PDBFTSDataVersion ADD temp_col ntext')
	EXEC('UPDATE PDBFTSDataVersion SET temp_col = Data')
	EXEC('ALTER TABLE PDBFTSDataVersion DROP COLUMN Data')
	EXEC sp_rename 'PDBFTSDataVersion.temp_col', Data, 'COLUMN'
	IF @dropped = 1
	BEGIN
		exec sp_fulltext_table 'PDBFTSDataVersion', 'create', 'FtsCatalog', 'pk_FTSVersionIndex'
	END	
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBFTSData, Converting to Unicode', GETDATE(), NULL, 'Already Updated')
END
;
IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBGlobalIndex'
	AND COLUMN_NAME = 'DataFieldName'
	AND DATA_TYPE = 'NVARCHAR')
BEGIN
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGlobalIndex, Trimming and Converting to Unicode', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	DECLARE	@TableName		varchar(128)
	DECLARE @ColumnName		nvarchar(128)
	DECLARE @DataType		nvarchar(128)
	DECLARE @PrimaryKey		varchar(128)
	DECLARE @UniqueKey		varchar(128)
	DECLARE @KeyColumnName		varchar(128)
	DECLARE @KeyColumnType		varchar(128)
	DECLARE @TabColumnScript	varchar(8000)
	DECLARE @InsColumnScript	varchar(8000)
	DECLARE @SelColumnScript	varchar(8000)
	DECLARE @IdentityFlag		char(1)

	SELECT	@TableName		= 'PDBGlobalIndex'
	SELECT	@ColumnName		= 'DataFieldName'
	SELECT	@DataType		= 'NVARCHAR'
	SELECT	@PrimaryKey		= 'pk_dfieldindex'
	SELECT	@UniqueKey		= NULL
	SELECT	@KeyColumnName		= 'DataFieldIndex'
	SELECT	@KeyColumnType		= 'int'
	-------------------------------------------------------------------------------
-- Changed by:           Shubham Mittal
-- Change Description:   Removed CONSTRAINT ck_globalind_gOrDflag CHECK (GlobalOrDataFlag IN (''G'',''D'', ''S'', ''H'')),
-- Change Reason:        OD7 to OD9.1 Upgrade issue -There is already an object named 'ck_globalind_gOrDflag' in the database.  
-------------------------------------------------------------------------------
	
	SELECT	@TabColumnScript	= '
			DataFieldIndex			int
			IDENTITY(1,1)   CONSTRAINT   pk_dfieldindex      PRIMARY KEY  Clustered,
			DataFieldName                   NVarChar(64),
			DataFieldType			Char(1) CONSTRAINT ck_globalind_dftype CHECK (DataFieldType IN (''I'',''L'',''D'',''F'',''S'',''B'',''X'',''T'')),
			DataFieldLength			int,
			GlobalOrDataFlag		Char(1),
			MainGroupId			smallint CONSTRAINT df_globalind_mgpid default 0 not null
	'

	SELECT	@InsColumnScript	= ' DataFieldIndex, DataFieldName, DataFieldType, DataFieldLength, GlobalOrDataFlag, MainGroupId '
	SELECT	@SelColumnScript	= ' DataFieldIndex, RTRIM(DataFieldName) DataFieldName, DataFieldType, DataFieldLength, GlobalOrDataFlag, MainGroupId '
	SELECT	@IdentityFlag		= 'Y'
	DECLARE @Status			int
	EXEC ConvertTableToUnicode
		@TableName,
		@ColumnName,
		@DataType,
		@PrimaryKey,
		@UniqueKey,
		@KeyColumnName,
		@KeyColumnType,
		@TabColumnScript,
		@InsColumnScript,
		@SelColumnScript,
		@IdentityFlag,
		@StepNo,
		@Status OUT

	IF @Status <> 0
		RETURN

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGlobalIndex, Trimming and Converting to Unicode', GETDATE(), NULL, 'Already Updated')
END
;
IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBGroup'
	AND COLUMN_NAME = 'GroupName'
	AND DATA_TYPE = 'NVARCHAR'
)
BEGIN
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGroup, Trimming and Converting to Unicode', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	DECLARE	@TableName		varchar(128)
	DECLARE @ColumnName		nvarchar(128)
	DECLARE @DataType		nvarchar(128)
	DECLARE @PrimaryKey		varchar(128)
	DECLARE @UniqueKey		varchar(128)
	DECLARE @KeyColumnName		varchar(128)
	DECLARE @KeyColumnType		varchar(128)
	DECLARE @TabColumnScript	varchar(8000)
	DECLARE @InsColumnScript	varchar(8000)
	DECLARE @SelColumnScript	varchar(8000)
	DECLARE @IdentityFlag		char(1)

	DECLARE	@ParGrpIndColExists	char(1)

	SELECT	@TableName		= 'PDBGroup'
	SELECT	@ColumnName		= 'GroupName'
	SELECT	@DataType		= 'NVARCHAR'
	SELECT	@PrimaryKey		= 'pk_groupind'
	SELECT	@UniqueKey		= 'uk_GroupTable'
	SELECT	@KeyColumnName		= 'GroupIndex'
	SELECT	@KeyColumnType		= 'smallint'
	SELECT	@TabColumnScript	= '
			GroupIndex			smallint
			IDENTITY(1,1) CONSTRAINT   pk_groupind      PRIMARY KEY  Clustered,
			MainGroupIndex			smallint,
			GroupName			nvarchar(65)
			CONSTRAINT   uk_GroupTable      UNIQUE (MainGroupIndex, GroupName),
			CreatedDateTime		         DateTime,
			ExpiryDateTime		         DateTime,
			PrivilegeControlList	         varchar(16) null,
			Owner			          int,
			Comment		          	  nvarchar(255) NULL,
			GroupType			char(1) CONSTRAINT df_gp_gptype default ''G'',
			ParentGroupIndex	smallint
	'

	IF EXISTS(
		SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'PDBGroup'
		AND COLUMN_NAME = 'ParentGroupIndex'
	)
		SELECT @ParGrpIndColExists = 'Y'
	ELSE
		SELECT @ParGrpIndColExists = 'N'

	SELECT @InsColumnScript = ' GroupIndex, MainGroupIndex, GroupName, CreatedDateTime, ExpiryDateTime, PrivilegeControlList, Owner, Comment, GroupType, ParentGroupIndex '
	
	IF @ParGrpIndColExists = 'Y'
	BEGIN
		SELECT @SelColumnScript = ' GroupIndex, MainGroupIndex, RTRIM(GroupName) GroupName, CreatedDateTime, ExpiryDateTime, RTRIM(PrivilegeControlList) PrivilegeControlList, Owner, RTRIM(Comment) Comment, GroupType, ParentGroupIndex '
	END
	ELSE
	BEGIN
		SELECT @SelColumnScript = ' GroupIndex, 0, RTRIM(GroupName) GroupName, CreatedDateTime, ExpiryDateTime, RTRIM(PrivilegeControlList) PrivilegeControlList, Owner, RTRIM(Comment) Comment, GroupType, MainGroupIndex '
	END
	SELECT	@IdentityFlag		= 'Y'
	DECLARE @Status			int
	EXEC ConvertTableToUnicode
		@TableName,
		@ColumnName,
		@DataType,
		@PrimaryKey,
		@UniqueKey,
		@KeyColumnName,
		@KeyColumnType,
		@TabColumnScript,
		@InsColumnScript,
		@SelColumnScript,
		@IdentityFlag,
		@StepNo,
		@Status OUT

	IF @Status <> 0
		RETURN

	EXECUTE ('UPDATE PDBGroup SET ParentGroupIndex = 0 WHERE GroupIndex IN (1, 2, 3)')

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGroup, Trimming and Converting to Unicode', GETDATE(), NULL, 'Already Updated')
END
;
IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'PDBRoles')
BEGIN
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Creating New Table', 'Creating Table PDBRoles', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	CREATE TABLE PDBRoles (
		RoleIndex int IDENTITY (1, 1) CONSTRAINT   pk_RoleId PRIMARY KEY  Clustered,
		RoleName nvarchar (255)  CONSTRAINT uk_RoleName UNIQUE   NONCLUSTERED,
		Description nvarchar (1000),
		ManyUserFlag char (1)
	) 

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Creating New Table', 'Creating Table PDBRoles', GETDATE(), NULL, 'Already Updated')
END
;
IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBRoles'
	AND COLUMN_NAME = 'RoleName'
	AND DATA_TYPE = 'NVARCHAR'
)
BEGIN
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBRoles, Trimming and Converting to Unicode', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	DECLARE	@TableName		varchar(128)
	DECLARE @ColumnName		nvarchar(128)
	DECLARE @DataType		nvarchar(128)
	DECLARE @PrimaryKey		varchar(128)
	DECLARE @UniqueKey		varchar(128)
	DECLARE @KeyColumnName		varchar(128)
	DECLARE @KeyColumnType		varchar(128)
	DECLARE @TabColumnScript	varchar(8000)
	DECLARE @InsColumnScript	varchar(8000)
	DECLARE @SelColumnScript	varchar(8000)
	DECLARE @IdentityFlag		char(1)

	SELECT	@TableName		= 'PDBRoles'
	SELECT	@ColumnName		= 'RoleName'
	SELECT	@DataType		= 'NVARCHAR'
	SELECT	@PrimaryKey		= 'pk_RoleId'
	SELECT	@UniqueKey		= 'uk_RoleName'
	SELECT	@KeyColumnName		= 'RoleIndex'
	SELECT	@KeyColumnType		= 'int'
	SELECT	@TabColumnScript	= '
		RoleIndex int IDENTITY (1, 1) CONSTRAINT   pk_RoleId PRIMARY KEY  Clustered,
		RoleName nvarchar (255)  CONSTRAINT uk_RoleName UNIQUE   NONCLUSTERED,
		Description nvarchar (1000),
		ManyUserFlag char (1)
	'
		
	SELECT	@InsColumnScript	= ' RoleIndex, RoleName, Description, ManyUserFlag'
	SELECT	@SelColumnScript	= ' RoleIndex, RTRIM(RoleName) RoleName, RTRIM(Description) Description, ManyUserFlag '

	SELECT	@IdentityFlag		= 'Y'

	DECLARE @Status			int
	EXEC ConvertTableToUnicode
		@TableName,
		@ColumnName,
		@DataType,
		@PrimaryKey,
		@UniqueKey,
		@KeyColumnName,
		@KeyColumnType,
		@TabColumnScript,
		@InsColumnScript,
		@SelColumnScript,
		@IdentityFlag,
		@StepNo,
		@Status OUT

	IF @Status <> 0
		RETURN

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBRoles, Trimming and Converting to Unicode', GETDATE(), NULL, 'Already Updated')
END
;
IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'PDBGroupRoles')
BEGIN
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Creating New Table', 'Creating Table PDBGroupRoles', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	CREATE TABLE PDBGroupRoles (
		GroupRoleIndex int IDENTITY(1,1) CONSTRAINT   pk_GroupRoleId PRIMARY KEY  Clustered,
		RoleIndex int CONSTRAINT fk_gproles_Roleind references  PDBRoles (RoleIndex),
		GroupIndex smallint CONSTRAINT fk_gproles_gpind references  PDBGroup (GroupIndex),
		UserIndex int CONSTRAINT fk_gproles_uind references  PDBUser (UserIndex)
	) 

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Creating New Table', 'Creating Table PDBGroupRoles', GETDATE(), NULL, 'Already Updated')
END
;
IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBLinkNotesTable'
	AND COLUMN_NAME = 'NoteNo'
	AND DATA_TYPE = 'VARCHAR'
	AND Character_maximum_length = 200
)
BEGIN 
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBLinkNotesTable, Converting NoteNo to varchar(200)', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	ALTER TABLE PDBLinkNotesTable ALTER COLUMN NoteNo VARCHAR(200) NULL

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBLinkNotesTable, Converting NoteNo to varchar(200)', GETDATE(), NULL, 'Already Updated')
END
;
BEGIN
	SET NOCOUNT ON
	CREATE TABLE #IndLongGlob(index_name varchar(256), indexdesc varchar(256), indkey varchar(2126))
	INSERT INTO #IndLongGlob exec sp_helpindex 'PDBLongGlobalIndex'
	IF EXISTS(SELECT 1 FROM #IndLongGlob WHERE INDEX_NAME = 'pk_datafielddocument1' AND CHARINDEX('DataFieldindex', INDKEY) = 1)
	BEGIN
		SET NOCOUNT ON

		DECLARE @StepNo			int
		INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBLongGlobalIndex, Converting Primary Key columns to DocumentIndex, DataFieldindex, LongValue', GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		ALTER TABLE PDBLongGlobalIndex DROP CONSTRAINT pk_datafielddocument1
		ALTER TABLE PDBLongGlobalIndex ADD CONSTRAINT pk_datafielddocument1 PRIMARY KEY (DocumentIndex, DataFieldindex, LongValue)
		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		SET NOCOUNT ON
		INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBLongGlobalIndex, Converting Primary Key columns to DocumentIndex, DataFieldindex, LongValue', GETDATE(), NULL, 'Already Updated')
	END
	DROP TABLE #IndLongGlob
END
;
IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBPersonalRoutes'
	AND COLUMN_NAME = 'RouteName'
	AND DATA_TYPE = 'NVARCHAR'
)
BEGIN
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBPersonalRoutes, Trimming and Converting to Unicode', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	DECLARE	@TableName		varchar(128)
	DECLARE @ColumnName		nvarchar(128)
	DECLARE @DataType		nvarchar(128)
	DECLARE @PrimaryKey		varchar(128)
	DECLARE @UniqueKey		varchar(128)
	DECLARE @KeyColumnName		varchar(128)
	DECLARE @KeyColumnType		varchar(128)
	DECLARE @TabColumnScript	varchar(8000)
	DECLARE @InsColumnScript	varchar(8000)
	DECLARE @SelColumnScript	varchar(8000)
	DECLARE @IdentityFlag		char(1)

	SELECT	@TableName		= 'PDBPersonalRoutes'
	SELECT	@ColumnName		= 'RouteName'
	SELECT	@DataType		= 'NVARCHAR'
	SELECT	@PrimaryKey		= 'pk_Routes'
	SELECT	@UniqueKey		=  NULL
	SELECT	@KeyColumnName		= 'UserIndex'
	SELECT	@KeyColumnType		= 'int'
	SELECT	@TabColumnScript	= '
		UserIndex	int,
		RouteName	nvarchar(255),
		RouteInfo	ntext
		CONSTRAINT   	pk_Routes  PRIMARY KEY (UserIndex, RouteName)
	'
		
	SELECT	@InsColumnScript	= ' UserIndex, RouteName, RouteInfo '
	SELECT	@SelColumnScript	= ' UserIndex, RTRIM(RouteName), RouteInfo '

	SELECT	@IdentityFlag		= 'N'

	DECLARE @Status			int
	EXEC ConvertTableToUnicode
		@TableName,
		@ColumnName,
		@DataType,
		@PrimaryKey,
		@UniqueKey,
		@KeyColumnName,
		@KeyColumnType,
		@TabColumnScript,
		@InsColumnScript,
		@SelColumnScript,
		@IdentityFlag,
		@StepNo,
		@Status OUT

	IF @Status <> 0
		RETURN

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBPersonalRoutes, Trimming and Converting to Unicode', GETDATE(), NULL, 'Already Updated')
END
;
IF NOT EXISTS(
	SELECT 1
	FROM INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE A, INFORMATION_SCHEMA.CHECK_CONSTRAINTS B 
	WHERE TABLE_NAME = 'PDBRIGHTS'
	AND A.CONSTRAINT_NAME = B.CONSTRAINT_NAME
	AND	A.COLUMN_NAME = 'FLAG2'
	AND CHARINDEX('''V''', CHECK_CLAUSE) > 0
)
BEGIN

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBRIGHTS, Changing check constraint to support ''V'' character', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	DECLARE @Constraint_Name nvarchar(128)
	DECLARE @QueryStr varchar(2000)
	BEGIN TRANSACTION TranUniUp
	SELECT	@Constraint_Name = A.CONSTRAINT_NAME
	FROM INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE A, INFORMATION_SCHEMA.CHECK_CONSTRAINTS B 
	WHERE TABLE_NAME = 'PDBRIGHTS'
	AND A.CONSTRAINT_NAME = B.CONSTRAINT_NAME
	AND	A.COLUMN_NAME = 'FLAG2'
	IF @@ROWCOUNT > 0
	BEGIN
		SELECT @QueryStr = ' ALTER TABLE PDBRights DROP CONSTRAINT ' + @Constraint_Name
		EXECUTE (@QueryStr)
		IF @@ERROR <> 0
		BEGIN
			ROLLBACK TRANSACTION TranUniUp
			RETURN
		END
		SELECT @QueryStr = ' ALTER TABLE PDBRights ADD CONSTRAINT ' + @Constraint_Name + ' CHECK (Flag2 IN (''F'',''C'',''D'',''A'',''T'',''N'',''V''))'
		EXECUTE (@QueryStr)
		IF @@ERROR <> 0
		BEGIN
			ROLLBACK TRANSACTION TranUniUp
			RETURN
		END
	END
	ELSE
	BEGIN
		SELECT @QueryStr = ' ALTER TABLE PDBRights ADD CONSTRAINT PDBRIGHTS_FLAG2_CHECK CHECK (Flag2 IN (''F'',''C'',''D'',''A'',''T'',''N'',''V''))'
		EXECUTE (@QueryStr)
		IF @@ERROR <> 0
		BEGIN
			ROLLBACK TRANSACTION TranUniUp
			RETURN
		END
	END
	COMMIT TRANSACTION TranUniUp	

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBRIGHTS, Changing check constraint to support ''V'' character', GETDATE(), NULL, 'Already Updated')
END
;
IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBService'
	AND COLUMN_NAME = 'HostName'
	AND DATA_TYPE = 'NVARCHAR')
BEGIN
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBService, Trimming and Converting to Unicode', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	DECLARE	@TableName		varchar(128)
	DECLARE @ColumnName		nvarchar(128)
	DECLARE @DataType		nvarchar(128)
	DECLARE @PrimaryKey		varchar(128)
	DECLARE @UniqueKey		varchar(128)
	DECLARE @KeyColumnName		varchar(128)
	DECLARE @KeyColumnType		varchar(128)
	DECLARE @TabColumnScript	varchar(8000)
	DECLARE @InsColumnScript	varchar(8000)
	DECLARE @SelColumnScript	varchar(8000)
	DECLARE @IdentityFlag		char(1)

	SELECT	@TableName		= 'PDBService'
	SELECT	@ColumnName		= 'HostName'
	SELECT	@DataType		= 'NVARCHAR'
	SELECT	@PrimaryKey		= 'pk_Service'
	SELECT	@UniqueKey		=  'uk_Service'
	SELECT	@KeyColumnName		= 'ServiceIndex'
	SELECT	@KeyColumnType		= 'smallint'
	SELECT	@TabColumnScript	= '
			ServiceIndex	smallint,
			ServiceType		VarChar(128) CONSTRAINT uk_Service UNIQUE NONCLUSTERED,
			HostName		nvarchar(255),
			DataBaseName	NVarChar(255),
			Comment		ntext NULL,
			CONSTRAINT   	pk_Service PRIMARY KEY (ServiceIndex)
	'
		
	SELECT	@InsColumnScript	= ' ServiceIndex, ServiceType, HostName, DataBaseName, Comment '
	SELECT	@SelColumnScript	= ' ServiceIndex, RTRIM(ServiceType) ServiceType, RTRIM(HostName) HostName, RTRIM(DataBaseName) DataBaseName, Comment '

	SELECT	@IdentityFlag		= 'N'

	DECLARE @Status			int
	EXEC ConvertTableToUnicode
		@TableName,
		@ColumnName,
		@DataType,
		@PrimaryKey,
		@UniqueKey,
		@KeyColumnName,
		@KeyColumnType,
		@TabColumnScript,
		@InsColumnScript,
		@SelColumnScript,
		@IdentityFlag,
		@StepNo,
		@Status OUT

	IF @Status <> 0
		RETURN

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBService, Trimming and Converting to Unicode', GETDATE(), NULL, 'Already Updated')
END
;
IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBStringGlobalIndex'
	AND COLUMN_NAME = 'StringValue'
	AND DATA_TYPE = 'NVARCHAR')
BEGIN
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBStringGlobalIndex, Trimming and Converting to Unicode', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	DECLARE	@TableName		varchar(128)
	DECLARE @ColumnName		nvarchar(128)
	DECLARE @DataType		nvarchar(128)
	DECLARE @PrimaryKey		varchar(128)
	DECLARE @UniqueKey		varchar(128)
	DECLARE @KeyColumnName		varchar(128)
	DECLARE @KeyColumnType		varchar(128)
	DECLARE @TabColumnScript	varchar(8000)
	DECLARE @InsColumnScript	varchar(8000)
	DECLARE @SelColumnScript	varchar(8000)
	DECLARE @IdentityFlag		char(1)

	SELECT	@TableName		= 'PDBStringGlobalIndex'
	SELECT	@ColumnName		= 'StringValue'
	SELECT	@DataType		= 'NVARCHAR'
	SELECT	@PrimaryKey		= 'pk_datafielddocument6'
	SELECT	@UniqueKey		=  NULL
	SELECT	@KeyColumnName		= 'DocumentIndex'
	SELECT	@KeyColumnType		= 'int'
	-----------------------------------------------
-- Changed by:           Shubham Mittal
-- Change Description:   Changes in TabColumnScript- Constraint removed in PDBStringGlobalIndex as it is dropped later in PRTUpdateScript if exists.
-----------------------------------------------
	SELECT	@TabColumnScript	= '
			DataFieldIndex			int
			CONSTRAINT fk_Strglobalind_dfind references  PDBGlobalIndex (DataFieldIndex),
			DocumentIndex			int,
			StringValue			NVarChar(255),
			CONSTRAINT   pk_datafielddocument6 
			PRIMARY KEY (DocumentIndex,DataFieldindex,StringValue)
	'
	
	SELECT	@InsColumnScript	= ' DataFieldIndex, DocumentIndex, StringValue '
	SELECT	@SelColumnScript	= ' DataFieldIndex, DocumentIndex, RTRIM(StringValue) StringValue '

	SELECT	@IdentityFlag		= 'N'

	DECLARE @Status			int
	EXEC ConvertTableToUnicode
		@TableName,
		@ColumnName,
		@DataType,
		@PrimaryKey,
		@UniqueKey,
		@KeyColumnName,
		@KeyColumnType,
		@TabColumnScript,
		@InsColumnScript,
		@SelColumnScript,
		@IdentityFlag,
		@StepNo,
		@Status OUT

	IF @Status <> 0
		RETURN

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBStringGlobalIndex, Trimming and Converting to Unicode', GETDATE(), NULL, 'Already Updated')
END
;
IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBTrackActionTable'
	AND COLUMN_NAME = 'ActionItemSubject'
	AND DATA_TYPE = 'NVARCHAR')
BEGIN
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBTrackActionTable, Trimming and Converting to Unicode', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	IF NOT EXISTS(
		SELECT 1 FROM SYSINDEXES WHERE NAME = 'IDX_Temp_Track_Act')
	BEGIN
		CREATE NONCLUSTERED INDEX IDX_Temp_Track_Act ON PDBTrackActionTable(ActionItemId)
		IF @@ERROR <> 0
		BEGIN
			ROLLBACK TRANSACTION TranUniUp
			RETURN
		END
	END

	DECLARE	@TableName		varchar(128)
	DECLARE @ColumnName		nvarchar(128)
	DECLARE @DataType		nvarchar(128)
	DECLARE @PrimaryKey		varchar(128)
	DECLARE @UniqueKey		varchar(128)
	DECLARE @KeyColumnName		varchar(128)
	DECLARE @KeyColumnType		varchar(128)
	DECLARE @TabColumnScript	varchar(8000)
	DECLARE @InsColumnScript	varchar(8000)
	DECLARE @SelColumnScript	varchar(8000)
	DECLARE @IdentityFlag		char(1)

	SELECT	@TableName		= 'PDBTrackActionTable'
	SELECT	@ColumnName		= 'ActionItemSubject'
	SELECT	@DataType		= 'NVARCHAR'
	SELECT	@PrimaryKey		= NULL
	SELECT	@UniqueKey		=  NULL
	SELECT	@KeyColumnName		= 'ActionItemId'
	SELECT	@KeyColumnType		= 'int'
	SELECT	@TabColumnScript	= '
			ActionItemId		int,
			ActionItemSubject	nvarchar(255),
			ActionType		char(1),
			ActionTime		datetime,
			FromUserId		int,
			ToUserId		int,
			ActionDataClassId	int,
			ActionDataClassName	nvarchar(255),
			Attachments		varchar(1020) NULL
	'
	
	SELECT	@InsColumnScript	= ' ActionItemId, ActionItemSubject, ActionType, ActionTime, FromUserId, ToUserId, ActionDataClassId, ActionDataClassName, Attachments '
	SELECT	@SelColumnScript	= ' ActionItemId, RTRIM(ActionItemSubject) ActionItemSubject, ActionType, ActionTime, FromUserId, ToUserId, ActionDataClassId, RTRIM(ActionDataClassName) ActionDataClassName, RTRIM(Attachments) Attachments '

	SELECT	@IdentityFlag		= 'N'

	DECLARE @Status			int
	EXEC ConvertTableToUnicode
		@TableName,
		@ColumnName,
		@DataType,
		@PrimaryKey,
		@UniqueKey,
		@KeyColumnName,
		@KeyColumnType,
		@TabColumnScript,
		@InsColumnScript,
		@SelColumnScript,
		@IdentityFlag,
		@StepNo,
		@Status OUT

	IF @Status <> 0
		RETURN

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBTrackActionTable, Trimming and Converting to Unicode', GETDATE(), NULL, 'Already Updated')
END
;
IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUserAddressList'
	AND COLUMN_NAME = 'ListName'
	AND DATA_TYPE = 'NVARCHAR')
BEGIN
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUserAddressList, Trimming and Converting to Unicode', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	DECLARE	@TableName		varchar(128)
	DECLARE @ColumnName		nvarchar(128)
	DECLARE @DataType		nvarchar(128)
	DECLARE @PrimaryKey		varchar(128)
	DECLARE @UniqueKey		varchar(128)
	DECLARE @KeyColumnName		varchar(128)
	DECLARE @KeyColumnType		varchar(128)
	DECLARE @TabColumnScript	varchar(8000)
	DECLARE @InsColumnScript	varchar(8000)
	DECLARE @SelColumnScript	varchar(8000)
	DECLARE @IdentityFlag		char(1)

	SELECT	@TableName		= 'PDBUserAddressList'
	SELECT	@ColumnName		= 'ListName'
	SELECT	@DataType		= 'NVARCHAR'
	SELECT	@PrimaryKey		= 'pk_AddressIndex'
	SELECT	@UniqueKey		=  'UK_List'
	SELECT	@KeyColumnName		= 'ListIndex'
	SELECT	@KeyColumnType		= 'int'
	SELECT	@TabColumnScript	= '
			ListIndex	int IDENTITY(1,1) Constraint pk_AddressIndex PRIMARY KEY,
			ListName	nvarchar(255),
			Owner		int,
			CONSTRAINT UK_List UNIQUE (ListName, Owner)
	'
	
	SELECT	@InsColumnScript	= ' ListIndex, ListName, Owner '
	SELECT	@SelColumnScript	= ' ListIndex, RTRIM(ListName) ListName, Owner '

	SELECT	@IdentityFlag		= 'Y'

	DECLARE @Status			int
	EXEC ConvertTableToUnicode
		@TableName,
		@ColumnName,
		@DataType,
		@PrimaryKey,
		@UniqueKey,
		@KeyColumnName,
		@KeyColumnType,
		@TabColumnScript,
		@InsColumnScript,
		@SelColumnScript,
		@IdentityFlag,
		@StepNo,
		@Status OUT

	IF @Status <> 0
		RETURN

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUserAddressList, Trimming and Converting to Unicode', GETDATE(), NULL, 'Already Updated')
END
;
IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'PDBUserConfig')
BEGIN
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Creating New Table', 'Creating Table PDBUserConfig and entering data', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	CREATE TABLE PDBUserConfig
	(
		PasswordLen			smallint,
		PasswordHistoryCount		smallint,
		LoggedinAttemptCount		smallint,
		UserGroupPreviledgeFlag		char CONSTRAINT df_Usrconfig_UGprivFlag DEFAULT 'N' NOT NULL,
		MinSpecialCharCount		smallint,
		PasswordExpiryWarnTime		int,
		PasswordDisable			CHAR(1) CONSTRAINT df_Usrconfig_pwdDisable	DEFAULT 'N' NOT NULL,
		PasswordDisableTime		INT, 
		DisableIdleUser			Char(1) CONSTRAINT df_Usrconfig_DisableIdleUser DEFAULT 'N' NOT NULL,
		LoginPeriod			INT
			
	)
	EXECUTE ('INSERT INTO PDBUserConfig (PasswordLen, PasswordHistoryCount, LoggedinAttemptCount, UserGroupPreviledgeFlag, MinSpecialCharCount, PasswordExpiryWarnTime,PasswordDisable,PasswordDisableTime,DisableIdleUser,LoginPeriod) VALUES (8,3,5,''N'',0,0,''N'',0,''N'',0)')

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Creating New Table', 'Creating Table PDBUserConfig and entering data', GETDATE(), NULL, 'Already Updated')
END
;
IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUserConfig'
	AND COLUMN_NAME = 'PasswordExpiryWarnTime')
BEGIN
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUserConfig ADD PasswordExpiryWarnTime Column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	ALTER TABLE PDBUSERCONFIG ADD PasswordExpiryWarnTime INT 
	UPDATE PDBUSERCONFIG SET PasswordExpiryWarnTime = 0

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUserConfig ADD PasswordExpiryWarnTime Column', GETDATE(), NULL, 'Already Updated')
END
;

IF NOT EXISTS(SELECT 1 FROM PDBUserConfig)
BEGIN
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Inserting data', 'Inserting into PDBUserConfig table', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	EXECUTE ('INSERT INTO PDBUserConfig (PasswordLen, PasswordHistoryCount, LoggedinAttemptCount, UserGroupPreviledgeFlag, MinSpecialCharCount, PasswordExpiryWarnTime,PasswordDisable,PasswordDisableTime,DisableIdleUser,LoginPeriod) VALUES (8,3,5,''N'',0,0,''N'',0,''N'',0)')

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Inserting data', 'Inserting into PDBUserConfig table', GETDATE(), NULL, 'Already Updated')
END
;
IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'PDBUserLicenseInfo')
BEGIN
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Creating New Table', 'Creating Table PDBUserLicenseInfo', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	CREATE TABLE PDBUserLicenseInfo( 
		UserIndex int CONSTRAINT PK_USERLICENSEINFO PRIMARY KEY Clustered,		
		UserType CHAR(1) 
	)

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Creating New Table', 'Creating Table PDBUserLicenseInfo', GETDATE(), NULL, 'Already Updated')
END
;
IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'UserSecurity')
BEGIN
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Creating New Table', 'Creating Table UserSecurity', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	CREATE TABLE UserSecurity
	(
		UserIndex		int,
		LoggedInAttempts	SmallInt,
		UserLocked		Char(1) NULL,
		LockedTime		DateTime NULL,
		PasswordHistory		NVARCHAR(1000) NULL,
		ExpiryDays		int NULL,
		ResetPasswordFlag       CHAR(1) CONSTRAINT df_us_rpwdf DEFAULT 'N' NOT NULL,	
		HasLoginBefore          CHAR(1) CONSTRAINT df_us_hloginbf DEFAULT 'Y' NOT NULL,
		LastLoginTime		DATETIME NULL,
		LastLoginFaliureTime	DATETIME NULL,
		FailureAttemptCount	INT CONSTRAINT df_us_fAc DEFAULT 0,
		LastUnlockTime		DATETIME NULL,
		LastLogoutTime		DATETIME NULL
	)

	EXECUTE ('INSERT INTO UserSecurity SELECT UserIndex, 0, ''N'', NULL, NULL, NULL,''N'',''Y'',NULL,NULL,0,NULL,NULL FROM PDBUser')

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Creating New Table', 'Creating Table UserSecurity', GETDATE(), NULL, 'Already Updated')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'UserSecurity'
	AND COLUMN_NAME = 'PasswordHistory'
	AND DATA_TYPE = 'NVARCHAR')
BEGIN
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table UserSecurity Trimming and Converting to Unicode', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	DECLARE @LastLogoutTmColExists CHAR(1)
	DECLARE @LastUnlockTmColExists CHAR(1)
	DECLARE @FailAtmptCntColExists CHAR(1)
	DECLARE @LoginFailTmColExists CHAR(1)
	DECLARE @LastLoginTmColExists CHAR(1)
	DECLARE @HasLoginBfrColExists CHAR(1)
	DECLARE @ResetPwdColExists CHAR(1)
	DECLARE @ExpDaysColExists CHAR(1)
		
	DECLARE	@TableName		varchar(128)
	DECLARE @ColumnName		nvarchar(128)
	DECLARE @DataType		nvarchar(128)
	DECLARE @PrimaryKey		varchar(128)
	DECLARE @UniqueKey		varchar(128)
	DECLARE @KeyColumnName		varchar(128)
	DECLARE @KeyColumnType		varchar(128)
	DECLARE @TabColumnScript	varchar(8000)
	DECLARE @InsColumnScript	varchar(8000)
	DECLARE @SelColumnScript	varchar(8000)
	DECLARE @IdentityFlag		char(1)

	SELECT	@TableName		= 'UserSecurity'
	SELECT	@ColumnName		= 'PasswordHistory'
	SELECT	@DataType		= 'NVARCHAR'
	SELECT  @PrimaryKey		= NULL
	SELECT  @UniqueKey		= NULL
	SELECT  @KeyColumnName		= 'UserIndex'
	SELECT	@KeyColumnType		= 'Int'	

	SELECT	@TabColumnScript	= '
			UserIndex		int,
			LoggedInAttempts	SmallInt,
			UserLocked		Char(1) NULL,
			LockedTime		DateTime NULL,
			PasswordHistory		NVARCHAR(1000) NULL,
			ExpiryDays		int NULL,
			ResetPasswordFlag       CHAR(1) CONSTRAINT df_us_rpwdf DEFAULT ''N'' NOT NULL,	
			HasLoginBefore          CHAR(1) CONSTRAINT df_us_hloginbf DEFAULT ''Y'' NOT NULL,
			LastLoginTime		DATETIME NULL,
			LastLoginFaliureTime	DATETIME NULL,
			FailureAttemptCount	INT CONSTRAINT df_us_fAc DEFAULT 0,
			LastUnlockTime		DATETIME NULL,
			LastLogoutTime		DATETIME NULL
	'

	SELECT	@InsColumnScript	= ' UserIndex, LoggedInAttempts, UserLocked, LockedTime, PasswordHistory, ExpiryDays, ResetPasswordFlag, HasLoginBefore, LastLoginTime, LastLoginFaliureTime, FailureAttemptCount, LastUnlockTime, LastLogoutTime '

	SELECT	@SelColumnScript	=  ' UserIndex, LoggedInAttempts, UserLocked, LockedTime, PasswordHistory, '

	IF EXISTS(
		SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'UserSecurity'
		AND COLUMN_NAME = 'LastLogoutTime'
	)
		SELECT @LastLogoutTmColExists = 'Y'
	ELSE
		SELECT @LastLogoutTmColExists = 'N'	

	IF EXISTS(
		SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'UserSecurity'
		AND COLUMN_NAME = 'LastUnlockTime'
	)
		SELECT @LastUnlockTmColExists = 'Y'
	ELSE
		SELECT @LastUnlockTmColExists = 'N'

	IF EXISTS(
		SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'UserSecurity'
		AND COLUMN_NAME = 'FailureAttemptCount'
	)
		SELECT @FailAtmptCntColExists = 'Y'
	ELSE
		SELECT @FailAtmptCntColExists = 'N'

	IF EXISTS(
		SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'UserSecurity'
		AND COLUMN_NAME = 'LastLoginFaliureTime'
	)
		SELECT @LoginFailTmColExists = 'Y'
	ELSE
		SELECT @LoginFailTmColExists = 'N'

	IF EXISTS(
		SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'UserSecurity'
		AND COLUMN_NAME = 'LastLoginTime'
	)
		SELECT @LastLoginTmColExists = 'Y'
	ELSE
		SELECT @LastLoginTmColExists = 'N'
	
	IF EXISTS(
		SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'UserSecurity'
		AND COLUMN_NAME = 'HasLoginBefore'
	)
		SELECT @HasLoginBfrColExists = 'Y'
	ELSE
		SELECT @HasLoginBfrColExists = 'N'
	
	IF EXISTS(
		SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'UserSecurity'
		AND COLUMN_NAME = 'ResetPasswordFlag'
	)
		SELECT @ResetPwdColExists = 'Y'
	ELSE
		SELECT @ResetPwdColExists = 'N'

	IF EXISTS(
		SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'UserSecurity'
		AND COLUMN_NAME = 'ExpiryDays'
	)
		SELECT @ExpDaysColExists = 'Y'
	ELSE
		SELECT @ExpDaysColExists = 'N'

	IF @ExpDaysColExists = 'N'
	BEGIN
		SELECT @SelColumnScript = RTRIM(@SelColumnScript) + ' NULL,''N'',''Y'',NULL,NULL,0,NULL,NULL '
	END
	ELSE IF @ResetPwdColExists = 'N'
	BEGIN
		SELECT @SelColumnScript = RTRIM(@SelColumnScript) + 'ExpiryDays, ''N'',''Y'',NULL,NULL,0,NULL,NULL '
	END
	ELSE IF @HasLoginBfrColExists = 'N'
	BEGIN
		SELECT @SelColumnScript = RTRIM(@SelColumnScript) + 'ExpiryDays, ResetPasswordFlag, ''Y'',NULL,NULL,0,NULL,NULL '
	END
	ELSE IF @LastLoginTmColExists = 'N'
	BEGIN
		SELECT @SelColumnScript = RTRIM(@SelColumnScript) + 'ExpiryDays, ResetPasswordFlag, HasLoginBefore, NULL,NULL,0,NULL,NULL '
	END
	ELSE IF @LoginFailTmColExists = 'N'
	BEGIN
		SELECT @SelColumnScript = RTRIM(@SelColumnScript) + 'ExpiryDays, ResetPasswordFlag, HasLoginBefore,LastLoginTime, NULL,0,NULL,NULL '
	END
	ELSE IF @FailAtmptCntColExists = 'N'
	BEGIN
		SELECT @SelColumnScript = RTRIM(@SelColumnScript) + 'ExpiryDays, ResetPasswordFlag, HasLoginBefore,LastLoginTime, LastLoginFaliureTime, 0,NULL,NULL '
	END
	ELSE IF @LastUnlockTmColExists = 'N'
	BEGIN
		SELECT @SelColumnScript = RTRIM(@SelColumnScript) + 'ExpiryDays, ResetPasswordFlag, HasLoginBefore,LastLoginTime, LastLoginFaliureTime, FailureAttemptCount ,NULL,NULL '
	END
	ELSE IF @LastLogoutTmColExists = 'N'
	BEGIN
		SELECT @SelColumnScript = RTRIM(@SelColumnScript) + 'ExpiryDays, ResetPasswordFlag, HasLoginBefore,LastLoginTime, LastLoginFaliureTime, FailureAttemptCount ,LastUnlockTime ,NULL '
	END
	ELSE
	BEGIN
		SELECT @SelColumnScript = RTRIM(@SelColumnScript) + 'ExpiryDays, ResetPasswordFlag, HasLoginBefore,LastLoginTime, LastLoginFaliureTime, FailureAttemptCount ,LastUnlockTime ,LastLogoutTime '
	END

	SELECT	@IdentityFlag		= 'N'

	DECLARE @Status			int

	EXEC ConvertTableToUnicode

		@TableName,
		@ColumnName,
		@DataType,
		@PrimaryKey,
		@UniqueKey,
		@KeyColumnName,
		@KeyColumnType,
		@TabColumnScript,
		@InsColumnScript,
		@SelColumnScript,
		@IdentityFlag,
		@StepNo,
		@Status OUT

	IF @Status <> 0
		RETURN
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table UserSecurity Trimming and Converting to Unicode', GETDATE(), NULL, 'Already Updated')
END

;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'PDBLicense'
)
BEGIN
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Creating New Table', 'Creating Table PDBLicense', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	CREATE TABLE PDBLicense( 
			MaxNoOfFixedUsers		int ,		
			EncrFixedUsers			NVARCHAR(64) ,
			IsPowerLess			CHAR(1) CONSTRAINT df_License_Ispwrless DEFAULT 'N' NOT NULL,
			PwdSensitivity			CHAR(1) CONSTRAINT df_License_pwdS DEFAULT 'Y' NOT NULL,
			FTLCHECK			CHAR(1)  CONSTRAINT df_License_ftlcheck DEFAULT 'N' NOT NULL,
			MaxNoOfSUsers			int ,
			EncrSUsers			NVARCHAR(64),
			IsMakerCheckerEnabled		CHAR(1) CONSTRAINT df_License_IsMCenabled DEFAULT 'N' NOT NULL,
			DDTFTS				CHAR(1) CONSTRAINT df_License_DDTFTS DEFAULT 'N' NOT NULL ,
			STypeLogout			CHAR(1) CONSTRAINT df_License_STypeLogout DEFAULT 'N' NOT NULL,
			PasswordAlgorithm		NVARCHAR(255) NULL
	)

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Creating New Table', 'Creating Table PDBLicense', GETDATE(), NULL, 'Already Updated')
END
;
IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBLicense'
	AND COLUMN_NAME = 'IsPowerLess')
BEGIN
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBLicense ADD IsPowerLess Column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	ALTER TABLE PDBLICENSE ADD ISPOWERLESS char(1) NOT NULL CONSTRAINT df_License_Ispwrless DEFAULT 'N'

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBLicense ADD IsPowerLess Column', GETDATE(), NULL, 'Already Updated')
END
;
IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBLicense'
	AND COLUMN_NAME = 'PwdSensitivity')
BEGIN
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBLicense ADD PWDSENSITIVITY Column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	ALTER TABLE PDBLICENSE ADD PWDSENSITIVITY char(1) NOT NULL CONSTRAINT df_License_pwdS DEFAULT 'Y'

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBLicense ADD PWDSENSITIVITY Column', GETDATE(), NULL, 'Already Updated')
END
;
IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBLicense'
	AND COLUMN_NAME = 'FTLCHECK')
BEGIN
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBLicense ADD FTLCHECK Column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	ALTER TABLE PDBLICENSE ADD FTLCHECK char(1) NOT NULL CONSTRAINT df_License_ftlcheck DEFAULT 'N'

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBLicense ADD FTLCHECK Column', GETDATE(), NULL, 'Already Updated')
END
;
IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBLicense'
	AND COLUMN_NAME = 'MaxNoOfSUsers')
BEGIN
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBLicense ADD MaxNoOfSUsers Column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	ALTER TABLE PDBLICENSE ADD MaxNoOfSUsers INT 

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBLicense ADD MaxNoOfSUsers Column', GETDATE(), NULL, 'Already Updated')
END
;
IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBLicense'
	AND COLUMN_NAME = 'EncrSUsers')
BEGIN
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBLicense ADD EncrSUsers Column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	ALTER TABLE PDBLICENSE ADD EncrSUsers NVARCHAR(64) 

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBLicense ADD EncrSUsers Column', GETDATE(), NULL, 'Already Updated')
END
;
IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBLicense'
	AND COLUMN_NAME = 'EncrFixedUsers'
	AND DATA_TYPE = 'nvarchar'
	AND CHARACTER_MAXIMUM_LENGTH = 64)
BEGIN
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter', 'Alter Table PDBLicense ALTER COLUMN EncrFixedUsers' , getdate(), NULL, 'UPDATING')
	SELECT @StepNo = @@IDENTITY
	ALTER TABLE PDBLicense ALTER COLUMN EncrFixedUsers NVARCHAR(64)
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter', 'Alter Table PDBLicense ALTER COLUMN EncrFixedUsers' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBLicense'
	AND COLUMN_NAME = 'EncrSUsers'
	AND DATA_TYPE = 'nvarchar'
	AND CHARACTER_MAXIMUM_LENGTH = 64)
BEGIN
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter', 'Alter Table PDBLicense ALTER COLUMN EncrSUsers' , getdate(), NULL, 'UPDATING')
	SELECT @StepNo = @@IDENTITY
	ALTER TABLE PDBLicense ALTER COLUMN EncrSUsers NVARCHAR(64)
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter', 'Alter Table PDBLicense ALTER COLUMN EncrSUsers' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(SELECT 1 FROM PDBLICENSE)
BEGIN
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Inserting data', 'Inserting into PDBLICENSE table', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY
	
	IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBLicense'
	AND COLUMN_NAME = 'IsMakerCheckerEnabled')
	BEGIN
		EXECUTE ( 'INSERT INTO PDBLicense(MaxNoOfFixedUsers, EncrFixedUsers,ISPowerLess,PwdSensitivity,FTLCHECK,MaxNoOfSUsers,EncrSUsers) VALUES (0, ''0'',''N'',''Y'',''N'',0,''0'')')
	END
	ELSE
	BEGIN
		EXECUTE ( 'INSERT INTO PDBLicense(MaxNoOfFixedUsers, EncrFixedUsers,ISPowerLess,PwdSensitivity,FTLCHECK,MaxNoOfSUsers,EncrSUsers,IsMakerCheckerEnabled) VALUES (0, ''0'',''N'',''Y'',''N'',0,''0'',''N'')')
	END
	
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Inserting data', 'Inserting into PDBLICENSE table', GETDATE(), NULL, 'Already Updated')
END
;
IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'Usr_0_UserPreferences'
)
BEGIN
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Creating New Table', 'Creating Table Usr_0_UserPreferences', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	CREATE TABLE  Usr_0_UserPreferences
	(
		UserIndex int NOT NULL CONSTRAINT df_UsrPref_uind default 0,
		FolderBatchSize smallint NOT NULL CONSTRAINT df_UsrPref_FolBatchSize default 10,
		DocumentBatchSize smallint NOT NULL CONSTRAINT df_UsrPref_DocBatchSize default 10,
		DocSearchBatchSize smallint NOT NULL CONSTRAINT df_UsrPref_DocSBatchsize default 10,
		ListViewContents varchar(255) NOT NULL CONSTRAINT df_UsrPref_ListviewCont default '111010111001111000',
		PickListBatchSize smallint NOT NULL  CONSTRAINT df_UsrPref_PickListBatchSize default 10,
		UserListBatchSize smallint NOT NULL CONSTRAINT df_UsrPref_UsrListBatchSize default 10,
		PreferedGroup nvarchar(64) NOT NULL CONSTRAINT df_UsrPref_PGp default '1#Everyone',
		PreferedFilter int NOT NULL CONSTRAINT df_UsrPref_Pfilter default 0,
		NativeAppDocTypes varchar(500),
		DoclistSortPreferences varchar(10)
	)

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Creating New Table', 'Creating Table Usr_0_UserPreferences', GETDATE(), NULL, 'Already Updated')
END
;

IF EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'Usr_0_UserPreferences')
BEGIN
	IF NOT EXISTS(
		SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'Usr_0_UserPreferences'
		AND COLUMN_NAME = 'PreferedGroup'
		AND DATA_TYPE = 'NVARCHAR')
	BEGIN
		SET NOCOUNT ON

		DECLARE @StepNo			int
		INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table Usr_0_UserPreferences Trimming and Converting to Unicode', GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		DECLARE @DocListSortPrfColExists CHAR(1)

		DECLARE	@TableName		varchar(128)
		DECLARE @ColumnName		nvarchar(128)
		DECLARE @DataType		nvarchar(128)
		DECLARE @PrimaryKey		varchar(128)
		DECLARE @UniqueKey		varchar(128)
		DECLARE @KeyColumnName		varchar(128)
		DECLARE @KeyColumnType		varchar(128)
		DECLARE @TabColumnScript	varchar(8000)
		DECLARE @InsColumnScript	varchar(8000)
		DECLARE @SelColumnScript	varchar(8000)
		DECLARE @IdentityFlag		char(1)

		SELECT	@TableName		= 'Usr_0_UserPreferences'
		SELECT	@ColumnName		= 'PreferedGroup'
		SELECT	@DataType		= 'NVARCHAR'
		SELECT  @PrimaryKey		= NULL
		SELECT  @UniqueKey		= NULL
		SELECT  @KeyColumnName		= 'UserIndex'
		SELECT	@KeyColumnType		= 'Int'	

		SELECT	@TabColumnScript	= '
				UserIndex int NOT NULL CONSTRAINT df_UsrPref_uind default 0,
				 FolderBatchSize smallint NOT NULL CONSTRAINT df_UsrPref_FolBatchSize default 10,
				 DocumentBatchSize smallint NOT NULL CONSTRAINT df_UsrPref_DocBatchSize default 10,
				 DocSearchBatchSize smallint NOT NULL CONSTRAINT df_UsrPref_DocSBatchsize default 10,
				 ListViewContents varchar(255) NOT NULL CONSTRAINT df_UsrPref_ListviewCont default ''111010111001111000'',
				 PickListBatchSize smallint NOT NULL CONSTRAINT df_UsrPref_PickListBatchSize default 10,
				 UserListBatchSize smallint NOT NULL CONSTRAINT df_UsrPref_UsrListBatchSize default 10,
				 PreferedGroup nvarchar(64) NOT NULL CONSTRAINT df_UsrPref_PGp default ''1#Everyone'',
				 PreferedFilter int NOT NULL CONSTRAINT df_UsrPref_Pfilter default 0,
				 NativeAppDocTypes varchar(500) NULL,
				 DoclistSortPreferences varchar(10) NULL
		'

		SELECT	@InsColumnScript	= ' UserIndex, FolderBatchSize, DocumentBatchSize, DocSearchBatchSize, ListViewContents, PickListBatchSize, UserListBatchSize, PreferedGroup, PreferedFilter, NativeAppDocTypes, DoclistSortPreferences '

		SELECT	@SelColumnScript	=  ' UserIndex, FolderBatchSize, DocumentBatchSize, DocSearchBatchSize, ListViewContents, PickListBatchSize, UserListBatchSize, PreferedGroup, PreferedFilter, NativeAppDocTypes, '

		IF EXISTS(
			SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
			WHERE TABLE_NAME = 'Usr_0_UserPreferences'
			AND COLUMN_NAME = 'DoclistSortPreferences'
		)
			SELECT @DocListSortPrfColExists = 'Y'
		ELSE
			SELECT @DocListSortPrfColExists = 'N'

		IF @DocListSortPrfColExists = 'N'
			SELECT @SelColumnScript = RTRIM(@SelColumnScript) + ' ''5#0'' '
		ELSE
			SELECT @SelColumnScript = RTRIM(@SelColumnScript) + ' DoclistSortPreferences '

		SELECT	@IdentityFlag		= 'N'

		DECLARE @Status			int

		EXEC ConvertTableToUnicode

			@TableName,
			@ColumnName,
			@DataType,
			@PrimaryKey,
			@UniqueKey,
			@KeyColumnName,
			@KeyColumnType,
			@TabColumnScript,
			@InsColumnScript,
			@SelColumnScript,
			@IdentityFlag,
			@StepNo,
			@Status OUT

		IF @Status <> 0
			RETURN
		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		SET NOCOUNT ON
		INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table Usr_0_UserPreferences Trimming and Converting to Unicode', GETDATE(), NULL, 'Already Updated')
	END
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBNewAuditTrail_Table'
	AND COLUMN_NAME = 'Comment'
	AND DATA_TYPE = 'NVARCHAR')
BEGIN
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBNewAuditTrail_Table, Trimming and Converting to Unicode', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	DECLARE	@TableName		varchar(128)
	DECLARE @ColumnName		nvarchar(128)
	DECLARE @DataType		nvarchar(128)
	DECLARE @PrimaryKey		varchar(128)
	DECLARE @UniqueKey		varchar(128)
	DECLARE @KeyColumnName		varchar(128)
	DECLARE @KeyColumnType		varchar(128)
	DECLARE @TabColumnScript	varchar(8000)
	DECLARE @InsColumnScript	varchar(8000)
	DECLARE @SelColumnScript	varchar(8000)
	DECLARE @IdentityFlag		char(1)

	SELECT	@TableName		= 'PDBNewAuditTrail_Table'
	SELECT	@ColumnName		= 'Comment'
	SELECT	@DataType		= 'NVARCHAR'
	SELECT	@PrimaryKey		= 'pk_auditlogid'
	SELECT	@UniqueKey		=  NULL
	SELECT	@KeyColumnName		= 'AuditLogIndex'
	SELECT	@KeyColumnType		= 'int'
	SELECT	@TabColumnScript	= '
			AuditLogIndex		int IDENTITY(1,1) CONSTRAINT   pk_auditlogid      PRIMARY KEY  Clustered,
			ActionId                int NOT NULL,
			Category                CHAR(1) NULL,
			ActiveObjectId          int NULL,
			ActiveObjectType        CHAR(1) NULL,
			SubsdiaryObjectId       int NULL,
			SubsdiaryObjectType     CHAR(1) NULL,
			Comment                 NVARCHAR(255) NULL,
			DATETIME                DATETIME NOT NULL,
			USERINDEX               int NOT NULL,
			UserName		nvarchar(64) NULL,
			ActiveObjectName	nvarchar(255) NULL,
			SubsdiaryObjectName	nvarchar(255) NULL,
			OldValue		nvarchar(255) NULL,
			NewValue		nvarchar(255) NULL
	'

	SELECT	@InsColumnScript	= ' AuditLogIndex, ActionId, Category, ActiveObjectId, ActiveObjectType, SubsdiaryObjectId, SubsdiaryObjectType, Comment, DATETIME, USERINDEX, UserName, ActiveObjectName, SubsdiaryObjectName, OldValue, NewValue '
	SELECT	@SelColumnScript	= ' AuditLogIndex, ActionId, Category, ActiveObjectId, ActiveObjectType, SubsdiaryObjectId, SubsdiaryObjectType, RTRIM(Comment) Comment, DATETIME, USERINDEX, NULL, NULL, NULL, NULL, NULL '
	SELECT	@IdentityFlag		= 'Y'
	DECLARE @Status			int
	EXEC ConvertTableToUnicode
		@TableName,
		@ColumnName,
		@DataType,
		@PrimaryKey,
		@UniqueKey,
		@KeyColumnName,
		@KeyColumnType,
		@TabColumnScript,
		@InsColumnScript,
		@SelColumnScript,
		@IdentityFlag,
		@StepNo,
		@Status OUT

	IF @Status <> 0
		RETURN

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBNewAuditTrail_Table, Trimming and Converting to Unicode', GETDATE(), NULL, 'Already Updated')
END
;
IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBAnnotationVersion'
	AND COLUMN_NAME = 'ACL')
BEGIN
	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBAnnotationVersion ADD ACL Column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	SELECT * INTO PDBAnnotationVersion_Old
	FROM PDBAnnotationVersion
	DROP TABLE PDBAnnotationVersion
	CREATE TABLE PDBAnnotationVersion
	(
		DocumentIndex		int,
		PageNumber              int,
		AnnotationIndex		int
			IDENTITY(1,1) CONSTRAINT   pk_AnnotationVerIndex      PRIMARY KEY  Clustered,
		AnnotationVersion	decimal(7,2),
		AnnotationName		nvarchar(64),
		AnnotationAccessType	char,
		Owner			int,
		AnnotationBuffer	ntext null,
		AnnotationType		char(4),
		CreationDateTime	datetime,
		ACL                     varchar(255) null,
		ACLMoreFlag 		char null CONSTRAINT ck_annotationver_aclmflag CHECK (ACLMoreFlag IN ('Y','N'))
	)
	INSERT INTO PDBAnnotationVersion
	(
		DocumentIndex, PageNumber, AnnotationVersion, AnnotationName,
		AnnotationAccessType, Owner, AnnotationBuffer, AnnotationType,
		CreationDateTime,ACL, ACLMoreFlag
	)
	SELECT 	A.DocumentIndex, A.PageNumber, A.AnnotationVersion, RTRIM(A.AnnotationName),
		A.AnnotationAccessType, A.Owner, A.AnnotationBuffer, A.AnnotationType,
		A.CreationDateTime, B.ACL, B.ACLMoreFlag
	FROM 	PDBAnnotationVersion_Old A, PDBAnnotation B
	WHERE 	A.AnnotationIndex = B.AnnotationIndex
	AND 	B.ACLMoreFlag = 'N'

	DECLARE AnnoCur CURSOR FAST_FORWARD FOR
	SELECT  A.AnnotationIndex
	FROM 	PDBAnnotationVersion_Old A, PDBAnnotation B
	WHERE 	A.AnnotationIndex = B.AnnotationIndex
	AND 	B.ACLMoreFlag = 'Y'
	OPEN AnnoCur
	DECLARE @AnnotationIndex 	int
	DECLARE @NewAnnotationIndex	int
	FETCH NEXT FROM AnnoCur INTO @AnnotationIndex
	WHILE @@FETCH_STATUS <> -1
	BEGIN
		IF @@FETCH_STATUS <> -2
		BEGIN
			INSERT INTO PDBAnnotationVersion
			(
				DocumentIndex, PageNumber, AnnotationVersion, AnnotationName,
				AnnotationAccessType, Owner, AnnotationBuffer, AnnotationType,
				CreationDateTime,ACL, ACLMoreFlag
			)
			SELECT 	A.DocumentIndex, A.PageNumber, A.AnnotationVersion, A.AnnotationName,
				A.AnnotationAccessType, A.Owner, A.AnnotationBuffer, A.AnnotationType,
				A.CreationDateTime, B.ACL, B.ACLMoreFlag
			FROM 	PDBAnnotationVersion_Old A, PDBAnnotation B
			WHERE 	A.AnnotationIndex = B.AnnotationIndex
			AND 	A.AnnotationIndex = @AnnotationIndex
			SELECT @NewAnnotationIndex = @@IDENTITY
			INSERT INTO PDBRights(
				ObjectIndex1, Flag1, ObjectIndex2, Flag2, Acl
			)
			SELECT ObjectIndex1, Flag1, @NewAnnotationIndex, 'V', Acl
			FROM PDBRights
			WHERE	ObjectIndex2 = @AnnotationIndex
			AND	Flag2 = 'A'
			FETCH NEXT FROM AnnoCur INTO @AnnotationIndex
		END
	END
	CLOSE AnnoCur
	DEALLOCATE AnnoCur
	DROP TABLE PDBAnnotationVersion_Old

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBAnnotationVersion ADD ACL Column', GETDATE(), NULL, 'Already Updated')
END
;
IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBAnnotationVersion'
	AND COLUMN_NAME = 'AnnotationName'
	AND DATA_TYPE = 'NVARCHAR')
BEGIN
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBAnnotationVersion, Trimming and Converting to Unicode', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	DECLARE	@TableName		varchar(128)
	DECLARE @ColumnName		nvarchar(128)
	DECLARE @DataType		nvarchar(128)
	DECLARE @PrimaryKey		varchar(128)
	DECLARE @UniqueKey		varchar(128)
	DECLARE @KeyColumnName		varchar(128)
	DECLARE @KeyColumnType		varchar(128)
	DECLARE @TabColumnScript	varchar(8000)
	DECLARE @InsColumnScript	varchar(8000)
	DECLARE @SelColumnScript	varchar(8000)
	DECLARE @IdentityFlag		char(1)

	SELECT	@TableName		= 'PDBAnnotationVersion'
	SELECT	@ColumnName		= 'AnnotationName'
	SELECT	@DataType		= 'NVARCHAR'
	SELECT	@PrimaryKey		= 'pk_AnnotationVerIndex'
	SELECT	@UniqueKey		=  NULL
	SELECT	@KeyColumnName		= 'AnnotationIndex'
	SELECT	@KeyColumnType		= 'int'
	SELECT	@TabColumnScript	= '
			DocumentIndex		int,
			PageNumber              int,
			AnnotationIndex		int
				IDENTITY(1,1) CONSTRAINT   pk_AnnotationVerIndex      PRIMARY KEY  Clustered,
			AnnotationVersion	decimal(7,2),
			AnnotationName		nvarchar(64),
			AnnotationAccessType	char,
			Owner			int,
			AnnotationBuffer	ntext null,
			AnnotationType		char(4),
			CreationDateTime	datetime,
			ACL                     varchar(255) null,
			ACLMoreFlag 		char null CONSTRAINT ck_annotationver_aclmflag CHECK (ACLMoreFlag IN (''Y'',''N''))
	'

	SELECT	@InsColumnScript	= ' DocumentIndex, PageNumber, AnnotationIndex, AnnotationVersion, AnnotationName, AnnotationAccessType, Owner, AnnotationBuffer, AnnotationType, CreationDateTime, ACL, ACLMoreFlag '
	SELECT	@SelColumnScript	= ' DocumentIndex, PageNumber, AnnotationIndex, AnnotationVersion, RTRIM(AnnotationName) AnnotationName, AnnotationAccessType, Owner, AnnotationBuffer, AnnotationType, CreationDateTime, RTRIM(ACL) ACL, ACLMoreFlag '
	SELECT	@IdentityFlag		= 'Y'
	DECLARE @Status			int
	EXEC ConvertTableToUnicode
		@TableName,
		@ColumnName,
		@DataType,
		@PrimaryKey,
		@UniqueKey,
		@KeyColumnName,
		@KeyColumnType,
		@TabColumnScript,
		@InsColumnScript,
		@SelColumnScript,
		@IdentityFlag,
		@StepNo,
		@Status OUT

	IF @Status <> 0
		RETURN

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBAnnotationVersion, Trimming and Converting to Unicode', GETDATE(), NULL, 'Already Updated')
END
;
IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUser'
	AND COLUMN_NAME = 'UserName'
	AND DATA_TYPE = 'nvarchar'
)
BEGIN
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUser, Trimming and Converting to Unicode', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	DECLARE @PasswordVarBinExists CHAR(1)
	DECLARE @SuperiorColExists CHAR(1)
	DECLARE @SuperiorFlagColExists CHAR(1)
	DECLARE @ParentGroupIndexColExists CHAR(1)
	DECLARE @PasswordNeverExpireColExists CHAR(1)
	DECLARE @PasswordExpiryTimeColExists CHAR(1)

	IF EXISTS(
		SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'PDBUser'
		AND COLUMN_NAME = 'Password'
		AND DATA_TYPE = 'varbinary'
	)
		SELECT @PasswordVarBinExists = 'Y'
	ELSE
		SELECT @PasswordVarBinExists = 'N'

	DECLARE @QueryStr	varchar(4000)
	IF NOT EXISTS(
		SELECT 1 FROM INFORMATION_SCHEMA.TABLES
		WHERE TABLE_NAME = 'PDBUserForPasswordChange'
	)
	BEGIN
		BEGIN TRANSACTION TranUniUp
		IF @PasswordVarBinExists = 'N'
		BEGIN
			SELECT @QueryStr = ' CREATE TABLE PDBUserForPasswordChange (UserIndex int, Password varchar(128), PasswordChanged Char(1))'
		END
		ELSE
		BEGIN
			SELECT @QueryStr = ' CREATE TABLE PDBUserForPasswordChange (UserIndex int, Password varbinary(128), PasswordChanged Char(1))'
		END
		EXECUTE (@QueryStr)
		IF @@ERROR <> 0
		BEGIN
			ROLLBACK TRANSACTION TranUniUp
			RETURN
		END
		CREATE TABLE LastUserPasswordIndexTable(UserIndex int)
		INSERT INTO LastUserPasswordIndexTable VALUES (0)
		IF @@ERROR <> 0
		BEGIN
			ROLLBACK TRANSACTION TranUniUp
			RETURN
		END
		COMMIT TRANSACTION TranUniUp
	END

	IF EXISTS(
		SELECT 1 FROM INFORMATION_SCHEMA.TABLES
		WHERE TABLE_NAME = 'PDBUserForPasswordChange'
	)
	BEGIN
		DECLARE @LastUserIndex 		int
		DECLARE @StartUserIndex		int
		DECLARE	@BatchCount		smallint
		DECLARE @EndUserIndex		int
		DECLARE @NumRowFetched		smallint
		DECLARE	@MaxUserIndex		int
		DECLARE	@MaxNewUserIndex	int
		DECLARE @UniCodeCursorQuery	NVARCHAR(4000)
		SELECT 	@BatchCount = 10000

		SELECT	TOP 1 @MaxUserIndex = UserIndex FROM PDBUser WITH (NOLOCK) ORDER BY UserIndex DESC
		IF @@ERROR <> 0
		BEGIN
			ROLLBACK TRANSACTION TranUniUp
			RETURN
		END
		SELECT @MaxUserIndex = ISNULL(@MaxUserIndex, 0)

		SELECT 	@UniCodeCursorQuery = N'SELECT TOP 1 @MaxNewUserIndex = UserIndex FROM PDBUserForPasswordChange WITH (NOLOCK) ORDER BY UserIndex DESC'
		EXEC SP_EXECUTESQL @UniCodeCursorQuery, N'@MaxNewUserIndex int OUTPUT', @MaxNewUserIndex OUTPUT		
		IF @@ERROR <> 0
		BEGIN
			ROLLBACK TRANSACTION TranUniUp
			RETURN
		END
		SELECT @MaxNewUserIndex = ISNULL(@MaxNewUserIndex, 0)

		IF @MaxNewUserIndex < @MaxUserIndex
		BEGIN
			SELECT 	@NumRowFetched	= 1 
	
			SELECT 	@UniCodeCursorQuery = N'SELECT @LastUserIndex = UserIndex FROM LastUserPasswordIndexTable'
			EXEC SP_EXECUTESQL @UniCodeCursorQuery, N'@LastUserIndex int OUTPUT', @LastUserIndex OUTPUT		
			IF @@ERROR <> 0
			BEGIN
				ROLLBACK TRANSACTION TranUniUp
				RETURN
			END
			SELECT  @StartUserIndex = @LastUserIndex + 1
	
			WHILE 	@NumRowFetched > 0
			BEGIN
				SELECT @EndUserIndex = @StartUserIndex + @BatchCount - 1
				BEGIN TRANSACTION TranUniUp
				SELECT 	@UniCodeCursorQuery = 
					N' INSERT INTO PDBUserForPasswordChange(UserIndex, Password, PasswordChanged) ' + 
					N' SELECT UserIndex, Password, ''N'' ' +
					N' FROM PDBUser WITH (NOLOCK) ' + 
					N' WHERE UserIndex BETWEEN @StartUserIndex AND @EndUserIndex ' +
					N' ORDER BY UserIndex ' +
					N' SELECT @NumRowFetched = @@ROWCOUNT '
				EXEC SP_EXECUTESQL @UniCodeCursorQuery, N'@StartUserIndex int, @EndUserIndex int, @NumRowFetched INT OUTPUT', @StartUserIndex, @EndUserIndex, @NumRowFetched OUTPUT
				IF @@ERROR <> 0
				BEGIN
					ROLLBACK TRANSACTION TranUniUp
					RETURN
				END
				
				SELECT 	@UniCodeCursorQuery = 
					N'UPDATE LastUserPasswordIndexTable SET UserIndex =  @EndUserIndex'
				EXEC SP_EXECUTESQL @UniCodeCursorQuery, N'@EndUserIndex int', @EndUserIndex
				IF @@ERROR <> 0
				BEGIN
					ROLLBACK TRANSACTION TranUniUp
					RETURN
				END

				COMMIT TRANSACTION TranUniUp
				SELECT @StartUserIndex = @EndUserIndex + 1
			END
		END
	END
	IF EXISTS(
		SELECT 1 FROM INFORMATION_SCHEMA.TABLES
		WHERE TABLE_NAME = 'LastUserPasswordIndexTable'
	)
	BEGIN
		SELECT @QueryStr = ' DROP TABLE LastUserPasswordIndexTable'
		EXECUTE (@QueryStr)
		IF @@ERROR <> 0
		BEGIN
			RETURN
		END
	END


	IF EXISTS(
		SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'PDBUser'
		AND COLUMN_NAME = 'Superior'
	)
		SELECT @SuperiorColExists = 'Y'
	ELSE
		SELECT @SuperiorColExists = 'N'

	IF EXISTS(
		SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'PDBUser'
		AND COLUMN_NAME = 'SuperiorFlag'
	)
		SELECT @SuperiorFlagColExists = 'Y'
	ELSE
		SELECT @SuperiorFlagColExists = 'N'

	IF EXISTS(
		SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'PDBUser'
		AND COLUMN_NAME = 'ParentGroupIndex'
	)
		SELECT @ParentGroupIndexColExists = 'Y'
	ELSE
		SELECT @ParentGroupIndexColExists = 'N'

	IF EXISTS(
		SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'PDBUser'
		AND COLUMN_NAME = 'PasswordNeverExpire'
	)
		SELECT @PasswordNeverExpireColExists = 'Y'
	ELSE
		SELECT @PasswordNeverExpireColExists = 'N'


	IF EXISTS(
		SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'PDBUser'
		AND COLUMN_NAME = 'PasswordExpiryTime'
	)
		SELECT @PasswordExpiryTimeColExists = 'Y'
	ELSE
		SELECT @PasswordExpiryTimeColExists = 'N'


	DECLARE	@TableName		varchar(128)
	DECLARE @ColumnName		nvarchar(128)
	DECLARE @DataType		nvarchar(128)
	DECLARE @PrimaryKey		varchar(128)
	DECLARE @UniqueKey		varchar(128)
	DECLARE @KeyColumnName		varchar(128)
	DECLARE @KeyColumnType		varchar(128)
	DECLARE @TabColumnScript	varchar(8000)
	DECLARE @InsColumnScript	varchar(8000)
	DECLARE @SelColumnScript	varchar(8000)
	DECLARE @IdentityFlag		char(1)

	SELECT	@TableName		= 'PDBUser'
	SELECT	@ColumnName		= 'UserName'
	SELECT	@DataType		= 'NVARCHAR'
	SELECT	@PrimaryKey		= 'pk_userind'
	SELECT	@UniqueKey		=  'uk_Username'
	SELECT	@KeyColumnName		= 'UserIndex'
	SELECT	@KeyColumnType		= 'int'
	SELECT	@TabColumnScript	= '
			UserIndex		       int
			IDENTITY(1,1) CONSTRAINT   pk_userind      PRIMARY KEY  Clustered,
			UserName		         nvarchar(64),
			PersonalName		         nvarchar(64) null,
			FamilyName		         nvarchar(255) null,
			CreatedDateTime		         DateTime,
			ExpiryDateTime		         DateTime,
			PrivilegeControlList	         varchar(16),
			Password		         varbinary(128) null,
			Account			         int,
			Comment			         nvarchar(255) NULL,
			DeletedDateTime		         DateTime,
			UserAlive		         char CONSTRAINT ck_user_ualv CHECK (UserAlive IN (''Y'',''N'')),
			MainGroupId 			 smallint CONSTRAINT df_user_mgpid default 0,
			MailId				nvarchar(255) NULL,
			Fax             		varchar(200) NULL,
			NoteColor       		int NULL,
			Superior				INT NULL,
			SuperiorFlag			CHAR NULL,
			ParentGroupIndex		SMALLINT NULL,
			PasswordNeverExpire		Char(1) NOT NULL CONSTRAINT df_user_pwdnexp DEFAULT ''Y'',
			PasswordExpiryTime		DATETIME NULL,
			CONSTRAINT uk_Username   UNIQUE (UserName, MainGroupId)	
	'

	SELECT	@InsColumnScript	= ' UserIndex, UserName, PersonalName, FamilyName, CreatedDateTime, ExpiryDateTime, PrivilegeControlList, Password, Account, Comment, DeletedDateTime, UserAlive, MainGroupId, MailId, Fax, NoteColor, Superior, SuperiorFlag, ParentGroupIndex, PasswordNeverExpire, PasswordExpiryTime '

	SELECT	@SelColumnScript	= ' UserIndex, RTRIM(UserName) UserName, RTRIM(PersonalName) PersonalName, RTRIM(FamilyName) FamilyName, CreatedDateTime, ExpiryDateTime, RTRIM(PrivilegeControlList) PrivilegeControlList, '


	IF @PasswordVarBinExists = 'Y'
		SELECT	@SelColumnScript = @SelColumnScript + ' Password, '
	ELSE
		SELECT	@SelColumnScript = @SelColumnScript + ' NULL, '
	
	SELECT	@SelColumnScript = @SelColumnScript + ' Account, RTRIM(Comment) Comment, DeletedDateTime, UserAlive, MainGroupId, RTRIM(MailId) MailId, RTRIM(Fax) Fax, NoteColor, '

	IF @SuperiorColExists = 'Y'
		SELECT	@SelColumnScript = @SelColumnScript + ' Superior, '
	ELSE
		SELECT	@SelColumnScript = @SelColumnScript + ' NULL, '

	IF @SuperiorFlagColExists = 'Y'
		SELECT	@SelColumnScript = @SelColumnScript + ' SuperiorFlag, '
	ELSE
		SELECT	@SelColumnScript = @SelColumnScript + ' NULL, '

	IF @ParentGroupIndexColExists = 'Y'
		SELECT	@SelColumnScript = @SelColumnScript + ' ParentGroupIndex, '
	ELSE
		SELECT	@SelColumnScript = @SelColumnScript + ' 2, '

	IF @PasswordNeverExpireColExists = 'Y'
		SELECT	@SelColumnScript = @SelColumnScript + ' PasswordNeverExpire, '
	ELSE
		SELECT	@SelColumnScript = @SelColumnScript +  '''Y'', '

	IF @PasswordExpiryTimeColExists = 'Y'
		SELECT	@SelColumnScript = @SelColumnScript + ' PasswordExpiryTime '
	ELSE
		SELECT	@SelColumnScript = @SelColumnScript + ' NULL '

	SELECT	@IdentityFlag		= 'Y'

	DECLARE @Status			int
	EXEC ConvertTableToUnicode
		@TableName,
		@ColumnName,
		@DataType,
		@PrimaryKey,
		@UniqueKey,
		@KeyColumnName,
		@KeyColumnType,
		@TabColumnScript,
		@InsColumnScript,
		@SelColumnScript,
		@IdentityFlag,
		@StepNo,
		@Status OUT

	IF @Status <> 0
		RETURN

	EXECUTE ('UPDATE PDBUSER SET SUPERIOR = 1, SUPERIORFLAG = ''U'', PARENTGROUPINDEX = 1 WHERE USERINDEX = 1')

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUser, Trimming and Converting to Unicode', GETDATE(), NULL, 'Already Updated')
END
;
IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'DDTUnicodeModTab'
)
BEGIN
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter DDT Table', 'Creating DDTUnicodeModTab table to store list of ddt tables with non-unicode columns', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	IF EXISTS(
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES A
		WHERE TABLE_TYPE = 'BASE TABLE'
		AND	TABLE_NAME LIKE 'DDT[_]%'
		AND EXISTS(
			SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS B
			WHERE A.TABLE_NAME = B.TABLE_NAME
			AND DATA_TYPE IN ('VARCHAR', 'TEXT')
		)
	)
	BEGIN
		SET NOCOUNT ON
		BEGIN TRANSACTION TranUniUp

		CREATE TABLE DDTUnicodeModTab(TabName varchar(50), TableSchema varchar(50), Updated char(1))
		CREATE TABLE DDTIndexList(TabName varchar(50), IndexName varchar(256), IndexDesc varchar(256), Indkey varchar(2126))

		DECLARE @TableName	varchar(50)
		DECLARE @TableSchema	varchar(50)
		DECLARE @Position 	int	
		DECLARE @DDTIndexStr 	varchar(50)
		DECLARE @DDTIndex 	int

		DECLARE ddtcur CURSOR FOR
			SELECT A.TABLE_NAME, A.TABLE_SCHEMA
			FROM INFORMATION_SCHEMA.TABLES A
			WHERE TABLE_TYPE = 'BASE TABLE'
			AND TABLE_NAME LIKE 'DDT[_]%'
			AND EXISTS(
				SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS B
				WHERE A.TABLE_NAME = B.TABLE_NAME
				AND DATA_TYPE IN ('VARCHAR', 'TEXT')
			)

		OPEN ddtcur
		FETCH NEXT FROM ddtcur INTO @TableName, @TableSchema
		WHILE (@@FETCH_STATUS <> -1)
		BEGIN
			IF (@@FETCH_STATUS <> -2)
			BEGIN
				SELECT @DDTIndexStr = NULL
				SELECT @Position = CHARINDEX('_', @TableName)
				IF @Position = 4
				BEGIN
					SELECT @DDTIndexStr = LTRIM(RTRIM(SUBSTRING(@TableName, @Position + 1, 50)))
					IF LEN(@DDTIndexStr) > 0 AND @DDTIndexStr IS NOT NULL AND ISNUMERIC(@DDTIndexStr) = 1
					BEGIN
						SELECT @DDTIndex = CONVERT(int, @DDTIndexStr)
						IF EXISTS(
							SELECT 1 FROM PDBDataDefinition
							WHERE DataDefIndex = @DDTIndex
						)
						BEGIN
							INSERT INTO DDTUnicodeModTab VALUES(@TableName, @TableSchema, 'N')	
						END
					END	
				END  
			END
			FETCH NEXT FROM ddtcur INTO @TableName, @TableSchema
		END
		CLOSE ddtcur
		DEALLOCATE ddtcur
		COMMIT TRANSACTION TranUniUp

	END
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter DDT Table', 'Creating DDTUnicodeModTab table to store list of ddt tables with non-unicode columns', GETDATE(), NULL, 'Already Updated')
END
;
IF EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'DDTUnicodeModTab'
)
BEGIN
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter DDT Table', 'Altering table Trimming and Converting to Unicode', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	DECLARE @DDTStepNo		int
	DECLARE @Status			int

	DECLARE @DDTTableName	varchar(50)
	DECLARE @DDTColName	varchar(50)
	DECLARE @DDTDataType	varchar(50)
	DECLARE @DDTColIsNullable	varchar(10)
	DECLARE @DDtColLength	VARCHAR(10)
	DECLARE @DDTConstraintName	varchar(50)
	DECLARE @DDTConstraintType	varchar(50)
	DECLARE @DDTConsColName	varchar(50)
	DECLARE @DDTConsNameList	varchar(8000)

	DECLARE @PrimaryKey		varchar(128)
	DECLARE @UniqueKey		varchar(128)
	DECLARE @KeyColumnName		varchar(128)
	DECLARE @KeyColumnType		varchar(128)
	DECLARE @TabColumnScript	varchar(8000)
	DECLARE @InsColumnScript	varchar(8000)
	DECLARE @SelColumnScript	varchar(8000)
	DECLARE @IdentityFlag		char(1)
	DECLARE @NewDataType		varchar(50)
	DECLARE @NewDataLength		int

	DECLARE @QueryStr		varchar(8000)
	DECLARE @Position 		int	
	DECLARE @FieldIndexStr 		varchar(50)
	DECLARE @FieldIndex 		int

	SELECT @QueryStr = 
		' DECLARE ddtcur CURSOR FOR
			SELECT TabName
			FROM DDTUnicodeModTab
			WHERE Updated = ''N'''
	EXECUTE (@QueryStr)
	OPEN ddtcur
	FETCH NEXT FROM ddtcur INTO @DDTTableName
	WHILE (@@FETCH_STATUS <> -1)
	BEGIN
		IF @@FETCH_STATUS <> -2
		BEGIN
			INSERT INTO PDBUpdateStatus values ('Alter DDT Table : ' + RTRIM(@DDTTableName), 'Altering table ' + RTRIM(@DDTTableName) + ' , Trimming and Converting to Unicode', GETDATE(), NULL, 'Updating Started')
			SELECT @DDTStepNo = @@IDENTITY

			SELECT @DDTConsNameList = ''
			SELECT @TabColumnScript = ''
			SELECT @InsColumnScript = ''
			SELECT @SelColumnScript = ''	
			DECLARE ddtcolcur CURSOR FOR 
				SELECT Column_Name, Data_Type, IS_NULLABLE, CHARACTER_MAXIMUM_LENGTH
				FROM INFORMATION_SCHEMA.COLUMNS
				WHERE TABLE_NAME = @DDTTableName
				ORDER BY ORDINAL_POSITION
			OPEN ddtcolcur
			FETCH NEXT FROM ddtcolcur INTO @DDTColName, @DDTDataType, @DDTColIsNullable, @DDtColLength
			WHILE (@@FETCH_STATUS <> -1)
			BEGIN
				IF @@FETCH_STATUS <> -2
				BEGIN
					IF @DDTDataType IN ('CHAR', 'VARCHAR', 'TEXT')
						SELECT @NewDataType = 'N' + @DDTDataType
					ELSE
						SELECT @NewDataType = @DDTDataType

					SELECT @TabColumnScript = LTRIM(RTRIM(@TabColumnScript)) +  ', ' + @DDTColName + ' ' + @NewDataType
					SELECT @InsColumnScript = LTRIM(RTRIM(@InsColumnScript)) + ',' + @DDTColName

-----------------------------------------------
-- Changed by:           Shubham Mittal
-- Change Description:   Added Check for NVARCHAR datatype
-----------------------------------------------
					IF @DDTDataType = 'CHAR' OR @DDTDataType = 'VARCHAR' OR @DDTDataType = 'NVARCHAR'
					BEGIN
						IF @DDTColName = 'FOLDDOCFLAG'
							SELECT @NewDataLength = 1
						ELSE
						BEGIN
							SELECT @Position = CHARINDEX('_', @DDTColName)
							SELECT @FieldIndexStr = LTRIM(RTRIM(SUBSTRING(@DDTColName, @Position + 1, 50)))
							SELECT @FieldIndex = CONVERT(int, @FieldIndexStr)
							SELECT @NewDataLength = DataFieldLength FROM PDBGlobalIndex WHERE DataFieldIndex = @FieldIndex
						END
-------------------------------------------------------------------------------
-- Changed by:           Shubham Mittal
-- Change Description:   Existing NVARCHAR datatype fields assigned length
-------------------------------------------------------------------------------
						IF(@DDTDataType = 'NVARCHAR')
						SELECT @TabColumnScript = LTRIM(RTRIM(@TabColumnScript)) +  '(' + LTRIM(RTRIM(CONVERT(varchar(10), @NewDataLength*2))) + ')'
						ELSE
						SELECT @TabColumnScript = LTRIM(RTRIM(@TabColumnScript)) +  '(' + LTRIM(RTRIM(CONVERT(varchar(10), @NewDataLength))) + ')'
						IF @NewDataLength > 1
							SELECT @SelColumnScript = LTRIM(RTRIM(@SelColumnScript)) + ',' + 'RTRIM(' + @DDTColName + ')'
						ELSE
							SELECT @SelColumnScript = LTRIM(RTRIM(@SelColumnScript)) + ',' + @DDTColName
					END
					ELSE
						SELECT @SelColumnScript = LTRIM(RTRIM(@SelColumnScript)) + ',' + @DDTColName
					IF @DDTColIsNullable = 'YES'
					BEGIN
						SELECT @TabColumnScript = LTRIM(RTRIM(@TabColumnScript)) + ' NULL '
					END
					ELSE
					BEGIN
						SELECT @TabColumnScript = LTRIM(RTRIM(@TabColumnScript)) + ' NOT NULL '
					END
				END
				FETCH NEXT FROM ddtcolcur INTO @DDTColName, @DDTDataType, @DDTColIsNullable, @DDtColLength
			END
			CLOSE ddtcolcur
			DEALLOCATE ddtcolcur

			DECLARE ddtconcur CURSOR FOR 
				SELECT CONSTRAINT_NAME, CONSTRAINT_TYPE 
				FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
				WHERE TABLE_NAME = @DDTTableName
				AND CONSTRAINT_TYPE IN ('PRIMARY KEY','UNIQUE')
			OPEN ddtconcur
			FETCH NEXT FROM ddtconcur INTO @DDTConstraintName, @DDTConstraintType
			WHILE (@@FETCH_STATUS <> -1)
			BEGIN
				IF @@FETCH_STATUS <> -2
				BEGIN
					SELECT @DDTConsNameList = LTRIM(RTRIM(@DDTConsNameList)) + LTRIM(RTRIM(@DDTConstraintName)) + ','
					SELECT @TabColumnScript = LTRIM(RTRIM(@TabColumnScript)) + ' , CONSTRAINT ' + @DDTConstraintName + ' ' + @DDTConstraintType
					IF @DDTConstraintType = 'PRIMARY KEY'
						SELECT @TabColumnScript = LTRIM(RTRIM(@TabColumnScript)) + '(FoldDocIndex,FoldDocFlag)'
					ELSE
					BEGIN
						SELECT @DDTConsColName = COLUMN_NAME 
						FROM INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE
						WHERE CONSTRAINT_NAME = @DDTConstraintName

						SELECT @TabColumnScript = LTRIM(RTRIM(@TabColumnScript)) + '( ' + @DDTConsColName + ' ) '
					END
				END
				FETCH NEXT FROM ddtconcur INTO @DDTConstraintName, @DDTConstraintType
			END
			CLOSE ddtconcur
			DEALLOCATE ddtconcur
			SELECT @TabColumnScript = LTRIM(RTRIM(SUBSTRING(@TabColumnScript, 2, 8000)))
--			SELECT @DDTConsNameList = LTRIM(RTRIM(SUBSTRING(@DDTConsNameList, 2, 8000)))
			SELECT @InsColumnScript = LTRIM(RTRIM(SUBSTRING(@InsColumnScript, 2, 8000)))
			SELECT @SelColumnScript = LTRIM(RTRIM(SUBSTRING(@SelColumnScript, 2, 8000)))

--			SELECT DDTConsNameList = @DDTConsNameList
--			SELECT TabColumnScript = @TabColumnScript
--			SELECT InsColumnScript = @InsColumnScript
--			SELECT SelColumnScript = @SelColumnScript

			EXEC ConvertDDTTableToUnicode
				@DDTTableName,
				@DDTConsNameList,
				@TabColumnScript,
				@InsColumnScript,
				@SelColumnScript,
				@DDTStepNo,
				@Status OUT

			IF @Status <> 0
				RETURN

			SELECT @QueryStr = 
				' UPDATE DDTUnicodeModTab SET Updated = ''Y''' +
				' WHERE TabName = ''' + @DDTTableName + ''''
			EXECUTE (@QueryStr)

			UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @DDTStepNo
			SELECT @DDTStepNo = @@IDENTITY
		END
		FETCH NEXT FROM ddtcur INTO @DDTTableName
	END
	CLOSE ddtcur
	DEALLOCATE ddtcur

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter DDT Table', 'Altering table Trimming and Converting to Unicode', GETDATE(), NULL, 'Already Updated')
END
;
IF EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'DDTUnicodeModTab'
)
BEGIN
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter DDT Table', 'Dropping DDTUnicodeModTab', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	EXECUTE ('DROP TABLE DDTUnicodeModTab')

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter DDT Table', 'Dropping DDTUnicodeModTab', GETDATE(), NULL, 'Already Updated')
END
;
IF EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'DDTIndexList'
)
BEGIN
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter DDT Table', 'Dropping DDTIndexList', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	EXECUTE ('DROP TABLE DDTIndexList')

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter DDT Table', 'Dropping DDTIndexList', GETDATE(), NULL, 'Already Updated')
END
;
IF NOT EXISTS(
	SELECT 1 FROM PDBUser
	WHERE UserIndex = 1
	AND FamilyName IS NULL
	AND PersonalName = 'Supervisor'
)
BEGIN
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Update Table', 'Update PDBUser : Set FamilyName and PersonalName for supervisor', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	UPDATE PDBUser
	SET FamilyName 	= NULL,
	    PersonalName = 'Supervisor'
	WHERE UserIndex = 1

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Update Table', 'Update PDBUser : Set FamilyName and PersonalName for supervisor', GETDATE(), NULL, 'Already Updated')
END
;
BEGIN
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus VALUES ('INSERT', 'INSERTING INTO PDBRIGHTS' , GETDATE(), NULL, 'UPDATING')
	SELECT @StepNo = @@IDENTITY

	INSERT INTO PDBRIGHTS (OBJECTINDEX1, FLAG1, OBJECTINDEX2, FLAG2, ACL) 
		SELECT OBJECTINDEX1, FLAG1, OBJECTINDEX2, 'C', ACL 
	FROM PDBRIGHTS B WHERE B.OBJECTINDEX2 = 0 AND B.FLAG2 = 'F'
	AND NOT EXISTS (SELECT * FROM PDBRIGHTS C WHERE C.OBJECTINDEX1 = B.OBJECTINDEX1 
	AND C.FLAG1 = B.FLAG1 AND C.OBJECTINDEX2 = B.OBJECTINDEX2 AND C.FLAG2 = 'C')

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
;
BEGIN
	-------------------------------------------------------------------------------------------
	-- Changed By				: Sneh Lata Sharma
	-- Reason / Cause (Bug No if Any)	: Separating user and group privileges
	-- Change Description			: Separating user and group privileges
	-------------------------------------------------------------------------------------------
	SET NOCOUNT ON

	DECLARE @StepNo			int

	DECLARE @AclLen int
	DECLARE @Diff int
	DECLARE @TempUserId int
	DECLARE @TempPrivilegeControlList VARCHAR(16)
	DECLARE @NewPrivilegeControlList VARCHAR(16)
	DECLARE @TempGroupId int
	DECLARE @TempGrpPrivilegeControlList VARCHAR(16)
	DECLARE @FirstBit Char(1)
	DECLARE @SecondBit Char(1)

	DECLARE UserCur CURSOR FOR 
	SELECT UserIndex,PrivilegeControlList 
	FROM PDBUser WHERE UserIndex <> 1

	DECLARE GroupCur CURSOR FOR 
	SELECT GroupIndex,PrivilegeControlList 
	FROM PDBGroup WHERE GroupIndex NOT IN (1,2) AND LEN(PrivilegeControlList) < 11

	INSERT INTO PDBUpdateStatus values ('UPDATE', 'UPDATE PDBUser SET PrivilegeControlList' , getdate(), NULL, 'UPDATING')
	SELECT @StepNo = @@IDENTITY

	SELECT @NewPrivilegeControlList = ''
	OPEN UserCur

	FETCH NEXT FROM UserCur INTO @TempUserId,@TempPrivilegeControlList
	WHILE (@@FETCH_STATUS <> -1)
	BEGIN
		IF @@FETCH_STATUS <> -2
		BEGIN
			SELECT @AclLen = LEN(@TempPrivilegeControlList)
			SELECT @Diff = 10 - @AclLen
			WHILE( @Diff > 0)
			BEGIN
				SELECT @TempPrivilegeControlList = RTRIM(@TempPrivilegeControlList) + '0'
				SELECT @Diff = @Diff - 1
			END
			SELECT @FirstBit = SUBSTRING(@TempPrivilegeControlList,1,1)
			SELECT @SecondBit = SUBSTRING(@TempPrivilegeControlList,2,1)

			SELECT @NewPrivilegeControlList = SUBSTRING(@TempPrivilegeControlList,1,7) + '0' + @FirstBit + @SecondBit

			UPDATE PDBUSER SET PrivilegeControlList = LTRIM(RTRIM(@NewPrivilegeControlList)) WHERE UserIndex = @TempUserId
		END
		FETCH NEXT FROM UserCur INTO @TempUserId,@TempPrivilegeControlList
	END
	CLOSE UserCur
	DEALLOCATE UserCur

	UPDATE PDBUSER SET PrivilegeControlList = '1111111111000000' WHERE UserIndex = 1

	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo

	insert into PDBUpdateStatus values ('UPDATE', 'UPDATE PDBGroup SET PrivilegeControlList' , getdate(), NULL, 'UPDATING')
	SELECT @StepNo = @@IDENTITY

	OPEN GroupCur
	FETCH NEXT FROM GroupCur INTO @TempGroupId,@TempGrpPrivilegeControlList
	WHILE (@@FETCH_STATUS <> -1)
	BEGIN
		IF @@FETCH_STATUS <> -2
		BEGIN
			SELECT @AclLen = LEN(@TempGrpPrivilegeControlList)
			SELECT @Diff = 10 - @AclLen
			WHILE( @Diff > 0)
			BEGIN
				SELECT @TempGrpPrivilegeControlList = RTRIM(@TempGrpPrivilegeControlList) + '0'
				SELECT @Diff = @Diff - 1
			END
			SELECT @FirstBit = SUBSTRING(@TempGrpPrivilegeControlList,1,1)
			SELECT @SecondBit = SUBSTRING(@TempGrpPrivilegeControlList,2,1)
			
			SELECT @NewPrivilegeControlList = SUBSTRING(@TempGrpPrivilegeControlList,1,7) + '0' + @FirstBit + @SecondBit

			UPDATE PDBGROUP SET PrivilegeControlList = LTRIM(RTRIM(@NewPrivilegeControlList)) WHERE GroupIndex = @TempGroupId
		END
		FETCH NEXT FROM GroupCur INTO @TempGroupId,@TempGrpPrivilegeControlList
	END
	CLOSE GroupCur
	DEALLOCATE GroupCur

	UPDATE PDBGROUP SET PrivilegeControlList = '11111111110' WHERE GroupIndex = 2

	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
;
BEGIN
	SET NOCOUNT ON

	DECLARE @StepNo			int

	INSERT INTO PDBUpdateStatus values ('UPDATE', 'UPDATE PDBDataDefinition SET TYPE = ACT' , getdate(), NULL, 'UPDATING')
	SELECT @StepNo = @@IDENTITY
		
	UPDATE PDBDataDefinition SET TYPE = 'ACT' WHERE DATADEFNAME LIKE 'System_Action_%'
		
	UPDATE PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
;
BEGIN
	SET NOCOUNT ON
	DECLARE @StepNo			int

	insert into PDBUpdateStatus values ('UPDATE', 'UPDATE PDBDataDefinition SET TYPE = G' , getdate(), NULL, 'UPDATING')
	SELECT @StepNo = @@IDENTITY
		
	UPDATE PDBDataDefinition SET TYPE = 'G' WHERE DATADEFNAME NOT LIKE 'System_Action_%'
		
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
;
IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBCabinet'
	AND COLUMN_NAME = 'CabinetName'
	AND DATA_TYPE = 'NVARCHAR'
)
BEGIN
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBCabinet, Trimming and Converting to Unicode', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY


	DECLARE @SelectStr	varchar(8000)
	SELECT @SelectStr = 'RTRIM(CabinetName), CabinetType, CreatedDateTime, VersioningFlag, SecurityLevel, RTRIM(FtsDatabasePath) FtsDatabasePath,' +
			' CabinetLock, LockByUser, RTRIM(ACL) ACL, ImageVolumeIndex, LastFsIndex, LastDocumentIndex,' +
			' ACLMoreFlag, EnableLog, License, Encr, '

	IF EXISTS(
		SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'PDBCabinet'
		AND COLUMN_NAME = 'MaxNoOfLoginUsers'
	)
		SELECT @SelectStr = LTRIM(RTRIM(@SelectStr)) + 'MaxNoOfLoginUsers,'
	ELSE
		SELECT @SelectStr = LTRIM(RTRIM(@SelectStr)) + 'NULL,'

	IF EXISTS(
		SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'PDBCabinet'
		AND COLUMN_NAME = 'EncrLogin'
	)
		SELECT @SelectStr = LTRIM(RTRIM(@SelectStr)) + 'EncrLogin,'
	ELSE
		SELECT @SelectStr = LTRIM(RTRIM(@SelectStr)) + 'NULL,'


	SELECT @SelectStr = LTRIM(RTRIM(@SelectStr)) + 'FtsIndexingFlag,'

	IF EXISTS(
		SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'PDBCabinet'
		AND COLUMN_NAME = 'BuildVersion'
	)
		SELECT @SelectStr = LTRIM(RTRIM(@SelectStr)) + 'BuildVersion,'
	ELSE
		SELECT @SelectStr = LTRIM(RTRIM(@SelectStr)) + 'NULL,'

	IF EXISTS(
		SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'PDBCabinet'
		AND COLUMN_NAME = 'OwnerInheritance'
	)
		SELECT @SelectStr = LTRIM(RTRIM(@SelectStr)) + 'OwnerInheritance'
	ELSE
		SELECT @SelectStr = LTRIM(RTRIM(@SelectStr)) + '''N'''

	BEGIN TRANSACTION TranUniUp

	IF EXISTS(
		SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'PDBCabinet_OldTab'
	)
	BEGIN
		EXECUTE ('DROP TABLE PDBCabinet_OldTab')
		IF @@ERROR <> 0
		BEGIN
			ROLLBACK TRANSACTION TranUniUp
			RETURN
		END
	END

	EXEC sp_rename 'PDBCabinet', 'PDBCabinet_OldTab'
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRANSACTION TranUniUp
		RETURN
	END

	DECLARE @QueryStr	varchar(8000)

	SELECT @QueryStr = '
		CREATE TABLE PDBCabinet
		( 
			CabinetName		NVARCHAR(255),
			CabinetType		CHAR CONSTRAINT ck_cab_ctype check (CabinetType in (''R'',''L'', ''B'')),
			CreatedDateTime		datetime,
			VersioningFlag		CHAR CONSTRAINT ck_cab_vf check (VersioningFlag in (''N'',''Y'')),
			SecurityLevel		int CONSTRAINT ck_cab_sl check (SecurityLevel in (0,1,2)),
			FtsDatabasePath		VARCHAR(1020) NULL,
			CabinetLock		CHAR CONSTRAINT ck_cab_cl check (CabinetLock IN (''Y'',''N'')),
			LockByUser		int,
			ACL                     varchar(255) NULL,
			ImageVolumeIndex	int,
			LastFsIndex		int,
			LastDocumentIndex	int,
			ACLMoreFlag 		char null CONSTRAINT ck_cab_acl CHECK (ACLMoreFlag IN (''Y'',''N'')),
			EnableLog		CHAR(1) NULL,
			License			int NULL,
			Encr			nvarchar(255) NULL,
			MaxNoOfLoginUsers	int NULL,
			EncrLogin		nvarchar(255) NULL,
			FtsIndexingFlag 	CHAR(1) CONSTRAINT df_cab_ftsf DEFAULT ''N'',
			BuildVersion		varchar(10) NULL,
			OwnerInheritance	CHAR(1) CONSTRAINT df_cab_owni DEFAULT ''N''
		)
	'
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRANSACTION TranUniUp
		RETURN
	END
	
	EXECUTE (@QueryStr)
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRANSACTION TranUniUp
		RETURN
	END

	SELECT @QueryStr = ' INSERT INTO PDBCabinet (CabinetName, CabinetType, CreatedDateTime, VersioningFlag, SecurityLevel, FtsDatabasePath, CabinetLock, LockByUser, ACL, ImageVolumeIndex, LastFsIndex, LastDocumentIndex, ACLMoreFlag, EnableLog, License, Encr, MaxNoOfLoginUsers, EncrLogin, FtsIndexingFlag, BuildVersion , OwnerInheritance) SELECT ' + @SelectStr + ' FROM PDBCabinet_OldTab '
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRANSACTION TranUniUp
		RETURN
	END

	EXECUTE (@QueryStr)
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRANSACTION TranUniUp
		RETURN
	END

	/*IF EXISTS(
		SELECT 1 FROM PDBCabinet
		WHERE EncrLogin IS NULL
	)*/
		EXECUTE ('UPDATE PDBCabinet SET	MaxNoOfLoginUsers = License, EncrLogin = Encr FROM PDBCabinet WHERE EncrLogin IS NULL')

	IF EXISTS(
		SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'PDBCabinet_OldTab'
	)
	BEGIN
		EXECUTE ('DROP TABLE PDBCabinet_OldTab')
		IF @@ERROR <> 0
		BEGIN
			ROLLBACK TRANSACTION TranUniUp
			RETURN
		END
	END

	COMMIT TRANSACTION TranUniUp
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBCabinet, Trimming and Converting to Unicode', GETDATE(), NULL, 'Already Updated')
END