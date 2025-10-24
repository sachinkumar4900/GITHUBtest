SELECT 
	ID
	,:WorkOrderID AS WorkOrderID
	,:ProductionLineID AS ProductionLineID
	,:EquipmentID AS EquipmentID
	,:tagPath AS tagPath
	,ScrapCode
FROM ScrapReason
WHERE  (ProductionLineTypeID = :ProductionLineTypeID
OR :ProductionLineTypeID = -1)
AND ScrapCode IS NOT NULL