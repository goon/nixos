#!/bin/bash

# yet-another-shell Arch Linux Install Script
# Automates dependency checking and installation for Arch Linux.

set -e

# --- Configuration ---
DRY_RUN=false
if [[ "$1" == "--dry-run" ]] || [[ "$1" == "-d" ]]; then
    DRY_RUN=true
    echo -e "${YELLOW}Running in DRY RUN mode. No changes will be made.${NC}\n"
fi

CORE_PKGS=(
    "qt6-base"
    "qt6-declarative"
    "qt6-svg"
    "qt6-wayland"
    "qt6-connectivity"
    "qt6-shadertools"
    "networkmanager"
    "libpulse"
    "pipewire"
    "wireplumber"
    "upower"
    "power-profiles-daemon"
    "util-linux"
    "bluez"
    "bluez-utils"
    "wl-clipboard"
    "ddcutil"
    "libnotify"
    "xdg-utils"
    "pciutils"
    "glib2"
    "mesa-utils"
    "mpv"
)

AUR_PKGS=(
    "quickshell-git"
    "gowall"
)

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== yet-another-shell Installer (Arch Linux) ===${NC}\n"

# 1. System Check
if [ ! -f /etc/arch-release ]; then
    echo -e "${RED}Error: This script only targets Arch Linux.${NC}"
    exit 1
fi

# 2. Check for AUR Helper (Yay)
if ! command -v yay &> /dev/null; then
    echo -e "${RED}Error: 'yay' is not installed. Please install an AUR helper to proceed.${NC}"
    exit 1
fi

# 3. Dependency Assessment
MISSING_CORE=()
MISSING_AUR=()

echo "Checking dependencies..."

for pkg in "${CORE_PKGS[@]}"; do
    if ! pacman -Qi "$pkg" &> /dev/null; then
        MISSING_CORE+=("$pkg")
    fi
done

for pkg in "${AUR_PKGS[@]}"; do
    if ! pacman -Qi "$pkg" &> /dev/null && ! yay -Qi "$pkg" &> /dev/null; then
        MISSING_AUR+=("$pkg")
    fi
done

# 4. Interactive Report
if [ ${#MISSING_CORE[@]} -eq 0 ] && [ ${#MISSING_AUR[@]} -eq 0 ]; then
    echo -e "${GREEN}All dependencies are already installed.${NC}"
else
    echo -e "${YELLOW}The following dependencies are missing:${NC}"
    
    if [ ${#MISSING_CORE[@]} -gt 0 ]; then
        echo -e "\n${BLUE}Core Packages (via pacman):${NC}"
        for pkg in "${MISSING_CORE[@]}"; do
            echo "  - $pkg"
        done
    fi

    if [ ${#MISSING_AUR[@]} -gt 0 ]; then
        echo -e "\n${BLUE}AUR Packages (via yay):${NC}"
        for pkg in "${MISSING_AUR[@]}"; do
            echo "  - $pkg"
        done
    fi

    echo -e "\n"
    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}DRY RUN: Would prompt for installation here.${NC}"
    else
        read -p "Do you want to proceed with installing these dependencies? [y/N] " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            echo "Installation aborted."
            exit 0
        fi
    fi

    # 5. Installation
    if [ ${#MISSING_CORE[@]} -gt 0 ]; then
        if [ "$DRY_RUN" = true ]; then
            echo -e "\n${YELLOW}DRY RUN: sudo pacman -S --needed ${MISSING_CORE[*]}${NC}"
        else
            echo -e "\n${BLUE}Installing core packages...${NC}"
            sudo pacman -S --needed "${MISSING_CORE[@]}"
        fi
    fi

    if [ ${#MISSING_AUR[@]} -gt 0 ]; then
        if [ "$DRY_RUN" = true ]; then
            echo -e "\n${YELLOW}DRY RUN: yay -S --needed ${MISSING_AUR[*]}${NC}"
        else
            echo -e "\n${BLUE}Installing AUR packages...${NC}"
            yay -S --needed "${MISSING_AUR[@]}"
        fi
    fi
fi

# 6. Configuration Check
echo -e "\n${BLUE}Checking configuration...${NC}"
SHELL_DIR="$HOME/.config/quickshell"
if [ ! -d "$SHELL_DIR" ]; then
    echo -e "${YELLOW}Warning: Configuration directory not found at $SHELL_DIR${NC}"
    echo "Make sure your shell configuration is placed correctly."
else
    echo -e "${GREEN}Configuration found at $SHELL_DIR${NC}"
fi

# 7. Final Instructions
echo -e "\n${GREEN}=== Installation Complete ===${NC}"

if [ "$DRY_RUN" = true ]; then
    echo -e "DRY RUN: Would prompt to start/restart the shell now."
    echo -e "Command: ${YELLOW}pkill quickshell; quickshell & disown${NC}"
else
    read -p "Do you want to start/restart the shell now? [y/N] " start_confirm
    if [[ "$start_confirm" =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}Restarting quickshell...${NC}"
        pkill quickshell || true
        quickshell & disown
        echo -e "${GREEN}Shell started in background.${NC}"
    else
        echo -e "\nTo start the shell later, run: ${YELLOW}quickshell & disown${NC}"
        echo -e "To restart the shell later, run: ${YELLOW}pkill quickshell; quickshell & disown${NC}"
    fi
fi
