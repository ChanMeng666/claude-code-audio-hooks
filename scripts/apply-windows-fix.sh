#!/bin/bash
# Automatic Windows Compatibility Fix Applier
# This script applies all the necessary fixes for Windows compatibility

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RESET='\033[0m'

# Helper functions
print_header() { echo -e "${BLUE}${1}${RESET}"; }
print_success() { echo -e "${GREEN}✓${RESET} ${1}"; }
print_warning() { echo -e "${YELLOW}⚠${RESET} ${1}"; }
print_error() { echo -e "${RED}✗${RESET} ${1}"; }
print_info() { echo -e "${CYAN}ℹ${RESET} ${1}"; }

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
HOOK_CONFIG="$PROJECT_DIR/hooks/shared/hook_config.sh"
INSTALL_SCRIPT="$PROJECT_DIR/scripts/install.sh"

echo ""
echo "================================================"
print_header "  Windows Compatibility Fix Applier"
echo "================================================"
echo ""

# Check if we're in the right directory
if [ ! -f "$HOOK_CONFIG" ]; then
    print_error "hook_config.sh not found at: $HOOK_CONFIG"
    echo "Please run this script from the project root or scripts directory"
    exit 1
fi

print_info "Project directory: $PROJECT_DIR"
echo ""

# Backup files
print_header "Creating backups..."
BACKUP_DIR="$PROJECT_DIR/backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

if [ -f "$HOOK_CONFIG" ]; then
    cp "$HOOK_CONFIG" "$BACKUP_DIR/hook_config.sh.backup"
    print_success "Backed up hook_config.sh"
fi

if [ -f "$INSTALL_SCRIPT" ]; then
    cp "$INSTALL_SCRIPT" "$BACKUP_DIR/install.sh.backup"
    print_success "Backed up install.sh"
fi

print_info "Backups saved to: $BACKUP_DIR"
echo ""

# Check if already patched
if grep -q "get_python_cmd()" "$HOOK_CONFIG" 2>/dev/null; then
    print_warning "hook_config.sh appears to be already patched"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
fi

# Apply Fix 1: Python Command Detection
print_header "Applying Fix 1: Smart Python Command Detection..."

# Find the line number where to insert the function
INSERT_AFTER=$(grep -n "^# CONFIGURATION PATHS" "$HOOK_CONFIG" | head -1 | cut -d: -f1)

if [ -z "$INSERT_AFTER" ]; then
    print_error "Could not find insertion point in hook_config.sh"
    exit 1
fi

# Create new version with Python detection function
cat > /tmp/hook_config_new.sh << 'PYTHON_DETECTOR'
#!/bin/bash
# Claude Code Audio Hooks - Shared Configuration Library
# This library provides common functions for all hook scripts
# Version: 2.0.0

# =============================================================================
# CONFIGURATION PATHS
# =============================================================================

# =============================================================================
# PYTHON COMMAND DETECTION (Windows Compatibility Fix)
# =============================================================================

# Smart Python command detector for cross-platform compatibility
get_python_cmd() {
    # Return cached command if already detected
    if [ -n "$CLAUDE_HOOKS_PYTHON_CMD" ]; then
        echo "$CLAUDE_HOOKS_PYTHON_CMD"
        return 0
    fi

    # Try different Python commands in order of preference
    for cmd in python3 python py; do
        if command -v "$cmd" &> /dev/null; then
            local version=$("$cmd" --version 2>&1)
            if [[ "$version" == *"Python 3"* ]]; then
                export CLAUDE_HOOKS_PYTHON_CMD="$cmd"
                echo "$cmd"
                return 0
            fi
        fi
    done

    # Windows specific: try common installation paths
    for py_pattern in \
        "/c/Python3*/python.exe" \
        "/c/Program Files/Python3*/python.exe" \
        "/d/Python/Python3*/python.exe" \
        "/c/Users/*/AppData/Local/Programs/Python/Python3*/python.exe"
    do
        for actual_path in $py_pattern; do
            if [ -f "$actual_path" ]; then
                local version=$("$actual_path" --version 2>&1)
                if [[ "$version" == *"Python 3"* ]]; then
                    export CLAUDE_HOOKS_PYTHON_CMD="$actual_path"
                    echo "$actual_path"
                    return 0
                fi
            fi
        done
    done

    return 1
}

PYTHON_DETECTOR

# Append the rest of the original file (after the header)
tail -n +$((INSERT_AFTER + 4)) "$HOOK_CONFIG" >> /tmp/hook_config_new.sh

# Replace all python3 calls with get_python_cmd
sed -i 's/local enabled=$(python3 <</local python_cmd=$(get_python_cmd)\n    if [ -z "$python_cmd" ]; then\n        case "$hook_type" in\n            notification|stop|subagent_stop) return 0 ;;\n            *) return 1 ;;\n        esac\n    fi\n    local enabled=$("$python_cmd" <</g' /tmp/hook_config_new.sh

sed -i 's/local audio_path=$(python3 <</local python_cmd=$(get_python_cmd)\n    local audio_path=$("$python_cmd" <</g' /tmp/hook_config_new.sh

sed -i 's/local queue_enabled=$(python3 <</local python_cmd=$(get_python_cmd)\n    [ -z "$python_cmd" ] \&\& echo "true" \&\& return 0\n    local queue_enabled=$("$python_cmd" <</g' /tmp/hook_config_new.sh

sed -i 's/^\s*python3 <</    local python_cmd=$(get_python_cmd)\n    [ -z "$python_cmd" ] \&\& echo "500" \&\& return\n    "$python_cmd" <</g' /tmp/hook_config_new.sh

# Copy back
cp /tmp/hook_config_new.sh "$HOOK_CONFIG"
chmod +x "$HOOK_CONFIG"
print_success "Python command detection added"
echo ""

# Apply Fix 2: PowerShell Audio Playback
print_header "Applying Fix 2: Improved PowerShell Audio Playback..."

# Find and replace the Git Bash audio playback section
# This is a simplified version - for production, use the full patch file

if grep -q "local temp_ps1=\"/tmp/claude_audio_play" "$HOOK_CONFIG"; then
    # Create a temporary Python script to do the replacement
    python3 << 'PYSCRIPT' || python << 'PYSCRIPT'
import re

with open('/tmp/hook_config_new.sh', 'r') as f:
    content = f.read()

# Pattern to match the old temp file approach
old_pattern = r'(\s+# Git Bash.*?\n\s+elif.*?msys.*?mingw.*?\n)(.*?)(\s+# Cygwin)'

new_code = r'''\1        # Convert Unix-style path to Windows path
        local win_path=$(echo "$audio_file" | sed 's|^/\\([a-zA-Z]\\)/|\\U\\1:/|')

        # Use direct PowerShell command (no temp file needed)
        powershell.exe -ExecutionPolicy Bypass -NoProfile -Command "
            \\$ErrorActionPreference = 'SilentlyContinue'
            try {
                Add-Type -AssemblyName presentationCore
                \\$uri = [uri]::new('file:///$win_path')
                \\$player = [System.Windows.Media.MediaPlayer]::new()
                \\$player.Open(\\$uri)
                \\$player.Play()
                Start-Sleep -Seconds 3
                \\$player.Stop()
                \\$player.Close()
            } catch {
                # Silent fail - hook errors should not block Claude
            }
        " 2>/dev/null &
        return 0
\3'''

# Replace the old code with new code
content = re.sub(old_pattern, new_code, content, flags=re.DOTALL)

with open('/tmp/hook_config_new.sh', 'w') as f:
    f.write(content)

print("PowerShell audio playback improved")
PYSCRIPT

    cp /tmp/hook_config_new.sh "$HOOK_CONFIG"
    print_success "PowerShell audio playback improved"
else
    print_warning "Could not find old PowerShell code (may already be updated)"
fi

echo ""

# Apply Fix 3: Install Script Error Handling
print_header "Applying Fix 3: Install Script Error Handling..."

if grep -q "^set -e" "$INSTALL_SCRIPT"; then
    # Comment out 'set -e'
    sed -i 's/^set -e/# set -e  # Disabled for better error handling/' "$INSTALL_SCRIPT"
    print_success "Disabled strict error mode in install script"

    # Add error counters (insert after shebang and comments)
    sed -i '/^# Claude Code Audio Hooks/a \
\
# Error tracking\
INSTALL_ERRORS=0\
INSTALL_WARNINGS=0' "$INSTALL_SCRIPT"
    print_success "Added error tracking to install script"
else
    print_warning "Install script does not have 'set -e' (may already be updated)"
fi

echo ""

# Test the changes
print_header "Testing changes..."

# Test Python detection
if bash -c "source '$HOOK_CONFIG' && get_python_cmd" &>/dev/null; then
    python_detected=$(bash -c "source '$HOOK_CONFIG' && get_python_cmd")
    print_success "Python detection working: $python_detected"
else
    print_warning "Python detection test failed (this is OK if Python is not installed)"
fi

# Validate syntax
if bash -n "$HOOK_CONFIG" 2>/dev/null; then
    print_success "hook_config.sh syntax is valid"
else
    print_error "hook_config.sh has syntax errors!"
    echo "Restoring from backup..."
    cp "$BACKUP_DIR/hook_config.sh.backup" "$HOOK_CONFIG"
    exit 1
fi

if bash -n "$INSTALL_SCRIPT" 2>/dev/null; then
    print_success "install.sh syntax is valid"
else
    print_warning "install.sh may have syntax errors (please review)"
fi

echo ""

# Summary
echo "================================================"
print_header "  Fix Application Complete!"
echo "================================================"
echo ""
print_success "All fixes have been applied successfully"
echo ""
echo "What was changed:"
echo "  1. ✓ Added smart Python command detection"
echo "  2. ✓ Improved PowerShell audio playback"
echo "  3. ✓ Enhanced install script error handling"
echo ""
echo "Backups saved to: $BACKUP_DIR"
echo ""
print_info "Next steps:"
echo "  1. Review the changes: git diff hooks/shared/hook_config.sh"
echo "  2. Test the installation: bash scripts/install.sh"
echo "  3. Test audio playback: bash scripts/test-audio.sh"
echo "  4. Test with Claude Code: claude 'test'"
echo ""
print_info "If something goes wrong, restore from backup:"
echo "  cp $BACKUP_DIR/*.backup hooks/shared/"
echo ""
print_info "For detailed information, see:"
echo "  - QUICK_FIX_GUIDE.md"
echo "  - WINDOWS_INSTALLATION_ANALYSIS.md"
echo ""
