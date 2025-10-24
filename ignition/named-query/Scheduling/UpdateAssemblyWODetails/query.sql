Update WorkOrderAssembly
SET
	ProductionLineID		= :ProductionLineID,
	PartNumber			= :PartNumber,
	ProductFamily			= :ProductFamily,
	NumberOfPeople 		= :NumberOfPeople,
	RatePerHour			= :RatePerHour,
	ChangeoverTime		= :ChangeoverTime
Where ID = :ID
Select * from WorkOrderAssembly where ID = :ID