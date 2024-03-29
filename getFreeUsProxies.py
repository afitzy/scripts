#!/usr/bin/python3

from __future__ import print_function

import requests
from bs4 import BeautifulSoup
import argparse
from enum import Enum


Anonymity = Enum('Anonymity', 'elite anonymous transparent')

def scrape():
	user_agent = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.143 Safari/537.36'
	try:
		page = requests.get("https://www.us-proxy.org", headers={'User-Agent': user_agent})
		content = page.content
	except:
		print("Fail!")
		content = None

	soup = BeautifulSoup(content, "html.parser")

	table = soup.find('tbody')

	header = ["IP Address", "Port", "Code", "Country", "Anonymity", "Google", "Https", "Last Checked"]
	results = []
	for row in table.findAll('tr'):
		rowDict = {}
		for i,col in enumerate(row.findAll('td')):
			rowDict[header[i]] = col.string
		results.append(rowDict)
	return results

def anonymityToEnum(name):
	for x in Anonymity:
		if x.name.lower() in name.lower():
			return x
	return None

def parseTypes(listOfDicts):
	for row in listOfDicts:
		row["Port"] = int(row["Port"])
		row["Anonymity"] = anonymityToEnum(row['Anonymity'])
	return listOfDicts

def flatten(listOfDicts):
	flattened = ["http://{}:{}".format(row["IP Address"], row['Port']) for row in listOfDicts]
	return " ".join(flattened)

def checkCounting(value):
	ivalue = int(value)
	if ivalue < 1:
		raise argparse.ArgumentTypeError("%s is an invalid int value greater than or equal to one" % value)
	return ivalue

def checkNatural(value):
	"""
	Ref: http://stackoverflow.com/a/14117511/4146779
	"""
	ivalue = int(value)
	if ivalue < 0:
		raise argparse.ArgumentTypeError("%s is an invalid positive int value" % value)
	return ivalue

def checkAnonymity(value):
	ivalue = int(value)
	if ivalue < 0 or ivalue > len(Anonymity):
		raise argparse.ArgumentTypeError("%s is an invalid Anonymity level" % value)
	return Anonymity(ivalue)

if __name__ == '__main__':
	parser = argparse.ArgumentParser()
	parser.add_argument('--startIdx', '-i', type=checkCounting, default=1, metavar='startIdx', help='starting index [startIdx...startIdx + maxNum] into proxy list')
	parser.add_argument('--max', '-m', type=checkNatural, default=1, metavar='maxNum', help='max number of proxies returned')
	parser.add_argument('--port', '-p', nargs='+', type=checkNatural, default=[], metavar='port', help='port numbers(s)')
	parser.add_argument('--anonymity', '-a', nargs='+', type=checkAnonymity, default=[Anonymity.elite, Anonymity.anonymous],
		metavar='anonymity', help='anonymity level(s)')
	args = parser.parse_args()

	#print("Args: {}".format(args))

	scraped = parseTypes(scrape())
	#print("Scraped count = {}".format(len(scraped)))

	filtered = scraped
	if len(args.port):
		filtered = list(filter(lambda d: (d['Port'] in args.port), filtered))
	if len(args.anonymity):
		filtered = list(filter(lambda d: (d['Anonymity'] in args.anonymity), filtered))

	startIdx = min(len(filtered), args.startIdx) - 1
	filtered = filtered[startIdx:(startIdx + args.max)]
	#print("Filtered count = {}".format(len(filtered)))
	print(flatten(filtered))
