DECLARE @newTimestamp DATETIME

SET @newTimestamp = GETUTCDATE()

EXEC sp_GEN_Scrap
    @pID =					:pID,
    @pWorkOrderID =			:pWorkOrderID,
    @pQuantity =			:pQuantity,
    @pTimestamp	=			@newTimestamp,
    @pProductionLineID =	:pProductionLineID,
    @pCommentID =			:pCommentID,  
    @pEquipmentID =			:pEquipmentID,
    @pReasonID =			:pReasonID,
    @pIsDelete =			:pIsDelete