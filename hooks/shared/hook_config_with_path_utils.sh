#!/bin/bash
# Claude Code Audio Hooks - Shared Configuration Library
# This library provides common functions for all hook scripts
# Version: 2.0.1 - With integrated path utilities

# =============================================================================
# LOAD PATH UTILITIES
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source path utilities if available
if [ -f "$SCRIPT_DIR/path_utils.sh" ]; then
    source "$SCRIPT_DIR/path_utils.sh"
else
    # Fallback: define minimal path conversion function
    to_windows_path() {
        local input_path="$1"
        if [[ "$input_path" =~ ^/([a-zA-Z])/ ]]; then
            local drive="${BASH_REMATCH[1]}"
            local rest="${input_path:3}"
            echo "${drive^^}:/${rest}"
        else
            echo "$input_path"
        fi
    }

    smart_path_convert() {
        local input_path="$1"
        echo "$input_path"
    }
fi

# =============================================================================
# PYTHON COMMAND DETECTION (Windows Compatibility)
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

# =============================================================================
# CONFIGURATION PATHS
# =============================================================================

# Determine project directory (works from any hook script location)
get_project_dir() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local hooks_parent="$(dirname "$script_dir")"

    # Strategy 1: Read from .project_path file (most reliable)
    local project_path_file="$hooks_parent/.project_path"
    if [ -f "$project_path_file" ]; then
        local recorded_path=$(cat "$project_path_file" 2>/dev/null | tr -d '\n\r')
        if [ -d "$recorded_path" ] && [ -f "$recorded_path/config/user_preferences.json" ]; then
            echo "$recorded_path"
            return 0
        fi
    fi

    # Strategy 2: Check if we're in the project directory structure
    local candidate="$(dirname "$hooks_parent")"
    if [ -f "$candidate/config/user_preferences.json" ]; then
        echo "$candidate"
        return 0
    fi

    # Strategy 3: Search common installation locations
    for possible_dir in \
        "$HOME/claude-code-audio-hooks" \
        "$HOME/projects/claude-code-audio-hooks" \
        "$HOME/Documents/claude-code-audio-hooks" \
        "$HOME/repos/claude-code-audio-hooks" \
        "$HOME/git/claude-code-audio-hooks" \
        "$HOME/src/claude-code-audio-hooks"
    do
        if [ -d "$possible_dir" ] && [ -f "$possible_dir/config/user_preferences.json" ]; then
            echo "$possible_dir"
            return 0
        fi
    done

    # Fallback: return the calculated directory
    echo "$candidate"
}

PROJECT_DIR="$(get_project_dir)"
AUDIO_DIR="$PROJECT_DIR/audio"
CONFIG_FILE="$PROJECT_DIR/config/user_preferences.json"
LOCK_FILE="/tmp/claude_audio_hooks.lock"
QUEUE_DIR="/tmp/claude_audio_hooks_queue"

# =============================================================================
# CONFIGURATION FUNCTIONS
# =============================================================================

# Check if a hook is enabled in configuration
is_hook_enabled() {
    local hook_type="$1"

    # Get Python command (may return empty if not available)
    local python_cmd=$(get_python_cmd)

    # If no Python available, use hard-coded defaults
    if [ -z "$python_cmd" ]; then
        case "$hook_type" in
            notification|stop|subagent_stop) return 0 ;;
            *) return 1 ;;
        esac
    fi

    # If no config file exists, use defaults
    if [ ! -f "$CONFIG_FILE" ]; then
        case "$hook_type" in
            notification|stop|subagent_stop) return 0 ;;
            *) return 1 ;;
        esac
    fi

    # Read enabled status from config using Python
    local enabled=$("$python_cmd" <<EOF 2>/dev/null
import json
import sys
try:
    with open("$CONFIG_FILE", "r") as f:
        config = json.load(f)
    enabled = config.get("enabled_hooks", {}).get("$hook_type", False)
    print("true" if enabled else "false")
except:
    print("false")
EOF
)

    [ "$enabled" = "true" ]
}

# Get audio file path for a hook type
get_audio_file() {
    local hook_type="$1"
    local default_file="$2"

    # Get Python command
    local python_cmd=$(get_python_cmd)

    # Try to read from config
    if [ -f "$CONFIG_FILE" ] && [ -n "$python_cmd" ]; then
        local audio_path=$("$python_cmd" <<EOF 2>/dev/null
import json
try:
    with open("$CONFIG_FILE", "r") as f:
        config = json.load(f)
    audio_file = config.get("audio_files", {}).get("$hook_type", "$default_file")
    print(audio_file)
except:
    print("$default_file")
EOF
)
        echo "$AUDIO_DIR/$audio_path"
    else
        # Fallback to default
        echo "$AUDIO_DIR/default/$default_file"
    fi
}

# =============================================================================
# AUDIO PLAYBACK FUNCTIONS (with integrated path utilities)
# =============================================================================

# Play audio file (platform-specific with smart path conversion)
play_audio_internal() {
    local audio_file="$1"

    # Verify file exists
    if [ ! -f "$audio_file" ]; then
        return 1
    fi

    # Detect platform and play audio
    local env_type=$(detect_environment 2>/dev/null || echo "UNKNOWN")

    # Windows environments (WSL, Git Bash, MSYS, MINGW, Cygwin)
    case "$env_type" in
        WSL)
            # WSL environment - use smart path conversion
            local win_path=$(smart_path_convert "$audio_file" "powershell")
            if [ -n "$win_path" ]; then
                powershell.exe -Command "
                    Add-Type -AssemblyName presentationCore
                    \$mediaPlayer = New-Object System.Windows.Media.MediaPlayer
                    \$mediaPlayer.Open('$win_path')
                    \$mediaPlayer.Play()
                    Start-Sleep -Seconds 3
                    \$mediaPlayer.Stop()
                    \$mediaPlayer.Close()
                " 2>/dev/null &
                return 0
            fi
            ;;

        GIT_BASH)
            # Git Bash / MSYS / MINGW - use improved PowerShell method
            local win_path=$(smart_path_convert "$audio_file" "powershell")

            # Use direct PowerShell command (no temp file needed)
            powershell.exe -ExecutionPolicy Bypass -NoProfile -Command "
                \$ErrorActionPreference = 'SilentlyContinue'
                try {
                    Add-Type -AssemblyName presentationCore
                    \$uri = [uri]::new('file:///$win_path')
                    \$player = [System.Windows.Media.MediaPlayer]::new()
                    \$player.Open(\$uri)
                    \$player.Play()
                    Start-Sleep -Seconds 3
                    \$player.Stop()
                    \$player.Close()
                } catch {
                    # Silent fail - hook errors should not block Claude
                }
            " 2>/dev/null &
            return 0
            ;;

        CYGWIN)
            # Cygwin - use smart path conversion
            local win_path=$(smart_path_convert "$audio_file" "powershell")
            if [ -n "$win_path" ]; then
                powershell.exe -Command "
                    Add-Type -AssemblyName presentationCore
                    \$mediaPlayer = New-Object System.Windows.Media.MediaPlayer
                    \$mediaPlayer.Open('$win_path')
                    \$mediaPlayer.Play()
                    Start-Sleep -Seconds 3
                    \$mediaPlayer.Stop()
                    \$mediaPlayer.Close()
                " 2>/dev/null &
                return 0
            fi
            ;;

        MACOS)
            # macOS
            if command -v afplay &> /dev/null; then
                afplay "$audio_file" 2>/dev/null &
                return 0
            fi
            ;;

        LINUX|*)
            # Linux (native) - not WSL
            # Try mpg123 first (best for MP3)
            if command -v mpg123 &> /dev/null; then
                mpg123 -q "$audio_file" 2>/dev/null &
                return 0
            fi
            # Try aplay (ALSA)
            if command -v aplay &> /dev/null; then
                aplay "$audio_file" 2>/dev/null &
                return 0
            fi
            # Try ffplay (from ffmpeg)
            if command -v ffplay &> /dev/null; then
                ffplay -nodisp -autoexit -hide_banner -loglevel quiet "$audio_file" 2>/dev/null &
                return 0
            fi
            # Try paplay (PulseAudio)
            if command -v paplay &> /dev/null; then
                paplay "$audio_file" 2>/dev/null &
                return 0
            fi
            ;;
    esac

    # No suitable player found
    return 1
}

# =============================================================================
# AUDIO QUEUE SYSTEM
# =============================================================================

# Initialize queue directory
init_queue() {
    mkdir -p "$QUEUE_DIR" 2>/dev/null
}

# Check if queue is enabled
is_queue_enabled() {
    # Get Python command
    local python_cmd=$(get_python_cmd)

    # Default to enabled if no Python
    if [ -z "$python_cmd" ]; then
        return 0
    fi

    if [ ! -f "$CONFIG_FILE" ]; then
        return 0  # Queue enabled by default
    fi

    local queue_enabled=$("$python_cmd" <<EOF 2>/dev/null
import json
try:
    with open("$CONFIG_FILE", "r") as f:
        config = json.load(f)
    enabled = config.get("playback_settings", {}).get("queue_enabled", True)
    print("true" if enabled else "false")
except:
    print("true")
EOF
)

    [ "$queue_enabled" = "true" ]
}

# Get debounce milliseconds
get_debounce_ms() {
    # Get Python command
    local python_cmd=$(get_python_cmd)

    # Default to 500ms if no Python
    if [ -z "$python_cmd" ]; then
        echo "500"
        return
    fi

    if [ ! -f "$CONFIG_FILE" ]; then
        echo "500"  # Default 500ms
        return
    fi

    "$python_cmd" <<EOF 2>/dev/null
import json
try:
    with open("$CONFIG_FILE", "r") as f:
        config = json.load(f)
    debounce = config.get("playback_settings", {}).get("debounce_ms", 500)
    print(debounce)
except:
    print("500")
EOF
}

# Play audio with queue management (prevents overlapping sounds)
play_audio_queued() {
    local audio_file="$1"

    # Initialize queue directory
    init_queue

    # Check if queue is enabled
    if ! is_queue_enabled; then
        # Queue disabled, play directly
        play_audio_internal "$audio_file"
        return $?
    fi

    # Get debounce time
    local debounce_ms=$(get_debounce_ms)
    local debounce_sec=$(echo "scale=3; $debounce_ms / 1000" | bc 2>/dev/null || echo "0.5")

    # Check for recent playback (debounce)
    local last_play_file="$QUEUE_DIR/last_play_time"
    local current_time=$(date +%s%3N 2>/dev/null || date +%s)

    if [ -f "$last_play_file" ]; then
        local last_time=$(cat "$last_play_file" 2>/dev/null || echo "0")
        local time_diff=$((current_time - last_time))

        # If within debounce period, skip
        if [ "$time_diff" -lt "$debounce_ms" ]; then
            return 0
        fi
    fi

    # Update last play time
    echo "$current_time" > "$last_play_file"

    # Acquire lock
    (
        flock -n 200 || exit 1

        # Play audio
        play_audio_internal "$audio_file"

    ) 200>"$LOCK_FILE"

    return $?
}

# =============================================================================
# HOOK TRIGGER LOGGING
# =============================================================================

# Log hook trigger for diagnostics
log_hook_trigger() {
    local hook_type="$1"
    local audio_file="$2"

    local log_dir="/tmp/claude_hooks_log"
    local log_file="$log_dir/hook_triggers.log"

    # Create log directory
    mkdir -p "$log_dir" 2>/dev/null

    # Circular buffer: keep last 200 entries
    if [ -f "$log_file" ]; then
        local line_count=$(wc -l < "$log_file" 2>/dev/null || echo 0)
        if [ "$line_count" -gt 200 ]; then
            tail -n 150 "$log_file" > "$log_file.tmp"
            mv "$log_file.tmp" "$log_file"
        fi
    fi

    # Log entry
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local audio_name=$(basename "$audio_file" 2>/dev/null || echo "unknown")
    echo "[$timestamp] $hook_type -> $audio_name" >> "$log_file" 2>/dev/null
}

# =============================================================================
# MAIN HOOK EXECUTION FUNCTION
# =============================================================================

# Main function to get and play audio for a hook
get_and_play_audio() {
    local hook_type="$1"
    local default_audio="$2"

    # Check if hook is enabled
    if ! is_hook_enabled "$hook_type"; then
        return 0
    fi

    # Get audio file path
    local audio_file=$(get_audio_file "$hook_type" "$default_audio")

    # Log trigger
    log_hook_trigger "$hook_type" "$audio_file"

    # Play audio with queue management
    play_audio_queued "$audio_file"

    return 0
}

# =============================================================================
# INITIALIZATION
# =============================================================================

# Initialize on source
init_queue 2>/dev/null

# Export key functions
export -f get_python_cmd
export -f get_project_dir
export -f is_hook_enabled
export -f get_audio_file
export -f play_audio_internal
export -f play_audio_queued
export -f get_and_play_audio
export -f log_hook_trigger
