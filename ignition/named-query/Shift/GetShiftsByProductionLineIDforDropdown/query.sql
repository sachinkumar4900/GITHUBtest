SELECT ID, [Name]
FROM [Shift]
WHERE ProductionLineID = :productionLineID
AND [Enabled] = 1