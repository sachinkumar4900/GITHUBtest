SELECT top(1000) [EventHeaderID]
      ,[ID]
      ,[NotificationGroupID]
      ,[Timestamp]
      ,[ProductionLineID]
      ,[StatusID]
      ,[CommentID]
      ,[ReasonID]
      ,[ProductionSiteID]
  FROM (
  SELECT  ae.*, aes.name, PL.ProductionSiteID, ROW_NUMBER() OVER (PARTITION BY ProductionLineID ORDER BY Timestamp DESC) rn
        FROM    [AndonEvent] as AE
		left join [AndonEventStatus] as AES
		on AES.ID = AE.statusID
		left join [ProductionLine] as PL
		on PL.ID = AE.ProductionLineID
		) active
	
where active.rn = 1 and active.Name != 'Resolved' and ProductionSiteID = :ProductionSiteID