SELECT TOP 1 NotificationGroupID
	FROM AndonEvent
	WHERE :ProductionLineID = ProductionLineID
	ORDER BY ID DESC