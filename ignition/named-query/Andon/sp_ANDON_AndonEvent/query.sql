EXEC [dbo].[sp_ANDON_AndonEvent]
	@pEventHeaderID			= :pEventHeaderID,
	@pID 					= :pID,
	@pNotificationGroupID	= :pNotificationGroupID,
	@pTimestamp				= :pTimestamp,
	@pProductionLineID 		= :pProductionLineID,
	@pStatusID				= :pStatusID,
	@pCommentID				= :pCommentID,
	@pReasonID				= :pReasonID,
	@pIsDelete				= :pIsDelete