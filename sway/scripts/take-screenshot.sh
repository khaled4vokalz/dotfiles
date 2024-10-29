#!/bin/bash
# Default values for flags
fullscreen=false
edit=false
copy=false

# Parse flags
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --fullscreen)
            fullscreen=true
            ;;
        --copy)
            copy=true
            ;;
        --edit)
            edit=true
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
    shift
done

FILENAME="/tmp/screenshot-$(date +%s).png"

if [[ "$fullscreen" = true && "$copy" = true ]]; then
  grim -o "$(swaymsg -t get_outputs | jq -r '.[] | select(.focused) | .name')" - | wl-copy
elif [[ "$fullscreen" = true && "$edit" = true ]]; then
  grim -o "$(swaymsg -t get_outputs | jq -r '.[] | select(.focused) | .name')" "$FILENAME"
  # Open the customized screenshot in KSnip for further annotation
  ksnip "$FILENAME"
elif [[ "$edit" = true ]]; then
  # Capture the screenshot using grim and slurp
  grim -g "$(slurp)" "$FILENAME"
  # Open the customized screenshot in KSnip for further annotation
  ksnip "$FILENAME"
else
  grim -g "$(slurp)" - | wl-copy
fi


