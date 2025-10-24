SELECT HHM.[StartTime]
      ,SUM(ROUND(HQAD.[Occurrences], 0)) OVER (ORDER BY StartTime) AS MissedParts
  FROM [dbo].[HourByHourQualityAndDelivery] HQAD
  LEFT JOIN [dbo].ScrapReason DR ON HQAD.ScrapReasonID = DR.ID
  LEFT JOIN [dbo].HourByHourMDI HHM ON HQAD.HourByHourMDIID = HHM.ID
  WHERE
  HQAD.ScrapReasonID IS NOT NULL
  AND HQAD.Occurrences IS NOT NULL
  AND HHM.StartTime BETWEEN :StartTime and :EndTime
  AND DR.Name = :Reason
  AND HHM.ProductionLineID = :ProductionLineID;
  