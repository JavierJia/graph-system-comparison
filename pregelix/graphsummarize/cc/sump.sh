echo "#  Overall Execution Time"
echo "#  001x 005x 01x 05x 1x"
for scale in 8 16 24 32
do
   line=${scale}
   for size in 001 005 01 05
   do
     exectime=`cat pregelix/numbers-${scale}/btc${size}x/*-$1*|grep 'Total Execution Time'|awk '{print $4}'`
     line="${line} ${exectime}"
   done
   exectime=`cat pregelix/numbers-${scale}/btc/*-$1*|grep 'Total Execution Time'|awk '{print $4}'`
   #exectime=$((exectime*1000))
   line="${line} ${exectime}"
   echo $line
done

echo "#  Average Iteration Time"
for scale in 8 16 24 32
do
   line=${scale}
   for size in 001 005 01 05
   do
     totaltime=0
     iterations=0
     avgtime=0
     cat pregelix/numbers-${scale}/btc${size}x/*-$1*|grep 'iteration' >tmp.txt
     while read iterationline
     do
	if [ $iterations -gt 1 ]; then
		iterationtime=`echo ${iterationline}|awk '{print $6}'|egrep -o '[0-9]*'`
        	totaltime=$((totaltime+iterationtime))
        fi
	iterations=$((iterations+1))
     done<tmp.txt
     
     iterations=$((iterations-1))
     avgtime=$((totaltime/iterations))
     line="${line} ${avgtime}"
   done

   totaltime=0
   iterations=0
   avgtime=0
   cat pregelix/numbers-${scale}/btc/*-$1*|grep 'iteration' >tmp.txt
   while read iterationline
   do
        if [ $iterations -gt 1 ]; then
        	iterationtime=`echo ${iterationline}|awk '{print $6}'|egrep -o '[0-9]*'`
        	totaltime=$((totaltime+iterationtime))
        fi
	iterations=$((iterations+1))
   done<tmp.txt
   #echo $iterations
   iterations=$((iterations-1))
   avgtime=$((totaltime/iterations))
   line="${line} ${avgtime}"
   
   echo $line
done

