#!/bin/bash

inet=$1

subnet=$(echo $inet | sed 's/\([0-9]*\.[0-9]*\.[0-9]*\.\)[0-9]*-[0-9]*/\1/')
start=$(echo $inet | sed 's/[0-9]*\.[0-9]*\.[0-9]*\.\([0-9]*\)/\1/' | sed 's/\([0-9]*\)\-\([0-9]*\)/\1/')
end=$(echo $inet | sed 's/[0-9]*\.[0-9]*\.[0-9]*\.\([0-9]*\)/\1/' | sed 's/\([0-9]*\)\-\([0-9]*\)/\2/')

echo "${end} hosts to ping..."
echo $subnet

for ((i = $start ; i < $end ; i++))
do
    ping -c 1 $subnet$i
done

