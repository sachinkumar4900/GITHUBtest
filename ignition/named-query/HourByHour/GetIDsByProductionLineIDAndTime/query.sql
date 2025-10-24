SELECT ID
FROM HourByHourOEE
WHERE ProductionLineID = :ProductionLineID
AND StartTime BETWEEN :start AND :end
ORDER BY StartTime DESC