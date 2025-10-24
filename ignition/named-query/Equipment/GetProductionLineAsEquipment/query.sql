SELECT e.ID
FROM Equipment e
JOIN ProductionLine pl ON e.ProductionLineID = pl.ID
						--AND e.Name = pl.Name
WHERE pl.ID = :plID