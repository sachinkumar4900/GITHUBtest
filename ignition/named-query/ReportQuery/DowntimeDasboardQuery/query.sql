SELECT SUM(h.PlannedParts) AS Planned, SUM(h.ActualParts) AS Actual, SUM(h.Scrap) AS Scrap, SUM(h.Downtime) AS Downtime
FROM HourByHourMDI h
WHERE h.StartTime BETWEEN :StartDate AND :EndDate
AND h.ProductionLineID = :ProductionLineID AND h.WorkOrderID IS NOT NULL

