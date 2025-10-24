SELECT plt.Name AS AssetType, pl.Name AS Asset, pl.ID
  FROM ProductionLine pl
  JOIN ProductionLineType plt ON pl.ProductionLineTypeID = plt.ID
WHERE pl.ProductionSiteID = :siteID
ORDER BY pl.Name