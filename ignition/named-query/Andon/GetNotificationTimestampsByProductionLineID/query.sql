-- Check if open downtime exists without an associated andon header
DECLARE @LatestAndon DATETIME2
SELECT TOP 1 @LatestAndon = [Timestamp] FROM AndonEvent WHERE ProductionLineID = :ProductionLineID ORDER BY ID DESC
IF EXISTS(
	SELECT TOP 1 *
		FROM DowntimeEvent de
		LEFT JOIN Equipment e ON e.ID = de.EquipmentID
		WHERE (de.EndTime IS NULL OR de.EndTime > @LatestAndon)
			AND de.AndonHeaderID IS NULL
			AND e.ProductionLineID = :ProductionLineID
		ORDER BY de.ID DESC
)
BEGIN
	SELECT TOP 1 
		CASE 
			WHEN de.EndTime IS NULL THEN de.StartTime
			ELSE de.EndTime
		END AS [Timestamp]
		FROM DowntimeEvent de
		LEFT JOIN Equipment e ON e.ID = de.EquipmentID
		JOIN ProductionLine pl ON pl.ID = e.ProductionLineID
		WHERE (de.EndTime IS NULL OR de.EndTime > @LatestAndon)
			AND de.AndonHeaderID IS NULL
			AND e.ProductionLineID = :ProductionLineID
		ORDER BY de.ID DESC
END
	ELSE
BEGIN

	DECLARE @EventHeader NVARCHAR(50)
	SELECT TOP 1 @EventHeader =
		EventHeaderID
	FROM AndonEvent
		WHERE ProductionLineID = :ProductionLineID
		ORDER BY ID DESC
	
	IF EXISTS (
	SELECT TOP 1 * 
		FROM AndonEvent
		WHERE (StatusID = 6)
			AND EventHeaderID = @EventHeader
	)
	BEGIN
	SELECT TOP 1 [Timestamp] --DATEADD(hour, :Offset, Timestamp) AS Timestamp 
		FROM AndonEvent
		WHERE (StatusID = 6)
			AND EventHeaderID = @EventHeader
	END
		ELSE
	BEGIN
	SELECT TOP 1 [Timestamp] --DATEADD(hour, :Offset, Timestamp) AS Timestamp 
		FROM AndonEvent
		WHERE ProductionLineID = :ProductionLineID
			AND (StatusID = 1 OR StatusID = 2 OR StatusID = 4 OR StatusID = 6)
			AND EventHeaderID = @EventHeader
	END
END