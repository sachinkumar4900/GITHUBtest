SELECT Code,
       Reason
FROM DowntimeEventLog
WHERE Code IS NOT NULL
      AND [ProductionLineID] IN (
          SELECT TRY_CAST(value AS INT) -- Using TRY_CAST to handle invalid conversions
          FROM STRING_SPLIT(:ProductionLineID, ',')
          WHERE TRY_CAST(value AS INT) IS NOT NULL -- Exclude invalid entries
      )
GROUP BY Code, Reason;
