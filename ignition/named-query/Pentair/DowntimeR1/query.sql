DECLARE @Switch INT = :Switch1;

SELECT 
    CASE 
        WHEN @Switch = 0 THEN Reason
        ELSE Reason 
    END AS DisplayField,
    CASE 
        WHEN @Switch = 0 THEN COUNT(*)
        ELSE SUM(Duration)/60
    END AS Value
FROM dbo.DowntimeEventLog
WHERE Equipment = :Equipment
AND StartTime BETWEEN :startTime AND :endtime
-- Uncomment if needed:
-- AND Reason != 'Waiting on Startup' 
-- AND Reason != 'Mold Change' 
GROUP BY 
Reason 
ORDER BY Value DESC;
