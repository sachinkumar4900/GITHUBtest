SELECT pl.ID, pl.[Name] AS Asset
FROM ProductionLine pl
WHERE ProductionLineTypeID = :typeID AND ProductionSiteID = :siteID
AND DATEADD(DAY, 1, GETDATE()) > :start