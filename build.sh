#!/bin/sh

family=SourceCodePro
romanWeights='Black Bold ExtraLight Light Medium Regular Semibold'
italicWeights='BlackIt BoldIt ExtraLightIt LightIt MediumIt It SemiboldIt'

# path to Python script that adds the SVG table
addSVG=$(cd $(dirname "$0") && pwd -P)/addSVGtable.py

# path to UVS file
UVS=$(cd $(dirname "$0") && pwd -P)/uvs.txt

# clean existing build artifacts
rm -rf target/
otfDir="target/OTF"
ttfDir="target/TTF"
mkdir -p $otfDir $ttfDir

for w in $romanWeights
do
  makeotf -f Roman/$w/font.ufo -r -ci "$UVS" -o $otfDir/$family-$w.otf
  makeotf -f Roman/$w/font.ttf -r -ci "$UVS" -o $ttfDir/$family-$w.ttf
  rm Roman/$w/current.fpr # remove default options file from the source tree after building
  "$addSVG" $otfDir/$family-$w.otf svg
  "$addSVG" $ttfDir/$family-$w.ttf svg
done

for w in $italicWeights
do
  makeotf -f Italic/$w/font.ufo -r -ci "$UVS" -o $otfDir/$family-$w.otf
  makeotf -f Italic/$w/font.ttf -r -ci "$UVS" -o $ttfDir/$family-$w.ttf
  rm Italic/$w/current.fpr # remove default options file from the source tree after building
  "$addSVG" $otfDir/$family-$w.otf svg
  "$addSVG" $ttfDir/$family-$w.ttf svg
done
