SELECT plt.ID, plt.Name
FROM ProductionLineType plt
JOIN ProductionLine pl ON pl.ProductionLineTypeID = plt.ID
WHERE ProductionSiteID = :siteID
GROUP BY plt.ID, plt.Name