DECLARE @Today Date = :DateNow;

SELECT 
    pfc.Month,
    t.ProductionSiteID,
    t.FPY_Target,
    t.OTD_Target
FROM 
    [dbo].[PentairFiscalCalender] pfc
JOIN 
    [dbo].[Targets] t
    ON pfc.ID = t.PentairFiscalCalenderID
WHERE 
    ProductionSiteID = :ProductionSiteID AND @Today BETWEEN pfc.StartDate AND pfc.EndDate;


