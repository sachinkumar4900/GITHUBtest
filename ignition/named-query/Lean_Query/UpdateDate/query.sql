UPDATE [dbo].[PentairFiscalCalender]
SET 
    StartDate = :StartDate,
    EndDate = :EndDate
WHERE 
    ID = :ID;