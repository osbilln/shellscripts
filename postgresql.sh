#!/bin/bash

if [ $# != 2 ]
then
  echo "Arg 1 must be an environment Location (rackspace, vivo, softlayer, etc.....)"
  echo "Arg 2 must be a file type "
  exit
fi

if [ -n $1 ]
 then
   ENV=$1
   echo $ENV
 else
   exit 1
fi

if [ -e $2 ]
 then
   SERVER=`cat $2`
   echo $SERVER
 else
   SERVER=$2
   echo $SERVER
fi


for i in $SERVER
  do
   echo $i
   ssh $i -C "chkconfig | grep postgresql"
#   ssh $i -C "chkconfig postgresql-9.1 off"
#   ssh $i -C "service postgresql-9.1 stop"
  done
