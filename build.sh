#!/usr/bin/env sh

set -e

family=SourceCodePro
upright_weights=(Black Bold ExtraLight Light Medium Regular Semibold)
italic_weights=(BlackIt BoldIt ExtraLightIt LightIt MediumIt It SemiboldIt)

# get absolute path to bash script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# clean existing build artifacts
rm -rf $DIR/target/
otf_dir="$DIR/target/OTF"
ttf_dir="$DIR/target/TTF"
mkdir -p $otf_dir $ttf_dir


function build_font {
    # $1 is Upright or Italic
    # $2 is weight name
    font_dir=$DIR/$1/Instances/$2
    font_ufo=$font_dir/font.ufo
    ps_name=$family-$2
    echo $ps_name
    echo "Building OTF ..."
    # -r is for "release mode" (subroutinization + applied glyph order)
    # -gs is for filtering the output font to contain only glyphs in the GOADB
    makeotf -f $font_ufo -r -gs -omitMacNames
    echo "Building TTF ..."
    otf2ttf $font_dir/$ps_name.otf
    echo "Componentizing TTF ..."
    ttfcomponentizer $font_dir/$ps_name.ttf

    # move font files to target directory
    mv $font_dir/$ps_name.otf $otf_dir
    mv $font_dir/$ps_name.ttf $ttf_dir
    echo "Done with $ps_name"
    echo ""
    echo ""
}


for w in ${upright_weights[@]}
do
	build_font Upright $w
done


for w in ${italic_weights[@]}
do
	build_font Italic $w
done
