#!/usr/bin/env bash
# scripts/kitty.sh
# Quickshell Hook: Updates Kitty terminal theme
# Args: $1 = theme_id, $2 = absolute_theme_path, $3 = context, $4 = opacity

THEME_PATH="$2"
# We assume the template is in the root of the assets/themes directory, 

ASSETS_DIR=$(dirname "$THEME_PATH")
TEMPLATE_FILE="$ASSETS_DIR/kitty.conf"
CACHE_DIR="$HOME/.cache/quickshell"
GENERATED_FILE="$CACHE_DIR/themes/kitty.conf"
COLORS_FILE="$THEME_PATH/colors.json"

mkdir -p "$CACHE_DIR/themes"

# Validate input
if [ ! -f "$COLORS_FILE" ]; then
    # echo "Error: colors.json not found at $COLORS_FILE"
    exit 1
fi

if [ ! -f "$TEMPLATE_FILE" ]; then
    # echo "Error: Template not found at $TEMPLATE_FILE"
    exit 1
fi

# Use AWK for one-pass JSON loading and template substitution
awk -v json_file="$COLORS_FILE" '
    BEGIN {
        # Load colors into an array
        while ((getline line < json_file) > 0) {
            if (line ~ /": "/) {
                match(line, /"([^"]+)": "([^"]+)"/, arr)
                colors[arr[1]] = arr[2]
            }
        }
        if (colors["primaryIdx"] != "") colors["primary"] = colors[colors["primaryIdx"]]
        if (colors["secondaryIdx"] != "") colors["secondary"] = colors[colors["secondaryIdx"]]
        if (colors["base"] == "") colors["base"] = colors["base00"]
        if (colors["background"] == "") colors["background"] = colors["base00"]
        if (colors["surface"] == "") colors["surface"] = colors["base01"]
        if (colors["text"] == "") colors["text"] = colors["base05"]
        if (colors["textDim"] == "") colors["textDim"] = colors["base04"]
        if (colors["muted"] == "") colors["muted"] = colors["base04"]
        if (colors["accent"] == "") colors["accent"] = colors["base0A"]
        if (colors["error"] == "") colors["error"] = colors["base08"]
        if (colors["warning"] == "") colors["warning"] = colors["base09"]
        if (colors["success"] == "") colors["success"] = colors["base0B"]
    }
    {
        line = $0
        for (key in colors) {
            gsub("{{" key "}}", colors[key], line)
        }
        print line
    }
' "$TEMPLATE_FILE" > "$GENERATED_FILE"

# Apply background opacity if provided
OPACITY="$4"
if [ -n "$OPACITY" ]; then
    echo "background_opacity $OPACITY" >> "$GENERATED_FILE"
fi

# Check if generation was successful
if [ $? -eq 0 ]; then
    # Live reload all kitty instances
    SOCKETS=""
    [ -S "/tmp/kitty" ] && SOCKETS="/tmp/kitty"
    DYNAMIC=$(find /tmp -maxdepth 1 -name "kitty-*" -type s 2>/dev/null)
    SOCKETS="$SOCKETS $DYNAMIC"
    
    if [ -n "$SOCKETS" ]; then
        for socket in $SOCKETS; do
            kitty @ --to "unix:$socket" set-colors -a "$GENERATED_FILE" >/dev/null 2>&1
        done
        (pkill -USR1 kitty) &
    fi
fi