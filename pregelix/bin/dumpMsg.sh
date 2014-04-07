. conf/cluster.properties
PREGELIX_PATH=`pwd`
LOG_PATH=$PREGELIX_PATH/msg/
rm -rf $LOG_PATH
mkdir $LOG_PATH
ccname=`hostname`

for i in `cat conf/slaves`
do
   echo $i
   ssh $i "cd ${PREGELIX_PATH}; bin/copyMsg.sh ${ccname} ${LOG_PATH}"
done

