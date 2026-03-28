#!/usr/bin/env bash
# scripts/qt6ct.sh
# This script is triggered by Quickshell's ThemeService.
# Generates a qt6ct color scheme based on the current shell theme.

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

# --- 1. Generate qt6ct color scheme ---
QT6CT_COLORS_DIR="$HOME/.config/qt6ct/colors"
QT6CT_MAIN_CONF="$HOME/.config/qt6ct/qt6ct.conf"
QT_CONF_FILE="$QT6CT_COLORS_DIR/Quickshell.conf"

mkdir -p "$QT6CT_COLORS_DIR"

# Roles: 0:WindowText, 1:Button, 2:Light, 3:Midlight, 4:Dark, 5:Mid, 6:Text, 7:BrightText, 8:ButtonText, 9:Base, 10:Window, 11:Shadow, 12:Highlight, 13:HighlightedText, 14:Link, 15:LinkVisited, 16:AlternateBase, 17:ToolTipBase, 18:ToolTipText, 19:PlaceholderText

COLORS="$TEXT, $SURFACE, $SURFACE, $SURFACE, $BG, $BG, $TEXT, $PRIMARY, $TEXT, $BG, $BG, $BG, $PRIMARY, #ffffff, $PRIMARY, $PRIMARY, $SURFACE, $SURFACE, $TEXT, $TEXT_DIM"

cat <<EOF > "$QT_CONF_FILE"
[Colors]
active_colors=$COLORS
inactive_colors=$COLORS
disabled_colors=$COLORS
EOF

# --- 2. Update qt6ct.conf to use our scheme ---
if [ -f "$QT6CT_MAIN_CONF" ]; then
    # Update color_scheme_path
    if grep -q "color_scheme_path=" "$QT6CT_MAIN_CONF"; then
        sed -i "s|color_scheme_path=.*|color_scheme_path=$QT_CONF_FILE|" "$QT6CT_MAIN_CONF"
    else
        sed -i "/\[Appearance\]/a color_scheme_path=$QT_CONF_FILE" "$QT6CT_MAIN_CONF"
    fi
    
    # Ensure custom style is selected (crucial for colors to apply)
    if ! grep -q "style=" "$QT6CT_MAIN_CONF"; then
        sed -i "/\[Appearance\]/a style=Fusion" "$QT6CT_MAIN_CONF"
    else
        # Only set to Fusion if color scheme is used (Fusion is standard for custom colors)
        sed -i "s|style=.*|style=Fusion|" "$QT6CT_MAIN_CONF"
    fi
fi

# --- 3. Update Environment (Best Effort) ---
# Most Qt apps need a restart, but we can try to hint
echo "Qt6ct Theme sync completed for $THEME_ID"
