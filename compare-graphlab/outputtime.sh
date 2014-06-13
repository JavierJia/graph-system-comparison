#!/bin/bash - 
#===============================================================================
#
#          FILE: outputtime.sh
# 
#         USAGE: ./outputtime.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Jianfeng Jia (), jianfeng.jia@gmail.com
#  ORGANIZATION: ics.uci.edu
#       CREATED: 05/20/2014 03:27:05 PM PDT
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

for file in $* ; do
    totaltime=`tail -n1 $file | gawk '{print $(NF-1)}'`
    iterations=`grep "iterations completed" $file | gawk '{print $(NF-2)}'`
    avgtime=`grep "Finished Running engine" $file | gawk -v nn=$iterations '{print $(NF-1)*1.0/nn}'`
    echo "$totaltime for $iterations iterations"
    echo "avgiter: $avgtime"
done

