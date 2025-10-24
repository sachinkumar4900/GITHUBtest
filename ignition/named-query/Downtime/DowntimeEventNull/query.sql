SELECT 
    de.ID,
    de.StartTime,
    de.EndTime,
    DATEDIFF(MINUTE, StartTime, EndTime) AS Duration, 
    dr.Name AS Reason,
    c.Text AS Countermeasure
FROM 
    [DowntimeEvent] de
LEFT JOIN [DowntimeReason] dr on de.ReasonID = dr.ID
LEFT JOIN [Comment] c on de.CommentID = c.ID
WHERE 
    EquipmentID = :Equipment
    AND (
        (:Tag1 = 0 AND ReasonID IS NULL) -- If tag1 is off, filter ReasonID NULL
        OR 
        (:Tag1 = 1 AND ReasonID IS NOT NULL AND StartTime BETWEEN :StartDate AND :EndDate) -- If tag1 is on, filter ReasonID NOT NULL and within date range
    )
Order By de.StartTime desc

