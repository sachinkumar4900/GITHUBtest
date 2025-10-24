SELECT WorkOrderID 
FROM WorkOrderSchedule
WHERE ProductionLineID = :ProductionLineID
    AND GETDATE() BETWEEN StartTime AND EndTime