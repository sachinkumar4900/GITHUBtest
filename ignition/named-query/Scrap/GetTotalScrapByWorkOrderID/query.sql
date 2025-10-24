DECLARE @offset INT
IF :offset IS NULL
BEGIN
	SET @offset = 0
END
ELSE
BEGIN
	SET @offset = :offset
END

SELECT
	COALESCE(SUM(s.Quantity), 0) AS ScrapCount
FROM Scrap s
	LEFT JOIN WorkOrderSchedule wos ON s.WorkOrderID = wos.WorkOrderID AND s.Timestamp BETWEEN wos.StartTime AND wos.EndTime
WHERE s.WorkOrderID = :pWorkOrderID
	AND s.Timestamp BETWEEN wos.StartTime AND wos.EndTime
	AND GETUTCDATE() BETWEEN wos.StartTime AND wos.EndTime