#!/bin/bash
# echook - Enhanced Uninstallation Script v3.2
# Removes all hook scripts, configurations, and optionally audio files
# Supports non-interactive mode for Claude Code and automation

set -e

# echook is AI-agent-first: uninstall is always non-interactive and never
# prompts. By default it PRESERVES config and audio (least destructive); pass
# --purge to also remove them.
NON_INTERACTIVE=true
PURGE=false

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Directories
HOME_DIR="$HOME"
CLAUDE_DIR="$HOME_DIR/.claude"
HOOKS_DIR="$CLAUDE_DIR/hooks"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"
SETTINGS_LOCAL_FILE="$CLAUDE_DIR/settings.local.json"
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# Hook scripts to remove
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
    "hook_runner.py"
    ".project_path"
)

# Hook events to remove from settings.json.
# MUST cover every event install-complete.sh can register, or an uninstall
# leaves orphaned registrations behind in settings.json pointing at deleted
# scripts. Guarded by tests/test_legacy_scripts_contract.py.
HOOK_EVENTS=(
    "Notification"
    "Stop"
    "StopFailure"
    "SessionStart"
    "SessionEnd"
    "SubagentStart"
    "SubagentStop"
    "PermissionRequest"
    "PermissionDenied"
    "TaskCreated"
    "TaskCompleted"
    "TeammateIdle"
    "PreToolUse"
    "PostToolUse"
    "PostToolUseFailure"
    "UserPromptSubmit"
    "PreCompact"
    "PostCompact"
    "ConfigChange"
    "InstructionsLoaded"
    "Elicitation"
    "ElicitationResult"
    "CwdChanged"
    "DirectoryAdded"
    "WorktreeRemove"
    "FileChanged"
    "Setup"
    "UserPromptExpansion"
    "PostToolBatch"
    "MessageDisplay"
)

# =============================================================================
# ARGUMENT PROCESSING
# =============================================================================

# Parse command line arguments
while [ $# -gt 0 ]; do
    case "$1" in
        --yes|-y|--non-interactive)
            # Accepted as a no-op for backward compatibility — this script is
            # always non-interactive.
            shift
            ;;
        --purge)
            PURGE=true
            shift
            ;;
        --help|-h)
            cat << EOF
${BOLD}echook - Uninstallation Script (AI-agent-first, always non-interactive)${NC}

${CYAN}USAGE:${NC}
  $0 [OPTIONS]

${CYAN}OPTIONS:${NC}
  ${BOLD}--purge${NC}
    Also remove your config (config/user_preferences.json) and audio files.
    Without it, those are PRESERVED (least-destructive default).

  ${BOLD}--yes, -y, --non-interactive${NC}
    No-op, accepted for backward compatibility. This script never prompts.

  ${BOLD}--help, -h${NC}
    Show this help message

${CYAN}BEHAVIOR:${NC}
  Always runs unattended (no prompts). Removes the registered hooks and
  settings; preserves config + audio unless --purge is given. A backup is
  created before any removal.

${CYAN}EXAMPLES:${NC}
  bash scripts/uninstall.sh            # remove hooks, keep config + audio
  bash scripts/uninstall.sh --purge    # also remove config + audio
  # Prefer the CLI wrapper:  audio-hooks uninstall [--purge]

${YELLOW}Note:${NC} Backups are created in: /tmp/claude_hooks_backup_*
EOF
            exit 0
            ;;
        *)
            echo -e "${RED}Error: Unknown option '$1'${NC}" >&2
            echo "Run '$0 --help' for usage information" >&2
            exit 1
            ;;
    esac
done

# =============================================================================
# MAIN EXECUTION
# =============================================================================

echo -e "${BLUE}${BOLD}================================================${NC}"
echo -e "${BLUE}${BOLD}  echook Uninstallation${NC}"
echo -e "${BLUE}${BOLD}================================================${NC}\n"

# Confirmation
echo -e "${YELLOW}${BOLD}This will remove:${NC}"
echo -e "  • All hook scripts from ${BOLD}~/.claude/hooks/${NC}"
echo -e "  • Shared configuration library"
echo -e "  • Hook configurations from settings.json"
echo -e "  • Permissions from settings.local.json"
echo -e "  • Optionally: audio files and project configuration"
echo ""

echo -e "${GREEN}Uninstalling (non-interactive)...${NC}"
echo ""

#=============================================================================
# BACKUP
#=============================================================================

echo -e "${BLUE}${BOLD}Creating backups...${NC}\n"

BACKUP_DIR="$CLAUDE_DIR/backups/audio-hooks-uninstall-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Backup settings
if [ -f "$SETTINGS_FILE" ]; then
    cp "$SETTINGS_FILE" "$BACKUP_DIR/settings.json.backup"
    echo -e "${GREEN}✓${NC} Backed up settings.json"
fi

if [ -f "$SETTINGS_LOCAL_FILE" ]; then
    cp "$SETTINGS_LOCAL_FILE" "$BACKUP_DIR/settings.local.json.backup"
    echo -e "${GREEN}✓${NC} Backed up settings.local.json"
fi

# Backup hook scripts
if [ -d "$HOOKS_DIR" ]; then
    mkdir -p "$BACKUP_DIR/hooks"
    for script in "${HOOK_SCRIPTS[@]}"; do
        if [ -f "$HOOKS_DIR/$script" ]; then
            cp "$HOOKS_DIR/$script" "$BACKUP_DIR/hooks/"
        fi
    done
    # Backup shared directory
    if [ -d "$HOOKS_DIR/shared" ]; then
        cp -r "$HOOKS_DIR/shared" "$BACKUP_DIR/hooks/"
    fi
    echo -e "${GREEN}✓${NC} Backed up hook scripts"
fi

echo -e "${CYAN}Backups saved to: $BACKUP_DIR${NC}\n"

#=============================================================================
# REMOVE HOOK SCRIPTS
#=============================================================================

echo -e "${BLUE}${BOLD}Removing hook scripts...${NC}\n"

removed=0
for script in "${HOOK_SCRIPTS[@]}"; do
    if [ -f "$HOOKS_DIR/$script" ]; then
        rm "$HOOKS_DIR/$script"
        echo -e "${GREEN}✓${NC} Removed $script"
        ((removed += 1))
    fi
done

# Remove shared directory
if [ -d "$HOOKS_DIR/shared" ]; then
    rm -rf "$HOOKS_DIR/shared"
    echo -e "${GREEN}✓${NC} Removed shared configuration library"
fi

# Also remove old v1.0 hook if it exists
if [ -f "$HOOKS_DIR/play_audio.sh" ]; then
    rm "$HOOKS_DIR/play_audio.sh"
    echo -e "${GREEN}✓${NC} Removed legacy play_audio.sh"
    ((removed += 1))
fi

if [ $removed -gt 0 ]; then
    echo -e "\n${GREEN}✓${NC} Removed $removed hook script(s)"
else
    echo -e "${YELLOW}⚠${NC} No hook scripts found (already removed?)"
fi

echo ""

#=============================================================================
# REMOVE HOOK CONFIGURATIONS
#=============================================================================

echo -e "${BLUE}${BOLD}Removing hook configurations...${NC}\n"

if [ -f "$SETTINGS_FILE" ]; then
    python3 << 'PYTHON_SCRIPT'
import json
import sys
import os

settings_file = os.path.expanduser("~/.claude/settings.json")

try:
    with open(settings_file, 'r') as f:
        settings = json.load(f)

    hooks_dir = os.path.expanduser("~/.claude/hooks")

    # Hook events to remove
    hook_events = [
        "Notification", "Stop", "StopFailure", "SessionStart", "SessionEnd",
        "SubagentStart", "SubagentStop", "PermissionRequest",
        "PermissionDenied", "TaskCreated", "TaskCompleted", "TeammateIdle",
        "PreToolUse", "PostToolUse", "PostToolUseFailure", "UserPromptSubmit",
        "PreCompact", "PostCompact", "ConfigChange", "InstructionsLoaded",
        "Elicitation", "ElicitationResult", "CwdChanged", "DirectoryAdded",
        "WorktreeRemove", "FileChanged",
        "Setup", "UserPromptExpansion", "PostToolBatch", "MessageDisplay",
    ]

    # Hook scripts to look for
    hook_scripts = [
        "notification_hook.sh", "stop_hook.sh", "pretooluse_hook.sh",
        "posttooluse_hook.sh", "userprompt_hook.sh", "subagent_hook.sh",
        "precompact_hook.sh", "session_start_hook.sh", "session_end_hook.sh",
        "play_audio.sh",  # Legacy v1.0
        "hook_runner.py"  # v3.0+ Python runner
    ]

    removed_count = 0

    # Remove hook configurations
    if 'hooks' in settings:
        for event_name in hook_events:
            if event_name in settings['hooks']:
                # Filter out our hooks
                original_len = len(settings['hooks'][event_name])
                settings['hooks'][event_name] = [
                    hook_entry for hook_entry in settings['hooks'][event_name]
                    if not any(
                        script in h.get('command', '')
                        for h in hook_entry.get('hooks', [])
                        for script in hook_scripts
                    )
                ]
                new_len = len(settings['hooks'][event_name])
                removed_count += (original_len - new_len)

                # Remove empty arrays
                if not settings['hooks'][event_name]:
                    del settings['hooks'][event_name]

        # Remove empty hooks object
        if not settings['hooks']:
            del settings['hooks']

    # Write back
    with open(settings_file, 'w') as f:
        json.dump(settings, f, indent=2)

    print(f"✓ Removed {removed_count} hook configuration(s) from settings.json")

except Exception as e:
    print(f"✗ Error updating settings.json: {e}")
    sys.exit(1)
PYTHON_SCRIPT

    echo ""
fi

#=============================================================================
# REMOVE PERMISSIONS
#=============================================================================

echo -e "${BLUE}${BOLD}Removing permissions...${NC}\n"

if [ -f "$SETTINGS_LOCAL_FILE" ]; then
    python3 << 'PYTHON_SCRIPT'
import json
import sys
import os

settings_local_file = os.path.expanduser("~/.claude/settings.local.json")

try:
    with open(settings_local_file, 'r') as f:
        settings = json.load(f)

    # Hook scripts to remove permissions for
    hook_scripts = [
        "notification_hook.sh", "stop_hook.sh", "pretooluse_hook.sh",
        "posttooluse_hook.sh", "userprompt_hook.sh", "subagent_hook.sh",
        "precompact_hook.sh", "session_start_hook.sh", "session_end_hook.sh",
        "play_audio.sh",  # Legacy v1.0
        "hook_runner.py"  # v3.0+ Python runner
    ]

    removed_count = 0

    # Remove permissions
    if 'permissions' in settings and 'allow' in settings['permissions']:
        original_len = len(settings['permissions']['allow'])
        settings['permissions']['allow'] = [
            perm for perm in settings['permissions']['allow']
            if not any(script in perm for script in hook_scripts)
        ]
        new_len = len(settings['permissions']['allow'])
        removed_count = original_len - new_len

    # Write back
    with open(settings_local_file, 'w') as f:
        json.dump(settings, f, indent=2)

    print(f"✓ Removed {removed_count} permission(s) from settings.local.json")

except Exception as e:
    print(f"✗ Error updating settings.local.json: {e}")
    sys.exit(1)
PYTHON_SCRIPT

    echo ""
fi

#=============================================================================
# OPTIONAL: REMOVE CONFIGURATION AND AUDIO FILES
#=============================================================================

echo -e "${BLUE}${BOLD}Optional cleanup:${NC}\n"

# Configuration file: removed only with --purge (default preserves it).
if [ -f "$PROJECT_DIR/config/user_preferences.json" ]; then
    if [ "$PURGE" = true ]; then
        cp "$PROJECT_DIR/config/user_preferences.json" "$BACKUP_DIR/user_preferences.json.backup"
        rm "$PROJECT_DIR/config/user_preferences.json"
        echo -e "${GREEN}✓${NC} Removed configuration file (backed up, --purge)"
    else
        echo -e "${CYAN}ℹ${NC} Preserved configuration file (use --purge to remove)"
    fi
    echo ""
fi

# Audio files: removed only with --purge (default preserves them).
if [ -d "$PROJECT_DIR/audio/default" ]; then
    if [ "$PURGE" = true ]; then
        mkdir -p "$BACKUP_DIR/audio"
        cp -r "$PROJECT_DIR/audio/default" "$BACKUP_DIR/audio/"
        rm -rf "$PROJECT_DIR/audio/default"/*
        echo -e "${GREEN}✓${NC} Removed audio files (backed up, --purge)"
    else
        echo -e "${CYAN}ℹ${NC} Preserved audio files (use --purge to remove)"
    fi
fi

echo ""

#=============================================================================
# CLEANUP QUEUE FILES
#=============================================================================

echo -e "${BLUE}${BOLD}Cleaning up temporary files...${NC}\n"

# Remove lock file and queue directory
_tmp_dir="${TEMP:-${TMP:-/tmp}}"
rm -f "$_tmp_dir/claude_audio_hooks.lock"
rm -rf "$_tmp_dir/claude_audio_hooks_queue"
echo -e "${GREEN}✓${NC} Removed temporary files"

echo ""

#=============================================================================
# SUMMARY
#=============================================================================

echo -e "${GREEN}${BOLD}================================================${NC}"
echo -e "${GREEN}${BOLD}  Uninstallation Complete! ${NC}"
echo -e "${GREEN}${BOLD}================================================${NC}\n"

echo -e "${CYAN}${BOLD}📝 What was removed:${NC}"
echo -e "   • All hook scripts from ${BOLD}~/.claude/hooks/${NC}"
echo -e "   • Shared configuration library"
echo -e "   • Hook configurations from settings.json"
echo -e "   • Permissions from settings.local.json"
echo -e "   • Temporary lock and queue files"
echo ""

echo -e "${CYAN}${BOLD}💾 Backups created:${NC}"
echo -e "   • Location: ${BOLD}$BACKUP_DIR${NC}"
echo -e "   • settings.json backup"
echo -e "   • settings.local.json backup"
echo -e "   • Hook scripts backup"
echo -e "   • Configuration and audio backups (if selected)"
echo ""

echo -e "${CYAN}${BOLD}📦 What remains:${NC}"
echo -e "   • Project directory: ${BOLD}$PROJECT_DIR${NC}"
echo -e "   • You can safely delete the project folder if desired"
echo ""

echo -e "${YELLOW}${BOLD}⚠️  Important:${NC}"
echo -e "   • ${BOLD}Restart Claude Code${NC} to apply changes"
echo -e "   • Backups are in: $BACKUP_DIR"
echo -e "   • To reinstall: run ${BOLD}bash scripts/install.sh${NC}"
echo ""

echo -e "${CYAN}${BOLD}🔄 To reinstall:${NC}"
echo -e "   cd $PROJECT_DIR"
echo -e "   bash scripts/install.sh"
echo ""
