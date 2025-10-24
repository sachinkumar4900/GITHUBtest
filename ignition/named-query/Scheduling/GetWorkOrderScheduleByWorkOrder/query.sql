SELECT WOS.WorkOrderID,
	PO.Name as ProductionLine,
	StartTime,
	EndTime,
	WOS.quantity as Quantity,
	WOR.Rate,
	PO.ID
FROM [WorkOrderSchedule] as WOS
join [WorkOrderRate] as WOR
on WOS.ProductionLineID = WOR.ProductionLineID
join [ProductionLine] as PO
on PO.ID = WOS.ProductionLineID
WHERE WOS.WorkOrderId = :WorkOrderId