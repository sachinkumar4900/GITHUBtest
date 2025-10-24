SELECT 
    pfc.StartDate,
    pfc.EndDate,
    t.ProductionSiteID,
    t.FPY_Target,
    t.OTD_Target
FROM 
    [dbo].[PentairFiscalCalender] pfc
JOIN 
    [dbo].[Targets] t
    ON pfc.ID = t.PentairFiscalCalenderID
WHERE 
   ProductionSiteID = :ProductionSiteID AND  pfc.Month = :Month AND pfc.Year = :Year;

