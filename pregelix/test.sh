export HADOOP_HOME=~/hadoop/hadoop4
dataset=webmap
i=1000

cp conf/slaves24 conf/slaves
./restart.sh
./run.sh true $i $dataset true false &> numbers/${dataset}/pagerank-sort$i-dyn.log
