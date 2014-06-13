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
source $HOME/common.sh

export HAMA_HOME=$PWD
jar=../../../../target/compare-hama-0.0.1-SNAPSHOT.jar
#input=/user/hadoop/data/webmap001x/part-all
test_alg=${1:-"all"}
input=${2:-"/user/jianfeng/data/sample/sample.400k.20.txt"}
output_folder=${3:-"/tmp/hama-result"}
nnode=`wc -l ./conf/groomservers | cut -d " " -f1`
#parallel=$(( $nnode * 4))
parallel=$(( $nnode * 1))

declare -A extra
extra["PageRank"]="5"   # for pagerank iterations
extra["SSSP"]="1824"      # for SSSP start node
extra["TriagleCounting"]=""
extra["ConnectedComponent"]=""

if [ $test_alg == "all" ]; then
    for cmd in "PageRank" "SSSP" "TriagleCounting" "ConnectedComponent"; do
        output="${output_folder}_${cmd}"
        exe="bin/hama jar $jar comparison.pregelix.hama.$cmd $input $output $parallel ${extra[$cmd]}"
        echo $exe
        eval "$exe"
    done
else
    cmd=$test_alg
    output="${output_folder}_${cmd}"
    filetag=`basename $output`
    logfile="hama.${filetag}.${cmd}.node${nnode}-task${parallel}.log"
 
    stt=$(date +"%s")
    exe="bin/hama jar $jar comparison.pregelix.hama.$cmd $input $output $parallel ${extra[$cmd]} 2>&1 | tee $logfile"
    echo $exe
    eval "$exe"
    exitno=$?
    end=$(date +"%s")
    diff=$(($end-$stt))
    exit_and_email_message $exitno "hama_${cmd}" "$exe" " time costs:$diff"
fi

