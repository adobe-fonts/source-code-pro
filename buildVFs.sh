#!/usr/bin/env sh

ro_name=SourceCodeVariable-Roman
it_name=SourceCodeVariable-Italic

# get absolute path to bash script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# clean existing build artifacts
var_dir="$DIR"/target/VAR
rm -rf "$var_dir"
mkdir -p "$var_dir"

# path to Python script that adds the SVG table
addSVG="$DIR"/addSVGtable.py

# path to UVS file
UVS="$DIR"/uvs.txt


function build_var_font {
	# $1 is Master directory
	# $2 is font name
	echo $2

	otf_file="$1"/$2.otf
	ttf_file="$1"/$2.ttf
	dsp_file="$1"/$2.designspace

	# build variable OTF
	buildmasterotfs --mkot -ci,"$UVS" -d "$dsp_file"
	buildcff2vf --omit-mac-names --keep-glyph-names -d "$dsp_file"

	# extract and subroutinize the CFF2 table
	echo 'Subroutinizing' $2.otf
	tx -cff2 +S +b -std "$otf_file" "$1"/.tb_cff2 2> /dev/null

	# replace CFF2 table with subroutinized version
	sfntedit -a CFF2="$1"/.tb_cff2 "$otf_file"

	# add SVG table to variable OTF
	echo 'Adding SVG table to' $2.otf
	"$addSVG" "$otf_file" "$DIR"/svg

	# build variable TTF
	fontmake -m "$dsp_file" -o variable --production-names --output-path "$ttf_file" --feature-writer None

	# use cmap, DSIG, name, OS/2, hhea, post, SVG, and STAT tables from OTFs
	sfntedit -x cmap="$1"/.tb_cmap,DSIG="$1"/.tb_DSIG,name="$1"/.tb_name,OS/2="$1"/.tb_os2,hhea="$1"/.tb_hhea,post="$1"/.tb_post,SVG="$1"/.tb_SVG,STAT="$1"/.tb_STAT "$otf_file"
	sfntedit -a cmap="$1"/.tb_cmap,DSIG="$1"/.tb_DSIG,name="$1"/.tb_name,OS/2="$1"/.tb_os2,hhea="$1"/.tb_hhea,post="$1"/.tb_post,SVG="$1"/.tb_SVG,STAT="$1"/.tb_STAT "$ttf_file"

	# use GDEF, GPOS, and GSUB tables from TTFs
	sfntedit -x GDEF="$1"/.tb_GDEF,GPOS="$1"/.tb_GPOS,GSUB="$1"/.tb_GSUB "$ttf_file"
	sfntedit -a GDEF="$1"/.tb_GDEF,GPOS="$1"/.tb_GPOS,GSUB="$1"/.tb_GSUB "$otf_file"

	# move font files to target directory
	mv "$otf_file" "$var_dir"
	mv "$ttf_file" "$var_dir"

	# delete build artifacts
	rm "$1"/.tb_*
	rm "$1"/master_*/*.*tf

	echo "Done with $2"
	echo ""
	echo ""
}

build_var_font "$DIR"/Roman/Masters $ro_name
build_var_font "$DIR"/Italic/Masters $it_name
