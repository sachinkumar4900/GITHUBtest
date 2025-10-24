SELECT TOP 1
	CASE 
		WHEN :Reason = -1 THEN 'Team Lead'
		ELSE ag.[Name]
	END AS [Name]
FROM DowntimeReason dr
JOIN AndonGroup ag ON dr.AndonGroupID = ag.ID
WHERE (dr.ID = :Reason OR :Reason = -1)