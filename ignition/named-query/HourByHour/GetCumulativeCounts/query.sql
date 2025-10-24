SELECT SUM(PlannedParts) AS Planned, SUM(ActualParts) AS Actual
FROM HourByHourOEE
WHERE ProductionLineID = :ProductionLineID
AND StartTime BETWEEN :start AND :end