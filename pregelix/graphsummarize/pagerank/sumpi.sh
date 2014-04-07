echo "#  Overall Execution Time"
echo "#  001x 005x 01x 05x 1x"
for scale in 8
do
   line=${scale}
   for size in 001 005 01 05
   do
     exectime=`cat pregelix/numbers-${scale}/webmap${size}x/*-$1*|grep 'Total Execution Time'|awk '{print $4}'`
     line="${line} ${exectime}"
   done
   exectime=`cat pregelix/numbers-${scale}/webmap/*-$1*|grep 'Total Execution Time'|awk '{print $4}'`
   #exectime=$((exectime*1000))
   line="${line} ${exectime}"
   echo $line
done
echo " "
echo " "
echo " "

echo "#  Average Iteration Time"
for scale in 8
do
   line=${scale}
   for size in 001 005 01 05
   do
     totaltime=0
     iterations=0
     avgtime=0
     cat pregelix/numbers-${scale}/webmap${size}x/*-$1*|grep 'iteration' >tmp.txt
     while read iterationline
     do
	iterationtime=`echo ${iterationline}|awk '{print $6}'|egrep -o '[0-9]*'`
        totaltime=$((totaltime+iterationtime))
        iterations=$((iterations+1))
     done<tmp.txt
     
     avgtime=$((totaltime/iterations))
     line="${line} ${avgtime}"
   done

   totaltime=0
   iterations=0
   avgtime=0
   cat pregelix/numbers-${scale}/webmap/*-$1*|grep 'iteration' >tmp.txt
   while read iterationline
   do
        iterationtime=`echo ${iterationline}|awk '{print $6}'|egrep -o '[0-9]*'`
        totaltime=$((totaltime+iterationtime))
        iterations=$((iterations+1))
   done<tmp.txt
   #echo $iterations
   avgtime=$((totaltime/iterations))
   line="${line} ${avgtime}"
   
   echo $line
done
echo " "
echo " "
echo " "
