SELECT sr.ID, sr.Name AS Reason, ConsecutiveDefects, DefectsPerHour, ProductionLineTypeID, plt.Name AS ProductionLineType
FROM ScrapReason sr
JOIN ProductionLineType plt ON sr.ProductionLineTypeID = plt.ID