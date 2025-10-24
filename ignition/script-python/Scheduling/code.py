#Helper function to getDowntimeInfo
#Finds time that the line is unmanned
def getUnplannedTimes(ProductionSiteID, startDate, daysDisplayed, offset = 0):
	shifts = system.db.runNamedQuery("Shift/GetShiftSchedule",{"productionSiteID":ProductionSiteID})
	startTime = system.date.addHours(startDate, -24)#system.date.midnight(startDate)
	endTime = system.date.addDays(startTime, daysDisplayed+1)
	planned = {}
	curDate = startTime
	for day in range(daysDisplayed):
		curDate = system.date.addDays(startTime, day)
		curEnd = system.date.addDays(curDate, 2)
		for row in shifts:
			offsetStart = system.date.addMinutes( row["StartTime"], offset * 60)
			offsetEnd = system.date.addMinutes( row["EndTime"], offset * 60)
			
			if row["ProductionLineID"] in planned.keys() and system.date.isBetween(offsetStart, curDate, curEnd) and system.date.isBetween(offsetEnd, curDate, curEnd):
				planned[row["ProductionLineID"]].append([ row["StartTime"], row["EndTime"]])
				
			elif system.date.isBetween(offsetStart, curDate, curEnd) and system.date.isBetween(offsetEnd, curDate, curEnd):
				planned[row["ProductionLineID"]]= [[row["StartTime"],  row["EndTime"]]]
		
	unplanned = {}
	for line, shifts in planned.items():
		unplanned[line] = [(startTime,shifts[0][0])]
		
		for shift in range(1,len(shifts)):
			if system.date.isBefore(shifts[shift-1][1], shifts[shift][0]):
				unplanned[line].append((shifts[shift-1][1],shifts[shift][0]))
		
		unplanned[line].append((shifts[len(shifts)-1][1],endTime))
		
	return unplanned
	
#Gets downtime and unmanned times on the line. 
#Used to find free time to schedule Work Orders
def getDowntimeInfo(ProductionSiteID, startDate, daysDisplayed, offset = 0):
	#get all line info
	params = {"startTime":startDate,"ProductionLineID":-1, "offset":offset}
	downtimeInfo = []
	ds = system.db.runNamedQuery("Scheduling/GetDowntime", params)
	now = system.date.now()
	for row in range(ds.getRowCount()):
		downtimeInfo.append({
			"itemId":ds.getValueAt(row,"ProductionLineID"),
			"startDate":ds.getValueAt(row,"StartTime"),
			"endDate":ds.getValueAt(row,"EndTime"),
			"underlay":False,
			"color":"#6EB70B" if ds.getValueAt(row,"PlannedDowntime") == 1 else "#E52C4F",
			"opacity":.3,
			"style":{}
		})
	params = {"ProductionSiteID":ProductionSiteID, "offset": offset}
	ds = system.db.runNamedQuery("Scheduling/GetActiveDowntimeEvents", params)
	for row in range(ds.getRowCount()):
		downtimeInfo.append({
			"itemId":ds.getValueAt(row,"ProductionLineID"),
			"startDate":ds.getValueAt(row,"Timestamp"),
			"endDate":now,
			"underlay":False,
			"color":"#E52C4F",
			"opacity":.3,
			"style":{}
		})
			
	for lineID, line in getUnplannedTimes(ProductionSiteID, startDate, daysDisplayed, offset).iteritems():
		for row in line:
			downtimeInfo.append({
				"itemId":lineID,
				"startDate":row[0],
				"endDate":row[1],
				"underlay":False,
				"color":"#D0DF00",
				"opacity":.7,
				"style":{}
			})
		
	return downtimeInfo
#Update all scheduled events 
def updateSchedule(ProductionSiteID, startDate, daysDisplayed, offset = 0):

	now = system.date.now()
	now = system.db.runScalarPrepQuery("SELECT GETUTCDATE()", [])
	
	#get all production Lines
	params = {"ProductionLineID":-1,	"StartTime":startDate,	"EndTime":system.date.addDays(startDate, daysDisplayed)}
	events = system.db.runNamedQuery("Scheduling/GetCurrentWOSchedule",params)
	currentLine = -1
	dte = getDowntimeInfo(ProductionSiteID, startDate, daysDisplayed, offset)
	
	if len(events) > 0:
		recheck = True
		while recheck:
			recheck = False
			for entry in events:
				
				if currentLine != entry["ProductionLineID"] or entry["StatusID"] == 2 or entry["StatusID"] == 4 or system.date.isAfter(now, entry["StartTime"]):
					currentLine = entry["ProductionLineID"]
					
					endTime = system.date.addSeconds(entry["StartTime"], int(entry["Duration"]*3600))
					#Remove 1 minute for screen clarity
					nowPlusFive = system.date.addMinutes(now, 5)
					endTime = nowPlusFive if (system.date.isBefore(entry["EndTime"],nowPlusFive) and (entry["StatusID"] == 1 or entry["StatusID"] == 2 or entry["StatusID"] == 4)) or entry["StatusID"] == 3 else endTime
					#If the line is running and WO is not done, extend the WO end time
					if system.date.isBetween(now, entry["StartTime"], entry["EndTime"]) and entry["StatusID"] < 3:						
						params = {"ID":entry["ID"],
							"StartTime":entry["StartTime"],
							"EndTime":endTime,
							"Quantity":entry["Quantity"]}
						endTime =  system.db.runNamedQuery("Scheduling/UpdateWOScheduleEntry", params)[0][0]
					elif system.date.isBetween(now, entry["StartTime"], entry["EndTime"]) and entry["StatusID"] == 3:
						params = {"ID":entry["ID"],
							"StartTime":entry["StartTime"],
							"EndTime":now,
							"Quantity":entry["Quantity"]}
						endTime =  system.db.runNamedQuery("Scheduling/UpdateWOScheduleEntry", params)[0][0]
					
					elif system.date.isBetween(now, entry["StartTime"], entry["EndTime"]): 
						endTime = entry["EndTime"]
						
				else: 
					endTime = entry["StartTime"] if system.date.isBefore(endTime,now) else endTime
					endTime = Scheduling.updateEvent(entry["ID"],endTime,dte,entry["Quantity"],entry["ProductionLineID"])[0][0]
					
		
	
#Reschedules the event based on the new start time
def updateEvent(WOS, start, DTE, quantity, ProductionLineID):
	import math 
	
	canEditTime = system.date.addHours(system.date.midnight(system.date.now()), -4)
	if system.date.isAfter(start, canEditTime):
		startTime = start
		qty = quantity
		duration = system.db.runNamedQuery("Scheduling/GetNewWODuration", {"Quantity":quantity,"WorkOrderScheduleId":WOS})
		if duration != None:
			duration = int(duration[0][0] * 3600)
		else:
			return
		downtimeEvents = DTE
		includedDT = []
		
		#if there is downtime at the intended start time, move the start back to the first free time
		noStart = True
		while noStart:
			noStart = False
			for item in downtimeEvents:
				if item["itemId"] == ProductionLineID and system.date.isBetween(startTime, item["startDate"], item["endDate"]) and item["endDate"] != startTime:
					noStart = True
					startTime = item["endDate"]		
		lastStart = startTime
		logger = system.util.getLogger("debug")
		endTime = system.date.addSeconds(lastStart, duration)
		checkDt = True
		
		#Extend the duration of the work order while the line is down or unmanned
		while (checkDt):
			checkDt = False

			for item in downtimeEvents:
				if int(ProductionLineID) == int(item["itemId"]) and lastStart < item["startDate"] and endTime > item["startDate"] and item["startDate"] not in includedDT:
					includedDT.append(item["startDate"])
					duration -= system.date.secondsBetween(lastStart, item["startDate"])
					lastStart = item["endDate"]
					endTime = system.date.addSeconds(lastStart, int(duration))
					checkDt = True			
		
		params = {"ID":WOS,
		"StartTime":startTime,
		"EndTime":endTime,
		"Quantity":qty}
		
		return system.db.runNamedQuery("Scheduling/UpdateWOScheduleEntry", params)
	else:
		return []		

#Add a work order at the first available slot
def scheduleEvent(WO, start, DTE, quantity, schedule):
	import math 
	selectedWO = WO
	
	start = system.db.runScalarPrepQuery("SELECT GETUTCDATE()", [])
	
	if selectedWO != None:
		startTime = start
		qty = quantity
		duration = int(selectedWO["TotalTime"] * 60)
		downtimeEvents = DTE
		includedDT = []
		noStart = True
		#if there is downtime or another event at the intended start time, move the start back to the first free time
		while noStart:
			noStart = False
			for item in downtimeEvents:
				if item["itemId"] == selectedWO["ProductionLineID"] and system.date.isBetween(startTime, item["startDate"], item["endDate"]) and item["endDate"] != startTime:
					noStart = True
					startTime = item["endDate"]
			for item in schedule:
				if item["itemId"] == selectedWO["ProductionLineID"] and system.date.isBetween(startTime, item["startDate"], item["endDate"]) and item["endDate"] != startTime:
					noStart = True
					startTime = item["endDate"]
					
		lastStart = startTime
		logger = system.util.getLogger("debug")
		endTime = system.date.addMinutes(lastStart, duration)
		checkDt = True
		while (checkDt):
			checkDt = False
			#Make sure this work order isn't overriding another one
			for item in schedule:
				if int(selectedWO["ProductionLineID"]) == int(item["itemId"]) and lastStart < item["startDate"] and endTime > item["startDate"]:
					lastStart = item["endDate"]
					duration = int(selectedWO["TotalTime"] * 60)
					
					includedDT = []
					endTime = system.date.addMinutes(lastStart, duration)
					checkDt = True
			#Extend the duration of the work order while the line is down or unmanned
			for item in downtimeEvents:
				if int(selectedWO["ProductionLineID"]) == int(item["itemId"]) and lastStart < item["startDate"] and endTime > item["startDate"] and item["startDate"] not in includedDT:
					includedDT.append(item["startDate"])
					duration -= system.date.minutesBetween(lastStart, item["startDate"])
					lastStart = item["endDate"]
					endTime = system.date.addMinutes(lastStart, int(duration))
					checkDt = True
					
					
		params = {"StartTime":system.date.addDays(start, -1), "ProductionLineID":selectedWO["ProductionLineID"],"EndTime":system.date.addHours(startTime,1)}
		checkRunning = system.db.runNamedQuery("Scheduling/GetCurrentWOSchedule", params)
		running = False
		
		for event in checkRunning:
			if event["StartTime"] <= startTime and event["EndTime"] >= startTime:
				running = True
				break
		
		if not running or len(checkRunning) == 0:
			tagPath = ""
			tags = system.tag.readBlocking(['TagPaths'])[0].value
			i = 0
			while tagPath == "":
				if tags.getValueAt(i,0) == selectedWO["ProductionLineID"]: tagPath = tags.getValueAt(i,1)
				i += 1
			
			
			countTagPath = tagPath + "/OEE/Quality/Work Order Count"
			system.tag.writeBlocking([countTagPath],[0])
			
			processArea = tagPath.split('/')[1]
			
			#Start Changeover for next work order
			reasonGroupID = 1 if processArea == 'Assembly' else 2
			parentReason = 8 if processArea == 'Assembly' else 4
			
			pID = None
			plID = system.tag.readBlocking([tagPath + "/OEE/ProductionLineID"])[0].value
			pEquipmentID = system.db.runNamedQuery("Equipment/GetProductionLineAsEquipment", {"plID": plID})
			pReasonID = system.db.runPrepQuery('SELECT TOP 1 ID FROM DowntimeReason WHERE (Name = ? OR Name = ?) AND ReasonGroupID = ? AND ParentReasonID = ?', ['Changeover', 'Mold Change', reasonGroupID, parentReason])[0][0] 
			pStartTime = system.db.runNamedQuery('Downtime/GetUTC')[0][0]
			pCommentID = None
			pAndonHeaderID = None
			
			params = {"pID": pID, "pEquipmentID": pEquipmentID, "pReasonID": pReasonID, "pStartTime": pStartTime, "pEndTime": None, "pCommentID": pCommentID, "pAndonHeaderID": pAndonHeaderID, "pIsDelete": False}
			system.db.runNamedQuery("Downtime/sp_GEN_DowntimeEvent", params)
		
		params = {"WorkOrderID":selectedWO["ID"],
		"ProductionLineID":selectedWO["ProductionLineID"],
		"StartTime":startTime,
		"EndTime":endTime,
		"Quantity":qty}
		
		return system.db.runNamedQuery("Scheduling/ScheduleWorkOrder", params)
	else:
		return []
		
def getCompletedPercentage(path, start, end, quantity):
	totalCountPath = "[default]" + path + "/OEE/Quality/Total Daily Count"
	scrapCountPath = "[default]" + path + "/OEE/Quality/Scrap Count"
	
	now = system.db.runScalarPrepQuery("SELECT GETUTCDATE()", [])
	
	if end > now:
		end = now
	
	start = system.date.parse(start)
	end = system.date.parse(end)
	
	startCounts = system.tag.queryTagHistory([totalCountPath, scrapCountPath], startDate = start, endDate = start, returnSize=1, aggregationMode="LastValue", returnFormat='Wide')
	endCounts = system.tag.queryTagHistory([totalCountPath, scrapCountPath], startDate = start, endDate = end, returnSize=1, aggregationMode="LastValue", returnFormat='Wide')
	
	totalStart = startCounts.getValueAt(0, 1)
	if totalStart is None:
		totalStart = 0
	
	scrapStart = startCounts.getValueAt(0, 2)
	if scrapStart is None:
		scrapStart = 0
	
	totalEnd = endCounts.getValueAt(0, 1)
	if totalEnd is None:
		totalEnd = 0
	
	scrapEnd = endCounts.getValueAt(0, 2)
	if scrapEnd is None:
		scrapEnd = 0
	
	total = totalEnd - totalStart
	scrap = scrapEnd - scrapStart
	
	return ((total - scrap) / float(quantity)) * 100
	
def IsDST():
	now = system.date.now()
	
	day = system.date.getDayOfMonth(now)
	month = system.date.getMonth(now)
	dow = system.date.getDayOfWeek(now)
    #January, february, and december are out.
	if (month < 2 or month > 10): 
		return False
    #April to October are in
	if (month > 2 and month < 10):
		return True
	previousSunday = day - dow;
    #In march, we are DST if our previous sunday was on or after the 8th.
	if (month == 2): 
		return previousSunday >= 8
    #In november we must be before the first sunday to be dst.
    #That means the previous sunday must be before the 1st.
	return previousSunday <= 0;	