SELECT 
s.ID,
s.[Name],
StartTime,
Hours,
ProductionLineID,
[Default],
Enabled,
pl.Name AS Asset
FROM Shift s
JOIN ProductionLine pl ON s.ProductionLineID = pl.ID
WHERE [Default] = :DefaultVal
AND ProductionSiteID = :productionSiteID