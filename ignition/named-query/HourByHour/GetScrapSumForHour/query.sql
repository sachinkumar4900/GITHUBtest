SELECT COALESCE(SUM(Quantity), 0)
FROM Scrap
WHERE EquipmentID IN (SELECT ID FROM dbo.GetEquipmentByProductionLineID(:productionLineID))
AND [Timestamp] BETWEEN :start AND :end