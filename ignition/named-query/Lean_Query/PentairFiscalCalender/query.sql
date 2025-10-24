SELECT 
	pfc.ID,
    pfc.Year,
    pfc.Month,
    pfc.StartDate,
    pfc.EndDate,
    t.FPY_Target,
    t.OTD_Target
FROM 
    [dbo].[PentairFiscalCalender] pfc
JOIN 
    [dbo].[Targets] t
    ON pfc.ID = t.PentairFiscalCalenderID
WHERE 
    pfc.Year = :Year
    AND t.ProductionSiteID = :ProductionSiteID;
