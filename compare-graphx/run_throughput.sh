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
hdfs="hdfs://sensorium-1.ics.uci.edu:9000"
output_folder="${hdfs}/result/graphx"
$hadoop_home/bin/hadoop fs -mkdir $output_folder

slaves=`wc -l ./spark/conf/slaves | cut -f 1 -d ' '`

#PageRank
#for p in "001x" "005x" "01x" "05x";do
#    for task in {2..3} ; do
for p in "001x";do
    for task in 1 ; do
        ./spark/sbin/stop-all.sh
        sleep 5s
        ./spark/sbin/start-all.sh
        for (( k = 1; k <= task; k++ )) ; do        
            sleep 10
            input="${hdfs}/data/adj/webmap${p}"
            output="${output_folder}/`basename $input`-job${k}-of-${task}"
            ./run.sh "PageRank" $input $output &
        done
        wait
    done
done

#BTC
#for input in "${hdfs}/data/adj/btc005x" "${hdfs}/data/adj/btc"
#for input in "${hdfs}/data/adj/btc005x" 
#do
#    for task in {2..3} ; do
#        ./spark/sbin/stop-all.sh
#        sleep 5s
#        ./spark/sbin/start-all.sh
# 
#        for (( k = 1; k <= task; k++ )) ; do        
#            sleep 10
#            output="${output_folder}/`basename $input`-job${k}-of-${task}"
#            ./run.sh "SSSP" $input $output &
#        done
#        wait
#    done
#done

## Clean up
\rm -rf ./spark/{work,logs}
