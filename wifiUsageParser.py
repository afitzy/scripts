import fileinput
from collections import OrderedDict
from bs4 import BeautifulSoup
from lxml import etree
from money import Money, xrates

from datetime import date
from dateutil.relativedelta import relativedelta

import UtilCurrency


def kibibyteToGigabyte(val):
	""" Convert KiB to GB """
	return val * (2**10 / 1e9)


if __name__ == '__main__':
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
		UtilCurrency.setCurrency(currencyBase="CAD", currencyExchg=["USD", "CAD"], date=exchgRateDate)

		mnyFrmt = u"#,####0.0000"
		print "{} thru {}; {:0.03f} GB; ${:0.02f} USD; {} USD:CAD exchg rate ${}; ${}".format(
			bill['start'],
			bill['end'],
			kibibyteToGigabyte(bill['data']),
			bill['cost'],
			exchgRateDate,
			Money(1.00,"USD").to("CAD").format(pattern=mnyFrmt, currency_digits=False),
			Money(bill['cost'], "USD").to(xrates.base),
		)
