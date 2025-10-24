SELECT 0 AS ID, 'NONE' AS [Name]
UNION
SELECT dr.ID, CONCAT(drg.[Name], ' - ', dr.[Name]) AS Name 
FROM DowntimeReason dr
JOIN DowntimeReasonGroup drg ON dr.ReasonGroupID = drg.ID
WHERE dr.ParentReasonID IS NULL