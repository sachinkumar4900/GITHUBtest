SELECT wo.Name,
	wot.EndTime,
	wot.EndedBy
FROM WorkOrderTracking wot
Join WorkOrder wo ON wo.ID = wot.WorkOrderID
WHERE ProductionLineID = :pID and EndTime between :StartTime and :EndTime
Order By wot.EndTime desc