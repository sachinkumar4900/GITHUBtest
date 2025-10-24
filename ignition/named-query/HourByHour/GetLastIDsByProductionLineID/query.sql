SELECT TOP 12 ID
FROM HourByHourOEE
WHERE ProductionLineID = :ProductionLineID
ORDER BY StartTime DESC