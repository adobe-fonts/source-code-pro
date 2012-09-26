#!/bin/sh

family=SourceCodePro
weights=('Black' 'Bold' 'ExtraLight' 'Light' 'Regular' 'Semibold')

# clean existing build artifacts
rm -rf target/
mkdir target/

for w in ${weights[@]};
do
  makeotf -sp target/$family-$w-otf.fpr -f Roman/$w/font.pfa -r -o target/$family-$w.otf
  makeotf -sp target/$family-$w-ttf.fpr -f Roman/$w/font.ttf -gf GlyphOrderAndAliasDB_TT -r -o target/$family-$w.ttf
  rm Roman/$w/current.fpr # remove default options file from the source tree after building
done
