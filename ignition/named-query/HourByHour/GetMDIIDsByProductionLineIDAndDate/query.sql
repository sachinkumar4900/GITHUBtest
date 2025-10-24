SELECT ID
FROM HourByHourMDI
WHERE ProductionLineID = :ProductionLineID
  AND (DATEPART(DAY, DATEADD(MINUTE, :offset, StartTime)) = DATEPART(DAY, :day)
  		AND DATEPART(MONTH, DATEADD(MINUTE, :offset, StartTime)) = DATEPART(MONTH, :day)
  		AND DATEPART(YEAR, DATEADD(MINUTE, :offset, StartTime)) = DATEPART(YEAR, :day)
  )
ORDER BY 
  CASE 
    WHEN :Toggle = 0 THEN StartTime
    ELSE NULL
  END ASC,
  CASE 
    WHEN :Toggle = 1 THEN StartTime
    ELSE NULL
  END DESC;
