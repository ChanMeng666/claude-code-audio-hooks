# Claude Code Audio Hooks 🔊

[English](#english) | [中文](#中文)

---

## English

### Overview

A customizable audio notification system for Claude Code that plays sound alerts when Claude finishes responding. Perfect for multitasking - get notified when your AI assistant completes tasks without constantly monitoring the terminal.

### Features

- 🎵 **Audio Notifications**: Plays custom MP3 audio when Claude Code stops responding
- 🔧 **Easy Setup**: Simple installation script with automated configuration
- 🎨 **Customizable**: Use your own audio files for personalized notifications
- 🪟 **WSL Compatible**: Works seamlessly in WSL (Windows Subsystem for Linux) environment
- ⚡ **Non-blocking**: Audio plays in background without interrupting workflow

### How It Works

This project leverages Claude Code's built-in hooks system to trigger audio playback when Claude finishes a response. The hook executes a bash script that converts WSL paths to Windows paths and uses PowerShell's Media Player to play the audio file.

### Installation

1. **Clone the repository**:
   ```bash
   cd ~
   git clone https://github.com/YOUR_USERNAME/claude-code-audio-hooks.git
   cd claude-code-audio-hooks
   ```

2. **Run the installation script**:
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

3. **Restart Claude Code** to apply changes

### Manual Installation

If you prefer manual setup:

1. Copy the hook script:
   ```bash
   mkdir -p ~/.claude/hooks
   cp hooks/play_audio.sh ~/.claude/hooks/
   chmod +x ~/.claude/hooks/play_audio.sh
   ```

2. Copy your audio file:
   ```bash
   cp audio/hey-chan-please-help-me.mp3 ~/
   ```

3. Add hook configuration to `~/.claude/settings.json`:
   ```json
   {
     "hooks": {
       "Stop": [
         {
           "matcher": "",
           "hooks": [
             {
               "type": "command",
               "command": "/home/YOUR_USERNAME/.claude/hooks/play_audio.sh"
             }
           ]
         }
       ]
     }
   }
   ```

4. Add permission to `~/.claude/settings.local.json`:
   ```json
   {
     "permissions": {
       "allow": [
         "Bash(~/.claude/hooks/play_audio.sh)"
       ]
     }
   }
   ```

### Customization

#### Using Your Own Audio File

1. Replace the MP3 file:
   ```bash
   cp /path/to/your/audio.mp3 ~/your-audio-file.mp3
   ```

2. Update the script at `~/.claude/hooks/play_audio.sh`:
   ```bash
   AUDIO_FILE="/home/YOUR_USERNAME/your-audio-file.mp3"
   ```

#### Adjusting Audio Duration

Edit the `Start-Sleep` duration in `play_audio.sh`:
```bash
Start-Sleep -Seconds 3  # Change 3 to your desired duration
```

### File Structure

```
claude-code-audio-hooks/
├── hooks/
│   └── play_audio.sh          # Main hook script
├── audio/
│   └── hey-chan-please-help-me.mp3  # Default notification sound
├── examples/
│   ├── settings.json          # Example hook configuration
│   └── settings.local.json    # Example permission configuration
├── install.sh                  # Automated installation script
├── README.md                   # This file
└── LICENSE                     # MIT License
```

### Troubleshooting

**Audio not playing?**
- Ensure the audio file path is correct in `play_audio.sh`
- Check that PowerShell is available in your WSL environment
- Verify the hook has execute permissions: `chmod +x ~/.claude/hooks/play_audio.sh`
- Check Claude Code settings.json for correct hook configuration

**Permission denied error?**
- Add the hook command to the allow list in `~/.claude/settings.local.json`

**Hook not triggering?**
- Restart Claude Code after making configuration changes
- Verify the hook is properly configured in `~/.claude/settings.json`

### Requirements

- Claude Code CLI
- WSL (Windows Subsystem for Linux)
- PowerShell (for audio playback on Windows)
- Bash shell

### Contributing

Contributions are welcome! Feel free to:
- Submit bug reports or feature requests via Issues
- Create pull requests with improvements
- Share your custom audio files and configurations

### License

MIT License - feel free to use and modify as needed.

### Author

Created with ❤️ by [Your Name]

---

## 中文

### 概述

为 Claude Code 定制的音频通知系统，当 Claude 完成响应时播放声音提醒。非常适合多任务处理 - 无需持续监控终端即可在 AI 助手完成任务时收到通知。

### 功能特点

- 🎵 **音频通知**: Claude Code 停止响应时播放自定义 MP3 音频
- 🔧 **简易设置**: 简单的安装脚本，自动化配置
- 🎨 **可自定义**: 使用您自己的音频文件实现个性化通知
- 🪟 **WSL 兼容**: 在 WSL (Windows Subsystem for Linux) 环境中无缝工作
- ⚡ **非阻塞**: 音频在后台播放，不中断工作流程

### 工作原理

本项目利用 Claude Code 内置的 hooks 系统，在 Claude 完成响应时触发音频播放。hook 执行一个 bash 脚本，将 WSL 路径转换为 Windows 路径，并使用 PowerShell 的媒体播放器播放音频文件。

### 安装步骤

1. **克隆仓库**:
   ```bash
   cd ~
   git clone https://github.com/YOUR_USERNAME/claude-code-audio-hooks.git
   cd claude-code-audio-hooks
   ```

2. **运行安装脚本**:
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

3. **重启 Claude Code** 以应用更改

### 手动安装

如果您偏好手动设置:

1. 复制 hook 脚本:
   ```bash
   mkdir -p ~/.claude/hooks
   cp hooks/play_audio.sh ~/.claude/hooks/
   chmod +x ~/.claude/hooks/play_audio.sh
   ```

2. 复制音频文件:
   ```bash
   cp audio/hey-chan-please-help-me.mp3 ~/
   ```

3. 在 `~/.claude/settings.json` 中添加 hook 配置:
   ```json
   {
     "hooks": {
       "Stop": [
         {
           "matcher": "",
           "hooks": [
             {
               "type": "command",
               "command": "/home/YOUR_USERNAME/.claude/hooks/play_audio.sh"
             }
           ]
         }
       ]
     }
   }
   ```

4. 在 `~/.claude/settings.local.json` 中添加权限:
   ```json
   {
     "permissions": {
       "allow": [
         "Bash(~/.claude/hooks/play_audio.sh)"
       ]
     }
   }
   ```

### 自定义配置

#### 使用您自己的音频文件

1. 替换 MP3 文件:
   ```bash
   cp /path/to/your/audio.mp3 ~/your-audio-file.mp3
   ```

2. 更新脚本 `~/.claude/hooks/play_audio.sh`:
   ```bash
   AUDIO_FILE="/home/YOUR_USERNAME/your-audio-file.mp3"
   ```

#### 调整音频时长

编辑 `play_audio.sh` 中的 `Start-Sleep` 时长:
```bash
Start-Sleep -Seconds 3  # 将 3 改为您想要的时长
```

### 文件结构

```
claude-code-audio-hooks/
├── hooks/
│   └── play_audio.sh          # 主 hook 脚本
├── audio/
│   └── hey-chan-please-help-me.mp3  # 默认通知声音
├── examples/
│   ├── settings.json          # hook 配置示例
│   └── settings.local.json    # 权限配置示例
├── install.sh                  # 自动安装脚本
├── README.md                   # 本文件
└── LICENSE                     # MIT 许可证
```

### 故障排除

**音频不播放？**
- 确保 `play_audio.sh` 中的音频文件路径正确
- 检查 WSL 环境中是否可用 PowerShell
- 验证 hook 具有执行权限: `chmod +x ~/.claude/hooks/play_audio.sh`
- 检查 Claude Code settings.json 中的 hook 配置是否正确

**权限被拒绝错误？**
- 在 `~/.claude/settings.local.json` 的允许列表中添加 hook 命令

**Hook 未触发？**
- 更改配置后重启 Claude Code
- 验证 hook 在 `~/.claude/settings.json` 中配置正确

### 系统要求

- Claude Code CLI
- WSL (Windows Subsystem for Linux)
- PowerShell (用于在 Windows 上播放音频)
- Bash shell

### 贡献

欢迎贡献! 您可以:
- 通过 Issues 提交错误报告或功能请求
- 创建包含改进的 pull requests
- 分享您的自定义音频文件和配置

### 许可证

MIT 许可证 - 可随意使用和修改。

### 作者

由 [Your Name] 用 ❤️ 创建
