SELECT ParentReason,
		Reason, 
		COUNT(*) as Occurrences, 
		SUM(Duration)/60 as Time_Min,
		Comment
FROM DowntimeEventLog
WHERE Equipment = :Equipment
AND StartTime BETWEEN :startTime AND :endtime
GROUP BY ParentReason, 
		Reason,
		Comment
ORDER BY 
Time_Min DESC
