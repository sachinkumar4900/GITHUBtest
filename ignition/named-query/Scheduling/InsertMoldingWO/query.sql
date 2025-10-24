DECLARE	@return_value int
EXEC @return_value = [dbo].[spOEE_MD_ADDMoldingWO]
	@pProductionLineID		= :ProductionLineID,
	@pID					= :ID,
	@pPartNumber			= :PartNumber,
	@pMoldNumber			= :MoldNumber,
	@pResinPartNumber		= :ResinPartNumber,
	@pProcessSheetLocation	= :ProcessSheetLocation,
	@pBOMWeight				= :BOMWeight,
	@pCavities				= :Cavities,
	@pCycletime				= :CycleTime,
	@pScrapRate				= :ScrapRate,
	@pChangeoverTime		= :ChangeoverTime
	
SELECT	'Return Value' = @return_value