EXEC [dbo].[sp_GetDowntimePareto]
	@ProductionLineID = :ProductionLineID,
    @StartTime 	= :StartDate,
    @EndTime	= :EndDate,
    @Top	= :Top
