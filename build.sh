#!/usr/bin/env sh

set -e

family=SourceCodePro
roman_weights=(Black Bold ExtraLight Light Medium Regular Semibold)
italic_weights=(BlackIt BoldIt ExtraLightIt LightIt MediumIt It SemiboldIt)

# get absolute path to bash script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# clean existing build artifacts
rm -rf "$DIR/target/"
otf_dir="$DIR/target/OTF"
ttf_dir="$DIR/target/TTF"
mkdir -p "$otf_dir" "$ttf_dir"

# path to Python script that adds the SVG table
addSVG="$DIR"/addSVGtable.py

# path to UVS file
UVS="$DIR"/uvs.txt


function build_font {
    # $1 is Roman or Italic
    # $2 is weight name
    font_dir="$DIR"/$1/Instances/$2
    font_ufo="$font_dir"/font.ufo
    font_ttf="$font_dir"/font.ttf
    ps_name=$family-$2
    echo $ps_name
    echo "Building OTF ..."
    # -r is for "release mode" (subroutinization + applied glyph order)
    makeotf -f "$font_ufo" -r -ci "$UVS"
    echo "Building TTF ..."
    makeotf -f "$font_ttf" -r -ci "$UVS" -ff "$font_ufo"/features.fea
    echo "Adding SVG table ..."
    "$addSVG" "$font_dir"/$ps_name.otf "$DIR"/svg

    # copy SVG and DSIG tables from OTF to TTF
    sfntedit -x DSIG="$font_dir"/.tb_DSIG,SVG="$font_dir"/.tb_SVG "$font_dir"/$ps_name.otf
    sfntedit -a DSIG="$font_dir"/.tb_DSIG,SVG="$font_dir"/.tb_SVG "$font_dir"/$ps_name.ttf

    # delete build artifacts
    rm "$font_dir"/.tb_*

    # move font files to target directory
    mv "$font_dir"/$ps_name.otf "$otf_dir"
    mv "$font_dir"/$ps_name.ttf "$ttf_dir"
    echo "Done with $ps_name"
    echo ""
    echo ""
}


for w in ${roman_weights[@]}
do
  build_font Roman $w
done


for w in ${italic_weights[@]}
do
  build_font Italic $w
done
