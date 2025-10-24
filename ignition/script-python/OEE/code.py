def getUnplannedDowntime(productionLineID, start, end):
	plID = productionLineID
	
	dt = system.db.runNamedQuery("Downtime/GetUnplannedDowntimeByProductionLineID", {"productionLineID": plID, "start": start, "end": end})
	
	return dt
	
def getPlannedDowntime(productionLineID, start, end):
	plID = productionLineID
	
	dt = system.db.runNamedQuery("Downtime/GetPlannedDowntimeByProductionLineID", {"productionLineID": plID, "start": start, "end": end})
	
	return dt

def getAvailability(tagPath, start, end):
	from datetime import datetime
	if tagPath is None or start is None or end is None:
		return 0

	plIDPath = tagPath + "/OEE/ProductionLineID"
	plID = system.tag.readBlocking([plIDPath])[0].value
	dt = 0
	dt = system.db.runNamedQuery("Downtime/GetUnplannedDowntimeByProductionLineID", {"productionLineID": plID, "start": start, "end": end})

	now = system.db.runNamedQuery("Downtime/GetUTC")[0][0] #< start
	#timeContainsNow = system.date.isBefore(system.date.parse(start), now) and system.date.isAfter(system.date.parse(end), now) 
	#if timeContainsNow:
	dt += system.db.runNamedQuery('Downtime/GetActiveDowntimeDurationByProductionLineID', {"plID": plID, "start": start, "end": end})	#Add active downtime seconds
	plannedDT = system.db.runNamedQuery("Downtime/GetPlannedDowntimeByProductionLineID", {"productionLineID": plID, "start": start, "end": end})
	
	totalTime = system.date.secondsBetween(system.date.parse(start), system.date.parse(end))
	totalTime -= plannedDT
	
	if totalTime is None or totalTime == 0:
		totalTime = 1

	#return float(totalTime - dt - plannedDT) / totalTime
	return float(totalTime - dt) / totalTime

def getPerformance(tagPath, start, end, partOverride = None):
	if tagPath is None or start is None or end is None:
		return 0

	plIDPath = tagPath + "/OEE/ProductionLineID"
	plID = system.tag.readBlocking([plIDPath])[0].value

	dt = system.db.runNamedQuery("Downtime/GetUnplannedDowntimeByProductionLineID", {"productionLineID": plID, "start": start, "end": end})
	now = system.db.runNamedQuery("Downtime/GetUTC")[0][0] #< start
	activeDT = system.db.runNamedQuery('Downtime/GetActiveDowntimeDurationByProductionLineID', {"plID": plID})
	timeContainsNow = system.date.isBefore(system.date.parse(start), now) and system.date.isAfter(system.date.parse(end), now) 
	if timeContainsNow and activeDT:
		dt += activeDT	#Add active downtime seconds
	plannedDT = system.db.runNamedQuery("Downtime/GetPlannedDowntimeByProductionLineID", {"productionLineID": plID, "start": start, "end": end})
	
	totalTime = system.date.secondsBetween(system.date.parse(start), system.date.parse(end))
	if totalTime is None or totalTime == 0:
		totalTime = 1
	
	uptime = totalTime - dt - plannedDT
#	workOrderID = system.db.runScalarPrepQuery("SELECT WorkOrderID FROM WorkOrderSchedule WHERE ProductionLineID = ? AND GETDATE() BETWEEN StartTime AND EndTime", [plID])
	
	expectedParts = 0
	
	totalCountPath = tagPath + "/OEE/Quality/Total Daily Count"
	
	resetTime = system.date.getDate(system.date.getYear(start), system.date.getMonth(start), system.date.getDayOfMonth(start))
	
	if 'Moorpark' in tagPath:
		mpkOffset = system.tag.readBlocking(['[default]General/Moorpark UTC offset'])[0].value
		resetTime = system.date.addHours(resetTime, mpkOffset * -1)
	else:
		sfdOffset = system.tag.readBlocking(['[default]General/Sanford UTC offset'])[0].value
		resetTime = system.date.addHours(resetTime, sfdOffset * -1)
	
	if system.date.isBefore(resetTime, start):
		resetTime = system.date.addDays(resetTime, 1)
	
	#print resetTime, start, end
	
	totalCount = 0
	
	
	if "Molding" in tagPath:
#		if workOrderID is None:
#			workOrderID = 4
		woData = system.db.runNamedQuery("WorkOrder/GetPerformanceWorkOrderMolding", {"StartTime": start, "EndTime":end, "plID":plID})
		for row in woData:
			woStart = row['StartTime']
			woEnd = row['EndTime']
			cavities = float(row['Cavities']) if '+' not in row['Cavities'] else 2 
			
			woTime = system.date.secondsBetween(system.date.parse(woStart), system.date.parse(woEnd)) 
			
			while system.date.isBefore(resetTime, woStart):
				resetTime = system.date.addDays(resetTime, 1)
			
			dt = system.db.runNamedQuery("Downtime/GetUnplannedDowntimeByProductionLineID", {"productionLineID": plID, "start": woStart, "end": woEnd})
			plannedDT = system.db.runNamedQuery("Downtime/GetPlannedDowntimeByProductionLineID", {"productionLineID": plID, "start": woStart, "end": woEnd})
			
			woUptime = woTime - dt - plannedDT
			
			expectedParts += ((woUptime / float(row['CycleTime'])) * cavities)
			
			while system.date.isBetween(resetTime, woStart, woEnd) and system.date.isAfter(resetTime, woStart) and system.date.isBefore(resetTime, woEnd):
				totalCountHistStart = system.tag.queryTagHistory([totalCountPath], startDate = system.date.addMinutes(woStart, 1), endDate = system.date.addMinutes(woStart, 1), returnSize=1, aggregationMode="LastValue", returnFormat='Wide')
				totalCountReset = system.tag.queryTagHistory([totalCountPath], startDate = resetTime, endDate = resetTime, returnSize=1, aggregationMode="LastValue", returnFormat='Wide')
				totalCountStart = totalCountHistStart.getValueAt(0, 1)
				totalCountReset = totalCountReset.getValueAt(0, 1)
				
				totalCount += (totalCountReset - totalCountStart)
				
				woStart = system.date.addMinutes(resetTime, 1)
				resetTime = system.date.addDays(resetTime, 1)
				
			totalCountHistStart = system.tag.queryTagHistory([totalCountPath], startDate = system.date.addMinutes(woStart, 1), endDate = system.date.addMinutes(woStart, 1), returnSize=1, aggregationMode="LastValue", returnFormat='Wide')
			totalCountHistEnd = system.tag.queryTagHistory([totalCountPath], startDate = woEnd, endDate = woEnd, returnSize=1, aggregationMode="LastValue", returnFormat='Wide')
			
			totalCountStart = totalCountHistStart.getValueAt(0, 1)
			totalCountEnd = totalCountHistEnd.getValueAt(0, 1)
	
			totalCount += (totalCountEnd - totalCountStart)
	
		#print("ep: " + str(expectedParts))
		#print("tc: " + str(totalCount))
	else:
#		if workOrderID is None:
#			workOrderID = 6
		woData = system.db.runNamedQuery("WorkOrder/GetPerformanceWorkOrderAssembly", {"StartTime": start, "EndTime":end, "plID":plID})
		for row in woData:
			woStart = row['StartTime']
			woEnd = row['EndTime']
			
			woTime = system.date.secondsBetween(system.date.parse(woStart), system.date.parse(woEnd))
			
			while system.date.isBefore(resetTime, woStart):
				resetTime = system.date.addDays(resetTime, 1)
			
			dt = system.db.runNamedQuery("Downtime/GetUnplannedDowntimeByProductionLineID", {"productionLineID": plID, "start": woStart, "end": woEnd})
			plannedDT = system.db.runNamedQuery("Downtime/GetPlannedDowntimeByProductionLineID", {"productionLineID": plID, "start": woStart, "end": woEnd})
			
			woUptime = woTime - dt - plannedDT
			
			expectedParts += ((woUptime / 3600.0) * float(row['RatePerHour']))
			
			while system.date.isBetween(resetTime, woStart, woEnd) and system.date.isAfter(resetTime, woStart) and system.date.isBefore(resetTime, woEnd):
				totalCountHistStart = system.tag.queryTagHistory([totalCountPath], startDate = system.date.addMinutes(woStart, 1), endDate = system.date.addMinutes(woStart, 1), returnSize=1, aggregationMode="LastValue", returnFormat='Wide')
				totalCountReset = system.tag.queryTagHistory([totalCountPath], startDate = resetTime, endDate = resetTime, returnSize=1, aggregationMode="LastValue", returnFormat='Wide')
				totalCountStart = totalCountHistStart.getValueAt(0, 1)
				totalCountReset = totalCountReset.getValueAt(0, 1)
				
				totalCount += (totalCountReset - totalCountStart)
				
				woStart = system.date.addMinutes(resetTime, 1)
				resetTime = system.date.addDays(resetTime, 1)
				
			totalCountHistStart = system.tag.queryTagHistory([totalCountPath], startDate = system.date.addMinutes(woStart, 1), endDate = system.date.addMinutes(woStart, 1), returnSize=1, aggregationMode="LastValue", returnFormat='Wide')
			totalCountHistEnd = system.tag.queryTagHistory([totalCountPath], startDate = woEnd, endDate = woEnd, returnSize=1, aggregationMode="LastValue", returnFormat='Wide')
			
			totalCountStart = totalCountHistStart.getValueAt(0, 1)
			totalCountEnd = totalCountHistEnd.getValueAt(0, 1)
	
			totalCount += (totalCountEnd - totalCountStart)
	# TODO: handle tag resets. Maybe just take max of each day total counter?
	if partOverride is not None:
		totalCount = partOverride
	
	if expectedParts is None or expectedParts == 0:
		expectedParts = totalCount
		if expectedParts == 0:
			expectedParts = 1
	#print(str(totalCount) + '/' + str(expectedParts))
	return float(totalCount) / expectedParts
	
def getPerformanceTotalCountAndExpectedParts(tagPath, start, end, partOverride = None):
	if tagPath is None or start is None or end is None:
		return 0

	plIDPath = tagPath + "/OEE/ProductionLineID"
	plID = system.tag.readBlocking([plIDPath])[0].value

	dt = system.db.runNamedQuery("Downtime/GetUnplannedDowntimeByProductionLineID", {"productionLineID": plID, "start": start, "end": end})
	now = system.db.runNamedQuery("Downtime/GetUTC")[0][0] #< start
	activeDT = system.db.runNamedQuery('Downtime/GetActiveDowntimeDurationByProductionLineID', {"plID": plID})
	timeContainsNow = system.date.isBefore(system.date.parse(start), now) and system.date.isAfter(system.date.parse(end), now) 
	if timeContainsNow and activeDT:
		dt += activeDT	#Add active downtime seconds
	plannedDT = system.db.runNamedQuery("Downtime/GetPlannedDowntimeByProductionLineID", {"productionLineID": plID, "start": start, "end": end})
	
	totalTime = system.date.secondsBetween(system.date.parse(start), system.date.parse(end))
	if totalTime is None or totalTime == 0:
		totalTime = 1
	
	uptime = totalTime - dt - plannedDT

	expectedParts = 0
	
	totalCountPath = tagPath + "/OEE/Quality/Total Daily Count"
	resetTime = system.date.getDate(system.date.getYear(start), system.date.getMonth(start), system.date.getDayOfMonth(start))
	
	if 'Moorpark' in tagPath:
		mpkOffset = system.tag.readBlocking(['[default]General/Moorpark UTC offset'])[0].value
		resetTime = system.date.addHours(resetTime, mpkOffset * -1)
	else:
		sfdOffset = system.tag.readBlocking(['[default]General/Sanford UTC offset'])[0].value
		resetTime = system.date.addHours(resetTime, sfdOffset * -1)
	
	if system.date.isBefore(resetTime, start):
		resetTime = system.date.addDays(resetTime, 1)
	
	totalCount = 0
	
	if "Molding" in tagPath:
#		if workOrderID is None:
#			workOrderID = 4
		woData = system.db.runNamedQuery("WorkOrder/GetPerformanceWorkOrderMolding", {"StartTime": start, "EndTime":end, "plID":plID})
		
		for row in woData:
			woStart = row['StartTime']
			woEnd = row['EndTime']
			cavities = float(row['Cavities']) if '+' not in row['Cavities'] else 2 
			
			woTime = system.date.secondsBetween(system.date.parse(woStart), system.date.parse(woEnd)) 
			
			while system.date.isBefore(resetTime, woStart):
				resetTime = system.date.addDays(resetTime, 1)
			# commented out for target count on OEE report
			#dt = system.db.runNamedQuery("Downtime/GetUnplannedDowntimeByProductionLineID", {"productionLineID": plID, "start": woStart, "end": woEnd})
			#plannedDT = system.db.runNamedQuery("Downtime/GetPlannedDowntimeByProductionLineID", {"productionLineID": plID, "start": woStart, "end": woEnd})
			
			#woUptime = woTime - dt - plannedDT
			
			expectedParts += ((woTime / float(row['CycleTime'])) * cavities)
			
			while system.date.isBetween(resetTime, woStart, woEnd) and system.date.isAfter(resetTime, woStart) and system.date.isBefore(resetTime, woEnd):
				totalCountHistStart = system.tag.queryTagHistory([totalCountPath], startDate = system.date.addMinutes(woStart, 1), endDate = system.date.addMinutes(woStart, 1), returnSize=1, aggregationMode="LastValue", returnFormat='Wide')
				totalCountReset = system.tag.queryTagHistory([totalCountPath], startDate = resetTime, endDate = resetTime, returnSize=1, aggregationMode="LastValue", returnFormat='Wide')
				totalCountStart = totalCountHistStart.getValueAt(0, 1)
				totalCountReset = totalCountReset.getValueAt(0, 1)
				
				totalCount += (totalCountReset - totalCountStart)
				
				woStart = system.date.addMinutes(resetTime, 1)
				resetTime = system.date.addDays(resetTime, 1)
				
			totalCountHistStart = system.tag.queryTagHistory([totalCountPath], startDate = system.date.addMinutes(woStart, 1), endDate = system.date.addMinutes(woStart, 1), returnSize=1, aggregationMode="LastValue", returnFormat='Wide')
			totalCountHistEnd = system.tag.queryTagHistory([totalCountPath], startDate = woEnd, endDate = woEnd, returnSize=1, aggregationMode="LastValue", returnFormat='Wide')
			
			totalCountStart = totalCountHistStart.getValueAt(0, 1)
			totalCountEnd = totalCountHistEnd.getValueAt(0, 1)
			
			totalCount += (totalCountEnd - totalCountStart)
	else:
#		if workOrderID is None:
#			workOrderID = 6
		woData = system.db.runNamedQuery("WorkOrder/GetPerformanceWorkOrderAssembly", {"StartTime": start, "EndTime":end, "plID":plID})
		for row in woData:
			woStart = row['StartTime']
			woEnd = row['EndTime']
			
			woTime = system.date.secondsBetween(system.date.parse(woStart), system.date.parse(woEnd)) 
			
			while system.date.isBefore(resetTime, woStart):
				resetTime = system.date.addDays(resetTime, 1)
			
			#dt = system.db.runNamedQuery("Downtime/GetUnplannedDowntimeByProductionLineID", {"productionLineID": plID, "start": woStart, "end": woEnd})
			#plannedDT = system.db.runNamedQuery("Downtime/GetPlannedDowntimeByProductionLineID", {"productionLineID": plID, "start": woStart, "end": woEnd})
			
			#woUptime = woTime - dt - plannedDT
			
			expectedParts += ((woTime / 3600.0) * float(row['RatePerHour']))
			
			while system.date.isBetween(resetTime, woStart, woEnd) and system.date.isAfter(resetTime, woStart) and system.date.isBefore(resetTime, woEnd):
				totalCountHistStart = system.tag.queryTagHistory([totalCountPath], startDate = system.date.addMinutes(woStart, 1), endDate = system.date.addMinutes(woStart, 1), returnSize=1, aggregationMode="LastValue", returnFormat='Wide')
				totalCountReset = system.tag.queryTagHistory([totalCountPath], startDate = resetTime, endDate = resetTime, returnSize=1, aggregationMode="LastValue", returnFormat='Wide')
				totalCountStart = totalCountHistStart.getValueAt(0, 1)
				totalCountReset = totalCountReset.getValueAt(0, 1)
				
				totalCount += (totalCountReset - totalCountStart)
				
				woStart = system.date.addMinutes(resetTime, 1)
				resetTime = system.date.addDays(resetTime, 1)
				
			totalCountHistStart = system.tag.queryTagHistory([totalCountPath], startDate = system.date.addMinutes(woStart, 1), endDate = system.date.addMinutes(woStart, 1), returnSize=1, aggregationMode="LastValue", returnFormat='Wide')
			totalCountHistEnd = system.tag.queryTagHistory([totalCountPath], startDate = woEnd, endDate = woEnd, returnSize=1, aggregationMode="LastValue", returnFormat='Wide')
			
			totalCountStart = totalCountHistStart.getValueAt(0, 1)
			totalCountEnd = totalCountHistEnd.getValueAt(0, 1)
			
			totalCount += (totalCountEnd - totalCountStart)
			
	# TODO: handle tag resets. Maybe just take max of each day total counter?

	if partOverride is not None:
		totalCount = partOverride
	
	if expectedParts is None or expectedParts == 0:
		expectedParts = totalCount
		if expectedParts == 0:
			expectedParts = 1
	#print(str(totalCount) + '/' + str(expectedParts))
	return float(totalCount), expectedParts
	
def getQuality(tagPath, start, end, partOverride = None, scrapOverride = None):
	if tagPath is None or start is None or end is None:
		return 0

	scrapPath = tagPath + "/OEE/Quality/Scrap Count"
	totalPath = tagPath + "/OEE/Quality/Total Daily Count"
	plIDPath = tagPath + "/OEE/ProductionLineID"
	plID = system.tag.readBlocking([plIDPath])[0].value
	
	histCountsStart = system.tag.queryTagHistory([scrapPath, totalPath], startDate = system.date.addMinutes(start, 1), endDate = system.date.addMinutes(start, 1), returnSize=1, aggregationMode="LastValue", returnFormat='Wide')
	histCountsEnd = system.tag.queryTagHistory([scrapPath, totalPath], startDate = end, endDate = end, returnSize=1, aggregationMode="LastValue", returnFormat='Wide')
	
	#scrapStart = histCountsStart.getValueAt(0, 1)
	#scrapEnd = histCountsEnd.getValueAt(0, 1)
	totalStart = histCountsStart.getValueAt(0, 2)
	totalEnd = histCountsEnd.getValueAt(0, 2)
	
	total = totalEnd - totalStart
	#scrap = scrapEnd - scrapStart
	scrap = system.db.runNamedQuery('Scrap/GetTotalScrapInTimeFrame', {"start": start, "end": end, "plID": plID})
	if total == 0 or total is None:
		total = 1.0
	
	if scrap is None or scrap < 0:
		scrap = 0
	
	if partOverride is not None:
		total = partOverride
	
	if scrapOverride is not None:
		scrap = scrapOverride
	return float(total - scrap) / total
	
def getOEE(tagPath, start, end):
	avail = getAvailability(tagPath, start, end)
	perf = getPerformance(tagPath, start, end)
	qual = getQuality(tagPath, start, end)
	
	return avail * perf * qual
	
def getTagListByProductionSiteID(productionSiteID):
	site = system.db.runScalarPrepQuery("SELECT [Name] FROM ProductionSite WHERE ID = ?", [productionSiteID])

	valueStreams = [site + "/Molding", site + "/Assembly"]
	
	tags = []
	
	for vs in valueStreams:
	
		results = system.tag.browse(vs, {"tagType":"UdtInstance"}).results
		for result in results:
			tags.append(str(result['fullPath']))

	return tags
	
def getTagListByProductionSiteIDAndProductionLineType(productionSiteID, productionLineTypeID):
	site = system.db.runScalarPrepQuery("SELECT [Name] FROM ProductionSite WHERE ID = ?", [productionSiteID])
	vs = system.db.runScalarPrepQuery("SELECT [Name] FROM ProductionLineType WHERE ID = ?", [productionLineTypeID])

	valueStream = site + "/" + vs
	
	tags = []
	
	results = system.tag.browse(valueStream, {"tagType":"UdtInstance"}).results
	for result in results:
		tags.append(str(result['fullPath']))

	return tags
	
def getSiteAvailability(productionSiteID, start, end):
	tagList = getTagListByProductionSiteID(productionSiteID)
	totalDT = 0

	totalTime = system.date.secondsBetween(system.date.parse(start), system.date.parse(end)) * len(tagList)

	for tag in tagList:
		plIDPath = tag + "/OEE/ProductionLineID"
		plID = system.tag.readBlocking([plIDPath])[0].value
		
		dt = system.db.runNamedQuery("Downtime/GetUnplannedDowntimeByProductionLineID", {"productionLineID": plID, "start": start, "end": end})
		totalDT += dt
		

	return float(totalTime - totalDT) / totalTime
	
def getSitePerformance(productionSiteID, start, end):
	tagList = getTagListByProductionSiteID(productionSiteID)
	totalDT = 0

	totalCount = targetCount = 0

	for tag in tagList:
		plIDPath = tag + "/OEE/ProductionLineID"
		plID = system.tag.readBlocking([plIDPath])[0].value
		
		totalTime = system.date.secondsBetween(system.date.parse(start), system.date.parse(end))
		
		dt = system.db.runNamedQuery("Downtime/GetUnplannedDowntimeByProductionLineID", {"productionLineID": plID, "start": start, "end": end})
		totalDT += dt
		
		uptime = totalTime - dt
		
		workOrderID = system.db.runScalarPrepQuery("SELECT WorkOrderID FROM WorkOrderSchedule WHERE ProductionLineID = ? AND GETDATE() BETWEEN StartTime AND EndTime", [plID])
		
		if "Molding" in tag:
			if workOrderID is None:
				workOrderID = 1297
			
			cycleTime = system.db.runScalarPrepQuery("SELECT CycleTime FROM WorkOrderMolding WHERE WorkOrderID = ?", [workOrderID])
			targetCount = float(uptime) / cycleTime
		else:
			if workOrderID is None:
				workOrderID = 1372
		
			ratePerHour = system.db.runScalarPrepQuery("SELECT RatePerHour FROM WorkOrderAssembly WHERE WorkOrderID = ?", [workOrderID])
			targetCount = uptime * (ratePerHour / 3600.0)
	
		# TODO: handle tag resets. Maybe just take max of each day total counter?
	
		totalCountPath = tag + "/OEE/Quality/Total Daily Count"
		totalCountHist = system.tag.queryTagHistory([totalCountPath], startDate = start, endDate = end, returnSize=1, aggregationMode="LastValue", returnFormat='Wide')
		totalCount += totalCountHist.getValueAt(0, 1)
	
		if targetCount is None or targetCount == 0:
			targetCount = 1

	return float(totalCount) / targetCount
	
def getSiteQuality(productionSiteID, start, end):
	tagList = getTagListByProductionSiteID(productionSiteID)
	scrap = total = 0
	
	for tag in tagList:
		plIDPath = tag + "/OEE/ProductionLineID"
		plID = system.tag.readBlocking([plIDPath])[0].value
		
		scrapPath = tag + "/OEE/Quality/Scrap Count"
		totalPath = tag + "/OEE/Quality/Total Daily Count"
		
		histCounts = system.tag.queryTagHistory([scrapPath, totalPath], startDate = start, endDate = end, returnSize=1, aggregationMode="LastValue", returnFormat='Wide')
		
		scrap += histCounts.getValueAt(0, 1)
		total += histCounts.getValueAt(0, 2)
		
	return float(total - scrap) / total
	
def getSiteOEE(productionSiteID, start, end):
	return 0.99
	
def getTagPathByProductionLineID(productionLineID):
	ds = system.dataset.toPyDataSet(system.tag.readBlocking(["[default]TagPaths"])[0].value)
	for row in ds:
		if row[0] == productionLineID:
			return row[1]
	return None
	
def addHourlyOEEDefaultHour(productionLineID):

	now = system.date.now()
	hour = system.date.addHours(now, -1)
	
	workOrderID = system.db.runScalarPrepQuery("SELECT WorkOrderID FROM WorkOrderSchedule WHERE ProductionLineID = ? AND GETDATE() BETWEEN StartTime AND EndTime", [productionLineID])
	if workOrderID is None:
		print("No Work Order found for: " + str(productionLineID))
	else:
		print("Work Order found for: " + str(productionLineID) + " woID: " + str(workOrderID))
	downtime = system.db.runNamedQuery("HourByHour/GetDowntimeSumForHour", {"productionLineID": productionLineID, "start": hour, "end": now})
	scrap = system.db.runNamedQuery("HourByHour/GetScrapSumForHour", {"productionLineID": productionLineID, "start": hour, "end": now})
	
	uptime = system.date.secondsBetween(hour, now) - downtime
	
	typeID = system.db.runScalarPrepQuery("SELECT ProductionLineTypeID FROM ProductionLine WHERE ID = ?", [productionLineID])
	
	if typeID == 2:
		if workOrderID is None:
			targetCount = 0
		else:
			woData = system.db.runPrepQuery("SELECT CycleTime, Cavities FROM WorkOrderMolding WHERE WorkOrderID = ?", [workOrderID])
			cycleTime = woData[0][0]
			cavities = woData[0][1]
			if cycleTime is None:
				#cycleTime = uptime
				targetCount = 0
			else:
				targetCount = 3600 / cycleTime
				
				if cavities == "1+1":
					cavities = 2
				else:
					cavities = int(cavities)
				
				targetCount *= cavities
	else:
		if workOrderID is None:
			workOrderID = 1372
	
		ratePerHour = system.db.runScalarPrepQuery("SELECT RatePerHour FROM WorkOrderAssembly WHERE WorkOrderID = ?", [workOrderID])
		targetCount = ratePerHour 
	
	path = getTagPathByProductionLineID(productionLineID)
	
	totalPath = path + "/OEE/Quality/Total Daily Count"
	
	startCount = system.tag.queryTagHistory([totalPath], startDate = hour, endDate = hour, returnSize=1, aggregationMode="LastValue", returnFormat='Wide')
	endCount = system.tag.queryTagHistory([totalPath], startDate = system.date.addMinutes(now, -5), endDate = now, returnSize=1, aggregationMode="LastValue", returnFormat='Wide')
	
	#Ignore negative counts due to resets at midnight
	count = endCount.getValueAt(0, 1) - startCount.getValueAt(0, 1) if endCount.getValueAt(0, 1) >= startCount.getValueAt(0, 1) else endCount.getValueAt(0, 1)
	
	avgSpeed = (((60.0 - (downtime / 60.0)) / count) * 60) if count != 0 else 0
	print 'inserting ', hour, workOrderID, productionLineID, targetCount, count, downtime, scrap, avgSpeed
	system.db.runPrepUpdate("INSERT INTO HourByHourOEE(StartTime, WorkOrderID, ProductionLineID, PlannedParts, ActualParts, Downtime, Scrap, AvgSpeed) VALUES(?,?,?,?,?,?,?,?)", [hour, workOrderID, productionLineID, targetCount, count, downtime, scrap, avgSpeed])
	
	#addHourMDIEntry(None, hour, workOrderID, productionLineID, targetCount, count, downtime, scrap, avgSpeed, None, None, None, None, None, False)
	addMDIHourPartChange(productionLineID)
	
def getValueStreamAvailability(productionSiteID, productionLineTypeID, start, end):
	tagList = getTagListByProductionSiteIDAndProductionLineType(productionSiteID, productionLineTypeID)
	totalDT = 0

	totalTime = system.date.secondsBetween(system.date.parse(start), system.date.parse(end)) * len(tagList)

	for tag in tagList:
		plIDPath = tag + "/OEE/ProductionLineID"
		plID = system.tag.readBlocking([plIDPath])[0].value
		
		dt = system.db.runNamedQuery("Downtime/GetUnplannedDowntimeByProductionLineID", {"productionLineID": plID, "start": start, "end": end})
		totalDT += dt
		

	if totalTime == 0:
		totalTime = 1

	return float(totalTime - totalDT) / totalTime
	
def getValueStreamPerformance(productionSiteID, productionLineTypeID, start, end):
	tagList = getTagListByProductionSiteIDAndProductionLineType(productionSiteID, productionLineTypeID)
	totalDT = 0

	totalCount = targetCount = 0

	for tag in tagList:
		tagTotal, tagExpected = getPerformanceTotalCountAndExpectedParts(tag, start, end)
		totalCount += tagTotal
		targetCount += tagExpected

	return float(totalCount) / targetCount
	
def getValueStreamQuality(productionSiteID, productionLineTypeID, start, end):
	tagList = getTagListByProductionSiteIDAndProductionLineType(productionSiteID, productionLineTypeID)
	scrap = total = 0
	
	for tag in tagList:
		plIDPath = tag + "/OEE/ProductionLineID"
		plID = system.tag.readBlocking([plIDPath])[0].value
		
		scrapPath = tag + "/OEE/Quality/Scrap Count"
		totalPath = tag + "/OEE/Quality/Total Daily Count"
		
		histCounts = system.tag.queryTagHistory([scrapPath, totalPath], startDate = start, endDate = end, returnSize=1, aggregationMode="LastValue", returnFormat='Wide')
		
		scrap += histCounts.getValueAt(0, 1)
		total += histCounts.getValueAt(0, 2)
		
	if total == 0:
		total = 1
		
	return float(total - scrap) / total
	
def getValueStreamOEE(productionSiteID, productionLineTypeID, start, end):
	pass
def getAndonPerformance(tagPath, start, end, partOverride = None):
	if tagPath is None or start is None or end is None:
		return 0

	plIDPath = tagPath + "/OEE/ProductionLineID"
	plID = system.tag.readBlocking([plIDPath])[0].value

	dt = system.db.runNamedQuery("Downtime/GetUnplannedDowntimeByProductionLineID", {"productionLineID": plID, "start": start, "end": end})
	now = system.db.runNamedQuery("Downtime/GetUTC")[0][0] #< start
	activeDT = system.db.runNamedQuery('Downtime/GetActiveDowntimeDurationByProductionLineID', {"plID": plID})
	timeContainsNow = system.date.isBefore(system.date.parse(start), now) and system.date.isAfter(system.date.parse(end), now) 
	if timeContainsNow and activeDT:
		dt += activeDT	#Add active downtime seconds
	plannedDT = system.db.runNamedQuery("Downtime/GetPlannedDowntimeByProductionLineID", {"productionLineID": plID, "start": start, "end": end})
	
	totalTime = system.date.secondsBetween(system.date.parse(start), system.date.parse(end))
	if totalTime is None or totalTime == 0:
		totalTime = 1
	
	uptime = totalTime - dt - plannedDT
	expectedParts = 0
	
	if "Molding" in tagPath:
#		if workOrderID is None:
#			workOrderID = 4
		woData = system.db.runNamedQuery("WorkOrder/GetPerformanceWorkOrderMolding", {"StartTime": start, "EndTime":end, "plID":plID})
		for row in woData:
			woStart = row['StartTime']
			woEnd = row['EndTime']
			
			woTime = system.date.secondsBetween(system.date.parse(woStart), system.date.parse(woEnd)) 
			
			dt = system.db.runNamedQuery("Downtime/GetUnplannedDowntimeByProductionLineID", {"productionLineID": plID, "start": woStart, "end": woEnd})
			plannedDT = system.db.runNamedQuery("Downtime/GetPlannedDowntimeByProductionLineID", {"productionLineID": plID, "start": woStart, "end": woEnd})
			
			woUptime = woTime - dt - plannedDT
			
			expectedParts += (woUptime / float(row['CycleTime']))
		#print("ep: " + str(expectedParts))
	else:
#		if workOrderID is None:
#			workOrderID = 6
		woData = system.db.runNamedQuery("WorkOrder/GetPerformanceWorkOrderAssembly", {"StartTime": start, "EndTime":end, "plID":plID})
		for row in woData:
			woStart = row['StartTime']
			woEnd = row['EndTime']
			
			woTime = system.date.secondsBetween(system.date.parse(woStart), system.date.parse(woEnd)) 
			
			dt = system.db.runNamedQuery("Downtime/GetUnplannedDowntimeByProductionLineID", {"productionLineID": plID, "start": woStart, "end": woEnd})
			plannedDT = system.db.runNamedQuery("Downtime/GetPlannedDowntimeByProductionLineID", {"productionLineID": plID, "start": woStart, "end": woEnd})
			
			woUptime = woTime - dt - plannedDT
			
			expectedParts += ((woUptime / 3600.0) * float(row['RatePerHour']))

	totalCountPath = tagPath + "/OEE/Quality/Work Order Count"
	totalCount = system.tag.readBlocking(totalCountPath)[0].value

	if partOverride is not None:
		totalCount = partOverride
	
	if expectedParts is None or expectedParts == 0:
		expectedParts = totalCount
		if expectedParts == 0:
			expectedParts = 1
	#print(str(totalCount) + '/' + str(expectedParts))
	return float(totalCount) / expectedParts
	
def getAndonQuality(tagPath, start, end, partOverride = None, scrapOverride = None):
	if tagPath is None or start is None or end is None:
		return 0

	scrapPath = tagPath + "/OEE/Quality/Scrap Count"
	plIDPath = tagPath + "/OEE/ProductionLineID"
	plID = system.tag.readBlocking([plIDPath])[0].value
	
	totalCountPath = tagPath + "/OEE/Quality/Work Order Count"
	total = system.tag.readBlocking(totalCountPath)[0].value
	scrap = system.db.runNamedQuery('Scrap/GetTotalScrapInTimeFrame', {"start": start, "end": end, "plID": plID})
	if total == 0 or total is None:
		total = 1.0
	
	if scrap is None or scrap < 0:
		scrap = 0
	
	if partOverride is not None:
		total = partOverride
	
	if scrapOverride is not None:
		scrap = scrapOverride
	return float(total - scrap) / total
	
def addHourMDIEntry(pID, pStartTime, pWorkOrderID, pProductionLineID, pPlannedParts, pActualParts, pDowntime, pScrap, pAvgSpeed, pRecovery, pRecoveryModifiedBy, pPlannedPartsModifiedBy, pActualPartsModifiedBy, pShiftScheduleID, pIsDelete):
#	pID = None
#	pStartTime = system.date.now()
#	pWorkOrderID = 1300
#	pProductionLineID = 1
#	pPlannedParts = 100
#	pActualParts = 80
#	pDowntime = 500
#	pScrap = 10
#	pAvgSpeed = 60
#	pCountermeasure = "averted"
#	pRecovery = "recovered"
#	pModifiedBy = "rovisys"
#	pShiftScheduleID = 3920
#	pIsDelete = False
	if pShiftScheduleID is None:
		pShiftScheduleID = system.db.runScalarPrepQuery("SELECT TOP 1 ID FROM ShiftSchedule WHERE ? BETWEEN StartTime AND EndTime AND ProductionLineID = ?", [pStartTime, pProductionLineID])
	
	
	params = {	"pID" 				:pID,
				"pStartTime"		:pStartTime,
				"pWorkOrderID"		:pWorkOrderID,
				"pProductionLineID"	:pProductionLineID,
				"pPlannedParts"		:pPlannedParts,
				"pActualParts"		:pActualParts,
				"pDowntime"			:pDowntime,
				"pScrap"			:pScrap,
				"pAvgSpeed"			:pAvgSpeed,
				"pRecovery"			:pRecovery,
				"pRecoveryModifiedBy"		:pRecoveryModifiedBy,
				"pPlannedPartsModifiedBy"	:pPlannedPartsModifiedBy,
				"pActualPartsModifiedBy"	:pActualPartsModifiedBy,
				"pShiftScheduleID"	:pShiftScheduleID,
				"pIsDelete"			:pIsDelete}
				
	queryPath = "HourByHour/sp_OEE_HourByHourMDI"

	print params
	system.db.runNamedQuery(queryPath, params)
	
def addMDIHourPartChange(productionLineID):
	now = system.date.now()

	path = getTagPathByProductionLineID(productionLineID)
	
	lastHourInsertPath = path + "/OEE/Last Hour Insert"
	
	lastHourInsert = system.tag.readBlocking([lastHourInsertPath])[0].value
	
	if lastHourInsert is not None and system.date.minutesBetween(lastHourInsert, system.date.now()) < 60:
		hour = lastHourInsert
	else:
		hour = system.date.addHours(now, -1)
	
	workOrderID = system.db.runScalarPrepQuery("SELECT WorkOrderID FROM WorkOrderSchedule WHERE ProductionLineID = ? AND GETDATE() BETWEEN StartTime AND EndTime", [productionLineID])
	if workOrderID is None:
		print("No Work Order found for: " + str(productionLineID))
	else:
		print("Work Order found for: " + str(productionLineID) + " woID: " + str(workOrderID))
	downtime = system.db.runNamedQuery("HourByHour/GetDowntimeSumForHour", {"productionLineID": productionLineID, "start": hour, "end": now})
	scrap = system.db.runNamedQuery("HourByHour/GetScrapSumForHour", {"productionLineID": productionLineID, "start": hour, "end": now})
	
	uptime = system.date.secondsBetween(hour, now) - downtime
	
	typeID = system.db.runScalarPrepQuery("SELECT ProductionLineTypeID FROM ProductionLine WHERE ID = ?", [productionLineID])
	
	if typeID == 2:
		if workOrderID is None:
			targetCount = 0
		else:
			woData = system.db.runPrepQuery("SELECT CycleTime, Cavities FROM WorkOrderMolding WHERE WorkOrderID = ?", [workOrderID])
			cycleTime = woData[0][0]
			cavities = woData[0][1]
			if cycleTime is None:
				#cycleTime = uptime
				targetCount = 0
			else:
				targetCount = 3600 / cycleTime
				
				if cavities == "1+1":
					cavities = 2
				else:
					cavities = int(cavities)
				
				targetCount *= cavities
	else:
		if workOrderID is None:
			workOrderID = 1372
	
		ratePerHour = system.db.runScalarPrepQuery("SELECT RatePerHour FROM WorkOrderAssembly WHERE WorkOrderID = ?", [workOrderID])
		targetCount = ratePerHour 
	
	targetCount *= (system.date.secondsBetween(hour, now) / 3600.0)	
	
	totalPath = path + "/OEE/Quality/Total Daily Count"
	
	startCount = system.tag.queryTagHistory([totalPath], startDate = hour, endDate = hour, returnSize=1, aggregationMode="LastValue", returnFormat='Wide')
	endCount = system.tag.queryTagHistory([totalPath], startDate = system.date.addMinutes(now, -5), endDate = now, returnSize=1, aggregationMode="LastValue", returnFormat='Wide')
	
	#Ignore negative counts due to resets at midnight
	count = endCount.getValueAt(0, 1) - startCount.getValueAt(0, 1) if endCount.getValueAt(0, 1) >= startCount.getValueAt(0, 1) else endCount.getValueAt(0, 1)
	
	avgSpeed = (((60.0 - (downtime / 60.0)) / count) * 60) if count != 0 else 0
	print 'inserting ', hour, workOrderID, productionLineID, targetCount, count, downtime, scrap, avgSpeed
	#system.db.runPrepUpdate("INSERT INTO HourByHourOEE(StartTime, WorkOrderID, ProductionLineID, PlannedParts, ActualParts, Downtime, Scrap, AvgSpeed) VALUES(?,?,?,?,?,?,?,?)", [hour, workOrderID, productionLineID, targetCount, count, downtime, scrap, avgSpeed])
	
	addHourMDIEntry(None, hour, workOrderID, productionLineID, targetCount, count, downtime, scrap, avgSpeed, None, None, None, None, None, False)
	system.tag.writeBlocking([lastHourInsertPath], [system.date.now()])