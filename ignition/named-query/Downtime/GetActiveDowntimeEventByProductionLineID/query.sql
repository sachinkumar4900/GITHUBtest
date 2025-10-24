SELECT TOP 1 de.ID
FROM DowntimeEvent de 
JOIN Equipment e ON e.ID = de.EquipmentID
WHERE e.ProductionLineID = :ProductionLineID AND de.EndTime IS NULL-- AND ReasonID IS NULL
ORDER BY de.ID DESC