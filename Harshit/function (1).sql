ALTER FUNCTION [dbo].[RAK_PC_CutOffValidate]
(
   @Condition nvarchar(100),
   @WorkstepName nvarchar(100),
   @EntryDatetime datetime,
   @Actiondatetime datetime,
   @PreviousWorkstepName nvarchar(100)
)
RETURNS varchar(60)
AS
BEGIN
    DECLARE @Output varchar(60) = '';
    DECLARE @QueryOutput varchar(100);
    DECLARE @CutOffvalue time;
    DECLARE @Validatevalue time;

    IF (@Condition IS NOT NULL AND @WorkstepName IS NOT NULL AND @EntryDatetime IS NOT NULL AND @Actiondatetime IS NOT NULL)
    BEGIN
        SELECT TOP 1 @QueryOutput = CutOfftime
        FROM rakcas.dbo.RAK_PC_OPS_CUTOFF_REPORT_MST WITH (NOLOCK)
        WHERE Workstep_Name = @WorkstepName AND isActive = 'Y';

        IF (@WorkstepName = 'OPS_Document_Checker' AND @PreviousWorkstepName IN 
            ('CBWC_Maker', 'Control_Checker', 'Control_Maker', 'Compliance', 
            'Compliance_Manager', 'Compliance_WC', 'Create_Credit_Case', 
            'Credit_Analyst', 'Credit_Asst_Manager', 'Credit_BB_Head', 
            'Credit_Manager', 'Credit_Sr_Analyst', 'Credit_Sr_Manager'))
        BEGIN
            RETURN NULL;
        END

        IF (@WorkstepName = 'OPS_Data_Entry_Maker' AND @PreviousWorkstepName IN 
            ('Compliance', 'Compliance_Manager', 'Compliance_WC', 
            'Control_Checker', 'Control_Maker', 'Collections_Checker', 'Collections_Maker'))
        BEGIN
            SET @QueryOutput = @QueryOutput;
        END
        ELSE
        BEGIN
            SET @QueryOutput = 'Day';
        END

        IF (@Condition = 'EntryValidate')
        BEGIN
            IF (@QueryOutput = 'Day')
            BEGIN
                SET @Output = 'WithinCutOff';
            END
            ELSE
            BEGIN
                SET @CutOffvalue = CONVERT(time, @QueryOutput);
                SET @Validatevalue = CONVERT(time, @EntryDatetime);
                SET @Output = CASE WHEN @Validatevalue >= @CutOffvalue THEN 'CutOffExceed' ELSE 'WithinCutOff' END;
            END
        END
        ELSE
        BEGIN
            IF (@QueryOutput = 'Day')
            BEGIN
                SET @Output = CASE WHEN CONVERT(date, @EntryDatetime) = CONVERT(date, @Actiondatetime)
                                   THEN 'WithinCutOff'
                                   ELSE 'CutOffExceed'
                              END;
            END
            ELSE
            BEGIN
                SET @CutOffvalue = CONVERT(time, @QueryOutput);
                SET @Validatevalue = CONVERT(time, @Actiondatetime);
                IF (CONVERT(date, @EntryDatetime) <> CONVERT(date, @Actiondatetime))
                BEGIN
                    SET @Output = 'CutOffExceed';
                END
                ELSE IF (@Validatevalue >= @CutOffvalue)
                BEGIN
                    SET @Output = 'CutOffExceed';
                END
                ELSE
                BEGIN
                    SET @Output = 'WithinCutOff';
                END
            END
        END
    END
    ELSE
    BEGIN
        SET @Output = 'Function Parameters missing..';
    END

    RETURN @Output;
END;
