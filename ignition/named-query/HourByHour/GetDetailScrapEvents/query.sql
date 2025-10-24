SELECT s.[ID]
      ,[WorkOrderID]
      ,wo.[Name] AS WorkOrder
      ,[Quantity]
      ,s.[Timestamp]
      ,s.[ProductionLineID]
      ,s.[CommentID]
      ,c.[Text] AS Comment
      ,[ReasonID]
      ,sr.[Name] AS Reason
      ,e.Name AS Equipment
FROM Scrap s
JOIN Equipment e ON s.EquipmentID = e.ID
LEFT JOIN WorkOrder wo ON s.WorkOrderID = wo.ID
LEFT JOIN Comment c ON s.CommentID = c.ID
LEFT JOIN ScrapReason sr ON s.ReasonID = sr.ID
WHERE (s.EquipmentID IN (SELECT ID FROM dbo.GetEquipmentByProductionLineID(:plID)) OR s.ProductionLineID = :plID)
AND s.[Timestamp] BETWEEN :start AND :end
ORDER BY s.[Timestamp]