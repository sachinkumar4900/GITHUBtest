DECLARE @EventHeader NVARCHAR(50)
SELECT TOP 1 @EventHeader =
	EventHeaderID
FROM AndonEvent
	WHERE ProductionLineID = :ProductionLineID
	ORDER BY ID DESC
SELECT 
TOP 1 ID, CommentID, EventHeaderID, NotificationGroupID, ProductionLineID, ReasonID, StatusID, DATEADD(MINUTE, CONVERT(INT, :offset * 60), Timestamp) AS Timestamp
	FROM AndonEvent
	WHERE ProductionLineID = :ProductionLineID
		AND (StatusID = 1 OR StatusID = 2 OR StatusID = 4 OR StatusID = 6)
		AND EventHeaderID = @EventHeader
	ORDER BY ID DESC
