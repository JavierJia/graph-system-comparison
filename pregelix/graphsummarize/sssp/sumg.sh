echo "  Overall Execution Time"
echo "  001x 005x 01x 05x 1x"
for scale in 8 16 24 32
do
   line=${scale}
   scale=$((scale-1))
   for size in  001 005 01 05
   do
     targetfile=giraph/numbers-${scale}/btc${size}x/*-${1}*
     if [ -f $targetfile ]
     then
        succ=`cat ${targetfile}|grep 'Superstep 2'`
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

   targetfile=giraph/numbers-${scale}/btc/*-${1}*
   if [ -f $targetfile ]
   then
	succ=`cat ${targetfile}|grep 'Superstep 2'`
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
   
     targetfile=giraph/numbers-${scale}/btc${size}x/*-${1}*

     if [ -f $targetfile ]
     then
        succ=`cat ${targetfile}|grep 'Superstep 2'`
        #echo $failure
        if [ "$succ" != "" ]
	then
     		cat ${targetfile}|grep 'Superstep'|grep 'ms' >tmp.txt
     		while read iterationline
     		do
			superstep=`echo  ${iterationline}|awk '{print $6}'`
			if [ $superstep != "0" ]; then
				iterationtime=`echo ${iterationline}|awk '{print $8}'|awk -F "=" '{print $2}'`
        			totaltime=$((totaltime+iterationtime))
        		fi
			iterations=$((iterations+1))
     		done<tmp.txt
		iterations=$((iterations-1))
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

   targetfile=giraph/numbers-${scale}/btc/*-${1}* 

   if [ -f $targetfile ]
   then
	succ=`cat ${targetfile}|grep 'Superstep 2'`
        #echo $failure
        if [ "$succ" != "" ]
        then
   		cat ${targetfile}|grep 'Superstep'|grep 'ms' >tmp.txt
   		while read iterationline
   		do
			superstep=`echo  ${iterationline}|awk '{print $6}'`
			if [ $superstep != "0" ]; then
        			iterationtime=`echo ${iterationline}|awk '{print $8}'|awk -F "=" '{print $2}'`
        			totaltime=$((totaltime+iterationtime))
        		fi
			iterations=$((iterations+1))
   		done<tmp.txt
   		#echo $iterations
		iterations=$((iterations-1))
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

