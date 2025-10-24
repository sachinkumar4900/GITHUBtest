DECLARE @thisEndTime DATETIME 

IF EXISTS(SELECT * FROM WorkOrderAssembly WHERE ProductionLineID = :ProductionLineID)
BEGIN
	SELECT @thisEndTime = EndTime
	FROM WorkOrderSchedule wos
	JOIN WorkOrderAssembly woa ON wos.WorkOrderID = woa.WorkOrderID AND wos.ProductionLineID = woa.ProductionLineID
	WHERE wos.ProductionLineID = :ProductionLineID
	AND GETDATE() BETWEEN StartTime AND EndTime
	
	SELECT wos.ID, StartTime, EndTime, Quantity, woa.ID AS WorkOrder, PartNumber
	FROM WorkOrderSchedule wos
	JOIN WorkOrderAssembly woa ON wos.WorkOrderID = woa.WorkOrderID AND wos.ProductionLineID = woa.ProductionLineID
	WHERE wos.ProductionLineID = :ProductionLineID
	AND DATEADD(MINUTE, 1, @thisEndTime) BETWEEN StartTime AND EndTime
END
ELSE
BEGIN
	SELECT @thisEndTime = EndTime
	FROM WorkOrderSchedule wos
	JOIN WorkOrderMolding wom ON wos.WorkOrderID = wom.WorkOrderID AND wos.ProductionLineID = wom.ProductionLineID
	WHERE wos.ProductionLineID = :ProductionLineID
	AND GETDATE() BETWEEN StartTime AND EndTime -- going from pacific to UTC time
	
	SELECT wos.ID, StartTime, EndTime, Quantity, wom.ID AS WorkOrder, PartNumber
	FROM WorkOrderSchedule wos
	JOIN WorkOrderMolding wom ON wos.WorkOrderID = wom.WorkOrderID AND wos.ProductionLineID = wom.ProductionLineID
	WHERE wos.ProductionLineID = :ProductionLineID
	AND DATEADD(MINUTE, 1, @thisEndTime) BETWEEN StartTime AND EndTime
END