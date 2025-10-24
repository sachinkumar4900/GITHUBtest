
SELECT top 1000 
   WO.ID as WorkOrderID,
   WO.Name as WorkOrderName,
   Isnull(WOA.PartNumber,  WOM.PartNumber) as PartNumber,
   PL.Name,
   PL.ProductionLineTypeID,
   ProductionSiteID,
   PL.ID as ProductionLineID
from WorkOrder as WO
left join WorkOrderAssembly as WOA
on WOA.WorkOrderID = WO.ID
left join WorkOrderMolding  as WOM
on WOM.WorkOrderID = WO.ID
left join ProductionLine as PL
on PL.ID = Isnull(WOA.ProductionLineID,  WOM.ProductionLineID)
where PL.ID = :ProductionLineID 