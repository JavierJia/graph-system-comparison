echo "  Overall Execution Time"
echo "  001x 005x 01x 05x 1x"
for scale in 8 16 24 32
do
   line=${scale}
   scale=$((scale-1))
   for size in  001 005 01 05
   do
     targetfile=giraph/numbers-${scale}/webmap${size}x/*-${1}*
     if [ -f $targetfile ]
     then
        succ=`cat ${targetfile}|grep 'Superstep'`
        #echo $failure
	if [ "$succ" != "" ]
        then
		exectime=`cat ${targetfile}|grep 'Total Execution Time'|awk '{print $4}'`
     	else
		exectime='FAILED'
	fi
     else
        exectime='FAILED'
     fi
     line="${line} ${exectime}"
   done

   targetfile=giraph/numbers-${scale}/webmap/*-${1}*
   if [ -f $targetfile ]
   then
	succ=`cat ${targetfile}|grep 'Superstep'`
        #echo $failure
        if [ "$succ" != "" ]
        then
        	exectime=`cat ${targetfile}|grep 'Total Execution Time'|awk '{print $4}'`
   	else
		exectime='FAILED'
	fi
   else
        exectime='FAILED'
   fi

   line="${line} ${exectime}"
   echo $line
done

echo "  Average Iteration Time"
for scale in 8 16 24 32
do
   line=${scale}
   scale=$((scale-1))
   for size in 001 005 01 05
   do
     totaltime=0
     iterations=0
     avgtime=0
   
     targetfile=giraph/numbers-${scale}/webmap${size}x/*-${1}*

     if [ -f $targetfile ]
     then
        succ=`cat ${targetfile}|grep 'Superstep'`
        #echo $failure
        if [ "$succ" != "" ]
	then
     		cat ${targetfile}|grep 'Superstep'|grep 'ms' >tmp.txt
     		while read iterationline
     		do
			#echo  ${iterationline}|awk '{print $8}'|awk -F "=" '{print $2}'
			iterationtime=`echo ${iterationline}|awk '{print $8}'|awk -F "=" '{print $2}'`
        		totaltime=$((totaltime+iterationtime))
        		iterations=$((iterations+1))
     		done<tmp.txt
     		avgtime=$((totaltime/iterations))
     	else
		avgtime='FAILED'
	fi
     else
	avgtime='FAILED'
     fi
     line="${line} ${avgtime}"
   done

   totaltime=0
   iterations=0
   avgtime=0

   targetfile=giraph/numbers-${scale}/webmap/*-${1}* 

   if [ -f $targetfile ]
   then
	succ=`cat ${targetfile}|grep 'Superstep'`
        #echo $failure
        if [ "$succ" != "" ]
        then
   		cat ${targetfile}|grep 'Superstep'|grep 'ms' >tmp.txt
   		while read iterationline
   		do
        		iterationtime=`echo ${iterationline}|awk '{print $8}'|awk -F "=" '{print $2}'`
        		totaltime=$((totaltime+iterationtime))
        		iterations=$((iterations+1))
   		done<tmp.txt
   		#echo $iterations
   		avgtime=$((totaltime/iterations))
  	else
		avgtime='FAILED'
	fi 
  else
	avgtime='FAILED'
   fi
   line="${line} ${avgtime}"
   
   echo $line
done

