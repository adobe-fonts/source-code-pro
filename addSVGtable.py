#! /usr/bin/env python

"""
Adds an SVG table to a TTF or OTF font.
The file names of the SVG glyphs need to match their corresponding glyph final names.
"""

import os
import sys
import re
from distutils.version import StrictVersion

try:
	from fontTools import ttLib, version
	from fontTools.ttLib.tables import S_V_G_
except ImportError:
	print >> sys.stderr, "ERROR: FontTools Python module is not installed."
	sys.exit(1)

# support for the SVG table was added to FontTools on Aug 28, 2013
# https://github.com/behdad/fonttools/commit/ddcca79308b52dc36b24ef94cab4ab00c8e32376
minFontToolsVersion = '2.5'
if StrictVersion(version) < StrictVersion(minFontToolsVersion):
	print >> sys.stderr, "ERROR:  The FontTools module version must be %s or higher.\n\
	You have version %s installed.\n\
	Get the latest version at https://github.com/behdad/fonttools" % (minFontToolsVersion, version)
	sys.exit(1)


def readFile(filePath):
	f = open(filePath, "rt")
	data = f.read()
	f.close()
	return data


def setIDvalue(data, gid):
	id = re.search(r"<svg.+?(id=\".*?\").+?>", data, re.DOTALL)
	if id:
		newData = re.sub(id.group(1), 'id="glyph%s"' % gid, data)
	else:
		newData = re.sub('<svg', '<svg id="glyph%s"' % gid, data)
	return newData


def fixViewBox(data):
	viewBox = re.search(r"<svg.+?(viewBox=[\"|\'][\d, ]+[\"|\']).+?>", data, re.DOTALL)
	if not viewBox:
		return data
	fixedViewBox = 'viewBox=\"0 1000 1000 1000\"'
	fixedData = re.sub(viewBox.group(1), fixedViewBox, data)
	return fixedData


def getGlyphNameFromFileName(filePath):
	folderPath, fontFileName = os.path.split(filePath)
	fileNameNoExtension, fileExtension = os.path.splitext(fontFileName)
	return fileNameNoExtension


def processFontFile(fontFilePath, svgFilePathsList):
	# retrieve the font's glyph order, to determine the GID later
	font = ttLib.TTFont(fontFilePath)
	glyphOrder = font.getGlyphOrder()

	# first create a dictionary because the SVG glyphs need to be sorted in the table
	svgDocsDict = {}
	for svgFilePath in svgFilePathsList:
		gName = getGlyphNameFromFileName(svgFilePath)
		try:
			gid = glyphOrder.index(gName)
		except ValueError:
			print >> sys.stderr, "ERROR: Could not find a glyph named %s in the font %s." % (gName, os.path.split(fontFilePath)[1])
			continue
		svgItemsList = []
		svgItemData = readFile(svgFilePath)
		svgItemData = setIDvalue(svgItemData, gid)
		svgItemData = fixViewBox(svgItemData)
		svgItemsList.append(svgItemData)
		svgItemsList.extend([gid, gid])
		svgDocsDict[gid] = svgItemsList

	# don't do any changes to the source OTF/TTF font if there's no SVG data
	if not svgDocsDict:
		return

	svgGIDsList = svgDocsDict.keys()
	svgGIDsList.sort()
	svgDocsList = [svgDocsDict[index] for index in svgGIDsList]

	svgTable = S_V_G_.table_S_V_G_()
	svgTable.docList = svgDocsList
	svgTable.colorPalettes = None
	font['SVG '] = svgTable

	# FontTools can't overwrite a font on save,
	# so save to a hidden file, and then rename it
	# https://github.com/behdad/fonttools/issues/302
	folderPath, fontFileName = os.path.split(fontFilePath)
	fileNameNoExtension, fileExtension = os.path.splitext(fontFileName)
	newFontFilePath = os.path.join(folderPath, "%s%s%s" % ('.', fileNameNoExtension, fileExtension))

	font.save(newFontFilePath)
	os.rename(newFontFilePath, fontFilePath)


def validateSVGfiles(svgFilePathsList):
	"""
	Light validation of SVG files.
	Checks that:
		- there is an <xml> header
		- there is an <svg> element
	"""
	validatedPaths = []

	for filePath in svgFilePathsList:
		# skip hidden files (filenames that start with period)
		fileName = os.path.basename(filePath)
		if fileName[0] == '.':
			continue

		# read file
		data = readFile(filePath)

		# find <xml> header
		xml = re.search(r"<\?xml.+?\?>", data)
		if not xml:
			print "WARNING: Could not find <xml> header in the file. Skiping %s" % (filePath)
			continue

		# find <svg> blob
		svg = re.search(r"<svg.+?>.+?</svg>", data, re.DOTALL)
		if not svg:
			print "WARNING: Could not find <svg> element in the file. Skiping %s" % (filePath)
			continue

		validatedPaths.append(filePath)

	return validatedPaths


def getFontFormat(fontFilePath):
	# these lines were scavenged from fontTools
	f = open(fontFilePath, "rb")
	header = f.read(256)
	head = header[:4]
	if head == "OTTO":
		return "OTF"
	elif head in ("\0\1\0\0", "true"):
		return "TTF"
	return None


def run():
	fontFilePath = os.path.realpath(sys.argv[1])
	svgFolderPath = os.path.realpath(sys.argv[2])

	# Font file path
	if os.path.isfile(fontFilePath):
		if getFontFormat(fontFilePath) not in ["OTF", "TTF"]:
			print >> sys.stderr, "ERROR: The path is not a valid OTF or TTF font."
			return
	else:
		print >> sys.stderr, "ERROR: The path to the font is invalid."
		return

	# SVG folder path
	if os.path.isdir(svgFolderPath):
		svgFilePathsList = []
		for dirName, subdirList, fileList in os.walk(svgFolderPath): # Support nested folders
			for file in fileList:
				svgFilePathsList.append(os.path.join(dirName, file)) # Assemble the full paths, not just file names
	else:
		print >> sys.stderr, "ERROR: The path to the folder containing the SVG files is invalid."
		return

	# validate the SVGs
	svgFilePathsList = validateSVGfiles(svgFilePathsList)

	if not svgFilePathsList:
		print >> sys.stderr, "WARNING: No SVG files were found."
		return

	processFontFile(fontFilePath, svgFilePathsList)


if __name__ == "__main__":
	if len(sys.argv) != 3:
		print "To run this script type:\n  python %s <path to input OTF/TTF file>  <path to folder tree containing SVG files>" % sys.argv[0]
	else:
		run()
