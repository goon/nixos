#!/usr/bin/env bash
# scripts/obsidian.sh
# Quickshell Hook: Updates Obsidian themes via CSS snippets
# Args: $1 = theme_id, $2 = absolute_theme_path

THEME_PATH="$2"
ASSETS_DIR=$(dirname "$THEME_PATH")
TEMPLATE_FILE="$ASSETS_DIR/obsidian.css"
COLORS_FILE="$THEME_PATH/colors.json"
OBSIDIAN_CONFIG="$HOME/.config/obsidian/obsidian.json"

# Extract Font
FONT="Outfit"
if [ -f "$PREFS_FILE" ]; then
    RAW_FONT=$(grep "\"shellFont\":" "$PREFS_FILE" | sed -E 's/.*:[[:space:]]*"([^"]*)".*/\1/')
    if [ -n "$RAW_FONT" ]; then
        FONT=$(echo "$RAW_FONT" | awk '{
            for(i=1;i<=NF;i++){
                if($i ~ /^(Thin|ExtraLight|Light|Regular|Medium|SemiBold|Bold|ExtraBold|Black|Heavy)$/) break;
                printf "%s%s", $i, (i==NF || $(i+1) ~ /^(Thin|ExtraLight|Light|Regular|Medium|SemiBold|Bold|ExtraBold|Black|Heavy)$/ ? "" : " ")
            }
        }')
    fi
fi

# Use AWK for color loading, HSL math, and substitution
SNIPPET_CONTENT=$(awk -v json_file="$COLORS_FILE" -v font="$FONT" '
    function max(a,b,c) { m=a; if(b>m)m=b; if(c>m)m=c; return m }
    function min(a,b,c) { m=a; if(b<m)m=b; if(c<m)m=c; return m }
    function hex_to_hsl(hex, out) {
        gsub(/^#/, "", hex)
        if (length(hex) == 3) {
            h1 = substr(hex,1,1); h2 = substr(hex,2,1); h3 = substr(hex,3,1)
            hex = h1 h1 h2 h2 h3 h3
        }
        r = strtonum("0x" substr(hex,1,2))/255
        g = strtonum("0x" substr(hex,3,2))/255
        b = strtonum("0x" substr(hex,5,2))/255
        mx = max(r,g,b); mn = min(r,g,b); df = mx - mn
        if (mx == mn) h = 0
        else if (mx == r) h = (60 * ((g-b)/df) + 360) % 360
        else if (mx == g) h = (60 * ((b-r)/df) + 120) % 360
        else if (mx == b) h = (60 * ((r-g)/df) + 240) % 360
        l = (mx + mn) / 2
        if (mx == mn) s = 0
        else if (l <= 0.5) s = df / (mx + mn)
        else s = df / (2 - mx - mn)
        out["h"] = sprintf("%d", h)
        out["s"] = sprintf("%d", s*100)
        out["l"] = sprintf("%d", l*100)
    }
    BEGIN {
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
        if (!colors["surfaceAlt"]) colors["surfaceAlt"] = colors["surface"] ? colors["surface"] : (colors["base"] ? colors["base"] : "#1a1a1a")
        if (!colors["textDim"]) colors["textDim"] = colors["muted"] ? colors["muted"] : "#888888"
        if (!colors["base"]) colors["base"] = colors["background"] ? colors["background"] : "#000000"
        colors["font"] = font; colors["code_font"] = font
        if (colors["primary"]) {
            hex_to_hsl(colors["primary"], hsl)
            colors["primary_h"] = hsl["h"]
            colors["primary_s"] = hsl["s"]
            colors["primary_l"] = hsl["l"]
        }
    }
    {
        line = $0
        for (key in colors) {
            gsub("{{" key "}}", colors[key], line)
        }
        print line
    }
' "$TEMPLATE_FILE")

# Apply to Obsidian Vaults
if [ -f "$OBSIDIAN_CONFIG" ]; then
    # Parse vault paths from obsidian.json using grep/sed
    VAULTS=$(grep "\"path\":" "$OBSIDIAN_CONFIG" | sed -E 's/.*:[[:space:]]*"([^"]*)".*/\1/')
    for vault in $VAULTS; do
        if [ -d "$vault" ]; then
            SNIPPET_DIR="$vault/.obsidian/snippets"
            mkdir -p "$SNIPPET_DIR"
            echo "$SNIPPET_CONTENT" > "$SNIPPET_DIR/quickshell.css"
            
            # Enable snippet in appearance.json if not already enabled
            APP_JSON="$vault/.obsidian/appearance.json"
            if [ -f "$APP_JSON" ]; then
                if ! grep -q "\"quickshell\"" "$APP_JSON"; then
                    # Simple injection into enabledSnippets array using sed
                    if grep -q "\"enabledSnippets\":" "$APP_JSON"; then
                        sed -i 's/"enabledSnippets":[[:space:]]*\[/"enabledSnippets": ["quickshell", /' "$APP_JSON"
                    else
                        # If enabledSnippets doesn't exist, append it (assuming simple JSON)
                        sed -i 's/}$/, "enabledSnippets": ["quickshell"]}/' "$APP_JSON"
                    fi
                fi
            else
                echo '{"enabledSnippets": ["quickshell"]}' > "$APP_JSON"
            fi
        fi
    done
fi
