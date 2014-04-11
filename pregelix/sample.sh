export HADOOP_HOME="/usr/local/hadoop"

hdfs_src="data/webmap/ydata*"
hdfs_des_prefix="data/webmap"

for rate in 01 05 1 5;do
bin/pregelix examples/pregelix-example-0.2.11-SNAPSHOT-jar-with-dependencies.jar edu.uci.ics.pregelix.example.GraphSampleUndirectedVertex \
        -inputpaths $hdfs_src \
        -outputpath "${hdfs_des_prefix}/0${rate}" \
        -ip `bin/getip.sh` -port 3099 \
        -cust-prop pregelix.globalrate=0.${rate}
done

