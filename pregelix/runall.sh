prefix=pagerank
for j in 32 24 16 8
do
	bin/stopCluster.sh
	cp conf/slaves$j conf/slaves
	#rm -rf numbers-$j
	mkdir $prefix/numbers-$j
      	
	for dataset in webmap001x webmap005x webmap01x webmap05x webmap
	do  
  		#rm -rf numbers-$j/$dataset
  		mkdir $prefix/numbers-$j/$dataset

  		for i in 1000 #2000 3000 4000 #5000 6000 7000 8000
  		do
        		#./restart.sh
			#echo "./run.sh true $i $dataset true true INNER_JOIN &> $prefix/numbers-$j/${dataset}/pagerank-sort$i-inner-dyn.log"
        		#./run.sh true $i $dataset true true INNER_JOIN &> $prefix/numbers-$j/${dataset}/pagerank-sort$i-inner-dyn.log

                        ./restart.sh
                        echo "./run.sh true $i $dataset true false OUTER_JOIN &> $prefix/numbers-$j/${dataset}/pagerank-sort$i-unmerge-dyn.log"
                        ./run.sh true $i $dataset true false OUTER_JOIN &> $prefix/numbers-$j/${dataset}/pagerank-sort$i-unmerge-dyn.log
		done
	done
done
