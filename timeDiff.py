#!/usr/bin/env python

from datetime import datetime
import dateutil.parser
import argparse

if __name__ == '__main__':
	parser = argparse.ArgumentParser()
	parser.add_argument('timeStart', help='Starting time')
	parser.add_argument('timeEnd', help='Ending time')
	args = parser.parse_args()

	d0 = dateutil.parser.parse(args.timeStart)
	d1 = dateutil.parser.parse(args.timeEnd)

	delta = d1 - d0
	days = delta.days
	hours, remainder = divmod(delta.seconds, 3600)
	minutes, seconds = divmod(remainder, 60)

	print '{} days, {} hours, {} minutes, {} seconds'.format(days, hours, minutes, seconds)
