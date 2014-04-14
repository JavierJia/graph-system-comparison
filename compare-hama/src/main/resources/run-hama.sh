#!/bin/bash - 
#===============================================================================
#
#          FILE: run-hama.sh
# 
#         USAGE: ./run-hama.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Jianfeng Jia (), jianfeng.jia@gmail.com
#  ORGANIZATION: ics.uci.edu
#       CREATED: 04/14/2014 04:28:22 PM PDT
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

jar=compare-hama-0.0.1-SNAPSHOT.jar
input=/user/hadoop/data/webmap001x/part-all
output=hama/webmap001x
parallel=8

extra="4"       # for pagerank notify how many iterations
#extra="1000"    # for SSSP notify the source point

for cmd in "PageRank" "SSSP" "TriagleCounting" "ConectedComponent"; do
    exe="bin/hama jar comparison.pregelix.hama.$cmd $input $output $parallel $extra"
    echo $exe
    eval "$exe"
done
