#!/bin/bash - 
#===============================================================================
#
#          FILE: driver.sh
# 
#         USAGE: ./driver.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Jianfeng Jia (), jianfeng.jia@gmail.com
#  ORGANIZATION: ics.uci.edu
#       CREATED: 04/11/2014 05:26:04 PM PDT
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

function usage {
    echo "usage `basename $0` [opts] <input> <output>"
    echo "  -s choose system: [P]regelix [H]ama [G]iraph Graph[X] Graph[L]ab "
    echo "  -t test_algorithm: [P]agerank [C]omponent [T]iragleCount [S]SSP"
    echo "  -a extra params"
    echo "  -p parallel_num: 4 ? 8 ? 16 ?"
    echo "  -h print this help"
    exit -1
}

[ $# -lt 1 ] && usage

platform="unknown"
algorithm="unknown"
parallel=4
extra=""

while getopts s:t:p:a:h OPT; do
    case $OPT in
        h)
            usage;;
        a)
            extra=$OPTARG;;
        s)
            [[ "$OPTARG" == "P" ]] && platform="pregelix";
            [[ "$OPTARG" == "H" ]] && platform="hama";
            [[ "$OPTARG" == "G" ]] && platform="giraph";
            [[ "$OPTARG" == "X" ]] && platform="graphx";
            [[ "$OPTARG" == "L" ]] && platform="graphlab";
            [[ "$platform" == "unknown" ]] && { echo "unknown system"; usage ;}
            ;;
        t)
            [[ "$OPTARG" == "P" ]] && algorithm="PageRank"
            [[ "$OPTARG" == "C" ]] && algorithm="ConectedComponent"
            [[ "$OPTARG" == "T" ]] && algorithm="TriagleCounting"
            [[ "$OPTARG" == "S" ]] && algorithm="SSSP"
            [[ "$platform" == "unknown" ]] && { echo "unknown algorithm"; usage;}
            ;;
        p)
            parallel=$OPTARG;;
    esac
done

shift $(( OPTIND -1 ));

input=$1
output=$2

echo "`date +\"%D %T\"` Using $platform"
echo "`date +\"%D %T\"` Solve $algorithm problem"
echo "`date +\"%D %T\"` Extra parameters: $extra"
echo "`date +\"%D %T\"` In parallel: $parallel"
echo "`date +\"%D %T\"` Input :$input"
echo "`date +\"%D %T\"` Output :$output"

./sys/${platform}/bin/restart.sh
if [ "${platform}" == "hama" ] ; then
    ./sys/hama/bin/hama jar compare-${platform}-*.jar comparison.pregelix.${platform}.${algorithm} $extra $input $output $parallel
fi
