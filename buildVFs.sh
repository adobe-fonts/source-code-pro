#!/usr/bin/env sh

# path to Python script that adds the SVG table
addSVG=$(cd $(dirname "$0") && pwd -P)/addSVGtable.py

# path to UVS file
UVS=$(cd $(dirname "$0") && pwd -P)/uvs.txt

rom=Roman/Masters
itm=Italic/Masters

ro_name=SourceCodeVariable-Roman
it_name=SourceCodeVariable-Italic

# build variable OTFs
buildmasterotfs --mkot -ci,"$UVS" $rom/$ro_name.designspace
buildcff2vf $rom/$ro_name.designspace
buildmasterotfs --mkot -ci,"$UVS" $itm/$it_name.designspace
buildcff2vf $itm/$it_name.designspace

# extract and subroutinize the CFF2 table
echo 'Subroutinizing' $rom/$ro_name.otf
tx -cff2 +S +b -std $rom/$ro_name.otf $rom/.tb_cff2 2> /dev/null
echo 'Subroutinizing' $itm/$it_name.otf
tx -cff2 +S +b -std $itm/$it_name.otf $itm/.tb_cff2 2> /dev/null

# replace CFF2 table with subroutinized version
sfntedit -a CFF2=$rom/.tb_cff2 $rom/$ro_name.otf 1> /dev/null
sfntedit -a CFF2=$itm/.tb_cff2 $itm/$it_name.otf 1> /dev/null

# add SVG table to variable OTFs
"$addSVG" $rom/$ro_name.otf svg
"$addSVG" $itm/$it_name.otf svg

# build variable TTFs
fontmake -m $rom/$ro_name.designspace -o variable --production-names
fontmake -m $itm/$it_name.designspace -o variable --production-names

# use cmap, DSIG, name, OS/2, hhea, post, SVG, and STAT tables from OTFs
sfntedit -x cmap=$rom/.tb_cmap,DSIG=$rom/.tb_DSIG,name=$rom/.tb_name,OS/2=$rom/.tb_os2,hhea=$rom/.tb_hhea,post=$rom/.tb_post,SVG=$rom/.tb_SVG,STAT=$rom/.tb_STAT $rom/$ro_name.otf 1> /dev/null
sfntedit -a cmap=$rom/.tb_cmap,DSIG=$rom/.tb_DSIG,name=$rom/.tb_name,OS/2=$rom/.tb_os2,hhea=$rom/.tb_hhea,post=$rom/.tb_post,SVG=$rom/.tb_SVG,STAT=$rom/.tb_STAT $rom/$ro_name.ttf 1> /dev/null
sfntedit -x cmap=$itm/.tb_cmap,DSIG=$itm/.tb_DSIG,name=$itm/.tb_name,OS/2=$itm/.tb_os2,hhea=$itm/.tb_hhea,post=$itm/.tb_post,SVG=$itm/.tb_SVG,STAT=$itm/.tb_STAT $itm/$it_name.otf 1> /dev/null
sfntedit -a cmap=$itm/.tb_cmap,DSIG=$itm/.tb_DSIG,name=$itm/.tb_name,OS/2=$itm/.tb_os2,hhea=$itm/.tb_hhea,post=$itm/.tb_post,SVG=$itm/.tb_SVG,STAT=$itm/.tb_STAT $itm/$it_name.ttf 1> /dev/null

# use GDEF, GPOS, and GSUB tables from TTFs
sfntedit -x GDEF=$rom/.tb_GDEF,GPOS=$rom/.tb_GPOS,GSUB=$rom/.tb_GSUB $rom/$ro_name.ttf 1> /dev/null
sfntedit -a GDEF=$rom/.tb_GDEF,GPOS=$rom/.tb_GPOS,GSUB=$rom/.tb_GSUB $rom/$ro_name.otf 1> /dev/null
sfntedit -x GDEF=$itm/.tb_GDEF,GPOS=$itm/.tb_GPOS,GSUB=$itm/.tb_GSUB $itm/$it_name.ttf 1> /dev/null
sfntedit -a GDEF=$itm/.tb_GDEF,GPOS=$itm/.tb_GPOS,GSUB=$itm/.tb_GSUB $itm/$it_name.otf 1> /dev/null

# delete build artifacts
rm */Masters/.tb_*
rm */Masters/master_*/*.*tf

echo "Done"
