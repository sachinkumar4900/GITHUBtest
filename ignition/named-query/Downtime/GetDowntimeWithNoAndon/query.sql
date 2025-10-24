IF EXISTS(
	SELECT TOP 1 *
		FROM DowntimeEvent de
		LEFT JOIN Equipment e ON e.ID = de.EquipmentID
		WHERE de.EndTime IS NULL
			AND de.AndonHeaderID IS NULL
			AND e.ProductionLineID = :plID
		ORDER BY de.ID DESC
)
BEGIN
	SELECT TOP 1 de.*
		FROM DowntimeEvent de
		LEFT JOIN Equipment e ON e.ID = de.EquipmentID
		JOIN ProductionLine pl ON pl.ID = e.ProductionLineID
		WHERE de.EndTime IS NULL
			AND de.AndonHeaderID IS NULL
			AND e.ProductionLineID = :plID
		ORDER BY de.ID DESC
END
	ELSE
BEGIN
	SELECT -1 AS dtid
END