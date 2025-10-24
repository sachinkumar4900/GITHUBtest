IF EXISTS (
	SELECT * FROM WorkOrderAssembly
	WHERE WorkOrderID = :WorkOrderID
		AND ProductionLineID = :ProductionLineID
)
BEGIN
	SELECT PartNumber 
	FROM WorkOrderAssembly
	WHERE WorkOrderID = :WorkOrderID
		AND ProductionLineID = :ProductionLineID
END
ELSE
BEGIN
	SELECT PartNumber
	FROM WorkOrderMolding 
	WHERE WorkOrderID = :WorkOrderID
		AND ProductionLineID = :ProductionLineID
END