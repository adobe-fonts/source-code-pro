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
buildMasterOTFs --mkot -ci,"$UVS" $rom/$ro_name.designspace
buildCFF2VF $rom/$ro_name.designspace
buildMasterOTFs --mkot -ci,"$UVS" $itm/$it_name.designspace
buildCFF2VF $itm/$it_name.designspace

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

# delete build artifacts
rm */Masters/.tb_*
rm */Masters/master_*/*.*tf

echo "Done"
