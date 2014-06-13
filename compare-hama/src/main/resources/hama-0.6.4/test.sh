 for i in {1..3}; do 
     echo $i
     sleep 20 & 
 done 
 wait 
 echo "finished"
