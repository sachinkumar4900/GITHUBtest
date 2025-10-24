EXEC [dbo].[sp_PLAN_ShiftSchedule]
	@pID 				= :pID,
	@pShiftID			= :pShiftID,
	@pStartTime			= :pStartTime,
	@pEndTime			= :pEndTime,
	@pProductionLineID 	= :pProductionLineID,
	@pIsDelete			= :pIsDelete