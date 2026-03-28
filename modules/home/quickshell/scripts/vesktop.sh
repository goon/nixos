#!/usr/bin/env bash
# scripts/vesktop.sh
# Quickshell Hook: Updates Vesktop (Discord) theme
# Args: $1 = theme_id, $2 = absolute_theme_path

THEME_PATH="$2"
THEME_DIR=$(dirname "$THEME_PATH")
TEMPLATE_FILE="$THEME_DIR/vesktop.css"
TARGET_FILE="$HOME/.config/vesktop/themes/qsTheme.css"
COLORS_FILE="$THEME_PATH/colors.json"

mkdir -p "$(dirname "$TARGET_FILE")"

# Extract Font from user-prefs.json using grep/sed
FONT="Outfit"
PREFS_FILE="$HOME/.cache/quickshell/preferences.json"
if [ -f "$PREFS_FILE" ]; then
    RAW_FONT=$(grep "\"shellFont\":" "$PREFS_FILE" | sed -E 's/.*:[[:space:]]*"([^"]*)".*/\1/')
    if [ -n "$RAW_FONT" ]; then
        # Clean font name (remove weights)
        FONT=$(echo "$RAW_FONT" | awk '{
            for(i=1;i<=NF;i++){
                if($i ~ /^(Thin|ExtraLight|Light|Regular|Medium|SemiBold|Bold|ExtraBold|Black|Heavy)$/) break;
                printf "%s%s", $i, (i==NF || $(i+1) ~ /^(Thin|ExtraLight|Light|Regular|Medium|SemiBold|Bold|ExtraBold|Black|Heavy)$/ ? "" : " ")
            }
        }')
    fi
fi

# Use AWK for one-pass JSON loading and template substitution
awk -v json_file="$COLORS_FILE" -v font="$FONT" '
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
        colors["font"] = font
        colors["code_font"] = font
    }
    {
        line = $0
        for (key in colors) {
            gsub("{{" key "}}", colors[key], line)
        }
        print line
    }
' "$TEMPLATE_FILE" > "$TARGET_FILE"
