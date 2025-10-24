    SELECT *
FROM (
    SELECT h.*, 
           CASE 
               WHEN wom.PartNumber IS NOT NULL THEN wom.PartNumber 
               WHEN woa.PartNumber IS NOT NULL THEN woa.PartNumber 
               ELSE NULL 
           END AS PartNumber,
           CASE 
               WHEN h.PlannedParts != 0 THEN ROUND((CAST(h.ActualParts AS FLOAT) / CAST(h.PlannedParts AS FLOAT) * 100), 0)
               ELSE CAST(h.PlannedParts AS FLOAT)
           END AS Efficiency
    FROM HourByHourMDI h
    LEFT JOIN WorkOrderMolding wom ON h.WorkOrderID = wom.WorkOrderID
    LEFT JOIN WorkOrderAssembly woa ON h.WorkOrderID = woa.WorkOrderID
    WHERE h.StartTime BETWEEN :StartTime AND :EndTime
      AND h.ProductionLineID = :ProductionLineID
) AS Sub
WHERE Sub.Efficiency != 0
ORDER BY Sub.StartTime;


/* OLD LOGIC 

SELECT h.*, 
       CASE 
           WHEN wom.PartNumber IS NOT NULL THEN wom.PartNumber 
           WHEN woa.PartNumber IS NOT NULL THEN woa.PartNumber 
           ELSE NULL 
       END AS PartNumber,
       CASE 
           WHEN h.PlannedParts != 0 THEN round((CAST(h.ActualParts AS FLOAT)/CAST(h.PlannedParts AS FLOAT)*100),0)
           ELSE CAST(h.PlannedParts AS FLOAT)
       END AS Efficiency,
       DATEADD(hour, {[default]General/Sanford UTC offset}, h.StartTime) AS MStartTime
FROM HourByHourMDI h
LEFT JOIN WorkOrderMolding wom 
    ON h.WorkOrderID = wom.WorkOrderID
LEFT JOIN WorkOrderAssembly woa 
    ON h.WorkOrderID = woa.WorkOrderID
WHERE 
    h.StartTime 
        BETWEEN {StartDate_String} AND {EndDate_String}
    AND h.ProductionLineID = 1
    AND (
        (h.ProductionLineID <> 11 AND wom.PartNumber IS NOT NULL) 
        OR 
        (h.ProductionLineID = 11 AND woa.PartNumber IS NOT NULL)
    )
ORDER BY 
    MStartTime;*/
