import fileinput
from collections import OrderedDict
from bs4 import BeautifulSoup
from lxml import etree

from datetime import date
from dateutil.relativedelta import relativedelta


# Convert GB to KiB
def kibibyteToGigabyte(val):
	return val * (2**10 / 1e9)

# Recursively search a dictionary for a given key. Return its value if found.
def findItem(obj, key):
	if key in obj: return obj[key]
	for k, v in obj.items():
		if isinstance(v,dict):
			item = findItem(v, key)
			if item is not None:
				return item

# Queries
def usdToCad(date, val=1.0):
	# If date is a weekend, use the Friday before it
	dateOffset = 0 if date.weekday() < 5 else 4 - date.weekday()
	newDate = date + relativedelta(days=dateOffset)
	dateStr = newDate.isoformat()

	rate = 1.30
	try:
		import requests

		# Up-to-the-minute quote
		#r = requests.get('https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.xchange%20where%20pair%20in%20(%22CAD%22)&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback=', timeout=3)
		#return val * float(findItem(r.json(), 'Rate'))

		# Historical quote
		# select * from yahoo.finance.historicaldata where symbol = "CAD=X" and startDate = "2016-11-17" and endDate = "2016-11-17"
		reqStr = 'https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.historicaldata%20where%20symbol%20%3D%20%22CAD%3DX%22%20and%20startDate%20%3D%20%22{startDate}%22%20and%20endDate%20%3D%20%22{endDate}%22&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback='.format(
			startDate=dateStr,
			endDate=dateStr)
		r = requests.get(reqStr, timeout=3)
		rate = float(findItem(r.json(), 'Close'))
	except:
		print "Warning: USD to CAD conversion request failed. Using predefined rate of {}".format(rate)

	return val * rate

billCycleEndDayIncl = 16
costPerGb = 10.00
costPerKb = kibibyteToGigabyte(costPerGb)

# Read WiFi stats from stdin
stdin = [line for line in fileinput.input()]
stdin = "".join(stdin)

# Parse stdin for XML
bills = OrderedDict()
soup = BeautifulSoup(stdin, "xml")
for entry in soup.days.select("day[id]"):
	entryDate = date(
		int(entry.year.text),
		int(entry.month.text),
		int(entry.day.text),
	)
	entryData = int(entry.tx.text) + int(entry.rx.text)

	billDate = entryDate + relativedelta(months=-1) if entryDate.day <= billCycleEndDayIncl else entryDate
	billDateStart = billDate.replace(day=billCycleEndDayIncl+1)
	billDateEnd = billDate.replace(day=billCycleEndDayIncl) + relativedelta(months=1)

	billKey = billDate.strftime("%Y%m")
	billVal = bills.get(billKey, dict(start=billDateStart, end=billDateEnd, data=0, cost=0))
	billVal.update(dict(
		data = billVal['data'] + entryData,
		cost = billVal['cost'] + entryData * costPerKb,
	))
	bills[billKey] = billVal

for k,bill in bills.iteritems():
	exchgRateDate = bill['end'] + relativedelta(days=1)
	usdToCadVal = usdToCad(exchgRateDate)
	print "{} thru {}; {:0.03f} GB; ${:0.02f} USD; {} USD:CAD exchg rate ${:0.04f}; ${:0.02f} CAD".format(
		bill['start'],
		bill['end'],
		kibibyteToGigabyte(bill['data']),
		bill['cost'],
		exchgRateDate,
		usdToCadVal,
		usdToCadVal * bill['cost'],
	)
