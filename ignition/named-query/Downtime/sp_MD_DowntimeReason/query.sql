EXEC [dbo].[sp_MD_DowntimeReason]
	@pID 				= :pID,
	@pName				= :pName,
	@pReasonGroupID		= :pReasonGroupID,
	@pLevel				= :pLevel,
	@pParentReasonID	= :pParentReasonID,
	@pPlannedDowntime	= :pPlannedDowntime,
	@pAndonGroupID		= :pAndonGroupID,
	@pIsDelete			= :pIsDelete