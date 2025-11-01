#!/bin/bash
# Claude Code Audio Hooks - Installation Script
# This script installs the audio notification hook for Claude Code

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get current user and home directory
CURRENT_USER=$(whoami)
HOME_DIR="$HOME"
CLAUDE_DIR="$HOME_DIR/.claude"
HOOKS_DIR="$CLAUDE_DIR/hooks"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"
SETTINGS_LOCAL_FILE="$CLAUDE_DIR/settings.local.json"

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  Claude Code Audio Hooks Installation${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Check if Claude Code is installed
if [ ! -d "$CLAUDE_DIR" ]; then
    echo -e "${RED}Error: Claude Code directory not found at $CLAUDE_DIR${NC}"
    echo -e "${YELLOW}Please install Claude Code first.${NC}"
    exit 1
fi

echo -e "${GREEN}✓${NC} Claude Code directory found"

# Create hooks directory if it doesn't exist
mkdir -p "$HOOKS_DIR"
echo -e "${GREEN}✓${NC} Hooks directory ready: $HOOKS_DIR"

# Copy hook script
echo -e "\n${BLUE}Installing hook script...${NC}"
cp hooks/play_audio.sh "$HOOKS_DIR/"
chmod +x "$HOOKS_DIR/play_audio.sh"

# Update the path in the hook script
sed -i "s|/home/chanmeng|$HOME_DIR|g" "$HOOKS_DIR/play_audio.sh"
echo -e "${GREEN}✓${NC} Hook script installed and configured"

# Copy audio file
echo -e "\n${BLUE}Installing audio file...${NC}"
cp audio/hey-chan-please-help-me.mp3 "$HOME_DIR/"
echo -e "${GREEN}✓${NC} Audio file installed: $HOME_DIR/hey-chan-please-help-me.mp3"

# Backup existing settings
if [ -f "$SETTINGS_FILE" ]; then
    BACKUP_FILE="$SETTINGS_FILE.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$SETTINGS_FILE" "$BACKUP_FILE"
    echo -e "${GREEN}✓${NC} Existing settings backed up: $BACKUP_FILE"
fi

# Update settings.json
echo -e "\n${BLUE}Configuring Claude Code settings...${NC}"

# Check if settings.json exists
if [ ! -f "$SETTINGS_FILE" ]; then
    echo -e "${YELLOW}Creating new settings.json...${NC}"
    cat > "$SETTINGS_FILE" << EOF
{
  "\$schema": "https://json.schemastore.org/claude-code-settings.json",
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "$HOOKS_DIR/play_audio.sh"
          }
        ]
      }
    ]
  }
}
EOF
else
    # If settings.json exists, we need to merge the hooks configuration
    echo -e "${YELLOW}Updating existing settings.json...${NC}"
    # Use Python to merge JSON (more reliable than jq for complex merging)
    python3 << EOF
import json
import sys

settings_file = "$SETTINGS_FILE"

try:
    with open(settings_file, 'r') as f:
        settings = json.load(f)
except:
    settings = {}

# Add hooks configuration
if 'hooks' not in settings:
    settings['hooks'] = {}

if 'Stop' not in settings['hooks']:
    settings['hooks']['Stop'] = []

# Check if our hook already exists
hook_exists = False
hook_command = "$HOOKS_DIR/play_audio.sh"
for stop_hook in settings['hooks']['Stop']:
    if 'hooks' in stop_hook:
        for h in stop_hook['hooks']:
            if h.get('command') == hook_command:
                hook_exists = True
                break

# Add our hook if it doesn't exist
if not hook_exists:
    settings['hooks']['Stop'].append({
        "matcher": "",
        "hooks": [
            {
                "type": "command",
                "command": hook_command
            }
        ]
    })

# Write back to file
with open(settings_file, 'w') as f:
    json.dump(settings, f, indent=2)

print("Settings updated successfully")
EOF
fi

echo -e "${GREEN}✓${NC} settings.json configured"

# Update settings.local.json for permissions
echo -e "\n${BLUE}Configuring permissions...${NC}"

if [ ! -f "$SETTINGS_LOCAL_FILE" ]; then
    echo -e "${YELLOW}Creating new settings.local.json...${NC}"
    cat > "$SETTINGS_LOCAL_FILE" << EOF
{
  "permissions": {
    "allow": [
      "Bash(~/.claude/hooks/play_audio.sh)"
    ],
    "deny": []
  }
}
EOF
else
    # If settings.local.json exists, add permission if not already present
    echo -e "${YELLOW}Updating existing settings.local.json...${NC}"
    python3 << EOF
import json

settings_local_file = "$SETTINGS_LOCAL_FILE"

try:
    with open(settings_local_file, 'r') as f:
        settings = json.load(f)
except:
    settings = {}

# Ensure permissions structure exists
if 'permissions' not in settings:
    settings['permissions'] = {}

if 'allow' not in settings['permissions']:
    settings['permissions']['allow'] = []

if 'deny' not in settings['permissions']:
    settings['permissions']['deny'] = []

# Add permission if it doesn't exist
permission = "Bash(~/.claude/hooks/play_audio.sh)"
if permission not in settings['permissions']['allow']:
    settings['permissions']['allow'].append(permission)

# Write back to file
with open(settings_local_file, 'w') as f:
    json.dump(settings, f, indent=2)

print("Permissions updated successfully")
EOF
fi

echo -e "${GREEN}✓${NC} settings.local.json configured"

# Final message
echo -e "\n${GREEN}================================================${NC}"
echo -e "${GREEN}  Installation Complete! ${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""
echo -e "📝 ${BLUE}Installation Summary:${NC}"
echo -e "   • Hook script: $HOOKS_DIR/play_audio.sh"
echo -e "   • Audio file: $HOME_DIR/hey-chan-please-help-me.mp3"
echo -e "   • Settings: $SETTINGS_FILE"
echo -e "   • Permissions: $SETTINGS_LOCAL_FILE"
echo ""
echo -e "🎵 ${BLUE}Next Steps:${NC}"
echo -e "   1. Restart Claude Code to apply changes"
echo -e "   2. Test the hook by running any Claude Code command"
echo -e "   3. You should hear audio when Claude finishes responding"
echo ""
echo -e "🎨 ${BLUE}Customization:${NC}"
echo -e "   • Replace $HOME_DIR/hey-chan-please-help-me.mp3 with your own audio"
echo -e "   • Edit $HOOKS_DIR/play_audio.sh to change audio file path"
echo ""
echo -e "${YELLOW}⚠️  Important: Please restart Claude Code now!${NC}"
echo ""
