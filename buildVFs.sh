#!/usr/bin/env sh

ro_name=SourceCodeVF-Roman
it_name=SourceCodeVF-Italic

# get absolute path to bash script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# clean existing build artifacts
var_dir=$DIR/target/VAR
rm -rf $var_dir
mkdir -p $var_dir


function build_var_font {
	# $1 is Master directory
	# $2 is font name
	echo $2
	# build variable OTF
	# --mkot gs is for using the makeotf option -gs, which omits glyphs not in the GOADB
	buildmasterotfs --mkot gs -d $1/$2.designspace
	buildcff2vf -d $1/$2.designspace

	# extract and subroutinize the CFF2 table
	echo 'Subroutinizing' $2.otf
	tx -cff2 +S +b -std $1/$2.otf $1/.tb_cff2 2> /dev/null

	# replace CFF2 table with subroutinized version
	sfntedit -a CFF2=$1/.tb_cff2 $1/$2.otf

	# comment out STAT feature file which cannot be digested by fontmake
	sed -i '' 's/^/#/' $1/STAT.fea

	# build variable TTF
	fontmake -m $1/$2.designspace -o variable --production-names --output-path $1/$2.ttf

	# use DSIG, name, OS/2, hhea, post, and STAT tables from OTFs
	sfntedit -x DSIG=$1/.tb_DSIG,name=$1/.tb_name,OS/2=$1/.tb_os2,hhea=$1/.tb_hhea,post=$1/.tb_post,STAT=$1/.tb_STAT,fvar=$1/.tb_fvar $1/$2.otf
	sfntedit -a DSIG=$1/.tb_DSIG,name=$1/.tb_name,OS/2=$1/.tb_os2,hhea=$1/.tb_hhea,post=$1/.tb_post,STAT=$1/.tb_STAT,fvar=$1/.tb_fvar $1/$2.ttf

	# use cmap, GDEF, GPOS, and GSUB tables from TTFs
	sfntedit -x cmap=$1/.tb_cmap,GDEF=$1/.tb_GDEF,GPOS=$1/.tb_GPOS,GSUB=$1/.tb_GSUB $1/$2.ttf
	sfntedit -a cmap=$1/.tb_cmap,GDEF=$1/.tb_GDEF,GPOS=$1/.tb_GPOS,GSUB=$1/.tb_GSUB $1/$2.otf

    # move font files to target directory
    mv $1/$2.otf $var_dir
    mv $1/$2.ttf $var_dir

	# delete build artifacts
	rm $1/.tb_*
	rm $1/master_*/*.*tf

	# undo changes to STAT feature file
	sed -i '' 's/#//' $1/STAT.fea

    echo "Done with $2"
    echo ""
    echo ""
}

build_var_font $DIR/Roman/Masters $ro_name
build_var_font $DIR/Italic/Masters $it_name
