#sources=(2691344 958337 1612164 9239908 9239908)
#sources=(2691344 958337 1612164 958337 958337)
#source=1120
prefix=cc
for j in 8
do
	bin/stopCluster.sh
	cp conf/slaves$j conf/slaves
	#rm -rf numbers-$j
	mkdir $prefix/numbers-$j
        d=0
	for dataset in btc05x btc #btc001x btc005x btc01x btc05x btc
	do  
  		#rm -rf numbers-$j/$dataset
  		mkdir $prefix/numbers-$j/$dataset

  		for i in 1000 #2000 3000 4000 #5000 6000 7000 8000
  		do
        		./restart.sh
                        echo "./runcc.sh true $i $dataset true false OUTER_JOIN &> $prefix/numbers-$j/${dataset}/cc-sort$i-outer-dyn.log"
        		./runcc.sh true $i $dataset true false OUTER_JOIN &> $prefix/numbers-$j/${dataset}/cc-sort$i-outer-dyn.log

                        ./restart.sh
                        echo "./runcc.sh true $i $dataset true false INNER_JOIN  &> $prefix/numbers-$j/${dataset}/cc-sort$i-inner-dyn.log"
                        ./runcc.sh true $i $dataset true false INNER_JOIN &> $prefix/numbers-$j/${dataset}/cc-sort$i-inner-dyn.log
  		done
                d=$((d+1))
	done
done
