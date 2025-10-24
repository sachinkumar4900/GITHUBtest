IF EXISTS (
	SELECT ProductionLineID
	FROM WorkOrderAssembly
		WHERE WorkOrderID = :woid
) BEGIN
	SELECT ProductionLineID
	FROM WorkOrderAssembly
	WHERE WorkOrderID = :woid
END 
	ELSE
BEGIN
	SELECT ProductionLineID
	FROM WorkOrderMolding
	WHERE WorkOrderID = :woid
END