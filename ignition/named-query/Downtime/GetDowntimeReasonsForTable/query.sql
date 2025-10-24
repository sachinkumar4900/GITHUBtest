SELECT dr.ID, dr.Name AS Reason, dr.[Level], dr.PlannedDowntime, dr.AndonGroupID, ag.Name AS AndonGroup, dr2.ID AS ParentReasonID, dr2.Name AS ParentReason, dr.ReasonGroupID, drg.Name AS ReasonGroup
FROM DowntimeReason dr
JOIN AndonGroup ag ON dr.AndonGroupID = ag.ID
LEFT JOIN DowntimeReason dr2 ON dr.ParentReasonID = dr2.ID
JOIN DowntimeReasonGroup drg ON dr.ReasonGroupID = drg.ID