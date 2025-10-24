;WITH X (CycleTime, Duration, StartTime, EndTime, Cavities, ID) AS (
SELECT 
	wom.CycleTime,
	CASE
		WHEN wos.StartTime < :StartTime THEN DATEDIFF(SECOND, :StartTime, wos.EndTime)
		WHEN wos.EndTime > :EndTime THEN DATEDIFF(SECOND, wos.StartTime, :EndTime)
		ELSE DATEDIFF(SECOND, wos.StartTime, wos.EndTime)
	END AS Duration,
	CASE
		WHEN wos.StartTime < :StartTime THEN :StartTime ELSE wos.StartTime END AS StartTime,
	CASE
		WHEN wos.EndTime > :EndTime THEN :EndTime ELSE wos.EndTime END AS EndTime,
	wom.Cavities,
	wom.ID
	
FROM WorkOrderMolding wom
	LEFT JOIN WorkOrderSchedule wos ON wom.WorkOrderID = wos.WorkOrderID
WHERE wom.ProductionLineID = :plID
	AND ((wos.StartTime BETWEEN :StartTime AND :EndTime
		OR wos.EndTime BETWEEN :StartTime AND :EndTime)
		OR (:StartTime BETWEEN wos.StartTime AND wos.EndTime 
			AND :EndTime BETWEEN wos.StartTime AND wos.EndTime)
		)
)
SELECT
	*--SUM((Duration / (t.s * 1.0)) * CycleTime) AS AvgCycleTime
FROM X
--CROSS JOIN (SELECT SUM(Duration) AS s FROM X) t