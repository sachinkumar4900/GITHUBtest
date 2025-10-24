DECLARE @ProductionLineID INT = :ProductionLineID;
DECLARE @StartDate DATETIME = :startDate;
DECLARE @EndDate DATETIME = :endDate;
DECLARE @Top INT = :TopSelect;

WITH EventData AS (
    SELECT
        DR.Name AS Reason,
        SUM(HBHQD.Occurrences) AS MissedParts
    FROM dbo.HourByHourQualityAndDelivery HBHQD
    LEFT JOIN dbo.ScrapReason DR 
        ON HBHQD.ScrapReasonID = DR.ID
    LEFT JOIN dbo.HourByHourMDI HBH 
        ON HBHQD.HourByHourMDIID = HBH.ID
    WHERE
        HBHQD.ScrapReasonID IS NOT NULL
		AND HBH.WorkOrderID IS NOT NULL
        AND HBHQD.Occurrences >= 1
        AND HBH.ProductionLineID = @ProductionLineID
        AND HBH.StartTime BETWEEN @StartDate AND @EndDate
    GROUP BY DR.Name
)
, RankedData AS (
    SELECT 
        Reason,
        MissedParts,
        CAST(MissedParts * 1.0 / SUM(MissedParts) OVER () AS DECIMAL(5,4)) * 100 AS Per, -- Percentage of total
        CAST(
            (
                SUM(MissedParts * 1.0) OVER (ORDER BY MissedParts DESC ROWS UNBOUNDED PRECEDING) 
                / SUM(MissedParts) OVER ()
            ) * 100 AS DECIMAL(5,2)
        ) AS CumulativePer, -- Cumulative percentage
        ROW_NUMBER() OVER (ORDER BY MissedParts DESC) AS RowNum
    FROM EventData
)
SELECT 
    Reason,
    MissedParts,
    Per, -- Individual percentage
    CumulativePer -- Cumulative percentage for Pareto
FROM RankedData
WHERE (@Top = 0 OR RowNum <= 5) -- Show top 6 rows if @Top = 0
ORDER BY MissedParts DESC;

