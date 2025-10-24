SELECT TOP 1 ReasonID 
FROM AndonEvent
WHERE ProductionLineID = :ProductionLineID
    ORDER BY ID DESC