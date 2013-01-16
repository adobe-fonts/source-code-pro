#!/bin/sh

family=SourceCodePro
weights=('Black' 'Bold' 'ExtraLight' 'Light' 'Medium' 'Regular' 'Semibold')

# clean existing build artifacts
rm -rf target/
mkdir target/
mkdir target/OTF/
mkdir target/TTF/

for w in ${weights[@]};
do
  makeotf -f Roman/$w/font.pfa -r -o target/OTF/$family-$w.otf
  makeotf -f Roman/$w/font.ttf -gf GlyphOrderAndAliasDB_TT -r -o target/TTF/$family-$w.ttf
  rm Roman/$w/current.fpr # remove default options file from the source tree after building
done
