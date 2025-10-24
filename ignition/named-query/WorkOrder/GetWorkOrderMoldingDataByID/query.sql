SELECT wom.ID,
  wom.WorkOrderID,
  wom.PartNumber,
  wom.ProductionLineID,
  wom.MoldNumber,
  wom.ResinPartNumber,
  wom.ProcessSheetLocation,
  wom.BOMWeight,
  wom.Cavities,
  wom.CycleTime,
  wom.ScrapRate,
  wom.ChangeoverTime,
  womrp.ResinPartNumber AS ResinPartNumber1,
  womrp.ResinDescription,
  womrp.MaterialDryTime,
  womrp.DryTemperature,
  womrp.ProcessTemperature,
  womrp.Color,
  wo.Name AS WorkOrder,
  pl.Name AS ProductionLine
FROM WorkOrderMolding wom 
JOIN WorkOrderMoldingResinPart womrp 
	ON wom.ResinPartNumber = womrp.ResinPartNumber
JOIN WorkOrder wo
	ON wom.WorkOrderID = wo.ID
JOIN ProductionLine pl
	ON wom.ProductionLineID = pl.ID
WHERE wom.WorkOrderID = :pWorkOrderID