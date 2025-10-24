SELECT TOP 1 StartTime, EndTime
  FROM ShiftSchedule ss
  JOIN ProductionLine pl ON ss.ProductionLineID = pl.ID
  JOIN ProductionLineType plt ON pl.ProductionLineTypeID = plt.ID
  WHERE GETUTCDATE() BETWEEN StartTime AND EndTime
  AND plt.Name = :vsType
  AND pl.ProductionSiteID = :siteID