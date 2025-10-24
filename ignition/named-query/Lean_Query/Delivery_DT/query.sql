DECLARE @Switch INT = :Switch;
DECLARE @TopSelect INT = :TopSelect;

WITH EventData AS (
    SELECT
        CASE 
            WHEN @Switch = 1 THEN Code
            ELSE Code 
        END AS DisplayField,
        CASE 
            WHEN @Switch = 1 THEN Reason
            ELSE Reason
        END AS Details,
        CAST(
        CASE 
            WHEN @Switch = 1 THEN SUM(Duration) / 3600.0
            ELSE SUM(ROUND([PartsDelayed], 0)) -- Ensure aggregation for `PartsDelayed`
        END AS DECIMAL(10,0)) AS Value -- Increased precision to handle larger numbers
    FROM dbo.DowntimeEventLog
    WHERE
        StartTime BETWEEN :startDate AND :endDate
        AND [ProductionLineID] IN (
            SELECT TRY_CAST(value AS INT) -- Using TRY_CAST to handle invalid conversions
            FROM STRING_SPLIT(:Equipement, ',')
            WHERE TRY_CAST(value AS INT) IS NOT NULL -- Exclude invalid entries
        )
    GROUP BY 
        Code, -- Include `Code` used in `CASE` expression
        Reason -- Include `Reason` used in `CASE` expression
)
, RankedData AS (
    SELECT 
        DisplayField,
        Value,
        Details,
        Value * 1.0 / SUM(Value) OVER () AS Per, -- Percentage of total
        CAST(
            (
                SUM(Value * 1.0) OVER (ORDER BY Value DESC ROWS UNBOUNDED PRECEDING) 
                / SUM(Value) OVER ()
            ) * 100 AS DECIMAL(5,2)
        ) AS CumulativePer, -- Cumulative percentage
        ROW_NUMBER() OVER (ORDER BY Value DESC) AS RowNum -- Assign row numbers
    FROM EventData
)
SELECT 
    DisplayField,
    Value,
    Details,
    Per * 100 AS Per, -- Convert `Per` to percentage
    CumulativePer
FROM RankedData
WHERE 
    (@TopSelect = 1 OR RowNum <= 6) -- Include only top 6 rows if @TopSelect = 0
    AND DisplayField IS NOT NULL -- Exclude nulls
ORDER BY Value DESC;

