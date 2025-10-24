DECLARE @EH NVARCHAR(50)
SELECT TOP 1 @EH = EventHeaderID FROM AndonEvent WHERE ProductionLineID = :plID ORDER BY ID DESC
SELECT TOP 1 c.Text
	FROM AndonEvent ae
	JOIN Comment c ON c.ID = ae.CommentID
		WHERE ProductionLineID = :plID
		AND EventHeaderID = @EH
			ORDER BY ae.ID DESC