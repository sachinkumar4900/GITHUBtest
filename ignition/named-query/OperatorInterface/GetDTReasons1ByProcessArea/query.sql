SELECT dt.ID AS [value],
  dt.Name AS [label]
FROM DowntimeReason dt
WHERE dt.ReasonGroupID = :ProcessArea 
AND dt.[Level] = 1