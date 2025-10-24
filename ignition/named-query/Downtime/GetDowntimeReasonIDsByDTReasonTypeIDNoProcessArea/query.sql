SELECT 
	ID
	,:EquipmentID AS EquipmentID
FROM DowntimeReason
WHERE  (ReasonGroupID = :ReasonGroupID
		OR :ReasonGroupID = -1)
	AND  [Level] = :Level