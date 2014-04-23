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

export HAMA_HOME=$PWD
jar=../../../../target/compare-hama-0.0.1-SNAPSHOT.jar
#input=/user/hadoop/data/webmap001x/part-all
input=/user/jianfeng/data/sample/sample.400k.20.txt
output_folder=/tmp/hama-result
parallel=8

declare -A extra
extra["PageRank"]="4"   # for pagerank iterations
extra["SSSP"]="33"      # for SSSP start node
extra["TriagleCounting"]=""
extra["ConnectedComponent"]=""

for cmd in "PageRank" "SSSP" "TriagleCounting" "ConnectedComponent"; do
    output="${output_folder}_${cmd}"
    exe="HADOOP_USER_NAME=hadoop bin/hama jar $jar comparison.pregelix.hama.$cmd $input $output $parallel ${extra[$cmd]}"
    echo $exe
    eval "$exe"
done

