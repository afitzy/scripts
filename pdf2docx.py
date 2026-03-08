#!/usr/bin/env python

import argparse
from pdf2docx import Converter

if __name__ == '__main__':
	parser = argparse.ArgumentParser()
	parser.add_argument('sourceFile', help='Source file')
	parser.add_argument('destinationFile', help='Destination file')
	args = parser.parse_args()

	pdf_file  = args.sourceFile
	docx_file = args.destinationFile

	# convert pdf to docx
	cv = Converter(pdf_file)
	cv.convert(docx_file, start=0, end=None)
	cv.close()
