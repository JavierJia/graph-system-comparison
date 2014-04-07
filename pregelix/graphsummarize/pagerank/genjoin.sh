./sumpi.sh inner >pregelix-inner.txt
mv pregelix.txt pregelix-outer.txt
mv pregelix-inner.txt pregelix.txt
prefix="response_join"

#aggmem="0.020 0.055 0.071 0.105 0.130"
aggmem="0.022 0.088 0.133 0.280 0.561"
for linenum in 2
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
  done<pregelix-outer.txt

  scale=`echo ${pnumber}|awk '{print $1}'`
  
  echo "#Dataset-Size Unouter OuterJoin">${prefix}_${scale}.txt
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
	#echo "factor $factor"
        mem=$( echo "scale=3; $mem*$factor"|bc)
	#echo $mem
        pregelixentry=`echo ${pnumber}|awk -v a=$i '{print $a}'`
        outermementry=`echo ${gmnumber}|awk -v a=$i '{print $a}'`
        i=$((i+1))	
        echo "${mem} ${pregelixentry} ${outermementry}">>${prefix}_${scale}.txt
  done
  find -P ${prefix}_${scale}.txt|xargs perl -pi -e 's|FAILED||g' 
done


prefix="iteration_join"
for linenum in 7
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
  done<pregelix-outer.txt


  scale=`echo ${pnumber}|awk '{print $1}'`

  echo "#Dataset-Size Pregelix InnerJoin OuterJoin">${prefix}_${scale}.txt
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
	mem=$(echo "scale=3; $mem*$factor"|bc)
        #pnumber=$(echo "scale=0; $pnumber/1000"|bc)
        #gmnumber=$(echo "scale=0; $gmnumber/1000"|bc)
        pregelixentry=`echo ${pnumber}|awk -v a=$i '{print $a}'`
        outermementry=`echo ${gmnumber}|awk -v a=$i '{print $a}'`
        pregelixentry=$(echo "scale=0; $pregelixentry/1000"|bc)
	outermementry=$(echo "scale=0; $outermementry/1000"|bc)
	i=$((i+1))
        echo "${mem} ${pregelixentry} ${outermementry}">>${prefix}_${scale}.txt
  done
  find -P ${prefix}_${scale}.txt|xargs perl -pi -e 's|FAILED||g'
done

