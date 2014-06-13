#!/bin/bash - 
#===============================================================================
#
#          FILE: run.sh
# 
#         USAGE: ./run.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Jianfeng Jia (), jianfeng.jia@gmail.com
#  ORGANIZATION: ics.uci.edu
#       CREATED: 04/12/2014 15:06:56 PDT
#      REVISION:  ---
#===============================================================================

source $HOME/common.sh
set -o nounset                              # Treat unset variables as an error

# only for remote is ipubmed2
#export HADOOP_USER_NAME=jianfeng

sbt_path="src/main/resources"
$sbt_path/sbt package
[ $? == 0 ] || exit 0

sparkserver="spark://sensorium-1:7077"
jar="target/scala-2.10/compare-graphx_2.10-0.1-SNAPSHOT.jar"
test_alg=${1:-"all"}
input=${2:-"hdfs://ipubmed2:9000/user/jianfeng/data/sample"}
output_folder=${3:-"hdfs://ipubmed2:9000/tmp/graphX"}

extra_sssp=1824
extra_pagerank=5

export slaves=`wc -l ./spark/conf/slaves | cut -f 1 -d ' ' `
core=$(( $slaves * 4 ))  
#mem="3400m"    # for one worker!
mem="6800m"    # for one worker!

function run_cmd {

    cmd=$1
    extra=""
    filetag=`basename $output_folder`
    node=$(($core / 4))
    logfile="graphX.${filetag}.${cmd}.node${node}.log"
    [ $cmd == "PageRank" ] && extra=$extra_pagerank
    [ $cmd == "SSSP" ] && extra=$extra_sssp

    fullcmd="$sbt_path/sbt 'run $sparkserver \
    jar $jar -c $core -m $mem\
    cmd $cmd $input ${output_folder}_${cmd} $extra' "
    eval $fullcmd 2>&1 | tee $logfile

    if [ $? != 0 ]; then 
        exit_and_email_message -1 "GraphX run failed" "$fullcmd" "$logfile"
        exit -1
    else
        exit_and_email_message 0 "GraphX run successfully" "$fullcmd" "$logfile"
    fi
}

if [ $test_alg == "all" ]; then
    for alg in "PageRank" "TC" "SSSP" "CC";do
        run_cmd $alg
    done
else
    run_cmd $test_alg
fi

