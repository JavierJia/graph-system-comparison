for i in `cat conf/slaves`
do
   echo $i
   ssh $i 'rm -rf /scratch/yingyib/t*; rm -rf /scratch/yingyib/s*; rm -rf /scratch/yingyib/c*; rm -rf /scratch/yingyib/hadoop2*; rm -rf /scratch/yingyib/hadoop3*; rm -rf /scratch/yingyib/hadoop-1.0.4*'
   ssh $i 'rm -rf /tmp/yingyib/t*; rm -rf /tmp/yingyib/s*; rm -rf /tmp/yingyib/c*'
done
