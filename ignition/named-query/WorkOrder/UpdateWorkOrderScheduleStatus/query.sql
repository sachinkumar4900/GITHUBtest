UPDATE WorkOrderSchedule
SET StatusID = :StatusID
WHERE WorkOrderID = :WorkOrderID
	AND ProductionLineID = :plID
	AND GETUTCDATE() BETWEEN StartTime AND EndTime 
-- 1 = WAITING
-- 2 = RUNNING
-- 3 = COMPLETED
-- 4 = STOPPED