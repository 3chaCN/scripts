#!/bin/bash

todo_list=$(calcurse -Q | xargs)
let size=20
let fsize=$(( ${size} * 2 ))
let length=${#todo_list}
let st=0
while true
do
	while [[ $st -lt $length ]];
	do
		printf -- '\b%.0s' {1..40}
		printf "${todo_list:${st}:${size}}"
		st=$(($st + 1))
		sleep 1
	done
	st=0
done


