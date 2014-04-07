lines="7 8 9 10"
line=0
echo "">speedup.txt

base0=""
base1=""
base2=""
base3=""
base4=""


echo "#scale 2.85GB 11.22GB 17.04GB 35.79GB 71.82GB">>speedup.txt
while read pline
do
  if [ $line -eq 7 ]; then
       	base0=`echo $pline|awk '{print $2}'`
        base1=`echo $pline|awk '{print $3}'`
        base2=`echo $pline|awk '{print $4}'`
        base3=`echo $pline|awk '{print $5}'`
        base4=`echo $pline|awk '{print $6}'`
  fi
  line=$((line+1))
done<pregelix.txt

line=0
while read pline
do
  if [ $line -gt 6 ] && [ $line -lt 11 ]; then
       scale=`echo $pline|awk '{print $1}'`
       
       num0=`echo $pline|awk '{print $2}'`
       num1=`echo $pline|awk '{print $3}'`
       num2=`echo $pline|awk '{print $4}'`
       num3=`echo $pline|awk '{print $5}'`
       num4=`echo $pline|awk '{print $6}'`

       res0=$(echo "scale=3; $num0/$base0"|bc)
       res1=$(echo "scale=3; $num1/$base1"|bc)
       res2=$(echo "scale=3; $num2/$base2"|bc)
       res3=$(echo "scale=3; $num3/$base3"|bc)
       res4=$(echo "scale=3; $num4/$base4"|bc)
       
       echo "$scale $res0 $res1 $res2 $res3 $res4">>speedup.txt
  fi
  line=$((line+1))
done<pregelix.txt

# generate scaleup file
line=0
base=""
while read pline
do
  if [ $line -eq 7 ] ; then
        base=`echo $pline|awk '{print $4}'`
  fi
  line=$((line+1))
done<pregelix.txt

line=0
echo "#scale time">scaleup.txt
scalebase="71.82"
while read pline
do
  if [ $line -eq 7 ] ; then
       scale=$(echo "scale=3; 17.04/$scalebase"|bc)
       #scale="1"
       num=`echo $pline|awk '{print $4}'`
       num=$(echo "scale=3; $num/$base"|bc)
       echo "$scale $num">>scaleup.txt
  fi
  
  if [ $line -eq 8 ] ; then
       scale=$(echo "scale=3; 35.79/$scalebase"|bc)
       #scale="2"
       num=`echo $pline|awk '{print $5}'`
       num=$(echo "scale=3; $num/$base"|bc)
       echo "$scale $num">>scaleup.txt
  fi

  if [ $line -eq 10 ] ; then
       #scale="71.82"
       scale=$(echo "scale=3; 71.82/$scalebase"|bc)
       #scale="4"
       num=`echo $pline|awk '{print $6}'`
       num=$(echo "scale=3; $num/$base"|bc)
       echo "$scale $num">>scaleup.txt
  fi

  line=$((line+1))
done<pregelix.txt


#generate comparison with Giraph
echo "#scale responetime">speedupcompare.txt
basep=""
baseg=""
for linenum in 7 8 9 10
do
   line=0
   linestr=""
   while read pline
   do
     if [ $line -eq 7 ]; then
     	basep=`echo $pline|awk '{print $3}'`
     fi
     if [ $line -eq $linenum ]; then
       scale=`echo $pline|awk '{print $1}'`
       num0=`echo $pline|awk '{print $3}'`
       num0=$(echo "scale=3; $num0/$basep"|bc)
       linestr=`echo "$scale $num0"`
     fi
     line=$((line+1))
   done<pregelix.txt

   line=0
   while read gmline
   do
     #if [ $line -eq 7 ] && [ $line -eq $linenum ]; then
     #	linestr=""
     #	continue	
     #fi
     if [ $line -eq 7 ]; then
        baseg=`echo $gmline|awk '{print $3}'`
	baseg=`expr $baseg|bc`
     fi
     if [ $line -eq $linenum ]; then
       #scale=`echo $pline|awk '{print $1}'`
       num0=`echo $gmline|awk '{print $3}'`
       num0=$(echo "scale=3; $num0/$baseg"|bc)
       linestr=`echo "$linestr $num0"`
     fi
     line=$((line+1))
   done<giraph-mem.txt
   echo $linestr>>speedupcompare.txt
done
