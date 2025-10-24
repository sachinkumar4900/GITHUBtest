SELECT plt.ID AS ProductionLineTypeID, plt.Name AS ValueStream, s.Name AS Shift, StartTime, Hours
FROM ProductionLineType plt
JOIN ProductionLine pl ON plt.ID = pl.ProductionLineTypeID
JOIN Shift s ON pl.ID = s.ProductionLineID
WHERE s.[Default] = 1 AND pl.ProductionSiteID = :siteID
GROUP BY plt.ID, plt.Name, s.Name, StartTime, Hours