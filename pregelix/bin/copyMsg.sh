. conf/cluster.properties

NODEID=`hostname | cut -d '.' -f 1`
#echo $NODEID

rsync /var/log/messages ${1}:${2}${NODEID}
