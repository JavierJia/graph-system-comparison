export HADOOP_HOME=/usr/local/hadoop

START=$(date +%s)

bin/pregelix examples/pregelix-example-0.2.11-SNAPSHOT-jar-with-dependencies.jar edu.uci.ics.pregelix.example.PageRankVertex -inputpaths /$3 -outputpath /tmp/pg_result -ip `bin/getip.sh` -port 3099 -vnum 1413511393 -num-iteration 4 -cust-prop pregelix.groupalg=$1,pregelix.groupmem=$2,pregelix.sortmem=$2,pregelix.merge=$5 -dyn-opt $4 -plan $6

END=$(date +%s)
DIFF=$(( $END - $START ))
echo "Total Execution Time: ${DIFF} seconds"
