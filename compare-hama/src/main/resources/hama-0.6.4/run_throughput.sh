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
output_folder="${hdfs}/result/hama"
#$hadoop_home/bin/hadoop fs -mkdir $output_folder

#PageRank
#for p in "001x" "005x" "01x" "05x";do
for p in "001x" "005x";do
    for task in {2..3} ; do
        bin/stop-bspd.sh && bin/start-bspd.sh
        [ $? == 0 ] || { echo "hama start failed"; exit -1; }
        sleep 10s
        for (( k = 1; k <= task; k++ )) ; do
            input="${hdfs}/data/adj/webmap${p}"
            output="${output_folder}/`basename $input`-job${k}-of-${task}"
            ./run-hama.sh "PageRank" $input $output &
        done
        wait
    done
done

##BTC
for input in "${hdfs}/data/adj/btc005x" "${hdfs}/data/adj/btc" ;do
    for task in {2..3} ; do
        bin/stop-bspd.sh && bin/start-bspd.sh
        [ $? == 0 ] || { echo "hama start failed"; exit -1; }
        sleep 10s
        for (( k = 1; k <= task; k++ )) ; do
            sleep 10
            output="${output_folder}/`basename $input`-job${k}-of-${task}"
            ./run-hama.sh "SSSP" $input $output &
        done
        wait
    done
done

bin/stop-bspd.sh
