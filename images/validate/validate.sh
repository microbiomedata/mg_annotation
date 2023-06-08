#!/bin/bash

CANDIDATE=${1}
REF=$(basename $CANDIDATE)
THRESH=0.002

echo "Testing $REF"
diff --color -u0 $REF $CANDIDATE
CT=$(diff -u0 $REF $CANDIDATE|grep ^+|grep -v ^+++|wc -l)
features=$(wc -l $REF|awk '{print $1}')
max=$(echo "${features}*${THRESH}"|bc|sed 's/\..*//')

if [ $CT -gt $max ] ; then
	echo "Failed for $REF $CT > $max"
	exit 1
fi

