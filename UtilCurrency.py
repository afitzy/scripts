#!/usr/bin/python

from __future__ import print_function

import logging
from datetime import date
from dateutil.relativedelta import relativedelta
import requests
import json
from decimal import Decimal
from money import Money, xrates


def getPreviousWeekday(date=date.today()):
	"""
	Returns the ISO format date of the previous weekday.
	If date is a weekend, use the Friday before it.
	"""
	datePrev = date + relativedelta(days=-1)
	dateOffset = 0 if datePrev.weekday() < 5 else 4 - datePrev.weekday()
	newDate = datePrev + relativedelta(days=dateOffset)
	return newDate.isoformat()

def getExchgRate(currencyIn="USD", currencyOut=["CAD"], date=date.today()):
	"""
	Returns an exchange rate using https://github.com/hakanensari/fixer-io
	"""
	logger = logging.getLogger("root")

	if date > date.today():
		date = date.today()
		logger.error("Requested date is in the future! Using today instead.")

	dateStr = getPreviousWeekday() if date == date.today() else date
	currencyOutStr = ','.join(currencyOut)
	logger.info("Querying {}:[{}] on {}".format(currencyIn, currencyOutStr, dateStr))

	reqStr = "http://api.fixer.io/latest"
	params = dict(
		base = currencyIn,
		symbols = currencyOutStr,
		date = dateStr,
	)

	resp = requests.get(url=reqStr, params=params, timeout=3)
	data = json.loads(resp.text)
	return data

def setCurrency(currencyBase="USD", currencyExchg=["USD", "CAD", "EUR", "SGD", "JPY", "CNY", "GBP"], date=date.today()):
	logger = logging.getLogger("root")

	xrates.install('money.exchange.SimpleBackend')
	xrates.base = currencyBase

	try:
		currencies.remove(currencyBase)
	except:
		logger.warn("Could not remove target currency from currency list")

	exchgRates = getExchgRate(currencyIn=currencyBase, currencyOut=currencyExchg, date=date)
	for c,r in exchgRates['rates'].items():
		xrates.setrate(c, Decimal(r))


if __name__ == '__main__':
	print(getPreviousWeekday())
	print(getExchgRate("USD", ["CAD", "GBP"]))
	setCurrency()
	print("CAD {} = {}".format(1, Money(1, "CAD").to("USD")))
	print("USD {} = {}".format(1, Money(1, "USD").to("CAD")))
