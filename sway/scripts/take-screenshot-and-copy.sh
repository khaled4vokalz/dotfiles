#!/bin/bash

# Capture the screenshot using grim and slurp
grim -g "$(slurp)" - | wl-copy

