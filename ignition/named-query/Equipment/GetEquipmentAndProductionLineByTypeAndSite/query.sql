SELECT 
	e.ID AS EquipmentID, 
	e.[Name] AS EquipmentName,
	pl.[Name] AS ProductionLineName,
	e.ProductionLineID
FROM Equipment e
JOIN ProductionLine pl ON e.ProductionLineID = pl.ID
WHERE ProductionLineTypeID = :typeID AND ProductionSiteID = :siteID
ORDER BY pl.Name