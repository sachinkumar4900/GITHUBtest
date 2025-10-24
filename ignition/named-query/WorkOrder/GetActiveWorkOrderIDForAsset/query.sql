SELECT wo.ID
FROM WorkOrder wo 
JOIN WorkOrderSchedule wos ON wo.ID = wos.WorkOrderID
WHERE ProductionLineID = :productionLineID 
AND GETDATE() BETWEEN StartTime AND EndTime -- going from pacific to UTC time
