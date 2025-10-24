SELECT 
	ID
	,:ProcessArea AS ProcessArea
	,:EquipmentID AS EquipmentID
	,DTCode
FROM DowntimeReason
WHERE 
(ParentReasonID = :ParentReasonID OR ( :ParentReasonID = -1 AND [Level] = 2 ))
AND (ID NOT IN (64, 65, 31))