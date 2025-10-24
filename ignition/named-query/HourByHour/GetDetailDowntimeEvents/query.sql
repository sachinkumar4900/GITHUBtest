SELECT de.[ID]
      ,[EquipmentID]
      ,e.Name AS Equipment
      ,[ReasonID]
      ,dr.Name AS Reason
      ,[StartTime]
      ,[EndTime]
      ,[CommentID]
      ,c.[Text] AS Comment
FROM DowntimeEvent de
JOIN Equipment e ON de.EquipmentID = e.ID
LEFT JOIN DowntimeReason dr ON de.ReasonID = dr.ID
LEFT JOIN Comment c ON de.CommentID = c.ID
WHERE EquipmentID IN (SELECT ID FROM dbo.GetEquipmentByProductionLineID(:plID))
AND (([StartTime] BETWEEN :start AND :end OR [EndTime] BETWEEN :start AND :end)
	OR ((:start BETWEEN [StartTime] AND [EndTime]) AND (:end BETWEEN [StartTime] AND [EndTime]))
	OR (:start > [StartTime] AND [EndTime] IS NULL))
ORDER BY StartTime