IF EXISTS (
	SELECT TOP 1 EventHeaderID
	FROM AndonEvent
	WHERE ProductionLineID = :productionLineID
	ORDER BY ID DESC
)
BEGIN
	SELECT TOP 1 EventHeaderID
	FROM AndonEvent
	WHERE ProductionLineID = :productionLineID
	ORDER BY ID DESC
END
	ELSE
BEGIN
		SELECT '-1' AS EventHeaderID
END