If :ProductionLineTypeID = 1
	BEGIN 
		Select top 1 [ID]
	      ,[WorkOrderID] as 'Work Order ID'
	      ,[ProductionLineID] as 'Production Line ID'
	      ,[ProductFamily] as 'Product Family'
	      ,[PartNumber] as 'Part Number'
	      ,[NumberOfPeople] as 'Number Of People'
	      ,[RatePerHour] as 'Rate Per Hour' 
	      ,[ChangeoverTime] as 'Changeover Time'
	      
		From WorkOrderAssembly
		Where WorkOrderID = :WorkOrderID
		and ProductionLineID = :ProductionLineID
	END
Else
	BEGIN 
		Select top 1 [ID]
	      ,[WorkOrderID] as 'Work Order ID'
	      ,[PartNumber] as 'Part Number'
	      ,[ProductionLineID] as 'Production Line ID'
	      ,[MoldNumber] as 'Mold Number' 
	      ,[ResinPartNumber] as 'Resin Part Number'
	      ,[ProcessSheetLocation] as 'Process Sheet Location'
	      ,[BOMWeight] as 'BOM Weight'
	      ,[Cavities] as 'Cavities'
	      ,[CycleTime] as 'Cycle Time'
	      ,[ScrapRate] as 'Scrap Rate'
	      ,[ChangeoverTime]  as 'Changeover Time'
	      
		From WorkOrderMolding
		Where WorkOrderID = :WorkOrderID
		and ProductionLineID = :ProductionLineID
	END