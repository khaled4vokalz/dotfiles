#!/bin/bash
FILENAME="/tmp/screenshot-$(date +%s).png"
OUTPUT="/tmp/customized_screenshot.png"

# Capture the screenshot using grim and slurp
grim -g "$(slurp)" "$FILENAME"

# Customize the screenshot using ImageMagick (resize and add border)
# convert "$FILENAME" -resize 75% -border 10x10 -bordercolor black "$OUTPUT"

# Open the customized screenshot in KSnip for further annotation
ksnip "$FILENAME"
