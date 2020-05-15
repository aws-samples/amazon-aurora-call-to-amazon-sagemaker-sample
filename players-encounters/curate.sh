#!/bin/bash

in_file=$1
file_suffix=`basename $1`
file_prefix=`basename $0 | cut -d'.' -f 1`
yyout_file="/tmp/"$file_prefix"_"$file_suffix
out_file="/percona/"$file_prefix"_"$file_suffix
echo "playerguid,playerx,playerz,quadrant,sector1,sector2,eventname" > $yyout_file
cat $in_file | awk -F\, '{print $1","$2","$3","$4","$5","$6","$14}' >> $yyout_file
sed -i 's/Quadrant //g' $yyout_file
sed -i 's/Sector //g' $yyout_file
sed -i 's/"//g' $yyout_file
`./curate.py $yyout_file > $out_file`

