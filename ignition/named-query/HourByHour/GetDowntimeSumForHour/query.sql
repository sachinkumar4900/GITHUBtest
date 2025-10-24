IF EXISTS (
	SELECT TOP 1 * FROM DowntimeEvent
	WHERE (StartTime < :start AND (EndTime > :end OR EndTime IS NULL))
	AND EquipmentID IN (SELECT ID FROM dbo.GetEquipmentByProductionLineID(:productionLineID))
)
BEGIN
	SELECT TOP 1 DATEDIFF(SECOND, :start, :end) From DowntimeEvent
END
	ELSE
BEGIN

SELECT COALESCE(SUM(DATEDIFF(SECOND, StartTime, EndTime)), 0)
FROM

(SELECT CASE WHEN StartTime < :start THEN :start ELSE StartTime END AS StartTime, CASE WHEN EndTime > :end OR EndTime IS NULL THEN :end ELSE EndTime END AS EndTime
FROM DowntimeEvent
WHERE EquipmentID IN (SELECT ID FROM dbo.GetEquipmentByProductionLineID(:productionLineID))
AND (StartTime BETWEEN :start AND :end OR EndTime BETWEEN :start AND :end) ) x

END