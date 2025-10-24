
Select TOP 5
	Summary.ProductionLineID, 
	Summary.ReasonID,
	Summary.Name as Reason,
	SUM(SUM(Quantity)) over (Partition by Summary.ProductionLineID, Summary.ReasonID) as ScrapTotal,
	SUM(Count(Summary.ReasonID)) over (Partition by Summary.ProductionLineID, Summary.ReasonID) as ScrapEvents
	FROM (
		SELECT TOP (1000) 
			SC.Quantity,
			SC.Timestamp,
			Sc.ProductionLineID,
			ISNULL(SC.ReasonID,-1) as ReasonID,
			ISNULL(SCR.Name,'Unknown') as Name
		  FROM Scrap as SC
		  left join ScrapReason as SCR
		  on SCR.ID = SC.ReasonID
		  WHERE SC.Timestamp >= :StartDate
		  and SC.ProductionLineID = :LineId) as summary
	Group by Summary.ProductionLineID, Summary.ReasonID, Summary.Name
	ORDER BY ScrapTotal DESC