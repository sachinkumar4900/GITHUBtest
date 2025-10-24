EXEC [dbo].[sp_GetMDIBoardData]
	@startTime	= :startTime,
    @endTime 	= :endTime,
    @resetOption	= :resetOption,
    @targetPercentPlanned	= :targetPercentPlanned,
    @targetPercent	= :targetPercent,
    @ProductionLineID	= :ProductionLineID,
    @ProductionSIteID = :ProductionSiteID