SELECT TOP 1 *
FROM Scrap 
WHERE ProductionLineID = :ProductionLineID
    ORDER BY ID DESC