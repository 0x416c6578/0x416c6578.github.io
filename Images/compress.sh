#!/bin/bash

# Change this value to set the compression quality (0–100, lower means more compression)
QUALITY=85

# Root directory to start the search; default to current directory
ROOT_DIR="${1:-.}"

# Find all .png and .jpg/.jpeg files recursively
find "$ROOT_DIR" -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \) | while read -r filepath; do
    dir=$(dirname "$filepath")
    filename=$(basename "$filepath")
    extension="${filename##*.}"
    name="${filename%.*}"
    output_file="$dir/${name}.jpg"

    # Skip if already converted
    if [[ "$filename" == *"-converted.jpg" ]]; then
        echo "Skipping already converted file: $filepath"
        continue
    fi

    echo "Converting: $filepath -> $output_file"
    convert "$filepath" -quality $QUALITY "$output_file"
done

echo "All done!"
