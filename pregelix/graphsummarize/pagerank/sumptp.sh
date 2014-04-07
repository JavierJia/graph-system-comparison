#echo "#  Overall Execution Time"
#echo "#  001x 01x 1x"
for scale in 32
do
   for size in 005 05
   do
     file=tp${size}x.txt
     echo "">$file
     for mpl in 1 2 3
     do
	avgtime=0
	for ((k=1; k<=mpl; k++))
	do
     		exectime=`cat pregelix/numbers-${scale}/webmap${size}x/*-mpl-${mpl}-${k}*|grep 'Total Execution Time'|awk '{print $4}'`
		avgtime=$((avgtime+exectime))
	done
	avgtime=$(echo "scale=3; $avgtime/$mpl"|bc)
        jph=$(echo "scale=3; $((mpl*3600))/$avgtime"|bc)
	line="${mpl} ${jph}"
	echo $line>>$file
     done
   done
    
   file=tp1x.txt
   echo "">$file
   for mpl in 1 2 3
   do
	avgtime=0
        for ((k=1; k<=mpl; k++))
        do
                exectime=`cat pregelix/numbers-${scale}/webmap/*-mpl-${mpl}-${k}*|grep 'Total Execution Time'|awk '{print $4}'`
                #echo $exectime
		avgtime=$((avgtime+exectime))
        done
        avgtime=$(echo "scale=3; $avgtime/$mpl"|bc)
        jph=$(echo "scale=3; $((mpl*3600))/$avgtime"|bc)
	line="${mpl} ${jph}"
        echo $line>>$file
   done
done


linenum=0
echo "">gtp005x.txt
echo "">gtp05x.txt
while read gline
do
   if [ $linenum -eq 5 ]; then
   	time01=`echo $gline|awk '{print $3}'`
	time02=`echo $gline|awk '{print $5}'`
	jph01=$(echo "scale=3; 3600/$time01"|bc)
	jph02=$(echo "scale=3; 3600/$time02"|bc)
	echo "1 $jph01">>gtp005x.txt
	echo "1 $jph02">>gtp05x.txt
   fi
   linenum=$((linenum+1))
done<giraph-mem.txt

echo "2 0">>gtp005x.txt
echo "3 0">>gtp005x.txt
echo "2 0">>gtp05x.txt
echo "3 0">>gtp05x.txt

echo "1 0">gtp1x.txt
echo "2 0">>gtp1x.txt
echo "3 0">>gtp1x.txt
