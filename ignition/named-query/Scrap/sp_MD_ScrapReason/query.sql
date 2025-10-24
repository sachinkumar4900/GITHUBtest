EXEC [dbo].[sp_MD_ScrapReason]
	@pID 					= :pID,
	@pName					= :pName,
	@pConsecutiveDefects	= :pConsecutiveDefects,
	@pDefectsPerHour		= :pDefectsPerHour,
	@pProductionLineTypeID	= :pProductionLineTypeID,
	@pIsDelete				= :pIsDelete