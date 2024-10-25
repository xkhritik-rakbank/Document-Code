
ALTER  PROCEDURE [dbo].[RAK_TWC_CreditPolicyBreach]
(
    @FromDate  VARCHAR(50),
	@ToDate  VARCHAR(50), 
    @BatchingReq NVARCHAR(5),
    @BatchSize NVARCHAR(20),
    @OrderBy INT, 
    @SortField NVARCHAR(64), 
    @SortFieldValue NVARCHAR(64), 
    @SortOrder NVARCHAR(5), 
    @KeyField NVARCHAR(64)
)
AS 
BEGIN
    DECLARE @QueryString NVARCHAR(MAX)
    DECLARE @WhereClause NVARCHAR(1000)
    DECLARE @ErrorMessage NVARCHAR(4000)
	create table #CreditPolicyBreach(
	    "APPROVAL DATE" NVARCHAR(200),
	    "APPROVING AUTHORITY" NVARCHAR(200),
		"WI_NAME" NVARCHAR(100),
		"DIVISION" NVARCHAR(100),
		"CIF" NVARCHAR(100),
		"CUSTOMER NAME"NVARCHAR(200),
		"PROPOSAL TYPE" NVARCHAR(200),
		"PRODUCT TYPE (TWC/FIGP/CRE/ABF)" NVARCHAR(200),
		"TOTAL CUSTOMER LIMIT APPROVED(AED 000)" NVARCHAR(200),
		"CREDIT POLICY BREACH  (Y/N)"  NVARCHAR(100),
		"POLICY BREACH DETAILS" NVARCHAR(200),
		"NEW/EXISTING" NVARCHAR(200)
		)

    BEGIN 
        -- Initialize query string and where clause
        SET @QueryString = ''
        SET @WhereClause = ''
		set @FromDate = @FromDate+' 00:00:00.000'
		set @ToDate = @ToDate+' 23:59:59.999'

        -- Log the initial state
        PRINT 'Starting Procedure Execution'
        PRINT 'BatchingReq: ' + @BatchingReq
        PRINT 'BatchSize: ' + @BatchSize
        PRINT 'OrderBy: ' + CAST(@OrderBy AS NVARCHAR)
        PRINT 'SortField: ' + @SortField
        PRINT 'SortFieldValue: ' + @SortFieldValue
        PRINT 'SortOrder: ' + @SortOrder
        PRINT 'KeyField: ' + @KeyField

        -- Build the main query
        SET @QueryString = 'WITH CTE AS (
								SELECT 
									WI_NAME,Product_Identifier,
									CAST(SUBSTRING(Product_Identifier, 1, CHARINDEX(''|'', Product_Identifier + ''|'') - 1) AS VARCHAR(100)) AS SplitValue,
									CAST(STUFF(Product_Identifier, 1, CHARINDEX(''|'', Product_Identifier + ''|''), '''') AS VARCHAR(MAX)) AS RemainingString
								FROM RB_TWC_EXTTABLE

								UNION ALL

								SELECT 
									WI_NAME, Product_Identifier,
									CAST(SUBSTRING(RemainingString, 1, CHARINDEX(''|'', RemainingString + ''|'') - 1) AS VARCHAR(100)),
									CAST(STUFF(RemainingString, 1, CHARINDEX(''|'', RemainingString + ''|''), '''') AS VARCHAR(MAX))
								FROM CTE
								WHERE RemainingString != ''''
							)
		                    SELECT  B.actiondatetime as [APPROVAL DATE],
                     		A.FinalCreditApproverAuth as [APPROVING AUTHORITY],
							A.WI_NAME,
		                    A.CHANNEL as [DIVISION],
							A.CIF_Id as [CIF],
							A.Customer_Name AS [CUSTOMER NAME],
							A.Request_Type as [PROPOSAL TYPE],
							C.Product_Types as [PRODUCT TYPE (TWC/FIGP/CRE/ABF)],
							A.Master_Facility_Limit  as [TOTAL CUSTOMER LIMIT APPROVED(AED 000)], 
							A.Breach_Deviation  AS  [CREDIT POLICY BREACH  (Y/N)],
							C.Description_of_Breach_Deviation as [POLICY BREACH DETAILS],
							C.Type_of_Breach_Deviation as [NEW/EXISTING] 
						FROM 
							RB_TWC_EXTTABLE AS A
							 LEFT JOIN USR_0_TWC_WIHISTORY AS B ON A.[WI_NAME]=B.winame
							JOIN USR_0_TWC_Credit_Policy_GRID as C on A.WI_NAME = C.WINAME
					    WHERE
						    
							B.actiondatetime BETWEEN '''+@FromDate+''' and '''+@ToDate+'''
							and A.CHANNEL =''BBG-SME'' and A.Breach_Deviation = ''Yes''
							and B.wsname=''Credit_Analyst'' and B.decision=''Approve''
							
							
					 UNION  ALL 
				      
					 SELECT   B.actiondatetime as [APPROVAL DATE],
                     		A.FinalCreditApproverAuth as [APPROVING AUTHORITY],
							A.WI_NAME,
		                    A.CHANNEL as [DIVISION],
							A.CIF_Id as [CIF],
							A.Customer_Name AS [CUSTOMER NAME],
							A.Request_Type as [PROPOSAL TYPE],
							 C.SplitValue as [PRODUCT TYPE (TWC/FIGP/CRE/ABF)],
							A.Master_Facility_Limit  as [TOTAL CUSTOMER LIMIT APPROVED(AED 000)], 
							(CASE WHEN A.Breach_Deviation = '''' THEN ''No'' else A.Breach_Deviation END)  AS  [CREDIT POLICY BREACH  (Y/N)],
							'''' as [POLICY BREACH DETAILS],
							'''' as [NEW/EXISTING] 
							
						FROM 
							RB_TWC_EXTTABLE AS A
							JOIN USR_0_TWC_WIHISTORY AS B ON A.[WI_NAME]=B.winame
							JOIN CTE AS C ON B.winame=C.WI_NAME
						WHERE
							B.actiondatetime BETWEEN '''+@FromDate+''' and '''+@ToDate+'''
							and A.CHANNEL = ''BBG-SME'' and (A.Breach_Deviation = ''No'' OR A.Breach_Deviation = '''')
							and B.wsname=''Credit_Analyst'' and B.decision=''Approve''
							and C.Product_Identifier IS NOT NULL
							ORDER BY actiondatetime DESC OPTION (MAXRECURSION 0);' 
END
        -- Log the main query before any modifications
        PRINT 'Main Query: ' + @QueryString

		INSERT #CreditPolicyBreach exec (@QueryString)
	
IF @OrderBy ='2'
  	BEGIN	
	
	PRINT @OrderBy

	SELECT * FROM (select row_number() over(order by "WI_NAME" asc)  "S.No.","APPROVAL DATE","APPROVING AUTHORITY","WI_NAME","DIVISION","CIF","CUSTOMER NAME","PROPOSAL TYPE","PRODUCT TYPE (TWC/FIGP/CRE/ABF)","TOTAL CUSTOMER LIMIT APPROVED(AED 000)","CREDIT POLICY BREACH  (Y/N)","POLICY BREACH DETAILS","NEW/EXISTING" FROM #CreditPolicyBreach) as a where "S.No." between  ((cast(@KeyField as int))-(cast(@BatchSize as int)))-1 and cast(@KeyField as int)-1 order by "S.No." desc;
   	END
   ELSE
   BEGIN
 
	select * from (SELECT row_number() over(order by "WI_NAME" asc)  "S.No.","APPROVAL DATE","APPROVING AUTHORITY","WI_NAME","DIVISION","CIF","CUSTOMER NAME","PROPOSAL TYPE","PRODUCT TYPE (TWC/FIGP/CRE/ABF)","TOTAL CUSTOMER LIMIT APPROVED(AED 000)","CREDIT POLICY BREACH  (Y/N)","POLICY BREACH DETAILS","NEW/EXISTING" FROM #CreditPolicyBreach) as a where "S.No." between 
	(case when @OrderBy=0
	then cast(@KeyField as int)+1
	when @OrderBy=1 
	then cast(@KeyField as int)+1 
	end)
	and 
	(case when @OrderBy=0
	then (cast(@KeyField as int))+cast(@BatchSize as int)
	when @OrderBy=1 then (cast(@KeyField as int))+cast(@BatchSize as int) 
	end)
	order by "WI_NAME" asc;
	END
	
end;


DROP TABLE #CreditPolicyBreach;
