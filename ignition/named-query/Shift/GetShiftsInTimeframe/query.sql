SELECT s.Name, ss.StartTime, ss.EndTime
FROM ShiftSchedule ss
JOIN Shift s ON ss.ShiftID = s.ID
WHERE ss.ProductionLineID = :plID
AND (ss.StartTime BETWEEN :StartTime AND :EndTime OR ss.EndTime BETWEEN :StartTime AND :EndTime)