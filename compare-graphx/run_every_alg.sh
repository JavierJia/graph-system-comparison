#!/bin/bash - 
#===============================================================================
#
#          FILE: run_every_alg.sh
# 
#         USAGE: ./run_every_alg.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Jianfeng Jia (), jianfeng.jia@gmail.com
#  ORGANIZATION: ics.uci.edu
#       CREATED: 04/25/2014 10:14:42 AM PDT
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

hadoop_home="/home/jianfenj/software/hadoop"
hdfs="hdfs://sensorium-21.ics.uci.edu:9000"
output_folder="${hdfs}/result/graphx"
$hadoop_home/bin/hadoop fs -mkdir $output_folder

##PageRank
#for p in "001x" "005x";do
#    sleep 5
#    input="${hdfs}/data/adj/webmap${p}"
#    output="${output_folder}/`basename $input`"
#    ./run.sh "PageRank" $input $output
#done

#BTC
input="${hdfs}/data/adj/btc"
#for alg in "TC" "SSSP" "CC"; do
for alg in "SSSP" "CC"; do
    sleep 5
    output="${output_folder}/`basename $input`"
    ./run.sh $alg $input $output
done

