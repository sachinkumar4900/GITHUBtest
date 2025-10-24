SELECT ps.Name AS Site, plt.Name AS AssetType, pl.Name AS Asset
  FROM ProductionLine pl
  JOIN ProductionSite ps ON pl.ProductionSiteID = ps.ID
  JOIN ProductionLineType plt ON pl.ProductionLineTypeID = plt.ID
WHERE pl.ID = :productionLineID