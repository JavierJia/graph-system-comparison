#!/bin/bash - 
#===============================================================================
#
#          FILE: .common.sh
# 
#         USAGE: ./.common.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Jianfeng Jia (), jianfeng.jia@gmail.com
#  ORGANIZATION: ics.uci.edu
#       CREATED: 04/24/2014 09:40:49 PM PDT
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

function exit_and_email_message {
    eno=$1
    subject=$2
    ssh openlab <<-EOF
    cd $PWD
    tempfilename=`mktemp -p /tmp`

    echo "From: jianfenj@ics.uci.edu" >\$tempfilename
    echo "To: jianfeng.jia@gmail.com" >>\$tempfilename
    echo "Subject: $subject" >>\$tempfilename
    echo >>\$tempfilename

    echo "$@" >> \$tempfilename
    for arg in "$@"; do
        [ -f "\$arg" ] &&  cat "\$arg" >>\$tempfilename
    done

    sendmail jianfeng.jia@gmail.com <\$tempfilename
EOF
    [ $eno == 0 ] || exit $eno
}


