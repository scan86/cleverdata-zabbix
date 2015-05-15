#!/bin/bash

proc=$1
jps_bin=/usr/lib/jvm/java-7-oracle-cloudera/bin/jps

if [ $# -ne 1 ]
then
 echo 2
 exit 0
fi

lines=$($jps_bin | cut -d ' ' -f 2 | grep -P "^${proc}$" | wc -l)
if [ $lines -gt 0 ]
then
 echo 1
 exit 0
fi

echo 0
exit 0
