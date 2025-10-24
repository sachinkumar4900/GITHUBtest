UPDATE [dbo].[DowntimeEvent]
SET 
    [ReasonID] = :ReasonID,
    [CommentID] = :CommentID
WHERE 
    [ID] = :DowntimeID;
