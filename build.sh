#!/bin/sh

family=SourceCodePro
romanWeights='Black Bold ExtraLight Light Medium Regular Semibold'
italicWeights='BlackIt BoldIt ExtraLightIt LightIt MediumIt It SemiboldIt'

# path to Python script that adds the SVG table
addSVG=$(cd $(dirname "$0") && pwd -P)/addSVGtable.py

# clean existing build artifacts
rm -rf target/
mkdir target/ target/OTF/ target/TTF/

for w in $romanWeights
do
  makeotf -f Roman/$w/font.ufo -r -o target/OTF/$family-$w.otf
  makeotf -f Roman/$w/font.ttf -r -o target/TTF/$family-$w.ttf
  rm Roman/$w/current.fpr # remove default options file from the source tree after building
  $addSVG target/OTF/$family-$w.otf svg/
  $addSVG target/TTF/$family-$w.ttf svg/
done

for w in $italicWeights
do
  makeotf -f Italic/$w/font.ufo -r -o target/OTF/$family-$w.otf
  makeotf -f Italic/$w/font.ttf -r -o target/TTF/$family-$w.ttf
  rm Italic/$w/current.fpr # remove default options file from the source tree after building
  $addSVG target/OTF/$family-$w.otf svg/
  $addSVG target/TTF/$family-$w.ttf svg/
done
