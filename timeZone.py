#!/usr/bin/env python

from datetime import datetime
import dateutil.parser
from pytz import timezone
import argparse

# Ref: https://stackoverflow.com/a/50710825/4146779
def hasTz(dt):
	if dt.tzinfo is None or dt.tzinfo.utcoffset(dt) is None:
		return False
	elif dt.tzinfo is not None and dt.tzinfo.utcoffset(dt) is not None:
		return True
	else:
		return None

def getTzDict():
	''' Builds a dictionary of common 2-3 letter timezone acronyms to real timezones. It's not accurate, but it is convenient. '''
	import re
	from pytz import all_timezones
	from dateutil.tz import gettz

	pattern = re.compile("^[a-zA-Z]{2,3}$")
	tzDict = {}
	dt = datetime.now()
	for tz in all_timezones:
		tzStr = timezone(tz).localize(dt).strftime('%Z')
		if pattern.match(tzStr):
			tzDict[tzStr] = gettz(tz)
	return tzDict

dtFrmtLng = "%Y-%m-%d %H:%M %Z%z"
dtFrmtShrt = "%b-%d %I:%M %p"

timezones = [
	('Canada (East)', 'Canada/Eastern'),
	('USA (Pacific)', 'US/Pacific'),
	('China', 'Asia/Shanghai'),
	('Netherlands', 'Europe/Amsterdam'),
]

if __name__ == '__main__':
	parser = argparse.ArgumentParser()
	parser.add_argument('timeStart', help='Starting time')
	args = parser.parse_args()

	d0 = dateutil.parser.parse(args.timeStart, tzinfos=getTzDict())
	if hasTz(d0):
		tz = d0.strftime('%Z%z')
		print 'Using provided timezone: {}'.format(tz)
	else:
		tzStr = 'Canada/Eastern'
		d0 = timezone(tzStr).localize(d0)
		tz = d0.strftime('%Z%z')
		print 'No time zone information provided! Assuming {} ({})'.format(tzStr, tz)

	# Formatting ref: https://stackoverflow.com/a/9989441/4146779
	timeZones = [(name, d0.astimezone(timezone(tz)).strftime(dtFrmtLng), '('+d0.astimezone(timezone(tz)).strftime(dtFrmtShrt)+')') for name,tz in timezones]

	# Sort output by earliest to latest datetime
	timeZones = sorted(timeZones, key=lambda x: x[1])

	colWidth = max(len(word) for row in timeZones for word in row) + 2 # padding
	for row in timeZones:
		print "".join(word.ljust(colWidth) for word in row)
