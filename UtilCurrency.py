#!/usr/bin/python

from __future__ import print_function

import logging
from datetime import date,datetime
from dateutil.relativedelta import relativedelta
import requests
import json
from decimal import Decimal
from money import Money, xrates


def getPreviousWeekday(d=date.today()):
	"""
	Returns the date of the previous weekday.
	If date is a weekend, use the Friday before it.
	"""
	datePrev = d + relativedelta(days=-1)
	dateOffset = 0 if datePrev.weekday() < 5 else 4 - datePrev.weekday()
	newDate = datePrev + relativedelta(days=dateOffset)
	return newDate

def getExchgRate(currencyIn="USD", currencyOut=["CAD"], exchgDate=getPreviousWeekday()):
	"""
	Returns exchange rates relative to currencyIn
	"""
	logger = logging.getLogger("root")

	if isinstance(exchgDate, datetime):
		exchgDate = exchgDate.date()
	elif isinstance(exchgDate, str):
		exchgDate =  dateutil.parser.parse(exchgDate)
	elif isinstance(exchgDate, date):
		pass
	else:
		raise ValueError('Unrecognized exchgDate type: {}', type(exchgDate))

	if exchgDate > date.today():
		exchgDate = date.today()
		logger.error("Requested exchgDate is in the future! Using today instead.")

	dateStr = getPreviousWeekday().isoformat() if exchgDate == date.today() else exchgDate
	currencyOutStr = ','.join(currencyOut)
	logger.info("Querying {}:[{}] for {}".format(currencyIn, currencyOutStr, dateStr))

	reqStr = 'https://api.exchangeratesapi.io/{}'.format(dateStr)
	params = dict(
		base = currencyIn,
		symbols = currencyOutStr,
		# date = dateStr,
	)

	resp = requests.get(url=reqStr, params=params, timeout=3)

	try:
		data = json.loads(resp.text)
	except ValueError:
		data = None
		log.fatal('Could not parse JSON from received data.')
		log.debug('Request URL: {}; request parameters: {}; received data: {}'.format(reqStr, params, data))
		raise

	return data

def setCurrency(currencyBase="USD", currencyExchg=["USD", "CAD", "EUR", "SGD", "JPY", "CNY", "GBP"], exchgDate=getPreviousWeekday()):
	logger = logging.getLogger("root")

	xrates.install('money.exchange.SimpleBackend')
	xrates.base = currencyBase

	try:
		currencies.remove(currencyBase)
	except:
		logger.warn('Could not remove target currency from currency list')

	exchgRates = getExchgRate(currencyIn=currencyBase, currencyOut=currencyExchg, exchgDate=exchgDate)

	try:
		rates = exchgRates['rates'].items()
		logger.info('Received exchange rates: {}'.format(rates))
	except:
		logger.fatal('Failed to get exchange rate')
		logger.fatal('Info from server: {}'.format(exchgRates))
		raise

	for c,r in rates:
		xrates.setrate(c, Decimal(r))


if __name__ == '__main__':
	print(getPreviousWeekday().isoformat())
	print(getExchgRate("USD", ["CAD", "GBP"]))
	setCurrency()
	print("CAD {} = {}".format(1, Money(1, "CAD").to("USD")))
	print("USD {} = {}".format(1, Money(1, "USD").to("CAD")))
