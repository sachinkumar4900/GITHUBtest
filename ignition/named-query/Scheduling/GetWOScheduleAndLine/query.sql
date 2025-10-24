SELECT TOP (1000) 
      WOS.[WorkOrderID]
      ,WOS.[ProductionLineID]
      ,WO.Name as WOName
	  ,PO.Name
      ,[StartTime]
      ,[EndTime]
      ,[CommentID]
      ,[Quantity]
	  ,PO.ID
	  
  FROM [Ignition].[dbo].[WorkOrderSchedule] as WOS
  join [Ignition].[dbo].[ProductionLine] as PO
  on PO.ID = WOS.ProductionLineID
  --where EndTime > GETDATE()
  Order by StartTime ASC