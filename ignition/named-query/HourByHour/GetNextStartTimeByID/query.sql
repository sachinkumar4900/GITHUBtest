DECLARE @start DATETIME2,
		@plID INT

SELECT @start = StartTime, @plID = ProductionLineID FROM HourByHourOEE WHERE ID = :id

SELECT TOP 1 StartTime
FROM HourByHourOEE
WHERE StartTime > @start
AND ProductionLineID = @plID
ORDER BY StartTime ASC