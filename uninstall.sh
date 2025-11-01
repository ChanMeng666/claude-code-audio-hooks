#!/bin/bash
# Claude Code Audio Hooks - Uninstallation Script
# This script removes the audio notification hook from Claude Code

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

HOME_DIR="$HOME"
CLAUDE_DIR="$HOME_DIR/.claude"
HOOKS_DIR="$CLAUDE_DIR/hooks"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"
SETTINGS_LOCAL_FILE="$CLAUDE_DIR/settings.local.json"

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  Claude Code Audio Hooks Uninstallation${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Ask for confirmation
read -p "Are you sure you want to uninstall Claude Code Audio Hooks? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Uninstallation cancelled.${NC}"
    exit 0
fi

# Remove hook script
if [ -f "$HOOKS_DIR/play_audio.sh" ]; then
    rm "$HOOKS_DIR/play_audio.sh"
    echo -e "${GREEN}✓${NC} Removed hook script"
else
    echo -e "${YELLOW}⚠${NC} Hook script not found (already removed?)"
fi

# Ask about audio file
echo ""
read -p "Do you want to remove the audio file ($HOME_DIR/hey-chan-please-help-me.mp3)? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ -f "$HOME_DIR/hey-chan-please-help-me.mp3" ]; then
        rm "$HOME_DIR/hey-chan-please-help-me.mp3"
        echo -e "${GREEN}✓${NC} Removed audio file"
    else
        echo -e "${YELLOW}⚠${NC} Audio file not found"
    fi
fi

# Remove hook configuration from settings.json
echo -e "\n${BLUE}Removing hook configuration...${NC}"
if [ -f "$SETTINGS_FILE" ]; then
    # Backup before modifying
    BACKUP_FILE="$SETTINGS_FILE.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$SETTINGS_FILE" "$BACKUP_FILE"
    echo -e "${GREEN}✓${NC} Settings backed up: $BACKUP_FILE"

    # Remove hook using Python
    python3 << EOF
import json

settings_file = "$SETTINGS_FILE"

try:
    with open(settings_file, 'r') as f:
        settings = json.load(f)

    # Remove our hook from Stop hooks
    if 'hooks' in settings and 'Stop' in settings['hooks']:
        hook_command = "$HOOKS_DIR/play_audio.sh"
        settings['hooks']['Stop'] = [
            stop_hook for stop_hook in settings['hooks']['Stop']
            if not any(
                h.get('command') == hook_command
                for h in stop_hook.get('hooks', [])
            )
        ]

        # Clean up empty Stop array
        if not settings['hooks']['Stop']:
            del settings['hooks']['Stop']

        # Clean up empty hooks object
        if not settings['hooks']:
            del settings['hooks']

    # Write back to file
    with open(settings_file, 'w') as f:
        json.dump(settings, f, indent=2)

    print("Hook configuration removed from settings.json")
except Exception as e:
    print(f"Error updating settings.json: {e}")
EOF
    echo -e "${GREEN}✓${NC} Hook configuration removed from settings.json"
fi

# Remove permission from settings.local.json
echo -e "\n${BLUE}Removing permissions...${NC}"
if [ -f "$SETTINGS_LOCAL_FILE" ]; then
    python3 << EOF
import json

settings_local_file = "$SETTINGS_LOCAL_FILE"

try:
    with open(settings_local_file, 'r') as f:
        settings = json.load(f)

    # Remove permission
    if 'permissions' in settings and 'allow' in settings['permissions']:
        permission = "Bash(~/.claude/hooks/play_audio.sh)"
        if permission in settings['permissions']['allow']:
            settings['permissions']['allow'].remove(permission)

    # Write back to file
    with open(settings_local_file, 'w') as f:
        json.dump(settings, f, indent=2)

    print("Permission removed from settings.local.json")
except Exception as e:
    print(f"Error updating settings.local.json: {e}")
EOF
    echo -e "${GREEN}✓${NC} Permission removed from settings.local.json"
fi

# Final message
echo -e "\n${GREEN}================================================${NC}"
echo -e "${GREEN}  Uninstallation Complete! ${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""
echo -e "📝 ${BLUE}What was removed:${NC}"
echo -e "   • Hook script from $HOOKS_DIR/"
echo -e "   • Hook configuration from settings.json"
echo -e "   • Permission from settings.local.json"
echo ""
echo -e "💾 ${BLUE}Backup files created:${NC}"
echo -e "   • Check $CLAUDE_DIR/ for .backup files"
echo ""
echo -e "${YELLOW}⚠️  Please restart Claude Code to apply changes.${NC}"
echo ""
