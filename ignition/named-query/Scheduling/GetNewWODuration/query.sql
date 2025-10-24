IF :WorkOrderScheduleId is Null or :WorkOrderScheduleId = 0
Begin 
SELECT top(1) [dbo].[getDuration](:WorkOrderId, :Quantity) as Duration
End
Else 
BEGIN
SELECT top(1) [dbo].[getDuration](WO.[ID], :Quantity) as Duration
  FROM [WorkOrderSchedule] as WOS
  join [WorkOrder] as WO
  on WO.ID = WOS.[WorkOrderID] 
 where WOS.ID = :WorkOrderScheduleId
END