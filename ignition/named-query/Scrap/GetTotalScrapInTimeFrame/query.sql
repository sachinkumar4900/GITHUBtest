SELECT 
CASE
	WHEN SUM(Quantity) IS NULL THEN 0
	ELSE SUM(Quantity)
END AS Quantity
FROM Scrap
WHERE ProductionLineID = :plID
	AND  ([Timestamp] BETWEEN :start AND :end)