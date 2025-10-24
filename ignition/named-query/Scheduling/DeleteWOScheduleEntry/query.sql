Delete From [WorkOrderSchedule] Where ID = :WorkOrderScheduleID and StartTime > :startTime
Select top(1) * from [WorkOrderSchedule] Where ID = :WorkOrderScheduleID