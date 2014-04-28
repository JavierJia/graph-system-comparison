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

source $HOME/common.sh

fmachines="./machinefile"
nmachines=`wc -l $fmachines | cut -d " " -f1`
#mpdboot -n $nmachines -f $fmachines 

hadoop_home="/home/jianfenj/software/hadoop"
toolkit_path="release/toolkits/graph_analytics"
test_alg=${1:-"all"}
input=${2:-"hdfs://ipubmed2.ics.uci.edu:9000/user/jianfeng/data/sample"}
#input="hdfs://ipubmed2.ics.uci.edu:9000/user/jianfeng/data/yingyi_webmap001x"
output_folder=${3:-"hdfs://ipubmed2.ics.uci.edu:9000/user/jianfeng/result/graph_lab/`basename $input`"}
ncores=$(($nmachines * 4))

declare -A extra=(\
    ["pagerank"]="--iteration 5 --saveprefix ${output_folder}_pagerank"\
    ["sssp"]="--source 1824 --saveprefix ${output_folder}_sssp"\
    ["connected_component"]="--saveprefix ${output_folder}_cc"\
    ["simple_undirected_triangle_count"]="--per_vertex ${output_folder}_tc"\
)

function run_cmd {
    alg=$1
    filetag=`basename $input`
    logfile="graphlab.${filetag}.${alg}.node${nmachines}.log"
    cmd="$toolkit_path/$alg --graph $input --format adj ${extra[$alg]} --ncpus $ncores 2>&1 | tee $logfile"
    echo $cmd
    success=true
    stt=$(date +"%s")
    eval "time mpiexec -machinefile $fmachines -n $nmachines env CLASSPATH=`$hadoop_home/bin/hadoop classpath` $cmd"
    [ $? == 0 ] || { success=false; }
    end=$(date +"%s")
    diff=$(($end-$stt))
    echo $'\n'"$cmd:$diff secs" >> $logfile
    if [ $success = true ];then
        exit_and_email_message 0 "GraphLab success" "$cmd" "time: $diff secs"
    else
        echo "EXIT WITH ERROR!" >> $logfile; 
        exit_and_email_message -1 "GraphLab failed" "$cmd"
    fi
}

if [ $test_alg == "all" ]; then 
    for alg in "pagerank" "sssp" "connected_component" "simple_undirected_triangle_count";
    do
        run_cmd $alg   
    done
else
    run_cmd $test_alg
fi

