#!/usr/bin/env python3

"""
Adds an SVG table to a TTF or OTF font.
The file names of the SVG glyphs need to match their corresponding glyph final names.
"""

import os
import sys
import re

try:
    from fontTools import ttLib
except ImportError:
    print("ERROR: FontTools Python module is not installed.", file=sys.stderr)
    sys.exit(1)

TABLE_TAG = 'SVG '

# Regexp patterns
reSVGelement = re.compile(r"<svg.+?>.+?</svg>", re.DOTALL)
reIDvalue = re.compile(r"<svg[^>]+?(id=\".*?\").+?>", re.DOTALL)
reViewBox = re.compile(r"<svg.+?(viewBox=[\"|\'][\d, ]+[\"|\']).+?>", re.DOTALL)
reWhiteSpace = re.compile(r">\s+<", re.DOTALL)


def readFile(filePath):
    with open(filePath, "rt") as f:
        return f.read()


def setIDvalue(data, gid):
    id = reIDvalue.search(data)
    if id:
        newData = re.sub(id.group(1), 'id="glyph{}"'.format(gid), data)
    else:
        newData = re.sub('<svg', '<svg id="glyph{}"'.format(gid), data)
    return newData


def fixViewBox(data):
    viewBox = reViewBox.search(data)
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
    font = ttLib.TTFont(fontFilePath)

    # first create a dictionary because the SVG glyphs need to be sorted in the table
    svgDocsDict = {}

    for svgFilePath in svgFilePathsList:
        gName = getGlyphNameFromFileName(svgFilePath)

        try:
            gid = font.getGlyphID(gName)
        except KeyError:
            print(
                "ERROR: Could not find a glyph named {} in the font {}.".format(
                    gName, os.path.split(fontFilePath)[1]
                ),
                file=sys.stderr
            )
            continue

        svgItemsList = []
        svgItemData = readFile(svgFilePath)
        svgItemData = setIDvalue(svgItemData, gid)
        svgItemData = fixViewBox(svgItemData)
        # Remove all white space between elements
        for whiteSpace in set(reWhiteSpace.findall(svgItemData)):
            svgItemData = svgItemData.replace(whiteSpace, '><')
        svgItemsList.append(svgItemData.strip())
        svgItemsList.extend([gid, gid])
        svgDocsDict[gid] = svgItemsList

    # don't do any changes to the source OTF/TTF font if there's no SVG data
    if not svgDocsDict:
        print(
            "ERROR: Could not find any artwork files "
            "that can be added to the font.",
            file=sys.stderr
        )
        return

    svgDocsList = [svgDocsDict[index] for index in sorted(svgDocsDict.keys())]

    svgTable = ttLib.newTable(TABLE_TAG)
    svgTable.compressed = False  # GZIP the SVG docs
    svgTable.docList = svgDocsList
    font[TABLE_TAG] = svgTable
    font.save(fontFilePath)
    font.close()

    print(
        "SVG table successfully added to {}".format(fontFilePath),
        file=sys.stderr
    )


def validateSVGfiles(svgFilePathsList):
    """
    Light validation of SVG files.
    Checks that there is an <svg> element.
    """
    validatedPaths = []

    for filePath in svgFilePathsList:
        # skip hidden files (filenames that start with period)
        fileName = os.path.basename(filePath)
        if fileName[0] == '.':
            continue

        # read file
        data = readFile(filePath)

        # find <svg> blob
        svg = reSVGelement.search(data)
        if not svg:
            print(
                "WARNING: Could not find <svg> element in the file. "
                "Skiping {}".format(filePath)
            )
            continue

        validatedPaths.append(filePath)

    return validatedPaths


def getFontFormat(fontFilePath):
    # these lines were scavenged from fontTools
    with open(fontFilePath, "rb") as f:
        header = f.read(256)
        head = header[:4]
    if head == b"OTTO":
        return "OTF"
    elif head in (b"\0\1\0\0", b"true"):
        return "TTF"
    return None


def run():
    fontFilePath = os.path.realpath(sys.argv[1])
    svgFolderPath = os.path.realpath(sys.argv[2])

    # Font file path
    if os.path.isfile(fontFilePath):
        if getFontFormat(fontFilePath) not in ["OTF", "TTF"]:
            print("ERROR: The path is not a valid OTF or TTF font.",
                  file=sys.stderr)
            return
    else:
        print("ERROR: The path to the font is invalid.",
              file=sys.stderr)
        return

    # SVG folder path
    if os.path.isdir(svgFolderPath):
        svgFilePathsList = []
        for dirName, subdirList, fileList in os.walk(
                svgFolderPath):  # Support nested folders
            for file in fileList:
                svgFilePathsList.append(os.path.join(dirName,
                                                     file))  # Assemble the full paths, not just file names
    else:
        print(
            "ERROR: The path to the folder "
            "containing the SVG files is invalid.",
            file=sys.stderr
        )
        return

    # validate the SVGs
    svgFilePathsList = validateSVGfiles(svgFilePathsList)

    if not svgFilePathsList:
        print("WARNING: No SVG files were found.", file=sys.stderr)
        return

    processFontFile(fontFilePath, svgFilePathsList)


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("To run this script type:\n  "
              "python {} <path to input OTF/TTF file>  "
              "<path to folder tree containing SVG files>".format(sys.argv[0]))
    else:
        run()
