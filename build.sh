#!/usr/bin/env sh

family=SourceCodePro
romanWeights=('Black' 'Bold' 'ExtraLight' 'Light' 'Medium' 'Regular' 'Semibold')
italicWeights=('BlackIt' 'BoldIt' 'ExtraLightIt' 'LightIt' 'MediumIt' 'It' 'SemiboldIt')

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
  font_path=Roman/Instances/$w/font
  makeotf -f $font_path.ufo -r -ci "$UVS" -o $otfDir/$family-$w.otf
  makeotf -f $font_path.ttf -r -ci "$UVS" -o $ttfDir/$family-$w.ttf -ff $font_path.ufo/features.fea
  "$addSVG" $otfDir/$family-$w.otf svg
  "$addSVG" $ttfDir/$family-$w.ttf svg
done

for w in $italicWeights
do
  font_path=Italic/Instances/$w/font
  makeotf -f $font_path.ufo -r -ci "$UVS" -o $otfDir/$family-$w.otf
  makeotf -f $font_path.ttf -r -ci "$UVS" -o $ttfDir/$family-$w.ttf -ff $font_path.ufo/features.fea
  "$addSVG" $otfDir/$family-$w.otf svg
  "$addSVG" $ttfDir/$family-$w.ttf svg
done
