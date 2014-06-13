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
#       CREATED: 05/16/2014 10:37:19 AM PDT
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

for file in $@ ; do
    startIterate=`grep "Running job" $file | tail -n1 | cut -d " " -f 2`
    endIterate=`grep "The total number " $file | tail -n1 | cut -d " " -f 2 `
    iterationtime=$((`date -d $endIterate +%s`-`date -d $startIterate +%s`))

    startLoad=`grep "Running job" $file | head -n1 | cut -d " " -f 2`
    endLoad=`grep "The total number " $file | head -n1 | cut -d " " -f 2 `
    loadingtime=$((`date -d $endLoad +%s`-`date -d $startLoad +%s`))

    iterations=`grep ITERATIONS $file | cut -d "=" -f 2`

    echo "$file"
    tail -n 1 $file
    echo "loading time:$loadingtime secs"
    echo "total iterations:$iterations"
    echo "iteration time:$iterationtime secs"
    echo "avg iterations: $(($iterationtime/$iterations)) secs"
done

