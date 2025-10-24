SELECT pl.ID, pl.Name, x.WorkOrderID, x.StartTime, x.EndTime, x.EndTime, x.Quantity, x.WorkOrder
FROM ProductionLine pl
LEFT JOIN(
	SELECT pl2.ID, pl2.Name, wos.WorkOrderID, wos.StartTime, wos.EndTime, wos.Quantity, wo.Name AS WorkOrder
	FROM ProductionLine pl2
	JOIN WorkOrderSchedule wos ON pl2.ID = wos.ProductionLineID
	JOIN WorkOrder wo ON wos.WorkOrderID = wo.ID
	AND GETDATE() BETWEEN StartTime AND EndTime) 
x ON pl.ID = x.ID
WHERE ProductionLineTypeID = :lineTypeID
	AND ProductionSiteID = :siteID
ORDER BY pl.Name