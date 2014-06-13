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
#       CREATED: 05/27/2014 04:04:25 PM PDT
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

for file in $@; do
    startIteration=`grep "reduce at" $file | grep "Job finished" | cut -d " " -f 1,2 | cut -d "/" -f 2,3 | head -n1`
    endIteration=`grep "reduce at" $file | grep "Job finished" | cut -d " " -f 1,2 | cut -d "/" -f 2,3 | tail -n1`

    iterations=`grep "reduce at" $file | grep "Job finished" | cut -d " " -f 1,2 | cut -d "/" -f 2,3 | wc -l`
    iterations=$(($iterations -1 ))

    iterationtime=$((`date -d "$endIteration" +%s`-`date -d "$startIteration" +%s`))

    echo $file
    echo "Iterations: $iterations"
    echo "AVG(itertime): $(( $iterationtime/$iterations ))"
done



