EXEC [dbo].[sp_GEN_DowntimeEvent]
	@pID 				= :pID,
	@pEquipmentID		= :pEquipmentID,
	@pReasonID			= :pReasonID,
	@pStartTime			= :pStartTime,
	@pEndTime			= :pEndTime,
	@pCommentID			= :pCommentID,
	@pAndonHeaderID		= :pAndonHeaderID,
	@pImpactAvailability = :pImpactAvailability,
	@pIsDelete			= :pIsDelete