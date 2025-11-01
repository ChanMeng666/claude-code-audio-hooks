#!/bin/bash
# Claude Code Audio Hooks - Audio Test Script
# Quick script to test if your audio notification works

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  Claude Code Audio Hooks - Audio Test${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Check if hook script exists
if [ ! -f "$HOME/.claude/hooks/play_audio.sh" ]; then
    echo -e "${RED}✗ Hook script not found!${NC}"
    echo ""
    echo "The hook script should be at: ~/.claude/hooks/play_audio.sh"
    echo ""
    echo "Please run the installer first:"
    echo "  cd ~/claude-code-audio-hooks"
    echo "  ./install.sh"
    echo ""
    exit 1
fi

# Check if audio file exists
AUDIO_FILE="$HOME/claude-code-audio-hooks/audio/hey-chan-please-help-me.mp3"
if [ ! -f "$AUDIO_FILE" ]; then
    echo -e "${RED}✗ Audio file not found!${NC}"
    echo ""
    echo "Expected location: $AUDIO_FILE"
    echo ""
    echo "Make sure the project folder is in your home directory."
    echo ""
    exit 1
fi

echo -e "${GREEN}✓${NC} Found hook script and audio file"
echo ""
echo -e "${BLUE}Playing audio notification...${NC}"
echo ""

# Run the hook script
bash "$HOME/.claude/hooks/play_audio.sh"

echo ""
echo -e "${YELLOW}Did you hear the audio? ${NC}(It should play for about 3 seconds)"
echo ""
echo "If you didn't hear anything, check:"
echo "  1. Your system volume (is it muted?)"
echo "  2. Your speakers are connected and working"
echo "  3. For WSL: PowerShell is available"
echo "  4. For Linux: mpg123 or another audio player is installed"
echo ""
echo "For more troubleshooting help, see README.md"
echo ""
