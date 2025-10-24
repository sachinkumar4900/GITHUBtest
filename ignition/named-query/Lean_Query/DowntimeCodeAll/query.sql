SELECT [DTCode]
      ,[Name]
FROM [dbo].[DowntimeReason]
WHERE   [DTCode] IS NOT NULL AND [DTCode] != 'G' AND ReasonGroupID = :ReasonGroup
Group By [DTCode], [NAME];