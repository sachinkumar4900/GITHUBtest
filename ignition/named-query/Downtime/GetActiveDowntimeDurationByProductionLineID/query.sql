IF EXISTS (
	SELECT TOP 1 * 
		FROM DowntimeEvent de
		JOIN Equipment e ON de.EquipmentID = e.ID
			WHERE EndTime IS NULL
			AND StartTime BETWEEN :start AND :end
			AND e.ProductionLineID = :plID
)
BEGIN
	SELECT DATEDIFF(SECOND, CASE WHEN StartTime < :start THEN :start ELSE StartTime END, CASE WHEN GETUTCDATE() > :end THEN :end ELSE GETUTCDATE() END) AS Duration
		FROM DowntimeEvent de
		JOIN Equipment e ON de.EquipmentID = e.ID
			WHERE EndTime IS NULL
			AND e.ProductionLineID = :plID
END
	ELSE
BEGIN
	SELECT 0 AS Duration
END