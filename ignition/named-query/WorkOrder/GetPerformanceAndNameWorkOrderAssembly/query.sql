;WITH X (CycleTime, Duration, StartTime, EndTime, ID, Cavities) AS (
	SELECT 
		RatePerHour AS CycleTime, 
		CASE 
			WHEN wos.StartTime < :StartTime THEN DATEDIFF(SECOND, :StartTime, wos.StartTime)
			WHEN wos.EndTime > :EndTime THEN DATEDIFF(SECOND, wos.StartTime, :EndTime)
			ELSE DATEDIFF(SECOND, wos.StartTime, wos.EndTime)
		END AS Duration,
	CASE
		WHEN wos.StartTime < :StartTime THEN :StartTime ELSE wos.StartTime END AS StartTime,
	CASE
		WHEN wos.EndTime > :EndTime THEN :EndTime ELSE wos.EndTime END AS EndTime,
		woa.ID,
		'N/A' AS Cavities
		
	FROM WorkOrderAssembly woa
		LEFT JOIN WorkOrderSchedule wos ON woa.WorkOrderID = wos.WorkOrderID
	WHERE woa.ProductionLineID = :plID
		AND (wos.StartTime BETWEEN :StartTime AND :EndTime
		OR wos.EndTime BETWEEN :StartTime AND :EndTime)
) 
SELECT 
	*--SUM((Duration / (t.s * 1.0)) * RatePerHour) AS AvgRatePerHour
FROM X
	--CROSS JOIN (SELECT SUM(Duration) AS s FROM X) t