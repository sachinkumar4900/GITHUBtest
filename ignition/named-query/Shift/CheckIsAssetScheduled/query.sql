 SELECT TOP 1 1 AS TimeslotTaken 
  FROM ShiftSchedule 
  WHERE ProductionLineID = :productionLineID
  AND ((StartTime > :start AND StartTime < :end) 
		OR
	(EndTime > :start AND EndTime < :end)
	
	OR
	((StartTime < :start AND StartTime < :end) 
		AND
	(EndTime > :start AND EndTime < :end)))