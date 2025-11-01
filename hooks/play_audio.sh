#!/bin/bash
# Claude Code Stop Hook - Play notification audio
# Plays audio when Claude Code finishes responding

AUDIO_FILE="/home/chanmeng/hey-chan-please-help-me.mp3"

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
