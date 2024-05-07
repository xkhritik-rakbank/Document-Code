/******************************************************************************************************
			NEWGEN SOFTWARE TECHNOLOGIES LIMITED
Group			: Application-Products
Product / Project	: Java Transaction Server
Module			: PanRemote
File Name		: PRTConnectCabinet.sql
Author			: Shikhar Prawesh
Date written		: 23/01/2002
Description		: This procedure connects user to a cabinet.
---------------------------------------------------------------------------
		CHANGE HISTORY
---------------------------------------------------------------------------
 Date		Change By		Change Description (Bug No. If Any)
 21/03/2002	Shikhar			Bug No ODS_3.0.2_71
 19/09/2002	Sanjay			Changes for password encryption and max no of login users
 03/07/2003	Anil Bhandari		Changes in size of variables for multibyte support.
 12/01/2004	Anil Bhandari		Password Security in Service Pack
 07/11/2005	Abhijeet		Change for fixed user license
 14/12/2006	Sneh Lata		Implementation of S type User License
 17/12/2006	Vipin Kumar Singla	Added support for NVARCHAR,NCHAR and NTEXT (ERC51)
 19/02/2007	Sneh Lata		Changes for Loggedin attempt count configurabilty
 19/02/2007	Sneh Lata		Changes for forceful password change on Password Expiry
 13/04/2007	Sneh Lata		Changes for warning before Password Expiry
 29-05-2007	Shikhar			Change for Optimization
 06/08/2007	Sneh Lata		Changes for Application Name Support
 17/08/2007	Sneh Lata		Audit Log Optimization
 17/10/2007	Rohika Gupta		Forceful Password change when Password reset from Admin
 18/10/2007	Bharat Pardeshi		Separating concurrent and fix user login check
 22/10/2007	Mili Das		Changes to get the details of last successful/unsuccessful login
 22/10/2007	Mili Das		Changes to  Lock new user if not login with a specified period
 16/01/2008	Mili Das		Changes for implementation of Maker-Checker feature
 06/02/2008	Mili Das		Changes for Checking Login period of a user.
 08/04/2008	Mili Das		Check if logged in user is Admin(Merge PRTIsAdmin in PRTConnectCabinet for optimization).
 01/05/2008	Vikas Dubey		Changes for implementation of DDTFTS feature
 02/05/2008	Vikas Dubey		Changes for implementation of 'S'Type User Concurrency
 17/07/2008	Mili Das		Added support for Turkish(Removed UPPER)
 17/07/2008	Rohika Gupta		Changes for Password Autogeneration
 19/09/2008	Shikhar			Added DeletedFlag in PDBUser Table. User with this property as 'Y' are marked for deleted.
 19/09/2008	Shikhar			Added indexes of user's system folders in user table
 29/09/2008	Mili Das		Changes for Audit Trail Unification
 27/11/2008	Pranay Tiwari		Changes in datatypes of variables to support larger userindex
 02/03/2009	Mili Das		Check for Stype maximum users even for Fixed users.
 04/01/2010	Mili Das		Support for Portal Users
 17/09/2010	Vikas Dubey		Change for 'Flexibility On Concurrent User Count Limit'
 22/11/2010	Vikas Dubey		Changes done to support dormant users expiry warning time(ERC180)
 05/01/2011	Vikas Dubey		Changes for ECM Server7.1 Bug id : 26451
 10/06/2011	Gaurav Rana		Support for Evaluation version
 05/09/2012 Swati Gupta     Changes for optimization (bug 2209)
 31/10/2012 Neeraj Kumar    set PasswdExpiryMailFlag to allow mail sendig on expiration of password.(Bug 2049)
 11/04/2013 Swati Gupta   	Changes for Flag based Password Encryption(bug 2777)
 24/05/2013 Neeraj Kumar	Bug 2211 - date format conversion in yyyy-mm-dd hh:mi:ss.mmm(24h)
 04/10/2013 Swati Gupta     Changes for Audit Log Enhancement(IP Address) 
 27/12/2013 Atul Khemka		Changes done to support Maximum concurrency condition
 11/08/2016 Vikas Dubey     Changes for Default system folders will not be returned
 20/03/2017 Ravinder Partap Changes for Access Log Capturing
 09/02/2108 Shubham Mittal  Changes for configuring different Action Ids for different failure reasons
 31/05/2018 Jitendra kumar   Bug 12454 - Handling for Failure cases for LDAP. Remove validations for dummy password
 19/06/2018 Shubham Mittal   Bug 13828 Application Specific Licensing
 03/07/2018 Shubham Mittal   Bug 13886- After upgrading the No.of concurrent users from 3 to 1 only , if the session of 1 user is not ended , after login blank screen is showing
 03/07/2018 Shubham Mittal   Bug 13875 -In case of U type license if concurrent connection limit reached and user login with utype license its showing Database is either stopped
 09/08/2018 Shubham Mittal   Bug 13973 - when we check concurrency in internal portal license the database is either stopped or not in use message is appearing
----------------------------------------------------------------------------
 Function Name 	: PRTConnectCabinet
 Date written	: 23/01/2002
 Author		: Shikhar Prawesh
 Input parameter	:
	@UserName		Name of the login user.
	@Password		Password of the login user.
	@CurrentDateTime	Date when the user is making the connection.
	@UserExistsFlag		Not being used.
	@RandomNum		Connection Id of the login user.
	@HostName		Host Name of the JTS server.
	@MainGroupId		The main group to which the login user belongs.
	@UserType		Type of user System or Normal.
 Output parameter	:
	@Privilege		Privileges of the login user.
	@LockByUser		Name of the lock by user.
	@DBStatus		Status. It will be 0 if the operation is done successfully, else it will contain the error code.
 Return value(Result set) :Return Status
*******************************************************************************************************/
--DROP PROCEDURE PRTConnectCabinet
--GO
CREATE PROCEDURE PRTConnectCabinet 
( 
@UserName		nvarchar(64), 
@Password		varbinary(128) = NULL, 
@CurrentDateTime 	varchar(50) = NULL, 
@UserExistsFlag		char(1)  = NULL, 
@RandomNum		int, 
@HostName		nvarchar(30), 
@MainGroupId		smallint, 
@UserType		char(1), 
@Locale			char(5) = NULL, 
@ApplicationInfo	varchar(20) = NULL, 
@Privilege		varchar(16) OUT, 
@LockByUser 		nvarchar(64) OUT, 
@DBStatus		int OUT, 
@LeftAttempts		int OUT, 
@ApplicationName	nvarchar(32) = NULL, 
@ListSysFolder		char(1)  = NULL, 
@lApplicationInfo	varchar(20) OUT, 
@lUserType		varchar(20) OUT, 
@ExtraInfoFlag          char(1) = 'N', 
@pwdCheckFlag           char(1) = 'Y',
@ProductName    nvarchar(255) = NULL,
@OTPValidationFlag 	char(1) = NULL
) 
--WITH ENCRYPTION 
AS 
BEGIN 
SET NOCOUNT ON 
DECLARE @spid smallint,@TSLoginTime datetime,@DBRight varchar(16),@DBFlag char(1), 
	@ctr smallint, 
	@TempExpiryDateTime datetime,@TempUserAlive char,@UserIndex int, 
	@CabinetLock char,@LockBy int,@DBpassword 	varbinary(128),@IsAdmin char(1), 
	@Count int 
DECLARE @ACLMore  		char(1) 
DECLARE @ACLStr   		varchar(255) 
DECLARE @DBDate			datetime 
DECLARE @TempDate		DATETIME 
Declare @LoggedInAttempts	smallInt 
Declare @UserLocked		char(1) 
Declare	@PasswordExpiryTime 	Datetime 
Declare	@PasswordExpiryFlag	Char(1) 
 
Declare	@DBUserNameInbox      	NVARCHAR(255) 
Declare	@DBUserNameTrash      	NVARCHAR(255) 
Declare	@DBUserNameSentItem     NVARCHAR(255) 
Declare @ExistFlag		smallint 
Declare @EscapeConcurrenyCheck	smallint 
Declare @tempIndex		int 
DECLARE @quote			char 
DECLARE @PWDFTCHECK		CHAR(1) 
DECLARE @DBPasswordHistory	NVARCHAR(1000) 
DECLARE @Counter                int 
DECLARE @Position		int 
DECLARE @MaxSUsers		int 
DECLARE @FUserLoginCount	int 
DECLARE @UserLoginCount		int 
DECLARE @LoggedinAttemptCount	smallint 
DECLARE @RemExpiryDays		int 
DECLARE @DBPasswdWarnTime	int 
DECLARE @DBEvalWarnTime		int 
DECLARE @DBApplicationInfo	VARCHAR(20) 
DECLARE @DBResetPasswordFlag	CHAR(1) 
 
DECLARE @ExternalPortalLoginCount	int 
DECLARE @InternalPortalLoginCount	int 
DECLARE @DefaultSystemUsers		int 
DECLARE	@lExistsFlag			int 
DECLARE	@lApplicationName	nvarchar(32) 
Declare @count1 int 
 
SELECT @quote = CHAR(39) 
 
DECLARE	@CabinetName		NVARCHAR(255), 
	@CabinetType		CHAR(10), 
	@CreatedDateTime	DATETIME, 
	@VersioningFlag		CHAR(10), 
	@SecurityLevel		INT, 
	@FtsDatabasePath	VARCHAR(1020), 
	@ImageVolumeIndex	INT, 
	@MaxNoOfLoginUsers	INT, 
    @BuildVersion       varchar(10), 
	@ThemeColor			varchar(120) 
 
DECLARE @UserPrivilegeControlList	VARCHAR(16) 
DECLARE @GroupPrivilegeControlList	VARCHAR(16) 
--Added by Mili 
DECLARE	@HasLoginBefore		char(1) 
DECLARE	@DayDifference		int 
DECLARE	@DBPasswordDisable	char(1) 
DECLARE	@DBPasswordDisableTime	INT 
DECLARE	@DBLastLoginTime	DATETIME 
DECLARE	@DBLastLoginFaliureTime	DATETIME 
DECLARE	@DBFailureAttemptCount	INT 
DECLARE @UserCreatedDateTime	DATETIME 
DECLARE @IsMCEnabled		CHAR(1) 
DECLARE @IsDDTFTSEnabled	CHAR(1) 
DECLARE @CheckerSuperIndex	int 
DECLARE	@DBDisableIdleUser	CHAR(1) 
DECLARE	@DBLoginPeriod		INT 
DECLARE	@DBUnlockTime		DATETIME 
DECLARE	@ldate			DATETIME 
------------------------------------------------------------------------------------------- 
--Changed By			: Rohika Gupta 
--Reason / Cause (Bug No if Any): Changes for Password Autogeneration 
--Change Description		: Changes for Password Autogeneration 
------------------------------------------------------------------------------------------- 
DECLARE @DBAutoPassword		CHAR(1) 
 
DECLARE @InboxFolderIndex	int 
DECLARE @SentItemFolderIndex	int 
DECLARE @TrashFolderIndex	int 
DECLARE @AttachmentFolderIndex	int 
DECLARE @DeletedFlag		char(1) 
DECLARE	@Comment		NVARCHAR(255) 
DECLARE	@FailureReason		NVARCHAR(255) -- bug 13973 the length of the datatype is increased
 
-- Added By Swati Gupta 
DECLARE	@MailId		NVARCHAR(255) 
DECLARE	@PersonalName		NVARCHAR(64) 
DECLARE	@FamilyName		NVARCHAR(255) 
DECLARE	@Account		int 
DECLARE @FolderBatchSize smallint 
DECLARE @DocumentBatchSize smallint 
DECLARE @DocSearchBatchSize smallint 
DECLARE @ListViewContents varchar(255) 
DECLARE @PickListBatchSize smallint  
DECLARE @UserListBatchSize smallint 
DECLARE @PreferedGroup nvarchar(64) 
DECLARE @PreferedFilter int 
DECLARE @NativeAppDocTypes varchar(500) 
DECLARE @DoclistSortPreferences varchar(10) 
DECLARE @SiteId int 
DECLARE @PasswdExpMailFlag CHAR(1) 
DECLARE @lTwoFactorAuthenticationFlag CHAR(1)
DECLARE @lTwoFactorClass NVARCHAR(1020)
DECLARE @lExistsImmuneGroup int 
DECLARE @EvaluationFlag		CHAR(1) 
DECLARE @NoOfTrailDays		Int 
DECLARE @CabinetCreationDate DATETIME 
DECLARE	@DBFlexibilityCount	SMALLINT 
DECLARE	@DBWarnFlag	CHAR(1) 
DECLARE @DBWarnFlag2 CHAR(1) 
DECLARE @loginPercent INT 
DECLARE	@DormantWarnTime		INT 
DECLARE	@DormantWarnTimeFlag	CHAR(1) 
DECLARE @sfid int 
DECLARE @sfun nvarchar(64) 
DECLARE @PreferredFolderIndex INT
DECLARE @lFolderLocation CHAR(1)
DECLARE @EnableDataSecurity CHAR(1)
DECLARE @GenerateAccessReport CHAR(1)
--added by shubham
DECLARE @lActionId int
DECLARE @lAssociatedAppName nvarchar(255) 
DECLARE @lAppIndex INT
DECLARE @lAssociationExist INT
DECLARE @lEnableLogin CHAR(1)
DECLARE @CabinetExternalPortalLoginCount	int 
DECLARE @CabinetInternalPortalLoginCount	int 
DECLARE @CabinetSystemUsers		int 
DECLARE @CabinetNormalUsers     int
DECLARE @ISDomainUser CHAR(1)
DECLARE @DefaultApplication varchar(255) 
DECLARE @folderIndex INT
EXECUTE GetDate1 @TempDate out 
SELECT @DBWarnFlag = 'N' 
SELECT @MainGroupId = ISNULL(@MainGroupId,0) 
SELECT @UserExistsFlag=ISNULL(@UserExistsFlag,'Y') 
SELECT @ListSysFolder = ISNULL(@ListSysFolder,'N') 
SELECT @ExtraInfoFlag = ISNULL(@ExtraInfoFlag,'N')	 
 
SELECT @CheckerSuperIndex = UserIndex FROM PDBUser WITH (NOLOCK) WHERE UserName = 'Supervisor2' 
SELECT @lExistsFlag = 0 
SELECT @lExistsImmuneGroup = 0
 
------------------------------------------------------------------------------------------------ 
-- Changed By				: Sneh Lata Sharma 
-- Reason / Cause (Bug No if Any)	: Changes for Application Name Support 
-- Change Description			: Changes for Application Name Support 
------------------------------------------------------------------------------------------------ 
IF @ApplicationName IS NOT NULL 
 
   Select	@ApplicationName = RTRIM(@ApplicationName) 
 
ELSE 
	Select @ApplicationName = '' 
 
 
IF @ApplicationInfo IS NOT NULL 
BEGIN 
	SELECT @ApplicationInfo = RTRIM(@ApplicationInfo) 
	SELECT @DBApplicationInfo = '-'+RTRIM(@ApplicationInfo) 
END 
ELSE 
BEGIN 
	SELECT @ApplicationInfo = '' 
	SELECT @DBApplicationInfo = '' 
END 
 
SELECT @lApplicationInfo = NULL 
SELECT @DBUserNameInbox = 'USER_INBOX_' + RTRIM(@UserName) 
SELECT @DBUserNameTrash = 'USER_SENTITEM_' + RTRIM(@UserName) 
SELECT @DBUserNameSentItem = 'USER_TRASH_' + RTRIM(@UserName) 
---------------------------------------------------------------------------- 
-- Changed By						: Neeraj Kumar 
-- Reason / Cause (Bug No if Any)	: Bug 2211  
-- Change Description				: date format conversion in yyyy-mm-dd hh:mi:ss.mmm(24h)  
----------------------------------------------------------------------------- 
 
IF @CurrentDateTime IS NULL 
	SELECT @DBDate = @TempDate 
ELSE 
	SELECT @DBDate = CONVERT(DATETIME, @CurrentDateTime,121) 
 
 
SELECT @DBStatus = -1 
SELECT @ctr = 1 
 


/* Check for the validity of the USER and CABINET */ 
 
	SELECT @DBStatus = 0 
    	SELECT @UserIndex = 0 
	SELECT @IsAdmin = 'N' 
 
------------------------------------------------------------------------------------------------ 
-- Changed By				: Swati Gupta 
-- Reason / Cause (Bug No if Any)	: Changes for optimization(bug 2209) 
-- Change Description			: User information is also fetched. 
------------------------------------------------------------------------------------------------ 
 
	SELECT 	@UserIndex = UserIndex, 
		@UserName = UserName, 
		@TempExpiryDateTime = ExpiryDateTime, 
        	@TempUserAlive = UserAlive, 
		@DBpassword = Password, 
		@PasswordExpiryTime = PasswordExpiryTime, 
		@PasswordExpiryFlag = PasswordNeverExpire, 
		@UserPrivilegeControlList = PrivilegeControlList, 
		@DeletedFlag = DeletedFlag, 
		@InboxFolderIndex = InboxFolderIndex, 
		@SentItemFolderIndex = SentItemFolderIndex, 
		@TrashFolderIndex = TrashFolderIndex, 
		@AttachmentFolderIndex = AttachmentFolderIndex, 
		@MailId = MailId, 
		@PersonalName = PersonalName, 
		@FamilyName = FamilyName, 
		@Account = Account, 
		@PreferredFolderIndex = PreferredFolderIndex
	FROM PDBUser WITH (NOLOCK)
	WHERE UserName = @Username 
	AND MainGroupId = @MainGroupId 
 
		IF 	@ProductName IS NOT NULL
		BEGIN
			SELECT @lAppIndex= ApplicationIndex FROM PDBApplicationLicenseDetails WHERE ApplicationName=@ProductName
		END	
        /* Check if user is valid */ 
        IF ( @UserIndex = 0 ) 
        BEGIN 
                EXECUTE PRTRaiseError 'PRT_ERR_User_Not_Exist',@DBStatus OUT 
		--INSERT into PDBNewAuditTrail_Table(ACTIONID,CATEGORY,ACTIVEOBJECTID,ACTIVEOBJECTTYPE, 
		--	SUBSDIARYOBJECTID,SUBSDIARYOBJECTTYPE,COMMENT,DATETIME,USERINDEX) 
		--VALUES(101, 'C', @UserIndex, 'U', -1, NULL, 'Failure-' + RTRIM(@UserName)+ RTRIM(@ApplicationInfo), @DBDate, @UserIndex) 
		--Return 
		SELECT @FailureReason = 'User does not exist' 
		--added by shubham
		SELECT @lActionId =674 --end
		GOTO ErrHnd 
        END 
------------------------------------------------------------------------------------------- 
--Changed By					: Gaurav Rana 
--Reason / Cause (Bug No if Any): Support for Evaluation version 
--Change Description			: Support for Evaluation versiont 
------------------------------------------------------------------------------------------- 
	SELECT @EvaluationFlag = LicenseType, @NoOfTrailDays = NoOfTrailDays, @CabinetCreationDate = CabinetCreationDate FROM PDBEvaluationInfo	WITH (NOLOCK) 
 
	IF(@EvaluationFlag NOT IN ('E','L','F')) 
	BEGIN 
		EXECUTE PRTRaiseError 'PRT_ERR_Invalid_Parameter', @DBStatus OUT 
		SELECT @FailureReason = 'Invalid Parameter'
			--added by shubham
		SELECT @lActionId =101 --end
		GOTO ErrHnd 
		 
	END 
 
	IF 	@EvaluationFlag = 'F' 
	Begin 
		EXECUTE PRTRaiseError 'PRT_ERR_Evaluation_Version_Expired', @DBStatus OUT 
		SELECT @FailureReason = 'Evaluation Version Expired' 
		--added by shubham
		SELECT @lActionId =672 --end
		GOTO ErrHnd 
	End 
	ELSE IF @EvaluationFlag = 'E' 
	Begin 
		SELECT @DBEvalWarnTime = DATEDIFF( dd , @CabinetCreationDate , @TempDate ) 
		SELECT @DBEvalWarnTime = @NoOfTrailDays - @DBEvalWarnTime 
		IF (@DBEvalWarnTime <= 0) 
		Begin 
			EXECUTE PRTRaiseError 'PRT_ERR_Evaluation_Version_Expired', @DBStatus OUT 
			SELECT @FailureReason = 'Evaluation Version Expired' 
			SELECT @lActionId =672 	--added by shubham
			GOTO ErrHnd 
		End 
		ELSE if (@DBEvalWarnTime >= 7) 
			SELECT @DBEvalWarnTime = NULL; 
	End 
 
 
------------------------------------------------------------------------------------------------------ 
--Changed By				: Shikhar 
--Reason / Cause (Bug No if Any)	: Added DeletedFlag in PDBUser Table. User with this property as 'Y' are marked for deleted. 
--Change Description			: User with DeletedFlag as 'Y' cannot log in 
----------------------------------------------------------------------------------------------------- 
	IF @DeletedFlag = 'Y' 
	BEGIN 
		EXECUTE PRTRaiseError 'PRT_ERR_User_Marked_For_Delete', @DBStatus OUT 
		SELECT @FailureReason = 'User is marked for deletion' 
		SELECT @lActionId =671 	--added by shubham
		GOTO ErrHnd 
		RETURN 
	END 
	--ANKIT
	SELECT @lFolderLocation = Location FROM PDBFolder WITH (NOLOCK) WHERE FolderIndex  = @PreferredFolderIndex
	IF 	@lFolderLocation <> 'G'
	 BEGIN
	  SELECT @PreferredFolderIndex = 0	 
	END
	 --ANKIT
------------------------------------------------------------------------------------------------ 
-- Changed By				: Mili Das 
-- Reason / Cause (Bug No if Any)	: Check if logged in user is Admin 
-- Change Description			: Check if logged in user is Admin 
------------------------------------------------------------------------------------------------ 
	if(Exists(Select * from PDBGroupMember WITH (NOLOCK)
	where GroupIndex = 2 and UserIndex = @UserIndex)) 
 
	Select @DBFlag = 'Y' 
------------------------------------------------------------------------------------------------ 
-- Changed By				: Sneh Lata Sharma 
-- Reason / Cause (Bug No if Any)	: Changes for Loggedin attempt count configurabilty 
-- Change Description			: Changes for Loggedin attempt count configurabilty 
------------------------------------------------------------------------------------------------ 
	SELECT @ExistFlag = 0 
	IF NOT EXISTS( 
		SELECT * FROM INFORMATION_SCHEMA.TABLES WITH (NOLOCK)
		WHERE TABLE_NAME = 'PDBUserConfig') 
	BEGIN 
		select @ExistFlag = 1 
	END 
 
------------------------------------------------------------------------------------------------ 
-- Changed By				: Sneh Lata Sharma 
-- Reason / Cause (Bug No if Any)	: Changes for warning before Password Expiry 
-- Change Description			: Changes for warning before Password Expiry 
------------------------------------------------------------------------------------------------ 
	IF @ExistFlag = 0 
	BEGIN 
		SELECT @LoggedinAttemptCount = LoggedinAttemptCount FROM PDBUserConfig WITH (NOLOCK)
 
		IF @LoggedinAttemptCount IS NULL OR @LoggedinAttemptCount = 0 
			SELECT @LoggedinAttemptCount = 5 
 
		SELECT @DBPasswdWarnTime = PasswordExpiryWarnTime FROM PDBUserConfig WITH (NOLOCK)
		IF @DBPasswdWarnTime IS NULL 
		BEGIN 
			SELECT @DBPasswdWarnTime = 0 
------------------------------------------------------------------------------------------- 
--Changed By			: Rohika Gupta 
--Reason / Cause (Bug No if Any): Changes for Password Autogeneration 
--Change Description		: Changes for Password Autogeneration 
------------------------------------------------------------------------------------------- 
			SELECT @DBAutoPassword = AutoPassword FROM PDBUserConfig WITH (NOLOCK)
			IF @DBAutoPassword IS NULL 
				SELECT @DBAutoPassword = 'N' 
		END 
	END 
	ELSE 
	BEGIN 
		SELECT @LoggedinAttemptCount = 5 
		SELECT @DBPasswdWarnTime = 0 
		SELECT @DBAutoPassword = 'N' 
	END 
------------------------------------------------------------------------------------------------ 
-- Changed By				: Mili Das 
-- Reason / Cause (Bug No if Any)	: Support for Portal Users 
-- Change Description			: Support for Portal Users 
------------------------------------------------------------------------------------------------ 
	/* Check whether user's logged in attempts has been exceded. */ 
	Select 	@LoggedInAttempts = LoggedInAttempts, 
		@UserLocked = UserLocked, 
		@lUserType = UserType 
	From UserSecurity WITH (NOLOCK)
	Where UserIndex = @UserIndex 
 
	IF(RTRIM(UPPER(@UserName))= 'SUPERVISOR' OR RTRIM(UPPER(@UserName))= 'SUPERVISOR2') 
	BEGIN 
		SELECT @lUserType = @UserType 
	END 
 
	--Select @LeftAttempts = 5 - @LoggedInAttempts 
	Select @LeftAttempts = @LoggedinAttemptCount - @LoggedInAttempts 
 
	--If @LoggedInAttempts >= 5 OR @UserLocked = 'Y' 
	If @LoggedInAttempts >= @LoggedinAttemptCount OR @UserLocked = 'Y' 
	Begin 
		Update 	UserSecurity Set UserLocked = 'Y', LockedTime = @TempDate 
		Where UserIndex = @UserIndex 
			--added by shubham
		
	      	EXECUTE PRTRaiseError 'PRT_ERR_LoggedInAttempts_Exceded',@DBStatus OUT 
		SELECT @FailureReason = 'Login attempts has exceeded' 
		SELECT @lActionId =673 	--added by shubham
		GOTO ErrHnd 
		Return 
	End 
------------------------------------------------------------------------------------------------ 
-- Changed By				: Mili Das 
-- Reason / Cause (Bug No if Any)	: Changes to  Lock new user if not login with a specified period 
-- Change Description			: Changes to  Lock new user if not login with a specified period 
------------------------------------------------------------------------------------------------ 
	SELECT  @DBPasswordDisable=PasswordDisable,@DBPasswordDisableTime=PasswordDisableTime 
	FROM PDBUserConfig WITH (NOLOCK)
 
	SELECT 	@HasLoginBefore = HasLoginBefore, 
		@UserLocked = UserLocked 
	FROM UserSecurity WITH (NOLOCK)
	WHERE UserIndex = @UserIndex 
 
 
	IF @DBPasswordDisable='Y' 
	BEGIN 
		IF @HasLoginBefore = 'N' 
		BEGIN 
			SELECT 	@UserCreatedDateTime = CreatedDateTime 
			FROM PDBUser WITH (NOLOCK)
			WHERE UserIndex = @UserIndex 
 
			SELECT @DayDifference = DATEDIFF( dd , @UserCreatedDateTime , @TempDate ) 
 
			IF  @DayDifference > @DBPasswordDisableTime 
			BEGIN 
				Update 	UserSecurity Set UserLocked = 'Y', LockedTime = @TempDate , HasLoginBefore = 'Y' 
				Where UserIndex = @UserIndex
				
				
				EXECUTE PRTRaiseError 'PRT_ERR_User_Expired',@DBStatus OUT 
				SELECT @FailureReason = 'User has expired' 
				SELECT @lActionId =675 	--added by shubham
				GOTO ErrHnd 
				RETURN 
			END 
		END 
	END 
------------------------------------------------------------------------------------------------ 
-- Changed By				: Mili Das 
-- Reason / Cause (Bug No if Any)	: Changes for Checking Login period of a user. 
-- Change Description			: Changes for Checking Login period of a user. 
------------------------------------------------------------------------------------------------ 
----------------------------------------------------------------------------------------------------- 
-- Changed By						: Neeraj Kumar 
-- Reason / Cause (Bug No if Any)   : set PasswdExpiryMailFlag to allow mail sendig on expiration of password.(Bug 2049) 
-- Change Description				: set PasswdExpiryMailFlag to allow mail sendig on expiration of password.(Bug 2049) 
-----------------------------------------------------------------------------------------------------	 
	SELECT @DBDisableIdleUser=DisableIdleUser,@DBLoginPeriod=LoginPeriod, 
		   @PasswdExpMailFlag = PasswdExpiryMailFlag 
	FROM   PDBUserConfig WITH (NOLOCK)
 
	SELECT @DBLastLoginTime=LastLoginTime FROM UserSecurity WITH (NOLOCK)
	WHERE UserIndex = @UserIndex 
 
	SELECT @DBUnlockTime=LastUnlockTime 
	FROM UserSecurity WITH (NOLOCK)
	WHERE UserIndex = @UserIndex 
------------------------------------------------------------------------------------------------ 
-- Changed By				: Mili Das 
-- Reason / Cause (Bug No if Any)	: Support for Portal Users 
-- Change Description			: Support for Portal Users 
------------------------------------------------------------------------------------------------ 
	IF @DBDisableIdleUser ='Y' AND @UserIndex <>1 AND @UserIndex <> @CheckerSuperIndex AND  @lUserType <> 'S' 
	BEGIN 
		IF  @DBLastLoginTime IS NOT NULL 
		BEGIN 
			IF @DBLastLoginTime > @DBUnlockTime OR @DBUnlockTime IS NULL 
 
				SELECT @ldate=@DBLastLoginTime 
			ELSE 
				SELECT @ldate=@DBUnlockTime 
 
 
			SELECT @DayDifference = DATEDIFF( dd , @ldate , @TempDate ) 
 
			IF  @DayDifference > @DBLoginPeriod 
			BEGIN 
				Update 	UserSecurity Set UserLocked = 'Y', LockedTime = @TempDate 
				Where UserIndex = @UserIndex
				
				
				EXECUTE PRTRaiseError 'PRT_ERR_User_Login_Period_Expired',@DBStatus OUT 
				SELECT @FailureReason = 'User login period has expired' 
				SELECT @lActionId =676 	--added by shubham
				GOTO ErrHnd 
				RETURN 
			END 
 
		END 
		ELSE 
		BEGIN 
			SELECT 	@UserCreatedDateTime = CreatedDateTime 
			FROM PDBUser WITH (NOLOCK)
			WHERE UserIndex = @UserIndex 
 
			IF @UserCreatedDateTime > @DBUnlockTime OR @DBUnlockTime IS NULL 
 
				SELECT @ldate=@UserCreatedDateTime 
			ELSE 
				SELECT @ldate=@DBUnlockTime 
 
			SELECT @DayDifference = DATEDIFF( dd , @ldate , @TempDate ) 
 
			IF  @DayDifference > @DBLoginPeriod 
			BEGIN 
				Update 	UserSecurity Set UserLocked = 'Y', LockedTime = @TempDate 
				Where UserIndex = @UserIndex
				
				
				EXECUTE PRTRaiseError 'PRT_ERR_User_Login_Period_Expired',@DBStatus OUT 
				SELECT @FailureReason = 'User login period has expired' 
				SELECT @lActionId =676  	--added by shubham
				GOTO ErrHnd 
				RETURN 
			END 
		END 
	END 
 
 
	/* Check for the valid password*/ 
	--IF @DBpassword IS NULL AND rtrim(@password) IS NOT NULL 
	-- Null Password not allowed 
	
	SELECT @ISDomainUser='N'
			IF EXISTS( SELECT 1 FROM PDBDOMAINUSER WHERE UserIndex = @UserIndex )
	SELECT @ISDomainUser='Y'
	
	
------------------------------------------------------------------------------------------- 
--Changed By			: Swati Gupta 
--Reason / Cause (Bug No if Any): Changes for Flag based Password Encryption(bug 2777) 
--Change Description		: Changes for Flag based Password Encryption 
------------------------------------------------------------------------------------------- 
	IF (@ISDomainUser<>'Y')
	BEGIN
		IF @Password IS NULL AND @pwdCheckFlag='Y' 
		BEGIN 
			EXECUTE PRTRaiseError 'PRT_ERR_Invalid_Password',@DBStatus OUT 
			/* 
			Changed By			: Shikhar 
			Reason / Cause (Bug No if Any)	: Bug No ODS_3.0.2_71 
			Change Description		: Log generated for unsuccessful login 
			*/ 
			--Select @LeftAttempts = 4 - @LoggedInAttempts 
			Select @LeftAttempts = (@LoggedinAttemptCount - 1) - @LoggedInAttempts 
			IF @LeftAttempts = 0 
			Begin 
				Update UserSecurity Set UserLocked = 'Y', LockedTime = @DBDate 
				Where UserIndex = @UserIndex 
				
					
			End 
			Update 	UserSecurity Set LoggedInAttempts = LoggedInAttempts + 1 
			Where UserIndex = @UserIndex 
			SELECT @FailureReason = 'Invalid password' 
			SELECT @lActionId =677 	--added by shubham
			GOTO ErrHnd 
			Return 
		END 
	 
		IF ((@DBpassword IS NOT NULL AND @password IS NULL) OR 
			(@DBpassword IS NULL AND rtrim(@password) IS NOT NULL)) AND @pwdCheckFlag='Y' 
		BEGIN 
			EXECUTE PRTRaiseError 'PRT_ERR_Invalid_Password',@DBStatus OUT 
			--Select @LeftAttempts = 4 - @LoggedInAttempts 
			Select @LeftAttempts = (@LoggedinAttemptCount - 1) - @LoggedInAttempts 
			IF @LeftAttempts = 0 
			Begin 
				Update UserSecurity Set UserLocked = 'Y', LockedTime = @DBDate 
				Where UserIndex = @UserIndex 
			End 
	 
			Update 	UserSecurity Set LoggedInAttempts = LoggedInAttempts + 1 
			Where UserIndex = @UserIndex 
			SELECT @FailureReason = 'Invalid password' 
			SELECT @lActionId =677  	--added by shubham
			GOTO ErrHnd 
			Return 
		END 
	 
		IF @DBpassword <> @password AND @pwdCheckFlag='Y' 
		BEGIN 
			EXECUTE PRTRaiseError 'PRT_ERR_Invalid_Password',@DBStatus OUT 
			--Select @LeftAttempts = 4 - @LoggedInAttempts 
			Select @LeftAttempts = (@LoggedinAttemptCount - 1) - @LoggedInAttempts 
			IF @LeftAttempts = 0 
			Begin 
				Update UserSecurity Set UserLocked = 'Y', LockedTime = @DBDate 
				Where UserIndex = @UserIndex 
				
			End 
	 
			Update 	UserSecurity Set LoggedInAttempts = LoggedInAttempts + 1 
			Where UserIndex = @UserIndex 
			SELECT @FailureReason = 'Invalid password' 
			SELECT @lActionId =677 	--added by shubham
			GOTO ErrHnd 
			Return 
		END 
	END
	
      IF ( @TempExpiryDateTime  < @DBDate ) 
      BEGIN 
		EXECUTE PRTRaiseError 'PRT_ERR_User_Expired',@DBStatus OUT 
		--Select @LeftAttempts = 4 - @LoggedInAttempts 
		Select @LeftAttempts = (@LoggedinAttemptCount - 1) - @LoggedInAttempts 
		IF @LeftAttempts = 0 
		Begin 
			Update UserSecurity Set UserLocked = 'Y', LockedTime = @DBDate 
			Where UserIndex = @UserIndex 
			
		End
 
		Update 	UserSecurity Set LoggedInAttempts = LoggedInAttempts + 1 
		Where UserIndex = @UserIndex 
		SELECT @FailureReason = 'User has expired' 
		SELECT @lActionId =675 	--added by shubham
      		GOTO ErrHnd 
	        return 
      END 
 
      IF ( @TempUserAlive <> 'Y' ) 
      BEGIN 
		EXECUTE PRTRaiseError 'PRT_ERR_User_Not_Alive',@DBStatus OUT 
		--Select @LeftAttempts = 4 - @LoggedInAttempts 
		Select @LeftAttempts = (@LoggedinAttemptCount - 1) - @LoggedInAttempts 
		IF @LeftAttempts = 0 
		Begin 
			Update UserSecurity Set UserLocked = 'Y', LockedTime = @DBDate 
			Where UserIndex = @UserIndex 
			
			
		End
 
		Update 	UserSecurity Set LoggedInAttempts = LoggedInAttempts + 1 
		Where UserIndex = @UserIndex 
		SELECT @FailureReason = 'User is not alive' 
		SELECT @lActionId =678  	--added by shubham
		GOTO ErrHnd 
		RETURN 
      END 
------------------------------------------------------------------------------------------------ 
/* 
	Changed By			: Yogvinder 
	Reason / Cause (Bug No if Any)	: ERC 22/ First time Login force password change 
	Change Description		: ERC 22/ First time Login force password change 
*/ 
		SELECT @ExistFlag = 0 
		IF NOT EXISTS( 
			SELECT * FROM INFORMATION_SCHEMA.TABLES 
			WHERE TABLE_NAME = 'PDBLicense') 
		BEGIN 
		select @ExistFlag = 1 
		SELECT @PWDFTCHECK = 'N' 
		END 
 
		IF @ExistFlag = 0 
		BEGIN 
			select @PWDFTCHECK = FTLCHECK from pdblicense WITH (NOLOCK)
		END 
 
------------------------------------------------------------------------------------------------ 
-- Changed By				: Rohika Gupta 
-- Reason / Cause (Bug No if Any)	: Forceful Password change when Password reset from Admin 
-- Change Description			: Forceful Password change when Password reset from Admin 
------------------------------------------------------------------------------------------------ 
		SELECT @DBPasswordHistory  = PasswordHistory, 
		       @DBResetPasswordFlag = ResetPasswordFlag FROM USERSECURITY WITH (NOLOCK) WHERE UserIndex = @UserIndex 
 
 
		SELECT @Counter = 0 
 
		WHILE(datalength(rtrim(ltrim(@DBPasswordHistory))) > 0) 
		BEGIN 
			SELECT @Position   =  CHARINDEX(CHAR(21),@DBPasswordHistory) 
			IF(@Position<1 OR @Counter>1 OR @Position IS NULL) 
				BREAK 
			ELSE 
				SELECT @Counter=@Counter+1 
			SELECT @DBPasswordHistory  =  STUFF(@DBPasswordHistory,1,@Position,NULL) 
		END 
 
------------------------------------------------------------------------------------------------ 
-- Changed By				: Mili Das 
-- Reason / Cause (Bug No if Any)	: Support for Portal Users 
-- Change Description			: Support for Portal Users 
------------------------------------------------------------------------------------------------		 
		IF (@Counter=1 AND @PWDFTCHECK ='Y' AND @UserIndex <>1 AND @UserIndex <> @CheckerSuperIndex AND  @lUserType <> 'S' AND @ISDomainUser <> 'Y') OR (@DBResetPasswordFlag = 'Y' AND @lUserType <> 'S' AND @PWDFTCHECK ='Y' AND @ISDomainUser <> 'Y') 
		BEGIN 
			EXECUTE PRTRaiseError 'PRT_ERR_First_Time_Login',@DBStatus OUT 
			RETURN 
		END 
 
------------------------------------------------------------------------------------------------ 
      /* check if the cabinet is locked */ 
      SELECT    @CabinetLock = CabinetLock, 
		@ACLMore = ACLMoreFlag, 
		@ACLstr	= ACL, 
		@LockBy 		= LockByUser, 
		@CabinetName		= CabinetName, 
		@CabinetType		= CabinetType, 
		@CreatedDateTime	= CreatedDateTime, 
		@VersioningFlag		= VersioningFlag, 
		@SecurityLevel 		= SecurityLevel, 
		@FtsDatabasePath 	= FtsDatabasePath, 
		@ImageVolumeIndex 	= ImageVolumeIndex, 
		@BuildVersion       = BuildVersion,
		@DBFlexibilityCount = FlexibilityCount, 
		@ThemeColor			= ThemeColor,
		@EnableDataSecurity 	= EnableDataSecurity,
		@GenerateAccessReport = GenerateAccessReport,
		@lTwoFactorAuthenticationFlag = TwoFactorAuthenticationFlag,
		@lTwoFactorClass = TwoFactorClass
	FROM PDBCabinet WITH (NOLOCK)
 
 
       /* Check READ rights on cabinet */ 
	Execute PRTGetRights @UserIndex, 'C', 0,@DBRight OUT, 
		NULL, NULL, @ACLMore, @ACLstr, @IsAdmin OUT, @DBStatus OUT 
	IF ( substring(@DBRight,2,1)  <> '1') 
	BEGIN 
		EXECUTE PRTRaiseError 'PRT_ERR_InvalidRights_On_Cabinet',@DBStatus OUT 
		--Select @LeftAttempts = 4 - @LoggedInAttempts 
		Select @LeftAttempts = (@LoggedinAttemptCount - 1) - @LoggedInAttempts 
		IF @LeftAttempts = 0 
		Begin 
			Update UserSecurity Set UserLocked = 'Y', LockedTime = @DBDate 
			Where UserIndex = @UserIndex 
			
		End
 
		Update 	UserSecurity Set LoggedInAttempts = LoggedInAttempts + 1 
		Where UserIndex = @UserIndex 
		SELECT @FailureReason = 'User does not have rights' 
		SELECT @lActionId =679 	--added by shubham
		GOTO ErrHnd 
		RETURN 
	END 
 
 
    IF ( @CabinetLock = 'Y' ) 
	BEGIN 
		IF NOT (@LockBy = @UserIndex OR @IsAdmin = 'Y') 
		BEGIN 
			EXECUTE PRTRaiseError 'PRT_ERR_Cabinet_Locked',@DBStatus OUT 
			--Select @LeftAttempts = 4 - @LoggedInAttempts 
			Select @LeftAttempts = (@LoggedinAttemptCount - 1) - @LoggedInAttempts 
			IF @LeftAttempts = 0 
			Begin 
				Update UserSecurity Set UserLocked = 'Y', LockedTime = @DBDate 
				Where UserIndex = @UserIndex 
			
			End
 
			Update 	UserSecurity Set LoggedInAttempts = LoggedInAttempts + 1 
			Where UserIndex = @UserIndex 
			SELECT @FailureReason = 'Cabinet is locked' 
			SELECT @lActionId =680 	--added by shubham
			GOTO ErrHnd 
			Return 
        END 
	END 
	-- End of validating user 
 
/* 
DECLARE @SeedVal char(20),@CurDate datetime,@DBYear smallint,@DBMonth smallint,@DBDate smallint, 
	@DBHour smallint,@DBMinuts smallint,@DBSeconds smallint,@DBMilisecond smallint, 
 
 
SELECT @CurDate = @TempDate 
SELECT @DBYear = CONVERT(CHAR(5),DATEPART(YY,@CurDate)) 
SELECT @DBMonth = CONVERT(CHAR(2),DATEPART(MM,@CurDate)) 
SELECT @DBDate = CONVERT(CHAR(2),DATEPART(DD,@CurDate)) 
SELECT @DBHour = CONVERT(CHAR(2),DATEPART(HH,@CurDate)) 
SELECT @DBMinuts = CONVERT(CHAR(2),DATEPART(MI,@CurDate)) 
SELECT @DBSeconds = CONVERT(CHAR(2),DATEPART(SS,@CurDate)) 
SELECT @DBMilisecond = CONVERT(CHAR(3),DATEPART(MS,@CurDate)) 
SELECT @SeedVal = rtrim(@DBYear)+rtrim(@DBMonth)+rtrim(@DBDate) 
		+rtrim(@DBHour)+rtrim(@DBMinuts)+rtrim(@DBSeconds) 
		+rtrim(@DBMilisecond) 
*/ 
 
 
/* delete all the entries from the table which are there for more than 24 hours */ 
 
/* check if the entry for the current index already exists */ 
IF EXISTS (SELECT * FROM PDBConnection WITH (NOLOCK) WHERE RandomNumber = @RandomNum) 
--	AND HostName = @HostName) 
BEGIN 
        Execute PRTRaiseError 'PRT_ERR_Cannot_Connect',@DBStatus OUT 
	SELECT @FailureReason = 'Cannot connect cabinet' 
	SELECT @lActionId =101  	--added by shubham
	GOTO ErrHnd 
     	Return 
END 

SELECT @lEnableLogin = AllowCrossApplicationLogin FROM PDBCABINET
	IF(RTRIM(UPPER(@UserName))<> 'SUPERVISOR' AND RTRIM(UPPER(@UserName))<> 'SUPERVISOR2') 
	BEGIN
		IF 	@ProductName IS NOT NULL
		BEGIN
			--SELECT @lAppIndex= ApplicationIndex FROM PDBApplicationLicenseDetails WHERE ApplicationName=@ProductName;
			SELECT @lAssociationExist = COUNT(*) FROM PDBUserApplicationMapping where applicationIndex=@lAppIndex and userIndex=@UserIndex
			
			IF (@lAssociationExist <>1)
			BEGIN
				
				SELECT @FailureReason= 'User is not associated with the application'
				SELECT @lActionId =696
				SELECT @Comment='Failure-' + RTRIM(@UserName)+ '-' + RTRIM(@FailureReason)
				
				EXECUTE PRTGenerateConnectionLog @UserIndex,null,@lActionId,@UserIndex,'U', NULL, NULL, @MainGroupId,NULL,NULL,'C',@Comment,-1,NULL,NULL, @ApplicationInfo,null,@lAppIndex,@ProductName,@lUserType
				
				SELECT @lAssociationExist = COUNT(*) FROM PDBUserApplicationMapping where userIndex=@UserIndex
				IF(@lAssociationExist=0)
				BEGIN
					Select @DefaultApplication = ApplicationName from PDBApplicationLicenseDetails where defaultApplication='Y'
					IF(@DefaultApplication <> @ProductName)
					BEGIN
						IF (@lEnableLogin='N')
						BEGIN
							SELECT @DBFailureAttemptCount=FailureAttemptCount 
							FROM UserSecurity WITH (NOLOCK)
							WHERE UserIndex=@UserIndex 
				
							UPDATE 	UserSecurity Set LastLoginFaliureTime=@TempDate, LoggedInAttempts = LoggedInAttempts + 1 ,
							FailureAttemptCount =@DBFailureAttemptCount + 1 
							WHERE UserIndex=@UserIndex 
					
							Select @LeftAttempts = (@LoggedinAttemptCount - 1) - @LoggedInAttempts 
					
							EXECUTE PRTRaiseError 'PRT_ERR_User_App_Assoc_Mismatch', @DBStatus OUT 
							Return
						END
					END
					
				END
				ELSE
				BEGIN
						IF (@lEnableLogin='N')
						BEGIN
							SELECT @DBFailureAttemptCount=FailureAttemptCount 
							FROM UserSecurity WITH (NOLOCK)
							WHERE UserIndex=@UserIndex 
				
							UPDATE 	UserSecurity Set LastLoginFaliureTime=@TempDate, LoggedInAttempts = LoggedInAttempts + 1 ,
							FailureAttemptCount =@DBFailureAttemptCount + 1 
							WHERE UserIndex=@UserIndex 
					
							Select @LeftAttempts = (@LoggedinAttemptCount - 1) - @LoggedInAttempts 
					
							EXECUTE PRTRaiseError 'PRT_ERR_User_App_Assoc_Mismatch', @DBStatus OUT 
							Return
						END
				END
			END	
		END	
	END	 
------------------------------------------------------------------------------------------------ 
-- Changed By				: Mili Das 
-- Reason / Cause (Bug No if Any)	: Support for Portal Users 
-- Change Description			: Support for Portal Users 
------------------------------------------------------------------------------------------------ 
	/*Check if user is already logged in */ 
	IF @UserExistsFlag IS NOT NULL AND @lUserType <> 'S' 
	BEGIN 
		SELECT @lExistsFlag = 1, @lApplicationInfo = ApplicationInfo, @lApplicationName = ApplicationName 
		FROM PDBConnection  WITH (NOLOCK) 
		WHERE UserIndex = @UserIndex  
		AND UserType = @lUserType AND ProductName =@ProductName
 
		IF (@lExistsFlag = 1)  
		BEGIN 
			IF @UserExistsFlag = 'Y' 
			BEGIN 
	                	EXECUTE PRTRaiseError 'PRT_ERR_User_Already_Logged_In', @DBStatus OUT 
				SELECT @FailureReason = 'User is already logged in' 
				SELECT @lActionId =101  	--added by shubham
				--GOTO ErrHnd 
				SELECT @Comment='Failure-' + RTRIM(@UserName)+ '-'+ RTRIM(@FailureReason)
				EXECUTE PRTGenerateConnectionLog @UserIndex,null,@lActionId,@UserIndex,'U', NULL, NULL, @MainGroupId,NULL,NULL,'C',@Comment,-1,NULL,NULL,@lApplicationInfo,null,@lAppIndex,@ProductName,@lUserType
	            RETURN 
			END 
			ELSE 
			BEGIN 
				DELETE FROM PDBConnection 
				WHERE UserIndex = @UserIndex 
				AND UserType = @lUserType AND ProductName =@ProductName
				SELECT @DBStatus = @@ERROR 
				IF (@DBStatus <> 0) 
				BEGIN 
					RETURN 
				END 
 
------------------------------------------------------------------------------------------- 
-- Changed By				: Swati Gupta 
-- Reason / Cause (Bug No if Any)	: Changes for Audit Log Enhancement(IP Address) 
-- Change Description			: Changes for Audit Log Enhancement(IP Address) 
------------------------------------------------------------------------------------------- 
				EXECUTE PRTGenerateConnectionLog @UserIndex, NULL, 102, @UserIndex, 'U', NULL, NULL, @MainGroupId,NULL,NULL,'C','ForceFul-LogOut',-1,NULL,NULL, @lApplicationInfo , @lApplicationName ,@lAppIndex,@ProductName,@lUserType
------------------------------------------------------------------------------------------- 
-- Changed By				: Utkarsh Yadav 
-- Reason / Cause (Bug No if Any)	: Changes for Unlocking folder locked by OmniProcess 
-- Change Description			: Changes for Unlocking folder locked by OmniProcess
------------------------------------------------------------------------------------------- 
				DECLARE folder_cursor CURSOR FOR
				SELECT FolderIndex
				FROM PDBFolder
				WHERE folderlock = 'Y'
				AND lockmessage = 'OmniProcess'
				AND CAST(SUBSTRING([lockbyuser],0, CHARINDEX('#', [lockbyuser])) AS INTEGER) = @UserIndex

				OPEN folder_cursor;

				FETCH NEXT FROM folder_cursor INTO @folderIndex;

				WHILE @@FETCH_STATUS = 0
				BEGIN
					UPDATE PDBFolder SET folderlock = 'N', lockmessage = NULL, lockbyuser= NULL
					WHERE FolderIndex= @folderIndex;
				  FETCH NEXT FROM folder_cursor INTO @folderIndex;
				END

				CLOSE folder_cursor;
				DEALLOCATE folder_cursor;

			END 
		END 
	END 
 
/* 
	Changed By			: Sanjay 
	Reason / Cause (Bug No if Any)	: Checking for max no of login users 
	Change Description		: Checking for max no of login users 
*/ 
 
/* 
	Changed By			: Abhijeet 
	Reason / Cause (Bug No if Any)	: Change for Fixed login users 
	Change Description		: Change for Fixed login users 
*/ 
 
 
/*	IF NOT EXISTS(SELECT 1 FROM PDBUserLicenseInfo WHERE UserIndex = @UserIndex AND UserType = 'F') 
			SELECT @EscapeConcurrenyCheck = 0 
		ELSE 
			SELECT @EscapeConcurrenyCheck = 1 
*/ 
	
SELECT @EscapeConcurrenyCheck = 0 
 
IF @lUserType = 'F' 
	SELECT @EscapeConcurrenyCheck = 1 
 
------------------------------------------------------------------------------------------------ 
-- Changed By				: Sneh Lata Sharma 
-- Reason / Cause (Bug No if Any)	: Implementation of S type User License 
-- Change Description			: Implementation of S type User License 
------------------------------------------------------------------------------------------------ 
------------------------------------------------------------------------------------------------ 
-- Changed By				: Mili Das 
-- Reason / Cause (Bug No if Any)	: Fixed + Stype were getting no limit on connection 
-- Change Description			: Check for Stype maximum users even for Fixed users. 
------------------------------------------------------------------------------------------------ 
	/*Check if max login user count reached */ 
	IF @EscapeConcurrenyCheck = 0 
		BEGIN 
---------------------------------------------------------------------------------------------------------- 
-- Changed By				: Bharat Pardeshi 
-- Reason / Cause (Bug No if Any)	: Separating concurrent and fix user login check 
-- Change Description			: Separating concurrent and fix user login check 
---------------------------------------------------------------------------------------------------------- 
--			IF ((Select Count(*) from PDBConnection Where UserType = 'U') >= @MaxNoOfLoginUsers) 
------------------------------------------------------------------------------------------------ 
-- Changed By				: Mili Das 
-- Reason / Cause (Bug No if Any)	: Support for Portal Users 
-- Change Description			: Support for Portal Users  
------------------------------------------------------------------------------------------------ 
------------------------------------------------------------------------------------------------ 
-- Changed By				: Atul Khemka 
-- Reason / Cause (Bug No if Any)	: Changes done to support Maximum concurrency condition 
-- Change Description			: Changes done to support Maximum concurrency condition  
------------------------------------------------------------------------------------------------ 
			SELECT @sfid = 0 
			SELECT @sfid=SetForUserId,@sfun=SetForUserName from pdbalarm WITH (NOLOCK) where actiontype=21 
			IF ( @sfid = 0 ) 
			BEGIN 
				SELECT @sfid = 2 
				SELECT @sfun = 'Supervisor2' 
			END 
 
			--IF @DBFlexibilityCount = 0 
				--SELECT @DBFlexibilityCount = 10 by shubham
				 
			IF @lUserType = 'I' 
			BEGIN 
				SELECT @UserLoginCount = Count(*) from PDBConnection WITH (NOLOCK) Where UserType = 'I' and productName=@ProductName
				SELECT @InternalPortalLoginCount = ConncurrentNoOfIntPortalUsers from PDBApplicationLicenseDetails WITH (NOLOCK) where applicationName=@ProductName
				SELECT @CabinetInternalPortalLoginCount= SUM(ConncurrentNoOfIntPortalUsers) from PDBApplicationLicenseDetails WITH (NOLOCK)

				SELECT @DBFlexibilityCount = (@InternalPortalLoginCount * @DBFlexibilityCount)/100 
				/*IF (@DBFlexibilityCount < 1)  
				BEGIN 
					SELECT @DBFlexibilityCount = 1 
				END */
				IF @InternalPortalLoginCount > 0 
					SELECT @loginPercent = ((@UserLoginCount+1)*100)/@InternalPortalLoginCount 
				ELSE 
					SELECT @loginPercent = 100 
				IF (@UserLoginCount < @InternalPortalLoginCount) 
				BEGIN  
					IF(@loginPercent >= 90) 
					BEGIN 
						SELECT @DBWarnFlag2 = 'Y' 
					END 
				END 
				IF (@UserLoginCount >= @InternalPortalLoginCount) 
				BEGIN 
					IF (@UserLoginCount >= (@InternalPortalLoginCount + @DBFlexibilityCount)) 
					BEGIN 
					
						SELECT @FailureReason = 'Maximum login limit of internal portal users exceeded' 
						SELECT @lActionId =681 	--added by shubham
						INSERT INTO PDBConnectionHistory (UserIndex, UserName, UserType, LoginTime, ConnectionAllowed, NoOfConcurrentUsers) 
						VALUES(@UserIndex, @UserName, @lUserType, @DBDate, 'N', @UserLoginCount ) 
						
						SELECT @Comment='Failure-' + RTRIM(@UserName)+ '-' + RTRIM(@FailureReason)
						
						EXECUTE PRTGenerateConnectionLog @UserIndex,null,@lActionId,@UserIndex,'U', NULL, NULL, @MainGroupId,NULL,NULL,'C',@Comment,-1,NULL,NULL, @lApplicationInfo,null,@lAppIndex,@ProductName,@lUserType 
						IF (@lEnableLogin='Y')
						BEGIN
							SELECT @UserLoginCount = Count(*) from PDBConnection WITH (NOLOCK) Where UserType = 'I' 
							
							IF (@UserLoginCount >= @CabinetInternalPortalLoginCount) 
							BEGIN
								EXECUTE PRTRaiseError 'PRT_ERR_Max_Login_User_Count_Reached', @DBStatus OUT 
								SELECT @FailureReason = 'Concurrency limit of internal portal users exceeded for the cabinet' 
								SELECT @lActionId =697
								GOTO ErrHnd 
								RETURN
								
							END
						END
						ELSE
						BEGIN
							SELECT @DBFailureAttemptCount=FailureAttemptCount 
							FROM UserSecurity WITH (NOLOCK)
							WHERE UserIndex=@UserIndex 
				
							UPDATE 	UserSecurity Set LastLoginFaliureTime=@TempDate, LoggedInAttempts = LoggedInAttempts + 1 ,
							FailureAttemptCount =@DBFailureAttemptCount + 1 
							WHERE UserIndex=@UserIndex 
							
							Select @LeftAttempts = (@LoggedinAttemptCount - 1) - @LoggedInAttempts 
							
							EXECUTE PRTRaiseError 'PRT_ERR_Max_Login_User_Count_Reached', @DBStatus OUT 
							RETURN 
						END
					END 
					ELSE  
					BEGIN
						SELECT @DBWarnFlag = 'Y' 
					END		
				END 
			END 
			ELSE IF @lUserType = 'E' 
			BEGIN 
				SELECT @UserLoginCount = Count(*) from PDBConnection WITH (NOLOCK) Where UserType = 'E'  and productName=@ProductName
				SELECT @ExternalPortalLoginCount =  ConncurrentNoOfExtPortalUsers from PDBApplicationLicenseDetails WITH (NOLOCK) where applicationName=@ProductName
				SELECT @CabinetExternalPortalLoginCount= SUM(ConncurrentNoOfExtPortalUsers) from PDBApplicationLicenseDetails WITH (NOLOCK)
				
				SELECT @DBFlexibilityCount = (@ExternalPortalLoginCount * @DBFlexibilityCount)/100 
				/*IF (@DBFlexibilityCount < 1)  
				BEGIN 
					SELECT @DBFlexibilityCount = 1 
				END */
				IF @ExternalPortalLoginCount > 0 
					SELECT @loginPercent = ((@UserLoginCount+1)*100)/@ExternalPortalLoginCount 
				ELSE 
					SELECT @loginPercent = 100 
				IF (@UserLoginCount < @ExternalPortalLoginCount) 
				BEGIN  
					IF(@loginPercent >= 90) 
					BEGIN 
						SELECT @DBWarnFlag2 = 'Y' 
					END 
				END 
				IF (@UserLoginCount >= @ExternalPortalLoginCount) 
				BEGIN 
					IF (@UserLoginCount >= (@ExternalPortalLoginCount + @DBFlexibilityCount)) 
					BEGIN 
						
						SELECT @FailureReason = 'Maximum login limit of external portal users exceeded' 
						SELECT @lActionId =682 	--added by shubham
						INSERT INTO PDBConnectionHistory (UserIndex, UserName, UserType, LoginTime, ConnectionAllowed, NoOfConcurrentUsers) 
						VALUES(@UserIndex, @UserName, @lUserType, @DBDate, 'N', @UserLoginCount ) 
						
						SELECT @Comment='Failure-' + RTRIM(@UserName)+ '-' + RTRIM(@FailureReason)
						
						EXECUTE PRTGenerateConnectionlog @UserIndex,null,@lActionId,@UserIndex,'U', NULL, NULL, @MainGroupId,NULL,NULL,'C',@Comment,-1,NULL,NULL, @lApplicationInfo,null,@lAppIndex,@ProductName,@lUserType 
						
						IF (@lEnableLogin='Y')
						BEGIN
							SELECT @UserLoginCount = Count(*) from PDBConnection WITH (NOLOCK) Where UserType = 'E' 
							IF (@UserLoginCount >= @CabinetExternalPortalLoginCount) 
							BEGIN
								EXECUTE PRTRaiseError 'PRT_ERR_Max_Login_User_Count_Reached', @DBStatus OUT 
								SELECT @FailureReason = 'Concurrency limit of external portal users exceeded for the cabinet' 
								SELECT @lActionId =697
								GOTO ErrHnd 
								RETURN
								
							END
						END
						ELSE
						BEGIN
							SELECT @DBFailureAttemptCount=FailureAttemptCount 
							FROM UserSecurity WITH (NOLOCK)
							WHERE UserIndex=@UserIndex 
				
							UPDATE 	UserSecurity Set LastLoginFaliureTime=@TempDate, LoggedInAttempts = LoggedInAttempts + 1 ,
							FailureAttemptCount =@DBFailureAttemptCount + 1 
							WHERE UserIndex=@UserIndex 
							
							Select @LeftAttempts = (@LoggedinAttemptCount - 1) - @LoggedInAttempts 
							
							EXECUTE PRTRaiseError 'PRT_ERR_Max_Login_User_Count_Reached', @DBStatus OUT 
							RETURN 
						END
					END 
					ELSE 
					BEGIN
						SELECT @DBWarnFlag = 'Y' 
					END		
				END 
			END 
			ELSE IF @lUserType = 'S' 
			BEGIN 
				SELECT @UserLoginCount = Count(*) from PDBConnection WITH (NOLOCK) Where UserType = 'S' and productName=@ProductName
				SELECT @MaxSUsers = ConcurrentNoOfSTypeUsers, @DefaultSystemUsers = DefaultSTypeUsers from PDBApplicationLicenseDetails WITH (NOLOCK) where applicationName=@ProductName
				SELECT @CabinetSystemUsers= SUM(ConcurrentNoOfSTypeUsers) + SUM(DefaultSTypeUsers) from PDBApplicationLicenseDetails WITH (NOLOCK)
				SELECT @DBFlexibilityCount = ((@MaxSUsers + @DefaultSystemUsers) * @DBFlexibilityCount)/100 
				/*IF (@DBFlexibilityCount < 1)  
				BEGIN 
					SELECT @DBFlexibilityCount = 1 
				END */
				IF (@MaxSUsers + @DefaultSystemUsers) > 0 
					SELECT @loginPercent = ((@UserLoginCount+1)*100)/(@MaxSUsers + @DefaultSystemUsers) 
				ELSE 
					SELECT @loginPercent = 100 
				IF (@UserLoginCount < (@MaxSUsers + @DefaultSystemUsers)) 
				BEGIN  
					IF(@loginPercent >= 90) 
					BEGIN 
						SELECT @DBWarnFlag2 = 'Y' 
					END 
				END 
				IF (@UserLoginCount >= (@DefaultSystemUsers + @MaxSUsers)) 
				BEGIN 
					IF (@UserLoginCount >= (@DefaultSystemUsers + @MaxSUsers + @DBFlexibilityCount)) 
					BEGIN 
						
						SELECT @FailureReason = 'Maximum login limit of service users exceeded' 
						SELECT @lActionId =683 	--added by shubham
						INSERT INTO PDBConnectionHistory (UserIndex, UserName, UserType, LoginTime, ConnectionAllowed, NoOfConcurrentUsers) 
						VALUES(@UserIndex, @UserName, @lUserType, @DBDate, 'N', @UserLoginCount ) 
						SELECT @Comment='Failure-' + RTRIM(@UserName)+ '-'+ RTRIM(@FailureReason)
						
						EXECUTE PRTGenerateConnectionlog @UserIndex,null,@lActionId,@UserIndex,'U', NULL, NULL, @MainGroupId,NULL,NULL,'C',@Comment,-1,NULL,NULL, @lApplicationInfo,null,@lAppIndex,@ProductName,@lUserType 
						
						IF (@lEnableLogin='Y')
						BEGIN
							
							SELECT @UserLoginCount = Count(*) from PDBConnection WITH (NOLOCK) Where UserType = 'S'							
							IF (@UserLoginCount >= @CabinetSystemUsers) 
							BEGIN
								EXECUTE PRTRaiseError 'PRT_ERR_Max_Login_User_Count_Reached', @DBStatus OUT 
								SELECT @FailureReason = 'Concurrency limit of service users exceeded for the cabinet' 
								SELECT @lActionId =697
								GOTO ErrHnd 
								RETURN
								
							END
						END
						ELSE
						BEGIN
							SELECT @DBFailureAttemptCount=FailureAttemptCount 
							FROM UserSecurity WITH (NOLOCK)
							WHERE UserIndex=@UserIndex 
				
							UPDATE 	UserSecurity Set LastLoginFaliureTime=@TempDate, LoggedInAttempts = LoggedInAttempts + 1 ,
							FailureAttemptCount =@DBFailureAttemptCount + 1 
							WHERE UserIndex=@UserIndex 
							
							Select @LeftAttempts = (@LoggedinAttemptCount - 1) - @LoggedInAttempts 
							
							EXECUTE PRTRaiseError 'PRT_ERR_Max_Login_User_Count_Reached', @DBStatus OUT 
							RETURN 
						END
					END 
					ELSE 
					BEGIN
						SELECT @DBWarnFlag = 'Y' 
					END		
				END 
			END 
			ELSE 
			BEGIN 
				SELECT @UserLoginCount = Count(*) from PDBConnection WITH (NOLOCK) Where UserType = 'U' and productName=@ProductName
				SELECT @MaxNoOfLoginUsers = ConcurrentNoOfUTypeUsers from PDBApplicationLicenseDetails WITH (NOLOCK) where applicationName=@ProductName
				SELECT @CabinetNormalUsers = SUM(ConcurrentNoOfUTypeUsers) from PDBApplicationLicenseDetails WITH (NOLOCK)
				SELECT @DBFlexibilityCount = (@MaxNoOfLoginUsers * @DBFlexibilityCount)/100 
				/*IF (@DBFlexibilityCount < 1)  
				BEGIN 
					SELECT @DBFlexibilityCount = 1 
				END */
				IF @MaxNoOfLoginUsers > 0 
					SELECT @loginPercent = ((@UserLoginCount+1)*100)/@MaxNoOfLoginUsers 
				ELSE 
					SELECT @loginPercent = 100 
				IF (@UserLoginCount < @MaxNoOfLoginUsers) 
				BEGIN  
					IF(@loginPercent >= 90) 
					BEGIN 
						SELECT @DBWarnFlag2 = 'Y' 
					END 
				END 
				IF (@UserLoginCount >= (@MaxNoOfLoginUsers)) 
				BEGIN 
					IF (@UserLoginCount >= (@MaxNoOfLoginUsers + @DBFlexibilityCount)) 
					BEGIN 
							
						SELECT @FailureReason = 'Maximum login limit of normal users exceeded' 
						SELECT @lActionId =684  	--added by shubham
						INSERT INTO PDBConnectionHistory (UserIndex, UserName, UserType, LoginTime, ConnectionAllowed, NoOfConcurrentUsers) 
						VALUES(@UserIndex, @UserName, @lUserType, @DBDate, 'N', @UserLoginCount ) 
						
						SELECT @Comment='Failure-' + RTRIM(@UserName)+ '-'+ RTRIM(@FailureReason)
						
						EXECUTE PRTGenerateConnectionlog @UserIndex,null,@lActionId,@UserIndex,'U', NULL, NULL, @MainGroupId,NULL,NULL,'C',@Comment,-1,NULL,NULL, @lApplicationInfo,null,@lAppIndex,@ProductName,@lUserType 
						
						IF (@lEnableLogin='Y')
						BEGIN
							SELECT @UserLoginCount = Count(*) from PDBConnection WITH (NOLOCK) Where UserType = 'U'
							
							IF (@UserLoginCount >= @CabinetNormalUsers) 
							BEGIN
								
								EXECUTE PRTRaiseError 'PRT_ERR_Max_Login_User_Count_Reached', @DBStatus OUT 
								SELECT @FailureReason = 'Concurrency limit of normal users exceeded for the cabinet' 
								SELECT @lActionId =697
								GOTO ErrHnd 
								RETURN
								
							END
						END
						ELSE
						BEGIN
							SELECT @DBFailureAttemptCount=FailureAttemptCount 
							FROM UserSecurity WITH (NOLOCK)
							WHERE UserIndex=@UserIndex 
				
							UPDATE 	UserSecurity Set LastLoginFaliureTime=@TempDate, LoggedInAttempts = LoggedInAttempts + 1 ,
							FailureAttemptCount =@DBFailureAttemptCount + 1 
							WHERE UserIndex=@UserIndex 
							
							Select @LeftAttempts = (@LoggedinAttemptCount - 1) - @LoggedInAttempts 
							
							EXECUTE PRTRaiseError 'PRT_ERR_Max_Login_User_Count_Reached', @DBStatus OUT 
							RETURN 
						END
					END 
					ELSE 
					BEGIN
						SELECT @DBWarnFlag = 'Y' 
					END		
				END 
			END 
		END 
 
------------------------------------------------------------------------------------------------ 
-- Changed By				: Sneh Lata Sharma 
-- Reason / Cause (Bug No if Any)	: Changes for forceful password change on Password Expiry 
-- Change Description			: Changes for forceful password change on Password Expiry 
------------------------------------------------------------------------------------------------ 
------------------------------------------------------------------------------------------------ 
-- Changed By				: Sneh Lata Sharma 
-- Reason / Cause (Bug No if Any)	: Changes for warning before Password Expiry 
-- Change Description			: Changes for warning before Password Expiry 
------------------------------------------------------------------------------------------------ 
SELECT @RemExpiryDays = DATEDIFF (dd , @TempDate , @PasswordExpiryTime) 
 
If(@PasswordExpiryFlag = 'N') AND (@RemExpiryDays >= 0 AND @RemExpiryDays < @DBPasswdWarnTime) 
BEGIN 
	SELECT @RemExpiryDays = @RemExpiryDays + 1 
----------------------------------------------------------------------------------------------------- 
-- Changed By						: Neeraj Kumar 
-- Reason / Cause (Bug No if Any)   : set PasswdExpiryMailFlag to allow mail sendig on expiration of password.(Bug 2049) 
-- Change Description				: set PasswdExpiryMailFlag to allow mail sendig on expiration of password.(Bug 2049) 
-----------------------------------------------------------------------------------------------------	 
	IF(@PasswdExpMailFlag = 'Y') 
	BEGIN	 
		SELECT @Comment = @UserName + '''s Password will expire after ' + convert(varchar(20),@RemExpiryDays) + ' days.'; 
		INSERT INTO PDBReminder(UserIndex,ObjectIndex,ObjectType,ObjectName,RemDateTime,Comment,SetByUser,InformMode, ReminderType, MailFlag, FaxFlag) 
		VALUES(@UserIndex,0,'D',null,@DBDate,@Comment,1,'M','U','Y','N') 
	END 
END 
ELSE 
	SELECT @RemExpiryDays = null 
 
If(@PasswordExpiryFlag = 'N') AND (@TempDate > @PasswordExpiryTime) 
BEGIN 
	Select @PasswordExpiryFlag = 'Y' 
	EXECUTE PRTRaiseError 'PRT_ERR_User_Password_Expired',@DBStatus OUT 
	Select @LeftAttempts = (@LoggedinAttemptCount - 1) - @LoggedInAttempts 
	IF @LeftAttempts = 0 
	Begin 
		Update UserSecurity Set UserLocked = 'Y', LockedTime = @DBDate 
		Where UserIndex = @UserIndex 
		
	End
 
	Update 	UserSecurity Set LoggedInAttempts = LoggedInAttempts + 1 
	Where UserIndex = @UserIndex 
	SELECT @FailureReason = 'Password has expired' 
	SELECT @lActionId =685 	--added by shubham
	GOTO ErrHnd 
	Return 
END 
else 
	Select @PasswordExpiryFlag = 'N' 
 
------------------------------------------------------------------------------------------------ 
-- Changed By				: Sneh Lata Sharma 
-- Reason / Cause (Bug No if Any)	: Changes for Application Name Support 
-- Change Description			: Two new columns added in PDBConnection 
------------------------------------------------------------------------------------------------ 
/* Register the random number for the user */ 
	IF(EXISTS(SELECT * FROM PDBGroup A,PDBGroupMember B WITH (NOLOCK) WHERE A.GroupName = 'Second Factor Immune' and A.GroupIndex = B.GroupIndex and B.UserIndex = @UserIndex))
		BEGIN
			SELECT @lExistsImmuneGroup = 1
		END	
		
	IF(@lTwoFactorAuthenticationFlag = 'Y') 
	BEGIN
		IF (@lExistsImmuneGroup = 0 AND @lTwoFactorClass IS NOT NULL)
		BEGIN
			IF(@OtpValidationFlag = 'Y') 
			BEGIN
				INSERT INTO PDBConnection(RandomNumber,UserIndex,HostName,UserLoginTime,MainGroupId,UserType,AccessDateTime,StatusFlag, Locale, ApplicationName, ApplicationInfo,ProductName)  
				VALUES (@RandomNum, @UserIndex, @HostName, @DBDate,@MainGroupId,@lUserType,@DBDate,'Y', @Locale, @ApplicationName, @ApplicationInfo,@ProductName) 
			END
		END
		ELSE
			IF(@lExistsImmuneGroup = 1)
			INSERT INTO PDBConnection(RandomNumber,UserIndex,HostName,UserLoginTime,MainGroupId,UserType,AccessDateTime,StatusFlag, Locale, ApplicationName, ApplicationInfo,ProductName)  
			VALUES (@RandomNum, @UserIndex, @HostName, @DBDate,@MainGroupId,@lUserType,@DBDate,'Y', @Locale, @ApplicationName, @ApplicationInfo,@ProductName)		
	END
	ELSE
	INSERT INTO PDBConnection(RandomNumber,UserIndex,HostName,UserLoginTime,MainGroupId,UserType,AccessDateTime,StatusFlag, Locale, ApplicationName, ApplicationInfo,ProductName)  
				VALUES (@RandomNum, @UserIndex, @HostName, @DBDate,@MainGroupId,@lUserType,@DBDate,'Y', @Locale, @ApplicationName, @ApplicationInfo,@ProductName) 
------------------------------------------------------------------------------------------------ 
-- Changed By				: Ravinder Partap
-- Reason / Cause (Bug No if Any)	: Changes for Access Log Capturing 
-- Change Description			: Changes for Access Log Capturing 
------------------------------------------------------------------------------------------------ 
IF @GenerateAccessReport = 'Y'
BEGIN
	INSERT INTO PDBAccessLog(UserIndex,RandomNumber ,UserType ,AccessDateTimeIn,AccessDateTimeOut,ArchiveFlag) 
	VALUES(@UserIndex,@RandomNum,@lUserType,@TempDate,@TempDate,'N')
END	
--End Changed by Ravinder Partap

SELECT @DBStatus = @@ERROR 
IF (@DBStatus <> 0) 
     	Return 
 
IF @LockBy > 0 
	SELECT @LockByUser = UserName FROM PDBUser WITH (NOLOCK) WHERE UserIndex = @LockBy 
ELSE 
	SELECT @LockByUser = NULL 
 
--Generate Alarm For Expired Documents 
--IF (SELECT ROWS FROM SYSINDEXES i WHERE i.indid < 2 
--	AND i.id = (SELECT id FROM SYSOBJECTS WHERE name = 'PDBALARM')) 
--	> 0 
--BEGIN 
------------------------------------------------------------------------------------------------ 
-- Changed By				: Mili Das 
-- Reason / Cause (Bug No if Any)	: Changes for optimization 
-- Change Description			: Changes for optimization 
------------------------------------------------------------------------------------------------ 
	/* 
	DECLARE	@ActionType		smallint 
	DECLARE @AlarmIndex		int 
	DECLARE	@AlarmRowCount		int 
	DECLARE	@AlarmDocumentIndex	int 
	SELECT 	@ActionType	= 5 
 
	SELECT TOP 1 	@AlarmIndex	= AlarmIndex, 
			@AlarmDocumentIndex = ObjectId 
	FROM		PDBAlarm 
	WHERE ActionType = @ActionType 
	ORDER BY AlarmIndex 
	SELECT @AlarmRowCount = @@ROWCOUNT 
	WHILE @AlarmRowCount > 0 
	BEGIN 
		IF EXISTS( 
			SELECT 1 FROM PDBDocument WHERE DocumentIndex = @AlarmDocumentIndex AND ExpiryDateTime < @TempDate) 
		BEGIN 
			UPDATE PDBALARM 
			SET AlarmGenerated = 'Y' 
			WHERE AlarmIndex = @AlarmIndex 
		END 
		SELECT TOP 1 	@AlarmIndex	= AlarmIndex, 
				@AlarmDocumentIndex = ObjectId 
		FROM		PDBAlarm 
		WHERE AlarmIndex > @AlarmIndex 
		AND	ActionType = @ActionType 
		ORDER BY AlarmIndex 
		SELECT @AlarmRowCount = @@ROWCOUNT 
	END 
*/ 
/* 
UPDATE PDBALARM 
SET AlarmGenerated = 'Y' 
WHERE ActionType = 5 
AND ObjectId IN ( 
SELECT DocumentIndex FROM PDBDocument a,PDBAlarm b 
WHERE ActionType = 5 
AND b.ObjectId = a.DocumentIndex 
AND a.ExpiryDateTime < @TempDate) 
*/ 
--END 
SELECT @Privilege = ' ' 
select @DBStatus = @@error 
if @DBStatus <> 0 
	return 
------------------------------------------------------------------------------------------------ 
-- Changed By				: Mili Das 
-- Reason / Cause (Bug No if Any)	: To set the HasLoginFlag to 'Y' on successful login 
-- Change Description			: To set the HasLoginFlag to 'Y' on successful login 
------------------------------------------------------------------------------------------------ 
IF @HasLoginBefore = 'N' OR @HasLoginBefore = NULL 
 
UPDATE 	UserSecurity Set HasLoginBefore='Y' 
WHERE UserIndex=@UserIndex 
 
------------------------------------------------------------------------------------------------ 
-- Changed By				: Mili Das 
-- Reason / Cause (Bug No if Any)	: To get the details of last unsuccessful login 
-- Change Description			: To get the details of last unsuccessful login 
------------------------------------------------------------------------------------------------ 
SELECT @DBLastLoginFaliureTime=LastLoginFaliureTime,@DBFailureAttemptCount=FailureAttemptCount 
FROM UserSecurity WITH (NOLOCK)
WHERE UserIndex=@UserIndex 
 
UPDATE 	UserSecurity Set LastLoginFaliureTime=NULL , FailureAttemptCount = 0 
WHERE UserIndex=@UserIndex 
 
------------------------------------------------------------------------------------------------ 
-- Changed By				: Mili Das 
-- Reason / Cause (Bug No if Any)	: Date and Time of the last successful login should be reported to the user 
-- Change Description			: Date and Time of the last successful login should be reported to the user 
------------------------------------------------------------------------------------------------ 
 
UPDATE 	UserSecurity Set LastLoginTime=@TempDate 
Where UserIndex = @UserIndex 
 
------------------------------------------------------------------------------------------------ 
-- Changed By						: Vikas Dubey 
-- Reason / Cause (Bug No if Any)	: ERC180 
-- Change Description				: Changes done to support dormant users expiry warning time 
------------------------------------------------------------------------------------------------ 
SELECT  @DormantWarnTime 		= DormantWarnTime, 
		@DormantWarnTimeFlag	= DormantWarnTimeFlag  
FROM PDBUserConfig	WITH (NOLOCK)	 
 
IF (@DBLoginPeriod > 0 AND @DormantWarnTimeFlag = 'Y') 
BEGIN	 
	IF NOT EXISTS(SELECT * FROM PDBReminder WITH (NOLOCK)
	WHERE UserIndex = @UserIndex 
	AND Comment = 'Reminder_Dormant_User') 
	BEGIN 
		INSERT INTO PDBReminder(UserIndex,ObjectIndex,ObjectName,RemDateTime,Comment,SetByUser, 
					InformMode, ReminderType, MailFlag, FaxFlag,ObjectType) 
		VALUES (@UserIndex, 0, 'D',@DBDate + @DBLoginPeriod - @DormantWarnTime, 'Reminder_Dormant_User', 1,  
			'M', 'M', 'N','N','D') 
	END 
	ELSE 
	BEGIN 
		UPDATE 	PDBReminder SET RemDateTime = @DBDate + @DBLoginPeriod - @DormantWarnTime 
		WHERE UserIndex = @UserIndex AND Comment = 'Reminder_Dormant_User' 
	END 
END 
 
Update 	UserSecurity Set LoggedInAttempts = 0, 
			LockedTime = NULL, 
			UserLocked = 'N' 
Where UserIndex = @UserIndex 
 
SELECT @Comment='Success-' + RTRIM(@UserName) 
 
------------------------------------------------------------------------------------------------ 
-- Changed By				: Vipin Kumar Singla 
-- Reason / Cause (Bug No if Any)	: Support for Portal Users 
-- Change Description			: Support for Portal Users 
------------------------------------------------------------------------------------------------ 
--IF (@lUserType <> 'S') 
	 EXECUTE PRTGenerateConnectionlog @UserIndex, NULL, 101, @UserIndex, 'U', @UserName, NULL,@MainGroupId,NULL,NULL,'C',@Comment,-1,NULL,NULL, @lApplicationInfo , @ApplicationName,@lAppIndex,@ProductName,@lUserType
 
IF @IsAdmin = 'Y' 
BEGIN 
	SELECT @Privilege = '1111111111111111' 
END 
ELSE 
BEGIN 
	SELECT 	@ctr = 1 
	WHILE @ctr < 17 
	BEGIN 
		IF SUBSTRING(@UserPrivilegeControlList, @ctr, 1) = '1' 
			SELECT @Privilege = rtrim(@Privilege) + '1' 
		ELSE 
		BEGIN 
	 		IF EXISTS (SELECT 1 
				FROM PDBGroup A WITH (NOLOCK), PDBGroupMember C WITH (NOLOCK) 
				WHERE 	C.groupindex = A.groupindex 
				AND 	C.userindex = @UserIndex 
				AND  	SUBSTRING(A.PrivilegeControlList,@ctr,1) = '1' 
			) 
			BEGIN
					SELECT @Privilege = rtrim(@Privilege) + '1'		
			END
			ELSE
			BEGIN 
			IF EXISTS (SELECT 1 
					FROM PDBROLEGROUP A WITH (NOLOCK)
					WHERE  GROUPINDEX IN
					(SELECT GROUPINDEX FROM PDBGROUPMEMBER WITH (NOLOCK) WHERE USERINDEX = @UserIndex)
					AND RoleIndex IN (SELECT RoleIndex FROM PDBGroupRoles WITH (NOLOCK) WHERE USERINDEX = @UserIndex)
					AND SUBSTRING(A.PrivilegeControlList,@ctr,1) = '1')
				BEGIN
				SELECT @Privilege = rtrim(@Privilege) + '1' 
				END
			
			ELSE
				BEGIN
					SELECT @Privilege = rtrim(@Privilege) + '0' 
				END
			END
		END 
 
		SELECT @ctr = @ctr + 1 
		END
	END 
 
SELECT @DBStatus 
/* Return root folder also */ 
SELECT FolderIndex,ParentFolderIndex,Name,Owner,CreatedDatetime,RevisedDateTime, 
	AccessedDateTime,DataDefinitionIndex,AccessType,ImageVolumeIndex,FolderType, 
	FolderLock,LockByUser,Location,DeletedDateTime,EnableVersion,ExpiryDateTime, 
	Comment,UseFulData,ACL,FinalizedFlag,FinalizedDateTime,FinalizedBy,ACLMoreFlag, 
	@DBRight,'Supervisor',null,null,null,0,1  RefFolders 
	FROM PDBFolder WITH (NOLOCK)
WHERE FolderIndex = 0 
 
/* 
	Changed By			: Harjan 
	Reason / Cause (Bug No if Any)	: PRC515 
	Change Description		: Folder names used in join. 
*/ 
 
/* InBox, Trash, SendItem, RandomId */ 
------------------------------------------------------------------------------------------------ 
-- Changed By				: Mili Das 
-- Reason / Cause (Bug No if Any)	: Changes for optimization 
-- Change Description			: Changes for optimization 
------------------------------------------------------------------------------------------------ 
------------------------------------------------------------------------------------------------------ 
--Changed By				: Shikhar 
--Reason / Cause (Bug No if Any)	: Added indexes of user's system folders in user table 
--Change Description			: Fetch indexes of user's system folders from user table 
----------------------------------------------------------------------------------------------------- 
IF @ListSysFolder='Y' 
BEGIN 
SELECT FolderIndex,ParentFolderIndex,Name,Owner,CreatedDatetime,RevisedDateTime, 
	AccessedDateTime,DataDefinitionIndex,AccessType,ImageVolumeIndex,FolderType, 
	FolderLock,LockByUser,Location,DeletedDateTime,EnableVersion,ExpiryDateTime, 
	Comment,UseFulData,ACL,FinalizedFlag,FinalizedDateTime,FinalizedBy, 
	ACLMoreFlag,'1111111111',@UserName,null,null,null, 
	(select count(*) FROM 
		PDBDocumentContent WITH (NOLOCK)
		WHERE parentfolderindex = a.folderindex ) RefDocs, 
	(select count(*) FROM 
		PDBFolderContent WITH (NOLOCK)
		WHERE parentfolderindex = a.folderindex ) 
		+(select count(*) from pdbfolder WITH (NOLOCK)
		WHERE parentfolderindex = a.folderindex ) RefFolders 
	FROM PDBFolder a WITH (NOLOCK)
--	WHERE ParentFolderIndex IN (3,4,5) 
	--AND Owner = @UserIndex 
--	WHERE Name IN(@DBUserNameInbox,@DBUserNameTrash,@DBUserNameSentItem) 
	WHERE FolderIndex IN (@InboxFolderIndex, @SentItemFolderIndex, @TrashFolderIndex) 
	ORDER BY FolderIndex 
END 
------------------------------------------------------------------------------------------------ 
-- Changed By				: Sneh Lata Sharma 
-- Reason / Cause (Bug No if Any)	: Changes for warning before Password Expiry 
-- Change Description			: Changes for warning before Password Expiry 
------------------------------------------------------------------------------------------------ 
------------------------------------------------------------------------------------------------ 
-- Changed By				: Mili Das 
-- Reason / Cause (Bug No if Any)	: To get the details of last successful/unsuccessful login 
-- Change Description			: To get the details of last successful/unsuccessful login 
------------------------------------------------------------------------------------------------ 
IF @DBFailureAttemptCount=0 
SELECT @DBFailureAttemptCount=NULL 
---------------------------------------------------------------------------------------------- 
-- Changed By				: Vikas Dubey 
-- Reason / Cause (Bug No if Any)	: Changes for implementation of DDTFTS feature 
-- Change Description			: Changes for implementation of DDTFTS feature 
--------------------------------------------------------------------------------------------- 
 
SELECT @IsMCEnabled = IsMakerCheckerEnabled,@IsDDTFTSEnabled = DDTFTS FROM PDBLICENSE WITH (NOLOCK)

------
 
------------------------------------------------------------------------------------------------ 
-- Changed By				: Swati Gupta 
-- Reason / Cause (Bug No if Any)	: Changes for optimization (bug 2209) 
-- Change Description			: Changes for optimization 
------------------------------------------------------------------------------------------------ 
 
SELECT	@CabinetName, @CabinetType, @CreatedDateTime, 
	@VersioningFlag, @SecurityLevel, @FtsDatabasePath, 
	@CabinetLock, 
	@LockBy, @ImageVolumeIndex, @UserIndex, @PasswordExpiryFlag, @RemExpiryDays,@DBLastLoginTime,@DBLastLoginFaliureTime,@DBFailureAttemptCount,@IsMCEnabled ,@DBFlag,@IsDDTFTSEnabled,@DBAutoPassword,@DBEvalWarnTime, 
	@BuildVersion, @UserName, @MailId, @InboxFolderIndex, @SentItemFolderIndex, @TrashFolderIndex, @PersonalName, 
	@FamilyName, @Account,@ThemeColor ,@PreferredFolderIndex ,@EnableDataSecurity,@lTwoFactorAuthenticationFlag
 
IF @ExtraInfoFlag = 'Y' OR @ExtraInfoFlag = 'y' 
BEGIN 
 
	Select @FolderBatchSize = FolderBatchSize, @DocumentBatchSize = DocumentBatchSize, @DocSearchBatchSize = DocSearchBatchSize, @ListViewContents = ListViewContents, @PickListBatchSize = PickListBatchSize, @UserListBatchSize = UserListBatchSize, @PreferedGroup = PreferedGroup, @PreferedFilter = PreferedFilter, @NativeAppDocTypes = NativeAppDocTypes, @DoclistSortPreferences = DoclistSortPreferences, @SiteId = SiteId From Usr_0_UserPreferences WITH (NOLOCK) Where UserIndex  = @UserIndex    
	 
	IF (@@ROWCOUNT <= 0) 
	BEGIN 
	    Select @FolderBatchSize = 10, @DocumentBatchSize = 10, @DocSearchBatchSize = 10, @ListViewContents = '111010111001111000', @PickListBatchSize = 10, @UserListBatchSize = 10, @PreferedGroup = '1#Everyone',  
		@PreferedFilter = 0, @NativeAppDocTypes = '', @DoclistSortPreferences = '5#0', @SiteId = 1 
		 
		INSERT INTO Usr_0_UserPreferences values (@UserIndex, @FolderBatchSize, @DocumentBatchSize, @DocSearchBatchSize, @ListViewContents, @PickListBatchSize, @UserListBatchSize, @PreferedGroup,  
		@PreferedFilter, @NativeAppDocTypes, @DoclistSortPreferences, @SiteId) 
	END 
	 
	Select @UserIndex, @FolderBatchSize, @DocumentBatchSize, @DocSearchBatchSize, @ListViewContents, @PickListBatchSize, @UserListBatchSize, @PreferedGroup, @PreferedFilter, @NativeAppDocTypes, @DoclistSortPreferences, @SiteId 
 
END 
	 
SELECT ServiceType,HostName,DataBaseName,Comment,ServiceIndex 
FROM PDBService WITH (NOLOCK)
---------------------------------------------------------------------------------------------- 
-- Changed By						: Vikas Dubey 
-- Reason / Cause (Bug No if Any)	: ECM Server7.1 Bug id : 26451 
-- Change Description				: Warning code must be thrown from outside the error code  
--------------------------------------------------------------------------------------------- 
IF (@DBWarnFlag2 = 'Y') 
BEGIN 
--	EXECUTE PRTRaiseError 'PRT_WARN_Login_User_High',@DBStatus OUT 
	INSERT INTO PDBConnectionHistory (UserIndex, UserName, UserType, LoginTime, ConnectionAllowed, NoOfConcurrentUsers) 
					VALUES(@UserIndex, @UserName, @lUserType, @DBDate, 'Y', @UserLoginCount+1 )	 
END 
 
IF (@DBWarnFlag = 'Y') 
BEGIN 
--	EXECUTE PRTRaiseError  'PRT_WARN_Concurrency_Limit_Reached', @DBStatus OUT 
	INSERT INTO PDBConnectionHistory (UserIndex, UserName, UserType, LoginTime, ConnectionAllowed, NoOfConcurrentUsers) 
					VALUES(@UserIndex, @UserName, @lUserType, @DBDate, 'Y', @UserLoginCount+1 )	 
END 
RETURN 
ErrHnd: 
	DECLARE @EnableLog char(1) 
	SELECT @EnableLog = 'N' 
	SELECT @EnableLog = EnableLog 
	FROM PDBAuditAction WITH (NOLOCK)
	WHERE ActionId	= @lActionId 	--changed by shubham
 
	IF @@ROWCOUNT <= 0 
		SELECT @EnableLog = 'N' 
 
------------------------------------------------------------------------------------------------ 
-- Changed By				: Mili Das 
-- Reason / Cause (Bug No if Any)	: To get the details of last unsuccessful login 
-- Change Description			: To get the details of last unsuccessful login 
------------------------------------------------------------------------------------------------ 
 
	SELECT @DBFailureAttemptCount=FailureAttemptCount 
	FROM UserSecurity WITH (NOLOCK)
	WHERE UserIndex=@UserIndex 
 
 
	UPDATE 	UserSecurity Set LastLoginFaliureTime=@TempDate, 
	FailureAttemptCount =@DBFailureAttemptCount + 1 
	WHERE UserIndex=@UserIndex 
 
	IF @EnableLog = 'Y' 
	BEGIN 
------------------------------------------------------------------------------------------------ 
-- Changed By				: Sneh Lata Sharma 
-- Reason / Cause (Bug No if Any)	: Changes for Application Name Support 
-- Change Description			: Changes for Application Name Support 
------------------------------------------------------------------------------------------------ 
------------------------------------------------------------------------------------------- 
-- Changed By				: Sneh Lata Sharma 
-- Reason / Cause (Bug No if Any)	: Audit Log Optimization 
-- Change Description			: Audit Log Optimization 
------------------------------------------------------------------------------------------- 
/* 
		INSERT into PDBNewAuditTrail_Table(ACTIONID,CATEGORY,ACTIVEOBJECTID,ACTIVEOBJECTTYPE, 
			SUBSDIARYOBJECTID,SUBSDIARYOBJECTTYPE,COMMENT,DATETIME,USERINDEX) 
		VALUES(101, 'C', @UserIndex, 'U', -1, NULL, 'Failure-' + RTRIM(@UserName)+ RTRIM(@DBApplicationInfo), @DBDate, @UserIndex) 
*/ 
		/*INSERT into PDBNewAuditTrail_Table(ACTIONID,CATEGORY,ACTIVEOBJECTID,ACTIVEOBJECTTYPE, 
			SUBSDIARYOBJECTID,SUBSDIARYOBJECTTYPE,COMMENT,DATETIME,USERINDEX,USERNAME, ACTIVEOBJECTNAME, SUBSDIARYOBJECTNAME, OLDVALUE, NEWVALUE) 
		VALUES(101, 'C', @UserIndex, 'U', -1, NULL, 'Failure-' + RTRIM(@UserName)+ '-' + RTRIM(@DBApplicationInfo)+ RTRIM(@FailureReason), @DBDate, @UserIndex, RTRIM(@UserName), RTRIM(@UserName), NULL, NULL, NULL) */ --by shubham
			--added by shubham
		SELECT @Comment='Failure-' + RTRIM(@UserName)+ '-' + RTRIM(@FailureReason)
		EXECUTE PRTGenerateConnectionlog @UserIndex,null,@lActionId,@UserIndex,'U', NULL, NULL, @MainGroupId,NULL,NULL,'C',@Comment,-1,NULL,NULL, @lApplicationInfo,null,@lAppIndex,@ProductName,@lUserType	
		IF(@LeftAttempts=0 OR @lActionId IN (673,675,676))	
		BEGIN
			SELECT @FailureReason = 'User Account Locked' 
			SELECT @lActionId =686
			SELECT @Comment='Failure-' + RTRIM(@UserName)+ '-'+ RTRIM(@FailureReason)
			
			EXECUTE PRTGenerateConnectionlog @UserIndex,null,@lActionId,@UserIndex,'U', NULL, NULL, @MainGroupId,NULL,NULL,'C',@Comment,-1,NULL,NULL,@lApplicationInfo,null,@lAppIndex,@ProductName,@lUserType
		END	
	END 
	RETURN 
END

