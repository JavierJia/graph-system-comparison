export HADOOP_HOME=/usr/local/hadoop

START=$(date +%s)

#input=/user/hadoop/data/webmap001x/part-all
input=/user/jianfeng/data/webmap/sample.txt

bin/pregelix examples/pregelix-example-0.2.11-SNAPSHOT-jar-with-dependencies.jar edu.uci.ics.pregelix.example.PageRankVertex \
    -inputpaths $input -outputpath /tmp/pg_result \
    -ip `bin/getip.sh` -port 3099 -vnum 1413511393 -num-iteration 4 \
    -cust-prop pregelix.groupalg=true,pregelix.groupmem=1000,pregelix.sortmem=1000,pregelix.merge=true -dyn-opt false -plan OUTER_JOIN

END=$(date +%s)
DIFF=$(( $END - $START ))
echo "Total Execution Time: ${DIFF} seconds"
