#!/usr/bin/env bash
# scripts/gowall-wrapper
# PIPE MODE
# Args: $1 = input_wallpaper, $2 = theme_id, $3 = output_path

INPUT_FILE="$1"
THEME_ID="$2"
OUTPUT_FILE="$3"

# Validate input
if [ -z "$INPUT_FILE" ] || [ -z "$THEME_ID" ] || [ -z "$OUTPUT_FILE" ]; then
    echo "Usage: $0 <input_file> <theme_id> <output_file>"
    exit 1
fi

mkdir -p "$(dirname "$OUTPUT_FILE")"

EXTENSION="${OUTPUT_FILE##*.}"
FILENAME=$(basename "$OUTPUT_FILE" ."$EXTENSION")
DIRNAME=$(dirname "$OUTPUT_FILE")
TEMP_FILE="$DIRNAME/${FILENAME}_temp.${EXTENSION}"

# Clean start
rm -f "$TEMP_FILE"

# PIPE IMPLEMENTATION
# According to docs: https://achno.github.io/gowall-docs/unix_pipe
# 1st arg '-' = Read from Stdin
# 2nd arg '-' = Write to Stdout (if we wanted to pipe to file)
# But here we can use the --output flag with Stdin input, or pipe output.
# Let's try pure pipes as it avoids gowall managing file handles.

# cat input | gowall convert - - -t theme > output
if cat "$INPUT_FILE" | gowall convert - - --theme "$THEME_ID" > "$TEMP_FILE"; then
    mv "$TEMP_FILE" "$OUTPUT_FILE"
    exit 0
else
    rm -f "$TEMP_FILE"
    exit 1
fi
