    IF EXISTS (
		SELECT TOP 1 * FROM DowntimeEvent de
		LEFT JOIN DowntimeReason dr ON de.ReasonID = dr.ID 
		WHERE (StartTime < :start AND (EndTime > :end))
  		AND (dr.PlannedDowntime = 1)
		AND EquipmentID IN (SELECT ID FROM dbo.GetEquipmentByProductionLineID(:productionLineID))
	)
	BEGIN
		SELECT TOP 1 DATEDIFF(SECOND, :start, :end) From DowntimeEvent de
	END
		ELSE
	BEGIN
  
  SELECT COALESCE(SUM(DATEDIFF(SECOND, StartTime, EndTime)), 0) AS Downtime
  FROM
  (
  SELECT CASE WHEN StartTime < :start THEN :start ELSE StartTime END AS StartTime, CASE WHEN EndTime > :end THEN :end ELSE EndTime END AS EndTime
  FROM DowntimeEvent de
  LEFT JOIN DowntimeReason dr ON de.ReasonID = dr.ID
  WHERE (dr.PlannedDowntime = 1)
  AND EquipmentID IN (SELECT ID FROM dbo.GetEquipmentByProductionLineID(:productionLineID))
  AND (StartTime BETWEEN :start AND :end OR EndTime BETWEEN :start AND :end)
  ) x
  END