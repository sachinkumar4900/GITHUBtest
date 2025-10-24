SELECT dr.ID
	,dr.[Name] AS [label]
	FROM DowntimeReason dr
	WHERE (ParentReasonID = :Reason1 OR (:Reason1 = -1 AND dr.[Level] = 2))