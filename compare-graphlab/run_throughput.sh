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
output_folder="${hdfs}/result/graph_lab"
$hadoop_home/bin/hadoop fs -mkdir $output_folder

fmachines="./machinefile"
nmachines=`wc -l $fmachines | cut -d ' ' -f1`
sleep 10s
#PageRank
#for p in "001x" "005x" "01x" "05x";do
#for p in "005x" "01x" "05x";do
for p in "005x" "01x" ;do
#    for task in {2..3} ; do
    for task in {2..3} ; do
        mpdallexit
        mpdboot -n $nmachines -f machinefile -v
        for (( k = 1; k <= task; k++ )) ; do        
            sleep 10
            input="${hdfs}/data/adj/webmap${p}-split${nmachines}"
            output="${output_folder}/`basename $input`-job${k}-of-${task}"
            ./run_graph_lab.sh "pagerank" $input $output &
        done
        wait
    done
done

#BTC
#for input in "${hdfs}/data/adj/btc005x-split${nmachines}" "${hdfs}/data/adj/btc-split${nmachines}";do
for input in "${hdfs}/data/adj/btc005x-split${nmachines}" ;do
    for task in {2..3} ; do
         mpdallexit
        mpdboot -n $nmachines -f machinefile -v
        
        for (( k = 1; k <= task; k++ )) ; do        
            sleep 10
            output="${output_folder}/`basename $input`-job${k}-of-${task}"
            ./run_graph_lab.sh "sssp" $input $output &
        done
        wait
    done
done

# some make up script
#input=${hdfs}/data/adj/webmap05x-split32
#output="${output_folder}/`basename $input`"
#./run_graph_lab.sh "pagerank" $input  $output
#
#input=${hdfs}/data/adj/btc001x
#output="${output_folder}/`basename $input`"
#./run_graph_lab.sh "connected_component" $input  $output
#sleep 5s
#./run_graph_lab.sh "simple_undirected_triangle_count" $input  $output
#sleep 5s
#./run_graph_lab.sh "undirected_triangle_count" $input  $output


