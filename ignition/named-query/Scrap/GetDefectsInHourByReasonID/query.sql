  SELECT COUNT(*) AS ScrapEventCount
  FROM Scrap
  WHERE ReasonID = :ScrapReason
  AND EquipmentID = :EquipmentID
  AND [Timestamp] >= DATEADD(hour, -1, GETDATE())