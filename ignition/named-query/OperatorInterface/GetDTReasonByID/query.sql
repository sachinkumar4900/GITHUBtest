SELECT TOP 1
	CASE
		WHEN :ReasonID = -1 THEN ''
		ELSE dr.[Name]
	END AS [Name]
FROM  DowntimeReason dr
WHERE :ReasonID = dr.ID OR :ReasonID = -1