SELECT woa.ID,
  woa.WorkOrderID,
  woa.ProductionLineID,
  woa.ProductFamily,
  woa.PartNumber,
  woa.NumberOfPeople,
  woa.RatePerHour,
  woa.ChangeoverTime,
  wo.Name AS WorkOrder,
  pl.Name AS ProductionLine
FROM WorkOrderAssembly woa
JOIN WorkOrder wo
	ON woa.WorkOrderID = wo.ID
JOIN ProductionLine pl
	ON woa.ProductionLineID = pl.ID
WHERE woa.WorkOrderID = :pWorkOrderID