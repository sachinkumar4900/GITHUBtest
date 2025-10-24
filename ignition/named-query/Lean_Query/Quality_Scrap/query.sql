DECLARE @TopSelect INT = :TopSelect;

WITH ScrapData AS (
    SELECT 
        sr.[ScrapCode] AS Code,
        sr.[Name] AS Details,
        SUM(s.[Quantity]) AS TotalScrap
    FROM 
        [dbo].[Scrap] s
    JOIN 
        [dbo].[ScrapReason] sr
    ON 
        s.[ReasonID] = sr.[ID]
     WHERE 
    	 s.[Timestamp] BETWEEN :startDate AND :endDate
    	 AND [ProductionLineID] IN (
            SELECT CAST(value AS INT)
            FROM STRING_SPLIT(:ProductionLineID, ',') -- Split the parameter into individual values
        )
    GROUP BY 
        sr.[ID], sr.[ScrapCode],sr.[Name]
), 
RankedScrap AS (
    SELECT 
        *,
        SUM(TotalScrap) OVER () AS TotalScrapOverall,
        SUM(TotalScrap) OVER (ORDER BY TotalScrap DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RunningTotal,
        ROW_NUMBER() OVER (ORDER BY TotalScrap DESC) AS RowNum -- Assign row numbers for ranking
    FROM 
        ScrapData
)
SELECT 
    Code,
    Details,
    TotalScrap,
    CAST((RunningTotal * 100.0 / TotalScrapOverall) AS DECIMAL(5, 2)) AS CumulativePercentage
FROM 
    RankedScrap
WHERE 
    (@TopSelect = 0 OR RowNum <= 6) AND Code IS NOT NULL -- Dynamically select either all rows or only the top 6 rows
ORDER BY 
    TotalScrap DESC;

