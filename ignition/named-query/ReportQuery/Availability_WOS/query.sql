SELECT 
	 SUM(DATEDIFF(SECOND,GREATEST(StartTime, :StartDate),LEAST(EndTime, :EndDate))) AS TotalTimeInSeconds
FROM [dbo].[WorkOrderSchedule]
WHERE ProductionLineID = :ProductionLineID 
AND StartTime < :EndDate
AND EndTime > :StartDate


