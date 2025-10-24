Insert into [dbo].[WorkOrderSchedule] 
(WorkOrderID, ProductionLineID, StartTime, EndTime, Quantity, StatusID) 
Values 
(:WorkOrderID, :ProductionLineID, :StartTime, :EndTime, :Quantity, 1) 
Select * 
From [dbo].[WorkOrderSchedule] 
Where EndTime > :StartTime 