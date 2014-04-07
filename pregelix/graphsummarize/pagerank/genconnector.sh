./sump.sh merge >pregelix-merge.txt
prefix="response_connector"

aggmem="0.022 0.088 0.133 0.280 0.561"
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
  done<pregelix-merge.txt

  scale=`echo ${pnumber}|awk '{print $1}'`
  
  echo "#Dataset-Size Unmerge Merge">${prefix}_${scale}.txt
  i=2
  for mem in ${aggmem}
  do
        factor=$((6-linenum))
        #echo "factor $factor"
        mem=$( echo "scale=3; $mem*$factor"|bc)
	#echo $mem
        pregelixentry=`echo ${pnumber}|awk -v a=$i '{print $a}'`
        mergemementry=`echo ${gmnumber}|awk -v a=$i '{print $a}'`
        i=$((i+1))	
        echo "${mem} ${pregelixentry} ${mergemementry}">>${prefix}_${scale}.txt
  done
  find -P ${prefix}_${scale}.txt|xargs perl -pi -e 's|FAILED||g' 
done


prefix="iteration_connector"
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
  done<pregelix-merge.txt


  scale=`echo ${pnumber}|awk '{print $1}'`

  echo "#Dataset-Size Pregelix Unmerge Merge">${prefix}_${scale}.txt
  i=2
  for mem in ${aggmem}
  do
        factor=$((11-linenum))
        mem=$(echo "scale=3; $mem*$factor"|bc)
        #pnumber=$(echo "scale=0; $pnumber/1000"|bc)
        #gmnumber=$(echo "scale=0; $gmnumber/1000"|bc)
        pregelixentry=`echo ${pnumber}|awk -v a=$i '{print $a}'`
        mergemementry=`echo ${gmnumber}|awk -v a=$i '{print $a}'`
        pregelixentry=$(echo "scale=0; $pregelixentry/1000"|bc)
	mergemementry=$(echo "scale=0; $mergemementry/1000"|bc)
	i=$((i+1))
        echo "${mem} ${pregelixentry} ${mergemementry}">>${prefix}_${scale}.txt
  done
  find -P ${prefix}_${scale}.txt|xargs perl -pi -e 's|FAILED||g'
done

