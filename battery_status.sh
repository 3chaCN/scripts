#!/bin/bash
# usage : <battery_num>

bar_char="▊▊▊▊▊▊▊▊▊▊"
bar_space="▭▭▭▭▭▭▭▭▭▭"
bar_len=10

sys_path="/sys/class/power_supply/BAT"
battery=$1

charge_full=$(cat ${sys_path}${battery}/charge_full) # 10 chars
charge_now=$(cat ${sys_path}${battery}/charge_now) # x chars

#bar_now=$(( (($charge_now*$bar_len)/$charge_full) * 8))
bar_now=$(( ($charge_now*$bar_len)/$charge_full ))
empty_now=$(( $bar_len - $bar_now ))
percent_now=$(( ($charge_now*100)/$charge_full ))

printf "║${bar_char:0:$bar_now}${bar_space:0:$empty_now}║${percent_now}\n"


