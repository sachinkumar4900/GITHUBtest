SELECT [ID]
      ,[Name]
      ,[ReasonGroupID]
      ,[Level]
      ,[ParentReasonID]
      ,[PlannedDowntime]
      ,[AndonGroupID]
FROM DowntimeReason
WHERE ID = :ID