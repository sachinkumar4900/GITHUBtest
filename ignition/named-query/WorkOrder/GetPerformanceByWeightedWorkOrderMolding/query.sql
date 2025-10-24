;WITH X (CycleTime, Duration) AS (
SELECT 
	wom.CycleTime,
	CASE
		WHEN wos.StartTime < :StartTime THEN DATEDIFF(SECOND, :StartTime, wos.EndTime)
		WHEN wos.EndTime > :EndTime THEN DATEDIFF(SECOND, wos.StartTime, :EndTime)
		ELSE DATEDIFF(SECOND, wos.StartTime, wos.EndTime)
	END AS Duration
	
FROM WorkOrderMolding wom
	LEFT JOIN WorkOrderSchedule wos ON wom.WorkOrderID = wos.WorkOrderID
WHERE wom.ProductionLineID = :plID
	AND (wos.StartTime BETWEEN :StartTime AND :EndTime
		OR wos.EndTime BETWEEN :StartTime AND :EndTime)
)
SELECT
	SUM((Duration / (t.s * 1.0)) * CycleTime) AS AvgCycleTime
FROM X
CROSS JOIN (SELECT SUM(Duration) AS s FROM X) t