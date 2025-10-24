SELECT TOP (1000) 
      WOS.[WorkOrderID] 
      ,WOS.[ProductionLineID]
      ,WO.Name as WOName
	  ,PO.Name as Name
      ,WOS.[StartTime]
      ,WOS.[EndTime]
      ,WOS.[CommentID]
      ,WOS.[Quantity]
	  ,WOS.ID
	  ,[dbo].[getDuration](WO.[ID], WOS.[Quantity]) as [Duration]
	  ,POS.Name as Site
	  ,POLT.Name as ProductionLineType
	  ,WOS.StatusID
	  ,wospc.PercentComplete
  FROM [WorkOrderSchedule] as WOS
  join [ProductionLine] as PO
  on PO.ID = WOS.ProductionLineID
  join [WorkOrder] as WO
  on WO.ID = WOS.[WorkOrderID] 
  join ProductionLineType as POLT
  on POLT.id = PO.ProductionLineTypeID
  join ProductionSite as POS
  on POS.ID = PO.ProductionSiteID
  LEFT JOIN WorkOrderSchedulePercentComplete wospc 
  	ON wospc.WorkOrderScheduleID = wos.ID
  
  where WOS.EndTime > :StartTime
  and (:ProductionLineID is NULL or :ProductionLineID  = -1 or PO.ID = :ProductionLineID)
  and (:EndTime is NULL or :EndTime  > WOS.StartTime)
  Order by ProductionLineID, StartTime ASC