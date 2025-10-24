UPDATE Targets
SET 
    OTD_Target = :OTD_Target
FROM 
    Targets t
JOIN 
    PentairFiscalCalender pfc
    ON t.PentairFiscalCalenderID = pfc.ID
WHERE 
    pfc.Year = :Year 
    AND pfc.Month = :Month
    AND t.ProductionSiteID = :ProductionSiteID;
