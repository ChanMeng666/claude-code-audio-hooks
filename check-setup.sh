#!/bin/bash
# Claude Code Audio Hooks - Setup Verification Script
# This script checks if everything is installed correctly

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
PASSED=0
FAILED=0
WARNINGS=0

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  Claude Code Audio Hooks - Setup Checker${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""
echo "This script will check if everything is set up correctly."
echo ""

# Function to print check results
check_pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((PASSED++))
}

check_fail() {
    echo -e "${RED}✗${NC} $1"
    ((FAILED++))
}

check_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARNINGS++))
}

# Check 1: Claude Code installed
echo -e "${BLUE}[1/8]${NC} Checking if Claude Code is installed..."
if command -v claude &> /dev/null; then
    CLAUDE_VERSION=$(claude --version 2>&1 | head -1)
    check_pass "Claude Code is installed: $CLAUDE_VERSION"
else
    check_fail "Claude Code is not installed or not in PATH"
    echo "       Install Claude Code from: https://claude.ai/download"
fi
echo ""

# Check 2: Claude configuration directory
echo -e "${BLUE}[2/8]${NC} Checking Claude Code configuration directory..."
if [ -d "$HOME/.claude" ]; then
    check_pass "Claude configuration directory exists: ~/.claude"
else
    check_fail "Claude configuration directory not found"
    echo "       Run Claude Code at least once to create the configuration directory"
fi
echo ""

# Check 3: Hooks directory
echo -e "${BLUE}[3/8]${NC} Checking hooks directory..."
if [ -d "$HOME/.claude/hooks" ]; then
    check_pass "Hooks directory exists: ~/.claude/hooks"
else
    check_warn "Hooks directory doesn't exist yet"
    echo "       This is normal if you haven't run the installer yet"
fi
echo ""

# Check 4: Hook script installed
echo -e "${BLUE}[4/8]${NC} Checking if hook script is installed..."
if [ -f "$HOME/.claude/hooks/play_audio.sh" ]; then
    check_pass "Hook script found: ~/.claude/hooks/play_audio.sh"

    # Check if it's executable
    if [ -x "$HOME/.claude/hooks/play_audio.sh" ]; then
        check_pass "Hook script is executable"
    else
        check_fail "Hook script is not executable"
        echo "       Fix with: chmod +x ~/.claude/hooks/play_audio.sh"
    fi
else
    check_fail "Hook script not found"
    echo "       Run ./install.sh to install the hook"
fi
echo ""

# Check 5: Project directory and audio file
echo -e "${BLUE}[5/8]${NC} Checking project directory and audio file..."
PROJECT_DIR="$HOME/claude-code-audio-hooks"

if [ -d "$PROJECT_DIR" ]; then
    check_pass "Project directory found: $PROJECT_DIR"

    if [ -f "$PROJECT_DIR/audio/hey-chan-please-help-me.mp3" ]; then
        FILE_SIZE=$(du -h "$PROJECT_DIR/audio/hey-chan-please-help-me.mp3" | cut -f1)
        check_pass "Audio file found: hey-chan-please-help-me.mp3 ($FILE_SIZE)"
    else
        check_fail "Audio file not found in project directory"
        echo "       Expected: $PROJECT_DIR/audio/hey-chan-please-help-me.mp3"
    fi
else
    check_warn "Project directory not found at expected location"
    echo "       Expected: $PROJECT_DIR"
    echo "       Make sure you cloned the repo to your home directory"
fi
echo ""

# Check 6: Claude settings.json
echo -e "${BLUE}[6/8]${NC} Checking Claude Code settings..."
SETTINGS_FILE="$HOME/.claude/settings.json"

if [ -f "$SETTINGS_FILE" ]; then
    check_pass "Settings file exists: settings.json"

    # Check if hook is configured
    if grep -q "play_audio.sh" "$SETTINGS_FILE"; then
        check_pass "Hook is configured in settings.json"
    else
        check_fail "Hook not configured in settings.json"
        echo "       Run ./install.sh to configure the hook"
    fi
else
    check_warn "Settings file doesn't exist yet"
    echo "       Run Claude Code at least once, or run ./install.sh"
fi
echo ""

# Check 7: Permissions
echo -e "${BLUE}[7/8]${NC} Checking permissions in settings.local.json..."
SETTINGS_LOCAL_FILE="$HOME/.claude/settings.local.json"

if [ -f "$SETTINGS_LOCAL_FILE" ]; then
    check_pass "Permissions file exists: settings.local.json"

    if grep -q "play_audio.sh" "$SETTINGS_LOCAL_FILE"; then
        check_pass "Hook permission is configured"
    else
        check_warn "Hook permission might not be configured"
        echo "       Run ./install.sh to add the permission"
    fi
else
    check_warn "Permissions file doesn't exist yet"
    echo "       Run ./install.sh to create it with proper permissions"
fi
echo ""

# Check 8: Audio playback capability (WSL check)
echo -e "${BLUE}[8/8]${NC} Checking audio playback capability..."

# Check if running in WSL
if grep -qi microsoft /proc/version 2>/dev/null; then
    check_pass "Running in WSL environment"

    # Check if PowerShell is available
    if command -v powershell.exe &> /dev/null; then
        check_pass "PowerShell is available for audio playback"
    else
        check_fail "PowerShell not found"
        echo "       PowerShell is required for audio playback in WSL"
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    check_pass "Running on macOS"

    # Check if afplay is available
    if command -v afplay &> /dev/null; then
        check_pass "afplay is available for audio playback"
    else
        check_warn "afplay not found (should be included with macOS)"
    fi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    check_pass "Running on Linux"

    # Check for audio players
    if command -v mpg123 &> /dev/null; then
        check_pass "mpg123 is available for audio playback"
    elif command -v aplay &> /dev/null; then
        check_warn "aplay is available (supports WAV files only)"
        echo "       Consider installing mpg123 for MP3 support"
    else
        check_warn "No audio player found"
        echo "       Install mpg123: sudo apt-get install mpg123"
        echo "       Note: Default script uses PowerShell (for WSL)"
    fi
fi
echo ""

# Summary
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  Summary${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""
echo -e "${GREEN}Passed:${NC}   $PASSED checks"
echo -e "${YELLOW}Warnings:${NC} $WARNINGS checks"
echo -e "${RED}Failed:${NC}   $FAILED checks"
echo ""

if [ $FAILED -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}🎉 Everything looks good!${NC}"
    echo ""
    echo "Your setup is complete. Try it out:"
    echo "  1. Restart Claude Code"
    echo "  2. Run any Claude command"
    echo "  3. Listen for the audio notification!"
    echo ""
elif [ $FAILED -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Setup is mostly complete with some warnings${NC}"
    echo ""
    echo "You can try using the hooks now, but you may want to"
    echo "address the warnings above for the best experience."
    echo ""
else
    echo -e "${RED}❌ Some checks failed${NC}"
    echo ""
    echo "Please fix the failed checks above before using the hooks."
    echo "If you need help, check the README or open an issue on GitHub."
    echo ""
fi

# Offer to test audio playback
if [ $FAILED -eq 0 ]; then
    echo -e "${BLUE}Would you like to test audio playback now? (y/N)${NC}"
    read -r -n 1 RESPONSE
    echo ""

    if [[ "$RESPONSE" =~ ^[Yy]$ ]]; then
        echo ""
        echo -e "${BLUE}Testing audio playback...${NC}"

        if [ -f "$HOME/.claude/hooks/play_audio.sh" ]; then
            bash "$HOME/.claude/hooks/play_audio.sh"
            echo ""
            echo "Did you hear the audio? If not, check your system volume"
            echo "and the troubleshooting section in the README."
        else
            echo -e "${RED}Hook script not found. Run ./install.sh first.${NC}"
        fi
    fi
fi

echo ""
echo -e "${BLUE}For more help, see:${NC}"
echo "  • README.md in this directory"
echo "  • https://github.com/ChanMeng666/claude-code-audio-hooks"
echo ""
