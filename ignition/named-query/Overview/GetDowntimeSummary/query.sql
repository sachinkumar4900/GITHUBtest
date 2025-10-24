DECLARE @eqID INT

IF (:EquipID = 0)
BEGIN
	SET @eqID = NULL
END
ELSE
BEGIN
	SET @eqID = :EquipID
END

EXEC [spOEE_MD_DowntimeSummary]
@pLineID = :LineId,
@pEquipID = @eqID,
@pStartDate = :StartDate,
@pEndDate = :EndDate,
@pIncPlanned = :IncPlanned