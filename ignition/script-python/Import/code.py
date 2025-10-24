def ImportSchedule(filePath):
	import openpyxl as xl
	
	#filePath = "C:\Projects\PENT23A\ScheduleImport\Schedule2.xlsx"
	
	workbook = xl.load_workbook(filePath, data_only=True)
	
	rows = workbook["Schedule"].iter_rows(2, 40)
	for row in rows:
		if row[0].value is not None and row[1].value is not None:
			plName = row[1].value
			plInfo = system.db.runPrepQuery("SELECT ID, ProductionLineTypeID FROM ProductionLine WHERE [Name] = ?", [plName])
			woTime = 0
			
			if len(plInfo) > 0:
				plID = plInfo[0][0]
				plTypeID = plInfo[0][1]
				
				if plTypeID == 1:
					woQuery = "SELECT WorkOrderID, RatePerHour, ChangeoverTime FROM WorkOrderAssembly WHERE ID = ?"
				else:
					woQuery = "SELECT WorkOrderID, CycleTime, ChangeoverTime FROM WorkOrderMolding WHERE ID = ?"
				ds = system.db.runPrepQuery(woQuery, [row[0].value])
				woID = ds[0][0]		
				start = system.date.addHours(system.date.parse(row[2].value), 4)
				#end = system.date.addHours(system.date.parse(row[3].value), 4)
				qty = row[3].value
				
				rate = ds[0][1]
				changeover = ds[0][2]
				
				if plTypeID == 1:
					mins = ((qty * 1.0) / rate) * 60 + changeover
				else:
					mins = ((qty * rate) / 60.0) + changeover
				
				end = system.date.addMinutes(start, int(mins))
				
				if woID is not None:
					system.db.runPrepUpdate("INSERT INTO WorkOrderSchedule(WorkOrderID, ProductionLineID, StartTime, EndTime, CommentID, Quantity, StatusID) VALUES(?, ?, ?, ?, ?, ?, ?)", [woID, plID, start, end, None, qty, None])