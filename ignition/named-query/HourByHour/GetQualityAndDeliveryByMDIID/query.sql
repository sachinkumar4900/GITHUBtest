SELECT TOP 4 qd.[ID]
      ,qd.[DowntimeReasonID]
      ,qd.[ScrapReasonID]
      ,qd.[EventCode]
      ,qd.[Occurrences]
      ,qd.[HourByHourMDIID]
      ,qd.[SortOrder]
      ,qd.[Countermeasure]
      ,qd.[CountermeasureModifiedBy]
      ,CASE WHEN qd.[ScrapReasonID] IS NOT NULL THEN 'Scrap' ELSE 'Downtime' END AS EventType
	  ,CASE WHEN qd.[ScrapReasonID] IS NOT NULL THEN sr.[Name] ELSE dr.[Name] END AS Reason
FROM HourByHourQualityAndDelivery qd
LEFT JOIN DowntimeReason dr ON qd.DowntimeReasonID = dr.ID
LEFT JOIN ScrapReason sr ON qd.ScrapReasonID = sr.ID
WHERE HourByHourMDIID = :MDIID 
ORDER BY SortOrder