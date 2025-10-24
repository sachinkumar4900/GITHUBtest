UPDATE WorkOrderSchedule
set StartTime = :StartTime, EndTime = :EndTime, Quantity = :Quantity
Where ID = :ID

Select top(1) EndTime 
From WorkOrderSchedule
Where ID = :ID