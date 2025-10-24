WITH DailyAggregates AS (
    SELECT 
        CAST(h.[StartTime] AS DATE) AS [Date],
        MAX(h.[StartTime]) AS [LastStartTimeOfDay],
        SUM(h.[PlannedParts]) AS DailyPlannedParts,
        SUM(h.[ActualParts]) AS DailyActualParts,
        SUM(h.[Scrap]) AS DailyScrap
    FROM 
        [dbo].[HourByHourOEE] h
    WHERE 
        h.[StartTime] BETWEEN :startTime AND :endTime
        AND h.[ProductionLineID] IN (
            SELECT CAST(value AS INT)
            FROM STRING_SPLIT(:ProductionLineID, ',') -- Split the parameter into individual values
        )
        AND h.[WorkOrderID] IS NOT NULL
    GROUP BY 
        CAST(h.[StartTime] AS DATE)
),
CumulativeData AS (
    SELECT 
        da.[Date],
        da.[LastStartTimeOfDay],
        SUM(da.DailyPlannedParts) OVER (PARTITION BY da.[Date] ORDER BY da.[LastStartTimeOfDay]) AS CumulativePlannedParts,
        SUM(da.DailyActualParts) OVER (PARTITION BY da.[Date] ORDER BY da.[LastStartTimeOfDay]) AS CumulativeActualParts,
        SUM(da.DailyScrap) OVER (PARTITION BY da.[Date] ORDER BY da.[LastStartTimeOfDay]) AS CurrentMonthScrap,
        ROUND(CASE
            WHEN :targetPercentPlanned IS NOT NULL THEN
                (100 - :targetPercentPlanned) / 100.0 * SUM(da.DailyPlannedParts) OVER (PARTITION BY da.[Date] ORDER BY da.[LastStartTimeOfDay])
            ELSE NULL
        END, 0) AS DailyTargetMissed,
        ROUND(CASE
            WHEN :targetPercent IS NOT NULL THEN
                (100 - :targetPercent) / 100.0 * SUM(da.DailyActualParts) OVER (PARTITION BY da.[Date] ORDER BY da.[LastStartTimeOfDay])
            ELSE NULL
        END, 0) AS DailyTargetScrap
    FROM 
        DailyAggregates da
)
SELECT 
    cd.[Date],
    cd.[LastStartTimeOfDay],
    cd.CumulativePlannedParts,
    cd.CumulativeActualParts,
    cd.CurrentMonthScrap,
    cd.DailyTargetMissed,
    cd.DailyTargetScrap,
    cd.CumulativePlannedParts - cd.CumulativeActualParts AS CurrentMonthMissed
FROM 
    CumulativeData cd
ORDER BY 
    cd.[Date] ASC;
