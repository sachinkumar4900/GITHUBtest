SELECT [EventHeaderID]
      ,ae.[ID]
      ,[NotificationGroupID]
      ,ag.[Name] AS AndonGroup
      ,ae.[Timestamp]
      ,[ProductionLineID]
      ,pl.[Name] AS Asset
      ,[StatusID]
      ,aes.[Name] AS Status
      ,ae.[CommentID] 
      ,c.[Text] AS Comment
      ,[ReasonID]
      ,dr.[Name] AS Reason
FROM AndonEvent ae
JOIN AndonGroup ag ON ae.NotificationGroupID = ag.ID
JOIN ProductionLine pl ON ae.ProductionLineID = pl.ID
JOIN AndonEventStatus aes ON ae.StatusID = aes.ID
LEFT JOIN Comment c ON ae.CommentID = c.ID
LEFT JOIN DowntimeReason dr ON ae.ReasonID = dr.ID
WHERE ProductionLineID = :plID
AND ae.[Timestamp] BETWEEN :start AND :end
ORDER BY ae.[Timestamp]