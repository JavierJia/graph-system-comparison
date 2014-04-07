./sump.sh unmerge >pregelix.txt
./sumg.sh mem > giraph-mem.txt
./sumg.sh ooc > giraph-ooc.txt


aggmem="0.011 0.044 0.067 0.140 0.280"
for linenum in 2 3 4 5
do
  line=0
  pnumber=""
  gmnumber=""
  gonumber=""

  while read pline
  do
   if [ "$line" == "$linenum"  ]; then
   	pnumber=$pline
   fi   
   line=$((line+1))
  done<pregelix.txt

  line=0
  while read gmline
  do
   if [ "$line" == "$linenum" ]; then
        gmnumber=$gmline
   fi   
   line=$((line+1))
  done<giraph-mem.txt

  line=0
  while read goline
  do 
    if [ "$line" == "$linenum" ]; then
        gonumber=$goline
    fi   
    line=$((line+1))
  done<giraph-ooc.txt

  scale=`echo ${pnumber}|awk '{print $1}'`
  
  echo "#Dataset-Size Pregelix Giraph-mem Giraph-ooc">response_${scale}.txt
  i=2
  for mem in ${aggmem}
  do
        factor=$((6-linenum))

	if [ "$factor" == "2" ]; then
                factor=1.33
        fi

        if [ "$factor" == "3" ]; then
                factor=2
        fi

        if [ “$factor” == "4" ]; then
                factor=4
        fi

        mem=$(echo "scale=3;  $mem*$factor"|bc)
	pregelixentry=`echo ${pnumber}|awk -v a=$i '{print $a}'`
        giraphmementry=`echo ${gmnumber}|awk -v a=$i '{print $a}'`
        giraphoocentry=`echo ${gonumber}|awk -v a=$i '{print $a}'`
        i=$((i+1))	
        echo "${mem} ${pregelixentry} ${giraphmementry} ${giraphoocentry}">>response_${scale}.txt
  done
  find -P response_${scale}.txt|xargs perl -pi -e 's|FAILED||g' 
done


for linenum in 7 8 9 10
do
  line=0
  pnumber=""
  gmnumber=""
  gonumber=""

  while read pline
  do
   if [ "$line" == "$linenum"  ]; then
        pnumber=$pline
   fi
   line=$((line+1))
  done<pregelix.txt

  line=0
  while read gmline
  do
   if [ "$line" == "$linenum" ]; then
        gmnumber=$gmline
   fi
   line=$((line+1))
  done<giraph-mem.txt

  line=0
  while read goline
  do
    if [ "$line" == "$linenum" ]; then
        gonumber=$goline
    fi
    line=$((line+1))
  done<giraph-ooc.txt

  scale=`echo ${pnumber}|awk '{print $1}'`

  echo "#Dataset-Size Pregelix Giraph-mem Giraph-ooc">iteration_${scale}.txt
  i=2
  for mem in ${aggmem}
  do
        factor=$((11-linenum))
	if [ "$factor" == "2" ]; then
                factor=1.33
        fi

        if [ "$factor" == "3" ]; then
                factor=2
        fi

        if [ “$factor” == "4" ]; then
                factor=4
        fi
	mem=$(echo "scale=3;  $mem*$factor"|bc)
        pregelixentry=`echo ${pnumber}|awk -v a=$i '{print $a}'`
        giraphmementry=`echo ${gmnumber}|awk -v a=$i '{print $a}'`
        giraphoocentry=`echo ${gonumber}|awk -v a=$i '{print $a}'`
 	
	pregelixentry=$(echo "scale=0; $pregelixentry/1000"|bc)
        if [ "$giraphmementry" != "FAILED" ]; then
		giraphmementry=$(echo "scale=0; $giraphmementry/1000"|bc)
	fi
	
	if [ "$giraphoocentry" != "FAILED" ]; then
        	giraphoocentry=$(echo "scale=0; $giraphoocentry/1000"|bc)
	fi
	
        i=$((i+1))
        echo "${mem} ${pregelixentry} ${giraphmementry} ${giraphoocentry}">>iteration_${scale}.txt
  done
  find -P iteration_${scale}.txt|xargs perl -pi -e 's|FAILED||g'
done
