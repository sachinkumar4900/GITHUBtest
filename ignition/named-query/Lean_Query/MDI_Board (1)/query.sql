
    
    
SELECT 
    h.[StartTime],
    COALESCE(w.[PartNumber], a.[PartNumber]) AS PartNumber,
    h.[PlannedParts],
    CAST(CASE 
        WHEN :resetOption = 0 THEN 
            SUM(h.[PlannedParts]) OVER (PARTITION BY CAST(h.[StartTime] AS DATE) ORDER BY h.[StartTime])
        WHEN :resetOption = 1 THEN 
            SUM(h.[PlannedParts]) OVER (
                PARTITION BY 
                    CASE 
                        WHEN h.[StartTime] >= :startTime THEN 1 
                        ELSE 0 
                    END 
                ORDER BY h.[StartTime]
            )
        WHEN :resetOption = 2 THEN 
            SUM(h.[PlannedParts]) OVER (PARTITION BY YEAR(h.[StartTime]) ORDER BY h.[StartTime])
        ELSE 
            SUM(h.[PlannedParts]) OVER (ORDER BY h.[StartTime])
    END AS INT) CumulativePlannedParts,
    h.[ActualParts],
    CAST(CASE 
        WHEN :resetOption = 0 THEN 
            SUM(h.[ActualParts]) OVER (PARTITION BY CAST(h.[StartTime] AS DATE) ORDER BY h.[StartTime])
        WHEN :resetOption = 1 THEN 
            SUM(h.[ActualParts]) OVER (
                PARTITION BY 
                    CASE 
                        WHEN h.[StartTime] >= :startTime THEN 1 
                        ELSE 0 
                    END 
                ORDER BY h.[StartTime]
            )
        WHEN :resetOption = 2 THEN 
            SUM(h.[ActualParts]) OVER (PARTITION BY YEAR(h.[StartTime]) ORDER BY h.[StartTime])
        ELSE 
            SUM(h.[ActualParts]) OVER (ORDER BY h.[StartTime])
    END AS INT) AS CumulativeActualParts,
    ROUND (
    CASE
        WHEN :targetPercentPlanned IS NOT NULL THEN
            (100 - :targetPercentPlanned) / 100.0 * 
            CASE 
                WHEN :resetOption = 0 THEN 
                    SUM(h.[PlannedParts]) OVER (PARTITION BY CAST(h.[StartTime] AS DATE) ORDER BY h.[StartTime])
                WHEN :resetOption = 1 THEN 
                    SUM(h.[PlannedParts]) OVER (
                        PARTITION BY 
                            CASE 
                                WHEN h.[StartTime] >= :startTime THEN 1 
                                ELSE 0 
                            END 
                        ORDER BY h.[StartTime]
                    )
                WHEN :resetOption = 2 THEN 
                    SUM(h.[PlannedParts]) OVER (PARTITION BY YEAR(h.[StartTime]) ORDER BY h.[StartTime])
                ELSE 
                    SUM(h.[PlannedParts]) OVER (ORDER BY h.[StartTime])
            END
        ELSE NULL
    END, 0
    )AS TargetPlannedParts,
    CAST(CASE
        WHEN :resetOption = 0 THEN 
            SUM(h.[PlannedParts]) OVER (PARTITION BY CAST(h.[StartTime] AS DATE) ORDER BY h.[StartTime]) -
            SUM(h.[ActualParts]) OVER (PARTITION BY CAST(h.[StartTime] AS DATE) ORDER BY h.[StartTime])
        WHEN :resetOption = 1 THEN 
            SUM(h.[PlannedParts]) OVER (
                PARTITION BY 
                    CASE 
                        WHEN h.[StartTime] >= :startTime THEN 1 
                        ELSE 0 
                    END 
                ORDER BY h.[StartTime]
            ) -
            SUM(h.[ActualParts]) OVER (
                PARTITION BY 
                    CASE 
                        WHEN h.[StartTime] >= :startTime THEN 1 
                        ELSE 0 
                    END 
                ORDER BY h.[StartTime]
            )
        WHEN :resetOption = 2 THEN 
            SUM(h.[PlannedParts]) OVER (PARTITION BY YEAR(h.[StartTime]) ORDER BY h.[StartTime]) -
            SUM(h.[ActualParts]) OVER (PARTITION BY YEAR(h.[StartTime]) ORDER BY h.[StartTime])
        ELSE 
            SUM(h.[PlannedParts]) OVER (ORDER BY h.[StartTime]) -
            SUM(h.[ActualParts]) OVER (ORDER BY h.[StartTime])
    END AS INT) AS MissedParts,
    h.[Scrap],
    CAST(CASE 
        WHEN :resetOption = 0 THEN 
            SUM(h.[Scrap]) OVER (PARTITION BY CAST(h.[StartTime] AS DATE) ORDER BY h.[StartTime])
        WHEN :resetOption = 1 THEN 
            SUM(h.[Scrap]) OVER (
                PARTITION BY 
                    CASE 
                        WHEN h.[StartTime] >= :startTime THEN 1 
                        ELSE 0 
                    END 
                ORDER BY h.[StartTime]
            )
        WHEN :resetOption = 2 THEN 
            SUM(h.[Scrap]) OVER (PARTITION BY YEAR(h.[StartTime]) ORDER BY h.[StartTime])
        ELSE 
            SUM(h.[Scrap]) OVER (ORDER BY h.[StartTime])
    END AS INT) AS CumulativeActualScrap,
    Round (
    CASE
        WHEN :targetPercent IS NOT NULL THEN
            (100 - :targetPercent) / 100.0 * 
            CASE 
                WHEN :resetOption = 0 THEN 
                    SUM(h.[ActualParts]) OVER (PARTITION BY CAST(h.[StartTime] AS DATE) ORDER BY h.[StartTime])
                WHEN :resetOption = 1 THEN 
                    SUM(h.[ActualParts]) OVER (
                        PARTITION BY 
                            CASE 
                                WHEN h.[StartTime] >= :startTime THEN 1 
                                ELSE 0 
                            END 
                        ORDER BY h.[StartTime]
                    )
                WHEN :resetOption = 2 THEN 
                    SUM(h.[ActualParts]) OVER (PARTITION BY YEAR(h.[StartTime]) ORDER BY h.[StartTime])
                ELSE 
                    SUM(h.[ActualParts]) OVER (ORDER BY h.[StartTime])
            END
        ELSE NULL
    END , 0
    ) AS CumulativeTargetScrap
FROM 
    [dbo].[HourByHourOEE] h
LEFT JOIN 
    [dbo].[WorkOrderMolding] w
    ON h.[ProductionLineID] <> 11 AND h.[WorkOrderID] = w.[WorkOrderID]
LEFT JOIN 
    [dbo].[WorkOrderAssembly] a
    ON h.[ProductionLineID] = 11 AND h.[WorkOrderID] = a.[WorkOrderID]
WHERE 
    DATEADD(HOUR, -5, h.[StartTime])  BETWEEN :startTime AND :endTime
    AND h.[ProductionLineID] IN (
        SELECT CAST(value AS INT)
        FROM STRING_SPLIT(:ProductionLineID, ',') -- Split the parameter into individual values
    )
    AND h.[WorkOrderID] IS NOT NULL
ORDER BY 
    h.[StartTime] ASC;