export HADOOP_HOME=~/hadoop/hadoop3

bin/pregelix examples/pregelix-example-0.2.11-SNAPSHOT-jar-with-dependencies.jar edu.uci.ics.pregelix.example.GraphSampleUndirectedVertex -inputpaths /webmap -outputpath /webmap001x -ip `bin/getip.sh` -port 3099 -cust-prop pregelix.globalrate=0.01

bin/pregelix examples/pregelix-example-0.2.11-SNAPSHOT-jar-with-dependencies.jar edu.uci.ics.pregelix.example.GraphSampleUndirectedVertex -inputpaths /webmap -outputpath /webmap005x -ip `bin/getip.sh` -port 3099 -cust-prop pregelix.globalrate=0.05

bin/pregelix examples/pregelix-example-0.2.11-SNAPSHOT-jar-with-dependencies.jar edu.uci.ics.pregelix.example.GraphSampleUndirectedVertex -inputpaths /webmap -outputpath /webmap01x -ip `bin/getip.sh` -port 3099 -cust-prop pregelix.globalrate=0.1

bin/pregelix examples/pregelix-example-0.2.11-SNAPSHOT-jar-with-dependencies.jar edu.uci.ics.pregelix.example.GraphSampleUndirectedVertex -inputpaths /webmap -outputpath /webmap05x -ip `bin/getip.sh` -port 3099 -cust-prop pregelix.globalrate=0.5
