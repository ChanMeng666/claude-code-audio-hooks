#!/bin/bash
# Claude Code Stop Hook - Play notification audio
# Plays audio when Claude Code finishes responding

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")/claude-code-audio-hooks"

# Try to find audio file in multiple locations
AUDIO_FILE=""
AUDIO_NAME="hey-chan-please-help-me.mp3"

# Priority 1: Project directory (for clean installation)
if [ -f "$PROJECT_DIR/audio/$AUDIO_NAME" ]; then
    AUDIO_FILE="$PROJECT_DIR/audio/$AUDIO_NAME"
# Priority 2: User home directory (legacy/fallback)
elif [ -f "$HOME/$AUDIO_NAME" ]; then
    AUDIO_FILE="$HOME/$AUDIO_NAME"
else
    # No audio file found, exit silently
    exit 0
fi

# 将WSL路径转换为Windows路径
WIN_PATH=$(wslpath -w "$AUDIO_FILE")

# 使用PowerShell和Windows Media Player播放MP3
powershell.exe -Command "
Add-Type -AssemblyName presentationCore
\$mediaPlayer = New-Object System.Windows.Media.MediaPlayer
\$mediaPlayer.Open('$WIN_PATH')
\$mediaPlayer.Play()
Start-Sleep -Seconds 3
" 2>/dev/null &

exit 0
