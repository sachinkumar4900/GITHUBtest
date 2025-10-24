SELECT 
		DT.ID AS ID,
		EquipmentID,
		ReasonID,
		StartTime,
		EndTime,
		CommentID,
		AndonHeaderID,
		ImpactAvailability,
		DR.ID AS ReasonID,
		DR.Name AS Reason,
		ReasonGroupID,
		[Level],
		ParentReasonID,
		PlannedDowntime,
		AndonGroupID,
		PL.Name AS ProductionLine,
		PL.ID AS ProductionLineID,
		AvailabilityIndependent,
		ProductionLineTypeID,
		ProductionSiteID
FROM DowntimeEvent as DT
left join DowntimeReason as DR
on DR.ID = DT.ReasonID
left join Equipment as EQ
on EQ.ID = DT.EquipmentID
left join ProductionLine as PL
on EQ.ProductionLineID = PL.ID
WHERE EndTime > :startTime
 and (:ProductionLineID is NULL or :ProductionLineID  = -1 or PL.ID = :ProductionLineID)