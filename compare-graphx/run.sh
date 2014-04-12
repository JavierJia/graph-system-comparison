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
$sbt_path/sbt "run spark://ipubmed2.ics.uci.edu:7077 cmd PageRank hdfs://ipubmed2.ics.uci.edu:9000/user/jianfeng/data/webmap/sample.4* hdfs://ipubmed2.ics.uci.edu:9000/user/jianfeng/result_graphx_pr"
