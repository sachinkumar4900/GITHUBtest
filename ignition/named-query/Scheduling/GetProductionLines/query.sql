IF :case = 0
BEGIN
	Select * 
	From ProductionLine
	WHERE
	(ProductionLineTypeID = 1 and ProductionSiteID = 1 and :AssemblySF = 1) or 
	(ProductionLineTypeID = 2 and ProductionSiteID = 1 and :MoldingSF = 1) or 
	(ProductionLineTypeID = 1 and ProductionSiteID = 2 and :AssemblyMP = 1) or 
	(ProductionLineTypeID = 2 and ProductionSiteID = 2 and :MoldingMP= 1)
	ORDER BY [Name]
END
ELSE IF :case = 1
BEGIN
	Select * 
	From ProductionLine
	WHERE
	ProductionSiteID = 1
	ORDER BY [Name]
END
ELSE IF :case = 2 
BEGIN 
	Select * 
	From ProductionLine 
	WHERE
	ProductionSiteID = 2
	ORDER BY [Name]
END
ELSE 
BEGIN 
	Select * 
	From ProductionLine
	ORDER BY [Name]
END