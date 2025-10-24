SELECT 
    Reason,
    SUM(Duration) / 60 AS Duration
FROM (
    SELECT 
        Reason,
        SUM(Duration) AS Duration,  -- Aggregate Duration properly
        RANK() OVER (ORDER BY SUM(Duration) DESC) AS Rank
    FROM [dbo].[DowntimeEventLog]
    WHERE Reason Is NOT NULL and ProductionLineID = :ProductionLineID
      AND StartTime BETWEEN :StartDate AND :EndDate
    GROUP BY Reason
    HAVING SUM(Duration) / 60 >= 1
) AS RankedData
WHERE (:Top = 0 OR Rank <= 5)
GROUP BY Reason
ORDER BY Duration DESC;



