SELECT top 1000 
	WO.ID,
   Isnull(WOA.ProductionLineID,  WOM.ProductionLineID) as ProductionLineID,
   Isnull(WOA.PartNumber,  WOM.PartNumber) as PartNumber,
   PL.Name,
   PL.ProductionLineTypeID,
   ProductionSiteID
from WorkOrder as WO
left join WorkOrderAssembly as WOA
on WOA.WorkOrderID = WO.ID
left join WorkOrderMolding  as WOM
on WOM.WorkOrderID = WO.ID
left join ProductionLine as PL
on PL.ID = Isnull(WOA.ProductionLineID,  WOM.ProductionLineID)
where WO.ID = :WorkOrderID 