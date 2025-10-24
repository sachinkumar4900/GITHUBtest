SELECT ID, ConsecutiveDefects, DefectsPerHour, [Name], ProductionLineTypeID
FROM ScrapReason
WHERE ID = :ID