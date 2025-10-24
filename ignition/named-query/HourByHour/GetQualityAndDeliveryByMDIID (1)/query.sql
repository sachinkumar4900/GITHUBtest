SELECT TOP 4 [ID]
      ,[DowntimeReasonID]
      ,[ScrapReasonID]
      ,[EventCode]
      ,[Occurrences]
      ,[HourByHourMDIID]
      ,[SortOrder]
      ,[Countermeasure]
      ,[CountermeasureModifiedBy]
FROM HourByHourQualityAndDelivery
WHERE [Occurrences] IS NOT NULL and  HourByHourMDIID = :MDIID
ORDER BY SortOrder
