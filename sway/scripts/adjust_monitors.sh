#!/bin/bash

scale_monitors() {
  for monitor in $(swaymsg -t get_outputs -r | grep DP | cut -f2 -d":" | tr -d \",); do
    swaymsg output $monitor scale 2
  done
}

scale_monitors
