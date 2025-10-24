DECLARE	@return_value int
EXEC @return_value = [dbo].[spOEE_MD_AddAssemblyWO]
	@pID					= :ID,
	@pProductionLineID		= :ProductionLineID,
	@pPartNumber			= :PartNumber,
	@pProductFamily			= :ProductFamily,
	@pNumberOfPeople 		= :NumberOfPeople,
	@pRatePerHour			= :RatePerHour,
	@pChangeoverTime		= :ChangeoverTime
	
SELECT	'Return Value' = @return_value