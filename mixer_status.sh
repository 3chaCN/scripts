#!/bin/bash

c=$1

cmd=$(amixer get Master | tail -n 1 | awk '{print $4}')
level=$(echo ${cmd:1:3} | sed 's/%//g')
bar="▁ ▂ ▃ ▅ ▆ ▇"
bar_empty="          "  

case $c in
   'p') amixer sset Master playback $((${level} + 10));;
   'm') amixer sset Master playback $((${level} - 10));;
esac

printf "[vol]:${bar:0:$((${level}/10))}"
