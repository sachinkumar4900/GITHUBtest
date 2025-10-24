IF EXISTS(SELECT * FROM WorkOrderAssembly WHERE ProductionLineID = :ProductionLineID)
BEGIN
	SELECT wos.ID, StartTime, EndTime, Quantity, woa.ID AS WorkOrder, PartNumber
	FROM WorkOrderSchedule wos
	JOIN WorkOrderAssembly woa ON wos.WorkOrderID = woa.WorkOrderID AND wos.ProductionLineID = woa.ProductionLineID
	WHERE wos.ProductionLineID = :ProductionLineID
	AND GETDATE() BETWEEN StartTime AND EndTime -- going from pacific to UTC time
END
ELSE
BEGIN
	SELECT wos.ID, StartTime, EndTime, Quantity, wom.ID AS WorkOrder, PartNumber
	FROM WorkOrderSchedule wos
	JOIN WorkOrderMolding wom ON wos.WorkOrderID = wom.WorkOrderID AND wos.ProductionLineID = wom.ProductionLineID
	WHERE wos.ProductionLineID = :ProductionLineID
	AND GETDATE() BETWEEN StartTime AND EndTime -- going from pacific to UTC time
END