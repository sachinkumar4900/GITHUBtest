SELECT 
	ID
	,:ProcessArea AS ProcessArea
	,:EquipmentID AS EquipmentID
	,DTCode
FROM DowntimeReason
WHERE  (ReasonGroupID = :ReasonGroupID
		OR :ReasonGroupID = -1)
	AND  [Level] = :Level
	AND DTCode IS NOT NULL