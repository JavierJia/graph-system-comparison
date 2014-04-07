for i in `cat conf/slaves`
do
   ssh $i 'mkdir /tmp/yingyib; mkdir /scratch/yingyib; mkdir /mnt/data/sdb/yingyib'
done
