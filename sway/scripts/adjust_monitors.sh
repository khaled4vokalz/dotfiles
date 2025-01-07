#!/bin/bash

scale_monitors() {
  for monitor in $(swaymsg -t get_outputs -r | jq -r '.[] | select(.name | startswith("DP")) | .name'); do
    swaymsg output "$monitor" scale 2
  done
}

scale_monitors
