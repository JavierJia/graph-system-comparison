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

set -o nounset                              # Treat unset variables as an error

sbt_path="src/main/resources"
$sbt_path/sbt package
[ $? == 0 ] || exit 0

for cmd in "PageRank" "CC" "TC" "SSSP";do
$sbt_path/sbt "run spark://ipubmed2:7077 \
    jar target/scala-2.10/compare-graphx_2.10-0.1-SNAPSHOT.jar\
    cmd $cmd hdfs://ipubmed2:9000/user/jianfeng/data/webmap/sample.4* hdfs://ipubmed2:9000/user/jianfeng/result_graphx_$cmd"
done
