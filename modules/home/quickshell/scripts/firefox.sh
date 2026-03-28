#!/usr/bin/env bash
# scripts/firefox.sh
# This script is triggered by Quickshell's ThemeService.
# Generates a Pywalfox-compatible JSON and triggers a live update.

THEME_ID="$1"
THEME_PATH="$2"
COLORS_JSON="$THEME_PATH/colors.json"

if [ ! -f "$COLORS_JSON" ]; then
    echo "Colors file not found: $COLORS_JSON"
    exit 1
fi

get_color_raw() {
    grep "\"$1\":" "$COLORS_JSON" | sed -E 's/.*:[[:space:]]*"([^"]*)".*/\1/' | head -n 1
}

get_color() {
    local key="$1"
    case "$key" in
        "background"|"base") key="base00" ;;
        "surface"|"surfaceAlt") key="base01" ;;
        "border"|"divider") key="base03" ;;
        "textDim"|"muted") key="base04" ;;
        "text") key="base05" ;;
        "error") key="base08" ;;
        "warning") key="base09" ;;
        "accent") key="base0A" ;;
        "success") key="base0B" ;;
        "info") key="base0C" ;;
        "primary") key="primaryIdx" ;;
        "secondary") key="secondaryIdx" ;;
    esac
    
    local val=$(get_color_raw "$key")
    if [[ "$val" == base* ]]; then
        get_color_raw "$val"
    else
        echo "$val"
    fi
}

BG=$(get_color "background")
SURFACE=$(get_color "surface")
TEXT=$(get_color "text")
TEXT_DIM=$(get_color "textDim")
PRIMARY=$(get_color "primary")
ACCENT=$(get_color "accent")

[ -z "$BG" ] && BG=$(get_color "base")
[ -z "$ACCENT" ] && ACCENT="$PRIMARY"
[ -z "$TEXT_DIM" ] && TEXT_DIM="#6a6a7a"

# --- 1. Generate Pywalfox JSON (Noctalia Mapping) ---
PYWALFOX_DIR="$HOME/.cache/quickshell/themes"
PY_JSON="$PYWALFOX_DIR/pywalfox.json"

mkdir -p "$PYWALFOX_DIR"

# Mapping colors to pywal roles for the extension
# color0: bg, color3: primary, color7: surface, color15: text, color19: bg
cat <<EOF > "$PY_JSON"
{
  "wallpaper": "",
  "alpha": "100",
  "colors": {
    "color0": "$BG",
    "color1": "$BG",
    "color2": "$BG",
    "color3": "$PRIMARY",
    "color4": "$PRIMARY",
    "color5": "$PRIMARY",
    "color6": "$ACCENT",
    "color7": "$SURFACE",
    "color8": "$BG",
    "color9": "$BG",
    "color10": "$PRIMARY",
    "color11": "$PRIMARY",
    "color12": "$PRIMARY",
    "color13": "$ACCENT",
    "color14": "$ACCENT",
    "color15": "$TEXT",
    "color16": "$TEXT",
    "color17": "$SURFACE",
    "color18": "$SURFACE",
    "color19": "$BG"
  }
}
EOF

# --- 2. Live Update via Pywalfox ---
# Pywalfox typically expects colors.json in ~/.cache/wal/colors.json
# We'll symlink our file there so the update command picks it up.
WAL_DIR="$HOME/.cache/wal"
mkdir -p "$WAL_DIR"
ln -sf "$PY_JSON" "$WAL_DIR/colors.json"

# Trigger the update
if command -v pywalfox >/dev/null 2>&1; then
    echo "Firefox: Triggering Pywalfox update..."
    pywalfox update
else
    echo "Firefox: pywalfox-native not found. Update skipped."
fi

echo "Firefox Theme sync completed for $THEME_ID"
