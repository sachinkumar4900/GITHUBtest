IF EXISTS	(SELECT * 
			FROM WorkOrderAssembly woa 
			WHERE ProductionLineID = :ProductionLineID)
BEGIN
	SELECT hbh.ID, StartTime, PlannedParts, ActualParts, Downtime / 60.0 AS Downtime, Scrap, PartNumber, AvgSpeed / 60.0 AS AvgSpeed
	FROM HourByHourOEE hbh 
	LEFT JOIN WorkOrderAssembly woa 
		ON hbh.WorkOrderID = woa.WorkOrderID 
		AND hbh.ProductionLineID = woa.ProductionLineID
	WHERE hbh.ProductionLineID = :ProductionLineID
	AND StartTime BETWEEN :start AND :end
	ORDER BY StartTime DESC
END
ELSE
BEGIN
	SELECT hbh.ID, StartTime, PlannedParts, ActualParts, Downtime / 60.0 AS Downtime, Scrap, PartNumber, AvgSpeed / 60.0 AS AvgSpeed
	FROM HourByHourOEE hbh 
	LEFT JOIN WorkOrderMolding wom
		ON hbh.WorkOrderID = wom.WorkOrderID 
		AND hbh.ProductionLineID = wom.ProductionLineID
	WHERE hbh.ProductionLineID = :ProductionLineID
	AND StartTime BETWEEN :start AND :end
	ORDER BY StartTime DESC
END
