#!/bin/bash - 
#===============================================================================
#
#          FILE: run_graph_lab.sh
# 
#         USAGE: ./run_graph_lab.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Jianfeng Jia (), jianfeng.jia@gmail.com
#  ORGANIZATION: ics.uci.edu
#       CREATED: 04/16/2014 05:44:31 PM PDT
#      REVISION:  ---
#===============================================================================

set -o nounset

input="hdfs://ipubmed2.ics.uci.edu:9000/user/jianfeng/data/sample"
output_folder="hdfs://ipubmed2.ics.uci.edu:9000/user/jianfeng/result/graph_lab"
ncores=8

declare -A extra=(\
    ["pagerank"]="--iteration 4 --saveprefix ${output_folder}_pagerank"\
    ["sssp"]="--source 1000 --saveprefix ${output_folder}_sssp"\
    ["connected_component"]="--saveprefix ${output_folder}_cc"\
    ["simple_undirected_triangle_count"]="--per_vertex ${output_folder}_tc"\
)

for alg in "pagerank" "sssp" "connected_component" "simple_undirected_triangle_count";
do
    cmd="./$alg --graph $input --format adj ${extra[$alg]} --ncpus $ncores 2>&1 | tee ${alg}.log"
    echo $cmd
    stt=$(date +"%s")
    eval "time mpiexec -n 1 env CLASSPATH=`hadoop classpath` $cmd"
    end=$(date +"%s")
    diff=$(($end-$stt))
    echo "$cmd:$diff secs" >> ${alg}.log
done
