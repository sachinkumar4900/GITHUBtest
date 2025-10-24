SELECT ID AS [Value], Name AS [Label]
FROM ScrapReason
WHERE  (ProductionLineTypeID = :ProductionLineTypeID
OR :ProductionLineTypeID = -1)