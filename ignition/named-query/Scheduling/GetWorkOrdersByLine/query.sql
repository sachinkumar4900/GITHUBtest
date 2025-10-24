SELECT WO.ID,
WO.Name,
WO.Description,
ISNULL(WOM.ProductionLineID, WOA.ProductionLineID) as ProductionLineID,
PL.name as ProductionLine,
PL.ProductionLineTypeID,
ISNULL(WOM.ChangeoverTime, WOA.ChangeoverTime) as ChangeoverTime,
WOA.RatePerHour,
WOM.CycleTime,
WOM.Cavities,
WOM.ScrapRate,
	(dbo.getMoldingDuration(WOM.Cavities,WOM.CycleTime,WOM.ScrapRate,:quantity, WOM.ChangeoverTime) +
	dbo.getAssemblyDuration(WOA.RatePerHour,:quantity,WOA.ChangeoverTime))
 as TotalTime
FROM WorkOrder as WO
left join WorkOrderMolding as WOM
on WOM.WorkOrderID = WO.ID 
left join WorkOrderAssembly as WOA
on WOA.WorkOrderID = WO.ID 
left join ProductionLine as PL
on pl.ID = ISNULL(WOM.ProductionLineID, WOA.ProductionLineID)
WHERE ISNULL(:WorkOrderID, -1) = -1 or WO.ID = :WorkOrderID
order by PL.Name, PL.ID