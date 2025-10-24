SELECT SUM(h.PlannedParts) AS Planned, SUM(h.ActualParts) AS Actual, SUM(h.Scrap) AS Scrap, SUM(h.Downtime) AS Downtime
FROM HourByHourMDI h
WHERE StartTime BETWEEN :StartTime AND :EndTime
AND h.ProductionLineID = :ProductionLineID