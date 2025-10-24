SELECT Code,
		Reason
FROM ScrapEventLog
WHERE
     [ProductionLineID] IN (
     SELECT TRY_CAST(value AS INT) -- Using TRY_CAST to handle invalid conversions
     FROM STRING_SPLIT(:ProductionLineID, ',')
     WHERE TRY_CAST(value AS INT) IS NOT NULL AND Code IS NOT NULL-- Exclude invalid entries
        )