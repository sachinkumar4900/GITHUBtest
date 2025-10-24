SELECT ID, [Name], ParentReasonID, IIF(NOT EXISTS(SELECT 1 FROM DowntimeReason WHERE ParentReasonId = r.ID), 1, 0) [IsTerminal]
FROM   DowntimeReason r
WHERE r.ParentReasonID = :ReasonId