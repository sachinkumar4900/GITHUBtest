SELECT TOP 1 DATEADD(MINUTE, CONVERT(INT, :offset * 60), Timestamp)
FROM AndonEvent
WHERE EventHeaderID = :EventHeaderID