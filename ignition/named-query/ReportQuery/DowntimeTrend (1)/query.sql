SELECT HHM.[StartTime]
      ,HQAD.[Occurrences]
  FROM [dbo].[HourByHourQualityAndDelivery] HQAD
  LEFT JOIN [dbo].DowntimeReason DR ON HQAD.DowntimeReasonID = DR.ID
  LEFT JOIN [dbo].HourByHourMDI HHM ON HQAD.HourByHourMDIID = HHM.ID
  WHERE
  HQAD.DowntimeReasonID IS NOT NULL
  AND HHM.WorkOrderID IS NOT NULL
  AND HQAD.Occurrences IS NOT NULL
  AND HHM.StartTime BETWEEN :StartTime and :EndTime
  AND DR.Name = :Reason
  AND HHM.ProductionLineID = :ProductionLineID;
  