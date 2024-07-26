/******************************************************************************************************
			NEWGEN SOFTWARE TECHNOLOGIES LIMITED
Group			: Eworkstyle
Product / Project	: Java Transaction Server	
Module			: OD6.0.1
File Name		: PRTUpdateScript.sql
Author			: Shikhar Prawesh/Mili Das
Date written		: 01/05/2008
Description		: Updates Cabinets.
---------------------------------------------------------------------------
		CHANGE HISTORY
---------------------------------------------------------------------------
 16/07/2008	Vikas Dubey		Check for user Name that is already in PDBDeletedUser
 16/07/2008	Mili			New column added to Usr_0_UserPreferences for implementing Centralized RIS
 16/07/2008	Mili			Changes for FTS on Dataclass
 16/07/2008	Mili			New table added to keep details of applied patches
 21/07/2008	Mili			AuditLog Enhancement(Documents and Folders)
 19/09/2008     Shikhar			Changes for bulk operations New error code -- -50234, -50235
 22/09/2008	Rohika		        Change for user credentials
 19/09/2008	Sneh Lata		New Pick List approach implementation
 30/09/2008	Sneh 			Changes for adding audit log priviledge
 05/11/2008	Sneh 			Changes for bug correction
 06/11/2008	Mili			Changes for Audit Trail Unification
 27/11/2008	Pranay Tiwari		Changes in datatypes of variables to support larger userindex
 09/03/2009	Mili Das		Implementation of Role based Rights
 16/03/2009	Mili Das 		Changes for assigning Rights to Roles on DataClass/Cabinet
 09/06/2009	Rohika Gupta		Change for adding pickable field to Global index
 29/03/2012	Vikas Dubey		To make password configure for LowerCase/UpperCase/Numeric count
 09/04/2013	Shipra Tiwari	Changes For Upgrade with hotfix 30-32
 08/07/2013 Swati Gupta     Changes For Upgrade with hotfix 30-38
 11/09/2013 Swati Gupta     Changes For Upgrade with hotfix 39
 18/10/2013 Silky Malik     Changes for support of "OwnerType"
 26/11/2013	Yogesh Verma	Changes for Password Algorithm
 10/05/2017	Shikhar			Removed foreign key references of pdbkeyword to document table since it is eventually being dropped. Added scripts for OD 9.1
 06/02/2018 Shubham Mittal  Bugid 12311 Different Action Ids to be configured for different login failure reasons
 22/02/2018 Shubham Mittal  Bugid 12311 Included action id 691 for connection entries deleted by wrapper
 23/02/2018 Shubham Mittal  Bug 12457 Update Data class fields validation and proper error message from API
 26/02/2018  Jitendra kumar  New error coded added for * search and blank search
 26/04/2018 Chandan			 Bug 13413 - Show password policy link on admin while adding user
  13/08/2018 Shubham Mittal  Added new action ids for Password Policy changes
  31/10/2018 Shubham Mittal  Bug 14302 - Login failed from other applications after upgrading cabinet to SP2
  13/05/2019	Shivam Gupta	Bug 14655 - Provide provision to add U type DataClass and use fields of U type dataclass as additional properties for User.
  21/01/2020 Chandan Kaushik Bug 19087 Change in LDAP inactivation functionality
  18/08/2020	Sanjeev Kumar Bug ID 21331-PDBAlarm table does not upgrade properly at the time of DmniDocs Upgrade from OD 7 to OD 10.1 Patch 3 In case of MSSQL Data base
  18/08/2020	Sanjeev Kumar Bug ID 21332-While upgrade the cabinet from OmniDocs 7 to OmniDocs 10.1 patch 3 the DomainName column is not created in PDBLDAPXML table in MSSQL data base
   04/09/2020 Sanjeev Kumar    Bug ID 21379 -  Facing Some issues with Multi-Threads in TEM
    3/03/2021  Sanjeev Kumar Bug 23898 - Asterisk prefix Search client side provide in document name and folder name.
 ----------------------------------------------------------------------------
Function Name 	: PRTUpdateScript
Date written	: 01/05/2008
Author		: Shikhar Prawesh/Mili Das
Input parameter	:
Output parameter	: Return Status
Return value(Result set) :
*******************************************************************************************************/
-----------------------------------------------------------------------------
-- Changed By				: Rohika Gupta
-- Reason / Cause (Bug No if Any)	: Forceful password change on password reset from Admin/To lock a new user if not login for a specified period and To display the last login time , last login FailureTime,Number of failed login attempts to the user on successful login
-- Change Description			: New columns added in table UserSecurity
-----------------------------------------------------------------------------
IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'UserSecurity'
	AND COLUMN_NAME = 'ResetPasswordFlag')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table UserSecurity add ResetPasswordFlag', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE UserSecurity ADD ResetPasswordFlag CHAR(1) NOT NULL DEFAULT 'N' 
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table UserSecurity  add ResetPasswordFlag', getdate(), getdate(), 'ALREADY UPDATED')
	
END	
;
IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'UserSecurity'
	AND COLUMN_NAME = 'HasLoginBefore')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table UserSecurity add HasLoginBefore', getdate(), NULL, 'UPDATING')

	ALTER TABLE UserSecurity ADD HasLoginBefore CHAR(1) NOT NULL DEFAULT 'Y' 		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table UserSecurity  add HasLoginBefore', getdate(), getdate(), 'ALREADY UPDATED')
END	
;
IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'UserSecurity'
	AND COLUMN_NAME = 'LastLoginTime')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table UserSecurity add LastLoginTime', getdate(), NULL, 'UPDATING')

	ALTER TABLE UserSecurity ADD LastLoginTime DATETIME
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table UserSecurity  add LastLoginTime', getdate(), getdate(), 'ALREADY UPDATED')
END	
;
IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'UserSecurity'
	AND COLUMN_NAME = 'LastLoginFaliureTime')
BEGIN

	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table UserSecurity add LastLoginFaliureTime', getdate(), NULL, 'UPDATING')

	ALTER TABLE UserSecurity ADD LastLoginFaliureTime DATETIME
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0	
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table UserSecurity  add LastLoginFaliureTime', getdate(), getdate(), 'ALREADY UPDATED')
END	
;
IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'UserSecurity'
	AND COLUMN_NAME = 'FailureAttemptCount')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table UserSecurity add FailureAttemptCount', getdate(), NULL, 'UPDATING')

	ALTER TABLE UserSecurity ADD FailureAttemptCount INT NOT NULL DEFAULT 0
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table UserSecurity  add FailureAttemptCount', getdate(), getdate(), 'ALREADY UPDATED')
END	
;
IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'UserSecurity'
	AND COLUMN_NAME = 'LastUnlockTime')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table UserSecurity add LastUnlockTime', getdate(), NULL, 'UPDATING')

	ALTER TABLE UserSecurity ADD LastUnlockTime DATETIME NULL
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table UserSecurity  add LastUnlockTime', getdate(), getdate(), 'ALREADY UPDATED')
END	
;

IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'UserSecurity'
	AND COLUMN_NAME = 'LastLogoutTime')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table UserSecurity add LastLogoutTime', getdate(), NULL, 'UPDATING')

	ALTER TABLE UserSecurity ADD LastLogoutTime DATETIME NULL
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table UserSecurity  add LastLogoutTime', getdate(), getdate(), 'ALREADY UPDATED')
END	
;

IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'UserSecurity'
	AND COLUMN_NAME = 'PasswordSaltOrKeyHistory')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table UserSecurity add PasswordSaltOrKeyHistory', getdate(), NULL, 'UPDATING')

	ALTER TABLE UserSecurity ADD PasswordSaltOrKeyHistory  NVARCHAR(4000) NULL
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table UserSecurity  add PasswordSaltOrKeyHistory', getdate(), getdate(), 'ALREADY UPDATED')
END	
;

IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'UserSecurity'
	AND COLUMN_NAME = 'UserType')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table UserSecurity add UserType', getdate(), NULL, 'UPDATING')

	ALTER TABLE UserSecurity ADD UserType  CHAR(1) NOT NULL DEFAULT 'U'
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table UserSecurity  add UserType', getdate(), getdate(), 'ALREADY UPDATED')
END	
;

-----------------------------------------------------------------------------------------------
-- Changed By				: Rohika Gupta
-- Reason / Cause (Bug No if Any)	: To lock a new user if not login for a specified period 
-- Change Description			: New column added in PDBUserConfig 
-----------------------------------------------------------------------------------------------
IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUserConfig'
	AND COLUMN_NAME = 'PasswordDisable')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUserConfig add PasswordDisable', getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBUSERCONFIG ADD PasswordDisable CHAR(1) CONSTRAINT df_Usrconfig_pwdDisable DEFAULT 'N' NOT NULL

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUserConfig  add PasswordDisable', getdate(), getdate(), 'ALREADY UPDATED')
END	
;
IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUserConfig'
	AND COLUMN_NAME = 'PasswordDisableTime')
BEGIN

	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUserConfig add PasswordDisableTime', getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBUSERCONFIG
		ADD PasswordDisableTime INT 

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUserConfig  add PasswordDisableTime', getdate(), getdate(), 'ALREADY UPDATED')
END	
;
IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUserConfig'
	AND COLUMN_NAME = 'DisableIdleUser')
BEGIN

	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUserConfig add DisableIdleUser', getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBUSERCONFIG ADD DisableIdleUser CHAR(1) CONSTRAINT df_Usrconfig_DisableIdleUser DEFAULT 'N' NOT NULL

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUserConfig  add DisableIdleUser', getdate(), getdate(), 'ALREADY UPDATED')
END	
;
IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUserConfig'
	AND COLUMN_NAME = 'LoginPeriod')
BEGIN

	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUserConfig add LoginPeriod', getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBUSERCONFIG ADD LoginPeriod INT 

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUserConfig  add LoginPeriod', getdate(), getdate(), 'ALREADY UPDATED')
END	
;

IF NOT EXISTS(
	SELECT  1 FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBUserConfig')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBUserConfig') AND NAME = 'PasswordDisable')
	AND	XTYPE = 'D'
)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	
	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUserConfig ADD Default constraint to PasswordDisable column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	ALTER TABLE PDBUSERCONFIG ADD CONSTRAINT DEF_PDBUserConfig_PasswordDisable DEFAULT ('N') FOR PasswordDisable
	IF EXISTS(
		SELECT 1 FROM PDBUSERCONFIG WHERE PasswordDisable IS NULL)
	BEGIN
		UPDATE PDBUSERCONFIG SET PasswordDisable = 0	
	END

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUserConfig ADD Default constraint to PasswordDisable column', GETDATE(), NULL, 'Already Updated')
END
;
-----------------------------------------------------------------------------------------------
-- Changed By				: Rohika Gupta
-- Reason / Cause (Bug No if Any)	: Change for user credentials
-- Change Description			: New column added in PDBUserConfig 
-----------------------------------------------------------------------------------------------
IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUserConfig'
	AND COLUMN_NAME = 'AutoPassword')
BEGIN
	SELECT 1	
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUserConfig add AutoPassword', getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBUSERCONFIG
		ADD AutoPassword CHAR(1) NULL

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUserConfig  add AutoPassword', getdate(), getdate(), 'ALREADY UPDATED')
END	
;
IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'Usr_0_UserPreferences'
	AND COLUMN_NAME = 'DoclistSortPreferences')
BEGIN

	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table Usr_0_UserPreferences add DoclistSortPreferences', getdate(), NULL, 'UPDATING')

	ALTER TABLE Usr_0_UserPreferences
		ADD DoclistSortPreferences varchar(10) 

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table Usr_0_UserPreferences  add DoclistSortPreferences', getdate(), getdate(), 'ALREADY UPDATED')
END	
;
-----------------------------------------------------------------------------------------------
-- Changed By				: Mili
-- Reason / Cause (Bug No if Any)	: New column added to Usr_0_UserPreferences for implementing Centralized RIS
-- Change Description			: New column added to Usr_0_UserPreferences for implementing Centralized RIS
-----------------------------------------------------------------------------------------------
IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'Usr_0_UserPreferences'
	AND COLUMN_NAME = 'SiteId')
BEGIN

	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table Usr_0_UserPreferences add SiteId', getdate(), NULL, 'UPDATING')

	ALTER TABLE Usr_0_UserPreferences
		ADD SiteId INT NOT NULL CONSTRAINT df_UsrPref_SiteId DEFAULT 1

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table Usr_0_UserPreferences add SiteId', getdate(), getdate(), 'ALREADY UPDATED')
END	
;
--------------------------------------------------------------------------------- 
-- Changed By						: Jitendra kumar
-- Reason / Cause (Bug No if Any)	: Changes for null values for SITEID column in USR_0_USERPREFERENCES
-- Change Description				: Changes for null values for SITEID column in USR_0_USERPREFERENCES
----------------------------------------------------------------------------- 

IF EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'Usr_0_UserPreferences'
	AND COLUMN_NAME = 'SiteId')
BEGIN
		SELECT 1
		declare @stepNo int
		insert into PDBUpdateStatus values ('Update Table','UPDATING TABLE USR_0_USERPREFERENCES ( SETTING DEFAULT SITEID=1 FOR NULL VALUES )', getdate(), NULL, 'UPDATING')

		EXECUTE ('UPDATE USR_0_USERPREFERENCES SET SITEID = 1 WHERE ISNULL (SITEID, -1) = -1')
		select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
		update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END	
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Update Table', 'UPDATING TABLE USR_0_USERPREFERENCES ( SETTING DEFAULT SITEID=1 FOR NULL VALUES )', getdate(), getdate(), 'ALREADY UPDATED')
END;

-----------------------------------------------------------------------------------------------
-- Changed By				: Vikas Dubey
-- Reason / Cause (Bug No if Any)	: Check for user Name that is already in PDBDeletedUser
-- Change Description			: Check for user Name that is already in PDBDeletedUser
-----------------------------------------------------------------------------------------------
IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'PDBDeletedUser')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBDeletedUser' , getdate(), NULL, 'UPDATING')
	
	
	CREATE TABLE PDBDeletedUser( 
                            UserIndex int,
                            UserName nvarchar(64)
                            )		
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBDeletedUser' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
-------------------------------------------------------------------------------------------
-- Changed By				: Mili Das
-- Reason / Cause (Bug No if Any)	: Changes for FTS on Dataclass
-- Change Description			: Changes for FTS on Dataclass
-------------------------------------------------------------------------------------------
IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'PDBJOBS')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBJobs' , getdate(), NULL, 'UPDATING')
		
	CREATE TABLE PDBJobs
			(
				JobId		INT IDENTITY(1,1) NOT NULL,
				JobName		NVARCHAR(64) NOT NULL,
				RepeatType	CHAR(1) NOT NULL,
				RepeatInterval	INT NOT NULL,
				JobType		INT NOT NULL,
				CONSTRAINT   uk_JobId UNIQUE(JobId),
				CONSTRAINT   uk_JobName UNIQUE(JobName)
			)
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBJobs' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
-----------------------------------------------------------------------------------------------
-- Changed By				: Mili 
-- Reason / Cause (Bug No if Any)	: New table added to keep details of applied patches
-- Change Description			: New table added to keep details of applied patches
-----------------------------------------------------------------------------------------------
IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'PDBPatchDetails')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBPatchDetails' , getdate(), NULL, 'UPDATING')
		
	CREATE TABLE PDBPatchDetails
			(	PatchId			int IDENTITY(1,1),
				PatchName		nvarchar(64),
				PatchReleasedDate	DATETIME,
				PatchApplicationDate	DATETIME,
				PatchContents		nvarchar(1000),
				PatchDescription	nvarchar(1000)
			)
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBPatchDetails' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
-----------------------------------------------------------------------------------------------
-- Changed By				: Shikhar
-- Reason / Cause (Bug No if Any)	: New table added for bulk operations
-- Change Description			: New table added for bulk operations
-----------------------------------------------------------------------------------------------
IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'PDBBulkOperationInfo')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBBulkOperationInfo' , getdate(), NULL, 'UPDATING')
		
	CREATE TABLE PDBBulkOperationInfo
	(
		BulkOperationId	int	IDENTITY(1,1) CONSTRAINT pk_bulkId PRIMARY KEY,
		LoginUserIndex	int,
		OperationType	smallint,
		ObjectIndex	int,
		Criteria	varchar(4000) NULL,
		OrderNo		int CONSTRAINT uk_bulkId UNIQUE,
		Active		char(1)	--N,Y only one will be Y
	)
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBBulkOperationInfo' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
-----------------------------------------------------------------------------------------------
-- Changed By				: Shikhar
-- Reason / Cause (Bug No if Any)	: New table added for bulk operations
-- Change Description			: New table added for bulk operations
-----------------------------------------------------------------------------------------------
IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'PDBSchedJob')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBSchedJob' , getdate(), NULL, 'UPDATING')
		
	CREATE TABLE PDBSchedJob(
		ConId	int,
		AccessDateTime	datetime
	)
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBSchedJob' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
-----------------------------------------------------------------------------------------------
-- Changed By				: Shikhar
-- Reason / Cause (Bug No if Any)	: Change for bulk operations
-- Change Description			: New column added to PDBUser
-----------------------------------------------------------------------------------------------
IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUser'
	AND COLUMN_NAME = 'InboxFolderIndex')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUser add InboxFolderIndex', getdate(), NULL, 'UPDATING')
		
	ALTER TABLE PDBUser ADD InboxFolderIndex INT NULL
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUser add InboxFolderIndex', getdate(), getdate(), 'ALREADY UPDATED')
END
;
-----------------------------------------------------------------------------------------------
-- Changed By				: Shikhar
-- Reason / Cause (Bug No if Any)	: Change for bulk operations
-- Change Description			: New column added to PDBUser
-----------------------------------------------------------------------------------------------
IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUser'
	AND COLUMN_NAME = 'SentItemFolderIndex')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUser add SentItemFolderIndex', getdate(), NULL, 'UPDATING')
		
	ALTER TABLE PDBUser ADD SentItemFolderIndex INT NULL
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUser add SentItemFolderIndex', getdate(), getdate(), 'ALREADY UPDATED')
END
;
-----------------------------------------------------------------------------------------------
-- Changed By				: Shikhar
-- Reason / Cause (Bug No if Any)	: Change for bulk operations
-- Change Description			: New column added to PDBUser
-----------------------------------------------------------------------------------------------
IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUser'
	AND COLUMN_NAME = 'TrashFolderIndex')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUser add TrashFolderIndex', getdate(), NULL, 'UPDATING')
		
	ALTER TABLE PDBUser ADD TrashFolderIndex INT NULL
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUser add TrashFolderIndex', getdate(), getdate(), 'ALREADY UPDATED')
END
;
-----------------------------------------------------------------------------------------------
-- Changed By				: Shikhar
-- Reason / Cause (Bug No if Any)	: Change for bulk operations
-- Change Description			: New column added to PDBUser
-----------------------------------------------------------------------------------------------
IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUser'
	AND COLUMN_NAME = 'AttachmentFolderIndex')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUser add AttachmentFolderIndex', getdate(), NULL, 'UPDATING')
		
	ALTER TABLE PDBUser ADD AttachmentFolderIndex INT NULL
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUser add AttachmentFolderIndex', getdate(), getdate(), 'ALREADY UPDATED')
END
;
-----------------------------------------------------------------------------------------------
-- Changed By				: Shikhar
-- Reason / Cause (Bug No if Any)	: Change for bulk operations
-- Change Description			: New column added to PDBUser
-----------------------------------------------------------------------------------------------
IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUser'
	AND COLUMN_NAME = 'DeletedFlag')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUser add DeletedFlag', getdate(), NULL, 'UPDATING')
		
	ALTER TABLE PDBUser ADD DeletedFlag CHAR(1) NOT NULL CONSTRAINT ck_user_deletedflag  CHECK (DeletedFlag IN ('Y','N')) CONSTRAINT df_user_deletedflag DEFAULT 'N'

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUser add DeletedFlag', getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUser'
	AND COLUMN_NAME = 'PasswordSaltOrKey')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUser add PasswordSaltOrKey', getdate(), NULL, 'UPDATING')
		
	ALTER TABLE PDBUser ADD PasswordSaltOrKey NVARCHAR(255) NULL

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUser add PasswordSaltOrKey', getdate(), getdate(), 'ALREADY UPDATED')
END
;

-----------------------------------------------------------------------------------------------
-- Changed By				: Shikhar
-- Reason / Cause (Bug No if Any)	: Change for bulk operations
-- Change Description			: Fill InboxFolderIndex column
-----------------------------------------------------------------------------------------------
IF EXISTS( SELECT 1 FROM PDBUser WHERE InboxFolderIndex IS NULL)
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('UPDATE Table', 'UPDATE  Table PDBUser Fill InboxFolderIndex column', getdate(), NULL, 'UPDATING')
		
	UPDATE PDBUSER 
	SET InboxFolderIndex   = (SELECT FolderIndex FROM PDBFolder 
				WHERE ParentFolderIndex = 3 
				AND Name = 'USER_INBOX_' + USERNAME)

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('UPDATE Table', 'UPDATE  Table PDBUser Fill InboxFolderIndex column', getdate(), getdate(), 'ALREADY UPDATED')
END
;
-----------------------------------------------------------------------------------------------
-- Changed By				: Shikhar
-- Reason / Cause (Bug No if Any)	: Change for bulk operations
-- Change Description			: Fill SentItemFolderIndex column
-----------------------------------------------------------------------------------------------
IF EXISTS( SELECT 1 FROM PDBUser WHERE SentItemFolderIndex IS NULL)
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('UPDATE Table', 'UPDATE  Table PDBUser Fill SentItemFolderIndex column', getdate(), NULL, 'UPDATING')
		
	UPDATE PDBUSER 
	SET SentItemFolderIndex   = (SELECT FolderIndex FROM PDBFolder 
				WHERE ParentFolderIndex = 4
				AND Name = 'USER_SENTITEM_' + USERNAME)

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('UPDATE Table', 'UPDATE  Table PDBUser Fill SentItemFolderIndex column', getdate(), getdate(), 'ALREADY UPDATED')
END
;
-----------------------------------------------------------------------------------------------
-- Changed By				: Shikhar
-- Reason / Cause (Bug No if Any)	: Change for bulk operations
-- Change Description			: Fill TrashFolderIndex column
-----------------------------------------------------------------------------------------------
IF EXISTS( SELECT 1 FROM PDBUser WHERE TrashFolderIndex IS NULL)
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('UPDATE Table', 'UPDATE  Table PDBUser Fill TrashFolderIndex column', getdate(), NULL, 'UPDATING')
		
	UPDATE PDBUSER 
	SET TrashFolderIndex   = (SELECT FolderIndex FROM PDBFolder 
				WHERE ParentFolderIndex = 5
				AND Name = 'USER_TRASH_' + USERNAME)

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('UPDATE Table', 'UPDATE  Table PDBUser Fill TrashFolderIndex column', getdate(), getdate(), 'ALREADY UPDATED')
END
;
-----------------------------------------------------------------------------------------------
-- Changed By				: Shikhar
-- Reason / Cause (Bug No if Any)	: Change for bulk operations
-- Change Description			: Fill AttachmentFolderIndex column
-----------------------------------------------------------------------------------------------
IF EXISTS( SELECT 1 FROM PDBUser WHERE AttachmentFolderIndex IS NULL)
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('UPDATE Table', 'UPDATE  Table PDBUser Fill AttachmentFolderIndex column', getdate(), NULL, 'UPDATING')
		
	UPDATE PDBUSER 
	SET AttachmentFolderIndex   = (SELECT FolderIndex FROM PDBFolder 
				WHERE ParentFolderIndex = 2
				AND Name = 'USER_ATTACHMENT_' + USERNAME)

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('UPDATE Table', 'UPDATE  Table PDBUser Fill AttachmentFolderIndex column', getdate(), getdate(), 'ALREADY UPDATED')
END
;
-----------------------------------------------------------------------------------------------
-- Changed By				: Sneh Lata  
-- Reason / Cause (Bug No if Any)	: New Pick List approach implementation
-- Change Description			: New table PDBPickList created  
-----------------------------------------------------------------------------------------------
IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'PDBPickList')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBPickList' , getdate(), NULL, 'UPDATING')
		
	CREATE TABLE PDBPickList
	(
		PickListIndex 			INT IDENTITY(1,1) CONSTRAINT pk_pickListId PRIMARY KEY,
		ACL 					VARCHAR(255) NULL,
		ACLMoreFlag 			CHAR(1) NOT NULL CONSTRAINT ck_picklist_aclmflag CHECK (ACLMoreFlag IN ('Y','N')) DEFAULT 'N',	
		DataFieldIndex			int not null,
		FieldValue				NVARCHAR(255) NULL,
		CONSTRAINT uk_FieldIdValue   UNIQUE (DataFieldIndex, FieldValue)
	)

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo

	CREATE NONCLUSTERED INDEX IDX_DataFieldIndex ON PDBPickList (DataFieldIndex)
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBPickList' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
------------------------------------------------------------------------------------------------
-- Changed By				: Mili Das 
-- Reason / Cause (Bug No if Any)	: Implementation of Maker Checker Feature
-- Change Description			: New Maker Checker actions added to PDBAuditAction
------------------------------------------------------------------------------------------------
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 601)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 601' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (601, 'C', 'Request to Create User', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 601' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 602)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 602' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (602, 'C', 'Create User Request Accepted', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 601' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 603)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 603' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (603, 'C', 'Create User Request Rejected', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 603' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 604)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 604' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (604, 'C', 'Create User Failed', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 604' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 605)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 605' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (605, 'C', 'Request to Delete User', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 605' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 606)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 606' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (606, 'C', 'Delete User Request Accepted', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 606' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 607)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 607' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (607, 'C', 'Delete User Request Rejected', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 607' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 608)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 608' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (608, 'C', 'Delete User Failed', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 608' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 609)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 609' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (609, 'C', 'Request to Modify User Properties', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 609' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 610)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 610' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (610, 'C', 'Request to Modify User Properties Accepted', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 610' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 611)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 611' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (611, 'C', 'Request to Modify User Properties Rejected', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 611' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 612)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 612' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (612, 'C', 'Modify User Properties Failed', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 612' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 613)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 613' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (613, 'C', 'Request to Create Group', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 613' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 614)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 614' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (614, 'C', 'Create Group Request Accepted', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 614' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 615)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 615' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (615, 'C', 'Create Group Request Rejected', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 615' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 616)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 616' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (616, 'C', 'Create Group Failed', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 616' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 617)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 617' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (617, 'C', 'Request to Delete Group', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 617' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 618)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 618' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (618, 'C', 'Delete Group Request Accepted', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 618' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 619)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 619' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (619, 'C', 'Delete Group Request Rejected', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 619' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 620)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 620' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (620, 'C', 'Delete Group Failed', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 620' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 621)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 621' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (621, 'C', 'Request to Modify Group Properties', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 621' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 622)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 622' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (622, 'C', 'Request to Modify Group Properties Accepted', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 622' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 623)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 623' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (623, 'C', 'Request to Modify Group Properties Rejected', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 623' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 624)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 624' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (624, 'C', 'Modify Group Properties Failed', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 624' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 625)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 625' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (625, 'C', 'Request to Delete User From Group', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 625' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 626)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 626' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (626, 'C', 'Request to Delete User From Group Accepted', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 626' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 627)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 627' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (627, 'C', 'Request to Delete User From Group Rejected', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 627' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 628)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 628' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (628, 'C', 'Delete User From Group Failed', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 628' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 629)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 629' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (629, 'C', 'Request to Add User To Group', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 629' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 630)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 630' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (630, 'C', 'Request to Add User To Group Accepted', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 630' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 631)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 631' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (631, 'C', 'Request to Add User To Group Rejected', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 631' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 632)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 632' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (632, 'C', 'Add User To Group Failed', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 632' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
---------------------------------------------------------------------------------
-- Changed By				: Mili Das
-- Reason / Cause (Bug No if Any)	: Changes for Audit Trail Unification
-- Change Description			: Extra actions added for application log
---------------------------------------------------------------------------------
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 633)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 633' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (633, 'F', 'Lock Folder', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 633' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 634)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 634' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (634, 'F', 'Unlock Folder', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 634' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 635)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 635' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (635, 'F', 'Associate DataDefinition with folder', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 635' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 636)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 636' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (636, 'F', 'Dissociate DataDefinition from folder', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 636' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 637)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 637' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (637, 'F', 'Set Data Def values on Folder', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 637' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 638)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 638' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (638, 'F', 'Set Rights on Folder', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 638' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 639)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 639' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (639, 'F', 'Revoke Rights from Folder', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 639' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 640)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 640' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (640, 'F', 'Move Folder reference', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 640' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 641)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 641' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (641, 'D', 'Lock Document', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 641' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 642)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 642' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (642, 'D', 'Unlock Document', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 642' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 643)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 643' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (643, 'D', 'Associate DataDefinition with Document', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 643' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 644)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 644' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (644, 'D', 'Dissociate DataDefinition from Document', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 644' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 645)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 645' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (645, 'D', 'Set Data Def values on Document', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 645' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 646)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 646' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (646, 'D', 'Set Rights on Document', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 646' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 647)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 647' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (647, 'D', 'Revoke Rights from Document', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 647' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 648)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 648' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (648, 'D', 'Move Document reference', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 648' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 649)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 649' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (649, 'D', 'Change Version Comment', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 649' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 650)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 650' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (650, 'D', 'Associate Index With Doc', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 650' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 651)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 651' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (651, 'D', 'Change Index Value', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 651' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 652)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 652' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (652, 'D', 'Disassociate Index from Doc', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 652' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 653)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 653' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (653, 'D', 'Add Keyword With Document', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 653' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 654)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 654' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (654, 'D', 'Delete Keywords From Document', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 654' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 655)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 655' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (655, 'D', 'Reshuffle Docs', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 655' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 656)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 656' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (656, 'D', 'Set Attachment', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 656' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 657)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 657' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (657, 'D', 'Delete Attachment', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 657' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 658)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 658' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (658, 'D', 'Change Attachment Name', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 658' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 659)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 659' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (659, 'C', 'Register Form', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 659' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 660)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 660' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (660, 'C', 'Delete Form', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 660' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 661)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 661' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (661, 'C', 'Change Form File', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 661' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 662)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 662' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (662, 'C', 'Set Form Prop', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 662' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 663)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 663' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (663, 'C', 'Set Data Def values on User', 'Y' , NULL)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 663' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

-------------------------------------------------------------------------------------------
-- Changed By				: Mili Das
-- Reason / Cause (Bug No if Any)	: Implementation of Maker Checker feature
-- Change Description			: New constants added in PDBConstant
-------------------------------------------------------------------------------------------
BEGIN
	SELECT 0
	declare @stepNo int

	IF NOT EXISTS(SELECT id FROM PDBConstant WHERE id = -50226)
	BEGIN
		
		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(-50226)', getdate(), NULL, 'UPDATING')

		INSERT INTO PDBConstant VALUES(-50226, 'PRT_ERR_Maker_Checker_Are_Same', 'Error')
		
		select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
		update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
	END 
	ELSE
	BEGIN
		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(-50226)', getdate(), getdate(), 'ALREADY UPDATED')
	END

	IF NOT EXISTS(SELECT id FROM PDBConstant WHERE id = -50227)
	BEGIN

		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(-50227)', getdate(), NULL, 'UPDATING')

		INSERT INTO PDBConstant VALUES(-50227, 'PRT_ERR_Reject_Comments_Not_Given', 'Error')

		select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
		update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo

	END 
	ELSE
	BEGIN
		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(-50227)', getdate(), getdate(), 'ALREADY UPDATED')
	END

	IF NOT EXISTS(SELECT id FROM PDBConstant WHERE id = -50228)
	BEGIN

		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(-50228)', getdate(), NULL, 'UPDATING')

		INSERT INTO PDBConstant VALUES(-50228, 'PRT_ERR_Request_Not_Exists', 'Error')

		select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
		update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo

	END 
	ELSE
	BEGIN
		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(-50228)', getdate(), getdate(), 'ALREADY UPDATED')
	END

	IF NOT EXISTS(SELECT id FROM PDBConstant WHERE id = -50229)
	BEGIN

		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(-50229)', getdate(), NULL, 'UPDATING')

		INSERT INTO PDBConstant VALUES(-50229, 'PRT_ERR_Req_Not_Found_For_User', 'Error')

		select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
		update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo

	END 
	ELSE
	BEGIN
		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(-50229)', getdate(), getdate(), 'ALREADY UPDATED')
	END

	IF NOT EXISTS(SELECT id FROM PDBConstant WHERE id = -50230)
	BEGIN

		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(-50230)', getdate(), NULL, 'UPDATING')

		INSERT INTO PDBConstant VALUES(-50230,'PRT_ERR_Cant_Approve_Own_Request','Error')

		select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
		update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo

	END 
	ELSE
	BEGIN
		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(-50230)', getdate(), getdate(), 'ALREADY UPDATED')
	END

	IF NOT EXISTS(SELECT id FROM PDBConstant WHERE id = 50023)
	BEGIN

		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(50023)', getdate(), NULL, 'UPDATING')

		INSERT INTO PDBConstant VALUES(50023, 'PRT_WARN_Not_All_Requests_Deleted', 'Warning')

		select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
		update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo

	END 
	ELSE
	BEGIN
		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(50023)', getdate(), getdate(), 'ALREADY UPDATED')
	END

	--Added for SOX compliance
	IF NOT EXISTS(SELECT id FROM PDBConstant WHERE id = -50231)
	BEGIN

		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(-50231)', getdate(), NULL, 'UPDATING')

		INSERT INTO PDBConstant VALUES(-50231,'PRT_ERR_User_Login_Period_Expired','Error')
		
		select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
		update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
	END 
	ELSE
	BEGIN
		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(-50231)', getdate(), getdate(), 'ALREADY UPDATED')
	END

	--Added for logical deletion of user
	IF NOT EXISTS(SELECT id FROM PDBConstant WHERE id = -50232)
	BEGIN
		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(-50232)', getdate(), NULL, 'UPDATING')

		INSERT INTO PDBConstant VALUES(-50232,'PRT_ERR_User_Already_Deleted','Error')

		select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
		update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
	END 
	ELSE
	BEGIN
		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(-50232)', getdate(), getdate(), 'ALREADY UPDATED')
	END
	 --Added for implementing FTS on Dataclass

	IF NOT EXISTS(SELECT id FROM PDBConstant WHERE id = -50233)
	BEGIN

		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(-50233)', getdate(), NULL, 'UPDATING')

		INSERT INTO PDBConstant VALUES(-50233,'PRT_ERR_Job_Not_Found','Error')

		select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
		update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo

	END 
	ELSE
	BEGIN
		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(-50233)', getdate(), getdate(), 'ALREADY UPDATED')
	END

END
;
-------------------------------------------------------------------------------------------
-- Changed By				: Shikhar
-- Reason / Cause (Bug No if Any)	: Changes for bulk operations
-- Change Description			: New constants added in PDBConstant
-------------------------------------------------------------------------------------------
BEGIN
	SELECT 0
	declare @stepNo int
	IF NOT EXISTS(SELECT id FROM PDBConstant WHERE id = -50234)
	  
	  BEGIN

		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(-50234)', getdate(), NULL, 'UPDATING')

		INSERT INTO PDBConstant VALUES(-50234,'PRT_ERR_User_Marked_For_Delete','Error')
		
		select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
		update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
	 END 
		ELSE
	 BEGIN
		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(-50234)', getdate(), getdate(), 'ALREADY UPDATED')
	 END
 --Added for implementing FTS on Dataclass

	IF NOT EXISTS(SELECT id FROM PDBConstant WHERE id = -50235)
	  
	  BEGIN

		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(-50235)', getdate(), NULL, 'UPDATING')

		INSERT INTO PDBConstant VALUES(-50235,'PRT_ERR_Target_User_Marked_For_Delete','Error')
		
		select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
		update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
	 END 
		ELSE
	 BEGIN
		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(-50235)', getdate(), getdate(), 'ALREADY UPDATED')
	 END


END
;
BEGIN
	SELECT 0
	declare @stepNo int
	IF NOT EXISTS(SELECT id FROM PDBConstant WHERE id = -50236)
  
	BEGIN
		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(-50236)', getdate(), NULL, 'UPDATING')
		INSERT INTO PDBConstant VALUES(-50236,'PRT_ERR_FieldValue_Not_Exist','Error')
		
		select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
		update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
	END 
	ELSE
	BEGIN
		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(-50236)', getdate(), getdate(), 'ALREADY UPDATED')
	END	
END
;
-------------------------------------------------------------------------------------------
-- Changed By				: Mili Das
-- Reason / Cause (Bug No if Any)	: Implementation of Role based Rights
-- Change Description			: Implementation of Role based Rights
-------------------------------------------------------------------------------------------
BEGIN
	 SELECT 0
	 declare @stepNo int
	 IF NOT EXISTS(SELECT id FROM PDBConstant WHERE id = -50237)
		  
	 BEGIN

		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(-50237)', getdate(), NULL, 'UPDATING')

		INSERT INTO PDBConstant VALUES(-50237,'PRT_ERR_Grp_Associated_With_Role','Error')
		
		select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
		update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
	 END 
	 ELSE
	 BEGIN
		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(-50237)', getdate(), getdate(), 'ALREADY UPDATED')
	 END

	 IF NOT EXISTS(SELECT id FROM PDBConstant WHERE id = -50238)
	  
	 BEGIN

		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(-50238)', getdate(), NULL, 'UPDATING')

		INSERT INTO PDBConstant VALUES(-50238,'PRT_ERR_Grp_NotAsso_With_Role','Error')
		
		select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
		update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
	 END 
	 ELSE
	 BEGIN
		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(-50238)', getdate(), getdate(), 'ALREADY UPDATED')
	 END

	 IF NOT EXISTS(SELECT id FROM PDBConstant WHERE id = -50239)
	  
	 BEGIN

		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(-50239)', getdate(), NULL, 'UPDATING')

		INSERT INTO PDBConstant VALUES(-50239,'PRT_ERR_Cant_Assign_Role_ToAdmGrp','Error')
		
		select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
		update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
	 END 
	 ELSE
	 BEGIN
		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(-50239)', getdate(), getdate(), 'ALREADY UPDATED')
	 END
END
;
-------------------------------------------------------------------------------------------
-- Changed By				: Mili Das
-- Reason / Cause (Bug No if Any)	: Implementation of Maker Checker feature
-- Change Description			: New Table: PDBmakerCheckerInfo created
-------------------------------------------------------------------------------------------
IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'PDBMakerCheckerInfo')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBMakerCheckerInfo' , getdate(), NULL, 'UPDATING')
	
	CREATE TABLE PDBMakerCheckerInfo
		(
			ActionId	       int
			IDENTITY(1,1) CONSTRAINT   pk_actionidind      PRIMARY KEY  Clustered,
			OperationId		smallint,
			OperationXML		ntext null,
			MakerId			int,
			CheckerId		int NULL,
			Comments		nvarchar(255) NULL,
			Status			char CONSTRAINT ck_MCInfo_status CHECK (Status IN ('P','A','R','F')),
			RequestDatetime		datetime,
			ActionDatetime		datetime null,
			UserIndex		ntext null,
			UserName		ntext null,
			GroupIndex		ntext null,
			GroupName		ntext null,
			RoleIndex		ntext null,
			RoleName		ntext null
		)
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBMakerCheckerInfo' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
-------------------------------------------------------------------------------------------
-- Changed By				: Mili Das
-- Reason / Cause (Bug No if Any)	: Implementation of Maker Checker feature
-- Change Description			: New column added in PDBLicense
-------------------------------------------------------------------------------------------
IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBLicense'
	AND COLUMN_NAME = 'IsMakerCheckerEnabled')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBLicense add IsMakerCheckerEnabled', getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBLICENSE ADD IsMakerCheckerEnabled CHAR(1) DEFAULT 'N' NOT NULL
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBLicense  add IsMakerCheckerEnabled', getdate(), getdate(), 'ALREADY UPDATED')
END
;
-------------------------------------------------------------------------------------------
-- Changed By				: Mili Das
-- Reason / Cause (Bug No if Any)	: Changes for FTS on Dataclass
-- Change Description			: Changes for FTS on Dataclass
-------------------------------------------------------------------------------------------
IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBLicense'
	AND COLUMN_NAME = 'DDTFTS')
BEGIN

	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBLicense add DDTFTS', getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBLICENSE ADD DDTFTS CHAR(1) DEFAULT 'N' NOT NULL
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBLicense  add DDTFTS', getdate(), getdate(), 'ALREADY UPDATED')
END
;
IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBLicense'
	AND COLUMN_NAME = 'STYPELOGOUT')
BEGIN

	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBLicense add STypeLogout ', getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBLICENSE ADD STypeLogout  CHAR(1) DEFAULT 'N' NOT NULL
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBLicense  add STypeLogOut', getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBLicense'
	AND COLUMN_NAME = 'PasswordAlgorithm')
BEGIN

	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBLicense add PasswordAlgorithm', getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBLICENSE ADD PasswordAlgorithm NVARCHAR(255) NULL
	EXECUTE('UPDATE PDBLICENSE SET PasswordAlgorithm = ''PC1''')
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBLicense add PasswordAlgorithm', getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBLicense'
	AND COLUMN_NAME = 'PasswordAlgorithm')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Update Table', 'UPDATINGING TABLE PDBLICENSE (SET PC1 PasswordAlgorithm )', getdate(), NULL, 'UPDATING')
	
	EXECUTE('UPDATE PDBLICENSE SET PasswordAlgorithm = ''PC1''  WHERE ISNULL (PasswordAlgorithm, -1) = -1')
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('update Table', 'Update Table PDBLicense add PasswordAlgorithm', getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBLicense'
	AND COLUMN_NAME = 'MaxNoOfExternalPortalUsers')
BEGIN

	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBLicense add MaxNoOfExternalPortalUsers', getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBLicense ADD MaxNoOfExternalPortalUsers INT
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBLicense add MaxNoOfExternalPortalUsers', getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBLicense'
	AND COLUMN_NAME = 'EncrExternalPortalUsers')
BEGIN

	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBLicense add EncrExternalPortalUsers', getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBLicense ADD EncrExternalPortalUsers NVARCHAR(64)
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBLicense add EncrExternalPortalUsers', getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBLicense'
	AND COLUMN_NAME = 'MaxNoOfInternalPortalUsers')
BEGIN

	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBLicense add MaxNoOfInternalPortalUsers', getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBLicense ADD MaxNoOfInternalPortalUsers INT
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBLicense add MaxNoOfInternalPortalUsers', getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBLicense'
	AND COLUMN_NAME = 'EncrInternalPortalUsers')
BEGIN

	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBLicense add EncrInternalPortalUsers', getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBLicense ADD EncrInternalPortalUsers NVARCHAR(64)
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBLicense add EncrInternalPortalUsers', getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBLicense'
	AND COLUMN_NAME = 'DefaultSystemUsers')
BEGIN

	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBLicense add DefaultSystemUsers', getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBLicense ADD DefaultSystemUsers INT
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBLicense add DefaultSystemUsers', getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBLicense'
	AND COLUMN_NAME = 'EncrDefaultSystemUsers')
BEGIN

	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBLicense add EncrDefaultSystemUsers', getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBLicense ADD EncrDefaultSystemUsers NVARCHAR(64)
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBLicense add EncrDefaultSystemUsers', getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBLicense'
	AND COLUMN_NAME = 'MaxLoginSUsers')
BEGIN

	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBLicense add MaxLoginSUsers', getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBLicense ADD MaxLoginSUsers INT
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBLicense add MaxLoginSUsers', getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBLicense'
	AND COLUMN_NAME = 'EncrLoginSUsers')
BEGIN

	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBLicense add EncrLoginSUsers', getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBLicense ADD EncrLoginSUsers NVARCHAR(64)
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBLicense add EncrLoginSUsers', getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBLicense'
	AND COLUMN_NAME = 'MaxLoginExternalPortalUsers')
BEGIN

	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBLicense add MaxLoginExternalPortalUsers', getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBLicense ADD MaxLoginExternalPortalUsers INT
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBLicense add MaxLoginExternalPortalUsers', getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBLicense'
	AND COLUMN_NAME = 'EncrLoginExtPortalUsers')
BEGIN

	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBLicense add EncrLoginExtPortalUsers', getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBLicense ADD EncrLoginExtPortalUsers NVARCHAR(64)
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBLicense add EncrLoginExtPortalUsers', getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBLicense'
	AND COLUMN_NAME = 'MaxLoginInternalPortalUsers')
BEGIN

	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBLicense add MaxLoginInternalPortalUsers', getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBLicense ADD MaxLoginInternalPortalUsers INT
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBLicense add MaxLoginInternalPortalUsers', getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBLicense'
	AND COLUMN_NAME = 'EncrLoginIntPortalUsers')
BEGIN

	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBLicense add EncrLoginIntPortalUsers', getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBLicense ADD EncrLoginIntPortalUsers NVARCHAR(64)
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBLicense add EncrLoginIntPortalUsers', getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
		WHERE TABLE_NAME = 'PDBUserLicenseInfo'
		AND CONSTRAINT_NAME = 'PK_USERLICENSEINFO'
)
AND 
NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUserLicenseInfo'
	AND COLUMN_NAME = 'UserIndex'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	
	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUserLicenseInfo DROP Primary Key Constraints to UserIndex column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	ALTER TABLE PDBUserLicenseInfo DROP CONSTRAINT PK_USERLICENSEINFO
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUserLicenseInfo DROP Primary Key Constraints to UserIndex column', GETDATE(), NULL, 'Already Updated')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUserLicenseInfo'
	AND COLUMN_NAME = 'UserIndex'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUserLicenseInfo Alter Column UserIndex', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBUserLicenseInfo ALTER COLUMN UserIndex INT NOT NULL
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUserLicenseInfo Alter Column UserIndex', getdate(), getdate(), 'ALREADY UPDATED')
	
END	
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
		WHERE TABLE_NAME = 'PDBUserLicenseInfo'
		AND CONSTRAINT_NAME = 'PK_USERLICENSEINFO'
)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	
	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUserLicenseInfo ADD Primary Key Constraints to UserIndex column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	ALTER TABLE PDBUserLicenseInfo ADD CONSTRAINT PK_USERLICENSEINFO PRIMARY KEY (UserIndex)
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUserLicenseInfo ADD Primary Key Constraints to UserIndex column', GETDATE(), NULL, 'Already Updated')
END
;


-------------------------------------------------------------------------------------------
-- Changed By				: Mili Das
-- Reason / Cause (Bug No if Any)	: Implementation of Maker Checker feature
-- Change Description			: New default user CheckerSupervisor is added
-------------------------------------------------------------------------------------------
BEGIN
SELECT 0
declare @stepNo int
DECLARE @UserName		varchar(256)
DECLARE @PersonalName		varchar(256)
DECLARE @FamilyName		varchar(1020) 
DECLARE @Privileges		varchar(16)
DECLARE @PassWord		varbinary(128)
DECLARE @Account		Integer
DECLARE @Comment		varchar(1020) 
DECLARE @UserAlive		CHAR(1)
DECLARE @TempDate		DATETIME
DECLARE @ExpiryDateTm		datetime
DECLARE @UserIndex		int
DECLARE @MainGroupId		smallint
DECLARE @Privilege		varchar(16)
DECLARE @Name			varchar(1020) 
DECLARE @DBImageVolumeIndex 	Int
DECLARE @DataDefinitionIndex 	Int
DECLARE @AccessType 		Char
DECLARE @FolderType 		Char
DECLARE @FolderLock 		Char
DECLARE @Location 		Char
DECLARE @Owner			int
DECLARE @FinalizedBY		Int
DECLARE @FolderLevel		int
DECLARE @FinalizedFlag		Char
DECLARE @DBStatus		int
DECLARE @ParentFolderIndex 	Int
DECLARE @strQuery VARCHAR(1020)



IF NOT EXISTS(
	SELECT * FROM PDBUser 
	WHERE UserName = 'Supervisor2')
	BEGIN
		SELECT @DBStatus = 0

		EXECUTE GetDate1 @TempDate out
		EXECUTE GetDate1 @ExpiryDateTm out,'E' 

		BEGIN Transaction TranChecker

		insert into PDBUpdateStatus  values ('Insert', 'INSERT INTO PDBUSER VALUES(Supervisor2)', getdate(), NULL, 'UPDATING')

------------------------------------------------------------------------------------
-- Changed By				: Sneh   
-- Reason / Cause (Bug No if Any)	: Changes for adding audit log priviledge
-- Change Description			: New bit added for audit log priviledge
------------------------------------------------------------------------------------	
			SELECT 	@UserName = 'Supervisor2', @PersonalName ='Supervisor2',--'System Administrator',
			@FamilyName  =NULL, @Privileges = '1111111111110000', @PassWord = NULL,
			@Account =0, @Comment = 'Supervisor2User', @UserAlive ='Y'

			INSERT INTO PDBUSER(UserName,PersonalName,FamilyName,CreatedDateTime,
			ExpiryDateTime,PrivilegeControlList,Password,Account,Comment,DeletedDateTime,
			UserAlive, MainGroupId,Superior,SuperiorFlag,ParentGroupIndex) 
			VALUES (@UserName,@PersonalName,@FamilyName,
				@TempDate, @ExpiryDateTm,@Privileges,
				@PassWord,@Account, @Comment, @TempDate,'Y',0,1,'U',1)

			SELECT @DBStatus = @@ERROR
			IF (@DBStatus <> 0)
			BEGIN
				ROLLBACK TRANSACTION TranChecker
			Return
			END

		select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
		update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo

		SELECT @UserIndex = @@IDENTITY

		UPDATE PDBUser SET Password = (SELECT Password FROM PDBUser WHERE UserIndex = 1)
		WHERE UserIndex = @UserIndex
		SELECT @DBStatus = @@ERROR
		IF (@DBStatus <> 0)
		BEGIN
			ROLLBACK TRANSACTION TranChecker
			Return
		END

		insert into PDBUpdateStatus  values ('Insert', 'INSERT INTO USERSECURITY VALUES(Supervisor2)', getdate(), NULL, 'UPDATING')

		SELECT @strQuery = 'INSERT INTO UserSecurity(UserIndex, LoggedInAttempts, UserLocked) VALUES( ' + CONVERT(VARCHAR(10),@UserIndex) + ' , 0, ''N'')'

		EXECUTE(@strQuery)

		SELECT @DBStatus = @@ERROR
		IF ( @DBStatus <> 0 )
		BEGIN
			ROLLBACK Transaction TranChecker
			RETURN
		END

		select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
		update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo

		insert into PDBUpdateStatus  values ('Insert', 'INSERT INTO PDBGROUP VALUES(1)', getdate(), NULL, 'UPDATING')

		INSERT INTO PDBGroupMember(GroupIndex,UserIndex) VALUES (1,@UserIndex)
		SELECT @DBStatus = @@ERROR
		IF ( @DBStatus <> 0 )
		BEGIN
			ROLLBACK Transaction TranChecker
			RETURN
		END
		
		select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
		update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo

		insert into PDBUpdateStatus  values ('Insert', 'INSERT INTO PDBGROUP VALUES(2)', getdate(), NULL, 'UPDATING')

		INSERT INTO PDBGroupMember(GroupIndex,UserIndex) VALUES (2,@UserIndex)
		SELECT @DBStatus = @@ERROR
		IF ( @DBStatus <> 0 )
		BEGIN
			ROLLBACK Transaction TranChecker
			RETURN
		END

		select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
		update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo

		insert into PDBUpdateStatus  values ('Insert', 'INSERT INTO PDBGROUP VALUES(3)', getdate(), NULL, 'UPDATING')

		INSERT INTO PDBGroupMember(GroupIndex,UserIndex) VALUES (3,@UserIndex)
		SELECT @DBStatus = @@ERROR
		IF ( @DBStatus <> 0 )
		BEGIN
			ROLLBACK Transaction TranChecker
			RETURN
		END

		select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
		update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo

--Creating folders for Supervisor2

		/* Create Supervisor2 In Box */

		insert into PDBUpdateStatus  values ('Insert', 'INSERT INTO PDBFolder VALUES(User_Inbox_Supervisor2)', getdate(), NULL, 'UPDATING')
		
		SELECT @ParentFolderIndex= 3, @Owner = @UserIndex,@Name = 'User_Inbox_Supervisor2',@DataDefinitionIndex = 0,
		       @AccessType = 'S',@FolderType = 'I',@FolderLock = 'N', @Location ='I',
		       @Comment ='',@FinalizedFlag = 'N',@FinalizedBY =0,@FolderLevel = 3

		SELECT @DBImageVolumeIndex = ImageVolumeIndex from pdbcabinet
		
		INSERT INTO PDBFOLDER (ParentFolderIndex,Name,Owner,CreatedDatetime,RevisedDateTime,AccessedDateTime,DataDefinitionIndex,AccessType,ImageVolumeIndex,	FolderType,FolderLock,LockByUser,Location,DeletedDateTime,EnableVersion,ExpiryDateTime,
			Comment,UseFulData,ACL,FinalizedFlag,FinalizedDateTime,FinalizedBy,ACLMoreFlag,
			MainGroupId, EnableFTS,FolderLevel,Hierarchy,OwnerInheritance)
			VALUES 
			(@ParentFolderIndex,@Name,@Owner,@TempDate,@TempDate,
			@TempDate,@Datadefinitionindex,@AccessType,@DBImageVolumeIndex,
			@FolderType, @FolderLock, null,@Location,@TempDate,'N',@ExpiryDateTm,
			@Comment,null,null,@FinalizedFlag,@TempDate,@FinalizedBy,'N',0,'N',
			@FolderLevel,'0.3.','N')
		
		SELECT @DBStatus = @@ERROR
		IF (@DBStatus <> 0)
		BEGIN
			ROLLBACK TRANSACTION TranChecker
			Return
		END

		select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
		update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo

		/* Create Supervisor2 Sent Item */

		insert into PDBUpdateStatus  values ('Insert', 'INSERT INTO PDBFolder VALUES(User_SentItem_Supervisor2)', getdate(), NULL, 'UPDATING')

		SELECT @ParentFolderIndex= 4, @Owner = @UserIndex,@Name = 'User_SentItem_Supervisor2',@DataDefinitionIndex = 0,
		       @AccessType = 'P',@FolderType = 'S',@FolderLock = 'N', @Location ='S',
		       @Comment ='',@FinalizedFlag = 'N',@FinalizedBY =0,@FolderLevel = 3
		
		INSERT INTO PDBFOLDER (ParentFolderIndex,Name,Owner,CreatedDatetime,RevisedDateTime,AccessedDateTime,DataDefinitionIndex,AccessType, 			ImageVolumeIndex,FolderType,FolderLock,LockByUser,Location,DeletedDateTime,
			EnableVersion,ExpiryDateTime,Comment,UseFulData,ACL,FinalizedFlag,
			FinalizedDateTime,FinalizedBy,ACLMoreFlag,MainGroupId, EnableFTS,FolderLevel,Hierarchy,OwnerInheritance)
			VALUES (@ParentFolderIndex,@Name,@Owner,@TempDate,
			@TempDate,@TempDate,@Datadefinitionindex,@AccessType,
			@DBImageVolumeIndex,@FolderType, @FolderLock, null,@Location,
			@TempDate,'N',@ExpiryDateTm,@Comment,null,null,@FinalizedFlag,
			@TempDate,@FinalizedBy,'N',0,'N',@FolderLevel,'0.4.','N')

		SELECT @DBStatus = @@ERROR
		IF (@DBStatus <> 0)
		BEGIN
			ROLLBACK TRANSACTION TranChecker
			Return
		END

		select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
		update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo

		/* Create Supervisor2 trash */

		insert into PDBUpdateStatus  values ('Insert', 'INSERT INTO PDBFolder VALUES(User_Trash_Supervisor2)', getdate(), NULL, 'UPDATING')

		SELECT 	@ParentFolderIndex = 5, @Name = 'User_Trash_Supervisor2',@Owner =@UserIndex,@DataDefinitionIndex = 0, @AccessType = 'P',@FolderType = 'T',
			@FolderLock = 'N', @Location ='T', @Comment ='',
			@FinalizedFlag = 'N',@FinalizedBY = 0,@FolderLevel = 3
		
		INSERT INTO PDBFOLDER (ParentFolderIndex,Name,Owner,CreatedDatetime,RevisedDateTime,AccessedDateTime,DataDefinitionIndex,AccessType,			ImageVolumeIndex,FolderType,FolderLock,LockByUser,Location,DeletedDateTime,
			EnableVersion,ExpiryDateTime,Comment,UseFulData,ACL,FinalizedFlag,
			FinalizedDateTime,FinalizedBy,ACLMoreFlag,MainGroupId, EnableFTS,FolderLevel,Hierarchy,OwnerInheritance)
			VALUES (@ParentFolderIndex,@Name,@Owner,@TempDate,
			@TempDate,@TempDate,@Datadefinitionindex,@AccessType,
			@DBImageVolumeIndex,@FolderType, @FolderLock, null,@Location,
			@TempDate,'N',@ExpiryDateTm,@Comment,null,null,@FinalizedFlag,
			@TempDate,@FinalizedBy,'N',0,'N',@FolderLevel,'0.5.','N')
		SELECT @DBStatus = @@ERROR
		IF (@DBStatus <> 0)
		BEGIN
			ROLLBACK TRANSACTION TranChecker
			Return
		END

		select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
		update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo


		/* Create Supervisor2 attachment */

		insert into PDBUpdateStatus  values ('Insert', 'INSERT INTO PDBFolder VALUES(User_Attachment_Supervisor2)', getdate(), NULL, 'UPDATING')


		SELECT 	@ParentFolderIndex = 2, @Name = 'User_Attachment_Supervisor2',@Owner =@UserIndex,@DataDefinitionIndex = 0, @AccessType = 'P',@FolderType = 'H',
			@FolderLock = 'N', @Location ='H', @Comment ='',
			@FinalizedFlag = 'N',@FinalizedBY = 0,@FolderLevel = 3
		
		INSERT INTO PDBFOLDER (ParentFolderIndex,Name,Owner,CreatedDatetime,RevisedDateTime,AccessedDateTime,DataDefinitionIndex,AccessType,
			ImageVolumeIndex,FolderType,FolderLock,LockByUser,Location,
			DeletedDateTime,EnableVersion,ExpiryDateTime,Comment,UseFulData,ACL,
			FinalizedFlag,FinalizedDateTime,FinalizedBy,ACLMoreFlag,
			MainGroupId, EnableFTS,FolderLevel, Hierarchy,OwnerInheritance)
			VALUES (@ParentFolderIndex,@Name,@Owner,@TempDate,
			@TempDate,@TempDate,@Datadefinitionindex,@AccessType,
			@DBImageVolumeIndex,@FolderType, @FolderLock, null,@Location,
			@TempDate,'N',@ExpiryDateTm,@Comment,null,null,@FinalizedFlag,
			@TempDate,@FinalizedBy,'N',0,'N',@FolderLevel,'0.2.','N')
		SELECT @DBStatus = @@ERROR
		IF (@DBStatus <> 0)
		BEGIN
			ROLLBACK TRANSACTION TranChecker
			Return
		END

		select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
		update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo

		COMMIT TRANSACTION TranChecker
	END

END
;
-------------------------------------------------------------------------------------------
-- Changed By				: Mili Das
-- Reason / Cause (Bug No if Any)	: Implementation of maker checker feature
-- Change Description			: Implementation of maker checker feature
-------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
-- Changed By				: Sneh   
-- Reason / Cause (Bug No if Any)	: Changes for adding audit log priviledge
-- Change Description			: New bit added for audit log priviledge
------------------------------------------------------------------------------------	
SELECT 0
DECLARE @AclLen int
DECLARE @Diff int
DECLARE @TempUserId int
DECLARE @TempPrivilegeControlList VARCHAR(16)
DECLARE @NewPrivilegeControlList VARCHAR(16)
DECLARE @TempGroupId int
DECLARE @TempGrpPrivilegeControlList VARCHAR(16)
DECLARE @FirstBit Char(1)
DECLARE @SecondBit Char(1)
DECLARE @stepNo int
DECLARE @CheckerSuperIndex	int



SELECT @CheckerSuperIndex = UserIndex FROM PDBUser WHERE UserName = 'Supervisor2'

DECLARE UserCur CURSOR FOR 
SELECT UserIndex,PrivilegeControlList 
FROM PDBUser WHERE UserIndex <> 1 AND UserIndex <> @CheckerSuperIndex AND LEN(PrivilegeControlList) < 12

DECLARE GroupCur CURSOR FOR 
SELECT GroupIndex,PrivilegeControlList 
FROM PDBGroup WHERE GroupIndex <>2 AND LEN(PrivilegeControlList) < 12

insert into PDBUpdateStatus values ('UPDATE', 'UPDATE PDBUser SET PrivilegeControlList' , getdate(), NULL, 'UPDATING')
SELECT @NewPrivilegeControlList = ''
OPEN UserCur

FETCH NEXT FROM UserCur INTO @TempUserId,@TempPrivilegeControlList
WHILE (@@FETCH_STATUS <> -1)
BEGIN
	IF @@FETCH_STATUS <> -2
	BEGIN
		SELECT @AclLen = LEN(@TempPrivilegeControlList)
		SELECT @Diff = 11 - @AclLen
		IF (@Diff = 0)
			BEGIN
				SELECT @NewPrivilegeControlList = RTRIM(@TempPrivilegeControlList) + '0'
			END
		ELSE
		BEGIN
			WHILE( @Diff > 0)
			BEGIN
				SELECT @TempPrivilegeControlList = RTRIM(@TempPrivilegeControlList) + '0'
				SELECT @Diff = @Diff - 1
			END
		
			SELECT @FirstBit = SUBSTRING(@TempPrivilegeControlList,1,1)
			SELECT @SecondBit = SUBSTRING(@TempPrivilegeControlList,2,1)

			SELECT @NewPrivilegeControlList = SUBSTRING(@TempPrivilegeControlList,1,7) + '0' + @FirstBit + @SecondBit + '0' + '0'

		END

		UPDATE PDBUSER SET PrivilegeControlList = LTRIM(RTRIM(@NewPrivilegeControlList)) WHERE UserIndex = @TempUserId
	END
	FETCH NEXT FROM UserCur INTO @TempUserId,@TempPrivilegeControlList
END
CLOSE UserCur
DEALLOCATE UserCur

UPDATE PDBUSER SET PrivilegeControlList = '1111111111110000' WHERE UserIndex = 1
UPDATE PDBUSER SET PrivilegeControlList = '1111111111110000' WHERE UserIndex = @CheckerSuperIndex

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo

insert into PDBUpdateStatus values ('UPDATE', 'UPDATE PDBGroup SET PrivilegeControlList' , getdate(), NULL, 'UPDATING')

OPEN GroupCur
FETCH NEXT FROM GroupCur INTO @TempGroupId,@TempGrpPrivilegeControlList
WHILE (@@FETCH_STATUS <> -1)
BEGIN
	IF @@FETCH_STATUS <> -2
	BEGIN
		SELECT @AclLen = LEN(@TempGrpPrivilegeControlList)
		SELECT @Diff = 11 - @AclLen
		IF (@Diff = 0)
		BEGIN
				SELECT @NewPrivilegeControlList = RTRIM(@TempGrpPrivilegeControlList) + '0'	
		END
		ELSE
		BEGIN
			WHILE( @Diff > 0)

			BEGIN
				SELECT @TempGrpPrivilegeControlList = RTRIM(@TempGrpPrivilegeControlList) + '0'
				SELECT @Diff = @Diff - 1
			END
			SELECT @FirstBit = SUBSTRING(@TempGrpPrivilegeControlList,1,1)
			SELECT @SecondBit = SUBSTRING(@TempGrpPrivilegeControlList,2,1)
		
			SELECT @NewPrivilegeControlList = SUBSTRING(@TempGrpPrivilegeControlList,1,7) + '0' + @FirstBit + @SecondBit + '0' + '0'
		END

		UPDATE PDBGROUP SET PrivilegeControlList = LTRIM(RTRIM(@NewPrivilegeControlList)) WHERE GroupIndex = @TempGroupId
	END
	FETCH NEXT FROM GroupCur INTO @TempGroupId,@TempGrpPrivilegeControlList
END
CLOSE GroupCur
DEALLOCATE GroupCur

UPDATE PDBGROUP SET PrivilegeControlList = '111111111111' WHERE GroupIndex = 2

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
;

--Foreign Key constraint added
SELECT 0
IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS 
	WHERE CONSTRAINT_NAME = 'FK_DCT_DOCID'
	AND UNIQUE_CONSTRAINT_NAME = 'pk_dindex')
BEGIN
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('ALTER TABLE', 'ALTER TABLE PDBDocumentContent ADD CONSTRAINT FK_DCT_DOCID' , getdate(), NULL, 'UPDATING')
	 
	ALTER TABLE PDBDocumentContent ADD CONSTRAINT FK_DCT_DOCID FOREIGN KEY (DocumentIndex)
		REFERENCES PDBDocument (DocumentIndex)
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
    
END
ELSE
BEGIN
	insert into PDBUpdateStatus values ('ALTER TABLE', 'ALTER TABLE PDBDocumentContent ADD CONSTRAINT FK_DCT_DOCID' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

SELECT 0
IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS 
	WHERE CONSTRAINT_NAME = 'FK_DCT_PARFOLID'
	AND UNIQUE_CONSTRAINT_NAME = 'pk_findex')
BEGIN
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('ALTER TABLE', 'ALTER TABLE PDBDocumentContent ADD CONSTRAINT FK_DCT_PARFOLID' , getdate(), NULL, 'UPDATING')
	 
	ALTER TABLE PDBDocumentContent ADD CONSTRAINT FK_DCT_PARFOLID FOREIGN KEY (ParentFolderIndex)
		REFERENCES PDBFolder(FolderIndex)

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
    
END
ELSE
BEGIN
	insert into PDBUpdateStatus values ('ALTER TABLE', 'ALTER TABLE PDBDocumentContent ADD CONSTRAINT FK_DCT_PARFOLID' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
--Add Referential constarints

IF NOT EXISTS(
	SELECT  1 FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBAnnotationObject')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBAnnotationObject') AND NAME = 'DocumentIndex')
	AND	XTYPE = 'F'
)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	
	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBAnnotationObject ADD Referential Constraints to DocumentIndex column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY


	ALTER TABLE PDBAnnotationObject ADD CONSTRAINT fk_annotobj_docind FOREIGN KEY (DocumentIndex)
		REFERENCES PDBDocument(DocumentIndex)
	
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBAnnotationObject Referential Constraints to DocumentIndex column', GETDATE(), NULL, 'Already Updated')
END
;

IF NOT EXISTS(
	SELECT  1 FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBBoolGlobalIndex')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBBoolGlobalIndex') AND NAME = 'DataFieldIndex')
	AND	XTYPE = 'F'
)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	
	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBBoolGlobalIndex ADD Referential Constraints to DataFieldIndex column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY


	ALTER TABLE PDBBoolGlobalIndex ADD CONSTRAINT fk_Boolglobalind_dfind FOREIGN KEY (DataFieldIndex)
		REFERENCES PDBGlobalIndex(DataFieldIndex)
	
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBBoolGlobalIndex Referential Constraints to DataFieldIndex column', GETDATE(), NULL, 'Already Updated')
END
;
-----------------------------------------------------------------------------------------------
-- Changed By				: Rohika Gupta
-- Reason / Cause (Bug No if Any)	: Change for user credentials
-- Change Description			: New column added in PDBDataFieldsTable 
-----------------------------------------------------------------------------------------------
IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBDataFieldsTable'
	AND COLUMN_NAME = 'UserUpdatable')
BEGIN

	declare @stepNo int
	SELECT 1
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDataFieldsTable add UserUpdatable', getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBDataFieldsTable
		ADD UserUpdatable CHAR(1) 

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDataFieldsTable  add UserUpdatable', getdate(), getdate(), 'ALREADY UPDATED')
END	
;
-----------------------------------------------------------------------------------------------
-- Changed By				: Rohika Gupta
-- Reason / Cause (Bug No if Any)	: Change for user credentials
-- Change Description			: New column added in PDBDataFieldsTable 
-----------------------------------------------------------------------------------------------
IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBDataFieldsTable'
	AND COLUMN_NAME = 'Pickable')
BEGIN

	declare @stepNo int
	SELECT 1
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDataFieldsTable add pickable', getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBDataFieldsTable
		ADD Pickable CHAR(1) CONSTRAINT ck_dft_pickable CHECK (Pickable IN ('Y','N')) DEFAULT 'N' NOT NULL

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDataFieldsTable  add Pickable', getdate(), getdate(), 'ALREADY UPDATED')
END	
;

IF NOT EXISTS(
	SELECT  1 FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBDataFieldsTable')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBDataFieldsTable') AND NAME = 'DataDefIndex')
	AND	XTYPE = 'F'
)
BEGIN
	SELECT 1
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDataFieldsTable ADD Referential Constraints to DataDefIndex column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY


	ALTER TABLE PDBDataFieldsTable ADD CONSTRAINT fk_dft_ddind FOREIGN KEY (DataDefIndex)
		REFERENCES PDBDataDefinition(DataDefIndex)
	
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDataFieldsTable Referential Constraints to DataDefIndex column', GETDATE(), NULL, 'Already Updated')
END
;

IF NOT EXISTS(
	SELECT  1 FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBDataFieldsTable')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBDataFieldsTable') AND NAME = 'DataFieldIndex')
	AND	XTYPE = 'F'
)
BEGIN
	SELECT 1
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDataFieldsTable ADD Referential Constraints to DataFieldIndex column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY


	ALTER TABLE PDBDataFieldsTable ADD CONSTRAINT fk_dft_dfind FOREIGN KEY (DataFieldIndex)
		REFERENCES PDBGlobalIndex (DataFieldIndex)
	
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDataFieldsTable Referential Constraints to DataFieldIndex column', GETDATE(), NULL, 'Already Updated')
END
;

IF NOT EXISTS(
	SELECT  1 FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBDateGlobalIndex')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBDateGlobalIndex') AND NAME = 'DataFieldIndex')
	AND	XTYPE = 'F'
)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	
	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDateGlobalIndex ADD Referential Constraints to DataFieldIndex column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY


	ALTER TABLE PDBDateGlobalIndex ADD CONSTRAINT fk_Dateglobalind_dfind FOREIGN KEY (DataFieldIndex)
		REFERENCES PDBGlobalIndex (DataFieldIndex)
	
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDateGlobalIndex Referential Constraints to DataFieldIndex column', GETDATE(), NULL, 'Already Updated')
END
;
IF NOT EXISTS(
	SELECT  1 FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBDocIdGlobalIndex')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBDocIdGlobalIndex') AND NAME = 'DataFieldIndex')
	AND	XTYPE = 'F'
)
BEGIN
	SELECT 1
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDocIdGlobalIndex ADD Referential Constraints to DataFieldIndex column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY


	ALTER TABLE PDBDocIdGlobalIndex ADD CONSTRAINT fk_DocIdglobalind_dfind FOREIGN KEY (DataFieldIndex)
		REFERENCES PDBGlobalIndex (DataFieldIndex)
	
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDocIdGlobalIndex Referential Constraints to DataFieldIndex column', GETDATE(), NULL, 'Already Updated')
END
;

IF NOT EXISTS(
	SELECT  1 FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBFloatGlobalIndex')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBFloatGlobalIndex') AND NAME = 'DataFieldIndex')
	AND	XTYPE = 'F'
)
BEGIN
	SELECT 1
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBFloatGlobalIndex ADD Referential Constraints to DataFieldIndex column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY


	ALTER TABLE PDBFloatGlobalIndex ADD CONSTRAINT fk_Fglobalind_dfind FOREIGN KEY (DataFieldIndex)
		REFERENCES PDBGlobalIndex (DataFieldIndex)
	
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBFloatGlobalIndex Referential Constraints to DataFieldIndex column', GETDATE(), NULL, 'Already Updated')
END
;
IF NOT EXISTS(
	SELECT  1 FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBFolderContent')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBFolderContent') AND NAME = 'ParentFolderIndex')
	AND	XTYPE = 'F'
)
BEGIN
	SELECT 1
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBFolderContent ADD Referential Constraints to ParentFolderIndex column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY


	ALTER TABLE PDBFolderContent ADD CONSTRAINT fk_fct_pfind FOREIGN KEY (ParentFolderIndex)
		REFERENCES PDBFolder(FolderIndex)
	
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBFolderContent Referential Constraints to ParentFolderIndex column', GETDATE(), NULL, 'Already Updated')
END
;

IF NOT EXISTS(
	SELECT  1 FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBFolderContent')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBFolderContent') AND NAME = 'FolderIndex')
	AND	XTYPE = 'F'
)
BEGIN
	SELECT 1
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBFolderContent ADD Referential Constraints to FolderIndex column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY


	ALTER TABLE PDBFolderContent ADD CONSTRAINT fk_fct_find FOREIGN KEY (FolderIndex)
		REFERENCES PDBFolder(FolderIndex)
	
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBFolderContent Referential Constraints to FolderIndex column', GETDATE(), NULL, 'Already Updated')
END
;

IF NOT EXISTS(
	SELECT  1 FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBIntGlobalIndex')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBIntGlobalIndex') AND NAME = 'DataFieldIndex')
	AND	XTYPE = 'F'
)
BEGIN
	SELECT 1
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBIntGlobalIndex ADD Referential Constraints to DataFieldIndex column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY


	ALTER TABLE PDBIntGlobalIndex ADD CONSTRAINT fk_Intglobalind_dfind FOREIGN KEY (DataFieldIndex)
		REFERENCES PDBGlobalIndex (DataFieldIndex)
	
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBIntGlobalIndex Referential Constraints to DataFieldIndex column', GETDATE(), NULL, 'Already Updated')
END
;

IF NOT EXISTS(
	SELECT  1 FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBKeyword')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBKeyword') AND NAME = 'KeywordIndex')
	AND	XTYPE = 'F'
)
BEGIN
	SELECT 1
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBKeyword ADD Referential Constraints to KeywordIndex column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY


	ALTER TABLE PDBKeyword ADD CONSTRAINT fk_keyword_keyind FOREIGN KEY (KeywordIndex)
		REFERENCES PDBDictionary (KeywordIndex)
	
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBKeyword Referential Constraints to KeywordIndex column', GETDATE(), NULL, 'Already Updated')
END
;

IF NOT EXISTS(
	SELECT  1 FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBTextGlobalIndex')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBTextGlobalIndex') AND NAME = 'DataFieldIndex')
	AND	XTYPE = 'F'
)
BEGIN
	SELECT 1
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBTextGlobalIndex ADD Referential Constraints to DataFieldIndex column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY


	ALTER TABLE PDBTextGlobalIndex ADD CONSTRAINT fk_Textglobalind_dfind FOREIGN KEY (DataFieldIndex)
		REFERENCES PDBGlobalIndex (DataFieldIndex)
	
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBTextGlobalIndex Referential Constraints to DataFieldIndex column', GETDATE(), NULL, 'Already Updated')
END
;

IF NOT EXISTS(
	SELECT  1 FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBLongGlobalIndex')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBLongGlobalIndex') AND NAME = 'DataFieldIndex')
	AND	XTYPE = 'F'
)
BEGIN
	SELECT 1
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBLongGlobalIndex ADD Referential Constraints to DataFieldIndex column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY


	ALTER TABLE PDBLongGlobalIndex ADD CONSTRAINT fk_Lglobalind_dfind FOREIGN KEY (DataFieldIndex)
		REFERENCES PDBGlobalIndex (DataFieldIndex)
	
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBLongGlobalIndex Referential Constraints to DataFieldIndex column', GETDATE(), NULL, 'Already Updated')
END
;

IF EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBLongGlobalIndex'
	AND COLUMN_NAME = 'DocumentIndex')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBLongGlobalIndex add FoldDocIndex' , getdate(), NULL, 'UPDATING')

	IF EXISTS(SELECT 1 FROM  INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
					WHERE CONSTRAINT_NAME = 'pk_datafielddocument1' AND TABLE_NAME = 'PDBLongGlobalIndex')
	BEGIN
		ALTER TABLE PDBLongGlobalIndex DROP CONSTRAINT pk_datafielddocument1
	END
	IF EXISTS(SELECT 1 FROM  INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
				WHERE CONSTRAINT_NAME = 'fk_Lglobalind_docind' AND TABLE_NAME = 'PDBLongGlobalIndex')
	BEGIN
		ALTER TABLE PDBLongGlobalIndex DROP CONSTRAINT fk_Lglobalind_docind
	END	
	EXECUTE sp_rename N'PDBLongGlobalIndex.DocumentIndex', N'FoldDocIndex', 'COLUMN'
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBLongGlobalIndex add FoldDocIndex' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBLongGlobalIndex'
	AND COLUMN_NAME = 'FoldDocFlag')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBLongGlobalIndex add FoldDocFlag' , getdate(), NULL, 'UPDATING')
		
	ALTER TABLE PDBLongGlobalIndex ADD FoldDocFlag CHAR(1) NOT NULL CONSTRAINT DF_LngGlblIndx_FoldDDocFlag DEFAULT 'D' WITH VALUES  
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBLongGlobalIndex add FoldDocFlag' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(SELECT 1 FROM  INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
			WHERE CONSTRAINT_NAME = 'pk_datafieldobject1' AND TABLE_NAME = 'PDBLongGlobalIndex')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBLongGlobalIndex ADD CONSTRAINT pk_datafieldobject1' , getdate(), NULL, 'UPDATING')
		
	ALTER TABLE PDBLongGlobalIndex ADD CONSTRAINT pk_datafieldobject1 PRIMARY KEY ( FoldDocIndex, FoldDocFlag, DataFieldindex,LongValue)
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBLongGlobalIndex ADD CONSTRAINT pk_datafieldobject1' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBIntGlobalIndex'
	AND COLUMN_NAME = 'DocumentIndex')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBIntGlobalIndex add FoldDocIndex' , getdate(), NULL, 'UPDATING')
		
	IF EXISTS(SELECT 1 FROM  INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
					WHERE CONSTRAINT_NAME = 'pk_datafielddocument2' AND TABLE_NAME = 'PDBIntGlobalIndex')
	BEGIN
		ALTER TABLE PDBIntGlobalIndex DROP CONSTRAINT pk_datafielddocument2
	END
	IF EXISTS(SELECT 1 FROM  INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
				WHERE CONSTRAINT_NAME = 'fk_Intglobalind_docind' 
				AND TABLE_NAME = 'PDBIntGlobalIndex')
	BEGIN
		ALTER TABLE PDBIntGlobalIndex DROP CONSTRAINT fk_Intglobalind_docind
	END	
	EXECUTE sp_rename N'PDBIntGlobalIndex.DocumentIndex', N'FoldDocIndex', 'COLUMN'
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBIntGlobalIndex add FoldDocIndex' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBIntGlobalIndex'
	AND COLUMN_NAME = 'FoldDocFlag')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBIntGlobalIndex add FoldDocFlag' , getdate(), NULL, 'UPDATING')
		
	ALTER TABLE PDBIntGlobalIndex ADD FoldDocFlag CHAR(1) NOT NULL CONSTRAINT DF_IntGlblIndx_FoldDDocFlag DEFAULT 'D' WITH VALUES  
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBIntGlobalIndex add FoldDocFlag' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(SELECT 1 FROM  INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
			WHERE CONSTRAINT_NAME = 'pk_datafieldobject2' AND TABLE_NAME = 'PDBIntGlobalIndex')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBIntGlobalIndex ADD CONSTRAINT pk_datafieldobject2' , getdate(), NULL, 'UPDATING')
		
	ALTER TABLE PDBIntGlobalIndex ADD CONSTRAINT pk_datafieldobject2 PRIMARY KEY (FoldDocIndex, FoldDocFlag,DataFieldindex, IntValue)
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBIntGlobalIndex ADD CONSTRAINT pk_datafieldobject2' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBBoolGlobalIndex'
	AND COLUMN_NAME = 'DocumentIndex')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBBoolGlobalIndex add FoldDocIndex' , getdate(), NULL, 'UPDATING')
		
	IF EXISTS(SELECT 1 FROM  INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
				WHERE CONSTRAINT_NAME = 'pk_datafielddocument3' 
				AND TABLE_NAME = 'PDBBoolGlobalIndex')
	BEGIN		
		ALTER TABLE PDBBoolGlobalIndex DROP CONSTRAINT pk_datafielddocument3
	END
	IF EXISTS(SELECT 1 FROM  INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
			WHERE CONSTRAINT_NAME = 'fk_Boolglobalind_docind' 
			AND TABLE_NAME = 'PDBBoolGlobalIndex')
	BEGIN		
		ALTER TABLE PDBBoolGlobalIndex DROP CONSTRAINT fk_Boolglobalind_docind
	END	
	EXECUTE sp_rename N'PDBBoolGlobalIndex.DocumentIndex', N'FoldDocIndex', 'COLUMN'
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBBoolGlobalIndex add FoldDocIndex' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBBoolGlobalIndex'
	AND COLUMN_NAME = 'FoldDocFlag')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBBoolGlobalIndex add FoldDocFlag' , getdate(), NULL, 'UPDATING')
		
	ALTER TABLE PDBBoolGlobalIndex ADD FoldDocFlag CHAR(1) NOT NULL CONSTRAINT DF_BlGlblIndx_FoldDDocFlag DEFAULT 'D' WITH VALUES  
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBBoolGlobalIndex add FoldDocFlag' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(SELECT 1 FROM  INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
			WHERE CONSTRAINT_NAME = 'pk_datafieldobject3' AND TABLE_NAME = 'PDBBoolGlobalIndex')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBBoolGlobalIndex ADD CONSTRAINT pk_datafieldobject3' , getdate(), NULL, 'UPDATING')
		
	ALTER TABLE PDBBoolGlobalIndex ADD CONSTRAINT pk_datafieldobject3 PRIMARY KEY (FoldDocIndex, FoldDocFlag,DataFieldindex)
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBBoolGlobalIndex ADD CONSTRAINT pk_datafieldobject3' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBFloatGlobalIndex'
	AND COLUMN_NAME = 'DocumentIndex')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBFloatGlobalIndex add FoldDocIndex' , getdate(), NULL, 'UPDATING')
		
	IF EXISTS(SELECT 1 FROM  INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
					WHERE CONSTRAINT_NAME = 'pk_datafielddocument4' AND TABLE_NAME = 'PDBFloatGlobalIndex')
	BEGIN
		ALTER TABLE PDBFloatGlobalIndex DROP CONSTRAINT pk_datafielddocument4
	END
	IF EXISTS(SELECT 1 FROM  INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
			WHERE CONSTRAINT_NAME = 'fk_Fglobalind_docind' 
			AND TABLE_NAME = 'PDBFloatGlobalIndex')
	BEGIN		
		ALTER TABLE PDBFloatGlobalIndex DROP CONSTRAINT fk_Fglobalind_docind
	END	
	EXECUTE sp_rename N'PDBFloatGlobalIndex.DocumentIndex', N'FoldDocIndex', 'COLUMN'
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBFloatGlobalIndex add FoldDocIndex' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBFloatGlobalIndex'
	AND COLUMN_NAME = 'FoldDocFlag')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBFloatGlobalIndex add FoldDocFlag' , getdate(), NULL, 'UPDATING')
		
	ALTER TABLE PDBFloatGlobalIndex ADD FoldDocFlag CHAR(1) NOT NULL CONSTRAINT DF_FltGlblIndx_FoldDDocFlag DEFAULT 'D' WITH VALUES  
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBFloatGlobalIndex add FoldDocFlag' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
IF NOT EXISTS(SELECT 1 FROM  INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
			WHERE CONSTRAINT_NAME = 'pk_datafieldobject4' AND TABLE_NAME = 'PDBFloatGlobalIndex')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBFloatGlobalIndex ADD CONSTRAINT pk_datafieldobject4' , getdate(), NULL, 'UPDATING')
		
	ALTER TABLE PDBFloatGlobalIndex ADD CONSTRAINT pk_datafieldobject4 PRIMARY KEY (FoldDocIndex, FoldDocFlag,DataFieldindex,FloatValue)
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBFloatGlobalIndex ADD CONSTRAINT pk_datafieldobject4' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBDateGlobalIndex'
	AND COLUMN_NAME = 'DocumentIndex')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBDateGlobalIndex add FoldDocIndex' , getdate(), NULL, 'UPDATING')
		
	IF EXISTS(SELECT 1 FROM  INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
					WHERE CONSTRAINT_NAME = 'pk_datafielddocument5' 
					AND TABLE_NAME = 'PDBDateGlobalIndex')
	BEGIN
		ALTER TABLE PDBDateGlobalIndex DROP CONSTRAINT pk_datafielddocument5
	END

	IF EXISTS(SELECT 1 FROM  INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
			WHERE CONSTRAINT_NAME = 'fk_Dateglobalind_docind' 
			AND TABLE_NAME = 'PDBDateGlobalIndex')
	BEGIN		
		ALTER TABLE PDBDateGlobalIndex DROP CONSTRAINT fk_Dateglobalind_docind
	END	
	EXECUTE sp_rename N'PDBDateGlobalIndex.DocumentIndex', N'FoldDocIndex', 'COLUMN'
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBDateGlobalIndex add FoldDocIndex' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBDateGlobalIndex'
	AND COLUMN_NAME = 'FoldDocFlag')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBDateGlobalIndex add FoldDocFlag' , getdate(), NULL, 'UPDATING')
		
	ALTER TABLE PDBDateGlobalIndex ADD FoldDocFlag CHAR(1) NOT NULL CONSTRAINT DF_DtGlblIndx_FoldDDocFlag DEFAULT 'D' WITH VALUES  
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBDateGlobalIndex add FoldDocFlag' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(SELECT 1 FROM  INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
			WHERE CONSTRAINT_NAME = 'pk_datafieldobject5' AND TABLE_NAME = 'PDBDateGlobalIndex')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBDateGlobalIndex ADD CONSTRAINT pk_datafieldobject5' , getdate(), NULL, 'UPDATING')
		
	ALTER TABLE PDBDateGlobalIndex ADD CONSTRAINT pk_datafieldobject5 PRIMARY KEY  (FoldDocIndex, FoldDocFlag,DataFieldindex,DateValue)
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBDateGlobalIndex ADD CONSTRAINT pk_datafieldobject5' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBstringGlobalIndex'
	AND COLUMN_NAME = 'DocumentIndex')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBstringGlobalIndex add FoldDocIndex' , getdate(), NULL, 'UPDATING')
		
	IF EXISTS(SELECT 1 FROM  INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
					WHERE CONSTRAINT_NAME = 'pk_datafielddocument6' AND TABLE_NAME = 'PDBStringGlobalIndex'	)
	BEGIN
		ALTER TABLE PDBstringGlobalIndex DROP CONSTRAINT pk_datafielddocument6
	END

	IF EXISTS(SELECT 1 FROM  INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
				WHERE CONSTRAINT_NAME = 'fk_Strglobalind_docind' AND TABLE_NAME = 'PDBStringGlobalIndex'	)
	BEGIN
		ALTER TABLE PDBstringGlobalIndex DROP CONSTRAINT fk_Strglobalind_docind
	END	
	EXECUTE sp_rename N'PDBstringGlobalIndex.DocumentIndex', N'FoldDocIndex', 'COLUMN'
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBstringGlobalIndex add FoldDocIndex' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBstringGlobalIndex'
	AND COLUMN_NAME = 'FoldDocFlag')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBstringGlobalIndex add FoldDocFlag' , getdate(), NULL, 'UPDATING')
		
	ALTER TABLE PDBstringGlobalIndex ADD FoldDocFlag CHAR(1) NOT NULL CONSTRAINT DF_StrGlblIndx_FoldDDocFlag DEFAULT 'D' WITH VALUES  
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBstringGlobalIndex add FoldDocFlag' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(SELECT 1 FROM  INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
			WHERE CONSTRAINT_NAME = 'pk_datafieldobject6' AND TABLE_NAME = 'PDBStringGlobalIndex')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBstringGlobalIndex ADD CONSTRAINT pk_datafieldobject6' , getdate(), NULL, 'UPDATING')
		
	ALTER TABLE PDBstringGlobalIndex ADD CONSTRAINT pk_datafieldobject6 PRIMARY KEY (FoldDocIndex, FoldDocFlag,DataFieldindex,StringValue)
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBstringGlobalIndex ADD CONSTRAINT pk_datafieldobject6' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBDocIdGlobalIndex'
	AND COLUMN_NAME = 'DocumentIndex')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBDocIdGlobalIndex add FoldDocIndex' , getdate(), NULL, 'UPDATING')
		
	IF EXISTS(SELECT 1 FROM  INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
					WHERE CONSTRAINT_NAME = 'pk_datafielddocument7' AND TABLE_NAME = 'PDBDocIdGlobalIndex')
	BEGIN
		ALTER TABLE PDBDocIdGlobalIndex DROP CONSTRAINT pk_datafielddocument7
	END
	IF EXISTS(SELECT 1 FROM  INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
			WHERE CONSTRAINT_NAME = 'fk_DocIdglobalind_docind' 
			AND TABLE_NAME = 'PDBDocIdGlobalIndex')
	BEGIN		
		ALTER TABLE PDBDocIdGlobalIndex DROP CONSTRAINT fk_DocIdglobalind_docind
	END	
	EXECUTE sp_rename N'PDBDocIdGlobalIndex.DocumentIndex', N'FoldDocIndex', 'COLUMN'
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBDocIdGlobalIndex add FoldDocIndex' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBDocIdGlobalIndex'
	AND COLUMN_NAME = 'FoldDocFlag')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBDocIdGlobalIndex add FoldDocFlag' , getdate(), NULL, 'UPDATING')
		
	ALTER TABLE PDBDocIdGlobalIndex ADD FoldDocFlag CHAR(1) NOT NULL CONSTRAINT DF_DocIdGlblIndx_FoldDDocFlag DEFAULT 'D' WITH VALUES  
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBDocIdGlobalIndex add FoldDocFlag' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(SELECT 1 FROM  INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
			WHERE CONSTRAINT_NAME = 'pk_datafieldobject7' AND TABLE_NAME = 'PDBDocIdGlobalIndex')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBDocIdGlobalIndex ADD CONSTRAINT pk_datafieldobject7' , getdate(), NULL, 'UPDATING')
		
	ALTER TABLE PDBDocIdGlobalIndex ADD CONSTRAINT pk_datafieldobject7 	PRIMARY KEY (FoldDocIndex, FoldDocFlag,DataFieldindex,DocIdValue)
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBDocIdGlobalIndex ADD CONSTRAINT pk_datafieldobject7' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBTextGlobalIndex'
	AND COLUMN_NAME = 'DocumentIndex')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBTextGlobalIndex add FoldDocIndex' , getdate(), NULL, 'UPDATING')
		
	IF EXISTS(SELECT 1 FROM  INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
					WHERE CONSTRAINT_NAME = 'pk_datafielddocument8' AND TABLE_NAME = 'PDBTextGlobalIndex')
	BEGIN
		ALTER TABLE PDBTextGlobalIndex DROP CONSTRAINT pk_datafielddocument8
	END
	
	IF EXISTS(SELECT 1 FROM  INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
				WHERE CONSTRAINT_NAME = 'fk_Textglobalind_docind' AND TABLE_NAME = 'PDBTextGlobalIndex')
	BEGIN
		ALTER TABLE PDBTextGlobalIndex DROP CONSTRAINT fk_Textglobalind_docind
	END
	EXECUTE sp_rename N'PDBTextGlobalIndex.DocumentIndex', N'FoldDocIndex', 'COLUMN'
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBTextGlobalIndex add FoldDocIndex' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBTextGlobalIndex'
	AND COLUMN_NAME = 'FoldDocFlag')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBTextGlobalIndex add FoldDocFlag' , getdate(), NULL, 'UPDATING')
		
	ALTER TABLE PDBTextGlobalIndex ADD FoldDocFlag CHAR(1) NOT NULL CONSTRAINT DF_TxtGlblIndx_FoldDDocFlag DEFAULT 'D' WITH VALUES  
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBTextGlobalIndex add FoldDocFlag' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(SELECT 1 FROM  INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
			WHERE CONSTRAINT_NAME = 'pk_datafieldobject8' AND TABLE_NAME = 'PDBTextGlobalIndex')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBTextGlobalIndex ADD CONSTRAINT pk_datafieldobject8' , getdate(), NULL, 'UPDATING')
		
	ALTER TABLE PDBTextGlobalIndex ADD CONSTRAINT pk_datafieldobject8 PRIMARY KEY (FoldDocIndex, FoldDocFlag,DataFieldindex)
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBTextGlobalIndex ADD CONSTRAINT pk_datafieldobject8' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT  1 FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBAlias')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBAlias') AND NAME = 'KeywordIndex')
	AND	XTYPE = 'F'
)
BEGIN
	SELECT 1
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBAlias ADD Referential Constraints to KeywordIndex column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	ALTER TABLE PDBAlias ADD CONSTRAINT fk_alias_keyind FOREIGN KEY (KeywordIndex)
		REFERENCES PDBDictionary (KeywordIndex)
	
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBAlias Referential Constraints to KeywordIndex column', GETDATE(), NULL, 'Already Updated')
END
;

IF NOT EXISTS(
	SELECT  1 FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBAlias')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBAlias') AND NAME = 'AliasIndex')
	AND	XTYPE = 'F'
)
BEGIN
	SELECT 1
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBAlias ADD Referential Constraints to AliasIndex column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY


	ALTER TABLE PDBAlias ADD CONSTRAINT fk_alias_aliasind FOREIGN KEY (AliasIndex)
		REFERENCES PDBDictionary (KeywordIndex)
	
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBAlias Referential Constraints to AliasIndex column', GETDATE(), NULL, 'Already Updated')
END
;


IF NOT EXISTS(
	SELECT  1 FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBAnnotation')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBAnnotation') AND NAME = 'DocumentIndex')
	AND	XTYPE = 'F'
)
BEGIN
	SELECT 1
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBAnnotation ADD Referential Constraints to DocumentIndex column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY


	ALTER TABLE PDBAnnotation ADD CONSTRAINT FK_annotation_docid FOREIGN KEY (DocumentIndex)
		REFERENCES PDBDocument(DocumentIndex)
	
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBAnnotation Referential Constraints to DocumentIndex column', GETDATE(), NULL, 'Already Updated')
END
;

IF NOT EXISTS(
	SELECT  1 FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBDocumentVersion')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBDocumentVersion') AND NAME = 'DocumentIndex')
	AND	XTYPE = 'F'
)
BEGIN
	SELECT 1
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDocumentVersion ADD Referential Constraints to DocumentIndex column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	ALTER TABLE PDBDocumentVersion ADD CONSTRAINT fk_docver_docind FOREIGN KEY (DocumentIndex)
		REFERENCES PDBDocument (DocumentIndex)
	
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDocumentVersion Referential Constraints to DocumentIndex column', GETDATE(), NULL, 'Already Updated')
END
;

IF NOT EXISTS(
	SELECT  1 FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBForm')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBForm') AND NAME = 'DataDefinitionIndex')
	AND	XTYPE = 'F'
)
BEGIN
	SELECT 1
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBForm ADD Referential Constraints to DataDefinitionIndex column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	ALTER TABLE PDBForm ADD CONSTRAINT fk_form_ddind FOREIGN KEY (DataDefinitionIndex)
		REFERENCES PDBDataDefinition(DataDefIndex)
	
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBForm Referential Constraints to DataDefinitionIndex column', GETDATE(), NULL, 'Already Updated')
END
;

IF NOT EXISTS(
	SELECT  1 FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBGroupRoles')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBGroupRoles') AND NAME = 'RoleIndex')
	AND	XTYPE = 'F'
)
BEGIN
	SELECT 1
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGroupRoles ADD Referential Constraints to RoleIndex column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	ALTER TABLE PDBGroupRoles ADD CONSTRAINT fk_gproles_Roleind FOREIGN KEY (RoleIndex)
		REFERENCES PDBRoles (RoleIndex)
	
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGroupRoles Referential Constraints to RoleIndex column', GETDATE(), NULL, 'Already Updated')
END
;

IF NOT EXISTS(
	SELECT  1 FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBstringGlobalIndex')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBstringGlobalIndex') AND NAME = 'DataFieldIndex')
	AND	XTYPE = 'F'
)
BEGIN
	SELECT 1
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBstringGlobalIndex ADD Referential Constraints to DataFieldIndex column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	ALTER TABLE PDBstringGlobalIndex ADD CONSTRAINT fk_Strglobalind_dfind FOREIGN KEY (DataFieldIndex)
		REFERENCES PDBGlobalIndex (DataFieldIndex)
	
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBstringGlobalIndex Referential Constraints to DataFieldIndex column', GETDATE(), NULL, 'Already Updated')
END
;

--Added by Vipin Singla
BEGIN
	SELECT 0
	SET NOCOUNT ON
	DECLARE @StepNo			int
	CREATE TABLE #indfol(index_name varchar(256), indexdesc varchar(256), indkey varchar(2126))
	INSERT INTO #indfol exec sp_helpindex 'PDBNEWAUDITTRAIL_TABLE'

	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'DateTime')
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBNewAuditTrail_Table (DateTime)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_PDBNewAuditTrail_DateTime ON PDBNewAuditTrail_Table (DateTime)

		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		SET NOCOUNT ON
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBNewAuditTrail_Table (DateTime)' , GETDATE(), NULL, 'Already Updated')
	END
	DROP TABLE #indfol
END
;


--For PDBFoldDocLockStatus
BEGIN
	SELECT 0
	SET NOCOUNT ON
	DECLARE @StepNo			int
	CREATE TABLE #indfol(index_name varchar(256), indexdesc varchar(256), indkey varchar(2126))
	INSERT INTO #indfol exec sp_helpindex 'PDBFoldDocLockStatus'

	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'FoldDocFlag, FoldDocIndex')
	BEGIN
		
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBFoldDocLockStatus Columns (FoldDocFlag, FoldDocIndex)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_PDBFoldDocLockStatus_FlgId ON PDBFoldDocLockStatus(FoldDocFlag, FoldDocIndex)

		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		
		SET NOCOUNT ON
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBFoldDocLockStatus  Columns (FoldDocFlag, FoldDocIndex)' , GETDATE(), NULL, 'Already Updated')
	END
	DROP TABLE #indfol
END
;

--For PDBLongGlobalIndex
BEGIN
	SELECT 0
	SET NOCOUNT ON
	DECLARE @StepNo			int
	CREATE TABLE #indfol(index_name varchar(256), indexdesc varchar(256), indkey varchar(2126))
	INSERT INTO #indfol exec sp_helpindex 'PDBLongGlobalIndex'

	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'DataFieldIndex, LongValue')
	BEGIN
		
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBLongGlobalIndex Columns (DataFieldIndex,LongValue)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_LongValue	ON PDBLongGlobalIndex (DataFieldIndex,LongValue)

		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		
		SET NOCOUNT ON
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBLongGlobalIndex Columns (DataFieldIndex,LongValue)' , GETDATE(), NULL, 'Already Updated')
	END
	DROP TABLE #indfol
END
;
--For PDBGlobalindex
BEGIN
	SELECT 0
	SET NOCOUNT ON
	DECLARE @StepNo			int
	CREATE TABLE #indfol(index_name varchar(256), indexdesc varchar(256), indkey varchar(2126))
	INSERT INTO #indfol exec sp_helpindex 'PDBGlobalindex'

	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'DataFieldName')
	BEGIN
		
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBGlobalindex Columns (DataFieldName)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_DataFieldName ON PDBGlobalindex (DataFieldName)

		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		
		SET NOCOUNT ON
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBGlobalindex Columns (DataFieldName)' , GETDATE(), NULL, 'Already Updated')
	END
	DROP TABLE #indfol
END
;
------------------------------------------------------------------------------------------------------------------------------------
--Changed By			: Rohika Gupta
--Reason / Cause (Bug No if Any): Change for adding pickable field to Global index
--Change Description		: Change for adding pickable field to Global index
------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBGlobalindex'
	AND COLUMN_NAME = 'Pickable')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGlobalindex add Pickable', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBGlobalindex ADD Pickable CHAR(1) NOT NULL DEFAULT 'N'

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo

	insert into PDBUpdateStatus values ('Alter View', 'Altering View PDBGTypeGlobalIndex,PDBDTypeGlobalIndex,PDBXTypeGlobalIndex add Pickable', getdate(), NULL, 'UPDATING')
	
	EXECUTE ('ALTER VIEW PDBGTypeGlobalIndex AS SELECT DataFieldIndex, DataFieldName, DataFieldType,DataFieldLength, GlobalOrDataFlag, MainGroupId, Pickable FROM PDBGlobalIndex WHERE globalordataflag = ''G''')	
	EXECUTE ('ALTER VIEW PDBDTypeGlobalIndex AS SELECT DataFieldIndex, DataFieldName, DataFieldType,DataFieldLength, GlobalOrDataFlag, MainGroupId, Pickable FROM PDBGlobalIndex WHERE globalordataflag = ''D''')	
	EXECUTE ('ALTER VIEW PDBXTypeGlobalIndex AS SELECT DataFieldIndex, DataFieldName, DataFieldType,DataFieldLength, GlobalOrDataFlag, MainGroupId, Pickable FROM PDBGlobalIndex WHERE globalordataflag = ''X''')		
		
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
        update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGlobalindex  add Pickable', getdate(), getdate(), 'ALREADY UPDATED')
	
END	
;

IF EXISTS(
	SELECT 1 FROM PDBGlobalindex
	WHERE Pickable IS NULL)
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGlobalindex Alter Pickable', getdate(), NULL, 'UPDATING')
	
	UPDATE PDBGlobalIndex SET Pickable = 'Y' 
	WHERE EXISTS (SELECT 1 FROM PDBPickList
		WHERE PDBGlobalIndex.DataFieldIndex = PDBPickList.DataFieldIndex )
	
	UPDATE PDBGlobalIndex SET Pickable = 'N' 
	WHERE NOT EXISTS (SELECT 1 FROM PDBPickList
		WHERE PDBGlobalIndex.DataFieldIndex = PDBPickList.DataFieldIndex )
	
	ALTER TABLE PDBGlobalindex ALTER COLUMN Pickable CHAR(1) NOT NULL
	ALTER TABLE PDBGlobalindex ADD CONSTRAINT def_pick DEFAULT 'N' FOR Pickable
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGlobalindex Alter Pickable', getdate(), getdate(), 'ALREADY UPDATED')
	
END	
;

--For PDBUser
BEGIN
	SELECT 0
	SET NOCOUNT ON
	DECLARE @StepNo			int
	CREATE TABLE #indfol(index_name varchar(256), indexdesc varchar(256), indkey varchar(2126))
	INSERT INTO #indfol exec sp_helpindex 'PDBUser'

	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'UserName')
	BEGIN
		
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBUser Columns (UserName)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_UserName	ON PDBUser (UserName)

		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		
		SET NOCOUNT ON
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBUser Columns (UserName)' , GETDATE(), NULL, 'Already Updated')
	END
	DROP TABLE #indfol
END
;
--for PDBGroup
BEGIN
	SELECT 0
	SET NOCOUNT ON
	DECLARE @StepNo			int
	CREATE TABLE #indfol(index_name varchar(256), indexdesc varchar(256), indkey varchar(2126))
	INSERT INTO #indfol exec sp_helpindex 'PDBGroup'

	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'GroupName, MainGroupIndex')
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBGroup Columns (GroupName, MainGroupIndex)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_GroupName	ON PDBGroup (GroupName, MainGroupIndex)

		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		
		SET NOCOUNT ON
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBGroup Columns (GroupName, MainGroupIndex)' , GETDATE(), NULL, 'Already Updated')
	END
	DROP TABLE #indfol
END
;
-- For PDBDocumentVersion
BEGIN
	SELECT 0
	SET NOCOUNT ON
	DECLARE @StepNo			int
	CREATE TABLE #indfol(index_name varchar(256), indexdesc varchar(256), indkey varchar(2126))
	INSERT INTO #indfol exec sp_helpindex 'PDBDocumentVersion'

	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'ImageIndex, VolumeIndex')
	BEGIN
		
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDocumentVersion Columns (ImageIndex, VolumeIndex)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_PDBDV_IMAGEID_VOLID ON PDBDocumentVersion (ImageIndex, VolumeIndex)

		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		
		SET NOCOUNT ON
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDocumentVersion Columns (ImageIndex, VolumeIndex)' , GETDATE(), NULL, 'Already Updated')
	END
	DROP TABLE #indfol
END
;

BEGIN
	SELECT 0
	SET NOCOUNT ON
	DECLARE @StepNo			int
	CREATE TABLE #indfol(index_name varchar(256), indexdesc varchar(256), indkey varchar(2126))
	INSERT INTO #indfol exec sp_helpindex 'PDBAnnotation'

	IF EXISTS(SELECT indkey FROM #indfol WHERE index_name = 'IDX_AnnotationName')
	BEGIN	
		INSERT INTO PDBUpdateStatus values ('Drop Index', 'Dropping extra index on Table PDBAnnotation Columns (DocumentIndex, PageNumber, AnnotationName)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		DROP INDEX PDBAnnotation.IDX_AnnotationName
		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		SET NOCOUNT ON
		INSERT INTO PDBUpdateStatus values ('Drop Index', 'Dropping extra index on Table PDBAnnotation Columns (DocumentIndex, PageNumber, AnnotationName)' , GETDATE(), NULL, 'Already Updated')
	END
	DROP TABLE #indfol
END
;
BEGIN
	SELECT 0
	SET NOCOUNT ON
	DECLARE @StepNo			int
	CREATE TABLE #indfol(index_name varchar(256), indexdesc varchar(256), indkey varchar(2126))
	INSERT INTO #indfol exec sp_helpindex 'PDBAnnotationVersion'

	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'DocumentIndex, PageNumber, AnnotationName, AnnotationVersion')
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBAnnotationVersion Columns (DocumentIndex, PageNumber, AnnotationName, AnnotationVersion)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_AnnotationVersion ON PDBAnnotationVersion (DocumentIndex, PageNumber, AnnotationName, AnnotationVersion)

		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		SET NOCOUNT ON
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBAnnotationVersion Columns (DocumentIndex, PageNumber, AnnotationName, AnnotationVersion)' , GETDATE(), NULL, 'Already Updated')
	END
	DROP TABLE #indfol
END
;
BEGIN
	SELECT 0
	SET NOCOUNT ON
	DECLARE @StepNo			int
	CREATE TABLE #indfol(index_name varchar(256), indexdesc varchar(256), indkey varchar(2126))
	INSERT INTO #indfol exec sp_helpindex 'PDBDataDefinition'

	IF EXISTS(SELECT indkey FROM #indfol WHERE index_name = 'IDX_DataDefinition')
	BEGIN	
		INSERT INTO PDBUpdateStatus values ('Drop Index', 'Dropping extra index on Table PDBDataDefinition Columns (DataDefName, GroupId)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		DROP INDEX PDBDataDefinition.IDX_DataDefinition
		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		SET NOCOUNT ON
		INSERT INTO PDBUpdateStatus values ('Drop Index', 'Dropping extra index on Table PDBDataDefinition Columns (DataDefName, GroupId)' , GETDATE(), NULL, 'Already Updated')
	END
	DROP TABLE #indfol
END
;
------------------------------------------------------------------------------------------------
-- Changed By				: Mili Das
-- Reason / Cause (Bug No if Any)	: Implementation of Role based Rights
-- Change Description			: Implementation of Role based Rights
------------------------------------------------------------------------------------------------
IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'PDBRoleGroup')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBRoleGroup' , getdate(), NULL, 'UPDATING')
	
	CREATE TABLE PDBRoleGroup( 
		GroupRoleId	INT IDENTITY(1,1) CONSTRAINT pk_GroupRoleIndex PRIMARY KEY,
		GroupIndex    	INT,
		RoleIndex      	INT,
		CONSTRAINT      uk_rolegroup UNIQUE  (GroupIndex,RoleIndex))

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBRoleGroup' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

SELECT 0
DECLARE @GroupId INT
DECLARE	@RoleId  INT
declare @stepNo int
DECLARE TempCursor CURSOR FOR SELECT DISTINCT GROUPINDEX,ROLEINDEX FROM PDBGROUPROLES

insert into PDBUpdateStatus values ('UPDATE', 'UPDATE PDBRoleGroup' , getdate(), NULL, 'UPDATING')
OPEN TempCursor
FETCH NEXT FROM TempCursor INTO @GroupId,@RoleId

WHILE @@Fetch_Status = 0
BEGIN
	INSERT INTO PDBROLEGROUP(GroupIndex,RoleIndex) VALUES(@GroupId,@RoleId)
	
	FETCH NEXT FROM TempCursor INTO @GroupId,@RoleId
END
CLOSE TempCursor
DEALLOCATE TempCursor

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
;
------------------------------------------------------------------------------------------------
-- Changed By				: Mili Das
-- Reason / Cause (Bug No if Any)	: Changes for assigning Rights to Roles on DataClass/Cabinet
-- Change Description			: Changes for assigning Rights to Roles on DataClass/Cabinet
------------------------------------------------------------------------------------------------
IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'PDBRoleRights')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBRoleRights' , getdate(), NULL, 'UPDATING')
	
	CREATE TABLE PDBRoleRights
(
	RoleIndex	INT,
	ObjectType    	CHAR(1) CONSTRAINT ck_ObjectType CHECK (ObjectType IN ('T','C')),
	ObjectIndex     INT,
	ACL		CHAR(10),
	FromDate 	DateTime NULL,
	ToDate 		DateTime NULL,
	CONSTRAINT   pk_rolerights PRIMARY KEY(RoleIndex,ObjectType,ObjectIndex)
	)

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBRoleRights' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
-------------------------------------------------------------------------------------------
-- Changed By				: Vipin Kumar Singla
-- Reason / Cause (Bug No if Any)	: Adding tables for Scheduler Framework
-- Change Description			: Adding tables for Scheduler Framework
-------------------------------------------------------------------------------------------
IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'PDBSERVICETYPE')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBServiceType' , getdate(), NULL, 'UPDATING')
		
	CREATE TABLE PDBServiceType
	(
		  ServiceTypeId INT IDENTITY(1,1),
		  Name NVARCHAR(255) NOT NULL,
		  Description NVARCHAR(512),
		  CLASS VARCHAR(255) NOT NULL,
		  CommonInfo NVARCHAR(2000),
		  ClientData NVARCHAR(1000),
		  CONSTRAINT PK_PDBServiceType PRIMARY KEY (ServiceTypeId ),
		  CONSTRAINT UK_ServiceTypeName UNIQUE(Name)
	)
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBServiceType' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'PDBREGISTEREDSERVICE')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBRegisteredService' , getdate(), NULL, 'UPDATING')
		
	CREATE TABLE PDBRegisteredService
	(
		  ServiceId INT IDENTITY(1,1),
		  Name NVARCHAR(255) NOT NULL,
		  ServiceType INT REFERENCES PDBServiceType(ServiceTypeId),
		  Description NVARCHAR(1000),
		  SchedulerLoc NVARCHAR(255) NOT NULL,
		  SchedulerName NVARCHAR(255) NOT NULL,
		  StartTime VARCHAR(255) NOT NULL,
		  Duration FLOAT NOT NULL,
		  CronExpression NVARCHAR(255) NOT NULL,
		  LastExecutionTime DATETIME NULL,
		  Status NVARCHAR(255) NOT NULL,
		  ServiceData Text,
		  CONSTRAINT PK_PDBRegisteredService PRIMARY KEY (ServiceId),
		  CONSTRAINT UK_ServiceName UNIQUE(Name)
	)
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBRegisteredService' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
BEGIN
	 SELECT 0
	 declare @stepNo int
	 IF NOT EXISTS(SELECT id FROM PDBConstant WHERE id = -50243)
	 BEGIN

		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(-50243)', getdate(), NULL, 'UPDATING')

		INSERT INTO PDBConstant VALUES(-50243,'PRT_ERR_SvcTypeName_Already_Exist','Error')
		
		select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
		update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
	 END 
	 ELSE
	 BEGIN
		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(-50243)', getdate(), getdate(), 'ALREADY UPDATED')
	 END

	 IF NOT EXISTS(SELECT id FROM PDBConstant WHERE id = -50244)
	 BEGIN

		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(-50244)', getdate(), NULL, 'UPDATING')

		INSERT INTO PDBConstant VALUES(-50244,'PRT_ERR_SvcType_Not_Exist','Error')
		
		select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
		update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
	 END 
	 ELSE
	 BEGIN
		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(-50244)', getdate(), getdate(), 'ALREADY UPDATED')
	 END

	 IF NOT EXISTS(SELECT id FROM PDBConstant WHERE id = -50245)
	 BEGIN

		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(-50245)', getdate(), NULL, 'UPDATING')

		INSERT INTO PDBConstant VALUES(-50245,'PRT_ERR_SvcName_Already_Exist','Error')
		
		select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
		update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
	 END 
	 ELSE
	 BEGIN
		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(-50245)', getdate(), getdate(), 'ALREADY UPDATED')
	 END

	 IF NOT EXISTS(SELECT id FROM PDBConstant WHERE id = -50246)
	 BEGIN

		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(-50246)', getdate(), NULL, 'UPDATING')

		INSERT INTO PDBConstant VALUES(-50246,'PRT_ERR_Svc_Not_Exist','Error')
		
		select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
		update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
	 END 
	 ELSE
	 BEGIN
		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(-50246)', getdate(), getdate(), 'ALREADY UPDATED')
	 END

	 IF NOT EXISTS(SELECT id FROM PDBConstant WHERE id = -50247)
	 BEGIN

		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(-50247)', getdate(), NULL, 'UPDATING')

		INSERT INTO PDBConstant VALUES(-50247,'PRT_ERR_Svc_Exist_For_SvcType','Error')
		
		select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
		update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
	 END 
	 ELSE
	 BEGIN
		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(-50247)', getdate(), getdate(), 'ALREADY UPDATED')
	 END
END
;

BEGIN
	 SELECT 0
	 declare @stepNo int
	 
	 IF NOT EXISTS(SELECT id FROM PDBConstant WHERE id = -50248)
	 BEGIN

		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(-50248)', getdate(), NULL, 'UPDATING')

		INSERT INTO PDBConstant VALUES(-50248,'PRT_ERR_MaxNoOfExternalPortalUsers_Exceeded','Error')
		
		select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
		update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
	 END 
	 ELSE
	 BEGIN
		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(-50248)', getdate(), getdate(), 'ALREADY UPDATED')
	 END

	 IF NOT EXISTS(SELECT id FROM PDBConstant WHERE id = -50249)
	 BEGIN

		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(-50249)', getdate(), NULL, 'UPDATING')

		INSERT INTO PDBConstant VALUES(-50249,'PRT_ERR_MaxNoOfInternalPortalUsers_Exceeded','Error')
		
		select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
		update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
	 END 
	 ELSE
	 BEGIN
		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(-50249)', getdate(), getdate(), 'ALREADY UPDATED')
	 END
END
;

--Check constraint of Flag1 modified to include 'R'
BEGIN
	SELECT 0
	DECLARE @name varchar(900)

	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBRights ADD CONSTRAINT', getdate(), NULL, 'UPDATING')

	SELECT @name = Name FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBRights')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBRights') AND NAME = 'Flag1')
	AND	XTYPE = 'C'

	IF (@@ROWCOUNT > 0)
	BEGIN
		EXECUTE ('ALTER TABLE PDBRights DROP CONSTRAINT ' + @name)
	END

	EXECUTE ('ALTER TABLE PDBRights WITH NOCHECK ADD CONSTRAINT ck_rights_flag1 CHECK ([Flag1] = ''U'' or [Flag1] = ''G'' or [Flag1] = ''R'' )')

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
;

--Vipin Started
IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBCabinet'
	AND COLUMN_NAME = 'LockByUser'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBCabinet Alter Column LockByUser', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBCabinet ALTER COLUMN LockByUser INT NOT NULL
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBCabinet Alter Column LockByUser', getdate(), getdate(), 'ALREADY UPDATED')
	
END	
;

IF EXISTS(
	SELECT  1 FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('UserSecurity')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('UserSecurity') AND NAME = 'UserIndex')
	AND	XTYPE = 'F'
)
AND 
NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUser'
	AND COLUMN_NAME = 'UserIndex'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	
	DECLARE @StepNo			int
	DECLARE @ConsName		NVARCHAR(255)

	SELECT  @ConsName = name FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('UserSecurity')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('UserSecurity') AND NAME = 'UserIndex')
	AND	XTYPE = 'F'

	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table UserSecurity DROP Referential Constraints to UserIndex column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	EXECUTE ('ALTER TABLE UserSecurity DROP CONSTRAINT ' + @ConsName)

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table UserSecurity DROP Referential Constraints to UserIndex column', GETDATE(), NULL, 'Already Updated')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUser'
	AND COLUMN_NAME = 'UserIndex'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	DECLARE @StepNo			int
	DECLARE @IndexName		NVARCHAR(255)
	CREATE TABLE #indfol(index_name varchar(256), indexdesc varchar(256), indkey varchar(2126))
	INSERT INTO #indfol exec sp_helpindex 'UserSecurity'

	IF EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'UserIndex')
	BEGIN
		SELECT 1
		SET NOCOUNT ON
		SELECT @IndexName = index_name FROM #indfol WHERE indkey = 'UserIndex'
		
		INSERT INTO PDBUpdateStatus values ('Drop Index', 'Dropping index on Table UserSecurity Columns (UserIndex)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		EXECUTE('DROP INDEX UserSecurity.' + @IndexName)

		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		SELECT 0
		SET NOCOUNT ON
		INSERT INTO PDBUpdateStatus values ('Drop Index', 'Dropping index on Table UserSecurity Columns (UserIndex)'  , GETDATE(), NULL, 'Already Updated')
	END
	DROP TABLE #indfol
END
ELSE
	BEGIN
		SELECT 0
		SET NOCOUNT ON
		INSERT INTO PDBUpdateStatus values ('Drop Index', 'Dropping index on Table UserSecurity Columns (UserIndex)1'  , GETDATE(), NULL, 'Already Updated')
	END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'UserSecurity'
	AND COLUMN_NAME = 'UserIndex'
	AND DATA_TYPE = 'INT'
	)
AND 
NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUser'
	AND COLUMN_NAME = 'UserIndex'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table UserSecurity Alter Column UserIndex', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE UserSecurity ALTER COLUMN UserIndex INT NOT NULL
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table UserSecurity Alter Column UserIndex', getdate(), getdate(), 'ALREADY UPDATED')
	
END	
;


IF EXISTS(
	SELECT  1 FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBGroup')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBGroup') AND NAME = 'Owner')
	AND	XTYPE = 'F'
)
AND 
NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUser'
	AND COLUMN_NAME = 'UserIndex'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	
	DECLARE @StepNo			int
	DECLARE @ConsName		NVARCHAR(255)

	SELECT  @ConsName = name FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBGroup')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBGroup') AND NAME = 'Owner')
	AND	XTYPE = 'F'

	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGroup DROP Referential Constraints to Owner column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	EXECUTE ('ALTER TABLE PDBGroup DROP CONSTRAINT ' + @ConsName)

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGroup DROP Referential Constraints to Owner column', GETDATE(), NULL, 'Already Updated')
END
;


IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBGroup'
	AND COLUMN_NAME = 'Owner'
	AND DATA_TYPE = 'INT'
	)
AND 
NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUser'
	AND COLUMN_NAME = 'UserIndex'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGroup Alter Column Owner', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBGroup ALTER COLUMN Owner INT NOT NULL
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGroup Alter Column Owner', getdate(), getdate(), 'ALREADY UPDATED')
	
END	
;


IF EXISTS(
	SELECT  1 FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBFolder')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBFolder') AND NAME = 'Owner')
	AND	XTYPE = 'F'
)
AND 
NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUser'
	AND COLUMN_NAME = 'UserIndex'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	
	DECLARE @StepNo			int
	DECLARE @ConsName		NVARCHAR(255)

	SELECT  @ConsName = name FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBFolder')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBFolder') AND NAME = 'Owner')
	AND	XTYPE = 'F'

	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBFolder DROP Referential Constraints to Owner column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	EXECUTE ('ALTER TABLE PDBFolder DROP CONSTRAINT ' + @ConsName)

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBFolder DROP Referential Constraints to Owner column', GETDATE(), NULL, 'Already Updated')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUser'
	AND COLUMN_NAME = 'UserIndex'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	DECLARE @StepNo			int
	DECLARE @IndexName		NVARCHAR(255)
	CREATE TABLE #indfol(index_name varchar(256), indexdesc varchar(256), indkey varchar(2126))
	INSERT INTO #indfol exec sp_helpindex 'PDBFolder'

	IF EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'Owner')
	BEGIN
		SELECT 1

		SELECT @IndexName = index_name FROM #indfol WHERE indkey = 'Owner'
		
		INSERT INTO PDBUpdateStatus values ('Drop Index', 'Dropping index on Table PDBFolder Columns (Owner)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		EXECUTE('DROP INDEX PDBFolder.' + @IndexName)

		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		SELECT 0
		SET NOCOUNT ON
		INSERT INTO PDBUpdateStatus values ('Drop Index', 'Dropping index on Table PDBFolder Columns (Owner)'  , GETDATE(), NULL, 'Already Updated')
	END
	DROP TABLE #indfol
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Drop Index', 'Dropping index on Table PDBFolder Columns (Owner)'  , GETDATE(), NULL, 'Already Updated')
	
END	
;


IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBFolder'
	AND COLUMN_NAME = 'Owner'
	AND DATA_TYPE = 'INT'
	)
AND 
NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUser'
	AND COLUMN_NAME = 'UserIndex'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBFolder Alter Column Owner', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBFolder ALTER COLUMN Owner INT NOT NULL
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBFolder Alter Column Owner', getdate(), getdate(), 'ALREADY UPDATED')
	
END	
;

IF EXISTS(
	SELECT  1 FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBForm')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBForm') AND NAME = 'Owner')
	AND	XTYPE = 'F'
)
AND 
NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUser'
	AND COLUMN_NAME = 'UserIndex'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	
	DECLARE @StepNo			int
	DECLARE @ConsName		NVARCHAR(255)

	SELECT  @ConsName = name FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBForm')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBForm') AND NAME = 'Owner')
	AND	XTYPE = 'F'

	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBForm DROP Referential Constraints to Owner column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	EXECUTE ('ALTER TABLE PDBForm DROP CONSTRAINT ' + @ConsName)

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBForm DROP Referential Constraints to Owner column', GETDATE(), NULL, 'Already Updated')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBForm'
	AND COLUMN_NAME = 'Owner'
	AND DATA_TYPE = 'INT'
	)
AND 
NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUser'
	AND COLUMN_NAME = 'UserIndex'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBForm Alter Column Owner', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBForm ALTER COLUMN Owner INT NOT NULL
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBForm Alter Column Owner', getdate(), getdate(), 'ALREADY UPDATED')
	
END	
;

IF EXISTS(
	SELECT  1 FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBDocument')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBDocument') AND NAME = 'Owner')
	AND	XTYPE = 'F'
)
AND 
NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUser'
	AND COLUMN_NAME = 'UserIndex'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	
	DECLARE @StepNo			int
	DECLARE @ConsName		NVARCHAR(255)

	SELECT  @ConsName = name FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBDocument')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBDocument') AND NAME = 'Owner')
	AND	XTYPE = 'F'

	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDocument DROP Referential Constraints to Owner column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	EXECUTE ('ALTER TABLE PDBDocument DROP CONSTRAINT ' + @ConsName)

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDocument DROP Referential Constraints to Owner column', GETDATE(), NULL, 'Already Updated')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUser'
	AND COLUMN_NAME = 'UserIndex'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	DECLARE @StepNo			int
	DECLARE @IndexName		NVARCHAR(255)
	CREATE TABLE #indfol(index_name varchar(256), indexdesc varchar(256), indkey varchar(2126))
	INSERT INTO #indfol exec sp_helpindex 'PDBDocument'

	IF EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'Owner')
	BEGIN
		SELECT 1
		SET NOCOUNT ON
		SELECT @IndexName = index_name FROM #indfol WHERE indkey = 'Owner'
		
		INSERT INTO PDBUpdateStatus values ('Drop Index', 'Dropping index on Table PDBDocument Columns (Owner)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		EXECUTE('DROP INDEX PDBDocument.' + @IndexName)

		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		SELECT 0
		SET NOCOUNT ON
		INSERT INTO PDBUpdateStatus values ('Drop Index', 'Dropping index on Table PDBDocument Columns (Owner)'  , GETDATE(), NULL, 'Already Updated')
	END
	DROP TABLE #indfol
END
ELSE
	BEGIN
		SELECT 0
		SET NOCOUNT ON
		INSERT INTO PDBUpdateStatus values ('Drop Index', 'Dropping index on Table PDBDocument Columns (Owner)1'  , GETDATE(), NULL, 'Already Updated')
	END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBDocument'
	AND COLUMN_NAME = 'Owner'
	AND DATA_TYPE = 'INT'
	)
AND 
NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUser'
	AND COLUMN_NAME = 'UserIndex'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDocument Alter Column Owner', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBDocument ALTER COLUMN Owner INT NOT NULL
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDocument Alter Column Owner', getdate(), getdate(), 'ALREADY UPDATED')
	
END	
;

IF EXISTS(
	SELECT  1 FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBFolderContent')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBFolderContent') AND NAME = 'FiledBy')
	AND	XTYPE = 'F'
)
AND 
NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUser'
	AND COLUMN_NAME = 'UserIndex'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	
	DECLARE @StepNo			int
	DECLARE @ConsName		NVARCHAR(255)

	SELECT  @ConsName = name FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBFolderContent')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBFolderContent') AND NAME = 'FiledBy')
	AND	XTYPE = 'F'

	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBFolderContent DROP Referential Constraints to FiledBy column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	EXECUTE ('ALTER TABLE PDBFolderContent DROP CONSTRAINT ' + @ConsName)

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBFolderContent DROP Referential Constraints to FiledBy column', GETDATE(), NULL, 'Already Updated')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBFolderContent'
	AND COLUMN_NAME = 'FiledBy'
	AND DATA_TYPE = 'INT'
	)
AND 
NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUser'
	AND COLUMN_NAME = 'UserIndex'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBFolderContent Alter Column FiledBy', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBFolderContent ALTER COLUMN FiledBy INT NOT NULL
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBFolderContent Alter Column FiledBy', getdate(), getdate(), 'ALREADY UPDATED')
	
END	
;

IF EXISTS(
	SELECT  1 FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBAnnotation')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBAnnotation') AND NAME = 'Owner')
	AND	XTYPE = 'F'
)
AND 
NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUser'
	AND COLUMN_NAME = 'UserIndex'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	
	DECLARE @StepNo			int
	DECLARE @ConsName		NVARCHAR(255)

	SELECT  @ConsName = name FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBAnnotation')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBAnnotation') AND NAME = 'Owner')
	AND	XTYPE = 'F'

	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBAnnotation DROP Referential Constraints to Owner column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	EXECUTE ('ALTER TABLE PDBAnnotation DROP CONSTRAINT ' + @ConsName)

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBAnnotation DROP Referential Constraints to Owner column', GETDATE(), NULL, 'Already Updated')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBAnnotation'
	AND COLUMN_NAME = 'Owner'
	AND DATA_TYPE = 'INT'
	)
AND 
NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUser'
	AND COLUMN_NAME = 'UserIndex'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBAnnotation Alter Column Owner', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBAnnotation ALTER COLUMN Owner INT NOT NULL
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBAnnotation Alter Column Owner', getdate(), getdate(), 'ALREADY UPDATED')
	
END	
;

IF EXISTS(
	SELECT  1 FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBGroupRoles')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBGroupRoles') AND NAME = 'UserIndex')
	AND	XTYPE = 'F'
)
AND 
NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUser'
	AND COLUMN_NAME = 'UserIndex'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	
	DECLARE @StepNo			int
	DECLARE @ConsName		NVARCHAR(255)

	SELECT  @ConsName = name FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBGroupRoles')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBGroupRoles') AND NAME = 'UserIndex')
	AND	XTYPE = 'F'

	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGroupRoles DROP Referential Constraints to UserIndex column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	EXECUTE ('ALTER TABLE PDBGroupRoles DROP CONSTRAINT ' + @ConsName)

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGroupRoles DROP Referential Constraints to UserIndex column', GETDATE(), NULL, 'Already Updated')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBGroupRoles'
	AND COLUMN_NAME = 'UserIndex'
	AND DATA_TYPE = 'INT'
	)
AND 
NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUser'
	AND COLUMN_NAME = 'UserIndex'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGroupRoles Alter Column UserIndex', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBGroupRoles ALTER COLUMN UserIndex INT NOT NULL
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGroupRoles Alter Column UserIndex', getdate(), getdate(), 'ALREADY UPDATED')
	
END	
;

IF EXISTS(
	SELECT  1 FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBGroupMember')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBGroupMember') AND NAME = 'UserIndex')
	AND	XTYPE = 'F'
)
AND 
NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUser'
	AND COLUMN_NAME = 'UserIndex'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	
	DECLARE @StepNo			int
	DECLARE @ConsName		NVARCHAR(255)

	SELECT  @ConsName = name FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBGroupMember')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBGroupMember') AND NAME = 'UserIndex')
	AND	XTYPE = 'F'

	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGroupMember DROP Referential Constraints to UserIndex column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	EXECUTE ('ALTER TABLE PDBGroupMember DROP CONSTRAINT ' + @ConsName)

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGroupMember DROP Referential Constraints to UserIndex column', GETDATE(), NULL, 'Already Updated')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUser'
	AND COLUMN_NAME = 'UserIndex'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	DECLARE @StepNo			int
	DECLARE @IndexName		NVARCHAR(255)
	CREATE TABLE #indfol(index_name varchar(256), indexdesc varchar(256), indkey varchar(2126))
	INSERT INTO #indfol exec sp_helpindex 'PDBGroupMember'

	IF EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'UserIndex')
	BEGIN
		SELECT 1
		SET NOCOUNT ON
		SELECT @IndexName = index_name FROM #indfol WHERE indkey = 'UserIndex'
		
		INSERT INTO PDBUpdateStatus values ('Drop Index', 'Dropping index on Table PDBGroupMember Columns (UserIndex)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		EXECUTE('DROP INDEX PDBGroupMember.' + @IndexName)

		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		SELECT 0
		SET NOCOUNT ON
		INSERT INTO PDBUpdateStatus values ('Drop Index', 'Dropping index on Table PDBGroupMember Columns (UserIndex)'  , GETDATE(), NULL, 'Already Updated')
	END
	DROP TABLE #indfol
END
ELSE
	BEGIN
		SELECT 0
		SET NOCOUNT ON
		INSERT INTO PDBUpdateStatus values ('Drop Index', 'Dropping index on Table PDBGroupMember Columns (UserIndex)1'  , GETDATE(), NULL, 'Already Updated')
END
;

IF EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
		WHERE TABLE_NAME = 'PDBGroupMember'
		AND CONSTRAINT_NAME = 'pk_UserGroup'
)
AND 
NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUser'
	AND COLUMN_NAME = 'UserIndex'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	
	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGroupMember DROP Primary Key Constraints to UserIndex column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	ALTER TABLE PDBGroupMember DROP CONSTRAINT pk_UserGroup
	
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGroupMember DROP Primary Key Constraints to UserIndex column', GETDATE(), NULL, 'Already Updated')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBGroupMember'
	AND COLUMN_NAME = 'UserIndex'
	AND DATA_TYPE = 'INT'
	)
AND 
NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUser'
	AND COLUMN_NAME = 'UserIndex'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGroupMember Alter Column UserIndex', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBGroupMember ALTER COLUMN UserIndex INT NOT NULL
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGroupMember Alter Column UserIndex', getdate(), getdate(), 'ALREADY UPDATED')
	
END	
;

------------------------------------------------------------------------------
------------------------------------------------------------------------------
------------------------------------------------------------------------------
IF EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
		WHERE TABLE_NAME = 'PDBUser'
		AND CONSTRAINT_NAME = 'pk_userind'
)
AND 
NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUser'
	AND COLUMN_NAME = 'UserIndex'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	
	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUser DROP Primary Key Constraints to UserIndex column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	ALTER TABLE PDBUSer DROP CONSTRAINT pk_userind
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUser DROP Primary Key Constraints to UserIndex column', GETDATE(), NULL, 'Already Updated')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUser'
	AND COLUMN_NAME = 'UserIndex'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUser Alter Column UserIndex', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBUser ALTER COLUMN UserIndex INT
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUser Alter Column UserIndex', getdate(), getdate(), 'ALREADY UPDATED')
	
END	
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
		WHERE TABLE_NAME = 'PDBUser'
		AND CONSTRAINT_NAME = 'pk_userind'
)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	
	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUser ADD Primary Key Constraints to UserIndex column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	ALTER TABLE PDBUSer ADD CONSTRAINT pk_userind PRIMARY KEY (UserIndex)
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUser ADD Primary Key Constraints to UserIndex column', GETDATE(), NULL, 'Already Updated')
END
;

------------------------------------------------------------------------------
------------------------------------------------------------------------------
------------------------------------------------------------------------------

--For UserSecurity
BEGIN
	SELECT 1
	SET NOCOUNT ON
	DECLARE @StepNo			int
	CREATE TABLE #indfol(index_name varchar(256), indexdesc varchar(256), indkey varchar(2126))
	INSERT INTO #indfol exec sp_helpindex 'UserSecurity'

	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'UserIndex')
	BEGIN
		SELECT 1
		SET NOCOUNT ON
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table UserSecurity Columns (UserIndex)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_UserSecurity_UserIndex ON UserSecurity (UserIndex)

		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		SELECT 0
		SET NOCOUNT ON
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table UserSecurity  Columns (UserIndex)' , GETDATE(), NULL, 'Already Updated')
	END
	DROP TABLE #indfol
END
;

IF NOT EXISTS(
	SELECT  1 FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('UserSecurity')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('UserSecurity') AND NAME = 'UserIndex')
	AND	XTYPE = 'F'
)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	
	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table UserSecurity ADD Referential Constraints to UserIndex column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	ALTER TABLE UserSecurity ADD CONSTRAINT fk_us_uind FOREIGN KEY (UserIndex)
		REFERENCES PDBUser(UserIndex)
	
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table UserSecurity ADD Referential Constraints to UserIndex column', GETDATE(), NULL, 'Already Updated')
END
;

IF NOT EXISTS(
	SELECT  1 FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBGroup')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBGroup') AND NAME = 'Owner')
	AND	XTYPE = 'F'
)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	
	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGroup ADD Referential Constraints to Owner column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	ALTER TABLE PDBGroup ADD CONSTRAINT fk_gp_owner FOREIGN KEY (Owner)
		REFERENCES PDBUser(UserIndex)
	
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGroup ADD Referential Constraints to Owner column', GETDATE(), NULL, 'Already Updated')
END
;

BEGIN
	SELECT 1
	SET NOCOUNT ON
	DECLARE @StepNo			int
	CREATE TABLE #indfol(index_name varchar(256), indexdesc varchar(256), indkey varchar(2126))
	INSERT INTO #indfol exec sp_helpindex 'PDBFolder'

	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'Owner')
	BEGIN
		SELECT 1
		SET NOCOUNT ON	
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBFolder Columns (Owner)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_FolderOwner ON PDBFolder (Owner)

		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		SELECT 0
		SET NOCOUNT ON
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBFolder  Columns (Owner)' , GETDATE(), NULL, 'Already Updated')
	END
	DROP TABLE #indfol
END
;

IF NOT EXISTS(
	SELECT  1 FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBFolder')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBFolder') AND NAME = 'Owner')
	AND	XTYPE = 'F'
)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	
	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBFolder ADD Referential Constraints to Owner column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	ALTER TABLE PDBFolder ADD CONSTRAINT fk_folder_owner FOREIGN KEY (Owner)
		REFERENCES PDBUser(UserIndex)
	
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBFolder ADD Referential Constraints to Owner column', GETDATE(), NULL, 'Already Updated')
END
;

IF NOT EXISTS(
	SELECT  1 FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBForm')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBForm') AND NAME = 'Owner')
	AND	XTYPE = 'F'
)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	
	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBForm ADD Referential Constraints to Owner column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	ALTER TABLE PDBForm ADD CONSTRAINT fk_form_owner FOREIGN KEY (Owner)
		REFERENCES PDBUser(UserIndex)
	
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBForm ADD Referential Constraints to Owner column', GETDATE(), NULL, 'Already Updated')
END
;

BEGIN
	SELECT 1
	SET NOCOUNT ON
	DECLARE @StepNo			int
	CREATE TABLE #indfol(index_name varchar(256), indexdesc varchar(256), indkey varchar(2126))
	INSERT INTO #indfol exec sp_helpindex 'PDBDocument'

	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'Owner')
	BEGIN
		SELECT 1
		
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDocument Columns (Owner)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_DocumentOwner ON PDBDocument (Owner)

		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		SELECT 0
		SET NOCOUNT ON
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDocument  Columns (Owner)' , GETDATE(), NULL, 'Already Updated')
	END
	DROP TABLE #indfol
END
;

IF NOT EXISTS(
	SELECT  1 FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBDocument')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBDocument') AND NAME = 'Owner')
	AND	XTYPE = 'F'
)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	
	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDocument ADD Referential Constraints to Owner column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	ALTER TABLE PDBDocument ADD CONSTRAINT fk_doc_owner FOREIGN KEY (Owner)
		REFERENCES PDBUser(UserIndex)
	
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDocument ADD Referential Constraints to Owner column', GETDATE(), NULL, 'Already Updated')
END
;

IF NOT EXISTS(
	SELECT  1 FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBFolderContent')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBFolderContent') AND NAME = 'FiledBy')
	AND	XTYPE = 'F'
)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	
	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBFolderContent ADD Referential Constraints to FiledBy column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	ALTER TABLE PDBFolderContent ADD CONSTRAINT fk_fct_filedby FOREIGN KEY (FiledBy)
		REFERENCES PDBUser(UserIndex)
	
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBFolderContent ADD Referential Constraints to FiledBy column', GETDATE(), NULL, 'Already Updated')
END
;

IF NOT EXISTS(
	SELECT  1 FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBAnnotation')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBAnnotation') AND NAME = 'Owner')
	AND	XTYPE = 'F'
)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	
	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBAnnotation ADD Referential Constraints to Owner column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	ALTER TABLE PDBAnnotation ADD CONSTRAINT FK_annotation_owner FOREIGN KEY (Owner)
		REFERENCES PDBUser(UserIndex)
	
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBAnnotation ADD Referential Constraints to Owner column', GETDATE(), NULL, 'Already Updated')
END
;

IF NOT EXISTS(
	SELECT  1 FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBGroupRoles')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBGroupRoles') AND NAME = 'UserIndex')
	AND	XTYPE = 'F'
)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	
	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGroupRoles ADD Referential Constraints to UserIndex column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	ALTER TABLE PDBGroupRoles ADD CONSTRAINT fk_gproles_uind FOREIGN KEY (UserIndex)
		REFERENCES PDBUser(UserIndex)
	
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGroupRoles ADD Referential Constraints to UserIndex column', GETDATE(), NULL, 'Already Updated')
END
;

BEGIN
SELECT 1
	SET NOCOUNT ON
	DECLARE @StepNo			int
	CREATE TABLE #indfol(index_name varchar(256), indexdesc varchar(256), indkey varchar(2126))
	INSERT INTO #indfol exec sp_helpindex 'PDBGroupMember'

	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'UserIndex')
	BEGIN
		SELECT 1
		SET NOCOUNT ON
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBGroupMember Columns (UserIndex)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_PDBGroupMember_UserIndex ON PDBGroupMember(UserIndex)

		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		SELECT 0
		SET NOCOUNT ON
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBGroupMember  Columns (UserIndex)' , GETDATE(), NULL, 'Already Updated')
	END
	DROP TABLE #indfol
END
;

IF NOT EXISTS(
	SELECT  1 FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBGroupMember')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBGroupMember') AND NAME = 'UserIndex')
	AND	XTYPE = 'F'
)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	
	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGroupMember ADD Referential Constraints to UserIndex column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	ALTER TABLE PDBGroupMember ADD CONSTRAINT fk_gpmember_userind FOREIGN KEY (UserIndex)
		REFERENCES PDBUser(UserIndex)
	
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGroupMember ADD Referential Constraints to UserIndex column', GETDATE(), NULL, 'Already Updated')
END
;

IF EXISTS(
	SELECT  1 FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBGroupRoles')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBGroupRoles') AND NAME = 'GroupIndex')
	AND	XTYPE = 'F'
)
AND 
NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBGroup'
	AND COLUMN_NAME = 'GroupIndex'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	
	DECLARE @StepNo			int
	DECLARE @ConsName		NVARCHAR(255)

	SELECT  @ConsName = name FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBGroupRoles')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBGroupRoles') AND NAME = 'GroupIndex')
	AND	XTYPE = 'F'

	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGroupRoles DROP Referential Constraints to GroupIndex column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	EXECUTE ('ALTER TABLE PDBGroupRoles DROP CONSTRAINT ' + @ConsName)

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGroupRoles DROP Referential Constraints to GroupIndex column', GETDATE(), NULL, 'Already Updated')
END
;


IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBGroupRoles'
	AND COLUMN_NAME = 'GroupIndex'
	AND DATA_TYPE = 'INT'
	)
AND 
NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBGroup'
	AND COLUMN_NAME = 'GroupIndex'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGroupRoles Alter Column GroupIndex', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBGroupRoles ALTER COLUMN GroupIndex INT NOT NULL
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGroupRoles Alter Column GroupIndex', getdate(), getdate(), 'ALREADY UPDATED')
	
END	
;


IF EXISTS(
	SELECT  1 FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBGroupMember')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBGroupMember') AND NAME = 'GroupIndex')
	AND	XTYPE = 'F'
)
AND 
NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBGroup'
	AND COLUMN_NAME = 'GroupIndex'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	
	DECLARE @StepNo			int
	DECLARE @ConsName		NVARCHAR(255)

	SELECT  @ConsName = name FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBGroupMember')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBGroupMember') AND NAME = 'GroupIndex')
	AND	XTYPE = 'F'

	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGroupMember DROP Referential Constraints to GroupIndex column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	EXECUTE ('ALTER TABLE PDBGroupMember DROP CONSTRAINT ' + @ConsName)

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGroupMember DROP Referential Constraints to GroupIndex column', GETDATE(), NULL, 'Already Updated')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBGroupMember'
	AND COLUMN_NAME = 'GroupIndex'
	AND DATA_TYPE = 'INT'
	)
AND 
NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBGroup'
	AND COLUMN_NAME = 'GroupIndex'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGroupMember Alter Column GroupIndex', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBGroupMember ALTER COLUMN GroupIndex INT NOT NULL
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGroupMember Alter Column GroupIndex', getdate(), getdate(), 'ALREADY UPDATED')
	
END	
;

------------------------------------------------------------------------------
------------------------------------------------------------------------------
------------------------------------------------------------------------------
IF EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
		WHERE TABLE_NAME = 'PDBGroup'
		AND CONSTRAINT_NAME = 'pk_groupind'
)
AND 
NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBGroup'
	AND COLUMN_NAME = 'GroupIndex'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	
	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGroup DROP Primary Key Constraints to GroupIndex column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	ALTER TABLE PDBGroup DROP CONSTRAINT pk_groupind
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGroup DROP Primary Key Constraints to GroupIndex column', GETDATE(), NULL, 'Already Updated')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBGroup'
	AND COLUMN_NAME = 'GroupIndex'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGroup Alter Column GroupIndex', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBGroup ALTER COLUMN GroupIndex INT
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGroup Alter Column GroupIndex', getdate(), getdate(), 'ALREADY UPDATED')
	
END	
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
		WHERE TABLE_NAME = 'PDBGroup'
		AND CONSTRAINT_NAME = 'pk_groupind'
)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	
	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGroup ADD Primary Key Constraints to GroupIndex column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	ALTER TABLE PDBGroup ADD CONSTRAINT pk_groupind PRIMARY KEY (GroupIndex)
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGroup ADD Primary Key Constraints to GroupIndex column', GETDATE(), NULL, 'Already Updated')
END
;

IF NOT EXISTS(
	SELECT  1 FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBGroupRoles')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBGroupRoles') AND NAME = 'GroupIndex')
	AND	XTYPE = 'F'
)
BEGIN
	SELECT 1
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGroupRoles ADD Referential Constraints to GroupIndex column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	ALTER TABLE PDBGroupRoles ADD CONSTRAINT fk_gproles_gpind FOREIGN KEY (GroupIndex)
		REFERENCES PDBGroup (GroupIndex)
	
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGroupRoles Referential Constraints to GroupIndex column', GETDATE(), NULL, 'Already Updated')
END
;

IF NOT EXISTS(
	SELECT  1 FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBGroupMember')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBGroupMember') AND NAME = 'GroupIndex')
	AND	XTYPE = 'F'
)
BEGIN
	SELECT 1
	SET NOCOUNT ON

	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGroupMember ADD Referential Constraints to GroupIndex column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY


	ALTER TABLE PDBGroupMember ADD CONSTRAINT fk_gpmember_gpind FOREIGN KEY (GroupIndex)
		REFERENCES PDBGroup (GroupIndex)
	
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGroupMember Referential Constraints to GroupIndex column', GETDATE(), NULL, 'Already Updated')
END
;


IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
		WHERE TABLE_NAME = 'PDBGroupMember'
		AND CONSTRAINT_NAME = 'pk_UserGroup'
)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	
	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGroupMember ADD Primary Key Constraints to UserIndex column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	ALTER TABLE PDBGroupMember ADD CONSTRAINT pk_UserGroup PRIMARY KEY (GroupIndex, UserIndex)
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGroupMember ADD Primary Key Constraints to UserIndex column', GETDATE(), NULL, 'Already Updated')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUser'
	AND COLUMN_NAME = 'ParentGroupIndex'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUser Alter Column ParentGroupIndex', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBUser ALTER COLUMN ParentGroupIndex INT
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUser Alter Column ParentGroupIndex', getdate(), getdate(), 'ALREADY UPDATED')
	
END	
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBGroup'
	AND COLUMN_NAME = 'ParentGroupIndex'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGroup Alter Column ParentGroupIndex', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBGroup ALTER COLUMN ParentGroupIndex INT NOT NULL
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGroup Alter Column ParentGroupIndex', getdate(), getdate(), 'ALREADY UPDATED')
	
END	
;


--Check constraint of Flag1 modified to include 'R'
BEGIN
	SELECT 1
	SET NOCOUNT ON
	DECLARE @name varchar(900)
	DECLARE @Id	int
	DECLARE @ColId	int

	SELECT @Id = id
	FROM sysobjects 
	WHERE name = 'PDBFolder'

	SELECT @ColId = ColId
	FROM syscolumns
	WHERE Name = 'FolderType'
	AND id = @id


	SELECT @name = Name
	FROM SYSCONSTRAINTS A, SYSOBJECTS B
	WHERE A.constid = B.id
	AND B.xtype = 'C'
	AND A.id = @id
	AND colid = @ColId

	IF (@@ROWCOUNT > 0)
	BEGIN
		declare @stepNo int
		insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBFolder chaning Check CONSTRAINT on FolderType', getdate(), NULL, 'UPDATING')
	
		
		EXECUTE ('ALTER TABLE PDBFolder DROP CONSTRAINT ' + @name)
		EXECUTE ('ALTER TABLE PDBFolder WITH NOCHECK ADD CONSTRAINT ' +  @name+ ' CHECK (FolderType IN (''S'',''I'',''T'',''G'',''A'',''H'',''K'',''W'')) ')

		

		select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
		update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
	END
END
;

BEGIN
	SELECT 1
	SET NOCOUNT ON
	DECLARE @name varchar(900)
	DECLARE @Id	int
	DECLARE @ColId	int

	SELECT @Id = id
	FROM sysobjects 
	WHERE name = 'PDBFolder'

	SELECT @ColId = ColId
	FROM syscolumns
	WHERE Name = 'Location'
	AND id = @id


	SELECT @name = Name
	FROM SYSCONSTRAINTS A, SYSOBJECTS B
	WHERE A.constid = B.id
	AND B.xtype = 'C'
	AND A.id = @id
	AND colid = @ColId

	IF (@@ROWCOUNT > 0)
	BEGIN
		declare @stepNo int
		insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBFolder chaning Check CONSTRAINT on Location', getdate(), NULL, 'UPDATING')
	
		
		EXECUTE ('ALTER TABLE PDBFolder DROP CONSTRAINT ' + @name)
		EXECUTE ('ALTER TABLE PDBFolder WITH NOCHECK ADD CONSTRAINT ' +  @name+ ' CHECK (Location IN (''S'',''I'',''T'',''G'',''R'',''A'',''H'',''K'',''W'')) ')

		

		select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
		update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
	END
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBDocument'
	AND COLUMN_NAME = 'FinalizedBy'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	DECLARE @StepNo			int
	DECLARE @IndexName		NVARCHAR(255)
	CREATE TABLE #indfol(index_name varchar(256), indexdesc varchar(256), indkey varchar(2126))
	INSERT INTO #indfol exec sp_helpindex 'PDBDocument'

	IF EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'FinalizedBy')
	BEGIN
		SELECT 1
		SET NOCOUNT ON
		SELECT @IndexName = index_name FROM #indfol WHERE indkey = 'FinalizedBy'
		
		INSERT INTO PDBUpdateStatus values ('Drop Index', 'Dropping index on Table PDBDocument Columns (FinalizedBy)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		EXECUTE('DROP INDEX PDBDocument.' + @IndexName)

		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		SELECT 0
		SET NOCOUNT ON
		INSERT INTO PDBUpdateStatus values ('Drop Index', 'Dropping index on Table PDBDocument Columns (FinalizedBy)'  , GETDATE(), NULL, 'Already Updated')
	END
	DROP TABLE #indfol
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Drop Index', 'Dropping index on Table PDBDocument Columns (FinalizedBy)1'  , GETDATE(), NULL, 'Already Updated')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBDocument'
	AND COLUMN_NAME = 'FinalizedBy'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDocument Alter Column FinalizedBy', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBDocument ALTER COLUMN FinalizedBy INT NOT NULL
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDocument Alter Column FinalizedBy', getdate(), getdate(), 'ALREADY UPDATED')
	
END	
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBDocument'
	AND COLUMN_NAME = 'CheckOutbyUser'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	DECLARE @StepNo			int
	DECLARE @IndexName		NVARCHAR(255)
	CREATE TABLE #indfol(index_name varchar(256), indexdesc varchar(256), indkey varchar(2126))
	INSERT INTO #indfol exec sp_helpindex 'PDBDocument'

	IF EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'CheckOutbyUser')
	BEGIN
		SELECT 1
		SET NOCOUNT ON
		SELECT @IndexName = index_name FROM #indfol WHERE indkey = 'CheckOutbyUser'
		
		INSERT INTO PDBUpdateStatus values ('Drop Index', 'Dropping index on Table PDBDocument Columns (CheckOutbyUser)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		EXECUTE('DROP INDEX PDBDocument.' + @IndexName)

		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		SELECT 0
		SET NOCOUNT ON
		INSERT INTO PDBUpdateStatus values ('Drop Index', 'Dropping index on Table PDBDocument Columns (CheckOutbyUser)'  , GETDATE(), NULL, 'Already Updated')
	END
	DROP TABLE #indfol
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Drop Index', 'Dropping index on Table PDBDocument Columns (CheckOutbyUser)1'  , GETDATE(), NULL, 'Already Updated')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBDocument'
	AND COLUMN_NAME = 'CheckOutbyUser'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDocument Alter Column CheckOutbyUser', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBDocument ALTER COLUMN CheckOutbyUser INT NOT NULL
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDocument Alter Column CheckOutbyUser', getdate(), getdate(), 'ALREADY UPDATED')
	
END	
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBDocumentContent'
	AND COLUMN_NAME = 'FiledBy'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	DECLARE @StepNo			int
	DECLARE @IndexName		NVARCHAR(255)
	CREATE TABLE #indfol(index_name varchar(256), indexdesc varchar(256), indkey varchar(2126))
	INSERT INTO #indfol exec sp_helpindex 'PDBDocumentContent'

	IF EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'FiledBy')
	BEGIN
		SELECT 1
		SET NOCOUNT ON
		SELECT @IndexName = index_name FROM #indfol WHERE indkey = 'FiledBy'
		
		INSERT INTO PDBUpdateStatus values ('Drop Index', 'Dropping index on Table PDBDocumentContent Columns (FiledBy)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		EXECUTE('DROP INDEX PDBDocumentContent.' + @IndexName)

		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		SELECT 0
		SET NOCOUNT ON
		INSERT INTO PDBUpdateStatus values ('Drop Index', 'Dropping index on Table PDBDocumentContent Columns (FiledBy)'  , GETDATE(), NULL, 'Already Updated')
	END
	DROP TABLE #indfol
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Drop Index', 'Dropping index on Table PDBDocumentContent Columns (FiledBy)1'  , GETDATE(), NULL, 'Already Updated')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBDocumentContent'
	AND COLUMN_NAME = 'FiledBy'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDocumentContent Alter Column FiledBy', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBDocumentContent ALTER COLUMN FiledBy INT NOT NULL
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDocumentContent Alter Column FiledBy', getdate(), getdate(), 'ALREADY UPDATED')
	
END	
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBAnnotation'
	AND COLUMN_NAME = 'FinalizedBy'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBAnnotation Alter Column FinalizedBy', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBAnnotation ALTER COLUMN FinalizedBy INT NOT NULL
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBAnnotation Alter Column FinalizedBy', getdate(), getdate(), 'ALREADY UPDATED')
	
END	
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBAnnotationVersion'
	AND COLUMN_NAME = 'Owner'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBAnnotationVersion Alter Column Owner', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBAnnotationVersion ALTER COLUMN Owner INT NOT NULL
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBAnnotationVersion Alter Column Owner', getdate(), getdate(), 'ALREADY UPDATED')
	
END	
;

IF EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
		WHERE TABLE_NAME = 'PDBRights'
		AND CONSTRAINT_NAME = 'uk_rights'
)
AND 
NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBRights'
	AND COLUMN_NAME = 'ObjectIndex1'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	
	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBRights DROP Unique Key Constraints to ObjectIndex1 column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	ALTER TABLE PDBRights DROP CONSTRAINT uk_rights
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBRights DROP Unique Key Constraints to ObjectIndex1 column', GETDATE(), NULL, 'Already Updated')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBRights'
	AND COLUMN_NAME = 'ObjectIndex1'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBRights Alter Column ObjectIndex1', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBRights ALTER COLUMN ObjectIndex1 INT NOT NULL
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBRights Alter Column ObjectIndex1', getdate(), getdate(), 'ALREADY UPDATED')
	
END	
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
		WHERE TABLE_NAME = 'PDBRights'
		AND CONSTRAINT_NAME = 'uk_rights'
)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	
	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBRights ADD Unique Key Constraints to ObjectIndex1 column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	ALTER TABLE PDBRights ADD CONSTRAINT uk_rights UNIQUE (ObjectIndex1,Flag1,ObjectIndex2,Flag2)
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBRights ADD Unique Key Constraints to ObjectIndex1 column', GETDATE(), NULL, 'Already Updated')
END
;


IF EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
		WHERE TABLE_NAME = 'PDBDictionary'
		AND CONSTRAINT_NAME = 'uk_Dictionary'
)
AND 
NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBDictionary'
	AND COLUMN_NAME = 'GroupIndex'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	
	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDictionary DROP Unique Key Constraints to GroupIndex column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	ALTER TABLE PDBDictionary DROP CONSTRAINT uk_Dictionary
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDictionary DROP Unique Key Constraints to GroupIndex column', GETDATE(), NULL, 'Already Updated')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBDictionary'
	AND COLUMN_NAME = 'GroupIndex'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDictionary Alter Column GroupIndex', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBDictionary ALTER COLUMN GroupIndex INT NOT NULL
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDictionary Alter Column GroupIndex', getdate(), getdate(), 'ALREADY UPDATED')
	
END	
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
		WHERE TABLE_NAME = 'PDBDictionary'
		AND CONSTRAINT_NAME = 'uk_Dictionary'
)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	
	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDictionary ADD Unique Key Constraints to GroupIndex column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	ALTER TABLE PDBDictionary ADD CONSTRAINT uk_Dictionary UNIQUE (GroupIndex,Keyword)
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDictionary ADD Unique Key Constraints to GroupIndex column', GETDATE(), NULL, 'Already Updated')
END
;


IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBDocumentVersion'
	AND COLUMN_NAME = 'Owner'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDocumentVersion Alter Column Owner', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBDocumentVersion ALTER COLUMN Owner INT NOT NULL
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDocumentVersion Alter Column Owner', getdate(), getdate(), 'ALREADY UPDATED')
	
END	
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBDocumentVersion'
	AND COLUMN_NAME = 'CreatedByUserIndex'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDocumentVersion Alter Column CreatedByUserIndex', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBDocumentVersion ALTER COLUMN CreatedByUserIndex INT NOT NULL
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDocumentVersion Alter Column CreatedByUserIndex', getdate(), getdate(), 'ALREADY UPDATED')
	
END	
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBDocumentVersion'
	AND COLUMN_NAME = 'LockByUser'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDocumentVersion Alter Column LockByUser', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBDocumentVersion ALTER COLUMN LockByUser INT NOT NULL
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDocumentVersion Alter Column LockByUser', getdate(), getdate(), 'ALREADY UPDATED')
	
END	
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBForm'
	AND COLUMN_NAME = 'LockByUser'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBForm Alter Column LockByUser', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBForm ALTER COLUMN LockByUser INT NOT NULL
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBForm Alter Column LockByUser', getdate(), getdate(), 'ALREADY UPDATED')
	
END	
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBConnection'
	AND COLUMN_NAME = 'UserIndex'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBConnection Alter Column UserIndex', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBConnection ALTER COLUMN UserIndex INT NOT NULL
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBConnection Alter Column UserIndex', getdate(), getdate(), 'ALREADY UPDATED')
	
END	
;

BEGIN
	SELECT 1
	SET NOCOUNT ON
	DECLARE @name varchar(900)
	DECLARE @Id	int
	DECLARE @ColId	int

	SELECT @Id = id
	FROM sysobjects 
	WHERE name = 'PDBConnection'

	SELECT @ColId = ColId
	FROM syscolumns
	WHERE Name = 'UserType'
	AND id = @id


	SELECT @name = Name
	FROM SYSCONSTRAINTS A, SYSOBJECTS B
	WHERE A.constid = B.id
	AND B.xtype = 'C'
	AND A.id = @id
	AND colid = @ColId

	IF (@@ROWCOUNT > 0)
	BEGIN
		declare @stepNo int
		insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBConnection Change CONSTRAINT on UserType', getdate(), NULL, 'UPDATING')
	
		
		EXECUTE ('ALTER TABLE PDBConnection DROP CONSTRAINT ' + @name)
		EXECUTE ('ALTER TABLE PDBConnection WITH NOCHECK ADD CONSTRAINT ' +  @name+ ' CHECK ( UserType IN (''S'',''U'',''E'',''I'',''F''))')

		select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
		update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
	END
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBReminder'
	AND COLUMN_NAME = 'UserIndex'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBReminder Alter Column UserIndex', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBReminder ALTER COLUMN UserIndex INT NOT NULL
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBReminder Alter Column UserIndex', getdate(), getdate(), 'ALREADY UPDATED')
	
END	
;


IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBReminder'
	AND COLUMN_NAME = 'SetByUser'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBReminder Alter Column SetByUser', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBReminder ALTER COLUMN SetByUser INT NOT NULL
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBReminder Alter Column SetByUser', getdate(), getdate(), 'ALREADY UPDATED')
	
END	
;

IF EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
		WHERE TABLE_NAME = 'PDBDivertAction'
		AND CONSTRAINT_NAME = 'pk_DivertAction'
)
AND 
NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBDivertAction'
	AND COLUMN_NAME = 'UserIndex'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	
	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDivertAction DROP Primary Key Constraints to UserIndex column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	ALTER TABLE PDBDivertAction DROP CONSTRAINT pk_DivertAction
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDivertAction DROP Primary Key Constraints to UserIndex column', GETDATE(), NULL, 'Already Updated')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBDivertAction'
	AND COLUMN_NAME = 'UserIndex'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDivertAction Alter Column UserIndex', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBDivertAction ALTER COLUMN UserIndex INT NOT NULL
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDivertAction Alter Column UserIndex', getdate(), getdate(), 'ALREADY UPDATED')
	
END	
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
		WHERE TABLE_NAME = 'PDBDivertAction'
		AND CONSTRAINT_NAME = 'pk_DivertAction'
)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	
	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDivertAction ADD Primary Key Constraints to UserIndex column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	ALTER TABLE PDBDivertAction ADD CONSTRAINT pk_DivertAction PRIMARY KEY (DataDefIndex, UserIndex)
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDivertAction ADD Primary Key Constraints to UserIndex column', GETDATE(), NULL, 'Already Updated')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBDivertAction'
	AND COLUMN_NAME = 'DivertedUserIndex'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDivertAction Alter Column DivertedUserIndex', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBDivertAction ALTER COLUMN DivertedUserIndex INT NOT NULL
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDivertAction Alter Column DivertedUserIndex', getdate(), getdate(), 'ALREADY UPDATED')
	
END	
;

IF EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
		WHERE TABLE_NAME = 'PDBUserAddressList'
		AND CONSTRAINT_NAME = 'UK_List'
)
AND 
NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUserAddressList'
	AND COLUMN_NAME = 'Owner'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	
	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUserAddressList DROP Unique Key Constraints to Owner column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	ALTER TABLE PDBUserAddressList DROP CONSTRAINT UK_List
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUserAddressList DROP Unique Key Constraints to Owner column', GETDATE(), NULL, 'Already Updated')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUserAddressList'
	AND COLUMN_NAME = 'Owner'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUserAddressList Alter Column Owner', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBUserAddressList ALTER COLUMN Owner INT NOT NULL
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUserAddressList Alter Column Owner', getdate(), getdate(), 'ALREADY UPDATED')
	
END	
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
		WHERE TABLE_NAME = 'PDBUserAddressList'
		AND CONSTRAINT_NAME = 'UK_List'
)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	
	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUserAddressList ADD Unique Key Constraints to Owner column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	ALTER TABLE PDBUserAddressList ADD CONSTRAINT UK_List UNIQUE (ListName, Owner)
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUserAddressList ADD Unique Key Constraints to Owner column', GETDATE(), NULL, 'Already Updated')
END
;

IF EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
		WHERE TABLE_NAME = 'PDBUserAddressListMember'
		AND CONSTRAINT_NAME = 'pk_ListMember'
)
AND 
NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUserAddressListMember'
	AND COLUMN_NAME = 'UserGroupIndex'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	
	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUserAddressListMember DROP Primary Key Constraints to UserGroupIndex column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	ALTER TABLE PDBUserAddressListMember DROP CONSTRAINT pk_ListMember
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUserAddressListMember DROP Primary Key Constraints to UserGroupIndex column', GETDATE(), NULL, 'Already Updated')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUserAddressListMember'
	AND COLUMN_NAME = 'UserGroupIndex'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUserAddressListMember Alter Column UserGroupIndex', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBUserAddressListMember ALTER COLUMN UserGroupIndex INT NOT NULL
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUserAddressListMember Alter Column UserGroupIndex', getdate(), getdate(), 'ALREADY UPDATED')
	
END	
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
		WHERE TABLE_NAME = 'PDBUserAddressListMember'
		AND CONSTRAINT_NAME = 'pk_ListMember'
)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	
	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUserAddressListMember ADD Primary Key Constraints to UserGroupIndex column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	ALTER TABLE PDBUserAddressListMember ADD CONSTRAINT pk_ListMember PRIMARY KEY (ListIndex, UserGroupType, UserGroupIndex)
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUserAddressListMember ADD Primary Key Constraints to UserGroupIndex column', GETDATE(), NULL, 'Already Updated')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBTrackActionTable'
	AND COLUMN_NAME = 'FromUserId'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBTrackActionTable Alter Column FromUserId', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBTrackActionTable ALTER COLUMN FromUserId INT NOT NULL
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBTrackActionTable Alter Column FromUserId', getdate(), getdate(), 'ALREADY UPDATED')
	
END	
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBTrackActionTable'
	AND COLUMN_NAME = 'ToUserId'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBTrackActionTable Alter Column ToUserId', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBTrackActionTable ALTER COLUMN ToUserId INT NOT NULL
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBTrackActionTable Alter Column ToUserId', getdate(), getdate(), 'ALREADY UPDATED')
	
END	
;

IF EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
		WHERE TABLE_NAME = 'PDBPersonalRoutes'
		AND CONSTRAINT_NAME = 'pk_Routes'
)
AND 
NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBPersonalRoutes'
	AND COLUMN_NAME = 'UserIndex'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	
	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBPersonalRoutes DROP Primary Key Constraints to UserIndex column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	ALTER TABLE PDBPersonalRoutes DROP CONSTRAINT pk_Routes
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBPersonalRoutes DROP Primary Key Constraints to UserIndex column', GETDATE(), NULL, 'Already Updated')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBPersonalRoutes'
	AND COLUMN_NAME = 'UserIndex'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBPersonalRoutes Alter Column UserIndex', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBPersonalRoutes ALTER COLUMN UserIndex INT NOT NULL
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBPersonalRoutes Alter Column UserIndex', getdate(), getdate(), 'ALREADY UPDATED')
	
END	
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
		WHERE TABLE_NAME = 'PDBPersonalRoutes'
		AND CONSTRAINT_NAME = 'pk_Routes'
)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	
	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBPersonalRoutes ADD Primary Key Constraints to UserIndex column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	ALTER TABLE PDBPersonalRoutes ADD CONSTRAINT pk_Routes PRIMARY KEY (UserIndex, RouteName)
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBPersonalRoutes ADD Primary Key Constraints to UserIndex column', GETDATE(), NULL, 'Already Updated')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBMakerCheckerInfo'
	AND COLUMN_NAME = 'MakerId'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBMakerCheckerInfo Alter Column MakerId', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBMakerCheckerInfo ALTER COLUMN MakerId INT
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBMakerCheckerInfo Alter Column MakerId', getdate(), getdate(), 'ALREADY UPDATED')
	
END	
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBMakerCheckerInfo'
	AND COLUMN_NAME = 'CheckerId'
	AND DATA_TYPE = 'INT'
	)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBMakerCheckerInfo Alter Column CheckerId', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBMakerCheckerInfo ALTER COLUMN CheckerId INT
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBMakerCheckerInfo Alter Column CheckerId', getdate(), getdate(), 'ALREADY UPDATED')
	
END	
;

BEGIN
	SELECT 0
	SET NOCOUNT ON
	DECLARE @StepNo			int
	CREATE TABLE #indfol(index_name varchar(256), indexdesc varchar(256), indkey varchar(2126))
	INSERT INTO #indfol exec sp_helpindex 'PDBDOCUMENT'

	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'DocumentLock')
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDOCUMENT Columns (DocumentLock)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_DocumnetLock ON PDBDocument (DocumentLock)
		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDOCUMENT Columns (DocumentLock)' , GETDATE(), NULL, 'Already Updated')
	END
	
	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'AppName')
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDOCUMENT Columns (AppName)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_AppName ON PDBDocument (AppName)
		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDOCUMENT Columns (AppName)' , GETDATE(), NULL, 'Already Updated')
	END
	
	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'CheckOutstatus')
	BEGIN	
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDOCUMENT Columns (CheckOutstatus)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_CheckOutStatus ON PDBDocument (CheckOutstatus)
		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDOCUMENT Columns (CheckOutstatus)' , GETDATE(), NULL, 'Already Updated')
	END
	
	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'DocStatus')
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDOCUMENT Columns (DocStatus)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_DocStatus ON PDBDocument (DocStatus)
		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDOCUMENT Columns (DocStatus)' , GETDATE(), NULL, 'Already Updated')
	END
	
	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'CheckOutbyUser')
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDOCUMENT Columns (CheckOutbyUser)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_DOCUMENT_CheckOutbyUser ON PDBDOCUMENT(CheckOutbyUser) 
		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDOCUMENT Columns (CheckOutbyUser)' , GETDATE(), NULL, 'Already Updated')
	END
	
	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'CreatedbyUser')
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDOCUMENT Columns (CreatedbyUser)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_DOCUMENT_CreatedbyUser ON PDBDOCUMENT(CreatedbyUser)
		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDOCUMENT Columns (CreatedbyUser)' , GETDATE(), NULL, 'Already Updated')
	END
	

	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'FINALIZEDBY')
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDOCUMENT Columns (FINALIZEDBY)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_DOCUMENT_FINALIZEDBY ON PDBDOCUMENT(FINALIZEDBY)
		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDOCUMENT Columns (FINALIZEDBY)' , GETDATE(), NULL, 'Already Updated')
	END
	

	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'FinalizedFlag')
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDOCUMENT Columns (FinalizedFlag)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_DocumentFinalizedFlag ON PDBDocument (FinalizedFlag)
		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDOCUMENT Columns (FinalizedFlag)' , GETDATE(), NULL, 'Already Updated')
	END
	

	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'DataDefinitionIndex')
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDOCUMENT Columns (DataDefinitionIndex)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_DocumentDataDefIndex ON PDBDocument (DataDefinitionIndex)
		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDOCUMENT Columns (DataDefinitionIndex)' , GETDATE(), NULL, 'Already Updated')
	END
	

	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'Owner')
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDOCUMENT Columns (Owner)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_DocumentOwner ON PDBDocument (Owner)
		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDOCUMENT Columns (Owner)' , GETDATE(), NULL, 'Already Updated')
	END
	

	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'DocumentType')
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDOCUMENT Columns (DocumentType)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_DocumentType ON PDBDocument (DocumentType)
		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDOCUMENT Columns (DocumentType)' , GETDATE(), NULL, 'Already Updated')
	END
	

	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'DocumentSize')
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDOCUMENT Columns (DocumentSize)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_DocumentSize ON PDBDocument (DocumentSize)
		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDOCUMENT Columns (DocumentSize)' , GETDATE(), NULL, 'Already Updated')
	END
	

	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'NoOfPages')
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDOCUMENT Columns (NoOfPages)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_NoOfPages ON PDBDocument (NoOfPages)
		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDOCUMENT Columns (NoOfPages)' , GETDATE(), NULL, 'Already Updated')
	END
	

	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'VolumeId, ImageIndex')
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDOCUMENT Columns (VolumeId, ImageIndex)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_ImageIndexVolId ON PDBDocument (VolumeId,ImageIndex)
		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDOCUMENT Columns (VolumeId, ImageIndex)' , GETDATE(), NULL, 'Already Updated')
	END
	

	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'AccessedDateTime')
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDOCUMENT Columns (AccessedDateTime)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_DocumentAcessedDateTime ON PDBDocument (AccessedDateTime)
		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDOCUMENT Columns (AccessedDateTime)' , GETDATE(), NULL, 'Already Updated')
	END
	
		
	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'CreatedDateTime')
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDOCUMENT Columns (CreatedDateTime)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_DocumentCreatedDateTime ON PDBDocument (CreatedDateTime)
		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDOCUMENT Columns (CreatedDateTime)' , GETDATE(), NULL, 'Already Updated')
	END
	

	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'ExpiryDateTime')
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDOCUMENT Columns (ExpiryDateTime)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_DocumentExpiryDateTime ON PDBDocument (ExpiryDateTime)
		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDOCUMENT Columns (ExpiryDateTime)' , GETDATE(), NULL, 'Already Updated')
	END
	

	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'FinalizedDateTime')
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDOCUMENT Columns (FinalizedDateTime)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_DocumentFinalizedDateTime ON PDBDocument (FinalizedDateTime)
		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDOCUMENT Columns (FinalizedDateTime)' , GETDATE(), NULL, 'Already Updated')
	END
	

	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'RevisedDateTime')
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDOCUMENT Columns (RevisedDateTime)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_DocumentRevisedDateTime ON PDBDocument (RevisedDateTime)
		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDOCUMENT Columns (RevisedDateTime)' , GETDATE(), NULL, 'Already Updated')
	END
	

	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'Name')
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDOCUMENT Columns (Name)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_DocumentName ON PDBDocument (Name)
		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDOCUMENT Columns (Name)' , GETDATE(), NULL, 'Already Updated')
	END
	

	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'ACL')
	BEGIN	
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDOCUMENT Columns (ACL)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_DOCUMENT_ACL ON PDBDOCUMENT(ACL)
		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDOCUMENT Columns (ACL)' , GETDATE(), NULL, 'Already Updated')
	END
	
	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'LOCKBYUSER')
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDOCUMENT Columns (LOCKBYUSER)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_DOCUMENT_LOCKBYUSER ON PDBDOCUMENT(LOCKBYUSER)
		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDOCUMENT Columns (LOCKBYUSER)' , GETDATE(), NULL, 'Already Updated')
	END
	DROP TABLE #indfol
END
;
BEGIN
	SELECT 0
	SET NOCOUNT ON
	DECLARE @StepNo			int
	CREATE TABLE #indfol(index_name varchar(256), indexdesc varchar(256), indkey varchar(2126))

	INSERT INTO #indfol exec sp_helpindex 'PDBDOCUMENTCONTENT'

	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'DocumentOrderNo')
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDocumentContent Columns (DocumentOrderNo)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_DocumentOrderNo ON PDBDocumentContent(DocumentOrderNo)
		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDocumentContent Columns (DocumentOrderNo)' , GETDATE(), NULL, 'Already Updated')
	END

	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'DocumentIndex')
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDocumentContent Columns (DocumentIndex)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_DocumentIndex ON PDBDocumentContent (DocumentIndex)
		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDocumentContent Columns (DocumentIndex)' , GETDATE(), NULL, 'Already Updated')
	END

	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'ParentFolderIndex')
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDocumentContent Columns (ParentFolderIndex)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_ParentFolderIndex ON PDBDocumentContent (ParentFolderIndex)
		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDocumentContent Columns (ParentFolderIndex)' , GETDATE(), NULL, 'Already Updated')
	END

	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'FILEDBY')
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDocumentContent Columns (FILEDBY)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_DOCUMENTCONTENT_FILEDBY ON PDBDOCUMENTCONTENT(FILEDBY) 
		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDocumentContent Columns (FILEDBY)' , GETDATE(), NULL, 'Already Updated')
	END

	DROP TABLE #indfol
END
;

IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'PDBCONCURRENTUSAGEINFO')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBConcurrentUsageInfo' , getdate(), NULL, 'UPDATING')
		
	CREATE TABLE PDBConcurrentUsageInfo
	(
		ConnUserCount int,
		RecordedDateTime datetime
	)
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBConcurrentUsageInfo' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'PDBARCHIVECABINET')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBArchiveCabinet' , getdate(), NULL, 'UPDATING')
		
	CREATE TABLE PDBArchiveCabinet
	(
		CabinetName NVARCHAR(255)
	)
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBArchiveCabinet' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
		WHERE TABLE_NAME = 'PDBFolder'
		AND CONSTRAINT_NAME = 'uk_pindex_name'
)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	
	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBFolder DROP Unique Key Constraints to CheckerId column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	ALTER TABLE PDBFolder DROP CONSTRAINT uk_pindex_name
	CREATE UNIQUE NONCLUSTERED INDEX IDX_Folder_Parent_Name ON PDBFOLDER (ParentFolderIndex,NAME)

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBFolder DROP Unique Key Constraints to CheckerId column', GETDATE(), NULL, 'Already Updated')
END
;

--For PDBFolder

BEGIN
	SELECT 0
	SET NOCOUNT ON
	DECLARE @StepNo			int
	CREATE TABLE #indfol(index_name varchar(256), indexdesc varchar(256), indkey varchar(2126))
	INSERT INTO #indfol exec sp_helpindex 'PDBFolder'


	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'FolderType')
	BEGIN
		
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBFolder Columns (FolderType)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_FolderType ON PDBFolder (FolderType)

		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		SELECT 1
		SET NOCOUNT ON
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBFolder Columns (FolderType)' , GETDATE(), NULL, 'Already Updated')
	END


	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'RevisedDateTime')
	BEGIN
		
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBFolder Columns (RevisedDateTime)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_FolderRevisedDateTime ON PDBFolder (RevisedDateTime)

		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		SELECT 1
		SET NOCOUNT ON
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBFolder Columns (RevisedDateTime)' , GETDATE(), NULL, 'Already Updated')
	END


	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'Owner')
	BEGIN
		
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBFolder Columns (Owner)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_FolderOwner ON PDBFolder (Owner)

		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		SELECT 0
		SET NOCOUNT ON
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBFolder Columns (Owner)' , GETDATE(), NULL, 'Already Updated')
	END


	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'Name')
	BEGIN
		
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBFolder Columns (Name)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_FolderName ON PDBFolder(Name)

		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		SELECT 1
		SET NOCOUNT ON
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBFolder Columns (Name)' , GETDATE(), NULL, 'Already Updated')
	END

	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'FolderLock')
	BEGIN
		
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBFolder Columns (FolderLock)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_FolderLock ON PDBFolder (FolderLock)

		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		
		SET NOCOUNT ON
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBFolder Columns (FolderLock)' , GETDATE(), NULL, 'Already Updated')
	END


	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'FinalizedFlag')
	BEGIN
		
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBFolder Columns (FinalizedFlag)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_FolderFinalizedFlag ON PDBFolder (FinalizedFlag)

		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		
		SET NOCOUNT ON
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBFolder Columns (FinalizedFlag)' , GETDATE(), NULL, 'Already Updated')
	END

	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'ExpiryDateTime')
	BEGIN
		
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBFolder Columns (ExpiryDateTime)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_FolderExpiryDateTime ON PDBFolder (ExpiryDateTime)

		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		
		SET NOCOUNT ON
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBFolder Columns (ExpiryDateTime)' , GETDATE(), NULL, 'Already Updated')
	END

	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'DataDefinitionIndex')
	BEGIN
		
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBFolder Columns (DataDefinitionIndex)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_FolderDataDefinitionIndex	ON PDBFolder (DataDefinitionIndex)

		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		
		SET NOCOUNT ON
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBFolder Columns (DataDefinitionIndex)' , GETDATE(), NULL, 'Already Updated')
	END


	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'CreatedDatetime')
	BEGIN
		
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBFolder Columns (CreatedDatetime)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_FolderCreatedDateTime ON PDBFolder (CreatedDatetime)

		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		
		SET NOCOUNT ON
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBFolder Columns (CreatedDatetime)' , GETDATE(), NULL, 'Already Updated')
	END

	
	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'AccessedDateTime')
	BEGIN
		
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBFolder Columns (AccessedDateTime)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_FolderAccessedDateTime ON PDBFolder (AccessedDateTime)

		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		
		SET NOCOUNT ON
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBFolder Columns (AccessedDateTime)' , GETDATE(), NULL, 'Already Updated')
	END


	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'ParentFolderIndex')
	BEGIN
		
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBFolder Columns (ParentFolderIndex)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_Folder_ParentFolderIndex	ON PDBFolder (ParentFolderIndex)

		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		
		SET NOCOUNT ON
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBFolder Columns (ParentFolderIndex)' , GETDATE(), NULL, 'Already Updated')
	END

	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'FinalizedBy')
	BEGIN
		
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBFolder Columns (FinalizedBy)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_FOLDER_FINALIZEDBY ON PDBFOLDER(FINALIZEDBY)

		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		
		SET NOCOUNT ON
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBFolder Columns (FinalizedBy)' , GETDATE(), NULL, 'Already Updated')
	END

	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'ACL')
	BEGIN
		
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBFolder Columns (ACL)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_FOLDER_ACL ON PDBFOLDER(ACL)

		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		
		SET NOCOUNT ON
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBFolder Columns (ACL)' , GETDATE(), NULL, 'Already Updated')
	END
	DROP TABLE #indfol

END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
		WHERE TABLE_NAME = 'PDBUser'
		AND CONSTRAINT_NAME = 'ck_user_deletedflag'
)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	
	DECLARE @StepNo			int
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUser ADD Check Constraints to DeletedFlag column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	ALTER TABLE PDBUser ADD CONSTRAINT ck_user_deletedflag  CHECK (DeletedFlag IN ('Y','N'))
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUser ADD Check Constraints to DeletedFlag column', GETDATE(), NULL, 'Already Updated')
END
;

BEGIN
	SELECT 0
	DECLARE @name varchar(900)
	SELECT @name = ''

	DECLARE @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDataFieldsTable ADD CONSTRAINT on UsefulInfoFlag', getdate(), NULL, 'UPDATING')

	SELECT @name = Name FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBDataFieldsTable')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBDataFieldsTable') AND NAME = 'UsefulInfoFlag')
	AND	XTYPE = 'C'

	IF (@@ROWCOUNT > 0)
	BEGIN
		IF(@name <> 'ck_dft_uinfoflag')
			EXECUTE ('ALTER TABLE PDBDataFieldsTable DROP CONSTRAINT ' + @name)
	END

	IF(@name <> 'ck_dft_uinfoflag')
		EXECUTE ('ALTER TABLE PDBDataFieldsTable WITH NOCHECK ADD CONSTRAINT ck_dft_uinfoflag CHECK (UsefulInfoFlag IN (''Y'',''N''))')

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
;

BEGIN
	SELECT 0
	DECLARE @name varchar(900)
	SELECT @name = ''

	DECLARE @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDataFieldsTable ADD CONSTRAINT on Pickable', getdate(), NULL, 'UPDATING')

	SELECT @name = Name FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBDataFieldsTable')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBDataFieldsTable') AND NAME = 'Pickable')
	AND	XTYPE = 'C'

	IF (@@ROWCOUNT > 0)
	BEGIN
		IF(@name <> 'ck_dft_pickable')
			EXECUTE ('ALTER TABLE PDBDataFieldsTable DROP CONSTRAINT ' + @name)
	END

	IF(@name <> 'ck_dft_pickable')
		EXECUTE ('ALTER TABLE PDBDataFieldsTable WITH NOCHECK ADD CONSTRAINT ck_dft_pickable CHECK (Pickable IN (''Y'',''N''))')

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
;

BEGIN
	SELECT 0
	DECLARE @name varchar(900)
	SELECT @name = ''

	DECLARE @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDivertAction ADD CONSTRAINT on DivertConfidentialFlag', getdate(), NULL, 'UPDATING')

	SELECT @name = Name FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBDivertAction')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBDivertAction') AND NAME = 'DivertConfidentialFlag')
	AND	XTYPE = 'C'

	IF (@@ROWCOUNT > 0)
	BEGIN
		IF(@name <> 'ck_divertact_DCflag')
			EXECUTE ('ALTER TABLE PDBDivertAction DROP CONSTRAINT ' + @name)
	END

	IF(@name <> 'ck_divertact_DCflag')
		EXECUTE ('ALTER TABLE PDBDivertAction WITH NOCHECK ADD CONSTRAINT ck_divertact_DCflag CHECK (DivertConfidentialFlag IN (''Y'',''N''))')

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
;

BEGIN
	SELECT 0
	DECLARE @name varchar(900)
	SELECT @name = ''

	DECLARE @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDivertAction ADD CONSTRAINT on DurationFlag', getdate(), NULL, 'UPDATING')

	SELECT @name = Name FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBDivertAction')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBDivertAction') AND NAME = 'DurationFlag')
	AND	XTYPE = 'C'

	IF (@@ROWCOUNT > 0)
	BEGIN
		IF(@name <> 'ck_divertact_durflag')
			EXECUTE ('ALTER TABLE PDBDivertAction DROP CONSTRAINT ' + @name)
	END

	IF(@name <> 'ck_divertact_durflag')
		EXECUTE ('ALTER TABLE PDBDivertAction WITH NOCHECK ADD CONSTRAINT ck_divertact_durflag CHECK (DurationFlag IN (''Y'',''N''))')

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
;

BEGIN
	SELECT 0
	DECLARE @name varchar(900)
	SELECT @name = ''

	DECLARE @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDivertAction ADD CONSTRAINT on InformByEmailFlag', getdate(), NULL, 'UPDATING')

	SELECT @name = Name FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBDivertAction')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBDivertAction') AND NAME = 'InformByEmailFlag')
	AND	XTYPE = 'C'

	IF (@@ROWCOUNT > 0)
	BEGIN
		IF(@name <> 'ck_divertact_InfMailflag')
			EXECUTE ('ALTER TABLE PDBDivertAction DROP CONSTRAINT ' + @name)
	END

	IF(@name <> 'ck_divertact_InfMailflag')
		EXECUTE ('ALTER TABLE PDBDivertAction WITH NOCHECK ADD CONSTRAINT ck_divertact_InfMailflag CHECK (InformByEmailFlag IN (''Y'',''N''))')

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
;

BEGIN
	SELECT 0
	DECLARE @name varchar(900)
	SELECT @name = ''

	DECLARE @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDivertAction ADD CONSTRAINT on LeaveCopyFlag', getdate(), NULL, 'UPDATING')

	SELECT @name = Name FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBDivertAction')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBDivertAction') AND NAME = 'LeaveCopyFlag')
	AND	XTYPE = 'C'

	IF (@@ROWCOUNT > 0)
	BEGIN
		IF(@name <> 'ck_divertact_Lcpyflag')
			EXECUTE ('ALTER TABLE PDBDivertAction DROP CONSTRAINT ' + @name)
	END

	IF(@name <> 'ck_divertact_Lcpyflag')
		EXECUTE ('ALTER TABLE PDBDivertAction WITH NOCHECK ADD CONSTRAINT ck_divertact_Lcpyflag CHECK (LeaveCopyFlag IN (''Y'',''N''))')

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
;

BEGIN
	SELECT 0
	DECLARE @name varchar(900)
	SELECT @name = ''

	DECLARE @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDocumentContent ADD CONSTRAINT on DocStatus', getdate(), NULL, 'UPDATING')

	SELECT @name = Name FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBDocumentContent')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBDocumentContent') AND NAME = 'DocStatus')
	AND	XTYPE = 'D'

	IF (@@ROWCOUNT > 0)
	BEGIN
		IF(@name <> 'df_DCT_docstat')
			EXECUTE ('ALTER TABLE PDBDocumentContent DROP CONSTRAINT ' + @name)
	END

	IF(@name <> 'df_DCT_docstat')
		EXECUTE ('ALTER TABLE PDBDocumentContent WITH NOCHECK ADD CONSTRAINT df_DCT_docstat DEFAULT ''A'' FOR DocStatus')

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
;

BEGIN
	SELECT 0
	DECLARE @name varchar(900)
	SELECT @name = ''

	DECLARE @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBLicense ADD CONSTRAINT on DDTFTS', getdate(), NULL, 'UPDATING')

	SELECT @name = Name FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBLicense')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBLicense') AND NAME = 'DDTFTS')
	AND	XTYPE = 'D'

	IF (@@ROWCOUNT > 0)
	BEGIN
		IF(@name <> 'df_License_DDTFTS')
			EXECUTE ('ALTER TABLE PDBLicense DROP CONSTRAINT ' + @name)
	END

	IF(@name <> 'df_License_DDTFTS')
		EXECUTE ('ALTER TABLE PDBLicense WITH NOCHECK ADD CONSTRAINT df_License_DDTFTS DEFAULT ''N'' FOR DDTFTS')

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
;

BEGIN
	SELECT 0
	DECLARE @name varchar(900)
	SELECT @name = ''

	DECLARE @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBLicense ADD CONSTRAINT on STypeLogout', getdate(), NULL, 'UPDATING')

	SELECT @name = Name FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBLicense')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBLicense') AND NAME = 'STypeLogout')
	AND	XTYPE = 'D'

	IF (@@ROWCOUNT > 0)
	BEGIN
		IF(@name <> 'df_License_STypeLogout')
			EXECUTE ('ALTER TABLE PDBLicense DROP CONSTRAINT ' + @name)
	END

	IF(@name <> 'df_License_STypeLogout')
		EXECUTE ('ALTER TABLE PDBLicense WITH NOCHECK ADD CONSTRAINT df_License_STypeLogout DEFAULT ''N'' FOR STypeLogout')

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
;

BEGIN
	SELECT 0
	DECLARE @name varchar(900)
	SELECT @name = ''

	DECLARE @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBRights ADD CONSTRAINT on Flag2', getdate(), NULL, 'UPDATING')

	SELECT @name = Name FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBRights')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBRights') AND NAME = 'Flag2')
	AND	XTYPE = 'C'

	IF (@@ROWCOUNT > 0)
	BEGIN
	--	IF(@name <> 'ck_rights_flag2')
			EXECUTE ('ALTER TABLE PDBRights DROP CONSTRAINT ' + @name)
	END

--	IF(@name <> 'ck_rights_flag2')
		EXECUTE ('ALTER TABLE PDBRights WITH NOCHECK ADD CONSTRAINT ck_rights_flag2 CHECK (Flag2 IN (''F'',''C'',''D'',''A'',''T'',''N'',''V'',''P''))')

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
;

BEGIN
	SELECT 0
	DECLARE @name varchar(900)
	SELECT @name = ''

	DECLARE @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUser ADD CONSTRAINT on DeletedFlag', getdate(), NULL, 'UPDATING')

	SELECT @name = Name FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBUser')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBUser') AND NAME = 'DeletedFlag')
	AND	XTYPE = 'D'

	IF (@@ROWCOUNT > 0)
	BEGIN
		IF(@name <> 'df_user_deletedflag')
			EXECUTE ('ALTER TABLE PDBUser DROP CONSTRAINT ' + @name)
	END

	IF(@name <> 'df_user_deletedflag')
		EXECUTE ('ALTER TABLE PDBUser WITH NOCHECK ADD CONSTRAINT df_user_deletedflag DEFAULT ''N'' FOR DeletedFlag')

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
;

BEGIN
	SELECT 0
	DECLARE @name varchar(900)
	SELECT @name = ''

	DECLARE @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table Usr_0_UserPreferences ADD CONSTRAINT on SiteId', getdate(), NULL, 'UPDATING')

	SELECT @name = Name FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('Usr_0_UserPreferences')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('Usr_0_UserPreferences') AND NAME = 'SiteId')
	AND	XTYPE = 'D'

	IF (@@ROWCOUNT > 0)
	BEGIN
		IF(@name <> 'df_UsrPref_SiteId')
			EXECUTE ('ALTER TABLE Usr_0_UserPreferences DROP CONSTRAINT ' + @name)
	END

	IF(@name <> 'df_UsrPref_SiteId')
		EXECUTE ('ALTER TABLE Usr_0_UserPreferences WITH NOCHECK ADD CONSTRAINT df_UsrPref_SiteId DEFAULT 1 FOR SiteId')

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
;

BEGIN
	SELECT 0
	DECLARE @name varchar(900)
	SELECT @name = ''

	DECLARE @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBAnnotationObject ADD CONSTRAINT on MainGroupId', getdate(), NULL, 'UPDATING')

	SELECT @name = Name FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBAnnotationObject')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBAnnotationObject') AND NAME = 'MainGroupId')
	AND	XTYPE = 'D'

	IF (@@ROWCOUNT > 0)
	BEGIN
		IF(@name <> 'df_annotobj_mgpid')
			EXECUTE ('ALTER TABLE PDBAnnotationObject DROP CONSTRAINT ' + @name)
	END

	IF(@name <> 'df_annotobj_mgpid')
		EXECUTE ('ALTER TABLE PDBAnnotationObject WITH NOCHECK ADD CONSTRAINT df_annotobj_mgpid DEFAULT 0 FOR MainGroupId')

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
;

BEGIN
	SELECT 0
	SET NOCOUNT ON
	DECLARE @StepNo			int
	CREATE TABLE #indfol(index_name varchar(256), indexdesc varchar(256), indkey varchar(2126))
	INSERT INTO #indfol exec sp_helpindex 'PDBDocument'

	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'LOCKBYUSER')
	BEGIN
		
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDocument Columns (LOCKBYUSER)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_PDBDocument_FlgId ON PDBDocument(LOCKBYUSER)

		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		
		SET NOCOUNT ON
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBDocument  Columns (LOCKBYUSER)' , GETDATE(), NULL, 'Already Updated')
	END
	DROP TABLE #indfol
END
;

BEGIN
	SELECT 0
	SET NOCOUNT ON
	DECLARE @StepNo			int
	CREATE TABLE #indfol(index_name varchar(256), indexdesc varchar(256), indkey varchar(2126))
	INSERT INTO #indfol exec sp_helpindex 'PDBFolder'

	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'LOCKBYUSER')
	BEGIN
		
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBFolder Columns (LOCKBYUSER)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_PDBFolder_FlgId ON PDBFolder(LOCKBYUSER)

		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		
		SET NOCOUNT ON
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBFolder  Columns (LOCKBYUSER)' , GETDATE(), NULL, 'Already Updated')
	END
	DROP TABLE #indfol
END
;

BEGIN
	SELECT 0
	declare @stepNo int
	IF NOT EXISTS(SELECT id FROM PDBConstant WHERE id = 50024)
	BEGIN
		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(50024)', getdate(), NULL, 'UPDATING')

		INSERT INTO PDBConstant VALUES(50024, 'PRT_WARN_Concurrency_Limit_Reached', 'Warning')

		select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
		update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
	END 
	ELSE
	BEGIN
		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(50024)', getdate(), getdate(), 'ALREADY UPDATED')
	END

	IF NOT EXISTS(SELECT id FROM PDBConstant WHERE id = 50025)
	BEGIN
		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(50025)', getdate(), NULL, 'UPDATING')

		INSERT INTO PDBConstant VALUES(50025, 'PRT_WARN_Login_User_High', 'Warning')

		select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
		update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
	END 
	ELSE
	BEGIN
		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(50025)', getdate(), getdate(), 'ALREADY UPDATED')
	END

	IF NOT EXISTS( SELECT 1 FROM PDBConstant WHERE Id = -50250 AND Message = 'PRT_ERR_Evaluation_Version_Expired')
	BEGIN
		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(-50250)', getdate(), NULL, 'UPDATING')

		IF EXISTS( SELECT 1 FROM PDBConstant WHERE Id = -50250)
		BEGIN
			DELETE FROM PDBConstant WHERE Id = -50250
		END	
		IF EXISTS( SELECT 1 FROM PDBConstant WHERE Message = 'PRT_ERR_Evaluation_Version_Expired')
		BEGIN
			DELETE FROM PDBConstant WHERE Message = 'PRT_ERR_Evaluation_Version_Expired'
		END	
		INSERT INTO PDBConstant VALUES (-50250,'PRT_ERR_Evaluation_Version_Expired','Error')

		select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
		update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
	END 
	ELSE
	BEGIN
		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(-50250)', getdate(), getdate(), 'ALREADY UPDATED')
	END

	IF NOT EXISTS( SELECT 1 FROM PDBConstant WHERE Id = -50251 AND Message = 'PRT_ERR_GlobalIndex_Associated_With_Folder')
	BEGIN
		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(-50251)', getdate(), NULL, 'UPDATING')

		IF EXISTS( SELECT 1 FROM PDBConstant WHERE Id = -50251)
		BEGIN
			DELETE FROM PDBConstant WHERE Id = -50251
		END	
		IF EXISTS( SELECT 1 FROM PDBConstant WHERE Message = 'PRT_ERR_GlobalIndex_Associated_With_Folder')
		BEGIN
			DELETE FROM PDBConstant WHERE Message = 'PRT_ERR_GlobalIndex_Associated_With_Folder'
		END	
		INSERT INTO PDBConstant VALUES (-50251,'PRT_ERR_GlobalIndex_Associated_With_Folder','Error')

		select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
		update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
	END 
	ELSE
	BEGIN
		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(-50251)', getdate(), getdate(), 'ALREADY UPDATED')
	END
END
;

IF NOT EXISTS (SELECT 1 FROM PDBAuditAction
		WHERE ActionId = 664 AND Category = 'F')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction Associate Index With Folder', getdate(), NULL, 'UPDATING')
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (664, 'F', 'Associate Index With Folder', 'Y',  NULL)
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction Associate Index With Folder', getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS (SELECT 1 FROM PDBAuditAction
		WHERE ActionId = 665 AND Category = 'F')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction Disassociate Index from Folder', getdate(), NULL, 'UPDATING')
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (665, 'F', 'Disassociate Index from Folder', 'Y',  NULL)
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction Disassociate Index from Folder', getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS (SELECT 1 FROM PDBAuditAction
		WHERE ActionId = 666 AND Category = 'F')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction Change Index Value', getdate(), NULL, 'UPDATING')
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (666, 'F', 'Change Index Value', 'Y',  NULL)
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction Change Index Value', getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS (SELECT 1 FROM PDBAuditAction
		WHERE ActionId = 667 AND Category = 'F')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction Attach Notes', getdate(), NULL, 'UPDATING')
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (667, 'F', 'Attach Notes', 'Y',  'Note is attached to a folder')
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction Attach Notes', getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS (SELECT 1 FROM PDBAuditAction
		WHERE ActionId = 668 AND Category = 'F')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction Delete Notes', getdate(), NULL, 'UPDATING')
	INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment) VALUES (668, 'F', 'Delete Notes', 'Y',  'Notes of a folder is deleted')
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction Delete Notes', getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
		SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'PDBCabinet'
		AND COLUMN_NAME = 'FlexibilityCount'
	)
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBCabinet add FlexibilityCount' , getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBCabinet ADD FlexibilityCount SMALLINT CONSTRAINT df_cab_FlexibilityCount DEFAULT 0 WITH VALUES
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBCabinet add FlexibilityCount' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
		SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'PDBCabinet'
		AND COLUMN_NAME = 'EncrFlexibilityCount'
	)
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBCabinet add EncrFlexibilityCount' , getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBCabinet ADD EncrFlexibilityCount nvarchar(255) NULL
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBCabinet add EncrFlexibilityCount' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
		SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'PDBConnectionHistory')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBConnectionHistory' , getdate(), NULL, 'UPDATING')

	CREATE TABLE PDBConnectionHistory 
	(
		UserIndex				INT,
		UserName				NVARCHAR(64),
		UserType				CHAR(1),
		LoginTime				DATETIME,
		ConnectionAllowed		CHAR(1),
		NoOfConcurrentUsers		INT		
	)

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBConnectionHistory' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
		SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'PDBFolder'
		AND COLUMN_NAME = 'Comment'
		AND DATA_TYPE = 'NVARCHAR'
		AND CHARACTER_MAXIMUM_LENGTH = 1020
	)
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBFolder COLUMN Comment' , getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBFolder ALTER COLUMN Comment NVARCHAR(1020) NULL
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBFolder COLUMN Comment' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
		SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'PDBDocument'
		AND COLUMN_NAME = 'Comment'
		AND DATA_TYPE = 'NVARCHAR'
		AND CHARACTER_MAXIMUM_LENGTH = 1020
	)
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBDocument COLUMN Comment' , getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBDocument ALTER COLUMN Comment NVARCHAR(1020) NULL
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBDocument COLUMN Comment' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
		SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'PDBRights'
		AND COLUMN_NAME = 'FromDate')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBRights add FromDate' , getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBRights ADD FromDate DateTime NULL
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBRights add FromDate' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
		SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'PDBRights'
		AND COLUMN_NAME = 'ToDate')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBRights add ToDate' , getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBRights ADD ToDate DateTime NULL
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBRights add ToDate' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'PDBGeneratedAlarm')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBGeneratedAlarm' , getdate(), NULL, 'UPDATING')

	CREATE TABLE PDBGeneratedAlarm
	(
		AlarmDataIndex			int IDENTITY (1,1) CONSTRAINT pk_AlarmDataIndex PRIMARY KEY,
		AlarmIndex				int,
		AlarmType				char(1) ,
		ActiveObjectType		char(1) null,
		ActiveObjectId			int null,
		ActiveObjectName		nvarchar(255) NULL,
		ActiveObjectPath		nvarchar(4000) NULL,
		UserGeneratedId			int,
		UserGenerated			nvarchar(64) NULL,
		ActionType				smallint,
		AlarmDateTime			datetime,
		SetByUser				int,
		SetByUserName			nvarchar(64) NULL,
		SetForUserId			int,
		SetForUserName			nvarchar(64) NULL,
		DocumentType			char(1) NULL,
		InformMode 				char(1),
		SubsidiaryObjectId       int NULL,
		SubsidiaryObjectType     CHAR(1) NULL,
		SubsidiaryObjectName		nvarchar(255) NULL,	
		SubsidiaryObjectPath		nvarchar(4000) NULL,
		Comment					nvarchar(4000) NULL
	)
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBGeneratedAlarm' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

DECLARE @QueryStr NVARCHAR(4000)
DECLARE @DataFieldIndex INT
DECLARE @FieldValue NVARCHAR(255)
DECLARE @CheckConstraintName varchar(255)
DECLARE    @DataBaseOwner            nvarchar(255)
DECLARE    @Uid                int
DECLARE @AlarmIndex  INT
DECLARE @Comment    NVARCHAR(4000)
DECLARE @ActionType SMALLINT
DECLARE @Pos    int
DECLARE @TempName NVARCHAR(255)
DECLARE @ConstraintName NVARCHAR(100)
DECLARE @ConstraintCol  NVARCHAR(4000)
DECLARE @ColumnName NVARCHAR(100)
DECLARE @DocumentIndex  INT
DECLARE @VersionNumber DECIMAL(7,2)
DECLARE @LatVersionNumber DECIMAL(7,2)
DECLARE @VersionSeries int
DECLARE @VersionExistFlag    char(1)
DECLARE @ISLatestVersion    char(1)    
DECLARE @ParentFolderIndex    int
DECLARE @AnnotationIndex    int
DECLARE @ACLMoreFlag    char(1)
DECLARE @AnnotVerIndex    int
DECLARE @DataDefIndex int
DECLARE @FieldColumns NVARCHAR(4000)
DECLARE @NewDocumentIndex int
DECLARE    @ObjectIndex    int
DECLARE @PageNumber    int
DECLARE @TempIndex int
DECLARE @DDTVerTableName NVARCHAR(40)
DECLARE @DataClassOrderNo INT
DECLARE @PrevDataDefIndex INT
DECLARE @ObjectType CHAR(1)
DECLARE @AlarmType CHAR(1)
DECLARE @ObjectId INT
DECLARE @ObjectName NVARCHAR(4000) 
DECLARE    @AlarmDate datetime
DECLARE    @UserIndex INT
DECLARE    @UserName NVARCHAR (255)
DECLARE @SetByUser INT 
DECLARE @SetByUserName NVARCHAR (255)            
DECLARE @DocumentType CHAR(1)
DECLARE @InformMode CHAR(1) 
DECLARE @UserGenerated nvarchar(500)
DECLARE @ActiveObjName NVARCHAR(4000)
DECLARE @UserGeneratedName INT
DECLARE    @name varchar(900)
DECLARE @QueryString NVARCHAR(4000)
DECLARE @lquote CHAR(1)
IF NOT EXISTS(
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_NAME = 'PDBAlarm'
        AND COLUMN_NAME = 'AlarmInheritance')
BEGIN
    SELECT 1
    
    declare @stepNo int
    insert into PDBUpdateStatus values ('Alter TABLE', 'Altering TABLE PDBAlarm' , getdate(), NULL, 'UPDATING')
    
        BEGIN TRANSACTION TranUpdateAlarm
        EXEC SP_RENAME 'pk_AlarmIndex', 'pk_AlarmIndex_Old_8542' 
        IF @@ERROR <> 0
        BEGIN
            ROLLBACK TRANSACTION TranUpdateAlarm
            RETURN    
        END    
        SELECT    @Uid=uid FROM SYSOBJECTS WHERE NAME='GetNameOrPath'
        SELECT    @DataBaseOwner = SCHEMA_NAME(@Uid)
 
        DECLARE checkcur CURSOR FOR
            SELECT A.CONSTRAINT_NAME
            FROM INFORMATION_SCHEMA.Constraint_Column_Usage A,  INFORMATION_SCHEMA.CHECK_CONSTRAINTS B
            WHERE Table_Name = 'PDBALARM'
            AND A.CONSTRAINT_NAME = B.CONSTRAINT_NAME 
        OPEN checkcur
        IF @@ERROR <> 0
        BEGIN
            ROLLBACK TRANSACTION TranUpdateAlarm
            RETURN    
        END    
        FETCH NEXT FROM checkcur INTO @CheckConstraintName
        WHILE (@@FETCH_STATUS = 0) 
        BEGIN
            SELECT @QueryStr = N' ALTER TABLE PDBALARM DROP CONSTRAINT ' + @CheckConstraintName 
            IF @@ERROR <> 0
            BEGIN
                ROLLBACK TRANSACTION TranUpdateAlarm
                RETURN    
            END    
            EXECUTE (@QueryStr)
            IF @@ERROR <> 0
            BEGIN
                ROLLBACK TRANSACTION TranUpdateAlarm
                RETURN    
            END    
            FETCH NEXT FROM checkcur INTO @CheckConstraintName
        END
        CLOSE checkcur
        IF @@ERROR <> 0
        BEGIN
            ROLLBACK TRANSACTION TranUpdateAlarm
            RETURN    
        END    
        DEALLOCATE checkcur
        IF @@ERROR <> 0
        BEGIN
            ROLLBACK TRANSACTION TranUpdateAlarm
            RETURN    
        END    
        EXEC SP_RENAME 'PDBAlarm', 'PDBAlarm_Old_8542' 
        IF @@ERROR <> 0
        BEGIN
            ROLLBACK TRANSACTION TranUpdateAlarm
            RETURN    
        END
 
        CREATE TABLE PDBAlarm
        (
            AlarmIndex        int IDENTITY (1,1) CONSTRAINT pk_AlarmIndex PRIMARY KEY,
            AlarmType        char(1) Constraint ck_alarm_alarmtype check (AlarmType in ('S','U')),
            ObjectType        char(1) null,
            ObjectId        int null,
            ObjectName        nvarchar(255) NULL,
            ActionType        smallint,
            AlarmDateTime        datetime,
            SetForUserId        int,
            SetForUserName        nvarchar(64) NULL,
            SetByUser        int,
            SetByUserName    nvarchar(64) NULL,
            DocumentType        char(1) NULL,
            InformMode         char(1) ,
            Comment            nvarchar(4000) NULL,
            AlarmInheritance Char(1) Constraint ck_alarm_inheritance check (AlarmInheritance in ('Y','N'))  default 'N',
            ParentAlarmIndex int    
        )
        IF @@ERROR <> 0
        BEGIN
            ROLLBACK TRANSACTION TranUpdateAlarm
            RETURN    
        END    
 
        SET IDENTITY_INSERT PDBAlarm ON
        IF @@ERROR <> 0
        BEGIN
            ROLLBACK TRANSACTION TranUpdateAlarm
            RETURN    
        END    
        EXECUTE('DECLARE AlarmCursor CURSOR FAST_FORWARD FOR
                SELECT AlarmIndex, AlarmType, ObjectType, ObjectId,ObjectName, ActionType,
                AlarmDateTime, UserIndex,SetByUser,DocumentType, InformMode, Comment
                FROM PDBAlarm_Old_8542
                WHERE ObjectType IN (''D'', ''F'')')
        OPEN AlarmCursor
        FETCH NEXT FROM AlarmCursor INTO @AlarmIndex, @AlarmType, @ObjectType, @ObjectId,@ObjectName, @ActionType, @AlarmDate,@UserIndex, @SetByUser, @DocumentType, @InformMode, @Comment
        WHILE @@FETCH_STATUS <> -1
        BEGIN
                IF @@FETCH_STATUS <> -2
                BEGIN                
                SELECT @UserName = UserName FROM PDBUSER WHERE UserIndex = @UserIndex
                SELECT @SetByUserName = UserName FROM PDBUSER WHERE UserIndex = @SetByUser
				SELECT @lquote=char(39)
                IF @ActionType = 9
                    SELECT @ObjectName = Name FROM PDBDocument WHERE DocumentIndex = @ObjectId 					   
				    EXECUTE ('INSERT INTO PDBAlarm(AlarmIndex, AlarmType, ObjectType, ObjectId, ObjectName, ActionType, 
                        AlarmDateTime, SetForUserId, SetForUserName, SetByUser, SetByUserName, 
                        DocumentType, InformMode, Comment, AlarmInheritance, ParentAlarmIndex) 
                        values ('+@AlarmIndex+',' + @lquote + @AlarmType + @lquote + ','+@lquote+ @ObjectType+@lquote+','+ @ObjectId+','+@lquote+@ObjectName+@lquote+','+@ActionType+','+@lquote+@AlarmDate+@lquote+','+@UserIndex+','+@lquote+@UserName+@lquote+','+@SetByUser+','+@lquote+@SetByUserName+@lquote+','+@DocumentType+','+@lquote+ @InformMode+@lquote+','+ @lquote+@Comment+@lquote+',''N'',0)')
                END
                FETCH NEXT FROM AlarmCursor INTO @AlarmIndex, @AlarmType, @ObjectType, @ObjectId,@ObjectName, @ActionType, @AlarmDate,@UserIndex, @SetByUser, @DocumentType, @InformMode, @Comment
        END
        CLOSE AlarmCursor
        DEALLOCATE AlarmCursor
        IF @@ERROR <> 0
        BEGIN
            SET IDENTITY_INSERT PDBAlarm OFF
            ROLLBACK TRANSACTION TranUpdateAlarm
            RETURN    
        END    
        EXECUTE('DECLARE AlarmCursor CURSOR FAST_FORWARD FOR
        SELECT AlarmIndex, AlarmType, ObjectType, ObjectId,ObjectName, UserGenerated,ActionType, 
                AlarmDateTime, UserIndex,SetByUser,DocumentType, InformMode, Comment
                FROM PDBAlarm_Old_8542 WHERE ObjectType = ''D''
                AND AlarmGenerated = ''Y'' ')
        OPEN AlarmCursor
        FETCH NEXT FROM AlarmCursor INTO @AlarmIndex, @AlarmType, @ObjectType, @ObjectId, @ObjectName, @UserGenerated, @ActionType, @AlarmDate,@UserIndex, @SetByUser, @DocumentType, @InformMode, @Comment
        WHILE @@FETCH_STATUS <> -1
        BEGIN
                IF @@FETCH_STATUS <> -2
                BEGIN        
                SELECT @ActiveObjName = @DataBaseOwner + '.GetNameOrPath('+@ObjectType+','+ @ObjectId+','+ '301'+','+ 'P'+')'
                --EXECUTE('SELECT @UserGeneratedName =     ISNULL((SELECT UserIndex FROM PDBUser WHERE PDBUser.UserName = PDBAlarm_Old_8542.UserGenerated), 0)')
                SELECT @QueryString= ISNULL(('SELECT @UserGeneratedName = PDBUser.UserIndex FROM PDBUser,PDBAlarm_Old_8542 WHERE PDBUser.UserName = PDBAlarm_Old_8542.UserGenerated'),0)
                
                EXEC SP_EXECUTESQL 
                            @query = @QueryString, 
                            @params = N'@UserGeneratedName INT OUTPUT',
                            @UserGeneratedName = @UserGeneratedName OUTPUT
                SELECT @UserName = UserName FROM PDBUSER WHERE UserIndex = @UserIndex
                SELECT @SetByUserName = UserName FROM PDBUSER WHERE UserIndex = @SetByUser
				SELECT @lquote=char(39)
                EXECUTE('INSERT INTO PDBGeneratedAlarm(AlarmIndex, AlarmType, ActiveObjectType, 
                ActiveObjectId, ActiveObjectName, ActiveObjectPath, 
                UserGeneratedId, UserGenerated, ActionType, AlarmDateTime, 
                SetByUser, SetByUserName, SetForUserId, SetForUserName,
                DocumentType, InformMode, 
                SubsidiaryObjectId, SubsidiaryObjectType, 
                SubsidiaryObjectName, SubsidiaryObjectPath, 
                Comment) VALUES('+@AlarmIndex+','+@lquote+ @AlarmType+@lquote+','+ @lquote+@ObjectType+@lquote+','+ @ObjectId+','+@lquote+@ObjectName+@lquote+','+@lquote+@ActiveObjName+@lquote+','+@UserGeneratedName+','+@lquote+@UserGenerated+@lquote+','+@ActionType+','+@lquote+ @AlarmDate+@lquote+','+@SetByUser+','+@lquote+@SetByUserName+@lquote+','+@UserIndex+','+@lquote+@UserName+@lquote+','+@lquote+@DocumentType+@lquote+','+@lquote+@InformMode+@lquote+',NULL,NULL,NULL,NULL,'+@lquote+@Comment+@lquote+')')
                IF @@ERROR <> 0
                BEGIN
                    ROLLBACK TRANSACTION TranUpdateAlarm
                    RETURN    
                END    
                END
                FETCH NEXT FROM AlarmCursor INTO @AlarmIndex, @AlarmType, @ObjectType, @ObjectId, @ObjectName, @UserGenerated, @ActionType, @AlarmDate,@UserIndex, @SetByUser, @DocumentType, @InformMode, @Comment
        END
        CLOSE AlarmCursor
        DEALLOCATE AlarmCursor        
 
        EXECUTE (' DECLARE alarmcur CURSOR FOR SELECT AlarmIndex, Comment, ActionType,UserGenerated,SetByUser,UserIndex
                            FROM PDBAlarm_Old_8542
                            WHERE ObjectType = ''F''
                            AND AlarmGenerated = ''Y''')
 
        OPEN alarmcur
        IF @@ERROR <> 0
        BEGIN
            ROLLBACK TRANSACTION TranUpdateAlarm
            RETURN    
        END    
        FETCH NEXT FROM alarmcur INTO @AlarmIndex, @Comment, @ActionType,@UserGenerated,@SetByUser,@UserIndex
        WHILE @@FETCH_STATUS = 0
        BEGIN
            IF @Comment IS NULL
                SELECT @Pos = 0
            ELSE
                SELECT @Pos = CHARINDEX(',' , @Comment)
            IF @Pos > 0
            BEGIN
                WHILE (@Pos > 0)
                BEGIN
                    SELECT @TempName = SUBSTRING(@Comment, 1, @Pos - 1)
                    SELECT @UserGeneratedName = ISNULL((SELECT UserIndex FROM PDBUser WHERE PDBUser.UserName = @UserGenerated), 0)
                    SELECT @UserName = UserName FROM PDBUSER WHERE UserIndex = @UserIndex
                    SELECT @SetByUserName = UserName FROM PDBUSER WHERE UserIndex = @SetByUser
                    SELECT @QueryStr = N'INSERT INTO PDBGeneratedAlarm(AlarmIndex, AlarmType, ActiveObjectType, 
                            ActiveObjectId, ActiveObjectName, ActiveObjectPath, 
                            UserGeneratedId, UserGenerated, ActionType, AlarmDateTime, 
                            SetByUser, SetByUserName, SetForUserId, SetForUserName,
                            DocumentType, InformMode, 
                            SubsidiaryObjectId, SubsidiaryObjectType, 
                            SubsidiaryObjectName, SubsidiaryObjectPath, 
                            Comment) 
                            SELECT AlarmIndex, AlarmType, ObjectType, 
                                ObjectId, ObjectName, ' + 
                                @DataBaseOwner + '.GetNameOrPath(ObjectType, ObjectId, 301, ''P''), 
                                ' + NCHAR(39) + CONVERT(varchar(255),@UserGeneratedName) + CHAR(39) + ',
                                UserGenerated,     ActionType, AlarmDateTime, 
                                SetByUser, ' + NCHAR(39) + @SetByUserName + CHAR(39) + ', 
                                UserIndex, ' + NCHAR(39) + @UserName + CHAR(39) + ', 
                                DocumentType, InformMode, NULL, ''D'', ' + NCHAR(39) + @TempName + CHAR(39) + ', NULL, Comment 
                            FROM PDBAlarm_Old_8542
                            WHERE AlarmIndex = ' + CONVERT(varchar(10), @AlarmIndex)
                            
                    EXECUTE (@QueryStr)
                    IF @@ERROR <> 0
                    BEGIN
                        ROLLBACK TRANSACTION TranUpdateAlarm
                        RETURN    
                    END    
 
                    SELECT @Comment = SUBSTRING(@Comment, @Pos + 1, 8000)
                    SELECT @Pos = CHARINDEX(',' , @Comment)
                END
            END
            ELSE
            BEGIN
                SELECT @UserGeneratedName = ISNULL((SELECT UserIndex FROM PDBUser WHERE PDBUser.UserName = @UserGenerated), 0)
                SELECT @UserName = UserName FROM PDBUSER WHERE UserIndex = @UserIndex
                SELECT @SetByUserName = UserName FROM PDBUSER WHERE UserIndex = @SetByUser
                SELECT @QueryStr = N'INSERT INTO PDBGeneratedAlarm(AlarmIndex, AlarmType, ActiveObjectType, 
                        ActiveObjectId, ActiveObjectName, ActiveObjectPath, 
                        UserGeneratedId, UserGenerated, ActionType, AlarmDateTime, 
                        SetByUser, SetByUserName, SetForUserId, SetForUserName,
                        DocumentType, InformMode, 
                        SubsidiaryObjectId, SubsidiaryObjectType, 
                        SubsidiaryObjectName, SubsidiaryObjectPath, 
                        Comment) 
                        SELECT AlarmIndex, AlarmType, ObjectType, 
                            ObjectId, ObjectName, ' + 
                            @DataBaseOwner + '.GetNameOrPath(ObjectType, ObjectId, 301, ''P''), 
                            ' + NCHAR(39) +CONVERT(varchar(255), @UserGeneratedName) + CHAR(39) + ',
                            UserGenerated,     ActionType, AlarmDateTime, 
                            SetByUser, ' + NCHAR(39) + @SetByUserName + CHAR(39) + ', 
                            UserIndex, ' + NCHAR(39) + @UserName + CHAR(39) + ', 
                            DocumentType, InformMode, NULL, ''D'', ' + NCHAR(39) + @TempName + CHAR(39) + ', NULL, Comment 
                        FROM PDBAlarm_Old_8542
                        WHERE AlarmIndex = ' + CONVERT(varchar(10), @AlarmIndex)
                        
                EXECUTE (@QueryStr)
                IF @@ERROR <> 0
                BEGIN
                    ROLLBACK TRANSACTION TranUpdateAlarm
                    RETURN    
                END    
            END
            FETCH NEXT FROM alarmcur INTO @AlarmIndex, @Comment, @ActionType,@UserGenerated,@SetByUser,@UserIndex
        END
        CLOSE alarmcur
        IF @@ERROR <> 0
        BEGIN
            ROLLBACK TRANSACTION TranUpdateAlarm
            RETURN    
        END    
        DEALLOCATE alarmcur
        IF @@ERROR <> 0
        BEGIN
            ROLLBACK TRANSACTION TranUpdateAlarm
            RETURN    
        END    
        EXECUTE('DECLARE AlarmCursor CURSOR FAST_FORWARD FOR
        SELECT AlarmIndex, AlarmType, ObjectType, ObjectId,ObjectName, UserGenerated,ActionType,
                AlarmDateTime, UserIndex,SetByUser,DocumentType, InformMode, Comment
                FROM PDBAlarm_Old_8542 WHERE ObjectType = ''U''
                AND AlarmGenerated = ''Y''')
        OPEN AlarmCursor
        FETCH NEXT FROM AlarmCursor INTO @AlarmIndex, @AlarmType, @ObjectType, @ObjectId, @ObjectName, @UserGenerated, @ActionType, @AlarmDate,@UserIndex, @SetByUser, @DocumentType, @InformMode, @Comment
        WHILE @@FETCH_STATUS <> -1
        BEGIN
                IF @@FETCH_STATUS <> -2
                BEGIN        
                --EXECUTE('SELECT @UserGeneratedName = ISNULL((SELECT UserIndex FROM PDBUser WHERE PDBUser.UserName = PDBAlarm_Old_8542.UserGenerated), 0)')
                SELECT @QueryString= ISNULL(('SELECT @UserGeneratedName = PDBUser.UserIndex FROM PDBUser,PDBAlarm_Old_8542 WHERE PDBUser.UserName = PDBAlarm_Old_8542.UserGenerated'),0)
                EXEC SP_EXECUTESQL 
                            @query = @QueryString, 
                            @params = N'@UserGeneratedName INT OUTPUT',
                            @UserGeneratedName = @UserGeneratedName OUTPUT
                SELECT @UserName = UserName FROM PDBUSER WHERE UserIndex = @UserIndex
                SELECT @SetByUserName = UserName FROM PDBUSER WHERE UserIndex = @SetByUser
				SELECT @lquote=char(39)
                EXECUTE('INSERT INTO PDBGeneratedAlarm(AlarmIndex, AlarmType, ActiveObjectType, 
                ActiveObjectId, ActiveObjectName, ActiveObjectPath, 
                UserGeneratedId, UserGenerated, ActionType, AlarmDateTime, 
                SetByUser, SetByUserName, SetForUserId, SetForUserName,
                DocumentType, InformMode, 
                SubsidiaryObjectId, SubsidiaryObjectType, 
                SubsidiaryObjectName, SubsidiaryObjectPath, 
                Comment) VALUES('+@AlarmIndex+','+ @lquote+@AlarmType+@lquote+','+@lquote+@ObjectType+@lquote+','+ @ObjectId+','+@lquote+@ObjectName+@lquote+','''','+@UserGeneratedName+','+@lquote+@UserGenerated+@lquote+','+@ActionType+','+@lquote+@AlarmDate+@lquote+','+@SetByUser+','+@lquote+@SetByUserName+@lquote+','+@UserIndex+','+@lquote+@UserName+@lquote+','+@lquote+@DocumentType+@lquote+','+ @lquote+@InformMode+@lquote+',NULL,NULL,NULL,NULL,'+@lquote+@Comment+@lquote+')')              
				IF @@ERROR <> 0
                BEGIN
                    ROLLBACK TRANSACTION TranUpdateAlarm
                    RETURN    
                END        
            END
                FETCH NEXT FROM AlarmCursor INTO @AlarmIndex, @AlarmType, @ObjectType, @ObjectId, @ObjectName, @UserGenerated, @ActionType, @AlarmDate,@UserIndex, @SetByUser, @DocumentType, @InformMode, @Comment 
	    END
        CLOSE AlarmCursor
        DEALLOCATE AlarmCursor       
        SELECT @QueryStr = N' DROP TABLE PDBAlarm_Old_8542'
        IF @@ERROR <> 0
        BEGIN
            ROLLBACK TRANSACTION TranUpdateAlarm
            RETURN    
        END    
        EXECUTE (@QueryStr)
        IF @@ERROR <> 0
        BEGIN
            ROLLBACK TRANSACTION TranUpdateAlarm
            RETURN    
        END    
        COMMIT TRANSACTION TranUpdateAlarm
    END
ELSE
BEGIN
    SELECT 0
    insert into PDBUpdateStatus values ('Alter TABLE', 'Altering TABLE PDBAlarm' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
		SELECT 1 FROM INFORMATION_SCHEMA.TABLES
		WHERE TABLE_NAME = 'PDBAlarmActions')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBAlarmActions' , getdate(), NULL, 'UPDATING')

	CREATE TABLE PDBAlarmActions
	(
	ActionId		SMALLINT ,
	ActionName		NVARCHAR(64),
	Category			char(1),
	Comment				NVARCHAR(255) NULL,
	CONSTRAINT pk_ActionId PRIMARY KEY(ActionId,Category)
	)
	
	INSERT INTO PDBAlarmActions(ActionId,ActionName,Category,Comment) VALUES (2,'Document Deleted','D','')
	INSERT INTO PDBAlarmActions(ActionId,ActionName,Category,Comment) VALUES (6,'Notes added','D','')
	INSERT INTO PDBAlarmActions(ActionId,ActionName,Category,Comment) VALUES (8,'Document Moved','D','')
	INSERT INTO PDBAlarmActions(ActionId,ActionName,Category,Comment) VALUES (9,'Document Renamed','D','')
	INSERT INTO PDBAlarmActions(ActionId,ActionName,Category,Comment) VALUES (10,'Document Shared','D','')
	INSERT INTO PDBAlarmActions(ActionId,ActionName,Category,Comment) VALUES (12,'Document Checked In','D','')
	INSERT INTO PDBAlarmActions(ActionId,ActionName,Category,Comment) VALUES (13,'Document Checked Out','D','')
	INSERT INTO PDBAlarmActions(ActionId,ActionName,Category,Comment) VALUES (2,'Document Deleted','F','')
	INSERT INTO PDBAlarmActions(ActionId,ActionName,Category,Comment) VALUES (4,'Document Added','F','')
	INSERT INTO PDBAlarmActions(ActionId,ActionName,Category,Comment) VALUES (6,'Notes added','F','')
	INSERT INTO PDBAlarmActions(ActionId,ActionName,Category,Comment) VALUES (8,'Document Moved','F','')
	INSERT INTO PDBAlarmActions(ActionId,ActionName,Category,Comment) VALUES (9,'Document Renamed','F','')
	INSERT INTO PDBAlarmActions(ActionId,ActionName,Category,Comment) VALUES (10,'Document Shared','F','')
	INSERT INTO PDBAlarmActions(ActionId,ActionName,Category,Comment) VALUES (12,'Document Checked In','F','')
	INSERT INTO PDBAlarmActions(ActionId,ActionName,Category,Comment) VALUES (13,'Document Checked Out','F','')
	INSERT INTO PDBAlarmActions(ActionId,ActionName,Category,Comment) VALUES (17,'Folder Added','F','')
	INSERT INTO PDBAlarmActions(ActionId,ActionName,Category,Comment) VALUES (18,'Folder Moved','F','')
	INSERT INTO PDBAlarmActions(ActionId,ActionName,Category,Comment) VALUES (19,'Folder Deleted','F','')
	INSERT INTO PDBAlarmActions(ActionId,ActionName,Category,Comment) VALUES (20,'Folder Renamed','F','')
	INSERT INTO PDBAlarmActions(ActionId,ActionName,Category,Comment) VALUES (2,'Document Deleted','C','')
	INSERT INTO PDBAlarmActions(ActionId,ActionName,Category,Comment) VALUES (4,'Document Added','C','')
	INSERT INTO PDBAlarmActions(ActionId,ActionName,Category,Comment) VALUES (6,'Notes added','C','')
	INSERT INTO PDBAlarmActions(ActionId,ActionName,Category,Comment) VALUES (8,'Document Moved','C','')
	INSERT INTO PDBAlarmActions(ActionId,ActionName,Category,Comment) VALUES (9,'Document Renamed','C','')
	INSERT INTO PDBAlarmActions(ActionId,ActionName,Category,Comment) VALUES (10,'Document Shared','C','')
	INSERT INTO PDBAlarmActions(ActionId,ActionName,Category,Comment) VALUES (12,'Document Checked In','C','')
	INSERT INTO PDBAlarmActions(ActionId,ActionName,Category,Comment) VALUES (13,'Document Checked Out','C','')
	INSERT INTO PDBAlarmActions(ActionId,ActionName,Category,Comment) VALUES (17,'Folder Added','C','')
	INSERT INTO PDBAlarmActions(ActionId,ActionName,Category,Comment) VALUES (18,'Folder Moved','C','')
	INSERT INTO PDBAlarmActions(ActionId,ActionName,Category,Comment) VALUES (19,'Folder Deleted','C','')
	INSERT INTO PDBAlarmActions(ActionId,ActionName,Category,Comment) VALUES (20,'Folder Renamed','C','')
	INSERT INTO PDBAlarmActions(ActionId,ActionName,Category,Comment) VALUES (21,'Login User High','U','')
	INSERT INTO PDBAlarmActions(ActionId,ActionName,Category,Comment) VALUES (22,'Folder Shared','D','')
	INSERT INTO PDBAlarmActions(ActionId,ActionName,Category,Comment) VALUES (22,'Folder Shared','F','')
	INSERT INTO PDBAlarmActions(ActionId,ActionName,Category,Comment) VALUES (22,'Folder Shared','C','')
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	IF NOT EXISTS(
	SELECT 1 FROM PDBAlarmActions
	WHERE ActionId = 21
	)
	BEGIN
		INSERT INTO PDBUpdateStatus VALUES ('INSERT', 'INSERTING INTO PDBALARMACTIONS FOR ACTIONID =21' , getdate(), NULL, 'UPDATING')
		INSERT INTO PDBAlarmActions(ActionId,ActionName,Category,Comment) VALUES (21,'Login User High','U','')
		SELECT @stepNo = MAX(STEPNUMBER) FROM pdbupdatestatus 
		UPDATE PDBUpdateStatus SET status = 'UPDATED', enddate = getdate() WHERE STEPNUMBER = @stepNo
	END
	IF NOT EXISTS(
	SELECT 1 FROM PDBAlarmActions
	WHERE ActionId = 22 AND Category ='D'
	)
	BEGIN
		INSERT INTO PDBUpdateStatus VALUES ('INSERT', 'INSERTING INTO PDBALARMACTIONS FOR ACTIONID =22 AND CATEGORY =''D''' , getdate(), NULL, 'UPDATING')
		INSERT INTO PDBAlarmActions(ActionId,ActionName,Category,Comment) VALUES (22,'Folder Shared','D','')
		SELECT @stepNo = MAX(STEPNUMBER) FROM pdbupdatestatus 
		UPDATE PDBUpdateStatus SET status = 'UPDATED', enddate = getdate() WHERE STEPNUMBER = @stepNo
	END
	IF NOT EXISTS(
	SELECT 1 FROM PDBAlarmActions
	WHERE ActionId = 22 AND Category ='F'
	)
	BEGIN
		INSERT INTO PDBUpdateStatus VALUES ('INSERT', 'INSERTING INTO PDBALARMACTIONS FOR ACTIONID =22 AND CATEGORY =''F''' , getdate(), NULL, 'UPDATING')
		INSERT INTO PDBAlarmActions(ActionId,ActionName,Category,Comment) VALUES (22,'Folder Shared','F','')
		SELECT @stepNo = MAX(STEPNUMBER) FROM pdbupdatestatus 
		UPDATE PDBUpdateStatus SET status = 'UPDATED', enddate = getdate() WHERE STEPNUMBER = @stepNo
	END
	IF NOT EXISTS(
	SELECT 1 FROM PDBAlarmActions
	WHERE ActionId = 22 AND Category ='C'
	)
	BEGIN
		INSERT INTO PDBUpdateStatus VALUES ('INSERT', 'INSERTING INTO PDBALARMACTIONS FOR ACTIONID =22 AND CATEGORY =''C''' , getdate(), NULL, 'UPDATING')
		INSERT INTO PDBAlarmActions(ActionId,ActionName,Category,Comment) VALUES (22,'Folder Shared','C','')
		SELECT @stepNo = MAX(STEPNUMBER) FROM pdbupdatestatus 
		UPDATE PDBUpdateStatus SET status = 'UPDATED', enddate = getdate() WHERE STEPNUMBER = @stepNo
	END
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBAlarmActions' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBReminder'
	AND COLUMN_NAME = 'DocIndex')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBReminder add ObjectIndex' , getdate(), NULL, 'UPDATING')

	EXECUTE sp_rename N'PDBReminder.DocIndex', N'ObjectIndex', 'COLUMN'
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBReminder add ObjectIndex' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBReminder'
	AND COLUMN_NAME = 'DocName')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBReminder add ObjectName' , getdate(), NULL, 'UPDATING')

	EXECUTE sp_rename N'PDBReminder.DocName', N'ObjectName', 'COLUMN' 
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBReminder add ObjectName' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBReminder'
	AND COLUMN_NAME = 'ObjectType')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBReminder add ObjectType' , getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBReminder ADD ObjectType char(1) Constraint ck_reminder_objecttype check (ObjectType in ('D','F')) NOT NULL Constraint DF_reminder_objecttype DEFAULT 'D' WITH VALUES
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBReminder add ObjectType' , getdate(), getdate(), 'ALREADY UPDATED')
END
;


BEGIN
	SELECT 1
	SET NOCOUNT ON
	DECLARE @name varchar(900)
	DECLARE @Id	int
	DECLARE @ColId	int

	SELECT @Id = id
	FROM sysobjects 
	WHERE name = 'PDBREMINDER'

	SELECT @ColId = ColId
	FROM syscolumns
	WHERE Name = 'OBJECTTYPE'
	AND id = @id


	SELECT @name = Name
	FROM SYSCONSTRAINTS A, SYSOBJECTS B
	WHERE A.constid = B.id
	AND B.xtype = 'C'
	AND A.id = @id
	AND colid = @ColId

	IF (@@ROWCOUNT > 0)
	BEGIN
		declare @stepNo int
		insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBREMINDER chaning Check CONSTRAINT on OBJECTTYPE', getdate(), NULL, 'UPDATING')
	
		
		EXECUTE ('ALTER TABLE PDBREMINDER DROP CONSTRAINT ' + @name)
		EXECUTE ('ALTER TABLE PDBREMINDER WITH NOCHECK ADD CONSTRAINT ' +  @name+ ' CHECK (OBJECTTYPE IN (''D'',''F'',''B'')) ')

		

		select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
		update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
	END
END
;





DECLARE @QueryStr NVARCHAR(4000)
IF NOT EXISTS(
		SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'PDBAuditAction'
		AND COLUMN_NAME = 'SysFlag')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBAuditAction add SysFlag' , getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBAuditAction ADD SysFlag CHAR(1) NOT NULL CONSTRAINT DF_AUDITACTION_SYSFLAG DEFAULT 'N'
	EXECUTE(' UPDATE PDBAuditAction SET SYSFLAG = ''Y'' WHERE ActionId IN (101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,117,118,119,120,121,201,202,203,204,207,208,209,210,211,212,213,214,215,216,217,218,219,221,222,223,224,225,303,304,305,307,308,309,310,311,312,313,314,315,316,317,318,319,320,321,601,602,603,604,605,606,607,608,609,610,611,612,613,614,615,616,617,618,619,620,621,622,623,624,625,626,627,628,629,630,631,632,633,634,635,636,637,638,639,640,641,642,643,644,645,646,647,648,649,650,651,652,653,654,655,656,657,658,659,660,661,662,663,664,665,666,667,668)')
	EXECUTE(' UPDATE PDBAuditAction SET SYSFLAG = ''N'' WHERE ActionId IN (116,205,206,220,301,302,306,322)')
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	IF NOT EXISTS(
		SELECT 1 
		FROM sys.default_constraints d
		INNER JOIN sys.columns c 
		ON d.parent_column_id = c.column_id
		WHERE d.parent_object_id = OBJECT_ID(N'PDBAuditAction', N'U')
		AND c.name = 'SysFlag'
	)
	BEGIN
		SELECT @QueryStr = 'ALTER TABLE PDBAuditAction ADD CONSTRAINT DF_AUDITACTION_SYSFLAG DEFAULT ''N'' FOR SysFlag'
		EXECUTE (@QueryStr)	
	END
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBAuditAction add SysFlag' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
		SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'PDBUserConfig'
		AND COLUMN_NAME = 'DormantWarnTimeFlag')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBUserConfig add DormantWarnTimeFlag' , getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBUserConfig ADD DormantWarnTimeFlag CHAR(1)  CONSTRAINT DF_USRCONFIG_WARNFLAG DEFAULT 'N' WITH VALUES
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	EXECUTE('UPDATE PDBUserConfig SET DormantWarnTimeFlag = ''N'' WHERE DormantWarnTimeFlag IS NULL')
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBUserConfig add DormantWarnTimeFlag' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
		SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'PDBUserConfig'
		AND COLUMN_NAME = 'DormantWarnTime')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBUserConfig add DormantWarnTime' , getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBUserConfig ADD DormantWarnTime INT CONSTRAINT DF_USRCONFIG_WARNTIME DEFAULT 0 WITH VALUES
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	EXECUTE('UPDATE PDBUserConfig SET DormantWarnTime = 0 WHERE DormantWarnTime IS NULL')
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBUserConfig add DormantWarnTime' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF EXISTS(
	SELECT Table_Name
	FROM INFORMATION_SCHEMA.Tables A
	WHERE TABLE_NAME LIKE 'DDT_%'
	AND TABLE_TYPE = 'BASE TABLE'
	AND NOT EXISTS
		(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS B
		WHERE A.TABLE_NAME = B.TABLE_NAME
		AND B.COLUMN_NAME = 'UNIQUEID')
)
BEGIN
	SELECT 1
	DECLARE @DDTTableName NVARCHAR(40)
	DECLARE @QueryStr NVARCHAR(4000)
	DECLARE @ConstraintName NVARCHAR(100)
	DECLARE @ConstraintCol  NVARCHAR(4000)
	DECLARE @ColumnName NVARCHAR(100)
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'ALTER TABLE DDT_% ADD UniqueId' , getdate(), NULL, 'UPDATING')
	
	BEGIN TRANSACTION TranDC
	DECLARE ddtcur CURSOR FOR
		SELECT Table_Name FROM INFORMATION_SCHEMA.COLUMNS A
		WHERE A.TABLE_NAME LIKE 'DDT_%'
		AND A.COLUMN_NAME = 'FoldDocIndex'
		AND NOT EXISTS(
			SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS B
			WHERE A.TABLE_NAME = B.TABLE_NAME
			AND B.COLUMN_NAME = 'UniqueId'
		)
	OPEN ddtcur
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRANSACTION TranDC
		RETURN	
	END	

	FETCH NEXT FROM ddtcur INTO @DDTTableName
	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		SELECT @QueryStr = N'ALTER TABLE ' + @DDTTableName + ' ADD UniqueId int NOT NULL DEFAULT 0 WITH VALUES '

		EXECUTE (@QueryStr)
		IF @@ERROR <> 0
		BEGIN
			ROLLBACK TRANSACTION TranDC
			CLOSE ddtcur
			DEALLOCATE ddtcur
			RETURN	
		END


		DECLARE uniquecur CURSOR FOR
			SELECT Constraint_Name FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS A
			WHERE TABLE_NAME = @DDTTableName
			AND CONSTRAINT_TYPE='UNIQUE' 
			AND NOT EXISTS(
				SELECT 1 FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE B
				WHERE A.TABLE_NAME = B.TABLE_NAME
				AND A.Constraint_Name = B.Constraint_Name
				AND B.Column_Name = 'UniqueId'
			)
		OPEN uniquecur
		FETCH NEXT FROM uniquecur INTO @ConstraintName
		WHILE @@FETCH_STATUS =  0
		BEGIN
			SELECT @ConstraintCol = NULL

			DECLARE unqcolcur CURSOR FOR
			SELECT Column_Name FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
			WHERE TABLE_NAME = @DDTTableName
			AND CONSTRAINT_Name = @ConstraintName
			ORDER BY Ordinal_Position
			OPEN unqcolcur
			FETCH NEXT FROM unqcolcur INTO @ColumnName
			WHILE @@FETCH_STATUS = 0
			BEGIN
				IF @ConstraintCol IS NULL
					SELECT @ConstraintCol = @ColumnName
				ELSE
					SELECT @ConstraintCol = @ConstraintCol + ',' + @ColumnName
				FETCH NEXT FROM unqcolcur INTO @ColumnName
			END	
			CLOSE unqcolcur
			DEALLOCATE unqcolcur
			IF @ConstraintCol IS NOT NULL
			BEGIN
				SELECT 	@QueryStr = ' ALTER TABLE ' + @DDTTableName + ' DROP CONSTRAINT ' + @ConstraintName
				EXECUTE (@QueryStr)
				IF @@ERROR <> 0
				BEGIN
					ROLLBACK TRANSACTION TranDC
					CLOSE uniquecur
					DEALLOCATE uniquecur
					CLOSE ddtcur
					DEALLOCATE ddtcur
					RETURN	
				END
				
				SELECT @ConstraintCol = @ConstraintCol + ', UniqueId' 
				SELECT 	@QueryStr = ' ALTER TABLE ' + @DDTTableName + ' ADD CONSTRAINT ' + @ConstraintName + ' UNIQUE ( ' + @ConstraintCol + ' ) '
				EXECUTE (@QueryStr)
				IF @@ERROR <> 0
				BEGIN
					ROLLBACK TRANSACTION TranDC
					CLOSE uniquecur
					DEALLOCATE uniquecur
					CLOSE ddtcur
					DEALLOCATE ddtcur
					RETURN	
				END
			END
			FETCH NEXT FROM uniquecur INTO @ConstraintName
		END
		CLOSE uniquecur
		DEALLOCATE uniquecur
		FETCH NEXT FROM ddtcur INTO @DDTTableName
	END
	CLOSE ddtcur
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRANSACTION TranDC
		RETURN	
	END	
	DEALLOCATE ddtcur
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRANSACTION TranDC
		RETURN	
	END	
	COMMIT TRANSACTION TranDC
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'ALTER TABLE DDT_% ADD UniqueId' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
		SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'PDBRoleRights'
		AND COLUMN_NAME = 'FromDate')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBRoleRights add FromDate' , getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBRoleRights ADD FromDate DATETIME NULL
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBRoleRights add FromDate' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
		SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'PDBRoleRights'
		AND COLUMN_NAME = 'ToDate')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBRoleRights add ToDate' , getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBRoleRights ADD ToDate DATETIME NULL
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBRoleRights add ToDate' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBDocVersionSeries')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBDocVersionSeries' , getdate(), NULL, 'UPDATING')

	CREATE TABLE PDBDocVersionSeries
	(
		VersionSeries	int IDENTITY(1,1) CONSTRAINT   PK_VersionSeries   PRIMARY KEY  Clustered,
		DocumentIndex	int
	)

	CREATE TABLE TempDocVerUpgrade
	(
		DocVersionUpgradeFlag char(1)
	)
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBDocVersionSeries' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

DECLARE @QueryStr NVARCHAR(4000)
IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'PDBNewDocumentVersion')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBNewDocumentVersion' , getdate(), NULL, 'UPDATING')

	CREATE TABLE PDBNewDocumentVersion(
			DocumentIndex int NOT NULL  CONSTRAINT  PK_Version_DocId   PRIMARY KEY  Clustered,
			VersionSeries int NOT NULL,
			VersionNumber DECIMAL(7,2) NOT NULL,
			LatestVersion	CHAR(1) NOT NULL,
			ParentFolderIndex	int NULL,
			CONSTRAINT UK_Version_VSVN UNIQUE(VersionSeries, VersionNumber)
		)
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
			WHERE TABLE_NAME = 'PDBNewDocumentVersion'
			AND CONSTRAINT_NAME = 'UK_Version_VSVN'
		)
		BEGIN
			SELECT @QueryStr = N' ALTER TABLE PDBNewDocumentVersion ADD CONSTRAINT UK_Version_VSVN UNIQUE(VersionSeries, VersionNumber)'
			EXECUTE (@QueryStr)	
		END
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBNewDocumentVersion' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'PDBEvaluationInfo')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBEvaluationInfo' , getdate(), NULL, 'UPDATING')

	CREATE TABLE PDBEvaluationInfo(
			LicenseType char CONSTRAINT CK_EVAL_LICTYPE CHECK (LicenseType IN ('L','E','F')), 
			EncrLicenseType nvarchar(255),	
			NoOfTrailDays int,
			EncrNoOfTrailDays nvarchar(255) NULL,
			CabinetCreationDate DATETIME,
			EncrCabinetCreationDate nvarchar(255) NULL								
		)
	EXECUTE ('INSERT INTO PDBEvaluationInfo(LicenseType, EncrLicenseType, NoOfTrailDays, EncrNoOfTrailDays, CabinetCreationDate, EncrCabinetCreationDate) VALUES(''E'',''0'',0,''0'', (SELECT CreatedDateTime FROM PDBCabinet),''0'')')
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBEvaluationInfo' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'PDBObjectNotes')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBObjectNotes' , getdate(), NULL, 'UPDATING')

	CREATE TABLE PDBObjectNotes(
		NoteIndex 		int IDENTITY(1,1) CONSTRAINT pk_NotesIndex PRIMARY KEY  Clustered,
		ObjectType 		CHAR(1) not null,
		ObjectIndex		int not null,
		CreatedDateTime DATETIME not null,
		CreatedBy		int not null,
		CreatedByName   NVARCHAR(64) not null,
		ActivityName	NVARCHAR(255) null,
		ActionName		NVARCHAR(255) null,
		Notes			NText null,
		ACL				Varchar(255) null,
		ACLMoreFlag		Char(1) default 'N'
	)
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBObjectNotes' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'PDBRepository')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBRepository' , getdate(), NULL, 'UPDATING')

	CREATE TABLE PDBRepository
	( 
		RepId 				int IDENTITY(1,1) CONSTRAINT PK_Repository_RepId PRIMARY KEY Clustered,
		RepositoryName  	VARCHAR(400) NOT NULL,
		RepositoryDetails 	ntext NOT NULL,
		RepType 			VARCHAR(255) NOT NULL
	)
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBRepository' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'SDBLocationType')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE SDBLocationType' , getdate(), NULL, 'UPDATING')

	CREATE TABLE SDBLocationType
	(
		LocId       int IDENTITY(1,1) CONSTRAINT pk_locid PRIMARY KEY  Clustered,
		LocLevel	int ,
		LocTypeName	nvarchar(64),
		CONSTRAINT uk_LocType   UNIQUE (LocLevel, LocTypeName)
	)
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE SDBLocationType' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'SDBDesktopTable')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE SDBDesktopTable' , getdate(), NULL, 'UPDATING')

	CREATE TABLE SDBDesktopTable
	(
		TabName		nvarchar(64),
		TabType		char(1)CONSTRAINT   pk_desktable PRIMARY KEY(TabType)
	)
	EXECUTE(' INSERT INTO SDBDesktopTable(TabName,TabType) VALUES(''Scanning Desktop'',''S'')')
	EXECUTE(' INSERT INTO SDBDesktopTable(TabName,TabType) VALUES(''Indexing Desktop'',''I'')')
	EXECUTE(' INSERT INTO SDBDesktopTable(TabName,TabType) VALUES(''Access Desktop'',''A'')')
	EXECUTE(' INSERT INTO SDBDesktopTable(TabName,TabType) VALUES(''Processing Desktop'',''P'')')
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE SDBDesktopTable' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'SDBActivityTable')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE SDBActivityTable' , getdate(), NULL, 'UPDATING')

	CREATE TABLE SDBActivityTable
	(
		ActivityId		        int IDENTITY(1,1) CONSTRAINT   pk_activitytable PRIMARY KEY  Clustered,
		ActivityName			nvarchar(64),
		DesktopType				char(1) CONSTRAINT fk_ActivityTable_DeskType REFERENCES SDBDesktopTable(TabType), 	
		RoleId					int CONSTRAINT fk_RoleActivityTable_RoleId REFERENCES PDBRoles(RoleIndex),
		FileDefId				int CONSTRAINT fk_ActivityTable_FolderId REFERENCES PDBFolder(FolderIndex),
		ActivityFolderId		int CONSTRAINT fk_ActivityTable_ActvityFolderId REFERENCES PDBFolder(FolderIndex),
		ActivityType			nvarchar(64)
	)
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE SDBActivityTable' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'SDBRoleFileDefTable')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE SDBRoleFileDefTable' , getdate(), NULL, 'UPDATING')

	CREATE TABLE SDBRoleFileDefTable
	(
		RoleId		int CONSTRAINT fk_RoleTable_RoleId REFERENCES PDBRoles(RoleIndex),
		FileDefId   int CONSTRAINT fk_RoleTable_FolderId REFERENCES PDBFolder(FolderIndex)
	)
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE SDBRoleFileDefTable' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

BEGIN
	SELECT 0
	SET NOCOUNT ON
	DECLARE @StepNo			int
	CREATE TABLE #indfol(index_name varchar(256), indexdesc varchar(256), indkey varchar(2126))
	INSERT INTO #indfol exec sp_helpindex 'PDBFTSDATA'

	IF EXISTS(SELECT indkey FROM #indfol WHERE index_name = 'FTSCATALOG')
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'dropping index on Table PDBFTSDATA' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		DROP INDEX PDBFTSDATA.FTSCATALOG

		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		SET NOCOUNT ON
		INSERT INTO PDBUpdateStatus values ('Create Index', 'dropping index on Table PDBFTSDATA' , GETDATE(), NULL, 'Already Updated')
	END
	DROP TABLE #indfol
END
;

-----------------------------------------------------------------------------------------------
-- Changed By				: Shipra Tiwari
-- Reason / Cause (Bug No if Any)	: Changes For Upgrade with hotfix 
-- Change Description			: Changes For Upgrade with hotfix 
-----------------------------------------------------------------------------------------------

IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUserConfig'
	AND COLUMN_NAME = 'RepeatCharInPassword')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUserConfig add RepeatCharInPassword', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBUserConfig ADD RepeatCharInPassword CHAR(1) NOT NULL CONSTRAINT df_Usrconfig_repchar DEFAULT 'N'
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUserConfig  add RepeatCharInPassword', getdate(), getdate(), 'ALREADY UPDATED')
	
END	
;

IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBFolder'
	AND COLUMN_NAME = 'EnableSecure')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBFolder add EnableSecure', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBFolder ADD EnableSecure CHAR(1) NOT NULL CONSTRAINT df_folder_ensec DEFAULT 'N'

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBFolder  add EnableSecure', getdate(), getdate(), 'ALREADY UPDATED')
	
END	
;

IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBDocument'
	AND COLUMN_NAME = 'EnableSecure')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDocument add EnableSecure', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBDocument ADD EnableSecure CHAR(1) NOT NULL CONSTRAINT df_doc_ensec DEFAULT 'N'

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDocument  add EnableSecure', getdate(), getdate(), 'ALREADY UPDATED')
END	
;

IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBCabinet'
	AND COLUMN_NAME = 'EnableSecure')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBCabinet add EnableSecure', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBCabinet ADD EnableSecure CHAR(1) NOT NULL CONSTRAINT df_cab_ensec DEFAULT 'N'
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBCabinet  add EnableSecure', getdate(), getdate(), 'ALREADY UPDATED')
END	
;

IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUserConfig'
	AND COLUMN_NAME = 'PasswdExpiryMailFlag')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUserConfig add PasswdExpiryMailFlag', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBUserConfig ADD PasswdExpiryMailFlag CHAR(1) CONSTRAINT df_Usrconfig_pemf DEFAULT 'N' NOT NULL
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUserConfig  add PasswdExpiryMailFlag', getdate(), getdate(), 'ALREADY UPDATED')
	
END	
;

IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBGlobalIndex'
	AND COLUMN_NAME = 'RightsCheckEnabled')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGlobalIndex add RightsCheckEnabled', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBGlobalIndex ADD RightsCheckEnabled CHAR(1) NOT NULL CONSTRAINT ck_picklist_rightscheck  CHECK (RightsCheckEnabled IN ('Y','N')) CONSTRAINT df_picklist_rightscheck DEFAULT 'N'

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
	
	insert into PDBUpdateStatus values ('Alter View', 'Altering View PDBGTypeGlobalIndex,PDBDTypeGlobalIndex,PDBXTypeGlobalIndex add RightsCheckEnabled', getdate(), NULL, 'UPDATING')
	
	EXECUTE ('ALTER VIEW PDBGTypeGlobalIndex AS SELECT DataFieldIndex, DataFieldName, DataFieldType,DataFieldLength, GlobalOrDataFlag, MainGroupId, Pickable,RightsCheckEnabled FROM PDBGlobalIndex WHERE globalordataflag = ''G''')	
	EXECUTE ('ALTER VIEW PDBDTypeGlobalIndex AS SELECT DataFieldIndex, DataFieldName, DataFieldType,DataFieldLength, GlobalOrDataFlag, MainGroupId, Pickable,RightsCheckEnabled FROM PDBGlobalIndex WHERE globalordataflag = ''D''')	
	EXECUTE ('ALTER VIEW PDBXTypeGlobalIndex AS SELECT DataFieldIndex, DataFieldName, DataFieldType,DataFieldLength, GlobalOrDataFlag, MainGroupId, Pickable,RightsCheckEnabled FROM PDBGlobalIndex WHERE globalordataflag = ''X''')		
		
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
        update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON

	insert into PDBUpdateStatus values ('Alter View', 'Altering View PDBGTypeGlobalIndex,PDBDTypeGlobalIndex,PDBXTypeGlobalIndex add RightsCheckEnabled', getdate(), NULL, 'UPDATING')
	
	EXECUTE ('ALTER VIEW PDBGTypeGlobalIndex AS SELECT DataFieldIndex, DataFieldName, DataFieldType,DataFieldLength, GlobalOrDataFlag, MainGroupId, Pickable,RightsCheckEnabled FROM PDBGlobalIndex WHERE globalordataflag = ''G''')	
	EXECUTE ('ALTER VIEW PDBDTypeGlobalIndex AS SELECT DataFieldIndex, DataFieldName, DataFieldType,DataFieldLength, GlobalOrDataFlag, MainGroupId, Pickable,RightsCheckEnabled FROM PDBGlobalIndex WHERE globalordataflag = ''D''')	
	EXECUTE ('ALTER VIEW PDBXTypeGlobalIndex AS SELECT DataFieldIndex, DataFieldName, DataFieldType,DataFieldLength, GlobalOrDataFlag, MainGroupId, Pickable,RightsCheckEnabled FROM PDBGlobalIndex WHERE globalordataflag = ''X''')		
		
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
        update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
	
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGlobalIndex add RightsCheckEnabled', getdate(), getdate(), 'ALREADY UPDATED')
END	
;

IF NOT EXISTS( SELECT 1 FROM PDBConstant WHERE Id = -50252 AND Message = 'PRT_ERR_Invalid_Rights_PickList')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant ADD PRT_ERR_Invalid_Rights_PickList value', getdate(), NULL, 'UPDATING')
	
	IF EXISTS( SELECT 1 FROM PDBConstant WHERE Id = -50252)
	BEGIN
		DELETE FROM PDBConstant WHERE Id = -50252
	END	
	IF EXISTS( SELECT 1 FROM PDBConstant WHERE Message = 'PRT_ERR_Invalid_Rights_PickList')
	BEGIN
		DELETE FROM PDBConstant WHERE Message = 'PRT_ERR_Invalid_Rights_PickList'
	END	
	
	INSERT INTO PDBConstant VALUES (-50252,'PRT_ERR_Invalid_Rights_PickList','Error')
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
Else
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant ADD PRT_ERR_Invalid_Rights_PickList value', getdate(), getdate(), 'ALREADY UPDATED')

END
;

IF NOT EXISTS( SELECT 1 FROM PDBConstant WHERE Id = -50253 AND Message = 'PRT_ERR_PickList_Not_Exist')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant ADD PRT_ERR_PickList_Not_Exist Value', getdate(), NULL, 'UPDATING')
	
	IF EXISTS( SELECT 1 FROM PDBConstant WHERE Id = -50253)
	BEGIN
		DELETE FROM PDBConstant WHERE Id = -50253
	END	
	IF EXISTS( SELECT 1 FROM PDBConstant WHERE Message = 'PRT_ERR_PickList_Not_Exist')
	BEGIN
		DELETE FROM PDBConstant WHERE Message = 'PRT_ERR_PickList_Not_Exist'
	END	
	
	INSERT INTO PDBConstant VALUES (-50253,'PRT_ERR_PickList_Not_Exist','Error')
    
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END	
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant ADD PDBConstantPRT_ERR_PickList_Not_Exist Value ', getdate(), getdate(), 'ALREADY UPDATED')

END
;

IF NOT EXISTS( SELECT 1 FROM PDBConstant WHERE Id = -50254 AND Message = 'PRT_ERR_Field_Not_Pickable')
	BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant ADD PRT_ERR_Field_Not_Pickable Value', getdate(), NULL, 'UPDATING')
	
	IF EXISTS( SELECT 1 FROM PDBConstant WHERE Id = -50254)
	BEGIN
		DELETE FROM PDBConstant WHERE Id = -50254
	END	
	IF EXISTS( SELECT 1 FROM PDBConstant WHERE Message = 'PRT_ERR_Field_Not_Pickable')
	BEGIN
		DELETE FROM PDBConstant WHERE Message = 'PRT_ERR_Field_Not_Pickable'
	END	
	
	INSERT INTO PDBConstant VALUES (-50254,'PRT_ERR_Field_Not_Pickable','Error')
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo	
END
ELSE
	BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant VALUES PRT_ERR_Field_Not_Pickable Value ', getdate(), getdate(), 'ALREADY UPDATED')

END
;

IF EXISTS(
SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'PDBPickList' 
AND COLUMN_NAME = 'FoldDocFlag')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	DECLARE @QueryStr NVARCHAR(4000)
	DECLARE @DataFieldIndex INT
	DECLARE @FieldValue NVARCHAR(255)
	DECLARE @DocumentIndex  INT
	DECLARE @ACLMoreFlag	char(1)
	DECLARE @TotalExistingRecord	int 
	insert into PDBUpdateStatus values ('Create Table', 'Creating Table PDBPickList Dropping Old table', getdate(), NULL, 'UPDATING')
	
	BEGIN TRANSACTION TranPickList
	EXEC SP_RENAME 'PDBPickList.IDX_DataFieldIndex', 'IDX_DataFieldIndex_Old_39456' 
	
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRANSACTION TranPickList
		RETURN	
	END	

	EXEC SP_RENAME 'PDBPickList', 'PDBPickList_Old_39456' 
	
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRANSACTION TranPickList
		RETURN	
	END	

	CREATE TABLE PDBPickList
	(
		PickListIndex 			INT IDENTITY(1,1) CONSTRAINT pk_pickListId PRIMARY KEY,
		ACL 					VARCHAR(255) NULL,
		ACLMoreFlag 			CHAR(1) NOT NULL CONSTRAINT ck_picklist_aclmflag CHECK (ACLMoreFlag IN ('Y','N')) DEFAULT 'N',	
		DataFieldIndex			int not null,
		FieldValue				NVARCHAR(255) NULL,
		CONSTRAINT uk_FieldIdValue   UNIQUE (DataFieldIndex, FieldValue)
	)
	
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRANSACTION TranPickList
		RETURN	
	END	

	SELECT  @QueryStr = ' DECLARE picklistcur CURSOR FOR SELECT DataFieldIndex, FieldValue ' +' FROM PDBPickList_Old_39456 '
	EXECUTE (@QueryStr)
	OPEN picklistcur
	SELECT @TotalExistingRecord = @@CURSOR_ROWS
	IF (@TotalExistingRecord = 0)
	BEGIN
		ROLLBACK TRANSACTION TranPickList
		RETURN	
	END	
	FETCH NEXT FROM picklistcur INTO @DataFieldIndex, @FieldValue
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF NOT EXISTS(SELECT 1 FROM PDBPickList WHERE DataFieldIndex = @DataFieldIndex AND FieldValue = @FieldValue)
		BEGIN
			SELECT @QueryStr = 'INSERT INTO PDBPickList(ACL, ACLMoreFlag, DataFieldIndex, 	FieldValue)
			VALUES (NULL, ''N'',' + CONVERT(varchar(10), @DataFieldIndex) + ',' + NCHAR(39) +  	@FieldValue + NCHAR(39) +  ' ) '
			IF @@ERROR <> 0
			BEGIN
				CLOSE picklistcur
				IF @@ERROR <> 0
				BEGIN
					ROLLBACK TRANSACTION TranPickList
					RETURN	
				END	
				DEALLOCATE picklistcur
				IF @@ERROR <> 0
				BEGIN
					ROLLBACK TRANSACTION TranPickList
					RETURN	
				END	
				ROLLBACK TRANSACTION TranPickList
				RETURN	
			END	
			EXECUTE (@QueryStr)
			IF @@ERROR <> 0
			BEGIN
				CLOSE picklistcur
				IF @@ERROR <> 0
				BEGIN
					ROLLBACK TRANSACTION TranPickList
					RETURN	
				END	
				DEALLOCATE picklistcur
				IF @@ERROR <> 0
				BEGIN
					ROLLBACK TRANSACTION TranPickList
					RETURN	
				END	
				ROLLBACK TRANSACTION TranPickList
				RETURN	
			END	
		END
		FETCH NEXT FROM picklistcur INTO @DataFieldIndex, @FieldValue
	END
	CLOSE picklistcur
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRANSACTION TranPickList
		RETURN	
	END	
	DEALLOCATE picklistcur
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRANSACTION TranPickList
		RETURN	
	END	
	SELECT  @QueryStr = ' DROP TABLE PDBPickList_Old_39456 '
	EXECUTE (@QueryStr)
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRANSACTION TranPickList
		RETURN	
	END	
	COMMIT TRANSACTION TranPickList
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo	
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Create Table', 'Creating Table PDBPickList', getdate(), getdate(), 'ALREADY UPDATED')

END
;

IF NOT EXISTS(
SELECT 1 FROM INFORMATION_SCHEMA.CHECK_CONSTRAINTS 
WHERE CONSTRAINT_NAME = 'ck_globalind_gOrDflag')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGlobalIndex adding Constraint on GlobalOrDataFlag', getdate(), NULL, 'UPDATING')
		
	ALTER TABLE PDBGlobalIndex ADD CONSTRAINT ck_globalind_gOrDflag CHECK (GlobalOrDataFlag IN ('G','D', 'S', 'H', 'M'))
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
	
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGlobalIndex adding Constraint on GlobalOrDataFlag', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBGlobalIndex DROP CONSTRAINT ck_globalind_gOrDflag
	ALTER TABLE PDBGlobalIndex ADD CONSTRAINT ck_globalind_gOrDflag CHECK (GlobalOrDataFlag IN ('G','D', 'S', 'H', 'M'))
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo

END
;

-----------------------------------------------------------------------------------------------
-- Changed By				: Swati Gupta
-- Reason / Cause (Bug No if Any)	: Changes For Upgrade with hotfix 
-- Change Description			: Changes For Upgrade with hotfix 
-----------------------------------------------------------------------------------------------
BEGIN
    SELECT 1
	SET NOCOUNT ON 
	DECLARE	@name varchar(900)
	DECLARE @Id	int
	DECLARE @ColId	int
	DECLARE @stepNo int
	BEGIN
		SELECT @Id = id
		FROM sysobjects 
		WHERE name = 'PDBKeyword'

		SELECT @ColId = ColId
		FROM syscolumns
		WHERE Name = 'DocumentIndex'
		AND id = @id
		

		SELECT @name = Name
		FROM SYSCONSTRAINTS A, SYSOBJECTS B
		WHERE A.constid = B.id
		AND A.id = @id
		AND colid = @ColId
		
		IF EXISTS(SELECT 1 FROM  INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
					WHERE CONSTRAINT_NAME = @name 
					AND TABLE_NAME = 'PDBKeyword')
		BEGIN			
		EXECUTE ('ALTER TABLE dbo.PDBKeyword DROP CONSTRAINT ' + @name)
		END
		
		insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBKeyword Renaming Column DocumentIndex to ObjectIndex', getdate(), NULL, 'UPDATING')	
		
		IF NOT EXISTS(
			SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
			WHERE TABLE_NAME = 'PDBKeyword'
			AND COLUMN_NAME = 'ObjectIndex')
		BEGIN	
		
			EXEC sp_rename 'PDBKeyword.DocumentIndex','ObjectIndex','COLUMN'
		END	
		
		select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
		update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
		insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBKeyword adding Column ObjectType', getdate(), NULL, 'UPDATING')	
		
		IF NOT EXISTS(
			SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
			WHERE TABLE_NAME = 'PDBKeyword'
			AND COLUMN_NAME = 'ObjectType')
		BEGIN
			ALTER TABLE PDBKeyword ADD ObjectType CHAR(1) NOT NULL DEFAULT 'D'
		END	
		
		select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
		update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
		insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBKeyword adding Constraint on ObjectIndex,KeywordIndex,ObjectType', getdate(), NULL, 'UPDATING')	
		
		IF EXISTS(SELECT 1 FROM  INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
					WHERE CONSTRAINT_NAME = 'PK_KEYWORD2' 
					AND TABLE_NAME = 'PDBKeyword')
		BEGIN			
			ALTER TABLE PDBKeyword DROP CONSTRAINT pk_keyword2 
		END
		
		IF NOT EXISTS(SELECT 1 FROM  INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
				WHERE CONSTRAINT_NAME = 'pk_keyword2' AND TABLE_NAME = 'PDBKeyword')
		
		BEGIN
			ALTER TABLE PDBKeyword ADD CONSTRAINT pk_keyword2 
			PRIMARY KEY(ObjectIndex,KeywordIndex,ObjectType)
		END
		
		select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
		update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
		IF NOT EXISTS (SELECT 1 FROM PDBAuditAction
				WHERE ActionId = 669 AND Category = 'F')
		BEGIN
		    insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction Add Keyword With Folder Action', getdate(), NULL, 'UPDATING')
			INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment,SysFlag) VALUES (669, 'F', 'Add Keyword With Folder', 'Y',  NULL, 'Y')
			select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
			update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		END

		IF NOT EXISTS (SELECT 1 FROM PDBAuditAction
				WHERE ActionId = 670 AND Category = 'F')
		BEGIN
		    insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction ADD Delete Keyword From Folder Action', getdate(), NULL, 'UPDATING')
			INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment,SysFlag) VALUES (670, 'F', 'Delete Keyword From Folder', 'Y',  NULL, 'Y')
			select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
			update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		END	
	END
END	
;
-----------------------------------------------------------------------------------------------
-- Changed By				: Swati Gupta
-- Reason / Cause (Bug No if Any)	: Changes For Upgrade with hotfix 39
-- Change Description			: Changes For Upgrade with hotfix 39
-----------------------------------------------------------------------------------------------
IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBThumbnail'
	AND COLUMN_NAME = 'ImageIndex')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBThumbnail add ImageIndex', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBThumbnail ADD ImageIndex INT 
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBThumbnail  add ImageIndex', getdate(), getdate(), 'ALREADY UPDATED')
	
END	
;

IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBThumbnail'
	AND COLUMN_NAME = 'VolumeId')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBThumbnail add VolumeId', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBThumbnail ADD VolumeId INT 
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBThumbnail  add VolumeId', getdate(), getdate(), 'ALREADY UPDATED')
	
END	
;

IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBThumbnailVersion'
	AND COLUMN_NAME = 'ImageIndex')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBThumbnailVersion add ImageIndex', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBThumbnailVersion ADD ImageIndex INT 
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBThumbnailVersion  add ImageIndex', getdate(), getdate(), 'ALREADY UPDATED')
	
END	
;

IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBThumbnailVersion'
	AND COLUMN_NAME = 'VolumeId')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBThumbnailVersion add VolumeId', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBThumbnailVersion ADD VolumeId INT 
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBThumbnailVersion  add VolumeId', getdate(), getdate(), 'ALREADY UPDATED')
	
END	
;

IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUSER'
	AND COLUMN_NAME = 'UserImage')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUSER add UserImage', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBUSER ADD UserImage nvarchar(max) NULL
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUSER  add UserImage', getdate(), getdate(), 'ALREADY UPDATED')
	
END	
;

IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUSER'
	AND COLUMN_NAME = 'ImageType')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUSER add ImageType', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBUSER ADD ImageType nvarchar(10) NULL

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUSER  add ImageType', getdate(), getdate(), 'ALREADY UPDATED')
	
END	
;

IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUSER'
	AND COLUMN_NAME = 'ModifiedImageDateTime')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUSER add ModifiedImageDateTime', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBUSER ADD ModifiedImageDateTime datetime NULL

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUSER  add ModifiedImageDateTime', getdate(), getdate(), 'ALREADY UPDATED')
	
END	
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBDOCUMENT'
	AND COLUMN_NAME = 'APPNAME'
	AND DATA_TYPE = 'CHAR'
	AND CHARACTER_MAXIMUM_LENGTH =10
	)
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDOCUMENT Alter Column APPNAME', getdate(), NULL, 'UPDATING')
	
	DROP INDEX PDBDocument.IDX_AppName
	ALTER TABLE PDBDocument ALTER COLUMN AppName CHAR(10)
	CREATE NONCLUSTERED INDEX IDX_AppName ON PDBDocument (AppName)

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDOCUMENT Alter Column APPNAME', getdate(), getdate(), 'ALREADY UPDATED')
	
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBDOCUMENTVERSION'
	AND COLUMN_NAME = 'APPNAME'
	AND DATA_TYPE = 'CHAR'
	AND CHARACTER_MAXIMUM_LENGTH =10
	)
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDOCUMENTVERSION Alter Column APPNAME', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBDOCUMENTVERSION ALTER COLUMN APPNAME CHAR(10)

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDOCUMENTVERSION Alter Column APPNAME', getdate(), getdate(), 'ALREADY UPDATED')
	
END
;

-----------------------------------------------------------------------------------------------------
-- Changed By						: Vikas Dubey
-- Reason / Cause (Bug No if Any)   : To make password configure for LowerCase/UpperCase/Numeric count
-- Change Description				: To make password configure for LowerCase/UpperCase/Numeric count
-----------------------------------------------------------------------------------------------------
IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUserConfig'
	AND COLUMN_NAME = 'MinNumericCharCount')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUserConfig add MinNumericCharCount', getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBUserConfig ADD MinNumericCharCount smallint NOT NULL CONSTRAINT DF_UserConfigMinNumChar DEFAULT 0
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUserConfig  add MinNumericCharCount', getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUserConfig'
	AND COLUMN_NAME = 'MinLowerCaseCharCount')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUserConfig add MinLowerCaseCharCount', getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBUserConfig ADD MinLowerCaseCharCount smallint NOT NULL CONSTRAINT DF_UserConfigMinLowChar DEFAULT 0
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUserConfig  add MinLowerCaseCharCount', getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUserConfig'
	AND COLUMN_NAME = 'MinUpperCaseCharCount')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUserConfig add MinUpperCaseCharCount', getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBUserConfig ADD MinUpperCaseCharCount smallint NOT NULL CONSTRAINT DF_UserConfigMinUppChar DEFAULT 0
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUserConfig add MinUpperCaseCharCount' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS( SELECT 1 FROM PDBConstant WHERE Id = -50255 AND Message = 'PRT_ERR_Passwd_Should_Have_Min_Numeric_Character')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant ADD PRT_ERR_Passwd_Should_Have_Min_Numeric_Character', getdate(), NULL, 'UPDATING')
	
	IF EXISTS( SELECT 1 FROM PDBConstant WHERE Id = -50255)
	BEGIN
		DELETE FROM PDBConstant WHERE Id = -50255
	END	
	IF EXISTS( SELECT 1 FROM PDBConstant WHERE Message = 'PRT_ERR_Passwd_Should_Have_Min_Numeric_Character')
	BEGIN
		DELETE FROM PDBConstant WHERE Message = 'PRT_ERR_Passwd_Should_Have_Min_Numeric_Character'
	END	
	INSERT INTO PDBConstant VALUES (-50255,'PRT_ERR_Passwd_Should_Have_Min_Numeric_Character','Error')
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo	
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant VALUES PRT_ERR_Passwd_Should_Have_Min_Numeric_Character ', getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS( SELECT 1 FROM PDBConstant WHERE Id = -50256 AND Message = 'PRT_ERR_Numeric_Character_Not_Allowed')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant ADD PRT_ERR_Numeric_Character_Not_Allowed', getdate(), NULL, 'UPDATING')
	
	IF EXISTS( SELECT 1 FROM PDBConstant WHERE Id = -50256)
	BEGIN
		DELETE FROM PDBConstant WHERE Id = -50256
	END	
	IF EXISTS( SELECT 1 FROM PDBConstant WHERE Message = 'PRT_ERR_Numeric_Character_Not_Allowed')
	BEGIN
		DELETE FROM PDBConstant WHERE Message = 'PRT_ERR_Numeric_Character_Not_Allowed'
	END	
	INSERT INTO PDBConstant VALUES (-50256,'PRT_ERR_Numeric_Character_Not_Allowed','Error')
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo	
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant VALUES PRT_ERR_Numeric_Character_Not_Allowed', getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS( SELECT 1 FROM PDBConstant WHERE Id = -50257 AND Message = 'PRT_ERR_Passwd_Should_Have_Min_LowerCase_Character')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant ADD PRT_ERR_Passwd_Should_Have_Min_LowerCase_Character', getdate(), NULL, 'UPDATING')
	
	IF EXISTS( SELECT 1 FROM PDBConstant WHERE Id = -50257)
	BEGIN
		DELETE FROM PDBConstant WHERE Id = -50257
	END	
	IF EXISTS( SELECT 1 FROM PDBConstant WHERE Message = 'PRT_ERR_Passwd_Should_Have_Min_LowerCase_Character')
	BEGIN
		DELETE FROM PDBConstant WHERE Message = 'PRT_ERR_Passwd_Should_Have_Min_LowerCase_Character'
	END	
	INSERT INTO PDBConstant VALUES (-50257,'PRT_ERR_Passwd_Should_Have_Min_LowerCase_Character','Error')
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo	
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant VALUES PRT_ERR_Passwd_Should_Have_Min_LowerCase_Character', getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS( SELECT 1 FROM PDBConstant WHERE Id = -50258 AND Message = 'PRT_ERR_LowerCase_Character_Not_Allowed')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant ADD PRT_ERR_LowerCase_Character_Not_Allowed', getdate(), NULL, 'UPDATING')
	
	IF EXISTS( SELECT 1 FROM PDBConstant WHERE Id = -50258)
	BEGIN
		DELETE FROM PDBConstant WHERE Id = -50258
	END	
	IF EXISTS( SELECT 1 FROM PDBConstant WHERE Message = 'PRT_ERR_LowerCase_Character_Not_Allowed')
	BEGIN
		DELETE FROM PDBConstant WHERE Message = 'PRT_ERR_LowerCase_Character_Not_Allowed'
	END	
	INSERT INTO PDBConstant VALUES (-50258,'PRT_ERR_LowerCase_Character_Not_Allowed','Error')
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo	
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant VALUES PRT_ERR_LowerCase_Character_Not_Allowed', getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS( SELECT 1 FROM PDBConstant WHERE Id = -50259 AND Message = 'PRT_ERR_Passwd_Should_Have_Min_UpperCase_Character')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant ADD PRT_ERR_Passwd_Should_Have_Min_UpperCase_Character', getdate(), NULL, 'UPDATING')
	
	IF EXISTS( SELECT 1 FROM PDBConstant WHERE Id = -50259)
	BEGIN
		DELETE FROM PDBConstant WHERE Id = -50259
	END	
	IF EXISTS( SELECT 1 FROM PDBConstant WHERE Message = 'PRT_ERR_Passwd_Should_Have_Min_UpperCase_Character')
	BEGIN
		DELETE FROM PDBConstant WHERE Message = 'PRT_ERR_Passwd_Should_Have_Min_UpperCase_Character'
	END	
	INSERT INTO PDBConstant VALUES (-50259,'PRT_ERR_Passwd_Should_Have_Min_UpperCase_Character','Error')
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo	
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant VALUES PRT_ERR_Passwd_Should_Have_Min_UpperCase_Character', getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS( SELECT 1 FROM PDBConstant WHERE Id = -50260 AND Message = 'PRT_ERR_UpperCase_Character_Not_Allowed')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant ADD PRT_ERR_UpperCase_Character_Not_Allowed', getdate(), NULL, 'UPDATING')
	
	IF EXISTS( SELECT 1 FROM PDBConstant WHERE Id = -50260)
	BEGIN
		DELETE FROM PDBConstant WHERE Id = -50260
	END	
	IF EXISTS( SELECT 1 FROM PDBConstant WHERE Message = 'PRT_ERR_UpperCase_Character_Not_Allowed')
	BEGIN
		DELETE FROM PDBConstant WHERE Message = 'PRT_ERR_UpperCase_Character_Not_Allowed'
	END	
	INSERT INTO PDBConstant VALUES (-50260,'PRT_ERR_UpperCase_Character_Not_Allowed','Error')
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo	
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant VALUES PRT_ERR_UpperCase_Character_Not_Allowed', getdate(), getdate(), 'ALREADY UPDATED')
END
;

----------------------------------------------------------------------------
-- Changed By						: Silky Malik
-- Reason / Cause (Bug No if Any)	: Changes for support of "OwnerType"
-- Change Description				: Changes for support of "OwnerType"
----------------------------------------------------------------------------
IF NOT EXISTS( SELECT 1 FROM PDBConstant WHERE Id = -50261 AND Message = 'PRT_ERR_Cannot_Delete_Owner_Group')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant ADD PRT_ERR_Cannot_Delete_Owner_Group', getdate(), NULL, 'UPDATING')
	
	IF EXISTS( SELECT 1 FROM PDBConstant WHERE Id = -50261)
	BEGIN
		DELETE FROM PDBConstant WHERE Id = -50261
	END	
	IF EXISTS( SELECT 1 FROM PDBConstant WHERE Message = 'PRT_ERR_Cannot_Delete_Owner_Group')
	BEGIN
		DELETE FROM PDBConstant WHERE Message = 'PRT_ERR_Cannot_Delete_Owner_Group'
	END	
	INSERT INTO PDBConstant VALUES (-50261,'PRT_ERR_Cannot_Delete_Owner_Group','Error')
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo	
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant VALUES PRT_ERR_Cannot_Delete_Owner_Group', getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS( SELECT 1 FROM PDBConstant WHERE Id = -50262 AND Message = 'PRT_ERR_Cannot_Delete_Owner_Role')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant ADD PRT_ERR_Cannot_Delete_Owner_Role', getdate(), NULL, 'UPDATING')
	
	IF EXISTS( SELECT 1 FROM PDBConstant WHERE Id = -50262)
	BEGIN
		DELETE FROM PDBConstant WHERE Id = -50262
	END	
	IF EXISTS( SELECT 1 FROM PDBConstant WHERE Message = 'PRT_ERR_Cannot_Delete_Owner_Role')
	BEGIN
		DELETE FROM PDBConstant WHERE Message = 'PRT_ERR_Cannot_Delete_Owner_Role'
	END	
	INSERT INTO PDBConstant VALUES (-50262,'PRT_ERR_Cannot_Delete_Owner_Role','Error')
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo	
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant VALUES PRT_ERR_Cannot_Delete_Owner_Role', getdate(), getdate(), 'ALREADY UPDATED')
END
;

--------------------------------------------------------------------------------
--Changed By						: Yogesh Verma
--Reason / Cause (Bug No if Any)	: Changes for Password Algorithm.
--Change Description				: PasswordAlgorithm field added in PDBUser
--------------------------------------------------------------------------------
IF NOT EXISTS( 
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
	WHERE TABLE_NAME = 'PDBUSER'
	AND COLUMN_NAME = 'PASSWORDALGORITHM')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int		
	DECLARE @lpwdalgo VARCHAR(255)
	DECLARE @QueryStr NVARCHAR(4000)
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUSER ADD PasswordAlgorithm', getdate(),NULL, 'UPDATING')
	ALTER TABLE pdbuser ADD PasswordAlgorithm VARCHAR(255)
	SELECT @lpwdalgo = PasswordAlgorithm  FROM PDBLicense
	SELECT  @QueryStr = 'UPDATE pdbuser SET PasswordAlgorithm = ' +CHAR(39)+ @lpwdalgo+CHAR(39)
	EXECUTE (@QueryStr)

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUSER ADD PasswordAlgorithm', getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBDATAFIELDSTABLE'
	AND COLUMN_NAME = 'FIELDORDER')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDataFieldsTable add FieldOrder', getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBDataFieldsTable ADD FieldOrder int null

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDataFieldsTable  add FieldOrder', getdate(), getdate(), 'ALREADY UPDATED')
END	
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBFolder'
	AND COLUMN_NAME = 'RevisedBy')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBFolder add RevisedBy', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBFolder ADD RevisedBy int NOT NULL CONSTRAINT df_folder_revised DEFAULT 1

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END	
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBFolder add RevisedBy', getdate(), getdate(), 'ALREADY UPDATED')
END	
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBDocument'
	AND COLUMN_NAME = 'RevisedBy')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDocument add RevisedBy', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBDocument ADD RevisedBy int NOT NULL CONSTRAINT df_doc_revised DEFAULT 1 

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END	
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDocument add RevisedBy', getdate(), getdate(), 'ALREADY UPDATED')
END	
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBDocument'
	AND COLUMN_NAME = 'SignFlag')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDocument add SignFlag', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBDocument ADD SignFlag CHAR(1) NOT NULL DEFAULT 'N'
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END	
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDocument add SignFlag', getdate(), getdate(), 'ALREADY UPDATED')
END	
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBDocument'
	AND COLUMN_NAME = 'OwnerType')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDocument add OwnerType', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBDocument ADD OwnerType CHAR(1) NOT NULL CONSTRAINT df_doc_ownertype DEFAULT 'U' CONSTRAINT ck_doc_ownertype check (OwnerType IN ('U','G','R'))
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END	
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDocument add OwnerType', getdate(), getdate(), 'ALREADY UPDATED')
END	
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBGroup'
	AND COLUMN_NAME = 'OwnerType')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGroup add OwnerType', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBGroup ADD OwnerType CHAR(1) NOT NULL CONSTRAINT df_gp_ownertype DEFAULT 'U' CONSTRAINT ck_gp_ownertype check (OwnerType IN ('U','G','R'))
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END	
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGroup add OwnerType', getdate(), getdate(), 'ALREADY UPDATED')
END	
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBFolder'
	AND COLUMN_NAME = 'OwnerType')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBFolder add OwnerType', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBFolder ADD OwnerType CHAR(1) NOT NULL CONSTRAINT df_folder_ownertype DEFAULT 'U' CONSTRAINT ck_folder_ownertype check (OwnerType IN ('U','G','R'))
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END	
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBFolder add OwnerType', getdate(), getdate(), 'ALREADY UPDATED')
END	
;

IF EXISTS(
	SELECT  1 FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBDocument')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBDocument') AND NAME = 'Owner')
	AND	XTYPE = 'F'
)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	
	DECLARE @StepNo			int
	DECLARE @ConsName		NVARCHAR(255)

	SELECT  @ConsName = name FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBDocument')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBDocument') AND NAME = 'Owner')
	AND	XTYPE = 'F'

	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDocument DROP Referential Constraints to Owner column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	EXECUTE ('ALTER TABLE PDBDocument DROP CONSTRAINT ' + @ConsName)

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDocument DROP Referential Constraints to Owner column', GETDATE(), NULL, 'Already Updated')
END
;

IF EXISTS(
	SELECT  1 FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBGroup')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBGroup') AND NAME = 'Owner')
	AND	XTYPE = 'F'
)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	
	DECLARE @StepNo			int
	DECLARE @ConsName		NVARCHAR(255)

	SELECT  @ConsName = name FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBGroup')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBGroup') AND NAME = 'Owner')
	AND	XTYPE = 'F'

	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGroup DROP Referential Constraints to Owner column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	EXECUTE ('ALTER TABLE PDBGroup DROP CONSTRAINT ' + @ConsName)

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBGroup DROP Referential Constraints to Owner column', GETDATE(), NULL, 'Already Updated')
END
;

IF EXISTS(
	SELECT  1 FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBFolder')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBFolder') AND NAME = 'Owner')
	AND	XTYPE = 'F'
)
BEGIN
	SELECT 1
	SET NOCOUNT ON
	
	DECLARE @StepNo			int
	DECLARE @ConsName		NVARCHAR(255)

	SELECT  @ConsName = name FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('PDBFolder')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('PDBFolder') AND NAME = 'Owner')
	AND	XTYPE = 'F'

	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBFolder DROP Referential Constraints to Owner column', GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY

	EXECUTE ('ALTER TABLE PDBFolder DROP CONSTRAINT ' + @ConsName)

	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	INSERT INTO PDBUpdateStatus values ('Alter Table', 'Altering Table PDBFolder DROP Referential Constraints to Owner column', GETDATE(), NULL, 'Already Updated')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'PDBTransferOwner')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBTransferOwner' , getdate(), NULL, 'UPDATING')
	
	Create table PDBTransferOwner(
		id				int IDENTITY(1,1) CONSTRAINT pk_TransferOwner_id PRIMARY KEY Clustered,
		OldOwnerIndex 	int,
		OldOwnerType	char(1) NOT NULL,
		NewOwnerIndex	int,
		NewOwnerType	char(1) NOT NULL,
		status			varchar(50) NULL,
		msg				varchar(400) NULL,
		flag			char(1) default 'N',
		ActionId		int default 0
	)

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBTransferOwner' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'Usr_0_ScannerConfig')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE Usr_0_ScannerConfig' , getdate(), NULL, 'UPDATING')
	
	CREATE TABLE Usr_0_ScannerConfig(
		DataClassName varchar(255) Primary key,
		ImageType varchar(255) NOT NULL,
		Compression varchar(255) NOT NULL,
		PaperSource varchar(255) NOT NULL,
		DPI int NOT NULL
	) 

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE Usr_0_ScannerConfig' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'usr_0_securefolder')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE usr_0_securefolder' , getdate(), NULL, 'UPDATING')
	
	CREATE TABLE usr_0_securefolder
	(
		FolderId char(50),
		HotFolderId char(50),
		UNIQUE (HotFolderId)
	) 

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE usr_0_securefolder' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

	--added for BOC Upgrade issue
	IF NOT EXISTS(select * from sys.indexes
where object_id = (select object_id from sys.objects where name = 'PDBALARM') and name='IDX_PDBAlarm_Comp')

BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBAlarm Columns (ObjectId, ObjectType,ActionType,AlarmType)' , GETDATE(), NULL, 'Updating Started')
	SELECT @StepNo = @@IDENTITY
	CREATE INDEX IDX_PDBAlarm_Comp ON PDBAlarm (ObjectId, ObjectType,ActionType,AlarmType)
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBAlarm Columns (ObjectId, ObjectType,ActionType,AlarmType)' , GETDATE(), NULL, 'Already Updated')
END
;

IF EXISTS(
	SELECT 1 FROM PDBDocumentVersion) AND EXISTS(SELECT 1 FROM SYSOBJECTS WHERE NAME = 'TempDocVerUpgrade' AND XTYPE = 'U')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('INSERT TABLE', 'INSERT INTO NEW VERSION TABLE' , getdate(), NULL, 'UPDATING')
	
	DECLARE @DDTTableName NVARCHAR(40)
	DECLARE @QueryStr NVARCHAR(4000)
	DECLARE @DataFieldIndex INT
	DECLARE @DocumentIndex  INT
	DECLARE @VersionNumber DECIMAL(7,2)
	DECLARE @LatVersionNumber DECIMAL(7,2)
	DECLARE @VersionSeries int
	DECLARE @VersionExistFlag	char(1)
	DECLARE @ISLatestVersion	char(1)	
	DECLARE @ParentFolderIndex	int
	DECLARE @AnnotationIndex	int
	DECLARE @ACLMoreFlag	char(1)
	DECLARE @AnnotVerIndex	int
	DECLARE @DataDefIndex int
	DECLARE @FieldColumns NVARCHAR(4000)
	DECLARE @NewDocumentIndex int
	DECLARE	@ObjectIndex	int
	DECLARE @PageNumber	int
	DECLARE @TempIndex int
	DECLARE @DDTVerTableName NVARCHAR(40)
	DECLARE docver CURSOR FOR
		SELECT DocumentIndex, VersionNumber
		FROM PDBDocumentVersion
		ORDER BY DocumentIndex, VersionNumber
	OPEN docver
	FETCH NEXT FROM docver INTO @DocumentIndex, @VersionNumber
	WHILE @@FETCH_STATUS = 0
	BEGIN
		BEGIN TRANSACTION TranDocVer
		SELECT	@VersionExistFlag = 'Y'
		SELECT	@VersionSeries = VersionSeries,
				@ISLatestVersion = LatestVersion
		FROM PDBNewDocumentVersion
		WHERE DocumentIndex = @DocumentIndex
		IF @@ROWCOUNT = 0
		BEGIN
			SELECT	@VersionExistFlag = 'N'
			SELECT 	@ISLatestVersion = 'Y'	
		END

		IF @VersionExistFlag = 'N' OR @VersionExistFlag = 'Y' AND NOT EXISTS(
					SELECT 1 FROM PDBNewDocumentVersion
					WHERE VersionSeries = @VersionSeries
					AND VersionNumber = @VersionNumber
				)
		BEGIN
			INSERT INTO PDBDocument(VersionNumber,VersionComment,Name,Owner,
				CreatedDateTime,RevisedDateTime,AccessedDateTime,DataDefinitionIndex,
				Versioning,AccessType,DocumentType,CreatedbyApplication,CreatedbyUser,	
				ImageIndex,VolumeId,NoOfPages,DocumentSize,FTSDocumentIndex,
				ODMADocumentIndex,HistoryEnableFlag,DocumentLock,LockByUser,
				Comment,Author,TextImageIndex,TextVolumeId,FTSFlag,DocStatus,
				ExpiryDateTime,FinalizedFlag,FinalizedDateTime,FinalizedBy,CheckOutstatus,
				CheckOutbyUser,UseFulData,ACL,PhysicalLocation,ACLMoreFlag,AppName,MainGroupId, PullPrintFlag, ThumbNailFlag, LockMessage) 
			SELECT 	B.VersionNumber,B.VersionComment,B.Name,A.Owner,
				B.CreatedDateTime,RevisedDateTime,AccessedDateTime,DataDefinitionIndex,
				Versioning,AccessType,B.DocumentType,CreatedbyApplication,B.CreatedbyUserIndex,	
				B.ImageIndex,B.VolumeIndex,B.NoOfPages,B.DocumentSize,FTSDocumentIndex,
				ODMADocumentIndex,HistoryEnableFlag,'N',NULL,
				Comment,Author,TextImageIndex,TextVolumeId,A.FTSFlag,DocStatus,
				ExpiryDateTime,'N',FinalizedDateTime,0,'N',
				0,UseFulData,NULL,PhysicalLocation,'N',B.AppName,A.MainGroupId, A.PullPrintFlag, ThumbNailFlag, NULL
			FROM PDBDocument A, PDBDocumentVersion B 
			WHERE B.DocumentIndex = @DocumentIndex
			AND	  B.VersionNumber = @VersionNumber	
			AND	  A.DocumentIndex = B.DocumentIndex

			SELECT @NewDocumentIndex = @@IDENTITY

			SELECT	@ParentFolderIndex = ParentFolderIndex
			FROM	PDBDocumentContent
			WHERE	DocumentIndex = @DocumentIndex
			AND		RefereceFlag = 'O'

			IF @VersionExistFlag = 'N'
			BEGIN
				INSERT INTO PDBDocVersionSeries(DocumentIndex) VALUES(@DocumentIndex)
				SELECT @VersionSeries = @@IDENTITY

				SELECT	@LatVersionNumber = VersionNumber
				FROM	PDBDocument
				WHERE	DocumentIndex = @DocumentIndex

				INSERT INTO PDBNewDocumentVersion(DocumentIndex, VersionSeries, VersionNumber, LatestVersion, ParentFolderIndex) VALUES(@DocumentIndex, @VersionSeries, @LatVersionNumber, 'Y', @ParentFolderIndex)
				INSERT INTO PDBNewDocumentVersion(DocumentIndex, VersionSeries, VersionNumber, LatestVersion, ParentFolderIndex) VALUES(@NewDocumentIndex, @VersionSeries, @VersionNumber, 'N', @ParentFolderIndex)
				IF @@ERROR <> 0
				BEGIN
					ROLLBACK TRANSACTION TranDocVer
					CLOSE docver
					DEALLOCATE docver
					RETURN	
				END	
			END
			ELSE
			BEGIN
				INSERT INTO PDBNewDocumentVersion(DocumentIndex, VersionSeries, VersionNumber, LatestVersion, ParentFolderIndex) VALUES(@NewDocumentIndex, @VersionSeries, @VersionNumber, 'N', @ParentFolderIndex)
				IF @@ERROR <> 0
				BEGIN
					ROLLBACK TRANSACTION TranDocVer
					CLOSE docver
					DEALLOCATE docver
					RETURN	
				END	
			END


			DECLARE AnnotCursor CURSOR FAST_FORWARD FOR
				SELECT AnnotationIndex, ACLMoreFlag
				FROM PDBAnnotationVersion
				WHERE DocumentIndex = @DocumentIndex
				AND	  AnnotationVersion = @VersionNumber	
			OPEN AnnotCursor
			FETCH NEXT FROM AnnotCursor INTO @AnnotationIndex, @ACLMoreFlag
			WHILE @@FETCH_STATUS <> -1
			BEGIN
				IF @@FETCH_STATUS <> -2
				BEGIN
					INSERT INTO PDBAnnotation(DocumentIndex, PageNumber,AnnotationName, AnnotationAccessType,
							ACL, Owner,AnnotationBuffer,ACLMoreFlag,AnnotationType,CreationDateTime,
							RevisedDateTime,FinalizedFlag,FinalizedDateTime,FinalizedBy,
							MainGroupId)
					SELECT @NewDocumentIndex, PageNumber,AnnotationName, AnnotationAccessType,
							ACL, Owner, AnnotationBuffer, ACLMoreFlag, AnnotationType, CreationDateTime,
							CreationDateTime, 'N', CreationDateTime, 0,
							0
					FROM PDBAnnotationVersion
					WHERE AnnotationIndex = @AnnotationIndex
					
					SELECT @AnnotVerIndex = @@IDENTITY

					IF @ACLMoreFlag = 'Y'
					BEGIN
						INSERT INTO PDBRights (ObjectIndex1, Flag1, ObjectIndex2, Flag2, Acl)
						SELECT ObjectIndex1, Flag1, @AnnotVerIndex, 'A', Acl
						FROM PDBRights
						WHERE Flag2 = 'V'
						AND ObjectIndex2 = @AnnotationIndex
						IF @@ERROR <> 0
						BEGIN
							ROLLBACK TRANSACTION TranDocVer
							CLOSE AnnotCursor
							DEALLOCATE AnnotCursor
							CLOSE docver
							DEALLOCATE docver
							RETURN	
						END	
					END
					INSERT INTO PDBFTSData(FolderIndex, DocumentIndex, Data, ObjectType, 
							ObjectIndex, PageNumber, DataCoordinate )
					SELECT 	FolderIndex, @NewDocumentIndex, Data, ObjectType, @AnnotVerIndex, PageNumber,DataCoordinate
					FROM PDBFTSDataVersion
					WHERE DocumentIndex = @DocumentIndex
					AND	VersionNumber = @VersionNumber
					AND ObjectIndex = @AnnotationIndex
					AND ObjectType IN (2,8,9)
					IF @@ERROR <> 0
					BEGIN
						ROLLBACK TRANSACTION TranDocVer
						CLOSE AnnotCursor
						DEALLOCATE AnnotCursor
						CLOSE docver
						DEALLOCATE docver
						RETURN	
					END	
				END
				FETCH NEXT FROM AnnotCursor INTO @AnnotationIndex, @ACLMoreFlag
			END
			CLOSE AnnotCursor
			DEALLOCATE AnnotCursor

			/* Create version for Annotation object */
			DECLARE AttachmentCursor CURSOR FOR 
			SELECT ObjectId, PageNumber
			FROM PDBAnnotationObjectVersion
			WHERE  DocumentIndex = @DocumentIndex
			AND	AnnotationObjectVersion	= @VersionNumber


			OPEN AttachmentCursor

			FETCH NEXT FROM AttachmentCursor INTO @ObjectIndex, @PageNumber
			WHILE(@@FETCH_STATUS <> -1)
			BEGIN
				IF (@@FETCH_STATUS <> -2)
				BEGIN
					INSERT INTO PDBAnnotationObject(DocumentIndex, ObjectType, PageNumber, ImageIndex, VolumeIndex,
										Notes, MainGroupId)
					SELECT @NewDocumentIndex, ObjectType, PageNumber, ImageIndex, VolumeIndex, Notes, 0
					FROM PDBAnnotationObjectVersion
					WHERE DocumentIndex = @DocumentIndex
					AND ObjectId = @ObjectIndex
					AND PageNumber = @PageNumber
					AND AnnotationObjectVersion	= @VersionNumber

					SELECT @TempIndex = @@IDENTITY

					INSERT INTO PDBFTSData (FolderIndex, DocumentIndex, Data, ObjectType, ObjectIndex, PageNumber, 
								DataCoordinate)
					SELECT FolderIndex, @NewDocumentIndex, Data, ObjectType, @TempIndex, PageNumber, DataCoordinate
					FROM PDBFtsDataVersion
					WHERE DocumentIndex = @DocumentIndex
					AND ObjectIndex = @ObjectIndex
					AND ObjectType = 3
					AND PageNumber = @PageNumber
					AND VersionNumber = @VersionNumber
					IF @@ERROR <> 0
					BEGIN
						ROLLBACK TRANSACTION TranDocVer
						CLOSE AttachmentCursor
						DEALLOCATE AttachmentCursor
						CLOSE docver
						DEALLOCATE docver
						RETURN	
					END	
				END
				FETCH NEXT FROM AttachmentCursor INTO @ObjectIndex
			END
			CLOSE AttachmentCursor
			DEALLOCATE AttachmentCursor


			INSERT INTO PDBFTSData (FolderIndex, DocumentIndex, Data, ObjectType, ObjectIndex, PageNumber, datacoordinate)
			SELECT FolderIndex, @NewDocumentIndex, Data, ObjectType, @NewDocumentIndex, PageNumber, DataCoordinate
			FROM PDBFtsDataVersion
			WHERE DocumentIndex = @DocumentIndex
			AND VersionNumber = @VersionNumber
			AND ObjectType = 1
			IF @@ERROR <> 0
			BEGIN
				ROLLBACK TRANSACTION TranDocVer
				CLOSE docver
				DEALLOCATE docver
				RETURN	
			END	

			INSERT INTO PDBThumbNail(DocumentIndex, PageNumber, ThumbNailData, CreatedDateTime, 
						AccessedDateTime, RevisedDateTime,ImageIndex,VolumeId)
			SELECT 	@NewDocumentIndex, PageNumber, ThumbNailData, CreatedDateTime, AccessedDateTime, RevisedDateTime,ImageIndex,VolumeId
			FROM PDBThumbNailVersion
			WHERE DocumentIndex = @DocumentIndex
			AND VersionNumber = @VersionNumber
			IF @@ERROR <> 0
			BEGIN
				ROLLBACK TRANSACTION TranDocVer
				CLOSE docver
				DEALLOCATE docver
				RETURN	
			END	

			SELECT @QueryStr = 
				N'INSERT INTO PDBIntGlobalindex(DataFieldIndex,FoldDocIndex,FoldDocFlag,IntValue)
				SELECT DataFieldIndex, @NewDocumentIndex, ''D'', IntValue
				FROM PDBIntGlobalindex 
				WHERE  FoldDocIndex = @DocumentIndex
				AND	FoldDocFlag = ''D'''	
			EXEC SP_EXECUTESQL @QueryStr, N'@NewDocumentIndex int, @DocumentIndex int', @NewDocumentIndex, @DocumentIndex
			IF @@ERROR <> 0
			BEGIN
				ROLLBACK TRANSACTION TranDocVer
				CLOSE docver
				DEALLOCATE docver
				RETURN	
			END	

			SELECT @QueryStr = 
				N'INSERT INTO PDBBoolGlobalindex(DataFieldIndex,FoldDocIndex,FoldDocFlag,BoolValue) 
				SELECT DataFieldIndex,@NewDocumentIndex, ''D'', BoolValue
				FROM PDBBoolGlobalindex 
				WHERE  FoldDocIndex = @DocumentIndex
				AND	FoldDocFlag = ''D'''	
			EXEC SP_EXECUTESQL @QueryStr, N'@NewDocumentIndex int, @DocumentIndex int', @NewDocumentIndex, @DocumentIndex
			IF @@ERROR <> 0
			BEGIN
				ROLLBACK TRANSACTION TranDocVer
				CLOSE docver
				DEALLOCATE docver
				RETURN	
			END	

			SELECT @QueryStr = 
				N'INSERT INTO PDBFloatGlobalindex(DataFieldIndex,FoldDocIndex,FoldDocFlag,FloatValue) 
				SELECT DataFieldIndex, @NewDocumentIndex, ''D'', FloatValue
				FROM PDBFloatGlobalindex 
				WHERE  FoldDocIndex = @DocumentIndex
				AND	FoldDocFlag = ''D'''	
			EXEC SP_EXECUTESQL @QueryStr, N'@NewDocumentIndex int, @DocumentIndex int', @NewDocumentIndex, @DocumentIndex
			IF @@ERROR <> 0
			BEGIN
				ROLLBACK TRANSACTION TranDocVer
				CLOSE docver
				DEALLOCATE docver
				RETURN	
			END	

			SELECT @QueryStr = 
				N'INSERT INTO PDBDateGlobalindex(DataFieldIndex,FoldDocIndex,FoldDocFlag,DateValue) 
				SELECT DataFieldIndex, @NewDocumentIndex, ''D'', DateValue
				FROM PDBDateGlobalindex  
				WHERE  FoldDocIndex = @DocumentIndex
				AND	FoldDocFlag = ''D'''	
			EXEC SP_EXECUTESQL @QueryStr, N'@NewDocumentIndex int, @DocumentIndex int', @NewDocumentIndex, @DocumentIndex
			IF @@ERROR <> 0
			BEGIN
				ROLLBACK TRANSACTION TranDocVer
				CLOSE docver
				DEALLOCATE docver
				RETURN	
			END	

			SELECT @QueryStr = 
				N'INSERT INTO PDBStringGlobalindex(DataFieldIndex,FoldDocIndex,FoldDocFlag,StringValue)
				SELECT DataFieldIndex,   @NewDocumentIndex, ''D'', StringValue
				FROM PDBStringGlobalindex 
				WHERE  FoldDocIndex = @DocumentIndex
				AND	FoldDocFlag = ''D'''	
			EXEC SP_EXECUTESQL @QueryStr, N'@NewDocumentIndex int, @DocumentIndex int', @NewDocumentIndex, @DocumentIndex
			IF @@ERROR <> 0
			BEGIN
				ROLLBACK TRANSACTION TranDocVer
				CLOSE docver
				DEALLOCATE docver
				RETURN	
			END	
				
			SELECT @QueryStr = 
				N'INSERT INTO PDBLongGlobalindex(DataFieldIndex,FoldDocIndex,FoldDocFlag,LongValue)
				SELECT DataFieldIndex,@NewDocumentIndex, ''D'', LongValue
				FROM PDBLongGlobalindex 
				WHERE  FoldDocIndex = @DocumentIndex
				AND	FoldDocFlag = ''D'''	
			EXEC SP_EXECUTESQL @QueryStr, N'@NewDocumentIndex int, @DocumentIndex int', @NewDocumentIndex, @DocumentIndex
			IF @@ERROR <> 0
			BEGIN
				ROLLBACK TRANSACTION TranDocVer
				CLOSE docver
				DEALLOCATE docver
				RETURN	
			END	
			
			SELECT @QueryStr = 
				' INSERT INTO PDBTextGlobalindex(DataFieldIndex,FoldDocIndex,FoldDocFlag,TextValue)
				SELECT DataFieldIndex, @NewDocumentIndex, ''D'', TextValue
				FROM PDBTextGlobalindex
				WHERE  FoldDocIndex = @DocumentIndex
				AND	FoldDocFlag = ''D'''	
			EXEC SP_EXECUTESQL @QueryStr, N'@NewDocumentIndex int, @DocumentIndex int', @NewDocumentIndex, @DocumentIndex
			IF @@ERROR <> 0
			BEGIN
				ROLLBACK TRANSACTION TranDocVer
				CLOSE docver
				DEALLOCATE docver
				RETURN	
			END	

			SELECT @QueryStr = 
				' INSERT INTO PDBKeyword(ObjectIndex,KeywordIndex)
			SELECT @NewDocumentIndex, KeywordIndex
			FROM PDBKeyword 
			WHERE  ObjectIndex = @DocumentIndex'
			EXEC SP_EXECUTESQL @QueryStr, N'@NewDocumentIndex int, @DocumentIndex int', @NewDocumentIndex, @DocumentIndex
				
			INSERT INTO PDBAnnotationData(DocumentIndex,PageNumber,AnnotationData)
			SELECT @NewDocumentIndex,PageNumber,Annotationdata
			FROM PDBAnnotationDataVersion 
			WHERE DocumentIndex = @DocumentIndex
			AND AnnotationVersion = @VersionNumber

			UPDATE PDBCabinet
			SET FTSIndexingFlag = 'Y'

			SELECT	@DataDefIndex = DataDefinitionIndex
			FROM	PDBDocument
			WHERE	DocumentIndex = @DocumentIndex

			IF @DataDefIndex > 0
			BEGIN
				SELECT @FieldColumns = N''
				DECLARE FieldCur CURSOR FAST_FORWARD FOR 
					SELECT DataFieldIndex FROM PDBDataFieldsTable
					WHERE DataDefIndex = @DataDefIndex
				OPEN FieldCur
				FETCH NEXT FROM FieldCur INTO @DataFieldIndex
				WHILE (@@FETCH_STATUS = 0)
				BEGIN
					SELECT @FieldColumns = @FieldColumns + N',Field_' + convert(nvarchar(10), @DataFieldIndex) 
					FETCH NEXT FROM FieldCur INTO @DataFieldIndex
				END
				CLOSE FieldCur
				DEALLOCATE FieldCur

				SELECT @DDTTableName	= N'DDT_' + convert(varchar(10), @DataDefIndex)
				SELECT @DDTVerTableName	= 'DDT_' + convert(varchar(10), @DataDefIndex) + '_Version '
				SELECT @QueryStr = N' INSERT INTO ' + @DDTTableName + N' ( FoldDocIndex, FoldDocFlag, UniqueId ' + 
								@FieldColumns + N' )  SELECT @NewDocumentIndex, @FoldDocFlag, @NewDocumentIndex ' +
								+ @FieldColumns + 
								+ N' FROM ' + @DDTTableName +
									N' WHERE FoldDocIndex = @FoldDocIndex AND FoldDocFlag = @FoldDocFlag'
				EXEC SP_EXECUTESQL @QueryStr, 
							N'@NewDocumentIndex int, @FoldDocFlag char(1), @FoldDocIndex int', 
							@NewDocumentIndex, N'D', @DocumentIndex
				IF @@ERROR <> 0
				BEGIN
					ROLLBACK TRANSACTION TranDocVer
					CLOSE docver
					DEALLOCATE docver
					RETURN	
				END	
			END
			DELETE FROM PDBDocumentVersion
			WHERE DocumentIndex = @DocumentIndex AND VersionNumber = @VersionNumber
		END
		FETCH NEXT FROM docver INTO @DocumentIndex, @VersionNumber
		COMMIT TRANSACTION TranDocVer
	END
	CLOSE docver
	DEALLOCATE docver
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('INSERT TABLE', 'INSERT INTO NEW VERSION TABLE' , getdate(), getdate(), 'ALREADY UPDATED')
END
IF EXISTS(SELECT 1 FROM SYSOBJECTS WHERE NAME = 'TempDocVerUpgrade' AND XTYPE = 'U')
BEGIN
	DROP TABLE TempDocVerUpgrade
END

;
--------------------------------------------------------------------------------
--Changed By						: Vivek Tiwari
--Reason / Cause (Bug No if Any)	: color Theme
--Change Description				: New themecolor coloumn added for storing theme color value
--------------------------------------------------------------------------------

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBCabinet'
	AND COLUMN_NAME = 'themecolor')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBCabinet add RevisedBy', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBCabinet ADD themecolor varchar(120)  DEFAULT '1281dd' WITH VALUES

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END	
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBCabinet add RevisedBy', getdate(), getdate(), 'ALREADY UPDATED')
END	
;

--------------------------------------------------------------------------------
--Changed By						: Pranay Tiwari
--Reason / Cause (Bug No if Any)	: Upgrade from OD7.5
--Change Description				: Update PDBDocument/PDBFolder from PDBObjectDataDef
--------------------------------------------------------------------------------
IF EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'PDBObjectDataDef')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('UPDATE TABLE', 'UPDATING TABLE PDBDocument/PDBFolder from PDBObjectDataDef' , getdate(), NULL, 'UPDATING')

	UPDATE PDBDocument SET DataDefinitionIndex = a.datadefindex, UseFulData = a.UseFulData 
	FROM PDBObjectDataDef a WHERE DocumentIndex = a.ObjectIndex and a.objecttype = 'D' and a.dataclassorderno = 1
	
	UPDATE PDBFolder SET DataDefinitionIndex = a.datadefindex, UseFulData = a.UseFulData 
	FROM PDBObjectDataDef a	WHERE FolderIndex = a.ObjectIndex and a.objecttype = 'F' and a.dataclassorderno = 1
	
	EXEC SP_RENAME 'PDBObjectDataDef', 'PDBObjectDataDef_NotUsed' 
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('UPDATE TABLE', 'UPDATING TABLE PDBDocument/PDBFolder from PDBObjectDataDef' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
------------------------------------------------------------------------------------
IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'PDBMetaData')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBMetaData' , getdate(), NULL, 'UPDATING')
		
	CREATE TABLE PDBMetaData(
	MetaDataName VARCHAR(750) CONSTRAINT   pk_MetaData PRIMARY KEY  Clustered,
    	DataType CHAR(1) NULL,
    	MediaType CHAR(1) NULL,
	ColumnName VARCHAR(30) NULL,
	DisplayFlag CHAR(1) NULL,
	SearchFlag CHAR(1) NULL,
	Unit VARCHAR(10) NULL

	)
	
	INSERT INTO PDBMetaData(MetaDataName,DataType,MediaType,ColumnName,DisplayFlag,SearchFlag)
		VALUES('CODEC','S','B','MetaData2','Y','Y')
	INSERT INTO PDBMetaData(MetaDataName,DataType,MediaType,ColumnName,DisplayFlag,SearchFlag,Unit)
		VALUES('BITRATE','I','B','MetaData32','Y','Y','bits/sec')
	INSERT INTO PDBMetaData(MetaDataName,DataType,MediaType,ColumnName,DisplayFlag,SearchFlag,Unit)
		VALUES('SAMPLERATE','I','U','MetaData33','Y','Y','Hz/sec')
	INSERT INTO PDBMetaData(MetaDataName,DataType,MediaType,ColumnName,DisplayFlag,SearchFlag,Unit)
		VALUES('FRAMERATE','I','V','MetaData34','Y','Y','frames/sec')
	INSERT INTO PDBMetaData(MetaDataName,DataType,MediaType,ColumnName,DisplayFlag,SearchFlag)
		VALUES('AUDIOCODEC','S','V','MetaData7','N','N')
	INSERT INTO PDBMetaData(MetaDataName,DataType,MediaType,ColumnName,DisplayFlag,SearchFlag,Unit)
		VALUES('DURATION','I','B','MetaData35','Y','Y','ms')
	INSERT INTO PDBMetaData(MetaDataName,DataType,MediaType,ColumnName,DisplayFlag,SearchFlag)
		VALUES('ARTIST','S','U','MetaData9','N','N')
	INSERT INTO PDBMetaData(MetaDataName,DataType,MediaType,ColumnName,DisplayFlag,SearchFlag)
		VALUES('GENRE','S','U','MetaData10','N','N')
	INSERT INTO PDBMetaData(MetaDataName,DataType,MediaType,ColumnName,DisplayFlag,SearchFlag)
		VALUES('TITLE','S','B','MetaData11','Y','Y')
	INSERT INTO PDBMetaData(MetaDataName,DataType,MediaType,ColumnName,DisplayFlag,SearchFlag,Unit)
		VALUES('HEIGHT','I','V','MetaData36','Y','Y','mm')
	INSERT INTO PDBMetaData(MetaDataName,DataType,MediaType,ColumnName,DisplayFlag,SearchFlag,Unit)
		VALUES('WIDTH','I','V','MetaData37','Y','Y','mm')
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBMetaData' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'PDBMetaDataDetail')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBMetaDataDetail' , getdate(), NULL, 'UPDATING')
		
	CREATE TABLE PDBMetaDataDetail
	(
	DocumentIndex			INT	CONSTRAINT FK_PDBMetaDataDetailDocId References PDBDocument(DocumentIndex),
	MetaData1		        NVARCHAR(1000) NULL,
	MetaData2		        NVARCHAR(1000) NULL,
	MetaData3		        NVARCHAR(1000) NULL,
	MetaData4		        NVARCHAR(1000) NULL,
	MetaData5		        NVARCHAR(1000) NULL,
	MetaData6		        NVARCHAR(1000) NULL,
	MetaData7		        NVARCHAR(1000) NULL,
	MetaData8		        NVARCHAR(1000) NULL,
	MetaData9		        NVARCHAR(1000) NULL,
	MetaData10		        NVARCHAR(1000) NULL,
	MetaData11		        NVARCHAR(1000) NULL,
	MetaData12		        NVARCHAR(1000) NULL,
	MetaData13		        NVARCHAR(1000) NULL,
	MetaData14		        NVARCHAR(1000) NULL,
	MetaData15		        NVARCHAR(1000) NULL,
	MetaData16		        NVARCHAR(1000) NULL,
	MetaData17		        NVARCHAR(1000) NULL,
	MetaData18		        NVARCHAR(1000) NULL,
	MetaData19		        NVARCHAR(1000) NULL,
	MetaData20		        NVARCHAR(1000) NULL,
	MetaData21		        NVARCHAR(1000) NULL,
	MetaData22		        NVARCHAR(1000) NULL,
	MetaData23		        NVARCHAR(1000) NULL,
	MetaData24		        NVARCHAR(1000) NULL,
	MetaData25		        NVARCHAR(1000) NULL,
	MetaData26		        NVARCHAR(1000) NULL,
	MetaData27		        NVARCHAR(1000) NULL,
	MetaData28		        NVARCHAR(1000) NULL,
	MetaData29		        NVARCHAR(1000) NULL,
	MetaData30		        NVARCHAR(1000) NULL,
	MetaData31		        INT NULL,
	MetaData32		        INT NULL,
	MetaData33		        INT NULL,
	MetaData34		        INT NULL,
	MetaData35		        INT NULL,
	MetaData36		        INT NULL,
	MetaData37		        INT NULL,
	MetaData38		        INT NULL,
	MetaData39		        INT NULL,
	MetaData40		        INT NULL,
	MetaData41		        DATETIME NULL,
	MetaData42		        DATETIME NULL,
	MetaData43		        DATETIME NULL,
	MetaData44		        DATETIME NULL,
	MetaData45		        DATETIME NULL,
	MetaData46		        DATETIME NULL,
	MetaData47		        DATETIME NULL,
	MetaData48		        DATETIME NULL,
	MetaData49		        DATETIME NULL,
	MetaData50		        DATETIME NULL,
	CONSTRAINT PK_PDBMetaDataDetailDocId PRIMARY KEY (DocumentIndex)
	)

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBMetaDataDetail' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
-----------------------------------------------------------------------------------------------
-- Changed By				: Ankit Jain
-- Reason / Cause (Bug No if Any)	: Change for Preferred folder for ODMobile
-- Change Description			: New column added to PDBUser
-----------------------------------------------------------------------------------------------
IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUser'
	AND COLUMN_NAME = 'PreferredFolderIndex')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUser add PreferredFolderIndex', getdate(), NULL, 'UPDATING')
		
	ALTER TABLE PDBUser ADD PreferredFolderIndex INT NOT NULL DEFAULT 0
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUser add PreferredFolderIndex', getdate(), getdate(), 'ALREADY UPDATED')
END
;


IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBReminder'
	AND COLUMN_NAME = 'RepeatFlag')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'Altering TABLE PDBReminder add RepeatFlag' , getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBReminder ADD RepeatFlag CHAR(1) CONSTRAINT df_reminder_repeatflag DEFAULT 'N'
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBReminder add RepeatFlag' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
-----------------------------
IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBDocument'
	AND COLUMN_NAME = 'ESTimeStamp')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'Altering TABLE PDBDocument add ESTimeStamp' , getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBDocument ADD ESTimeStamp VARCHAR(50) NULL DEFAULT 'N' WITH VALUES
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBDocument add ESTimeStamp' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBDocument'
	AND COLUMN_NAME = 'ESIndexTime')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'Altering TABLE PDBDocument add ESIndexTime' , getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBDocument ADD ESIndexTime VARCHAR(250) NULL
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBDocument add ESIndexTime' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBDocument'
	AND COLUMN_NAME = 'ESFlag')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'Altering TABLE PDBDocument add ESFlag' , getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBDocument ADD ESFlag CHAR(1)  NULL DEFAULT 'N' WITH VALUES
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBDocument add ESFlag' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
----------------------------
IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBFolder'
	AND COLUMN_NAME = 'ESTimeStamp')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'Altering TABLE PDBFolder add ESTimeStamp' , getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBFolder ADD ESTimeStamp VARCHAR(50) NULL DEFAULT 'N' WITH VALUES
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBFolder add ESTimeStamp' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBFolder'
	AND COLUMN_NAME = 'ESIndexTime')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'Altering TABLE PDBFolder add ESIndexTime' , getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBFolder ADD ESIndexTime VARCHAR(250) NULL
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBFolder add ESIndexTime' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBFolder'
	AND COLUMN_NAME = 'ESFlag')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'Altering TABLE PDBFolder add ESFlag' , getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBFolder ADD ESFlag CHAR(1) NULL DEFAULT 'N' WITH VALUES
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBFolder add ESFlag' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBCabinet'
	AND COLUMN_NAME = 'EnableDataSecurity')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'Altering TABLE PDBCabinet add EnableDataSecurity' , getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBCabinet ADD EnableDataSecurity CHAR(1) NOT NULL CONSTRAINT ck_cab_datasecure CHECK (EnableDataSecurity IN ('Y','N')) CONSTRAINT df_cab_datasecure DEFAULT 'N' WITH VALUES
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBCabinet add EnableDataSecurity' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBCabinet'
	AND COLUMN_NAME = 'OwnerSecureRight')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'Altering TABLE PDBCabinet add OwnerSecureRight' , getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBCabinet ADD OwnerSecureRight CHAR(1) NOT NULL CONSTRAINT ck_cab_ownersecure CHECK (OwnerSecureRight IN ('Y','N')) CONSTRAINT df_cab_ownersecure DEFAULT 'N' WITH VALUES
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBCabinet add OwnerSecureRight' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBCabinet'
	AND COLUMN_NAME = 'AdminSecureRight')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'Altering TABLE PDBCabinet add AdminSecureRight' , getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBCabinet ADD AdminSecureRight CHAR(1) NOT NULL CONSTRAINT ck_cab_adminsecure CHECK (AdminSecureRight IN ('Y','N')) CONSTRAINT df_cab_adminsecure DEFAULT 'N' WITH VALUES
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBCabinet add AdminSecureRight' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBCabinet'
	AND COLUMN_NAME = 'GenerateAccessReport')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'Altering TABLE PDBCabinet add GenerateAccessReport' , getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBCabinet ADD GenerateAccessReport CHAR(1) NOT NULL CONSTRAINT ck_cab_genreport CHECK (GenerateAccessReport IN ('Y','N')) CONSTRAINT df_cab_genreport DEFAULT 'N'
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBCabinet add GenerateAccessReport' , getdate(), getdate(), 'ALREADY UPDATED')
END
;


IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBGlobalIndex'
	AND COLUMN_NAME = 'FieldSecureFlag')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'Altering TABLE PDBGlobalIndex add FieldSecureFlag' , getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBGlobalIndex ADD FieldSecureFlag CHAR(1) NOT NULL CONSTRAINT ck_gi_fieldsecureflag  CHECK (FieldSecureFlag IN ('Y','N')) CONSTRAINT df_gi_fieldsecureflag DEFAULT 'N' WITH VALUES
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'AlterING TABLE PDBGlobalIndex add FieldSecureFlag' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBGTypeGlobalIndex'
	AND COLUMN_NAME = 'FieldSecureFlag')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'Altering VIEW PDBGTypeGlobalIndex add FieldSecureFlag' , getdate(), NULL, 'UPDATING')

	EXECUTE ('ALTER VIEW PDBGTypeGlobalIndex AS SELECT DataFieldIndex, DataFieldName, DataFieldType,DataFieldLength, GlobalOrDataFlag ,MainGroupId,Pickable, RightsCheckEnabled, FieldSecureFlag FROM PDBGlobalIndex WHERE GlobalOrDataFlag = ''G''')	
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'Altering VIEW PDBGTypeGlobalIndex add FieldSecureFlag' , getdate(), getdate(), 'ALREADY UPDATED')
END
;


IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBDTypeGlobalIndex'
	AND COLUMN_NAME = 'FieldSecureFlag')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'Altering VIEW PDBDTypeGlobalIndex add FieldSecureFlag' , getdate(), NULL, 'UPDATING')

	EXECUTE ('ALTER VIEW PDBDTypeGlobalIndex AS SELECT DataFieldIndex, DataFieldName, DataFieldType,DataFieldLength, GlobalOrDataFlag , MainGroupId,Pickable, RightsCheckEnabled, FieldSecureFlag FROM PDBGlobalIndex WHERE GlobalOrDataFlag = ''D''')	
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'Altering VIEW PDBDTypeGlobalIndex add FieldSecureFlag' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBXTypeGlobalIndex'
	AND COLUMN_NAME = 'FieldSecureFlag')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'Altering VIEW PDBXTypeGlobalIndex add FieldSecureFlag' , getdate(), NULL, 'UPDATING')

	EXECUTE ('ALTER VIEW PDBXTypeGlobalIndex AS SELECT DataFieldIndex, DataFieldName, DataFieldType, DataFieldLength, GlobalOrDataFlag ,MainGroupId,Pickable, RightsCheckEnabled, FieldSecureFlag FROM PDBGlobalIndex WHERE DataFieldType = ''X''')		
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'Altering VIEW PDBXTypeGlobalIndex add FieldSecureFlag' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'PDBMTypeGlobalIndex')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING VIEW PDBMTypeGlobalIndex' , getdate(), NULL, 'UPDATING')
		
	EXECUTE ('CREATE VIEW PDBMTypeGlobalIndex AS 
	SELECT DataFieldIndex, DataFieldName, DataFieldType,DataFieldLength, GlobalOrDataFlag, MainGroupId, Pickable,RightsCheckEnabled, FieldSecureFlag 
	FROM PDBGlobalIndex WHERE GlobalOrDataFlag = ''M''')

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING VIEW PDBMTypeGlobalIndex' , getdate(), getdate(), 'ALREADY UPDATED')
END

;


IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBMTypeGlobalIndex'
	AND COLUMN_NAME = 'FieldSecureFlag')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'Altering VIEW PDBMTypeGlobalIndex add FieldSecureFlag' , getdate(), NULL, 'UPDATING')

	EXECUTE (' ALTER VIEW PDBMTypeGlobalIndex AS 
	SELECT DataFieldIndex, DataFieldName, DataFieldType,DataFieldLength, GlobalOrDataFlag, MainGroupId, Pickable,RightsCheckEnabled, FieldSecureFlag 
	FROM PDBGlobalIndex WHERE GlobalOrDataFlag = ''M''')
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'Altering VIEW PDBMTypeGlobalIndex add FieldSecureFlag' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'PDBKmsMaster')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBKmsMaster' , getdate(), NULL, 'UPDATING')
		
	CREATE TABLE PDBKmsMaster(
		KmsServiceProvider nvarchar(50) NOT NULL CONSTRAINT  pk_KmsMaster PRIMARY KEY  Clustered,
		KmsServiceProviderDesc nvarchar(255) NOT NULL,
		KmsServiceTable nvarchar(255) NULL,
		KmsServiceClass nvarchar(1020) NOT NULL
	)

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBKmsMaster' , getdate(), getdate(), 'ALREADY UPDATED')
END

;

IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'PDBKmsServiceProvider')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBKmsServiceProvider' , getdate(), NULL, 'UPDATING')
		
	CREATE TABLE PDBKmsServiceProvider(
		PKM_KmsServiceProvider nvarchar(50) NOT NULL CONSTRAINT  pk_KmsServiceProvider PRIMARY KEY  Clustered,
		Active CHAR(1) NOT NULL CONSTRAINT ck_kms_serviceprovider  CHECK (Active IN ('Y','N')) CONSTRAINT df_kms_serviceprovider DEFAULT 'N',
		CONSTRAINT fk_KmsServiceProvider FOREIGN KEY (PKM_KmsServiceProvider) REFERENCES PDBKmsMaster(KmsServiceProvider)
	)

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBKmsServiceProvider' , getdate(), getdate(), 'ALREADY UPDATED')
END

;
SELECT 0
IF NOT EXISTS(SELECT 1 FROM PDBKmsMaster WHERE KmsServiceProvider = 'AMAZON-AWSKMS')
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBKmsMaster for KmsServiceProvider = AMAZON-AWSKMS' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBKmsMaster(KmsServiceProvider, KmsServiceProviderDesc, KmsServiceTable, KmsServiceClass) VALUES('AMAZON-AWSKMS', 'Amazon Web Service(AWS)','PDBAmazonKMS', 'com.newgen.omni.jts.kms.impl.KeyManagementServiceAmzonImpl')

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBKmsMaster for KmsServiceProvider = AMAZON-AWSKMS' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'PDBAmazonKMS')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBAmazonKMS' , getdate(), NULL, 'UPDATING')
		
	CREATE TABLE PDBAmazonKMS(
		AmazonKMSIndex	int IDENTITY(1,1) NOT NULL CONSTRAINT pk_PDBAmazonKMS PRIMARY KEY,
		AccessKey nvarchar(255) NOT NULL,
		SecretKey VARBINARY(255) NOT NULL,
		EndPointUrl nvarchar(255) NOT NULL,
		MasterKeyId nvarchar(255) NULL,
		DataEncrBitLength	nvarchar(10) NOT NULL DEFAULT '128',
		Active CHAR(1) NOT NULL CONSTRAINT ck_awskms_Active  CHECK (Active IN ('Y','N')) CONSTRAINT df_awskms_Active DEFAULT 'N'
	)

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBAmazonKMS' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'PDBAmazonKMSData')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBAmazonKMSData' , getdate(), NULL, 'UPDATING')
		
	CREATE TABLE PDBAmazonKMSData(
		AmazonKMSIndex	int IDENTITY(1,1) NOT NULL CONSTRAINT pk_PDBAmazonKMSData PRIMARY KEY,
		KMSAmazonMasterIndex int NOT NULL REFERENCES PDBAmazonKMS(AmazonKMSIndex),
		EncryptedDataKeyId nvarchar(1020)  NOT NULL CONSTRAINT uk_PDBAmazonKMSData UNIQUE,
		Active CHAR(1) NOT NULL CONSTRAINT ck_awskmsdata_Active  CHECK (Active IN ('Y','N')) CONSTRAINT df_awskmsdata_Active DEFAULT 'N'
	)

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBAmazonKMSData' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'PDBAccessLog')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBAccessLog' , getdate(), NULL, 'UPDATING')
		
	CREATE TABLE PDBAccessLog(
		AccessLogIndex bigint IDENTITY(-9223372036854775808,1) NOT NULL CONSTRAINT pk_AcessLog_AccessLogIndex PRIMARY KEY CLUSTERED,
		RandomNumber int NOT NULL,
		UserIndex int NOT NULL,
		UserType char(1) NOT NULL,
		AccessDateTimeIn datetime NOT NULL,
		AccessDateTimeOut datetime NOT NULL,
		ArchiveFlag char(1) NOT NULL DEFAULT ('N'),
		CONSTRAINT   pk_RandomNumber_AccessLog UNIQUE(RandomNumber,UserIndex,UserType)
	)

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBAccessLog' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'PDBAccessLogHistory')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBAccessLogHistory' , getdate(), NULL, 'UPDATING')
		
	CREATE TABLE PDBAccessLogHistory(
		AccessLogIndex bigint IDENTITY(-9223372036854775808,1) NOT NULL CONSTRAINT pk_AcessLog_AccessLoghHst PRIMARY KEY CLUSTERED,
		RandomNumber [int] NOT NULL,
		UserIndex int NOT NULL,
		UserType char(1) NOT NULL,
		AccessDateTimeIn datetime NOT NULL,
		AccessDateTimeOut datetime NOT NULL,
		HistoryEntryDateTime datetime NOT NULL
	)

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBAccessLogHistory' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'PDBAccessLogSummary')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBAccessLogSummary' , getdate(), NULL, 'UPDATING')
		
	CREATE TABLE PDBAccessLogSummary(
		AccessLogIndex bigint IDENTITY(-9223372036854775808,1) NOT NULL CONSTRAINT pk_AcessLogSmry_AccessLogIndex PRIMARY KEY CLUSTERED,
		UserIndex int NOT NULL,
		UserType char(1) NOT NULL,
		TotalLogins int NOT NULL DEFAULT 0,
		AccessDate date NOT NULL,
		TotalSessionTime BIGINT NOT NULL DEFAULT 0,
		UserName nvarchar(64) NULL,
		CONSTRAINT   uk_AccessLogSummary UNIQUE(AccessDate, UserIndex, UserType)
	)

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBAccessLogSummary' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

BEGIN
	SELECT 0
	SET NOCOUNT ON
	DECLARE @StepNo			int
	CREATE TABLE #indfol(index_name varchar(256), indexdesc varchar(256), indkey varchar(2126))
	INSERT INTO #indfol exec sp_helpindex 'PDBAccessLog'

	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'AccessDateTimeIn')
	BEGIN
		
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBAccessLog Columns (AccessDateTimeIn)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_PDBAccessLog_AccessDateTimeIn ON PDBAccessLog(AccessDateTimeIn) INCLUDE(AccessLogIndex, RandomNumber, UserIndex, AccessDateTimeOut)

		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		
		SET NOCOUNT ON
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBAccessLog  Columns (AccessDateTimeIn)' , GETDATE(), NULL, 'Already Updated')
	END
	DROP TABLE #indfol
END
;

BEGIN
	SELECT 0
	SET NOCOUNT ON
	DECLARE @StepNo			int
	CREATE TABLE #indfol(index_name varchar(256), indexdesc varchar(256), indkey varchar(2126))
	INSERT INTO #indfol exec sp_helpindex 'PDBAccessLogSummary'

	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'UserIndex')
	BEGIN
		
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBAccessLogSummary Columns (UserIndex)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_AcessLogSmry_UserIndex ON PDBAccessLogSummary(UserIndex)
		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		
		SET NOCOUNT ON
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBAccessLogSummary  Columns (UserIndex)' , GETDATE(), NULL, 'Already Updated')
	END
	DROP TABLE #indfol
END
;

BEGIN
	SELECT 0
	SET NOCOUNT ON
	DECLARE @StepNo			int
	CREATE TABLE #indfol(index_name varchar(256), indexdesc varchar(256), indkey varchar(2126))
	INSERT INTO #indfol exec sp_helpindex 'PDBAccessLogSummary'

	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'UserName')
	BEGIN
		
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBAccessLogSummary Columns (UserName)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_AcessLogSmry_UserName ON PDBAccessLogSummary(UserName)
		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		
		SET NOCOUNT ON
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBAccessLogSummary  Columns (UserName)' , GETDATE(), NULL, 'Already Updated')
	END
	DROP TABLE #indfol
END

;
SELECT 0
IF NOT EXISTS(SELECT 1 FROM PDBUser WHERE USERNAME = 'SUPERVISOR' AND PrivilegeControlList = '1111111111111111')
begin
declare @stepNo int
insert into PDBUpdateStatus values ('UPDATE', 'UPDATING PrivilegeControlList FOR SUPERVISOR USER' , getdate(), NULL, 'UPDATING')

UPDATE PDBUSER SET PrivilegeControlList = '1111111111111111' WHERE USERNAME = 'SUPERVISOR'

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('UPDATE', 'UPDATING PrivilegeControlList FOR SUPERVISOR USER' , getdate(), getdate(), 'ALREADY UPDATED')
END

;
SELECT 0
IF NOT EXISTS(SELECT 1 FROM PDBUser WHERE USERNAME = 'SUPERVISOR2' AND PrivilegeControlList = '1111111111111111')
begin
declare @stepNo int
insert into PDBUpdateStatus values ('UPDATE', 'UPDATING PrivilegeControlList FOR SUPERVISOR2 USER' , getdate(), NULL, 'UPDATING')

UPDATE PDBUSER SET PrivilegeControlList = '1111111111111111' WHERE USERNAME = 'SUPERVISOR2'

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('UPDATE', 'UPDATING PrivilegeControlList FOR SUPERVISOR2 USER' , getdate(), getdate(), 'ALREADY UPDATED')
END

;
SELECT 0
IF NOT EXISTS(SELECT 1 FROM PDBGROUP WHERE GROUPNAME = 'SUPERVISORS' AND PrivilegeControlList = '1111111111111111')
begin
declare @stepNo int
insert into PDBUpdateStatus values ('UPDATE', 'UPDATING PrivilegeControlList FOR SUPERVISORS GROUP' , getdate(), NULL, 'UPDATING')

UPDATE PDBGROUP SET PrivilegeControlList = '1111111111111111' WHERE GROUPNAME = 'SUPERVISORS'

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('UPDATE', 'UPDATING PrivilegeControlList FOR SUPERVISORS GROUP' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
-------------------------------------------------------------------------------------------------------------
-- Changed By				: Jitendra kumar
-- Reason / Cause (Bug No if Any)	: Changes for Support NGOGetUserPreferences and NGOSetUserPreferences API
-- Change Description			: Suppot for new API
------------------------------------------------------------------------------------------------------------
IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'PDBUSERPREFERNCES')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBUSERPREFERNCES' , getdate(), NULL, 'UPDATING')
	
	Create Table PDBUSERPREFERNCES  (
                                UserIndex INT NOT NULL,
                                PreferenceXML  ntext,
                                LastModifiedDate  DateTime,
                                CONSTRAINT UK_USERPREFERNCES_UserID UNIQUE (UserIndex))		
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBUSERPREFERNCES' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
-------------------------------------------------------------------------------------------------------------------------
--Changed By			: Jitendra Kumar
--Reason / Cause (Bug No if Any): Changes for compaction new table created PDBCOMPACTIONPROCESS and TEMPCOMPACTIONPROCESS
--Change Description		: Change for compaction 
--------------------------------------------------------------------------------------------------------------------------

IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'PDBCOMPACTIONPROCESS')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBCOMPACTIONPROCESS' , getdate(), NULL, 'UPDATING')
	
	CREATE   TABLE  PDBCOMPACTIONPROCESS  ( 
						VOLBLOCKID  INT ,  
						VOLBLOCKPATH  VARCHAR(100) NOT NULL ,  
						SPACEFRAGMENTED  INT  NULL,  
						CURROFFSET  INT  NULL,  
						COMPACTED  varchar(50))	
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBCOMPACTIONPROCESS' , getdate(), getdate(), 'ALREADY UPDATED')
END

;
IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'TempCOMPACTIONPROCESS')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE TempCOMPACTIONPROCESS' , getdate(), NULL, 'UPDATING')
	
	CREATE   TABLE  TempCOMPACTIONPROCESS  ( 
							VOLBLOCKID  INT ,  
							VOLBLOCKPATH  VARCHAR(100) NOT NULL ,  
							SPACEFRAGMENTED  INT NULL,  
							CURROFFSET  INT  NULL , 
							Remainingdocsize INT NULL, 
							COMPACTED  varchar(50))	
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE TempCOMPACTIONPROCESS' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
------------------------------------------------------------------------------------------------------------------------
--Changed By			: Jitendra Kumar
--Reason / Cause (Bug No if Any):  Bug 13334 
--Change Description		: Changes for Merging LDAP APIS IN OmniDOcs
--------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'PDBLDAPXML')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBLDAPXML' , getdate(), NULL, 'UPDATING')
	
	CREATE TABLE PDBLDAPXML (
					DomainName nvarchar(150), 
					XmlName nvarchar(16), 
					XmlContent ntext )	
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBLDAPXML' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
------------------------------------------------------------------------------------------------------------------------
--Changed By			: Sanjeev Kumar
--Reason / Cause (Bug No if Any):  Bug 21332
--Change Description		: While upgrade the cabinet from OmniDocs 7 to OmniDocs 10.1 patch 3 the DomainName column is not created in PDBLDAPXML table in MSSQL data base
--------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBLDAPXML'
	AND COLUMN_NAME = 'DomainName')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'Alter TABLE PDBLDAPXML Add Column DomainName ' , getdate(), NULL, 'UPDATING')

	DECLARE @PDBLDAPXMLTableName_OLD varchar(50)
	SET @PDBLDAPXMLTableName_OLD='PDBLDAPXML_Old_' +(CONVERT(VARCHAR(8),GETDATE(),112))

	EXEC SP_RENAME 'PDBLDAPXML', @PDBLDAPXMLTableName_OLD

	CREATE TABLE PDBLDAPXML (
					DomainName nvarchar(150), 
					XmlName nvarchar(16), 
					XmlContent ntext )
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'Alter TABLE PDBLDAPXML Add Column DomainName' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'PDBDOMAINUSER')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBDOMAINUSER' , getdate(), NULL, 'UPDATING')
	
	CREATE TABLE PDBDOMAINUSER ( 
					UserName nvarchar(64), 
					DomainName nvarchar(64), 
					UserIndex int, 
					DistinguishedName nvarchar(64))	
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBDOMAINUSER' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

------------------------------------------------------------------------------------------------------------------------
--Changed By			: Jitendra Kumar
--Reason / Cause (Bug No if Any): Changes for new error code PRT_ERR_Volblock_Docid_locked
--Change Description		: If volblockk is locked then docuemnt should not delete 
-------------------------------------------------------------------------------------------------------------------------

IF NOT EXISTS( SELECT 1 FROM PDBConstant WHERE Id = -50263 AND Message = 'PRT_ERR_Volblock_Docid_locked')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant ADD PRT_ERR_Volblock_Docid_locked', getdate(), NULL, 'UPDATING')
	
	
	INSERT INTO PDBConstant VALUES (-50263,'PRT_ERR_Volblock_Docid_locked','Error')
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo	
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant VALUES PRT_ERR_Volblock_Docid_locked', getdate(), getdate(), 'ALREADY UPDATED')
END
;

------------------------------------------------------------------------------------------------------------------------
--Changed By			: Jitendra Kumar
--Reason / Cause (Bug No if Any): Changes for new error code PRT_ERR_No_Secured_Rights_GlobalIndex
--Change Description		: If no secured rights on Globalindex
-------------------------------------------------------------------------------------------------------------------------

IF NOT EXISTS( SELECT 1 FROM PDBConstant WHERE Id = -50264 AND Message = 'PRT_ERR_No_Secured_Rights_GlobalIndex')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant ADD PRT_ERR_No_Secured_Rights_GlobalIndex', getdate(), NULL, 'UPDATING')
	
	
	INSERT INTO PDBConstant VALUES (-50264,'PRT_ERR_No_Secured_Rights_GlobalIndex','Error')
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo	
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant VALUES PRT_ERR_No_Secured_Rights_GlobalIndex', getdate(), getdate(), 'ALREADY UPDATED')
END

;
------------------------------------------------------------------------------------------------------------------------
--Changed By					: Shubham Mittal
--Reason / Cause (Bug No if Any): Bug 12457 Update Data class fields validation and proper error message from API
--Change Description			: Added new error constants
-------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS( SELECT 1 FROM PDBConstant WHERE Id = -50266 AND Message = 'PRT_ERR_DataType_Conversion_Not_Allowed')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant ADD PRT_ERR_DataType_Conversion_Not_Allowed', getdate(), NULL, 'UPDATING')
	
	
	INSERT INTO PDBConstant VALUES (-50266,'PRT_ERR_DataType_Conversion_Not_Allowed','Error')
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo	
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant VALUES PRT_ERR_DataType_Conversion_Not_Allowed', getdate(), getdate(), 'ALREADY UPDATED')
END

;
IF NOT EXISTS( SELECT 1 FROM PDBConstant WHERE Id = -50267 AND Message = 'PRT_ERR_Data_Exists_With_Null_Field_Values')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant ADD PRT_ERR_Data_Exists_With_Null_Field_Values', getdate(), NULL, 'UPDATING')
	
	
	INSERT INTO PDBConstant VALUES (-50267,'PRT_ERR_Data_Exists_With_Null_Field_Values','Error')
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo	
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant VALUES PRT_ERR_Data_Exists_With_Null_Field_Values', getdate(), getdate(), 'ALREADY UPDATED')
END

;
IF NOT EXISTS( SELECT 1 FROM PDBConstant WHERE Id = -50268 AND Message = 'PRT_ERR_Data_Is_Not_Unique')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant ADD PRT_ERR_Data_Is_Not_Unique', getdate(), NULL, 'UPDATING')
	
	
	INSERT INTO PDBConstant VALUES (-50268,'PRT_ERR_Data_Is_Not_Unique','Error')
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo	
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant VALUES PRT_ERR_Data_Is_Not_Unique', getdate(), getdate(), 'ALREADY UPDATED')
END
;
--end

------------------------------------------------------------------------------------------------------------------------
--Changed By					: Shivam Gupta
--Reason / Cause (Bug No if Any): Bug 14655 - Provide provision to add U type DataClass and use fields of U type dataclass as additional properties for User.
--Change Description			: Added new error constants
-------------------------------------------------------------------------------------------------------------------------

IF NOT EXISTS( SELECT 1 FROM PDBConstant WHERE Id = -50284 AND Message = 'PRT_ERR_DDI_Associated_With_User')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant ADD PRT_ERR_DDI_Associated_With_User', getdate(), NULL, 'UPDATING')
	
	
	INSERT INTO PDBConstant VALUES (-50284,'PRT_ERR_DDI_Associated_With_User','Error')
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo	
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant VALUES PRT_ERR_DDI_Associated_With_User', getdate(), getdate(), 'ALREADY UPDATED')
END

;
--ends
------------------------------------------------------------------------------------------------------------------------
--Changed By					  : 		    Jitendra Kumar
--Reason / Cause (Bug No if Any)  :  			if UserSecurity table does not have foreign key on UserIndex column
--Change Description			  :      		Foreign Key constraint added on UserIndex
-------------------------------------------------------------------------------------------------------------------------

IF Not EXISTS(
	SELECT  1 FROM SYSOBJECTS A, SYSconstraints b
	where	a.id = b.constid
	AND	b.id = OBJECT_ID('UserSecurity')
	AND 	colid = (SELECT ColId FROM SYSCOLUMNS WHERE ID = OBJECT_ID('UserSecurity') AND NAME = 'UserIndex')
	AND	XTYPE = 'F'
)
BEGIN
	
	select 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('ALTER TABLE', 'ALTER TABLE UserSecurity ADD CONSTRAINT fk_us_uind' , getdate(), NULL, 'UPDATING')
	 
	ALTER TABLE UserSecurity ADD CONSTRAINT fk_us_uind FOREIGN KEY (UserIndex)
		REFERENCES PDBUser (UserIndex)
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
    
END
ELSE
BEGIN
	Select 0
	insert into PDBUpdateStatus values ('ALTER TABLE', 'ALTER TABLE UserSecurity ADD CONSTRAINT fk_us_uind' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
------------------------------------------------------------------------------------------------------------------------
--Changed By					  : 		    Jitendra Kumar
--Reason / Cause (Bug No if Any)  :  			For Auto Logout S-Type user 
--Change Description			  :      		Default behaviour of Auto Logout S-Type user
-------------------------------------------------------------------------------------------------------------------------

IF  EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBLICENSE'
	AND COLUMN_NAME = 'STYPELOGOUT')
BEGIN

	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Update Table', 'Updating Table PDBLicense for STYPELOGOUT = Y', getdate(), NULL, 'UPDATING')

	update pdblicense set STYPELOGOUT ='Y'
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Update Table', 'Updating Table PDBLicense for STYPELOGOUT = Y', getdate(), getdate(), 'ALREADY UPDATED')
END;




IF  EXISTS( SELECT 1 FROM PDBAuditAction WHERE ActionId = 207 AND Category = 'F' AND EnableLog = 'Y')
BEGIN

	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Update Table', 'Updating Table PDBAuditAction for ActionId = 207', getdate(), NULL, 'UPDATING')

	update PDBAuditAction set EnableLog = 'N' where ActionId = 207 AND Category = 'F'

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Update Table', 'Updating Table PDBAuditAction for ActionId = 207', getdate(), getdate(), 'ALREADY UPDATED')
END;

IF  EXISTS( SELECT 1 FROM PDBAuditAction WHERE ActionId = 221 AND Category = 'F' AND EnableLog = 'Y')
BEGIN

	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Update Table', 'Updating Table PDBAuditAction for ActionId = 221', getdate(), NULL, 'UPDATING')

	update PDBAuditAction set EnableLog = 'N' where ActionId = 221 AND Category = 'F'

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Update Table', 'Updating Table PDBAuditAction for ActionId = 221', getdate(), getdate(), 'ALREADY UPDATED')
END;

-------------------------------------------------------------------------------------------
-- Changed By				: Shubham Mittal
-- Reason / Cause (Bug No if Any)	: BugId 12311
-- Change Description			: Different Action Ids to be configured for different login failure reasons (added from 671 to 691)
-------------------------------------------------------------------------------------------

SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 671)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 671' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment,SysFlag) VALUES (671, 'C', 'User is marked for deletion', 'Y' , NULL,'Y')
select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 671' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 672)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 672' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment,SysFlag) VALUES (672, 'C', 'Evaluation Version Expired', 'Y' , NULL,'Y')
select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 672' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 673)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 673' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment,SysFlag) VALUES (673, 'C', 'Login attempts has exceeded', 'Y' , NULL,'Y')
select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 673' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 674)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 674' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment,SysFlag) VALUES (674, 'C', 'User does not exist', 'Y' , NULL,'Y')
select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 674' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 675)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 675' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment,SysFlag) VALUES (675, 'C', 'User has expired', 'Y' , NULL,'Y')
select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 675' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 676)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 676' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment,SysFlag) VALUES (676, 'C', 'User login period has expired', 'Y' , NULL,'Y')
select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 676' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 677)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 677' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment,SysFlag) VALUES (677, 'C', 'Invalid password', 'Y' , NULL,'Y')
select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 677' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 678)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 678' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment,SysFlag) VALUES (678, 'C', 'User is not alive', 'Y' , NULL,'Y')
select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 678' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 679)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 679' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment,SysFlag) VALUES (679, 'C', 'User does not have rights', 'Y' , NULL,'Y')
select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 679' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 680)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 680' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment,SysFlag) VALUES (680, 'C', 'Cabinet is locked', 'Y' , NULL,'Y')
select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 680' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 681)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 681' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment,SysFlag) VALUES (681, 'C', 'Maximum login limit of internal portal users exceeded', 'Y' , NULL,'Y')
select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 681' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 682)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 682' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment,SysFlag) VALUES (682, 'C', 'Maximum login limit of external portal users exceeded', 'Y' , NULL,'Y')
select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 682' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 683)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 683' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment,SysFlag) VALUES (683, 'C', 'Maximum login limit of service users exceeded', 'Y' , NULL,'Y')
select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 683' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 684)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 684' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment,SysFlag) VALUES (684, 'C', 'Maximum login limit of normal users exceeded', 'Y' , NULL,'Y')
select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 684' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 685)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 685' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment,SysFlag) VALUES (685, 'C', 'Password has expired', 'Y' , NULL,'Y')
select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 685' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 686)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 686' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment,SysFlag) VALUES (686, 'C', 'User Account Locked', 'Y' , NULL,'Y')
select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 686' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 687)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 687' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment,SysFlag) VALUES (687, 'C', 'User Account UnLocked', 'Y' , NULL,'Y')
select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 687' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 688)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 688' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment,SysFlag) VALUES (688, 'C', 'Change Password Attempt Failed', 'Y' , NULL,'Y')
select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 688' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 689)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 689' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment,SysFlag) VALUES (689, 'C', 'User is enabled', 'Y' , NULL,'Y')
select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 689' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 690)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 690' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment,SysFlag) VALUES (690, 'C', 'User is disabled', 'Y' , NULL,'Y')
select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 690' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
--Bug id 12311 Added action id 691 for connection entries deleted by wrapper
SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 691)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 691' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment,SysFlag) VALUES (691, 'C', 'User Loggedout by Wrapper', 'Y' , NULL,'Y')
select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 691' , getdate(), getdate(), 'ALREADY UPDATED')
END ;--end


/*------------------------------------------------------------------------------------------------     Changed By						: Jitendra Kumar
Reason / Cause (Bug No if Any)	 : Bug 12461 New error coded added for * search and blank search
Change Description				 : Added new error codes
--------------------------------------------------------------------------------------------------	*/

IF NOT EXISTS( SELECT 1 FROM PDBConstant WHERE Id = -50269 AND Message = 'PRT_ERR_Blank_Search_Restricted')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant ADD PRT_ERR_Blank_Search_Restricted', getdate(), NULL, 'UPDATING')
	
	
	INSERT INTO PDBConstant VALUES (-50269,'PRT_ERR_Blank_Search_Restricted','Error')
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo	
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant VALUES PRT_ERR_Blank_Search_Restricted', getdate(), getdate(), 'ALREADY UPDATED')
END
;
--end
/*------------------------------------------------------------------------------------------------        Changed By					: Chandan
Reason / Cause (Bug No if Any)	: Bug 13413 - Show password policy link on admin while adding user
Change Description				: Added new error codes
--------------------------------------------------------------------------------------------------	*/

IF NOT EXISTS( SELECT 1 FROM PDBConstant WHERE Id = -50270 AND Message = 'PRT_ERR_Password_Must_Less_Than_MaxAllowed')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant ADD PRT_ERR_Password_Must_Less_Than_MaxAllowed', getdate(), NULL, 'UPDATING')
	
	
	INSERT INTO PDBConstant VALUES (-50270,'PRT_ERR_Password_Must_Less_Than_MaxAllowed','Error')
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo	
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant VALUES PRT_ERR_Password_Must_Less_Than_MaxAllowed', getdate(), getdate(), 'ALREADY UPDATED')
END
--end
;
-----------------------------------------------------------------------------------------------
-- Changed By				: Chandan
-- Reason / Cause (Bug No if Any)	:Bug 13413 - Show password policy link on admin while adding user
-- Change Description			: Adding new column MaxPasswordLen
-----------------------------------------------------------------------------------------------

IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUserConfig'
	AND COLUMN_NAME = 'MaxPasswordLen')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUserConfig add MaxPasswordLen', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBUserConfig ADD MaxPasswordLen smallint NOT NULL CONSTRAINT df_Usrconfig_MaxPasswordLen DEFAULT 30
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUserConfig  add MaxPasswordLen', getdate(), getdate(), 'ALREADY UPDATED')
	
END;

IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'PDBApplicationLicenseDetails')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBApplicationLicenseDetails' , getdate(), NULL, 'UPDATING')
		
	CREATE TABLE PDBApplicationLicenseDetails(
		ApplicationIndex   			 				int
		IDENTITY(1,1) CONSTRAINT   pk_appindex      PRIMARY KEY  Clustered,
		ApplicationName    			 				NVARCHAR(100) ,
		EncrApplicationName			 				NVARCHAR(255) ,
		DefaultApplication  						CHAR(1),
		ClientName 									NVARCHAR(64) NULL,
		MaxNoOfUTypeUsers  							int,
		EncrMaxNoOfUTypeUsers 						NVARCHAR(64) ,
		MaxNoOfFixedUsers  							int,
		EncrFixedUsers     							NVARCHAR(64) ,
		ConcurrentNoOfUTypeUsers 					int,
		EncrConcurrentNoOfUTypeUsers				NVARCHAR(64) ,
		MaxNoOfSTypeUsers 							int,
		EncrMaxNoOfSTypeUsers 						NVARCHAR(64) ,
		ConcurrentNoOfSTypeUsers					int,
		EncrConcurNoOfSTypeUsers 					NVARCHAR(64) ,
		MaxNoOfExternalPortalUsers					int,
		EncrMaxNoOfExternalPortalUsers 				NVARCHAR(64) ,
		ConncurrentNoOfExtPortalUsers				int,
		EncrConncurNoOfExtPortalUsers 				NVARCHAR(64) ,
		MaxNoOfInternalPortalUsers 					int,
		EncrMaxNoOfInternalPortalUsers 				NVARCHAR(64) ,
		ConncurrentNoOfIntPortalUsers				int,
		EncrConncurNoOfIntPortalUsers 				NVARCHAR(64) ,
		DefaultSTypeUsers   						int,
		EncrDefaultSTypeUsers 						NVARCHAR(64),
		EnvironmentType                             NVARCHAR(100) ,
		EncrEnvironmentType 						NVARCHAR(255)
	)

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBApplicationLicenseDetails' , getdate(), getdate(), 'ALREADY UPDATED')
END
;	

IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'PDBUserApplicationMapping')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBUserApplicationMapping' , getdate(), NULL, 'UPDATING')
		
	CREATE TABLE PDBUserApplicationMapping(
		MappingIndex								int
		IDENTITY(1,1) CONSTRAINT   pk_userAppMapindex      PRIMARY KEY  Clustered,
		ApplicationIndex 							int,
		UserIndex									int,
	    CONSTRAINT   uk_userAppMapping	UNIQUE (ApplicationIndex,UserIndex)
	)

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBUserApplicationMapping' , getdate(), getdate(), 'ALREADY UPDATED')
END
;	
IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'PDBAdminLogTable')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBAdminLogTable' , getdate(), NULL, 'UPDATING')
		
	CREATE TABLE PDBAdminLogTable(
		AuditTrailIndex		int IDENTITY(1,1) CONSTRAINT   pk_admin_audittrailid      PRIMARY KEY  Clustered,
		ActionId                int NOT NULL,
		Category                CHAR(1) NULL,
		ProductId				int NULL,
		ProductName				nvarchar(255) NULL,
		ActiveObjectId          int NULL,
		ActiveObjectType        CHAR(1) NULL,
		LicenseType        		CHAR(1) NULL,
		SubsdiaryObjectId       int NULL,
		SubsdiaryObjectType     CHAR(1) NULL,
		Comment                 NVARCHAR(255) NULL,
		DATETIME                DATETIME NOT NULL,
		USERINDEX               int NOT NULL,
		UserName		nvarchar(64) NULL,
		ActiveObjectName	nvarchar(255) NULL,
		SubsdiaryObjectName	nvarchar(255) NULL,
		OldValue		nvarchar(255) NULL,
		NewValue		nvarchar(255) NULL,
		ApplicationInfo nvarchar(20) NULL,
		Status          CHAR(1) NOT NULL  CONSTRAINT DF_ADMIN_AUDIT_STATUSFLAG DEFAULT 'S'
	)

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
	
	
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBAdminLogTable' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
BEGIN
	SELECT 0
	SET NOCOUNT ON
	DECLARE @StepNo			int
	CREATE TABLE #indfol(index_name varchar(256), indexdesc varchar(256), indkey varchar(2126))
	INSERT INTO #indfol exec sp_helpindex 'PDBAdminLogTable'

	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'DateTime')
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBAdminLogTable Column (DateTime)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_PDBAdminLogTable_DateTime ON PDBAdminLogTable (DateTime)

		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		
		SET NOCOUNT ON
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBAdminLogTable Column (DateTime)' , GETDATE(), GETDATE(), 'Already Updated')
	END
	DROP TABLE #indfol
END
;
IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'PDBConnectionAuditTrail')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBConnectionAuditTrail' , getdate(), NULL, 'UPDATING')
		
	CREATE TABLE PDBConnectionAuditTrail(
		AuditTrailIndex		bigint IDENTITY(1,1) CONSTRAINT   pk_audittrailid      PRIMARY KEY  Clustered,
		ActionId                int NOT NULL,
		Category                CHAR(1) NULL,
		ProductId				int NULL,
		ProductName				nvarchar(255) NULL,
		ActiveObjectId          int NULL,
		ActiveObjectType        CHAR(1) NULL,
		LicenseType        		CHAR(1) NULL,
		SubsdiaryObjectId       int NULL,
		SubsdiaryObjectType     CHAR(1) NULL,
		Comment                 NVARCHAR(255) NULL,
		DATETIME                DATETIME NOT NULL,
		USERINDEX               int NOT NULL,
		UserName		nvarchar(64) NULL,
		ActiveObjectName	nvarchar(255) NULL,
		SubsdiaryObjectName	nvarchar(255) NULL,
		OldValue		nvarchar(255) NULL,
		NewValue		nvarchar(255) NULL,
		ApplicationInfo varchar(20) NULL,
		Status          CHAR(1) NOT NULL  CONSTRAINT DF_Conn_AUDIT_STATUSFLAG DEFAULT 'S',
		UserAppLoginCount int NULL
	)

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
	
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBConnectionAuditTrail' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

BEGIN
	SELECT 0
	SET NOCOUNT ON
	DECLARE @StepNo			int
	CREATE TABLE #indfol(index_name varchar(256), indexdesc varchar(256), indkey varchar(2126))
	INSERT INTO #indfol exec sp_helpindex 'PDBConnectionAuditTrail'

	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'DateTime')
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBConnectionAuditTrail Column (DateTime)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_PDBConAuditTrail_DateTime ON PDBConnectionAuditTrail (DateTime)

		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		
		SET NOCOUNT ON
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBConnectionAuditTrail Column (DateTime)' , GETDATE(), GETDATE(), 'Already Updated')
	END
	DROP TABLE #indfol
END
;
IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'PDBLicenseLogTable')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBLicenseLogTable' , getdate(), NULL, 'UPDATING')
		
	CREATE TABLE PDBLicenseLogTable(

	AuditTrailIndex		int IDENTITY(1,1) CONSTRAINT   pk_lic_audittrailid      PRIMARY KEY  Clustered,
	ActionId                int NOT NULL,
	Category                CHAR(1) NULL,
	ProductId				int NULL,
	ProductName				nvarchar(255) NULL,
	ActiveObjectId          int NULL,
	ActiveObjectType        CHAR(1) NULL,
	LicenseType        		CHAR(1) NULL,
	SubsdiaryObjectId       int NULL,
	SubsdiaryObjectType     CHAR(1) NULL,
	Comment                 NVARCHAR(255) NULL,
	DATETIME                DATETIME NOT NULL,
	USERINDEX               int NOT NULL,
	UserName		nvarchar(64) NULL,
	ActiveObjectName	nvarchar(255) NULL,
	SubsdiaryObjectName	nvarchar(255) NULL,
	OldValue		nvarchar(255) NULL,
	NewValue		nvarchar(255) NULL,
	ApplicationInfo nvarchar(20) NULL,
	Status          CHAR(1) NOT NULL  CONSTRAINT DF_lic_AUDIT_STATUSFLAG DEFAULT 'S'
)

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
	
	
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBLicenseLogTable' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

BEGIN
	SELECT 0
	SET NOCOUNT ON
	DECLARE @StepNo			int
	CREATE TABLE #indfol(index_name varchar(256), indexdesc varchar(256), indkey varchar(2126))
	INSERT INTO #indfol exec sp_helpindex 'PDBLicenseLogTable'

	IF NOT EXISTS(SELECT indkey FROM #indfol WHERE indkey = 'DateTime')
	BEGIN
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBLicenseLogTable Column (DateTime)' , GETDATE(), NULL, 'Updating Started')
		SELECT @StepNo = @@IDENTITY

		CREATE NONCLUSTERED INDEX IDX_PDBLICLOGTABLE_DATETIME ON PDBLicenseLogTable (DateTime)

		UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	END
	ELSE
	BEGIN
		
		SET NOCOUNT ON
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBLicenseLogTable Column (DateTime)' , GETDATE(), GETDATE(), 'Already Updated')
	END
	DROP TABLE #indfol
END
;
IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBCabinet'
	AND COLUMN_NAME = 'AllowCrossApplicationLogin')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBCabinet add AllowCrossApplicationLogin', getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBCabinet ADD AllowCrossApplicationLogin CHAR(1) CONSTRAINT df_cab_AllowCrossAppLogin DEFAULT 'Y' NOT NULL
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBCabinet  add AllowCrossApplicationLogin', getdate(), getdate(), 'ALREADY UPDATED')
	
END;
IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBConnection'
	AND COLUMN_NAME = 'ProductName')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBConnection add ProductName', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBConnection ADD ProductName NVARCHAR(255)
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBConnection  add ProductName', getdate(), getdate(), 'ALREADY UPDATED')
END;



IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBNEWAUDITTRAIL_TABLE'
	AND COLUMN_NAME = 'Status')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBNEWAUDITTRAIL_TABLE add Status', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBNEWAUDITTRAIL_TABLE ADD Status CHAR(1) NULL
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBNEWAUDITTRAIL_TABLE  add Status', getdate(), getdate(), 'ALREADY UPDATED')
END;

IF NOT EXISTS( SELECT 1 FROM PDBConstant WHERE Id = 50026 AND Message = 'PRT_WARN_Not_All_Applications_Associated_To_User')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant ADD PRT_WARN_Not_All_Applications_Associated_To_User', getdate(), NULL, 'UPDATING')
	
	
	INSERT INTO PDBConstant VALUES (50026,'PRT_WARN_Not_All_Applications_Associated_To_User','Warning')
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo	
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant VALUES PRT_WARN_Not_All_Applications_Associated_To_User', getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS( SELECT 1 FROM PDBConstant WHERE Id = 50027 AND Message = 'PRT_WARN_Not_All_Users_Dissociated')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant ADD PRT_WARN_Not_All_Users_Dissociated', getdate(), NULL, 'UPDATING')
	
	
	INSERT INTO PDBConstant VALUES (50027,'PRT_WARN_Not_All_Users_Dissociated','Warning')
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo	
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant VALUES PRT_WARN_Not_All_Users_Dissociated', getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS( SELECT 1 FROM PDBConstant WHERE Id = -50271 AND Message = 'PRT_ERR_User_Already_Associated')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant ADD PRT_ERR_User_Already_Associated', getdate(), NULL, 'UPDATING')
	
	
	INSERT INTO PDBConstant VALUES (-50271,'PRT_ERR_User_Already_Associated','Error')
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo	
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant VALUES PRT_ERR_User_Already_Associated', getdate(), getdate(), 'ALREADY UPDATED')
END
;
IF NOT EXISTS( SELECT 1 FROM PDBConstant WHERE Id = -50272 AND Message = 'PRT_ERR_Application_LicLimit_UType_Exceeded')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant ADD PRT_ERR_Application_LicLimit_UType_Exceeded', getdate(), NULL, 'UPDATING')
	
	
	INSERT INTO PDBConstant VALUES (-50272,'PRT_ERR_Application_LicLimit_UType_Exceeded','Error')
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo	
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant VALUES PRT_ERR_Application_LicLimit_UType_Exceeded', getdate(), getdate(), 'ALREADY UPDATED')
END
;
IF NOT EXISTS( SELECT 1 FROM PDBConstant WHERE Id = -50273 AND Message = 'PRT_ERR_Application_LicLimit_FType_Exceeded')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant ADD PRT_ERR_Application_LicLimit_FType_Exceeded', getdate(), NULL, 'UPDATING')
	
	
	INSERT INTO PDBConstant VALUES (-50273,'PRT_ERR_Application_LicLimit_FType_Exceeded','Error')
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo	
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant VALUES PRT_ERR_Application_LicLimit_FType_Exceeded', getdate(), getdate(), 'ALREADY UPDATED')
END
;
IF NOT EXISTS( SELECT 1 FROM PDBConstant WHERE Id = -50274 AND Message = 'PRT_ERR_Application_LicLimit_SType_Exceeded')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant ADD PRT_ERR_Application_LicLimit_SType_Exceeded', getdate(), NULL, 'UPDATING')
	
	
	INSERT INTO PDBConstant VALUES (-50274,'PRT_ERR_Application_LicLimit_SType_Exceeded','Error')
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo	
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant VALUES PRT_ERR_Application_LicLimit_SType_Exceeded', getdate(), getdate(), 'ALREADY UPDATED')
END
;
IF NOT EXISTS( SELECT 1 FROM PDBConstant WHERE Id = -50275 AND Message = 'PRT_ERR_Application_LicLimit_IType_Exceeded')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant ADD PRT_ERR_Application_LicLimit_IType_Exceeded', getdate(), NULL, 'UPDATING')
	
	
	INSERT INTO PDBConstant VALUES (-50275,'PRT_ERR_Application_LicLimit_IType_Exceeded','Error')
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo	
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant VALUES PRT_ERR_Application_LicLimit_IType_Exceeded', getdate(), getdate(), 'ALREADY UPDATED')
END
;
IF NOT EXISTS( SELECT 1 FROM PDBConstant WHERE Id = -50276 AND Message = 'PRT_ERR_Application_LicLimit_EType_Exceeded')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant ADD PRT_ERR_Application_LicLimit_EType_Exceeded', getdate(), NULL, 'UPDATING')
	
	
	INSERT INTO PDBConstant VALUES (-50276,'PRT_ERR_Application_LicLimit_EType_Exceeded','Error')
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo	
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant VALUES PRT_ERR_Application_LicLimit_EType_Exceeded', getdate(), getdate(), 'ALREADY UPDATED')
END
;
IF NOT EXISTS( SELECT 1 FROM PDBConstant WHERE Id = -50277 AND Message = 'PRT_ERR_Application_NotRegistered_WithCabinet')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant ADD PRT_ERR_Application_NotRegistered_WithCabinet', getdate(), NULL, 'UPDATING')
	
	
	INSERT INTO PDBConstant VALUES (-50277,'PRT_ERR_Application_NotRegistered_WithCabinet','Error')
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo	
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant VALUES PRT_ERR_Application_NotRegistered_WithCabinet', getdate(), getdate(), 'ALREADY UPDATED')
END
;
IF NOT EXISTS( SELECT 1 FROM PDBConstant WHERE Id = -50278 AND Message = 'PRT_ERR_User_App_Association_Mismatch')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant ADD PRT_ERR_User_App_Association_Mismatch', getdate(), NULL, 'UPDATING')
	
	
	INSERT INTO PDBConstant VALUES (-50278,'PRT_ERR_User_App_Association_Mismatch','Error')
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo	
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant VALUES PRT_ERR_User_App_Association_Mismatch', getdate(), getdate(), 'ALREADY UPDATED')
END
;
IF NOT EXISTS( SELECT 1 FROM PDBConstant WHERE Id = -50279 AND Message = 'PRT_ERR_Default_Application_Not_Set')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant ADD PRT_ERR_Default_Application_Not_Set', getdate(), NULL, 'UPDATING')
	
	
	INSERT INTO PDBConstant VALUES (-50279,'PRT_ERR_Default_Application_Not_Set','Error')
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo	
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant VALUES PRT_ERR_Default_Application_Not_Set', getdate(), getdate(), 'ALREADY UPDATED')
END
;
IF NOT EXISTS( SELECT 1 FROM PDBConstant WHERE Id = -50280 AND Message = 'PRT_ERR_User_Not_Associated_WithAny_Application')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant ADD PRT_ERR_User_Not_Associated_WithAny_Application', getdate(), NULL, 'UPDATING')
	
	
	INSERT INTO PDBConstant VALUES (-50280,'PRT_ERR_User_Not_Associated_WithAny_Application','Error')
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo	
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant VALUES PRT_ERR_User_Not_Associated_WithAny_Application', getdate(), getdate(), 'ALREADY UPDATED')
END
;
IF NOT EXISTS( SELECT 1 FROM PDBConstant WHERE Id = -50281 AND Message = 'PRT_ERR_Application_LicLimit_Exceeded_GroupMembers')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant ADD PRT_ERR_Application_LicLimit_Exceeded_GroupMembers', getdate(), NULL, 'UPDATING')
	
	
	INSERT INTO PDBConstant VALUES (-50281,'PRT_ERR_Application_LicLimit_Exceeded_GroupMembers','Error')
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo	
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant VALUES PRT_ERR_Application_LicLimit_Exceeded_GroupMembers', getdate(), getdate(), 'ALREADY UPDATED')
END
;
IF NOT EXISTS( SELECT 1 FROM PDBConstant WHERE Id = -50282 AND Message = 'PRT_ERR_No_Users_Got_Associated')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant ADD PRT_ERR_No_Users_Got_Associated', getdate(), NULL, 'UPDATING')
	
	
	INSERT INTO PDBConstant VALUES (-50282,'PRT_ERR_No_Users_Got_Associated','Error')
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo	
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant VALUES PRT_ERR_No_Users_Got_Associated', getdate(), getdate(), 'ALREADY UPDATED')
END
;

SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 692)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 692' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment,SysFlag) VALUES (692, 'C', 'User associated To Application', 'Y',  NULL,'Y')
select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 692' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 693)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 693' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment,SysFlag) VALUES (693, 'C', 'User association To Application Failed ', 'Y',  NULL,'Y')
select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 693' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 694)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 694' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment,SysFlag) VALUES (694, 'C', 'Object association To Application Failed due to License Limit Exceeded', 'Y',  NULL,'Y')
select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 694' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 695)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 695' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment,SysFlag) VALUES (695, 'C', 'User Dissociated From Application', 'Y',  NULL,'Y')
select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 695' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 696)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 696' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment,SysFlag) VALUES (696, 'C', 'User Login from different application than associated with', 'Y',  NULL,'Y')
select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 696' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 697)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 697' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment,SysFlag) VALUES (697, 'C', 'Concurrency limit exceeded for an application for a cabinet', 'Y',  NULL,'Y')
select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 697' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 698)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 698' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment,SysFlag) VALUES (698, 'C', 'User license type change success', 'Y',  NULL,'Y')
select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 698' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 699)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 699' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment,SysFlag) VALUES (699, 'C', 'User license type change failed', 'Y',  NULL,'Y')
select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 699' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 700)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 700' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment,SysFlag) VALUES (700, 'C', 'Default Application changed for cabinet', 'Y',  NULL,'Y')
select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 700' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 701)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 701' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment,SysFlag) VALUES (701, 'C', 'Error in Default Application change for cabinet', 'Y',  NULL,'Y')
select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 701' , getdate(), getdate(), 'ALREADY UPDATED')
END
;


-----------------------------------------------------------------------------------------------
-- Changed By						: Tarang
-- Reason / Cause (Bug No if Any)	: Created for storing data for new AddIns EJB
-- Change Description				: Adding new table CIFFORM_TABLE
-----------------------------------------------------------------------------------------------
SELECT 0
IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'CIFFORM_TABLE')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE CIFFORM_TABLE' , getdate(), NULL, 'UPDATING')
	
	CREATE TABLE CIFFORM_TABLE 
	(
		OBJECTTYPE int NOT NULL , 
		OBJECTID int NOT NULL , 
		FORMID int IDENTITY(1,1)PRIMARY KEY CLUSTERED , 
		FORMNAME varchar(50) NOT 	NULL , 
		FORMBUFFER ntext, 
		ISENCRYPTED CHAR 
	)
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE CIFFORM_TABLE' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUserConfig'
	AND COLUMN_NAME = 'PWDExpiryTimeByAdmin')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUserConfig add PWDExpiryTimeByAdmin', getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBUSERCONFIG ADD PWDExpiryTimeByAdmin smallint default 1 not null

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUserConfig  add PWDExpiryTimeByAdmin', getdate(), getdate(), 'ALREADY UPDATED')
END	
;

IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBUserConfig'
	AND COLUMN_NAME = 'PWDExpiryTimeByUser')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUserConfig add PWDExpiryTimeByUser', getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBUSERCONFIG ADD PWDExpiryTimeByUser smallint default 30  not null

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBUserConfig  add PWDExpiryTimeByUser', getdate(), getdate(), 'ALREADY UPDATED')
END
;

SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 702)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 702' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment,SysFlag) VALUES (702, 'C', 'Password Policy Changed Success', 'Y',  NULL,'Y')
select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 702' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

SELECT 0
IF NOT EXISTS(SELECT ActionId FROM PDBAuditAction WHERE ActionId = 703)
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBAuditAction for ActionId = 703' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBAuditAction (ActionId,Category,ActionName,EnableLog,Comment,SysFlag) VALUES (703, 'C', 'Password Policy Changed Failure', 'Y',  NULL,'Y')
select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBAuditAction for ActionId = 703' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
-----------------------------------------------------------------------------------------------
-- Changed By						: Shubham Mittal
-- Reason / Cause (Bug No if Any)	: Created for storing product subproduct mapping for application wise licensing
-- Change Description				: Adding new table PDBProductModuleMapping
-----------------------------------------------------------------------------------------------
SELECT 0
IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'PDBPRODUCTMODULEMAPPING')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBPRODUCTMODULEMAPPING' , getdate(), NULL, 'UPDATING')
	
	CREATE TABLE PDBProductModuleMapping
	(
	SubProductName varchar(255) not null,
	ProductName varchar(255) not null,
	CONSTRAINT   pk_productModuleMapping PRIMARY KEY (SubProductName, ProductName)
	)

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBPRODUCTMODULEMAPPING' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

SELECT 0
IF NOT EXISTS(SELECT SubProductName FROM PDBPRODUCTMODULEMAPPING WHERE SubProductName='OFServices')
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBPRODUCTMODULEMAPPING for SubProductName =OFServices' , getdate(), NULL, 'UPDATING')

INSERT INTO pdbproductmodulemapping VALUES ('OFServices','OmniFlow')
select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBPRODUCTMODULEMAPPING for SubProductName =OFServices' , getdate(), getdate(), 'ALREADY UPDATED')
END
;


SELECT 0
IF NOT EXISTS(SELECT SubProductName FROM PDBPRODUCTMODULEMAPPING WHERE SubProductName='OmniScan')
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBPRODUCTMODULEMAPPING for SubProductName =OmniScan' , getdate(), NULL, 'UPDATING')

INSERT INTO pdbproductmodulemapping VALUES ('OmniScan','OmniScan')
select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBPRODUCTMODULEMAPPING for SubProductName =OmniScan' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

SELECT 0
IF NOT EXISTS(SELECT SubProductName FROM PDBPRODUCTMODULEMAPPING WHERE SubProductName='Process Manager')
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBPRODUCTMODULEMAPPING for SubProductName =Process Manager' , getdate(), NULL, 'UPDATING')

INSERT INTO pdbproductmodulemapping VALUES ('Process Manager','OmniFlow')
select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBPRODUCTMODULEMAPPING for SubProductName =Process Manager' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

SELECT 0
IF NOT EXISTS(SELECT SubProductName FROM PDBPRODUCTMODULEMAPPING WHERE SubProductName='OAP')
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBPRODUCTMODULEMAPPING for SubProductName =OAP' , getdate(), NULL, 'UPDATING')

INSERT INTO pdbproductmodulemapping VALUES ('OAP','iBPS')
select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBPRODUCTMODULEMAPPING for SubProductName =OAP' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

SELECT 0
IF NOT EXISTS(SELECT SubProductName FROM PDBPRODUCTMODULEMAPPING WHERE SubProductName='Webdesktop')
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBPRODUCTMODULEMAPPING for SubProductName =Webdesktop' , getdate(), NULL, 'UPDATING')
INSERT INTO pdbproductmodulemapping VALUES ('Webdesktop','OmniFlow')
select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBPRODUCTMODULEMAPPING for SubProductName =Webdesktop' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
IF NOT EXISTS( SELECT 1 FROM PDBConstant WHERE Id = -50283 AND Message = 'PRT_ERR_Module_Not_Mapped_With_Product')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant ADD PRT_ERR_Module_Not_Mapped_With_Product', getdate(), NULL, 'UPDATING')
	
	
	INSERT INTO PDBConstant VALUES (-50283,'PRT_ERR_Module_Not_Mapped_With_Product','Error')
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo	
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant VALUES PRT_ERR_Module_Not_Mapped_With_Product', getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT SubProductName FROM PDBPRODUCTMODULEMAPPING WHERE SubProductName='ODSOAPWS')
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBPRODUCTMODULEMAPPING for SubProductName =ODSOAPWS' , getdate(), NULL, 'UPDATING')
INSERT INTO pdbproductmodulemapping VALUES ('ODSOAPWS','OmniDocs')
select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBPRODUCTMODULEMAPPING for SubProductName =ODSOAPWS' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

SELECT 0
IF NOT EXISTS(SELECT SubProductName FROM PDBPRODUCTMODULEMAPPING WHERE SubProductName='ODRESTWS')
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBPRODUCTMODULEMAPPING for SubProductName =ODRESTWS' , getdate(), NULL, 'UPDATING')
INSERT INTO pdbproductmodulemapping VALUES ('ODRESTWS','OmniDocs')
select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBPRODUCTMODULEMAPPING for SubProductName =ODRESTWS' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT SubProductName FROM PDBPRODUCTMODULEMAPPING WHERE SubProductName='OmniNewgenMSAddIns')
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBPRODUCTMODULEMAPPING for SubProductName =OmniNewgenMSAddIns' , getdate(), NULL, 'UPDATING')
INSERT INTO pdbproductmodulemapping VALUES ('OmniNewgenMSAddIns','OmniDocs')
select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBPRODUCTMODULEMAPPING for SubProductName =OmniNewgenMSAddIns' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT SubProductName FROM PDBPRODUCTMODULEMAPPING WHERE SubProductName='OmniNewgenRMSAddIns')
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBPRODUCTMODULEMAPPING for SubProductName =OmniNewgenRMSAddIns' , getdate(), NULL, 'UPDATING')
INSERT INTO pdbproductmodulemapping VALUES ('OmniNewgenRMSAddIns','OmniDocs')
select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBPRODUCTMODULEMAPPING for SubProductName =OmniNewgenRMSAddIns' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT SubProductName FROM PDBPRODUCTMODULEMAPPING WHERE SubProductName='OmniNewgenTEM')
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBPRODUCTMODULEMAPPING for SubProductName =OmniNewgenTEM' , getdate(), NULL, 'UPDATING')
INSERT INTO pdbproductmodulemapping VALUES ('OmniNewgenTEM','OmniDocs')
select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBPRODUCTMODULEMAPPING for SubProductName =OmniNewgenTEM' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

SELECT 0
IF NOT EXISTS(SELECT SubProductName FROM PDBPRODUCTMODULEMAPPING WHERE SubProductName='OmniNewgenCMIS')
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBPRODUCTMODULEMAPPING for SubProductName =OmniNewgenCMIS' , getdate(), NULL, 'UPDATING')
INSERT INTO pdbproductmodulemapping VALUES ('OmniNewgenCMIS','OmniDocs')
select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBPRODUCTMODULEMAPPING for SubProductName =OmniNewgenCMIS' , getdate(), getdate(), 'ALREADY UPDATED')
END
;

SELECT 0
IF NOT EXISTS(SELECT SubProductName FROM PDBPRODUCTMODULEMAPPING WHERE SubProductName='RMS')
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBPRODUCTMODULEMAPPING for SubProductName =RMS' , getdate(), NULL, 'UPDATING')
INSERT INTO pdbproductmodulemapping VALUES ('RMS','OmniDocs')
select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBPRODUCTMODULEMAPPING for SubProductName =RMS' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT SubProductName FROM PDBPRODUCTMODULEMAPPING WHERE SubProductName='ODToSAPConnector')
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBPRODUCTMODULEMAPPING for SubProductName =ODToSAPConnector' , getdate(), NULL, 'UPDATING')
INSERT INTO pdbproductmodulemapping VALUES ('ODToSAPConnector','OmniDocs')
select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBPRODUCTMODULEMAPPING for SubProductName =ODToSAPConnector' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT SubProductName FROM PDBPRODUCTMODULEMAPPING WHERE SubProductName='SAPToODConnector')
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBPRODUCTMODULEMAPPING for SubProductName =SAPToODConnector' , getdate(), NULL, 'UPDATING')
INSERT INTO pdbproductmodulemapping VALUES ('SAPToODConnector','OmniDocs')
select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBPRODUCTMODULEMAPPING for SubProductName =SAPToODConnector' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
SELECT 0
IF NOT EXISTS(SELECT SubProductName FROM PDBPRODUCTMODULEMAPPING WHERE SubProductName='FormWrapper')
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBPRODUCTMODULEMAPPING for SubProductName =FormWrapper' , getdate(), NULL, 'UPDATING')
INSERT INTO pdbproductmodulemapping VALUES ('FormWrapper','OmniDocs')
select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('Insert', 'INSERTING INTO PDBPRODUCTMODULEMAPPING for SubProductName =FormWrapper' , getdate(), getdate(), 'ALREADY UPDATED')
END;
IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'ISVolume'
	AND COLUMN_NAME = 'EncrServiceClass')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table from patch', 'Altering Table ISVolume adding EncrServiceClass', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE ISVolume ADD EncrServiceClass  NVARCHAR(1020)
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table from patch', 'Altering Table ISVolume adding EncrServiceClass', getdate(), getdate(), 'ALREADY UPDATED')
	
END;

IF EXISTS(
SELECT * FROM PDBCabinet WHERE ThemeColor NOT IN ('1281dd','0072c6','cccccc')
)
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('UPDATE', 'Alter Table PDBCabinet for ThemeColor= 1281dd', getdate(), NULL, 'UPDATING')
	
	UPDATE PDBCabinet SET themecolor = '1281dd'
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
	
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('UPDATE', 'Alter Table PDBCabinet for ThemeColor= 1281dd', getdate(), getdate(), 'ALREADY UPDATED')
	
END;

SELECT 0
IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'PDBPMS_TABLE')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBPMS_TABLE' , getdate(), NULL, 'UPDATING')
	
	CREATE TABLE PDBPMS_TABLE
	(
		Product_Name	NVARCHAR(255),
		Product_Version	NVARCHAR(255),
		Product_Type	NVARCHAR(255),
		Patch_Number	INT NULL,
		Install_Date    NVARCHAR(255)
	)
	INSERT INTO PDBPMS_TABLE(Product_Name,Product_Version,Product_Type,Patch_Number,Install_Date) values('OD','10.1','BS',null,'22/08/2019')
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBPMS_TABLE' , getdate(), getdate(), 'ALREADY UPDATED')
END;

IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBDOMAINUSER'
	AND COLUMN_NAME = 'EligibleForInactivation')
BEGIN

	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDOMAINUSER add EligibleForInactivation', getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBDOMAINUSER ADD EligibleForInactivation CHAR NOT NULL DEFAULT 'N'
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBDOMAINUSER add EligibleForInactivation', getdate(), getdate(), 'ALREADY UPDATED')
END;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'PDBFTSANNOTATION')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBFTSANNOTATION' , getdate(), NULL, 'UPDATING')
	
 CREATE TABLE PDBFTSAnnotation
	( 
		   FTSAnnotationIndex         int IDENTITY(1,1) CONSTRAINT   pk_ftsannotationid      PRIMARY KEY     Clustered,
		   DocumentIndex              int
		   CONSTRAINT FK_FTSAnnotation_docid References  PDBDocument(DocumentIndex),
		   PageNumber                     int,
		   AnnotationIndex                   int
		   CONSTRAINT FK_FTSAnnotation References  PDBAnnotation(AnnotationIndex),
		   AnnotationBuffer           ntext null,
		   AnnotationType                    char(4),
		   CreationDateTime		datetime,
		   FileName				NVARCHAR(255) null,
		   FileDocumentIndex int null
		   CONSTRAINT FK_FTSAnnotationattachment_docid References  PDBDocument(DocumentIndex),
		   FileImageIndex			int null,
		   FileVolumeId			smallint null,
		   FileFTSFlag 		CHAR(2) null,
		   FileCoordinates     Varchar (4000) null
	 )	

	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBFTSANNOTATION' , getdate(), getdate(), 'ALREADY UPDATED')
END;

IF EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBRIGHTS'
	AND COLUMN_NAME = 'ACL'
	AND DATA_TYPE = 'CHAR'
	AND CHARACTER_MAXIMUM_LENGTH =10
	)
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBRIGHTS Alter Column ACL', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBRIGHTS ALTER COLUMN ACL CHAR(12)

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBRIGHTS Alter Column ACL', getdate(), getdate(), 'ALREADY UPDATED')
	
END;

IF EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBROLERIGHTS'
	AND COLUMN_NAME = 'ACL'
	AND DATA_TYPE = 'CHAR'
	AND CHARACTER_MAXIMUM_LENGTH =10
	)
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBROLERIGHTS Alter Column ACL', getdate(), NULL, 'UPDATING')
	
	ALTER TABLE PDBROLERIGHTS ALTER COLUMN ACL CHAR(12)

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBROLERIGHTS Alter Column ACL', getdate(), getdate(), 'ALREADY UPDATED')
	
END;

IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PDBROLEGROUP'
	AND COLUMN_NAME = 'PRIVILEGECONTROLLIST')
BEGIN

	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBROLEGROUP add PRIVILEGECONTROLLIST', getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBROLEGROUP ADD PRIVILEGECONTROLLIST VARCHAR(16) NOT NULL CONSTRAINT  def_priv DEFAULT '0000000000000000'
		
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter Table', 'Altering Table PDBROLEGROUP add PRIVILEGECONTROLLIST', getdate(), getdate(), 'ALREADY UPDATED')
END;

SELECT 0
IF NOT EXISTS(SELECT 1 FROM PDBGROUP WHERE GROUPNAME = 'Second Factor Immune' AND PrivilegeControlList = '0000000000000000')
begin
declare @stepNo int
insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBGROUP FOR Second Factor Immune GROUP' , getdate(), NULL, 'UPDATING')

INSERT INTO PDBGROUP(MainGroupIndex,GroupName,CreatedDateTime,ExpiryDateTime,PrivilegeControlList,Owner,Comment,GroupType, ParentGroupIndex)
VALUES (0,'Second Factor Immune',GETDATE(),GETDATE()+ 100*365 + 23,'0000000000000000', 1, '','G', 0)

select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
end
ELSE
BEGIN
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBGROUP FOR Second Factor Immune GROUP' , getdate(), getdate(), 'ALREADY UPDATED')
END;

BEGIN
	 SELECT 0
	 declare @stepNo int
	 IF NOT EXISTS(SELECT id FROM PDBConstant WHERE id = -50285) 
	 BEGIN

		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(-50285)', getdate(), NULL, 'UPDATING')

		INSERT INTO PDBConstant VALUES(-50285,'PRT_ERR_Two_Factor_Generation_Success','Error')
		
		select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
		update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
	 END 
	 ELSE
	 BEGIN
		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(-50285)', getdate(), getdate(), 'ALREADY UPDATED')
	 END

	 IF NOT EXISTS(SELECT id FROM PDBConstant WHERE id = -50286)
	 BEGIN

		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(-50286)', getdate(), NULL, 'UPDATING')

		INSERT INTO PDBConstant VALUES(-50286,'PRT_ERR_Two_Factor_Generation_Failure','Error')
		
		select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
		update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
	 END 
	 ELSE
	 BEGIN
		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(-50286)', getdate(), getdate(), 'ALREADY UPDATED')
	 END

	 IF NOT EXISTS(SELECT id FROM PDBConstant WHERE id = -50287) 
	 BEGIN

		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(-50287)', getdate(), NULL, 'UPDATING')

		INSERT INTO PDBConstant VALUES(-50287,'PRT_ERR_Two_Factor_Authentication_Validation_Failure','Error')
		
		select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
		update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
	 END 
	 ELSE
	 BEGIN
		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(-50287)', getdate(), getdate(), 'ALREADY UPDATED')
	 END
	 
	 IF NOT EXISTS(SELECT id FROM PDBConstant WHERE id = -50288)
	 BEGIN

		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(-50288)', getdate(), NULL, 'UPDATING')

		INSERT INTO PDBConstant VALUES(-50288,'PRT_ERR_Two_Factor_Authentication_Login_Failure','Error')
		
		select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
		update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
	 END 
	 ELSE
	 BEGIN
		insert into PDBUpdateStatus values ('Insert', 'INSERT INTO PDBCONSTANT VALUES(-50288)', getdate(), getdate(), 'ALREADY UPDATED')
	 END
END;

IF NOT EXISTS(
		SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'PDBCabinet'
		AND COLUMN_NAME = 'TwoFactorAuthenticationFlag'
	)
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'Altering TABLE PDBCabinet add TwoFactorAuthenticationFlag' , getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBCabinet ADD TwoFactorAuthenticationFlag CHAR(1) NOT NULL DEFAULT 'N'
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'Altering TABLE PDBCabinet add TwoFactorAuthenticationFlag' , getdate(), getdate(), 'ALREADY UPDATED')
END;

IF NOT EXISTS(
		SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'PDBCabinet'
		AND COLUMN_NAME = 'TwoFactorClass'
	)
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'Altering TABLE PDBCabinet add TwoFactorClass' , getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBCabinet ADD TwoFactorClass NVARCHAR(1020)
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'Altering TABLE PDBCabinet add TwoFactorClass' , getdate(), getdate(), 'ALREADY UPDATED')
END;

IF NOT EXISTS(
select * from sys.indexes
where object_id = (select object_id from sys.objects where name = 'PDBFTSDATA') and name='IDX_PDBFTSDATA_DOCID')

BEGIN
	SELECT 1
	declare @stepNo int
	
	INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBFTSDATA Columns (ObjectIndex, DocumentIndex, ObjectType)' , GETDATE(), NULL, 'Updating Started')
	
	
	CREATE NONCLUSTERED INDEX IDX_PDBFTSDATA_DOCID ON PDBFTSDATA (ObjectIndex, DocumentIndex, ObjectType)
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	UPDATE PDBUpdateStatus SET Status = 'UPDATED', EndDate = GETDATE() WHERE StepNumber = @StepNo
	
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
		INSERT INTO PDBUpdateStatus values ('Create Index', 'Creating index on Table PDBFTSDATA Columns (ObjectIndex, DocumentIndex, ObjectType)' , GETDATE(), NULL, 'Already Updated')
END;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'PDBDATAFIELDVALIDATION')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBDATAFIELDVALIDATION' , getdate(), NULL, 'UPDATING')
	
CREATE TABLE PDBDataFieldValidation 
(
	ValidationIndex INT
	IDENTITY(1,1) 	CONSTRAINT   	pk_validationIndex      PRIMARY KEY  Clustered,
	ValidationName nvarchar(255)
	CONSTRAINT   uk_validationName	UNIQUE (ValidationName),
    ValidationData ntext,
	DataFieldType char(1),
    LastModifiedDate  DATETIME
)

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBDATAFIELDVALIDATION' , getdate(), getdate(), 'ALREADY UPDATED')
END;

IF NOT EXISTS(
		SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'PDBCabinet'
		AND COLUMN_NAME = 'CabinetConfig'
	)
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'Altering TABLE PDBCabinet add CabinetConfig' , getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBCabinet ADD CabinetConfig ntext
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'Altering TABLE PDBCabinet add CabinetConfig' , getdate(), getdate(), 'ALREADY UPDATED')
END;

IF NOT EXISTS(
	SELECT 1 FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'PDBMULTILINGUAL')
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBMULTILINGUAL' , getdate(), NULL, 'UPDATING')
	
 CREATE TABLE PDBMultilingual 
(
	ObjectIndex int,
	Type CHAR(1) NOT NULL,
	Value NVARCHAR(1020),
	Locale VARCHAR(6)
)

	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBMULTILINGUAL' , getdate(), getdate(), 'ALREADY UPDATED')
END;

IF NOT EXISTS( SELECT 1 FROM PDBConstant WHERE Id = -50289 AND Message = 'PRT_ERR_OneCharacterSearchNotAllowed')
BEGIN
	SELECT 1
	SET NOCOUNT ON
	declare @stepNo int
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant ADD PRT_ERR_OneCharacterSearchNotAllowed', getdate(), NULL, 'UPDATING')
	
	
	Insert into PDBConstant values (-50289,'PRT_ERR_OneCharacterSearchNotAllowed','Error')
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
    update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo	
END
ELSE
BEGIN
	SELECT 0
	SET NOCOUNT ON
	insert into PDBUpdateStatus values ('INSERT', 'INSERTING INTO PDBConstant VALUES PRT_ERR_OneCharacterSearchNotAllowed', getdate(), getdate(), 'ALREADY UPDATED')
END;

IF NOT EXISTS(
		SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'PDBDATADEFINITION'
		AND COLUMN_NAME = 'DATACLASSMETADATA'
	)
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'Altering TABLE PDBDATADEFINITION add DATACLASSMETADATA' , getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBDataDefinition ADD DataClassMetaData ntext null
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'Altering TABLE PDBDATADEFINITION add DATACLASSMETADATA' , getdate(), getdate(), 'ALREADY UPDATED')
END;

IF NOT EXISTS(
		SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'PDBGLOBALINDEX'
		AND COLUMN_NAME = 'FIELDMETADATA'
	)
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'Altering TABLE PDBGLOBALINDEX add FIELDMETADATA' , getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBGlobalIndex ADD FieldMetaData ntext null
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'Altering TABLE PDBGLOBALINDEX add FIELDMETADATA' , getdate(), getdate(), 'ALREADY UPDATED')
END;
IF NOT EXISTS(
		SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'PDBPickList'
		AND COLUMN_NAME = 'PickListMetaData'
	)
BEGIN
	SELECT 1
	declare @stepNo int
	insert into PDBUpdateStatus values ('Alter TABLE', 'Altering TABLE PDBPickList add PickListMetaData' , getdate(), NULL, 'UPDATING')

	ALTER TABLE PDBPickList ADD PickListMetaData ntext null
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('Alter TABLE', 'Altering TABLE PDBPickList add PickListMetaData' , getdate(), getdate(), 'ALREADY UPDATED')
END;
------------------------------------------------------------------------------------------------------------------------
--Changed By			: Sanjeev Kumar
--Reason / Cause (Bug No if Any):  Bug 23898 
--Change Description		: Asterisk prefix Search client side provide in document name and folder name.
--------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'PDBDOCUMENTNAME')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBDOCUMENTNAME' , getdate(), NULL, 'UPDATING')
	
	Create table PDBDocumentName
	(
		DocumentIndex int CONSTRAINT   pk_dindexname  PRIMARY KEY  Clustered,
		Name NVARCHAR(255),
		CONSTRAINT FK_DN_DOCName FOREIGN KEY (DOCUMENTINDEX) REFERENCES PDBDOCUMENT(DOCUMENTINDEX)
	)	
	insert into PDBDocumentName  Select DocumentIndex, name from PDBDocument
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBDOCUMENTNAME' , getdate(), getdate(), 'ALREADY UPDATED')
END
;
------------------------------------------------------------------------------------------------------------------------
--Changed By			: Sanjeev Kumar
--Reason / Cause (Bug No if Any):  Bug 23898 
--Change Description		: Asterisk prefix Search client side provide in document name and folder name.
--------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = 'PDBFOLDERNAME')
BEGIN
	SELECT 1
	
	declare @stepNo int
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBFOLDERNAME' , getdate(), NULL, 'UPDATING')
	
	Create table PDBFolderName
	(
		FolderIndex int CONSTRAINT   pk_findexname       PRIMARY KEY  Clustered,
		Name NVARCHAR(255),
	CONSTRAINT FK_FN_FolderName FOREIGN KEY (FolderIndex) REFERENCES PDBFolder(FolderIndex)
	)
	
	insert into PDBFolderName  Select FolderIndex, name from PDBFolder where FolderType = 'G'
	
	select @stepNo = max(STEPNUMBER) from pdbupdatestatus 
	update PDBUpdateStatus set status = 'UPDATED', enddate = getdate() where STEPNUMBER = @stepNo
		
END
ELSE
BEGIN
	SELECT 0
	insert into PDBUpdateStatus values ('CREATE TABLE', 'CREATING TABLE PDBFOLDERNAME' , getdate(), getdate(), 'ALREADY UPDATED')
END

--end
