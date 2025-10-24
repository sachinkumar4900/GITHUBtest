UPDATE [dbo].[Targets]
SET 
    FPY_Target = :FPY_Target,
    OTD_Target = :OTD_Target
WHERE 
    PentairFiscalCalenderID = :ID;

