prefix=pagerank
for j in 32
do
	bin/stopCluster.sh
	cp conf/slaves$j conf/slaves
	#rm -rf numbers-$j
	mkdir $prefix/numbers-$j
      	
	for dataset in webmap001x webmap05x webmap
	do  
  		#rm -rf numbers-$j/$dataset
  		mkdir $prefix/numbers-$j/$dataset

  		for i in 500 #1000 #2000 3000 4000 #5000 6000 7000 8000
  		do
        		#./restart.sh
			#echo "./run.sh true $i $dataset true true INNER_JOIN &> $prefix/numbers-$j/${dataset}/pagerank-sort$i-inner-dyn.log"
        		#./run.sh true $i $dataset true true INNER_JOIN &> $prefix/numbers-$j/${dataset}/pagerank-sort$i-inner-dyn.log

                        #./restart.sh
                        for mpl in 1 2 3
                        do
				./restart.sh
				dynopt=true
                                if [ $mpl -gt 1 ]; then
                                        dynopt=false
                                fi
                        	for (( k=1; k<=mpl; k++ ))
                        	do
                        		echo "./run2.sh true $i $dataset $dynopt true OUTER_JOIN /tmp/pg_resul${k}  &> $prefix/numbers-$j/${dataset}/pagerank-sort$i-tp-mpl-${mpl}-${k}.log"
                        		./run2.sh true $i $dataset $dynopt true OUTER_JOIN /tmp/pg_resul${k} &> $prefix/numbers-$j/${dataset}/pagerank-sort$i-tp-mpl-${mpl}-${k}.log &
				done
				wait
				sleep 10
			done
		done
	done
done
