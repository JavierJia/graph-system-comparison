source=1120
prefix=sssp
for j in 32
do
	bin/stopCluster.sh
	cp conf/slaves$j conf/slaves
	#rm -rf numbers-$j
	mkdir $prefix/numbers-$j
      	
	for dataset in btc01x btc05x btc
	do  
  		#rm -rf numbers-$j/$dataset
  		mkdir $prefix/numbers-$j/$dataset

  		for i in 500 #1000 #2000 3000 4000 #5000 6000 7000 8000
  		do
        		#./restart.sh
                        for mpl in 3
                        do
                                dynopt=true
                                if [ $mpl -gt 2 ]; then
					dynopt=false
                                fi
				./restart.sh
                        	for (( k=1; k<=mpl; k++ ))
                        	do
                        		echo "./runssp2.sh true $i $dataset false false $source OUTER_JOIN /tmp/sp_result${k}  &> $prefix/numbers-$j/${dataset}/sp-sort$i-tp-mpl-${mpl}-${k}.log"
                        		./runssp2.sh true $i $dataset $dynopt false $source OUTER_JOIN /tmp/sp_result${k} &> $prefix/numbers-$j/${dataset}/sp-sort$i-tp-mpl-${mpl}-${k}.log &
					sleep 15
				done
				wait
			done
		done
	done
done
