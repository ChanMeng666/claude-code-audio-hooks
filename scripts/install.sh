#!/bin/bash
# Claude Code Audio Hooks - Enhanced Installation Script v2.0
# Supports multi-hook installation and automatic upgrade from v1.0

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Version
VERSION="2.0.0"

# Directories
CURRENT_USER=$(whoami)
HOME_DIR="$HOME"
CLAUDE_DIR="$HOME_DIR/.claude"
HOOKS_DIR="$CLAUDE_DIR/hooks"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"
SETTINGS_LOCAL_FILE="$CLAUDE_DIR/settings.local.json"

# Get project directory (go up one level from scripts/)
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG_DIR="$PROJECT_DIR/config"
AUDIO_DIR="$PROJECT_DIR/audio"

# Hook scripts to install
HOOK_SCRIPTS=(
    "notification_hook.sh"
    "stop_hook.sh"
    "pretooluse_hook.sh"
    "posttooluse_hook.sh"
    "userprompt_hook.sh"
    "subagent_hook.sh"
    "precompact_hook.sh"
    "session_start_hook.sh"
    "session_end_hook.sh"
)

# Hook event names (matching Claude Code hook events)
HOOK_EVENTS=(
    "Notification"
    "Stop"
    "PreToolUse"
    "PostToolUse"
    "UserPromptSubmit"
    "SubagentStop"
    "PreCompact"
    "SessionStart"
    "SessionEnd"
)

#=============================================================================
# HELPER FUNCTIONS
#=============================================================================

print_header() {
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}${BOLD}  Claude Code Audio Hooks v${VERSION}${NC}"
    echo -e "${BLUE}  Installation / Upgrade${NC}"
    echo -e "${BLUE}================================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo -e "${CYAN}ℹ${NC} $1"
}

#=============================================================================
# DETECTION FUNCTIONS
#=============================================================================

detect_v1_installation() {
    # Check if v1.0 is installed (old play_audio.sh in hooks/)
    if [ -f "$HOOKS_DIR/play_audio.sh" ]; then
        # Check if it's the old single-file hook (not our new hook system)
        if ! grep -q "hook_config.sh" "$HOOKS_DIR/play_audio.sh" 2>/dev/null; then
            return 0  # v1.0 detected
        fi
    fi
    return 1  # Not v1.0
}

#=============================================================================
# UPGRADE FROM V1.0
#=============================================================================

upgrade_from_v1() {
    echo -e "\n${YELLOW}${BOLD}Upgrade from v1.0 detected!${NC}"
    echo -e "${CYAN}Upgrading to v2.0 with multi-hook support...${NC}\n"

    # Backup old hook script
    if [ -f "$HOOKS_DIR/play_audio.sh" ]; then
        local backup_file="$HOOKS_DIR/play_audio.sh.v1.backup.$(date +%Y%m%d_%H%M%S)"
        mv "$HOOKS_DIR/play_audio.sh" "$backup_file"
        print_info "Old hook script backed up to: $backup_file"
    fi

    # Preserve user's custom audio if it exists
    local old_audio="$PROJECT_DIR/audio/hey-chan-please-help-me.mp3"
    if [ -f "$old_audio" ]; then
        print_info "Preserving your custom audio file"
        # It's already in legacy directory from our restructuring
    fi

    print_success "Upgrade preparation complete"
    echo ""
}

#=============================================================================
# PRE-INSTALLATION CHECKS
#=============================================================================

check_prerequisites() {
    echo -e "${BLUE}${BOLD}Checking prerequisites...${NC}\n"

    # Check if Claude Code is installed
    if [ ! -d "$CLAUDE_DIR" ]; then
        print_error "Claude Code directory not found at $CLAUDE_DIR"
        echo -e "${YELLOW}Please install Claude Code first: https://claude.ai/download${NC}"
        exit 1
    fi
    print_success "Claude Code directory found"

    # Check Python 3 (needed for JSON manipulation)
    if ! command -v python3 &> /dev/null; then
        print_error "Python 3 is required but not found"
        echo -e "${YELLOW}Please install Python 3: sudo apt-get install python3${NC}"
        exit 1
    fi
    print_success "Python 3 is available"

    # Check if project directory structure is correct
    if [ ! -d "$PROJECT_DIR/hooks" ] || [ ! -d "$PROJECT_DIR/audio" ]; then
        print_error "Project directory structure is invalid"
        echo -e "${YELLOW}Please ensure you're running this from the correct project directory${NC}"
        exit 1
    fi
    print_success "Project directory structure validated"

    echo ""
}

#=============================================================================
# INSTALLATION FUNCTIONS
#=============================================================================

install_hook_scripts() {
    echo -e "${BLUE}${BOLD}Installing hook scripts...${NC}\n"

    # Create hooks directory
    mkdir -p "$HOOKS_DIR"
    print_success "Hooks directory ready: $HOOKS_DIR"

    # Record project path for hook scripts to find audio and config files
    echo -e "${CYAN}Recording project path...${NC}"
    echo "$PROJECT_DIR" > "$HOOKS_DIR/.project_path"
    print_success "Project path recorded: $PROJECT_DIR"

    # Install shared configuration library
    echo -e "${CYAN}Installing shared configuration library...${NC}"
    mkdir -p "$HOOKS_DIR/shared"
    cp "$PROJECT_DIR/hooks/shared/hook_config.sh" "$HOOKS_DIR/shared/"
    chmod +x "$HOOKS_DIR/shared/hook_config.sh"
    print_success "Shared library installed"

    # Install all hook scripts
    echo -e "${CYAN}Installing hook scripts...${NC}"
    local installed=0
    for script in "${HOOK_SCRIPTS[@]}"; do
        if [ -f "$PROJECT_DIR/hooks/$script" ]; then
            cp "$PROJECT_DIR/hooks/$script" "$HOOKS_DIR/"
            chmod +x "$HOOKS_DIR/$script"
            ((installed++))
        else
            print_warning "Hook script not found: $script"
        fi
    done

    print_success "Installed $installed hook scripts"

    # Create necessary temporary directories for hook operation
    echo -e "${CYAN}Creating temporary directories...${NC}"
    mkdir -p /tmp/claude_audio_hooks_queue 2>/dev/null || true
    mkdir -p /tmp/claude_hooks_log 2>/dev/null || true
    print_success "Temporary directories created (queue and log)"

    echo ""
}

install_configuration() {
    echo -e "${BLUE}${BOLD}Installing configuration files...${NC}\n"

    # Check if user already has a configuration
    if [ -f "$CONFIG_DIR/user_preferences.json" ]; then
        print_info "User configuration already exists, keeping it"
    else
        print_warning "No user configuration found, using default configuration"
    fi

    print_success "Configuration files ready"
    echo ""
}

verify_audio_files() {
    echo -e "${BLUE}${BOLD}Verifying audio files...${NC}\n"

    local audio_count=0
    local missing_count=0

    for audio_file in "$AUDIO_DIR/default"/*.mp3; do
        if [ -f "$audio_file" ]; then
            ((audio_count++))
        else
            ((missing_count++))
        fi
    done

    print_success "Found $audio_count audio files in $AUDIO_DIR/default/"

    if [ $audio_count -lt 9 ]; then
        print_warning "Some audio files are missing (expected 9, found $audio_count)"
        print_info "See docs/AUDIO_CREATION.md for instructions on creating audio files"
    fi

    # Check if task-complete.mp3 exists (most important)
    if [ -f "$AUDIO_DIR/default/task-complete.mp3" ]; then
        print_success "Default task completion audio is ready"
    else
        print_error "Critical: task-complete.mp3 not found!"
    fi

    echo ""
}

update_claude_settings() {
    echo -e "${BLUE}${BOLD}Configuring Claude Code settings...${NC}\n"

    # Backup existing settings
    if [ -f "$SETTINGS_FILE" ]; then
        local backup_file="$SETTINGS_FILE.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$SETTINGS_FILE" "$backup_file"
        print_success "Settings backed up to: $(basename $backup_file)"
    fi

    # Use Python to update settings.json with all hooks
    python3 << 'PYTHON_SCRIPT'
import json
import sys
import os

settings_file = os.path.expanduser("~/.claude/settings.json")
hooks_dir = os.path.expanduser("~/.claude/hooks")

# Load existing settings or create new
try:
    with open(settings_file, 'r') as f:
        settings = json.load(f)
except:
    settings = {
        "$schema": "https://json.schemastore.org/claude-code-settings.json"
    }

# Ensure hooks section exists
if 'hooks' not in settings:
    settings['hooks'] = {}

# Hook configurations
hooks_config = {
    "Notification": "notification_hook.sh",
    "Stop": "stop_hook.sh",
    "PreToolUse": "pretooluse_hook.sh",
    "PostToolUse": "posttooluse_hook.sh",
    "UserPromptSubmit": "userprompt_hook.sh",
    "SubagentStop": "subagent_hook.sh",
    "PreCompact": "precompact_hook.sh",
    "SessionStart": "session_start_hook.sh",
    "SessionEnd": "session_end_hook.sh"
}

# Add/update each hook
for event_name, script_name in hooks_config.items():
    hook_command = f"{hooks_dir}/{script_name}"

    # Initialize event array if it doesn't exist
    if event_name not in settings['hooks']:
        settings['hooks'][event_name] = []

    # Check if hook already exists
    hook_exists = False
    for hook_entry in settings['hooks'][event_name]:
        if 'hooks' in hook_entry:
            for h in hook_entry['hooks']:
                if h.get('command') == hook_command:
                    hook_exists = True
                    break

    # Add hook if it doesn't exist
    if not hook_exists:
        settings['hooks'][event_name].append({
            "matcher": "",
            "hooks": [
                {
                    "type": "command",
                    "command": hook_command
                }
            ]
        })

# Write settings back
with open(settings_file, 'w') as f:
    json.dump(settings, f, indent=2)

print("settings.json updated successfully")
PYTHON_SCRIPT

    print_success "settings.json configured with all hooks"
    echo ""
}

update_permissions() {
    echo -e "${BLUE}${BOLD}Configuring permissions...${NC}\n"

    # Use Python to update settings.local.json
    python3 << 'PYTHON_SCRIPT'
import json
import sys
import os

settings_local_file = os.path.expanduser("~/.claude/settings.local.json")

# Load existing settings or create new
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

# Hook scripts to grant permission
hook_scripts = [
    "notification_hook.sh",
    "stop_hook.sh",
    "pretooluse_hook.sh",
    "posttooluse_hook.sh",
    "userprompt_hook.sh",
    "subagent_hook.sh",
    "precompact_hook.sh",
    "session_start_hook.sh",
    "session_end_hook.sh"
]

# Add permissions for all hook scripts
for script in hook_scripts:
    permission = f"Bash(~/.claude/hooks/{script})"
    if permission not in settings['permissions']['allow']:
        settings['permissions']['allow'].append(permission)

# Write settings back
with open(settings_local_file, 'w') as f:
    json.dump(settings, f, indent=2)

print("settings.local.json updated successfully")
PYTHON_SCRIPT

    print_success "Permissions configured for all hooks"
    echo ""
}

#=============================================================================
# SUMMARY AND NEXT STEPS
#=============================================================================

print_summary() {
    echo -e "\n${GREEN}${BOLD}================================================${NC}"
    echo -e "${GREEN}${BOLD}  Installation Complete! 🎉${NC}"
    echo -e "${GREEN}${BOLD}================================================${NC}\n"

    echo -e "${CYAN}${BOLD}📝 Installation Summary:${NC}"
    echo -e "   ${BOLD}Version:${NC} $VERSION"
    echo -e "   ${BOLD}Hook Scripts:${NC} 9 scripts installed"
    echo -e "   ${BOLD}Audio Files:${NC} $AUDIO_DIR/default/"
    echo -e "   ${BOLD}Configuration:${NC} $CONFIG_DIR/user_preferences.json"
    echo -e "   ${BOLD}Claude Settings:${NC} $SETTINGS_FILE"
    echo -e "   ${BOLD}Permissions:${NC} $SETTINGS_LOCAL_FILE"
    echo ""

    echo -e "${CYAN}${BOLD}🎵 Enabled by Default:${NC}"
    echo -e "   ✓ ${GREEN}Notification${NC} - Authorization/confirmation requests"
    echo -e "   ✓ ${GREEN}Stop${NC} - Task completion"
    echo -e "   ✓ ${GREEN}SubagentStop${NC} - Background task completion"
    echo ""

    echo -e "${CYAN}${BOLD}📚 Next Steps:${NC}"
    echo -e "   ${BOLD}1.${NC} ${YELLOW}IMPORTANT: Restart Claude Code${NC} to apply changes"
    echo -e "   ${BOLD}2.${NC} Test the hooks by running any Claude Code command"
    echo -e "   ${BOLD}3.${NC} You should hear audio notifications!"
    echo ""

    echo -e "${CYAN}${BOLD}🎨 Customization Options:${NC}"
    echo -e "   • Run ${BOLD}bash scripts/configure.sh${NC} for interactive configuration"
    echo -e "   • Run ${BOLD}bash scripts/test-audio.sh${NC} to test all audio files"
    echo -e "   • See ${BOLD}docs/AUDIO_CREATION.md${NC} to create custom audio files"
    echo -e "   • See ${BOLD}docs/CONFIGURATION.md${NC} for advanced configuration"
    echo ""

    echo -e "${YELLOW}${BOLD}⚠️  Important Reminders:${NC}"
    echo -e "   • Keep the project folder at: ${BOLD}$PROJECT_DIR${NC}"
    echo -e "   • Some audio files are placeholders - replace them for best experience"
    echo -e "   • See ${BOLD}audio/README.md${NC} for audio file instructions"
    echo ""

    echo -e "${CYAN}${BOLD}📖 Documentation:${NC}"
    echo -e "   • README.md - Main documentation"
    echo -e "   • docs/HOOKS_GUIDE.md - Detailed hook explanations"
    echo -e "   • docs/CONFIGURATION.md - Configuration guide"
    echo -e "   • docs/AUDIO_CREATION.md - Audio file creation guide"
    echo ""

    echo -e "${GREEN}${BOLD}Enjoy your enhanced Claude Code experience! 🚀${NC}\n"
}

#=============================================================================
# MAIN INSTALLATION FLOW
#=============================================================================

main() {
    print_header

    # Check prerequisites
    check_prerequisites

    # Detect and handle v1.0 upgrade
    if detect_v1_installation; then
        upgrade_from_v1
    else
        print_info "Performing fresh installation\n"
    fi

    # Installation steps
    install_hook_scripts
    install_configuration
    verify_audio_files
    update_claude_settings
    update_permissions

    # Show summary
    print_summary
}

# Run main installation
main
