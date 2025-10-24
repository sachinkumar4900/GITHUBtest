DECLARE @plID INT

SELECT @plID = ProductionLineID FROM Equipment WHERE ID = :equipmentID

-- This is used as the column parameter for DowntimeEvent.ImpactAvailability
-- If there is already something impacting availability, this should not also impact availability so return 0

IF EXISTS(
	SELECT *
	FROM DowntimeEvent de
	WHERE EndTime IS NULL AND ImpactAvailability = 1
	AND EquipmentID IN (SELECT ID FROM dbo.GetEquipmentByProductionLineID(@plID))
)
BEGIN
	SELECT 0
END
ELSE
BEGIN
	SELECT 1
END