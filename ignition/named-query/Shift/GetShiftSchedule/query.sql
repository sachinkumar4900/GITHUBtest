SELECT 
  ss.ID,
  ss.ShiftID,
  pl.Name AS Asset,
  s.Name AS Shift,
  ss.StartTime,
  ss.EndTime,
  ss.ProductionLineID,
  s.[Default],
  :search as search
FROM ShiftSchedule ss
JOIN [Shift] s ON ss.ShiftID = s.ID
JOIN ProductionLine pl ON s.ProductionLineID = pl.ID
WHERE ProductionSiteID = :productionSiteID
	AND (((pl.Name LIKE '%' + :search + '%') OR (s.Name LIKE '%' + :search + '%'))
	OR (:search = '' OR :search IS NULL))
	AND ss.StartTime > DATEADD(HOUR, -20, GETUTCDATE())
ORDER BY ss.StartTime