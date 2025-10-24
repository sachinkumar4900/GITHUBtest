IF EXISTS	(SELECT * 
			FROM WorkOrderAssembly woa 
			JOIN HourByHourOEE hbh 
				ON hbh.WorkOrderID = woa.WorkOrderID 
				AND hbh.ProductionLineID = woa.ProductionLineID 
			WHERE hbh.ID = :ID)
BEGIN
	SELECT StartTime, PlannedParts, ActualParts, Downtime, Scrap, PartNumber, AvgSpeed, hbh.ProductionLineID, woa.ID
	FROM HourByHourOEE hbh 
	LEFT JOIN WorkOrderAssembly woa 
		ON hbh.WorkOrderID = woa.WorkOrderID 
		AND hbh.ProductionLineID = woa.ProductionLineID
	WHERE hbh.ID = :ID
END
ELSE
BEGIN
	SELECT StartTime, PlannedParts, ActualParts, Downtime, Scrap, PartNumber, AvgSpeed, hbh.ProductionLineID, wom.ID
	FROM HourByHourOEE hbh 
	LEFT JOIN WorkOrderMolding wom
		ON hbh.WorkOrderID = wom.WorkOrderID 
		AND hbh.ProductionLineID = wom.ProductionLineID
	WHERE hbh.ID = :ID
END
