#!/usr/bin/env sh

# path to Python script that adds the SVG table
addSVG=$(cd $(dirname "$0") && pwd -P)/addSVGtable.py

rom=Roman/Masters
itm=Italic/Masters

ro_name=SourceCodeVariable-Roman
it_name=SourceCodeVariable-Italic

# build variable OTFs
buildMasterOTFs $rom/$ro_name.designspace
buildCFF2VF $rom/$ro_name.designspace
buildMasterOTFs $itm/$it_name.designspace
buildCFF2VF $itm/$it_name.designspace

# extract and subroutinize the CFF2 table
tx -cff2 +S +b -std $rom/$ro_name.otf $rom/.tb_cff2
tx -cff2 +S +b -std $itm/$it_name.otf $itm/.tb_cff2

# replace CFF2 table with subroutinized version
sfntedit -a CFF2=$rom/.tb_cff2 $rom/$ro_name.otf
sfntedit -a CFF2=$itm/.tb_cff2 $itm/$it_name.otf

# add SVG table to variable OTFs
"$addSVG" $rom/$ro_name.otf svg
"$addSVG" $itm/$it_name.otf svg

# delete build artifacts
rm */Masters/.tb_*
rm */Masters/master_*/*.*tf
