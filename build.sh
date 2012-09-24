#!/bin/sh

# Build OTFs
for f in $(find . -name 'font.pfa')
do
	makeotf -f $f -r
done

# Build TTFs
for f in $(find . -name 'font.ttf')
do
	makeotf -f $f -gf GlyphOrderAndAliasDB_TT -newNameID4 -r
done
