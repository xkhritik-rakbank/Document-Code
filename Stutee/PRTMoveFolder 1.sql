/******************************************************************************************************
			NEWGEN SOFTWARE TECHNOLOGIES LIMITED
Group			: Application-Products
Product / Project	: Java Transaction Server	
Module			: PanRemote
File Name		: PRTMoveFolder.sql
Author			: Shikhar Prawesh
Date written		: 11/02/2002
Description		: Moves a folder to another folder
---------------------------------------------------------------------------
		CHANGE HISTORY
---------------------------------------------------------------------------
 Date		Change By		Change Description (Bug No. If Any)
 21/03/2002	Shikhar			Change to allow lock by user to move folder
 30/10/2002	Shikhar			Lock status of folder will be changed depending on destination folder
 04/07/2003	Anil Bhandari		Changes in size of variables for multibyte support.
 24/07/2004	Shikhar			Change for Optimization
 04/08/2004	Shikhar			Id to be appended to objects in case of duplicate name
 16/03/2005	Shikhar			Changed for right checking error and for optimization
 13/12/2006	Vipin Kumar Singla	Added support for NVARCHAR,NCHAR and NTEXT (ERC51)
 9/07/2007	Ghanshyam Sharma	Support For KM
 06/05/2008	Mili Das		Chages for Audit log enhancement(Support for VERS)(ERC 150)
 19/09/2008	Shikhar			Added indexes of user's system folders in user table
 01/09/2008	Mili Das		Changes for Audit Trail Unification
 27/11/2008	Pranay Tiwari		Changes in datatypes of variables to support larger userindex
 28/02/2009	Pranay Tiwari		Changes for supporting read only rights on data class
 15/07/2009	Mili Das		Changes for implemetation of Owner Inheritance.
 29/07/2009	Mili Das		Mantis id:0009823 resolved(No rights checking on document dataclass)
 11/08/2010	Vikas Dubey		Changes for "support Of PickList rights"
 23/12/2010	Shikhar	Prawesh		Change for adding version in new folder and for having separate meta data for each version
 30/12/2010	Vikas Dubey			Changes for ECM Server7.1 Bug id : 26453
 10/08/2012 Neeraj Kumar	Bug 2211 - date format conversion in yyyy-mm-dd hh:mi:ss.mmm(24h)
 20/12/2012 Shipra Tiwari   Changes for enable secure flag
 04/10/2013 Swati Gupta		Changes for Audit Log Enhancement(IP Address)
----------------------------------------------------------------------------
 Function Name 	: PRTMoveFolder
 Date written	: 11/02/2002
 Author		: Shikhar Prawesh
 Input parameter	:
	DBConnectId			ConnectionId of the user performing the operation.
	DBHostName			Name of the server to which the user is to be connected
	In_DBDate			Date when thenfolder is moved
	DBMoveFolderIndex		Index of the folder which is to be moved
	In_DBDestFolderIndex		Index of the destination folder
	In_DBLockFlag			If ‘N’ , set it to ‘Y’ if the folder being moved has a document locked and return , else move the folder.
	In_DBCheckOutFlag		If ‘N’ , set it to ‘Y’ if the folder being moved has a checked out document locked and return , else move the folder.
	DBParentFolderIndex		Parent folder of the folder being moved.
	NameLength			Limit on length of name
 Output parameter	:
 Return value(Result set) :Return Status
*******************************************************************************************************/
--DROP PROCEDURE PRTMoveFolder
--GO
CREATE  PROCEDURE PRTMoveFolder
(
	@DBConnectId			int,
	@DBHostName			nvarchar(30),
	@DBDate				varchar(50) = null,
	@DBMoveFolderIndex		int,
	@DBDestFolderIndex		int,
	@DBLockFlag			char(1),
	@DBCheckOutFlag			char(1),
	@DBParentFolderIndex    	int = null,
	@NameLength			int = null,
	@Flag                           char(1)= null,
	@DuplicateNameFlag		char(1) = null,
	@TransactionFlag		char(1) = 'Y',
	@DBOwnerInheritanceFlag		CHAR(1),
	@DBIncludesubFolder		CHAR(1)
)
--WITH ENCRYPTION
AS
	SET NOCOUNT ON
    	-- Declare variables
	DECLARE @DBLoginUserRights      char(12)
	DECLARE @DBStatus               int
	DECLARE @Str 			varchar(255)
	DECLARE @TempIndex 		int
 	DECLARE @LockStatus		char(1)
	DECLARE @Status 		char(1)
	DECLARE @CheckedOut		char(1)
	DECLARE @DBUserId       	int
	DECLARE @DBFlag			char(1)
	DECLARE @SrcFinalisedFlag 	char(1)
	DECLARE @SrcFolderType 		char(1)
	DECLARE @DestFolderType 	char(1)
	DECLARE @SrcLocation 		char(1)
	DECLARE @DestLocation 		char(1)
	DECLARE @SrcFolderName		nvarchar(255)
	DECLARE @FLockStatus		char(1)
	DECLARE @MainGroupId		smallint
	DECLARE @IsAdmin		char(1)
	DECLARE @SrcOwner		int
	DECLARE @SrcAccessType		char(1)
	DECLARE @SrcACLMoreFlag		char(1)
	DECLARE @SrcACL			varchar(255)
	DECLARE @DestOwner		int
	DECLARE @DestAccessType		char(1)
	DECLARE @DestACLMoreFlag	char(1)
	DECLARE @DestACL		varchar(255)
	DECLARE @HasRights		char(1)
	DECLARE @SrcParentFolderIndex	int
	DECLARE @TempDocumentIndex 	int
	DECLARE @MainGroupIndex		smallint
	DECLARE @DestFolderLevel	int
	DECLARE @LockByUser 		varchar(1020)
	DECLARE @UpdateList 		varchar(255)
	DECLARE @EffectiveLockByUser	int
	DECLARE @DestLockMessage	nvarchar(255)
	DECLARE @LockedObject		int
	Declare @DocLockByUser  	varchar(1020)  
	declare @DataDefinitionIndex 	int
	DECLARE @MaximumFolderLevel	smallint	
	DECLARE @SrcFolLock		char(1)
	DECLARE @TempLockByUser		VARCHAR(1020)
	DECLARE @TempFolderLock		CHAR(1)
	DECLARE @TempLockMessage	NVARCHAR(255)
	DECLARE @AdjLockByUser		VARCHAR(1020)
	DECLARE @SrcLockByUser		VARCHAR(1020)
	DECLARE @DestFolLock		CHAR(1)
	DECLARE	@DestLockByUser		VARCHAR(1020)
	DECLARE @NewLockByUser		VARCHAR(1020)
	DECLARE @NewLockFlag		CHAR(1)
	DECLARE @Pattern		VARCHAR(25)
	DECLARE	@OldHierarchy		VARCHAR(2500)
	DECLARE	@NewHierarchy		VARCHAR(2500)
	DECLARE @SrcDataDefinitionIndex	int

	DECLARE @SecurityLevel 		int
	DECLARE @DBRightString		varchar(16)
	DECLARE @SrcFolderLevel		int
	DECLARE @TempDBDestFolderIndex	int
	DECLARE @SrcLockMessage		nvarchar(255)
	DECLARE @CurrentDate		datetime
	DECLARE @TotalFolderCount	int
	DECLARE @FolderListId		varchar(8000)

	DECLARE @RowCounter 		int
	DECLARE @PrevIndex  		int
	DECLARE @LeafCounter  		int
	DECLARE @TempFolderIndex	int
	DECLARE @TempOwner		int
	DECLARE @ParRowCounter		int
	DECLARE @ParPrevIndex		int
	DECLARE @SubRowCounter		int
	DECLARE @SubPrevIndex		int
	DECLARE @TempDataDefinition	int
	DECLARE @TempAccessType		char(1)
	DECLARE @ParFolderIndex		int
	DECLARE @TempParentFolderIndex	int
	DECLARE @TempCheckedOut		char(1)
	DECLARE @TempLockStatus		char(1)
	DECLARE @TempACLMore		char(1)
	DECLARE @TempFolderType		char(1)
	DECLARE @TempFolderName		varchar(255)
	DECLARE @TempACL		varchar(255)
	DECLARE @TempDataDefinitionIndex int	
	DECLARE @FoldRowCount		int
	DECLARE @FolPrevIndex		int
	DECLARE @DocRowCounter 		int
	DECLARE @DocPrevIndex		int
	DECLARE @SrcFinalizedBy		int
	DECLARE @OwnerName		nvarchar(64)
	DECLARE @DataDefName		nvarchar(64)
	DECLARE @LOCKBYUSERName		nvarchar(64)
	DECLARE @FINALISEDBYname	nvarchar(64)
	DECLARE @TempFolderListId	varchar(8000)
	DECLARE @TempFolderListCount	int
	DECLARE @Position		int
	DECLARE @SubTempFolderListId	varchar(8000)
	DECLARE @SubTempFolderListCount	int
	DECLARE @TempUserName		nvarchar(64)
	DECLARE @TempDate		DATETIME
	DECLARE @DestFolderLevelStr varchar(10)
	DECLARE @SrcFolderLevelStr varchar(10)
	DECLARE @NoOfSubFolders  int
	DECLARE @NoOfDocs 	int
	DECLARE @NoOfRefDocs 	int
	DECLARE @NoOfRefFolders	int
	DECLARE @DBUseFull_InfoOnly char(1)
	DECLARE @Valcount 	SMALLINT
	DECLARE @EnableSecure Char(1) 
-------------------------------------------------------------------------------------------
-- Changed By				: Mili Das
-- Reason / Cause (Bug No if Any)	: Chages for Audit log enhancement(Support for VERS)(ERC 150)
-- Change Description			: Chages for Audit log enhancement(Support for VERS)(ERC 150)
-------------------------------------------------------------------------------------------
	DECLARE	@NewList		nvarchar(2000)
	DECLARE	@OldList		nvarchar(2000)
--For Audit Trail Unification
	DECLARE	@lcomment1		nVARCHAR(1000)
	DECLARE	@lcomment2		nVARCHAR(1000)
	DECLARE	@OldParentFold		nvarchar(65)
	DECLARE	@NewParentFold		nvarchar(65)

	DECLARE @DCRightStr		VARCHAR(12)
	DECLARE	@SrcOwnerInheritance	CHAR(1)
	DECLARE	@HasRight		CHAR(1)
	DECLARE	@TempHasRightsOnDoc	CHAR(1)
	DECLARE	@TempFoldLock		CHAR(1)
	DECLARE	@LockMessage		nvarchar(255)
	DECLARE	@TempDocCheckOut	CHAR(1)
	DECLARE	@TempDocLock		CHAR(1)
	DECLARE @IsLatestVersion	CHAR(1)
	DECLARE	@TempLatestVersion	CHAR(1)
	DECLARE @VersionSeries int
	DECLARE	@LatVerDocIndex int
	DECLARE @LatVerDataDefIndex int
	DECLARE	@DBRightObjectType CHAR(1)

	DECLARE @DBAppInfo   varchar(20)
	DECLARE @DBAppName  nvarchar(32)
	DECLARE @TempParentFolId   INT
	DECLARE @DBDateTimeStr VARCHAR(50)
	DECLARE @DeleteReferences		char(1)
	DECLARE @RefFoldIndex   INT	
	
	SELECT 	@OldList	= ''
	SELECT 	@NewList	= ''


	SELECT 	@SecurityLevel = SecurityLevel FROM PDBCabinet WITH (NOLOCK)


	EXECUTE GetDate1 @TempDate out 
	/*Set default values */
	SELECT 	@MaximumFolderLevel	= 255
	SELECT 	@DBLoginUserRights 	= REPLICATE('0',12)
	SELECT 	@DBStatus 		= 1
----------------------------------------------------------------------------
-- Changed By						: Neeraj Kumar
-- Reason / Cause (Bug No if Any)	: Bug 2211 
-- Change Description				: date format conversion in yyyy-mm-dd hh:mi:ss.mmm(24h) 
-----------------------------------------------------------------------------	
	SELECT 	@DBDate 		= ISNULL(@DBDate, CONVERT(varchar(50), @TempDate,121))
	SELECT  @CurrentDate		= Convert(datetime,@DBDate,121)
	SELECT 	@DBDateTimeStr 	= CONVERT(VARCHAR(50), @CurrentDate,121)  
	SELECT 	@NameLength 		= ISNULL(@NameLength,255)
	select @flag			= ISNULL(@Flag,'Y')
	select @DuplicateNameFlag 	= isnull(@DuplicateNameFlag,'Y')
	SELECT @DeleteReferences = 'Y'
	/*Check the validity of the user */	
------------------------------------------------------------------------------------------------
-- Changed By						: Swati Gupta
-- Reason / Cause (Bug No if Any)	: Changes for Audit Log Enhancement(IP Address)
-- Change Description				: Changes for Audit Log Enhancement(IP Address)
------------------------------------------------------------------------------------------------
	EXECUTE PRTCheckUser @DBConnectId, @DBHostName, @DBUserId OUT, 
				@MainGroupId OUT, @DBStatus OUT, @DBAppInfo OUT, @DBAppName OUT 
	IF(@DBStatus <> 0)
	BEGIN
		SELECT 	Stat 		= @DBStatus ,
			UserRights 	= @DBLoginUserRights,
			LockFlag	= @DBLockFlag,
			CheckOutFlag	= @DBCheckOutFlag
		RETURN
	END	

--RETURN
	IF (@DBOwnerInheritanceFlag IS NOT NULL) AND (@DBOwnerInheritanceFlag NOT IN ('I','N'))
	BEGIN
		EXECUTE PRTRaiseError 'PRT_ERR_Invalid_Parameter', @DBStatus OUT
		SELECT Status = @DBStatus
		RETURN
	END 

	IF (@DBIncludesubFolder IS NOT NULL) AND (@DBIncludesubFolder NOT IN ('Y','N'))
	BEGIN
		EXECUTE PRTRaiseError 'PRT_ERR_Invalid_Parameter', @DBStatus OUT
		SELECT Status = @DBStatus
		RETURN
	END 
----------------------------------------------------------------------------
-- Changed By				: Munish
-- Reason / Cause (Bug No if Any)	: Added check for TransactionFlag with return
-- Change Description			: Added check for TransactionFlag 
-----------------------------------------------------------------------------
	SELECT @TransactionFlag=ISNULL(@TransactionFlag,'Y')

	IF @TransactionFlag = 'Y'
		BEGIN  TRANSACTION TranMoveFolder				

	if @@TRANCOUNT =0 
	begin
		EXECUTE PRTRaiseError 'PRT_ERR_Invalid_Transaction', @DBStatus out
		SELECT 	Stat 		= @DBStatus , --munish
			UserRights 	= @DBLoginUserRights,
			LockFlag	= @DBLockFlag,
			CheckOutFlag	= @DBCheckOutFlag
		RETURN
	end 

	/*Check validity of destination folder*/

	SELECT 	@TempDBDestFolderIndex 	= FolderIndex, 
		@DestFolderType 	= FolderType,
		@DestLocation 		= Location,
		@DestFolLock		= FolderLock,
		@DestOwner 		= Owner,
		@DestAccessType 	= AccessType,
		@DestACLMoreFlag 	= ACLMoreFlag,	
		@DestACL		= ACL,
		@DestLockMessage	= LockMessage,
		@DestLockByUser		= LockByUser,
		@DestFolderLevel	= FolderLevel,
		@DataDefinitionIndex 	= DataDefinitionIndex,
		@NewHierarchy 		= Hierarchy,
		@EnableSecure       = EnableSecure
	FROM PDBFolder  
	WHERE FolderIndex = @DBDestFolderIndex
--	AND (@MainGroupId = 0 OR MainGroupId = @MainGroupId OR MainGroupId = 0)

	IF (@@ROWCOUNT <= 0)
	BEGIN
		IF @TransactionFlag = 'Y'
			ROLLBACK TRANSACTION TranMoveFolder
		EXECUTE PRTRaiseError 'PRT_ERR_Folder_Not_Exist',@DBStatus OUT
		SELECT 	Stat 		= @DBStatus ,
			UserRights 	= @DBLoginUserRights,
			LockFlag	= @DBLockFlag,
			CheckOutFlag	= @DBCheckOutFlag
		RETURN
	END

----------------------------------------------------------------------------
-- Changed By						: Shipra Tiwari
-- Reason / Cause (Bug No if Any)	: Changes for enable secure flag
-- Change Description				: Changes for enable secure flag
-----------------------------------------------------------------------------	
	IF (@EnableSecure = 'Y')
	BEGIN
		IF @TransactionFlag = 'Y'
			ROLLBACK TRANSACTION TranMoveFolder
		EXECUTE PRTRaiseError 'PRT_ERR_Invalid_Rights_OnFolder', @DBStatus OUT
		SELECT 	Stat 		= @DBStatus
		RETURN
	END

	IF (@DBDestFolderIndex = 5)
	BEGIN
		/* This extra query is made to make the facility 
		to move the folder to system trash so that it's
		automatically moved to the user trash*/
------------------------------------------------------------------------------------------------------ 
--Changed By				: Shikhar 
--Reason / Cause (Bug No if Any)	: Added indexes of user's system folders in user table
--Change Description			: Fetch indexes of user's system folders from user table
----------------------------------------------------------------------------------------------------- 
		SELECT	@TempDBDestFolderIndex = TrashFolderIndex FROM PDBUser WHERE UserIndex = @DBUserId
/*
		SELECT  @TempUserName = UserName FROM PDBUser WHERE UserIndex = @DBUserId 
		SELECT	@TempUserName = N'USER_TRASH_' + @TempUserName
*/
		SELECT 	@DestFolderType = FolderType,
			@DestLocation 	= Location,
			@DestFolLock	= FolderLock, 
			@DestLockByUser	= LockByUser,
			@DestFolderLevel = FolderLevel,	
			@DataDefinitionIndex = DataDefinitionIndex,
			@NewHierarchy = Hierarchy,
			@DestOwner 		= Owner,
			@DestAccessType 	= AccessType,
			@DestACLMoreFlag 	= ACLMoreFlag,	
			@DestACL		= ACL
		FROM PDBFolder 
		WHERE FolderIndex = @TempDBDestFolderIndex
	END


	UPDATE PDBFolder SET AccessedDateTime = @CurrentDate,
			     RevisedBy = @DBUserId,
				 RevisedDateTime = @CurrentDate
        WHERE FolderIndex = @TempDBDestFolderIndex
	
	IF (@@ERROR <>0)
	BEGIN
		IF @TransactionFlag = 'Y'
			ROLLBACK TRANSACTION TranMoveFolder
		RETURN
	END
	SELECT @NewHierarchy = RTRIM(ISNULL(@NewHierarchy, '')) + RTRIM(CONVERT(VARCHAR(10), @TempDBDestFolderIndex)) + '.'
-- Changed By				: Shikhar
-- Reason / Cause (Bug No if Any)	: Lock status of folder to change depending on destination folder
-- Change Description			: Lock status of folder will be changed depending on destination folder
	IF (@DestFolLock = 'Y')
	BEGIN
		-- Fetch effective lock by user and lock message
		EXECUTE CheckLock 'F', @TempDBDestFolderIndex, @DestLockByUser, @DestFolLock,
				@EffectiveLockByUser OUT, 
				@DestLockMessage OUT, 
				@LockedObject OUT, 
				@DBStatus OUT
		IF @EffectiveLockByUser <> @DBUserId
		BEGIN
			IF @TransactionFlag = 'Y'
				ROLLBACK Transaction TranMoveFolder
			EXECUTE PRTRaiseError 'PRT_ERR_Folder_Locked', @DBStatus OUT
			SELECT 	Status = @DBStatus,
				LockByUser = @EffectiveLockByUser,
				LockMessage	= @DestLockMessage
			RETURN
		END
		SELECT @NewLockByUser = @DestLockByUser	
		SELECT @NewLockFlag = 'Y'
	END	
/***
	IF(@SrcFinalisedFlag = 'Y')
  	BEGIN
		IF @TransactionFlag = 'Y'
			ROLLBACK TRANSACTION TranMoveFolder
		EXECUTE PRTRaiseError 'PRT_ERR_Finalised_Folder',@DBStatus OUT
		SELECT 	Stat 		= @DBStatus ,
			UserRights 	= @DBLoginUserRights,
			LockFlag	= @DBLockFlag,
			CheckOutFlag	= @DBCheckOutFlag
		RETURN
	END
***/
---------------------------------------------------------------------------------
--Changed By			: Ghanshyam Sharma
--Reason / Cause (Bug No if Any): Support For KM
--Change Description		: Support For KM
---------------------------------------------------------------------------------
	--IF (NOT(@DestFolderType = @DestLocation OR (@DestLocation = 'R' AND @DestFolderType = 'G') ))
	IF (NOT(@DestFolderType = @DestLocation OR (@DestLocation = 'R' AND @DestFolderType = 'G') OR (@DestLocation = 'G' AND @DestFolderType = 'K') ))
	BEGIN
		IF @TransactionFlag = 'Y'
			ROLLBACK TRANSACTION TranMoveFolder
		EXECUTE PRTRaiseError 'PRT_ERR_Cannot_Move_Folder',@DBStatus OUT
		SELECT 	Stat 		= @DBStatus ,
			UserRights 	= @DBLoginUserRights,
			LockFlag	= @DBLockFlag,
			CheckOutFlag	= @DBCheckOutFlag
		RETURN
	END
	
/********
	IF(NOT(@DestFolderType ='G' or (@DestFolderType = 'T' AND @SrcFolderType <> 'T') ))
	BEGIN
		IF @TransactionFlag = 'Y'
			ROLLBACK TRANSACTION TranMoveFolder
		EXECUTE PRTRaiseError 'PRT_ERR_Cannot_Move_Folder',@DBStatus OUT
		SELECT 	Stat 		= @DBStatus ,
			UserRights 	= @DBLoginUserRights,
			LockFlag	= @DBLockFlag,
			CheckOutFlag	= @DBCheckOutFlag
		RETURN
	END
********/
	SELECT 	@SrcParentFolderIndex 	= ParentFolderIndex,
		@SrcFinalisedFlag 	= FinalizedFlag,
		@SrcFolderType 		= FolderType,
		@SrcLocation 		= Location,
		@SrcFolderName 		= Name,
		@SrcFolLock 		= FolderLock, 
		@SrcOwner 		= Owner,
		@SrcAccessType 		= AccessType,
		@SrcACLMoreFlag		= ACLMoreFlag,	
		@SrcACL			= ACL,
		@MainGroupIndex 	= MainGroupId,
		@SrcLockMessage		= LockMessage,
		@SrcLockByUser		= LockByUser,
		@OldHierarchy   	= Hierarchy,
		@SrcDataDefinitionIndex = DataDefinitionIndex,
		@SrcFolderLevel		= FolderLevel,
		@SrcFinalizedBy		= FinalizedBy,
		@SrcOwnerInheritance	= OwnerInheritance,
		@EnableSecure		= EnableSecure
	FROM PDBFolder (UPDLOCK) 
	WHERE FolderIndex = @DBMoveFolderIndex
--	AND (@MainGroupId = 0 OR MainGroupId = @MainGroupId)


	IF (@@ROWCOUNT <= 0)
	BEGIN
		IF @TransactionFlag = 'Y'
			ROLLBACK TRANSACTION TranMoveFolder
		EXECUTE PRTRaiseError 'PRT_ERR_Folder_Not_Exist',@DBStatus OUT
		SELECT 	Stat 		= @DBStatus ,
			UserRights 	= @DBLoginUserRights,
			LockFlag	= @DBLockFlag,
			CheckOutFlag	= @DBCheckOutFlag
		RETURN
	END

	IF @DBParentFolderIndex IS NOT NULL
	BEGIN
		IF @SrcParentFolderIndex <> @DBParentFolderIndex 
		BEGIN
			IF @TransactionFlag = 'Y'
				ROLLBACK TRANSACTION TranMoveFolder
			Execute PRTRaiseError 'PRT_ERR_Folder_Deleted_Or_Moved',@DBStatus OUT
			SELECT 	Stat 		= @DBStatus ,
			UserRights 	= @DBLoginUserRights,
			LockFlag	= @DBLockFlag,
			CheckOutFlag	= @DBCheckOutFlag
			RETURN
		END
	END
----------------------------------------------------------------------------
-- Changed By						: Shipra Tiwari
-- Reason / Cause (Bug No if Any)	: Changes for enable secure flag
-- Change Description				: Changes for enable secure flag
-----------------------------------------------------------------------------
	IF (@EnableSecure = 'Y')
	BEGIN
		IF @TransactionFlag = 'Y'
				ROLLBACK TRANSACTION TranMoveFolder
		EXECUTE PRTRaiseError 'PRT_ERR_Invalid_Rights_OnFolder', @DBStatus OUT
		SELECT 	Stat 		= @DBStatus
		RETURN
	END
	
	SELECT @AdjLockByUser = @NewLockByUser
	IF (@SrcFolLock = 'Y')
	BEGIN
		-- Fetch effective lock by user and lock message
		EXECUTE CheckLock 'F', @DBMoveFolderIndex, @SrcLockByUser, @SrcFolLock,
				@EffectiveLockByUser OUT, 
				@SrcLockMessage OUT, 
				@LockedObject OUT, 
				@DBStatus OUT
		IF @EffectiveLockByUser <> @DBUserId
		BEGIN
			IF @TransactionFlag = 'Y'
				ROLLBACK Transaction TranMoveFolder
			EXECUTE PRTRaiseError 'PRT_ERR_Folder_Locked', @DBStatus OUT
			SELECT 	Status = @DBStatus,
				LockByUser = @EffectiveLockByUser,
				LockMessage	= @SrcLockMessage
			RETURN
		END
		SELECT @AdjLockByUser = @NewLockByUser
		SELECT @Pattern = ',' + RTRIM(CONVERT(varchar(10), @DBUserId)) + '#' + RTRIM(CONVERT(varchar(10), @DBMoveFolderIndex)) + ','
		IF CHARINDEX(@Pattern, (',' + @SrcLockByUser)) > 0
		BEGIN
			IF @AdjLockByUser IS NOT NULL
				SELECT @AdjLockByUser = @AdjLockByUser + RTRIM(CONVERT(varchar(10), @DBUserId)) + '#' + RTRIM(CONVERT(varchar(10), @DBMoveFolderIndex)) + ','
			ELSE
				SELECT @AdjLockByUser = RTRIM(CONVERT(varchar(10), @DBUserId)) + '#' + RTRIM(CONVERT(varchar(10), @DBMoveFolderIndex)) + ','
		END
	END	

/*
	IF(@SrcFinalisedFlag = 'Y')
	BEGIN
		IF @TransactionFlag = 'Y'
			ROLLBACK TRANSACTION TranMoveFolder
		EXECUTE PRTRaiseError 'PRT_ERR_Finalised_Folder',@DBStatus OUT
		SELECT 	Stat 		= @DBStatus ,
			UserRights 	= @DBLoginUserRights,
			LockFlag	= @DBLockFlag,
			CheckOutFlag	= @DBCheckOutFlag
		RETURN
	END	
*/
	
	--IF(@SrcFolderType NOT IN ('G','A') OR  @SrcLocation NOT IN('G','I','T', 'A'))
	IF(@SrcFolderType IN ('S','I','T','H') OR  @SrcLocation IN('S','H','R'))
	BEGIN
		IF @TransactionFlag = 'Y'
			ROLLBACK TRANSACTION TranMoveFolder
		EXECUTE PRTRaiseError 'PRT_ERR_Cannot_Move_Folder',@DBStatus OUT
		SELECT 	Stat 		= @DBStatus ,
			UserRights 	= @DBLoginUserRights,
			LockFlag	= @DBLockFlag,
			CheckOutFlag	= @DBCheckOutFlag
		RETURN
	END
	
	If @Flag = 'Y'
	begin
		/* Check write right on destination */
		EXECUTE PRTCheckRights	 @DBUserId, 'F', @TempDBDestFolderIndex, 3,@DBFlag OUT,
			@DestOwner, @DestAccessType, @DestACLMoreFlag, @DestACL, @IsAdmin OUT, 
			@DBStatus OUT
		IF (@DBStatus <> 0)
		BEGIN
			IF @TransactionFlag = 'Y'
				ROLLBACK TRANSACTION TranMoveFolder
			SELECT 	Stat 		= @DBStatus ,
				UserRights 	= @DBLoginUserRights,
				LockFlag	= @DBLockFlag,
				CheckOutFlag	= @DBCheckOutFlag
			RETURN
		END
		-------------------------------------------------------------------------------------------
		-- Changed By				: Pranay Tiwari
		-- Reason / Cause (Bug No if Any)	: Changes for supporting read only rights on data class 
		-- Change Description			: Changes for supporting read only rights on data class
		-------------------------------------------------------------------------------------------
		IF (@DBFlag = '1') AND @IsAdmin <> 'y'
		Begin
			EXECUTE CheckDataClassNPickListRights @DBUserId, @TempDBDestFolderIndex, 'F', @DataDefinitionIndex, 3, @IsAdmin OUT, @DBFlag OUT, @DBRightObjectType OUT, @DBStatus OUT
			If (@DBStatus <> 0)
			Begin
				IF @TransactionFlag = 'Y'
					ROLLBACK TRANSACTION TranMoveFolder
				Select 	Stat = @DBStatus ,
					UserRights = @DBLoginUserRights
				Return
			End
		END

		IF (@DBFlag <> '1') 
		BEGIN
			IF @TransactionFlag = 'Y'
				ROLLBACK TRANSACTION TranMoveFolder
			EXECUTE PRTRaiseError 'PRT_ERR_Invalid_Rights_OnFolder', @DBStatus OUT
			SELECT 	Stat 		= @DBStatus ,
				UserRights 	= @DBLoginUserRights,
				LockFlag	= @DBLockFlag,
				CheckOutFlag	= @DBCheckOutFlag
			RETURN
		END
	end

	IF (@DBMoveFolderIndex = @TempDBDestFolderIndex)
	BEGIN
		IF @TransactionFlag = 'Y'
			ROLLBACK TRANSACTION TranMoveFolder
		EXECUTE PRTRaiseError 'PRT_ERR_Cannot_Move_Folder',@DBStatus OUT
		SELECT 	Stat 		= @DBStatus ,
			UserRights 	= @DBLoginUserRights,
			LockFlag	= @DBLockFlag,
			CheckOutFlag	= @DBCheckOutFlag
		RETURN
	END
	IF EXISTS(SELECT 1  FROM PDBFolderContent 
		WHERE	ParentFolderIndex = @DBMoveFolderIndex AND FolderIndex = @TempDBDestFolderIndex)
	OR EXISTS(SELECT 1  FROM PDBFolderContent
		WHERE 	ParentFolderIndex = @TempDBDestFolderIndex AND FolderIndex = @DBMoveFolderIndex)	
	BEGIN
		IF @TransactionFlag = 'Y'
			ROLLBACK TRANSACTION TranMoveFolder
		EXECUTE PRTRaiseError 'PRT_ERR_Cannot_Move_Folder',@DBStatus OUT
		SELECT 	Stat 		= @DBStatus ,
			UserRights 	= @DBLoginUserRights,
			LockFlag	= @DBLockFlag,
			CheckOutFlag	= @DBCheckOutFlag
		RETURN
	END

	/* Gets the subfolders of the source folder*/
	DECLARE @TempFolderTable TABLE
	( 
		FolderIndex 		int ,--PRIMARY KEY, 
		ParentFolderIndex 	int,
		FolderType 		char(1),
		Leaf			int,--UNIQUE(Leaf, FolderIndex)
		FName			NVARCHAR(255)
	)

	DECLARE RecCur1 CURSOR FAST_FORWARD FOR 
				SELECT FolderIndex,FName,ParentFolderIndex FROM @TempFolderTable
	

	SELECT 	@ParRowCounter		= 1
	SELECT 	@RowCounter 		= 1
	SELECT 	@LeafCounter 		= 1 
	SELECT 	@PrevIndex  		= 0
	SELECT  @TempFolderIndex 	= @DBMoveFolderIndex,
		@TempOwner 		= @SrcOwner,
		@TempAccessType 	= @SrcAccessType,
		@TempACLMore 		= @SrcACLMoreFlag, 
		@TempAcl 		= @SrcACL,
		@TempDataDefinition 	= @SrcDataDefinitionIndex


	IF @Flag = 'Y' AND @IsAdmin = 'N'
	BEGIN
		/* Check write right on destination */
		EXECUTE PRTCheckRights	 @DBUserId, 'F', @TempFolderIndex, 5, @DBFlag OUT,
			@TempOwner, @TempAccessType, @TempACLMore, @TempAcl, @IsAdmin OUT, 
			@DBStatus OUT
		IF (@DBStatus <> 0)
		BEGIN
			IF @TransactionFlag = 'Y'
				ROLLBACK TRANSACTION TranMoveFolder
			SELECT 	Stat 		= @DBStatus ,
				UserRights 	= @DBLoginUserRights,
				LockFlag	= @DBLockFlag,
				CheckOutFlag	= @DBCheckOutFlag
			RETURN
		END
	
		IF (@DBFlag = '1') AND @IsAdmin <> 'Y'
		BEGIN
			EXECUTE CheckDataClassNPickListRights @DBUserId, @TempFolderIndex, 'F', @TempDataDefinition, 2, @IsAdmin OUT, @DBFlag OUT, @DBRightObjectType OUT, @DBStatus OUT
			IF (@DBStatus <> 0)
			BEGIN
				IF @TransactionFlag = 'Y'
					ROLLBACK TRANSACTION TranMoveFolder
				Select 	Stat = @DBStatus ,
					UserRights = @DBLoginUserRights
				Return
			End
		END

		IF (@DBFlag <> '1') 
		BEGIN
			IF @TransactionFlag = 'Y'
				ROLLBACK TRANSACTION TranMoveFolder
			EXECUTE PRTRaiseError 'PRT_ERR_Invalid_Rights_OnFolder', @DBStatus OUT
			SELECT 	Stat 		= @DBStatus ,
				UserRights 	= @DBLoginUserRights,
				LockFlag	= @DBLockFlag,
				CheckOutFlag	= @DBCheckOutFlag
			RETURN
		END
	END
	IF @DBCheckOutFlag = 'N' OR @DBLockFlag = 'N' OR @Flag = 'Y'
	BEGIN
		IF (@DBCheckOutFlag = 'N')
		BEGIN	
			IF EXISTS(SELECT  1 FROM PDBDocument A, PDBDocumentContent B
			WHERE 	A.DocumentIndex     = B.DocumentIndex
			AND 	ParentFolderIndex   = @TempFolderIndex
			AND	CheckOutStatus      = 'Y')
			BEGIN
				IF @TransactionFlag = 'Y'
					ROLLBACK TRANSACTION TranMoveFolder
				SELECT @DBCheckOutFlag 	= 'Y'
				SELECT @DBStatus 	= 0
				EXECUTE PRTRaiseError 'PRT_ERR_Document_Check_Out',@DBStatus OUT
				SELECT 	Stat 		= @DBStatus ,
					UserRights 	= @DBLoginUserRights,
					LockFlag	= @DBLockFlag,
					CheckOutFlag	= @DBCheckOutFlag
				RETURN	
			END			
		END

		IF (@DBLockFlag = 'N') AND @SrcFolLock <> 'Y'
		BEGIN
	/*
			IF EXISTS(SELECT  1 FROM PDBDocument A, PDBDocumentContent B
			WHERE 	A.DocumentIndex     = B.DocumentIndex
			AND 	ParentFolderIndex   = @TempFolderIndex
			AND	DocumentLock        = 'Y'
			AND	CONVERT(int, RTRIM(SUBSTRING(LockByUser, 1, CHARINDEX('#', A.LockByUser) - 1))) <> @DBUserId
			)
	*/
			SELECT TOP 1 	@TempLockMessage = LockMessage,
					@TempDocumentIndex = A.DocumentIndex
			FROM PDBDocument A, PDBDocumentContent B
			WHERE 	A.DocumentIndex     = B.DocumentIndex
			AND 	ParentFolderIndex   = @TempFolderIndex
			AND	DocumentLock        = 'Y'
			AND	CONVERT(int, RTRIM(SUBSTRING(LockByUser, 1, CHARINDEX('#', A.LockByUser) - 1))) <> @DBUserId
			
			IF (@@ROWCOUNT > 0)
			BEGIN
				IF @TransactionFlag = 'Y'
					ROLLBACK TRANSACTION TranMoveFolder
				EXECUTE PRTRaiseError 'PRT_ERR_Document_Locked', @DBStatus OUT
				SELECT 	Status = @DBStatus,
					LockByUser = @EffectiveLockByUser,
					LockMessage	= @TempLockMessage
				RETURN
			END
		END

		IF (@Flag = 'Y') AND (@SecurityLevel = 2) AND (@IsAdmin = 'N')
		BEGIN

		-------------------------------------------------------------------------------------------
		-- Changed By				: Mili Das
		-- Reason / Cause (Bug No if Any)	: Mantis id:0009823 resolved(No rights checking on document dataclass) 
		-- Change Description			: Initialization of the variable @DocPrevIndex was not done.
		-------------------------------------------------------------------------------------------
			SELECT	@DocPrevIndex  = 0
			SELECT 	@DocRowCounter = 1
			WHILE  	@DocRowCounter > 0
			BEGIN
				SELECT TOP 1 	@TempDocumentIndex = A.DocumentIndex, 
						@TempOwner 	   = A.Owner, 
						@TempAccessType    = A.AccessType, 
						@TempACLMore 	   = A.ACLMoreFlag, 
						@TempACL 	   = A.ACL, 
						@TempLockStatus    = A.DocumentLock, 
						@TempCheckedOut    = CheckOutStatus, 
						@TempLockMessage   = A.LockMessage, 
						@DocLockByUser     = A.LockByUser,
						@TempDataDefinitionIndex = A.DataDefinitionIndex,
						@EnableSecure		= EnableSecure
				FROM 	PDBDocumentContent B, PDBDocument A
				WHERE 	B.ParentFolderIndex = @TempFolderIndex
				AND  	B.DocumentIndex > @DocPrevIndex
				AND	A.DocumentIndex = B.DocumentIndex
				ORDER BY B.DocumentIndex ASC

				SELECT @DocRowCounter 	= @@ROWCOUNT
				--SELECT @DocPrevIndex 	= 0

				IF @DocRowCounter > 0
				BEGIN
					----------------------------------------------------------------------------
					-- Changed By						: Shipra Tiwari
					-- Reason / Cause (Bug No if Any)	: Changes for enable secure flag
					-- Change Description				: Changes for enable secure flag
					-----------------------------------------------------------------------------
					IF (@EnableSecure = 'Y')
					BEGIN
						IF @TransactionFlag = 'Y'
								ROLLBACK TRANSACTION TranMoveFolder
						EXECUTE PRTRaiseError 'PRT_ERR_Invalid_Rights_OnDocument', @DBStatus OUT
						SELECT 	Stat 		= @DBStatus
						RETURN
					END
					
					SELECT @DocPrevIndex 	= @TempDocumentIndex

					SELECT 	@IsLatestVersion = 'N'
					SELECT 	@TempLatestVersion = 'N'
					SELECT  @VersionSeries = VersionSeries,
							@TempLatestVersion = LatestVersion
					FROM	PDBNewDocumentVersion
					WHERE	DocumentIndex = @TempDocumentIndex
					IF @@ROWCOUNT = 0
					BEGIN
						SELECT 	@IsLatestVersion = 'Y'
						SELECT	@VersionSeries = NULL
						SELECT	@TempLatestVersion = 'Y'
					END
					ELSE
					BEGIN
						SELECT	@LatVerDocIndex = DocumentIndex
						FROM	PDBDocVersionSeries
						WHERE	VersionSeries = @VersionSeries
						IF @LatVerDocIndex =  @TempDocumentIndex
							SELECT @IsLatestVersion = 'Y'
						ELSE
							SELECT	@IsLatestVersion = 'N'
					END		
					IF @TempLatestVersion = 'N'
					BEGIN
						SELECT	@TempOwner = Owner,
								@TempAccessType = AccessType,
								@TempACLMore = ACLMoreFlag, 
								@TempACL = ACL,
								@LatVerDataDefIndex = DataDefinitionIndex
						FROM	PDBDocument
						WHERE	DocumentIndex = @LatVerDocIndex		
						IF @Flag = 'Y' AND @IsAdmin <> 'Y'
						BEGIN
							EXECUTE PRTCheckRights	 @DBUserId, 'D', @LatVerDocIndex, 5, @DBFlag OUT,
								@TempOwner,TempAccessType,@TempACLMore, @TempACL, @IsAdmin OUT, @DBStatus OUT
							IF (@DBStatus <> 0)
							BEGIN
								IF @TransactionFlag = 'Y'
									ROLLBACK TRANSACTION TranMoveFolder
								SELECT 	Stat = @DBStatus ,
									UserRights = @DBLoginUserRights
								RETURN
							END
							IF (@DBFlag = '1') AND @IsAdmin <> 'Y'
							BEGIN
								EXECUTE CheckDataClassNPickListRights @DBUserId, @LatVerDocIndex, 'D', @LatVerDataDefIndex, 2, @IsAdmin OUT, @DBFlag OUT, @DBRightObjectType OUT, @DBStatus OUT
								IF (@DBStatus <> 0)
								BEGIN
									IF @TransactionFlag = 'Y'
										ROLLBACK TRANSACTION TranMoveFolder
									SELECT 	Stat = @DBStatus ,
										UserRights = @DBLoginUserRights
									RETURN
								END
							END
							IF (@DBFlag <> '1') 
							BEGIN
								IF @TransactionFlag = 'Y'
									ROLLBACK TRANSACTION TranMoveFolder
								EXECUTE PRTRaiseError 'PRT_ERR_Invalid_Rights_OnFolder', @DBStatus OUT
								SELECT 	Stat 		= @DBStatus ,
									UserRights 	= @DBLoginUserRights,
									LockFlag	= @DBLockFlag,
									CheckOutFlag	= @DBCheckOutFlag
								RETURN
							END
						END
					END
					ELSE
					BEGIN
						IF (@DBUserId = @TempOwner) OR (@SecurityLevel = 0) OR (@IsAdmin = 'Y') OR(@Flag = 'N' )
							SELECT @DBFlag = '1'
						ELSE IF (@SecurityLevel = 1) OR (@TempAccessType = 'I')
							SELECT @DBFlag = '1'
						ELSE IF (@TempAccessType = 'P') 
							SELECT @DBFlag = '0'
						ELSE IF (@TempAccessType = 'S')
						BEGIN
							IF @TempACL IS NOT NULL
							BEGIN
								IF (@TempACLMore  = 'N')
									EXECUTE PRTGetUserRightsFromCatche
									@DBUserId, @TempACL, @DBRightString OUT,@TempDataDefinitionIndex
								ELSE
									EXECUTE PRTGetUserSharedRights @DBUserId, @TempACL,
										'D', @TempDocumentIndex, @DBRightString out,
									@DBStatus OUT,@TempDataDefinitionIndex
								IF @DBRightString IS NULL
									SELECT @DBFlag = '1'
								ELSE
									SELECT @DBFlag = SUBSTRING(@DBRightString, 5, 1)
							END
							ELSE
								SELECT @DBFlag = '1'
						END
						ELSE
							SELECT @DBFlag = '0'
						
						IF @Flag = 'Y' AND(@DBFlag = '1') AND @IsAdmin <> 'Y'
						BEGIN
							EXECUTE CheckDataClassNPickListRights @DBUserId, @TempDocumentIndex, 'D', @TempDataDefinitionIndex, 2, @IsAdmin OUT, @DBFlag OUT, @DBRightObjectType OUT, @DBStatus OUT
							IF (@DBStatus <> 0)
							BEGIN
								IF @TransactionFlag = 'Y'
									ROLLBACK TRANSACTION TranMoveFolder
								SELECT 	Stat = @DBStatus ,
									UserRights = @DBLoginUserRights
								RETURN
							END
						END
						IF (@DBFlag <> '1') 
						BEGIN
							IF @TransactionFlag = 'Y'
								ROLLBACK TRANSACTION TranMoveFolder
							EXECUTE PRTRaiseError 'PRT_ERR_Invalid_Rights_OnFolder', @DBStatus OUT
							SELECT 	Stat 		= @DBStatus ,
								UserRights 	= @DBLoginUserRights,
								LockFlag	= @DBLockFlag,
								CheckOutFlag	= @DBCheckOutFlag
							RETURN
						END
					END
				END	
			END
		END
	END

	IF (@DestFolderLevel + @LeafCounter) > @MaximumFolderLevel
	BEGIN
		IF @TransactionFlag = 'Y'
			ROLLBACK TRANSACTION TranMoveFolder
		EXECUTE PRTRaiseError 'PRT_ERR_Max_Level_Count_Reached', @DBStatus OUT
		SELECT 	Stat 		= @DBStatus ,
			UserRights 	= @DBLoginUserRights,
			LockFlag	= @DBLockFlag,
			CheckOutFlag	= @DBCheckOutFlag
		RETURN
	END
	INSERT INTO @TempFolderTable VALUES(@TempFolderIndex, @SrcParentFolderIndex, @SrcFolderType, 1,@SrcFolderName)

	SELECT @FolderListId 			=  CONVERT(varchar(10), @TempFolderIndex)
	SELECT @TempFolderListId 		=  CONVERT(varchar(10), @TempFolderIndex) + ','
	SELECT @TempFolderListCount 	= 1
	SELECT @TotalFolderCount 		= 1
	WHILE @ParRowCounter > 0
	BEGIN
		SELECT @LeafCounter 				= @LeafCounter + 1
		SELECT @ParPrevIndex 				= 0
		SELECT @SubTempFolderListCount 		= 0
		SELECT @SubTempFolderListId 		= ''

		IF (@DestFolderLevel + @LeafCounter) > @MaximumFolderLevel
		BEGIN
			IF @TransactionFlag = 'Y'
				ROLLBACK TRANSACTION TranMoveFolder
			EXECUTE PRTRaiseError 'PRT_ERR_Max_Level_Count_Reached', @DBStatus OUT
			SELECT 	Stat 		= @DBStatus ,
				UserRights 	= @DBLoginUserRights,
				LockFlag	= @DBLockFlag,
				CheckOutFlag	= @DBCheckOutFlag
			RETURN
		END
		
		WHILE @ParRowCounter > 0
		BEGIN
			IF @TempFolderListCount < 700
			BEGIN
				SELECT  @Position  	  =    CHARINDEX(',', @TempFolderListId)
				IF @Position > 0
				BEGIN
					SELECT 	@ParFolderIndex   =		SUBSTRING(@TempFolderListId, 1, @Position - 1)
					SELECT 	@TempFolderListId =		STUFF(@TempFolderListId, 1, @Position, NULL)
					SELECT  @ParRowCounter    =		1
				END
				ELSE
					SELECT  @ParRowCounter = 0
			END
			ELSE
			BEGIN
				SELECT TOP 1  	@ParFolderIndex = FolderIndex
				FROM  			@TempFolderTable
				WHERE Leaf = @LeafCounter - 1
				AND   FolderIndex > @ParPrevIndex
				ORDER BY FolderIndex
				SELECT @ParRowCounter = @@ROWCOUNT
			END

			IF @ParRowCounter > 0
			BEGIN
				SELECT 	@ParPrevIndex 	= @ParFolderIndex
				SELECT 	@SubRowCounter 	= 1
				SELECT 	@SubPrevIndex 	= 0
				WHILE 	@SubRowCounter 	> 0
				BEGIN
--SELECT ParFolderIndex 	= @ParFolderIndex
--SELECT SubPrevIndex 	= @SubPrevIndex
					SELECT 	TOP 1 @TempFolderIndex	= FolderIndex,
						@TempParentFolderIndex 	= ParentFolderIndex,
						@TempFolderType		= FolderType,
						@TempOwner 		= Owner,
						@TempAccessType 	= AccessType,
						@TempACLMore 		= ACLMoreFlag,	
						@TempACL		= ACL,
						@TempLockMessage	= LockMessage,
						@TempLockByUser		= LockByUser,
						@TempLockStatus		= FolderLock,
						@TempDataDefinitionIndex = DataDefinitionIndex,
						@TempFolderName		= Name,
						@EnableSecure		= EnableSecure
					FROM PDBFolder 
					WHERE ParentFolderIndex = @ParFolderIndex
					AND   FolderIndex > @SubPrevIndex	
					ORDER BY FolderIndex ASC
					SELECT @SubRowCounter = @@ROWCOUNT
					IF @SubRowCounter > 0
					BEGIN
						SELECT @SubPrevIndex = @TempFolderIndex
						
						----------------------------------------------------------------------------
						-- Changed By						: Shipra Tiwari
						-- Reason / Cause (Bug No if Any)	: Changes for enable secure flag
						-- Change Description				: Changes for enable secure flag
						-----------------------------------------------------------------------------
						IF (@EnableSecure = 'Y')
						BEGIN
							IF @TransactionFlag = 'Y'
									ROLLBACK TRANSACTION TranMoveFolder
							EXECUTE PRTRaiseError 'PRT_ERR_Invalid_Rights_OnFolder', @DBStatus OUT
							SELECT 	Stat 		= @DBStatus
							RETURN
						END

						IF(@TempFolderIndex = @TempDBDestFolderIndex)
						BEGIN
							IF @TransactionFlag = 'Y'
								ROLLBACK TRANSACTION TranMoveFolder
							EXECUTE PRTRaiseError 'PRT_ERR_Cannot_Move_SubFolder', @DBStatus OUT
							SELECT 	Stat 		= @DBStatus ,
								UserRights 	= @DBLoginUserRights,
								LockFlag	= @DBLockFlag,
								CheckOutFlag	= @DBCheckOutFlag
							RETURN
						END

						IF(@TempLockStatus = 'Y' ) AND @SrcFolLock <> 'Y' -- if @SrcFolLock = 'Y' error would already have been thrown if lock bu user not login user
						BEGIN
							-- Fetch effective lock by user and lock message
							EXECUTE CheckLock 'F', @TempFolderIndex, @TempLockByUser, 
									@TempLockStatus, @EffectiveLockByUser OUT, 
									@TempLockMessage OUT, 
									@LockedObject OUT, 
									@DBStatus OUT
							IF @EffectiveLockByUser <> @DBUserId
							BEGIN
								IF @TransactionFlag = 'Y'
									ROLLBACK Transaction TranMoveFolder
								EXECUTE PRTRaiseError 'PRT_ERR_Folder_Locked', @DBStatus OUT
								SELECT 	Status = @DBStatus,
									LockByUser = @EffectiveLockByUser,
									LockMessage = @TempLockMessage
								RETURN
							END
						END
	
						IF (@DBUserId = @TempOwner) OR (@SecurityLevel = 0) OR (@IsAdmin = 'Y') OR(@Flag = 'N' )
							SELECT @DBFlag = '1'
						ELSE IF (@SecurityLevel = 1) OR (@TempAccessType = 'I')
							SELECT @DBFlag = '1'
						ELSE IF (@TempAccessType = 'P') 
							SELECT @DBFlag = '0'
						ELSE IF (@TempAccessType = 'S')
						BEGIN
							IF @TempACL IS NOT NULL
							BEGIN
								IF (@TempACLMore  = 'N')
									EXECUTE PRTGetUserRightsFromCatche
										@DBUserId, @TempACL, @DBRightString OUT,@TempDataDefinitionIndex
								ELSE
									EXECUTE PRTGetUserSharedRights @DBUserId, @TempACL,
										'F', @TempFolderIndex, @DBRightString out,
										@DBStatus OUT,@TempDataDefinitionIndex
								IF @DBRightString IS NULL
									SELECT @DBFlag = '1'
								ELSE
									SELECT @DBFlag = SUBSTRING(@DBRightString, 5, 1)
							END
							ELSE
								SELECT @DBFlag = '1'
						END
						ELSE
							SELECT @DBFlag = '0'

						
						IF @Flag = 'Y' AND (@DBFlag = '1') AND @IsAdmin <> 'Y'
						BEGIN
							EXECUTE CheckDataClassNPickListRights @DBUserId, @TempFolderIndex, 'F', @TempDataDefinitionIndex, 2, @IsAdmin OUT, @DBFlag OUT, @DBRightObjectType OUT, @DBStatus OUT
							IF (@DBStatus <> 0)
							BEGIN
								IF @TransactionFlag = 'Y'
									ROLLBACK TRANSACTION TranMoveFolder
								Select 	Stat = @DBStatus ,
									UserRights = @DBLoginUserRights
								Return
							End
						END
						IF (@DBFlag <> '1') 
						BEGIN
							IF @TransactionFlag = 'Y'
								ROLLBACK TRANSACTION TranMoveFolder
							EXECUTE PRTRaiseError 'PRT_ERR_Invalid_Rights_OnFolder', @DBStatus OUT
							SELECT 	Stat 		= @DBStatus ,
								UserRights 	= @DBLoginUserRights,
								LockFlag	= @DBLockFlag,
								CheckOutFlag	= @DBCheckOutFlag
							RETURN
						END

						IF @DBCheckOutFlag = 'N' OR @DBLockFlag = 'N' OR @Flag = 'N'
						BEGIN
							IF (@DBCheckOutFlag = 'N')
							BEGIN	
								IF EXISTS(SELECT  1 FROM PDBDocument A, PDBDocumentContent B
								WHERE 	A.DocumentIndex     = B.DocumentIndex
								AND 	ParentFolderIndex   = @TempFolderIndex
								AND	CheckOutStatus      = 'Y')
								BEGIN
									IF @TransactionFlag = 'Y'
										ROLLBACK TRANSACTION TranMoveFolder
									SELECT @DBCheckOutFlag 	= 'Y'
									SELECT @DBStatus 	= 0
									EXECUTE PRTRaiseError 'PRT_ERR_Document_Check_Out',@DBStatus OUT
									SELECT 	Stat 		= @DBStatus ,
										UserRights 	= @DBLoginUserRights,
										LockFlag	= @DBLockFlag,
										CheckOutFlag	= @DBCheckOutFlag
									RETURN	
								END			
							END

							IF (@DBLockFlag = 'N') AND @SrcFolLock <> 'Y'
							BEGIN
/*
								IF EXISTS(SELECT  1 FROM PDBDocument A, PDBDocumentContent B
								WHERE 	A.DocumentIndex     = B.DocumentIndex
								AND 	ParentFolderIndex   = @TempFolderIndex
								AND	DocumentLock        = 'Y'
								AND	CONVERT(int, RTRIM(SUBSTRING(LockByUser, 1, CHARINDEX('#', A.LockByUser) - 1))) <> @DBUserId
								)
*/
								SELECT TOP 1 	@TempLockMessage = LockMessage,
										@TempDocumentIndex = A.DocumentIndex
								FROM PDBDocument A, PDBDocumentContent B
								WHERE 	A.DocumentIndex     = B.DocumentIndex
								AND 	ParentFolderIndex   = @TempFolderIndex
								AND	DocumentLock        = 'Y'
								AND	CONVERT(int, RTRIM(SUBSTRING(LockByUser, 1, CHARINDEX('#', A.LockByUser) - 1))) <> @DBUserId
								
								IF (@@ROWCOUNT > 0)
								BEGIN
									IF @TransactionFlag = 'Y'
										ROLLBACK TRANSACTION TranMoveFolder
									EXECUTE PRTRaiseError 'PRT_ERR_Document_Locked', @DBStatus OUT
									SELECT 	Status = @DBStatus,
										LockByUser = @EffectiveLockByUser,
										LockMessage	= @TempLockMessage
									RETURN
								END
							END

							IF (@Flag = 'Y') AND (@SecurityLevel = 2) AND (@IsAdmin = 'N')
							BEGIN
		-------------------------------------------------------------------------------------------
		-- Changed By				: Mili Das
		-- Reason / Cause (Bug No if Any)	: Mantis id:0009823 resolved(No rights checking on document dataclass) 
		-- Change Description			: Initialization of the variable @DocPrevIndex was not done.
		-------------------------------------------------------------------------------------------
								SELECT	@DocPrevIndex  = 0
								SELECT 	@DocRowCounter = 1
								WHILE  	@DocRowCounter > 0
								BEGIN
									SELECT TOP 1 	@TempDocumentIndex = A.DocumentIndex, 
											@TempOwner 	   = A.Owner, 
											@TempAccessType    = A.AccessType, 
											@TempACLMore 	   = A.ACLMoreFlag, 
											@TempACL 	   = A.ACL, 
											@TempLockStatus    = A.DocumentLock, 
											@TempCheckedOut    = CheckOutStatus, 
											@TempLockMessage   = A.LockMessage, 
											@DocLockByUser     = A.LockByUser,
											@TempDataDefinitionIndex = A.DataDefinitionIndex,
											@EnableSecure		= EnableSecure
									FROM 	PDBDocumentContent B, PDBDocument A
									WHERE 	B.ParentFolderIndex = @TempFolderIndex
									AND  	B.DocumentIndex > @DocPrevIndex
									AND	A.DocumentIndex = B.DocumentIndex
									ORDER BY B.DocumentIndex ASC
	
									SELECT @DocRowCounter 	= @@ROWCOUNT
									--SELECT @DocPrevIndex 	= 0
						
									IF @DocRowCounter > 0
									BEGIN
										----------------------------------------------------------------------------
										-- Changed By						: Shipra Tiwari
										-- Reason / Cause (Bug No if Any)	: Changes for enable secure flag
										-- Change Description				: Changes for enable secure flag
										-----------------------------------------------------------------------------
										IF (@EnableSecure = 'Y')
										BEGIN
											IF @TransactionFlag = 'Y'
													ROLLBACK TRANSACTION TranMoveFolder
											EXECUTE PRTRaiseError 'PRT_ERR_Invalid_Rights_OnDocument', @DBStatus OUT
											SELECT 	Stat 		= @DBStatus
											RETURN
										END
										
										SELECT @DocPrevIndex 	= @TempDocumentIndex
						
										SELECT 	@IsLatestVersion = 'N'
										SELECT 	@TempLatestVersion = 'N'
										SELECT  @VersionSeries = VersionSeries,
												@TempLatestVersion = LatestVersion
										FROM	PDBNewDocumentVersion
										WHERE	DocumentIndex = @TempDocumentIndex
										IF @@ROWCOUNT = 0
										BEGIN
											SELECT 	@IsLatestVersion = 'Y'
											SELECT	@VersionSeries = NULL
											SELECT	@TempLatestVersion = 'Y'
										END
										ELSE
										BEGIN
											SELECT	@LatVerDocIndex = DocumentIndex
											FROM	PDBDocVersionSeries
											WHERE	VersionSeries = @VersionSeries
											IF @LatVerDocIndex =  @TempDocumentIndex
												SELECT @IsLatestVersion = 'Y'
											ELSE
												SELECT	@IsLatestVersion = 'N'
										END		
										IF @TempLatestVersion = 'N'
										BEGIN
											SELECT	@TempOwner = Owner,
													@TempAccessType = AccessType,
													@TempACLMore = ACLMoreFlag, 
													@TempACL = ACL,
													@LatVerDataDefIndex = DataDefinitionIndex
											FROM	PDBDocument
											WHERE	DocumentIndex = @LatVerDocIndex		
											IF @Flag = 'Y' AND @IsAdmin <> 'Y'
											BEGIN
												EXECUTE PRTCheckRights	 @DBUserId, 'D', @LatVerDocIndex, 5, @DBFlag OUT,
													@TempOwner,TempAccessType,@TempACLMore, @TempACL, @IsAdmin OUT, @DBStatus OUT
												IF (@DBStatus <> 0)
												BEGIN
													IF @TransactionFlag = 'Y'
														ROLLBACK TRANSACTION TranMoveFolder
													SELECT 	Stat = @DBStatus ,
														UserRights = @DBLoginUserRights
													RETURN
												END
												IF (@DBFlag = '1') AND @IsAdmin <> 'Y'
												BEGIN
													EXECUTE CheckDataClassNPickListRights @DBUserId, @LatVerDocIndex, 'D', @LatVerDataDefIndex, 2, @IsAdmin OUT, @DBFlag OUT, @DBRightObjectType OUT, @DBStatus OUT
													IF (@DBStatus <> 0)
													BEGIN
														IF @TransactionFlag = 'Y'
															ROLLBACK TRANSACTION TranMoveFolder
														SELECT 	Stat = @DBStatus ,
															UserRights = @DBLoginUserRights
														RETURN
													END
												END
												IF (@DBFlag <> '1') 
												BEGIN
													IF @TransactionFlag = 'Y'
														ROLLBACK TRANSACTION TranMoveFolder
													EXECUTE PRTRaiseError 'PRT_ERR_Invalid_Rights_OnFolder', @DBStatus OUT
													SELECT 	Stat 		= @DBStatus ,
														UserRights 	= @DBLoginUserRights,
														LockFlag	= @DBLockFlag,
														CheckOutFlag	= @DBCheckOutFlag
													RETURN
												END
											END
										END
										ELSE
										BEGIN
											IF (@DBUserId = @TempOwner) OR (@SecurityLevel = 0) OR (@IsAdmin = 'Y') OR(@Flag = 'N' )
												SELECT @DBFlag = '1'
											ELSE IF (@SecurityLevel = 1) OR (@TempAccessType = 'I')
												SELECT @DBFlag = '1'
											ELSE IF (@TempAccessType = 'P') 
												SELECT @DBFlag = '0'
											ELSE IF (@TempAccessType = 'S')
											BEGIN
												IF @TempACL IS NOT NULL
												BEGIN
													IF (@TempACLMore  = 'N')
														EXECUTE PRTGetUserRightsFromCatche
														@DBUserId, @TempACL, @DBRightString OUT,@TempDataDefinitionIndex
													ELSE
														EXECUTE PRTGetUserSharedRights @DBUserId, @TempACL,
															'D', @TempDocumentIndex, @DBRightString out,
														@DBStatus OUT,@TempDataDefinitionIndex
													IF @DBRightString IS NULL
														SELECT @DBFlag = '1'
													ELSE
														SELECT @DBFlag = SUBSTRING(@DBRightString, 5, 1)
												END
												ELSE
													SELECT @DBFlag = '1'
											END
											ELSE
												SELECT @DBFlag = '0'
											
											IF @Flag = 'Y' AND(@DBFlag = '1') AND @IsAdmin <> 'Y'
											BEGIN
												EXECUTE CheckDataClassNPickListRights @DBUserId, @TempDocumentIndex, 'D', @TempDataDefinitionIndex, 2, @IsAdmin OUT, @DBFlag OUT, @DBRightObjectType OUT, @DBStatus OUT
												IF (@DBStatus <> 0)
												BEGIN
													IF @TransactionFlag = 'Y'
														ROLLBACK TRANSACTION TranMoveFolder
													SELECT 	Stat = @DBStatus ,
														UserRights = @DBLoginUserRights
													RETURN
												END
											END
											IF (@DBFlag <> '1') 
											BEGIN
												IF @TransactionFlag = 'Y'
													ROLLBACK TRANSACTION TranMoveFolder
												EXECUTE PRTRaiseError 'PRT_ERR_Invalid_Rights_OnFolder', @DBStatus OUT
												SELECT 	Stat 		= @DBStatus ,
													UserRights 	= @DBLoginUserRights,
													LockFlag	= @DBLockFlag,
													CheckOutFlag	= @DBCheckOutFlag
												RETURN
											END
										END	
									END
								END
							END
						END

						INSERT INTO @TempFolderTable VALUES(@TempFolderIndex, @TempParentFolderIndex, @TempFolderType, @LeafCounter,@TempFolderName)
						SELECT @FolderListId 			=  @FolderListId + ',' + CONVERT(varchar(10), @TempFolderIndex)
						SELECT @TotalFolderCount		= @TotalFolderCount + 1
						SELECT @SubTempFolderListCount 	= @SubTempFolderListCount + 1
						SELECT @SubTempFolderListId 	= @SubTempFolderListId + CONVERT(varchar(10), @TempFolderIndex) + ','

					END
				END
			END
		END
		SELECT @TempFolderListId 		= @SubTempFolderListId 
		SELECT @TempFolderListCount 	= @SubTempFolderListCount
		SELECT @ParRowCounter			= @SubTempFolderListCount
	END
	insert into t1 values('@AdjLockByUser')
	insert into t1 values(@AdjLockByUser)
	insert into t1 values('@SrcLockByUser')
	insert into t1 values(@SrcLockByUser)
	IF @AdjLockByUser IS NOT NULL
	BEGIN
		IF @SrcLockByUser IS NOT NULL
		BEGIN
			UPDATE PDBFolder
			SET     FolderLock = 'Y',
				LockByUser = (
					SELECT CASE ISNULL(CHARINDEX(@SrcLockByUser, LockByUser), -1)
					WHEN 0 THEN
						RTRIM(@AdjLockByUser) + RTRIM(LockByUser)
					WHEN -1 THEN
						RTRIM(@AdjLockByUser)
					ELSE @AdjLockByUser + SUBSTRING(LockByUser, CHARINDEX(@SrcLockByUser, LockByUser) + LEN(@SrcLockByUser), 255)
					END
				)
			WHERE FolderIndex IN(
				SELECT FolderIndex FROM @TempFolderTable
			)
		
			UPDATE PDBDocument
			SET     DocumentLock = 'Y',
				LockByUser = (
					SELECT CASE ISNULL(CHARINDEX(@SrcLockByUser, LockByUser), -1)
					WHEN 0 THEN
						RTRIM(@AdjLockByUser) + RTRIM(LockByUser)
					WHEN -1 THEN
						RTRIM(@AdjLockByUser)
					ELSE @AdjLockByUser + SUBSTRING(LockByUser, CHARINDEX(@SrcLockByUser, LockByUser) + LEN(@SrcLockByUser), 255)
					END
				)
			WHERE DocumentIndex IN(
				SELECT DocumentIndex FROM PDBDocumentContent
				WHERE ParentFolderIndex IN  
					(SELECT FolderIndex FROM @TempFolderTable)
				AND RefereceFlag = 'O'
			)
			AND NOT EXISTS(
				SELECT 1 FROM PDBNewDocumentVersion
				WHERE PDBDocument.DocumentIndex = PDBNewDocumentVersion.DocumentIndex
				AND PDBNewDocumentVersion.LatestVersion = 'N' 
			)
			
		END
		ELSE
		BEGIN
			UPDATE PDBFolder
			SET     FolderLock = 'Y',
				LockByUser = RTRIM(@AdjLockByUser) + ISNULL(RTRIM(LockByUser), '')
			WHERE FolderIndex IN(
				SELECT FolderIndex FROM @TempFolderTable
			)
			UPDATE PDBDocument
			SET     DocumentLock = 'Y',
				LockByUser = RTRIM(@AdjLockByUser) + ISNULL(RTRIM(LockByUser), '')
			WHERE DocumentIndex IN(
				SELECT DocumentIndex FROM PDBDocumentContent
				WHERE ParentFolderIndex IN  
					(SELECT FolderIndex FROM @TempFolderTable)
				AND RefereceFlag = 'O'
			)
			AND NOT EXISTS(
				SELECT 1 FROM PDBNewDocumentVersion
				WHERE PDBDocument.DocumentIndex = PDBNewDocumentVersion.DocumentIndex
				AND PDBNewDocumentVersion.LatestVersion = 'N' 
			)
		END
	END
	ELSE
	BEGIN
		IF @SrcLockByUser IS NOT NULL
		BEGIN
			UPDATE PDBFolder
			SET LockByUser = (
					SELECT CASE ISNULL(LEN(SUBSTRING(LockByUser, CHARINDEX(@SrcLockByUser, LockByUser) + LEN(@SrcLockByUser), 255)), -1)
					WHEN 0 THEN NULL
					WHEN -1 THEN NULL
					ELSE SUBSTRING(LockByUser, CHARINDEX(@SrcLockByUser, LockByUser) + LEN(@SrcLockByUser), 255)
					END
			),
			    FolderLock = (
					SELECT CASE ISNULL(LEN(SUBSTRING(LockByUser, CHARINDEX(@SrcLockByUser, LockByUser) + LEN(@SrcLockByUser), 255)), -1)
					WHEN 0 THEN 'N'
					WHEN -1 THEN 'N'
					ELSE 'Y'
					END
				)
			WHERE FolderIndex IN(
				SELECT FolderIndex FROM @TempFolderTable
			)

			UPDATE PDBDocument
			SET LockByUser = (
					SELECT CASE ISNULL(LEN(SUBSTRING(LockByUser, CHARINDEX(@SrcLockByUser, LockByUser) + LEN(@SrcLockByUser), 255)), -1)
					WHEN 0 THEN NULL
					WHEN -1 THEN NULL
					ELSE SUBSTRING(LockByUser, CHARINDEX(@SrcLockByUser, LockByUser) + LEN(@SrcLockByUser), 255)
					END
			),
			    DocumentLock = (
					SELECT CASE ISNULL(LEN(SUBSTRING(LockByUser, CHARINDEX(@SrcLockByUser, LockByUser) + LEN(@SrcLockByUser), 255)), -1)
					WHEN 0 THEN 'N'
					WHEN -1 THEN 'N'
					ELSE 'Y'
					END
				)
			WHERE DocumentIndex IN(
				SELECT DocumentIndex FROM PDBDocumentContent
				WHERE ParentFolderIndex IN  
					(SELECT FolderIndex FROM @TempFolderTable)
				AND RefereceFlag = 'O'
			)
			AND NOT EXISTS(
				SELECT 1 FROM PDBNewDocumentVersion
				WHERE PDBDocument.DocumentIndex = PDBNewDocumentVersion.DocumentIndex
				AND PDBNewDocumentVersion.LatestVersion = 'N' 
			)
		END
	END

	EXECUTE GenerateName 'F', @SrcFolderName, @TempDBDestFolderIndex, 
				 NULL, NULL, @NameLength, @MainGroupIndex,
				 @DuplicateNameFlag, @DBMoveFolderIndex, NULL,
				 @SrcFolderName OUT, @DBStatus OUT
	IF @DBStatus <> 0
	BEGIN		
		IF @TransactionFlag = 'Y'
			ROLLBACK TRANSACTION TranMoveFolder	
		SELECT 	Stat = @DBStatus
		RETURN
	END

	--EXECUTE GenerateAlarm @DBUserId,'F',@DBMoveFolderIndex,17,@CurrentDate,@SrcFolderName,@TempDBDestFolderIndex

	OPEN RecCur1
	FETCH NEXT FROM RecCur1 INTO @TempFolderIndex,@TempFolderName,@TempParentFolId
	WHILE (@@FETCH_STATUS <> -1)
	BEGIN
		IF (@@FETCH_STATUS <> -2)
		BEGIN
			IF @DestLocation <> 'T'
			BEGIN
				EXECUTE GenerateAlarm @DBUserId,'F',@TempFolderIndex,18,@CurrentDate,@TempFolderName,@TempParentFolId	
				
				DELETE FROM PDBAlarm WHERE ObjectId = @TempFolderIndex 
					AND ObjectType = 'F' AND AlarmInheritance = 'Y'	
					
				INSERT INTO PDBAlarm(AlarmType,ObjectType,ObjectId,ObjectName,ActionType,	
				AlarmDateTime,SetForUserId,SetForUserName,SetByUser,SetByUserName,
				DocumentType,InformMode,AlarmInheritance,ParentAlarmIndex)
				SELECT 'U','F',@TempFolderIndex,@TempFolderName,ActionType,
				@CurrentDate,SetForUserId,SetForUserName,SetByUser,SetByUserName,
				DocumentType,InformMode,AlarmInheritance, CASE ParentAlarmIndex WHEN 0 THEN AlarmIndex ELSE ParentAlarmIndex END
				FROM PDBAlarm
				WHERE ObjectId = @TempDBDestFolderIndex 
				AND ObjectType = 'F'	
				AND AlarmInheritance = 'Y'
			END
			ELSE IF @DestLocation = 'T'
			BEGIN
				EXECUTE GenerateAlarm @DBUserId,'F',@TempFolderIndex,19,@CurrentDate,@TempFolderName,@TempParentFolId
			END
		END
		FETCH NEXT FROM RecCur1 INTO @TempFolderIndex,@TempFolderName,@TempParentFolId
	END	
	CLOSE RecCur1
	DEALLOCATE RecCur1


	IF(@DestFolderType <> 'T')
	BEGIN
/*
		EXECUTE GenerateName 'F', @SrcFolderName, @TempDBDestFolderIndex, 
				     NULL, NULL, @NameLength, @MainGroupIndex,
				     @DuplicateNameFlag, @SrcFolderName OUT, @DBStatus OUT
		IF @DBStatus <> 0
		BEGIN		
			IF @TransactionFlag = 'Y'
				ROLLBACK TRANSACTION TranMoveFolder	
			SELECT 	Stat = @DBStatus
			RETURN
		END
*/
		UPDATE PDBFolder
		SET 	Name 		  = @SrcFolderName,
			ParentFolderIndex = @TempDBDestFolderIndex,
			AccessedDateTime  = @CurrentDate,
			RevisedBy		  = @DBUserId,
			RevisedDateTime   = @CurrentDate,
			Location 	  = @DestFolderType,
			ESTimeStamp = @DBDateTimeStr,
			ESFlag = 'U'
		WHERE FolderIndex = @DBMoveFolderIndex
		
		Update PDBFolderName set Name = @SrcFolderName where FolderIndex = @DBMoveFolderIndex
		
	END
	ELSE
	BEGIN
/*
		EXECUTE GenerateName 'F', @SrcFolderName, @TempDBDestFolderIndex, NULL, NULL,
				     @NameLength, @MainGroupIndex, 
				     @DuplicateNameFlag, @SrcFolderName OUT, @DBStatus OUT
		IF @DBStatus <> 0
		BEGIN					
			IF @TransactionFlag = 'Y'
				ROLLBACK TRANSACTION TranMoveFolder	
			SELECT 	Stat = @DBStatus
			RETURN
		 END
*/
		UPDATE PDBFolder
		SET 	Name 		  = @SrcFolderName,
			ParentFolderIndex = @TempDBDestFolderIndex,
			AccessedDateTime  = @CurrentDate,
			RevisedDateTime   = @CurrentDate,
			Location 	  = @DestFolderType,
			DeletedDateTime   = @CurrentDate,
			ESTimeStamp = @DBDateTimeStr,
			ESFlag = 'U'
		WHERE FolderIndex = @DBMoveFolderIndex
		IF (@@ERROR <>0)
		BEGIN
			IF @TransactionFlag = 'Y'
				ROLLBACK TRANSACTION TranMoveFolder
			RETURN
		END
		
		IF(@DeleteReferences = 'Y')
		BEGIN
			DECLARE FoldRefCur CURSOR fast_forward FOR 
					SELECT ParentFolderIndex  
					FROM PDBFolderContent 
					WHERE FolderIndex = @DBMoveFolderIndex
					
			OPEN FoldRefCur 
			FETCH NEXT FROM FoldRefCur INTO @RefFoldIndex 
			WHILE(@@FETCH_STATUS <> -1) 
			BEGIN 
				IF @@FETCH_STATUS <> -2 
				BEGIN 
					Execute PRTReference 	@DBUserId, @DBDate, 
						'F', @DBMoveFolderIndex, 
						@RefFoldIndex,'D', 
						@MainGroupID, @IsAdmin, NULL, 
						@DBStatus   OUT, @DBAppInfo, @DBAppName
					IF(@DBStatus <> 0) 
					BEGIN
						IF @TransactionFlag = 'Y'
							ROLLBACK TRANSACTION TranMoveFolder	
						CLOSE FoldRefCur 
						DEALLOCATE FoldRefCur
						SELECT 	Stat = @DBStatus
						RETURN
					END 
				END 
				FETCH NEXT FROM FoldRefCur INTO @RefFoldIndex 
			END 
			CLOSE FoldRefCur 
			DEALLOCATE FoldRefCur 
		END
	END			
/*
	UPDATE A
	SET 	Location 	= @DestFolderType,
		FolderLevel	= @DestFolderLevel + (@SrcFolderLevel - FolderLevel) + 1,
		Hierarchy   	= REPLACE(Hierarchy, @OldHierarchy, @NewHierarchy)	
	FROM PDBFolder A
	WHERE EXISTS(
		SELECT FolderIndex FROM @TempFolderTable B WHERE A.FolderIndex = B.FolderIndex)
*/
--SELECT * FROM @TempFolderTable

	IF @TotalFolderCount > 700
	BEGIN
		UPDATE A
		SET 	Location 	= @DestFolderType,
			FolderLevel	= @DestFolderLevel + (@SrcFolderLevel - FolderLevel) + 1,
			Hierarchy   	= REPLACE(Hierarchy, @OldHierarchy, @NewHierarchy)	
		FROM @TempFolderTable B, PDBFolder A 
		WHERE B.FolderIndex = A.FolderIndex
	END
	ELSE
	BEGIN
		SELECT 	@DestFolderLevelStr = CONVERT(varchar(10),  @DestFolderLevel) 
		SELECT 	@SrcFolderLevelStr = CONVERT(varchar(10),  @SrcFolderLevel) 

		EXECUTE ( ' UPDATE PDBFolder
			SET 	Location 	= ''' + @DestFolderType + ''' , ' +
				' FolderLevel	= ' + @DestFolderLevelStr + ' + ' + @SrcFolderLevelStr + ' - FolderLevel + 1 , ' +
				' Hierarchy   	= REPLACE(Hierarchy, ''' + @OldHierarchy + ''' , ''' + @NewHierarchy +  ''' ) ' +	
			' WHERE FolderIndex IN (' + @FolderListId + ' ) ')
	END
-------------------------------------------------------------------------------------------
-- Changed By				: Mili Das
-- Reason / Cause (Bug No if Any)	: Changes for implemetation of Owner Inheritance.
-- Change Description			: Changes for implemetation of Owner Inheritance.
-------------------------------------------------------------------------------------------
		CREATE TABLE #TempFolderListTable (
					FolderIndex 		int,
					ParentFolderIndex 	int,
					FolderType 		char(1),
					Leaf			int)

	
		IF @IsAdmin = 'Y'
		BEGIN
			EXECUTE PRTGetListinTable1 @DBUserId, @DBMoveFolderIndex, '#TempFolderListTable', 0, 'Y', @HasRight OUT, @TempFoldLock OUT, @TempDocLock OUT, @TempDocCheckOut OUT, @TempHasRightsOnDoc OUT
		END
		ELSE
		BEGIN
			EXECUTE PRTGetListinTable1 @DBUserId, @DBMoveFolderIndex, '#TempFolderListTable', 4, 'Y', @HasRight OUT, @TempFoldLock OUT, @TempDocLock OUT, @TempDocCheckOut OUT, @TempHasRightsOnDoc OUT

			IF @HasRight = 'N'
			BEGIN
				IF @TransactionFlag = 'Y'
				BEGIN
					ROLLBACK TRANSACTION TranMoveFolder
					Execute PRTRaiseError 				'PRT_ERR_Invalid_Rights_OnFolder', @DBStatus OUT
					Select 	Stat = @DBStatus,
						UserRights = @DBLoginUserRights
						
					RETURN
				END
			END
			IF @TempHasRightsOnDoc = 'N'
			BEGIN
				IF @TransactionFlag = 'Y'
				BEGIN
					ROLLBACK TRANSACTION TranMoveFolder
					EXECUTE PRTRaiseError 'PRT_ERR_Invalid_Rights_OnDocument',@DBStatus OUT
					Select 	Stat = @DBStatus,
						UserRights = @DBLoginUserRights
						
					RETURN
				END
			END
		END
		IF @TempFoldLock = 'Y'
		BEGIN
			IF @TransactionFlag = 'Y'
				ROLLBACK TRANSACTION TranMoveFolder
			EXECUTE PRTRaiseError 'PRT_ERR_Folder_Locked', @DBStatus OUT
			SELECT 	Status = @DBStatus,
				LockByUser = @EffectiveLockByUser,
				LockMessage	= @LockMessage
			RETURN
		END

		IF @TempDocLock = 'Y'
		BEGIN
			IF @TransactionFlag = 'Y'
				ROLLBACK TRANSACTION TranMoveFolder
			EXECUTE PRTRaiseError 'PRT_ERR_Document_Locked', @DBStatus OUT
			SELECT 	Status = @DBStatus,
				LockByUser = @EffectiveLockByUser,
				LockMessage	= @LockMessage
			RETURN
		END
		IF @TempDocCheckOut = 'Y'
		BEGIN
			IF @TransactionFlag = 'Y'
				ROLLBACK TRANSACTION TranMoveFolder
			Execute PRTRaiseError  'PRT_ERR_Document_Check_Out', @DBStatus OUT
			SELECT 	status = @DBStatus 
			Return
		END
		IF @SrcOwnerInheritance='I'
		BEGIN
			IF ((ISNULL(@DBOwnerInheritanceFlag,'E') = 'E') OR (@DBOwnerInheritanceFlag = 'I'))
			BEGIN
				
				UPDATE PDBFolder 
				SET Owner = @DestOwner, 
					ESTimeStamp = @DBDateTimeStr,
					ESFlag = 'U'
				WHERE FolderIndex IN 
					(SELECT FolderIndex FROM #TempFolderListTable)

				UPDATE PDBDocument SET Owner = @DestOwner, ESTimeStamp = @DBDateTimeStr, ESFlag = 'U'
				WHERE DocumentIndex IN (SELECT A.DocumentIndex FROM PDBDocument A, PDBDocumentContent B, PDBFolder C WHERE A.DocumentIndex = B.DocumentIndex AND B.ParentFolderIndex = C.FolderIndex AND  C.FolderIndex IN (SELECT FolderIndex FROM #TempFolderListTable))

			END
			ELSE
			BEGIN
				IF ((ISNULL(@DBIncludesubFolder,'E') = 'E') OR (@DBIncludesubFolder = 'Y'))
					UPDATE PDBFolder 
					SET OwnerInheritance = 'N',ESTimeStamp = @DBDateTimeStr, ESFlag = 'U'
					WHERE FolderIndex IN 
					(SELECT FolderIndex FROM #TempFolderListTable)
				ELSE
					UPDATE PDBFolder 
					SET    OwnerInheritance = 'N',ESTimeStamp = @DBDateTimeStr, ESFlag = 'U'
					WHERE FolderIndex = @DBMoveFolderIndex
				
			END
		END
		ELSE
		BEGIN
			
			IF @DBOwnerInheritanceFlag='I'
			BEGIN

				IF ((ISNULL(@DBIncludesubFolder,'E') = 'E') OR (@DBIncludesubFolder = 'Y'))
				BEGIN
					UPDATE PDBFolder 
					SET Owner = @DestOwner,OwnerInheritance = 'I',ESTimeStamp = @DBDateTimeStr, ESFlag = 'U' 
					WHERE FolderIndex IN 
						(SELECT FolderIndex FROM @TempFolderTable)

					UPDATE PDBDocument SET Owner = @DestOwner,ESTimeStamp = @DBDateTimeStr, ESFlag = 'U'
					WHERE DocumentIndex IN (SELECT A.DocumentIndex FROM PDBDocument A, PDBDocumentContent B, PDBFolder C WHERE A.DocumentIndex = B.DocumentIndex AND B.ParentFolderIndex = C.FolderIndex AND  C.FolderIndex IN (SELECT FolderIndex FROM @TempFolderTable))

				END
				ELSE
				BEGIN
					UPDATE PDBFolder 
					SET    OwnerInheritance = 'I' ,ESTimeStamp = @DBDateTimeStr, ESFlag = 'U'
					WHERE FolderIndex = @DBMoveFolderIndex

					UPDATE PDBFolder 
					SET Owner = @DestOwner,ESTimeStamp = @DBDateTimeStr, ESFlag = 'U'
					WHERE FolderIndex IN 
						(SELECT FolderIndex FROM #TempFolderListTable)

					UPDATE PDBDocument SET Owner = @DestOwner,ESTimeStamp = @DBDateTimeStr, ESFlag = 'U'
					WHERE DocumentIndex IN (SELECT A.DocumentIndex FROM PDBDocument A, PDBDocumentContent B, PDBFolder C WHERE A.DocumentIndex = B.DocumentIndex AND B.ParentFolderIndex = C.FolderIndex AND  C.FolderIndex IN (SELECT FolderIndex FROM #TempFolderListTable))

				END
			END
		END
		DROP TABLE #TempFolderListTable

		SELECT @SrcOwner=OWNER FROM PDBfolder WHERE FolderIndex = @DBMoveFolderIndex

--SELECT TotalFolderCount = @TotalFolderCount
-------------------------------------------------------------------------------------------
-- Changed By				: Mili Das
-- Reason / Cause (Bug No if Any)	: Chages for Audit log enhancement(Support for VERS)(ERC 150)
-- Change Description			: Chages for Audit log enhancement(Support for VERS)(ERC 150)
-------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
-- Changed By				: Mili Das
-- Reason / Cause (Bug No if Any)	: Changes for Audit Trail Unification
-- Change Description			: Changes for Audit Trail Unification
------------------------------------------------------------------------------------------------

	SELECT 	@OldList	= @OldList + 'ParentFolderIndex = '+ rtrim(@SrcParentFolderIndex) 
	SELECT 	@NewList	= @NewList + 'ParentFolderIndex = '+ rtrim(@TempDBDestFolderIndex)

	SELECT @OldParentFold=Name FROM PDBFolder
	WHERE FolderIndex=@SrcParentFolderIndex

	SELECT @NewParentFold=Name FROM PDBFolder
	WHERE FolderIndex=@TempDBDestFolderIndex
		
	SELECT @lcomment1 = RTRIM(@TempDBDestFolderIndex) + CHAR(124) + RTRIM(@SrcFolderName)+ CHAR(124) + RTRIM(@OldParentFold)+ CHAR(124) + RTRIM(@NewParentFold)

------------------------------------------------------------------------------------------------
-- Changed By						: Swati Gupta
-- Reason / Cause (Bug No if Any)	: Changes for Audit Log Enhancement(IP Address)
-- Change Description				: Changes for Audit Log Enhancement(IP Address)
------------------------------------------------------------------------------------------------
	EXECUTE PRTGeneratelog @DBUserId, @DBDate, 208, @SrcParentFolderIndex, 'F',@OldParentFold,NULL,@MainGroupId,@OldList,@NewList,'F',@lcomment1,@DBMoveFolderIndex,'F', @SrcFolderName, @DBAppInfo, @DBAppName


	SELECT @lcomment2 = RTRIM(@SrcParentFolderIndex) + CHAR(124) + RTRIM(@SrcFolderName)+ CHAR(124) + RTRIM(@OldParentFold)+ CHAR(124) + RTRIM(@NewParentFold)

	EXECUTE PRTGeneratelog @DBUserId, @DBDate, 209, @TempDBDestFolderIndex, 'F',@NewParentFold,NULL,@MainGroupId,@OldList,@NewList,'F',@lcomment2,@DBMoveFolderIndex,'F', @SrcFolderName, @DBAppInfo, @DBAppName

	EXECUTE PRTGeneratelog @DBUserId, @DBDate, 210, @DBMoveFolderIndex, 'F',@SrcFolderName,NULL,@MainGroupId,@OldList,@NewList,'F',@lcomment1,@SrcParentFolderIndex,'F', @OldParentFold, @DBAppInfo, @DBAppName
		
	IF @TransactionFlag = 'Y'
		COMMIT TRANSACTION TranMoveFolder
	IF (@IsAdmin = 'Y')
	BEGIN
		SELECT @DBLoginUserRights = REPLICATE('1',10)
	END
	ELSE
	BEGIN
		EXECUTE PRTGetRights	@DBUserId, 'F', @DBMoveFolderIndex,@DBLoginUserRights OUT , 
			@SrcOwner,@SrcAccessType,@SrcACLMoreFlag, @SrcACL, @IsAdmin OUT, @DBStatus OUT
	END
	SELECT 	Stat 		= @DBStatus ,
		UserRights 	= @DBLoginUserRights,
		LockFlag	= @DBLockFlag,
		CheckOutFlag	= @DBCheckOutFlag
--	EXECUTE PRTDocumentAllProp11 @DBDate, 'Y' , 'F' , @DBMoveFolderIndex, NULL, NULL, NULL

-------------------------------------------------------------------------------------------
-- Changed By						: 	Jitendra Kumar
-- Reason / Cause (Bug No if Any)	: 	Hierarchy Of Folder
-- Change Description				: 	TO Get Hierarchy Of Folder  
-------------------------------------------------------------------------------------------

	SELECT 	FolderIndex,ParentFolderIndex,Name,Owner,CreatedDatetime,RevisedDateTime,
		AccessedDateTime,DataDefinitionIndex,AccessType,ImageVolumeIndex,FolderType,
		FolderLock,CONVERT(int, RTRIM(SUBSTRING(LockByUser, 1, CHARINDEX('#', LockByUser) - 1))),Location,DeletedDateTime,EnableVersion,ExpiryDateTime,
		Comment,UseFulData,ACL,FinalizedFlag,FinalizedDateTime,FinalizedBy,ACLMoreFlag,EnableFTS,
		LockMessage,Hierarchy  
	From PDBFolder 
	WHERE FolderIndex = @DBMoveFolderIndex

	SELECT @OwnerName = UserName FROM PDBUser WHERE UserIndex = @SrcOwner

	IF @SrcLockByUser IS NOT NULL
	BEGIN
		SELECT @SrcLockByUser = UserName FROM PDBUser WHERE UserIndex = CONVERT(int, RTRIM(SUBSTRING(@SrcLockByUser, 1, CHARINDEX('#', @SrcLockByUser) - 1)))
	END

	IF @SrcFinalizedBy > 0
	BEGIN
		SELECT @SrcFinalizedBy = UserName FROM PDBUser WHERE UserIndex = @SrcFinalizedBy
	END

	IF @SrcDataDefinitionIndex > 0
	BEGIN
		SELECT @DataDefName= DataDefName FROM PDBDataDefinition WHERE DatadefIndex = @SrcDataDefinitionIndex
	END

	SELECT 	OWNER 		= @OwnerName, 
		LOCKBYUSER 	= @SrcLockByUser, 
		FINALISEDBY 	= @SrcFinalizedBy, 
		DataDefName 	= @DataDefName 



		SELECT @NoOfSubFolders = count(*) from pdbfolder a
			where a.parentfolderindex = @DBMoveFolderIndex
		
		SELECT @NoOfDocs = count(*) from pdbdocumentcontent a
			where a.parentfolderindex = @DBMoveFolderIndex
			and RefereceFlag = 'O'

		SELECT @NoOfRefDocs = count(*) from pdbdocumentcontent a
			where a.parentfolderindex = @DBMoveFolderIndex
			and RefereceFlag = 'R'

		SELECT @NoOfRefFolders = count(*) from pdbfoldercontent a
			where a.parentfolderindex = @DBMoveFolderIndex

		SELECT 	NoOfSubFolders = @NoOfSubFolders, NoOfDocs = @NoOfDocs,
			NoOfRefDocs = @NoOfRefDocs, NoOfRefFolders = @NoOfRefFolders
	SELECT @DBUseFull_InfoOnly = 'Y'
	IF (@SrcDataDefinitionIndex  > 0 AND @DBUseFull_InfoOnly =  'Y')
	BEGIN
		SELECT a.DataDefName,
			a.DataDefComment,
			c.DataFieldIndex,
			c.DataFieldName,
			c.DataFieldType,
			c.DataFieldlength,
			b.FieldAttribute,
			Value = NULL,
			C.GlobalOrDataFlag, 
			b.UsefulInfoFlag
		FROM PDBDataDefinition a, PDBDataFieldsTable b, PDBglobalindex c
		WHERE a.DataDefIndex = b.DataDefIndex
		AND b.DatafieldIndex = c.DatafieldIndex
		AND a.DataDefIndex  = @SrcDataDefinitionIndex
		order by b.FieldOrder
		SELECT @Valcount = @@rowcount

		DECLARE @FoldDocTable 		varchar(64)
			SELECT @FoldDocTable = 'DDT_'+CONVERT(varchar(20),@SrcDataDefinitionIndex)

			/* Check if Tablename already exists */
			IF EXISTS (SELECT * FROM sysobjects
				WHERE NAME = @FoldDocTable AND Type = 'U')
			BEGIN
			SELECT TableExists = 'Y'
			END
	END

	RETURN

