# Claude Code Audio Hooks 🔊

> **Get notified when Claude finishes working!** This tool plays a sound alert when Claude Code completes a task, so you can multitask without constantly checking your terminal.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: Linux | WSL](https://img.shields.io/badge/Platform-Linux%20%7C%20WSL-blue)](https://github.com/ChanMeng666/claude-code-audio-hooks)

---

## 📖 Table of Contents

- [What Does This Do?](#what-does-this-do)
- [Before You Start](#before-you-start)
- [Installation Guide](#installation-guide)
  - [For Windows (WSL) Users](#for-windows-wsl-users)
  - [For Linux Users](#for-linux-users)
  - [For macOS Users](#for-macos-users)
- [Creating Your Custom Audio](#creating-your-custom-audio)
- [Testing Your Setup](#testing-your-setup)
- [Troubleshooting](#troubleshooting)
- [Uninstalling](#uninstalling)
- [FAQ](#faq)

---

## 🎯 What Does This Do?

This project adds an **audio notification** to Claude Code that plays whenever Claude finishes responding to you. Think of it as a friendly "Hey, I'm done!" notification.

**Perfect for:**
- 💼 Multitasking while Claude works on long tasks
- 📚 Studying or working on other things while waiting for responses
- ⏰ Getting notified without staring at your terminal

**Example:** You ask Claude to build a complex feature. Instead of watching the terminal, you can work on something else. When you hear the sound, you know Claude is done!

---

## ✅ Before You Start

### What You Need:

1. **Claude Code CLI** installed on your computer
   - Don't have it? [Get Claude Code here](https://claude.ai/download)

2. **Your operating system:**
   - ✅ Windows with WSL (Windows Subsystem for Linux)
   - ✅ Linux (Ubuntu, Debian, etc.)
   - ✅ macOS (coming soon - requires slight modifications)

3. **Basic command line access** (don't worry, we'll guide you through it!)

### Quick Check - Do You Have What You Need?

Open your terminal and type:
```bash
claude --version
```

If you see a version number, you're ready to go! If not, please install Claude Code first.

---

## 🚀 Installation Guide

Choose your operating system below and follow the step-by-step instructions:

### For Windows (WSL) Users

> **What is WSL?** Windows Subsystem for Linux lets you run Linux on Windows. If you're using Claude Code on Windows, you're likely using WSL!

#### Step 1: Open Your WSL Terminal

1. Press `Windows Key + R`
2. Type `wsl` and press Enter
3. A terminal window will open - this is your Linux environment!

#### Step 2: Download This Project

Copy and paste this command into your terminal (press Enter after pasting):

```bash
cd ~
git clone https://github.com/ChanMeng666/claude-code-audio-hooks.git
cd claude-code-audio-hooks
```

**What this does:** Downloads the project to your computer and enters the project folder.

#### Step 3: Run the Installer

Copy and paste this command:

```bash
chmod +x install.sh
./install.sh
```

**What this does:** Makes the installer executable and runs it. The installer will automatically set everything up for you!

#### Step 4: Restart Claude Code

Close your Claude Code terminal completely and open it again. This lets the changes take effect.

#### Step 5: Test It!

Try asking Claude anything:
```bash
claude
# Then type any question
```

When Claude finishes, you should hear a sound! 🎉

---

### For Linux Users

#### Step 1: Open Your Terminal

Use your favorite terminal application (GNOME Terminal, Konsole, xterm, etc.)

#### Step 2: Download This Project

```bash
cd ~
git clone https://github.com/ChanMeng666/claude-code-audio-hooks.git
cd claude-code-audio-hooks
```

#### Step 3: Check Your Audio System

**Important:** This script uses PowerShell's media player (designed for WSL). For native Linux, you may need to modify the hook script.

For native Linux, you can use `mpg123` or `aplay`:

```bash
# Install audio player (choose one)
sudo apt-get install mpg123        # For Debian/Ubuntu
# or
sudo apt-get install alsa-utils    # For simpler playback
```

Then modify `hooks/play_audio.sh` to use your preferred player. See [Customization for Linux](#customization-for-linux) below.

#### Step 4: Run the Installer

```bash
chmod +x install.sh
./install.sh
```

#### Step 5: Restart Claude Code and Test

Close and reopen Claude Code, then test with any command!

---

### For macOS Users

> **Note:** This project is primarily designed for WSL/Linux. For macOS, you'll need to modify the audio playback method.

#### Step 1: Open Terminal

Find Terminal in Applications > Utilities, or press `Cmd + Space` and type "Terminal"

#### Step 2: Download This Project

```bash
cd ~
git clone https://github.com/ChanMeng666/claude-code-audio-hooks.git
cd claude-code-audio-hooks
```

#### Step 3: Modify for macOS

The default script uses PowerShell (Windows). For macOS, you need to use `afplay` instead.

Edit `hooks/play_audio.sh` and replace the PowerShell section with:

```bash
# macOS audio playback
afplay "$AUDIO_FILE" &
```

#### Step 4: Run the Installer

```bash
chmod +x install.sh
./install.sh
```

#### Step 5: Restart Claude Code and Test

---

## 🎨 Creating Your Custom Audio

Want a personalized notification sound? Here's how to create your own using AI!

### Option 1: Use ElevenLabs (Recommended for Beginners)

**ElevenLabs** is a text-to-speech AI that can create natural-sounding voices.

#### Step-by-Step Guide:

1. **Visit ElevenLabs**
   - Go to [elevenlabs.io](https://elevenlabs.io)
   - Sign up for a free account (you get free credits!)

2. **Create Your Audio**
   - Click on "Text to Speech"
   - Type your notification message, for example:
     - "Hey, I'm done with that task!"
     - "Your code is ready!"
     - "Task completed successfully!"
   - Choose a voice you like
   - Click "Generate"

3. **Download Your Audio**
   - Click the download button
   - Save it as an MP3 file

4. **Add It to Your Project**

   **For Windows/WSL:**
   ```bash
   # Copy your downloaded file to the project
   # Replace the path with where you downloaded your file
   cp /mnt/c/Users/YourName/Downloads/your-audio.mp3 ~/claude-code-audio-hooks/audio/hey-chan-please-help-me.mp3
   ```

   **For Linux:**
   ```bash
   cp ~/Downloads/your-audio.mp3 ~/claude-code-audio-hooks/audio/hey-chan-please-help-me.mp3
   ```

5. **That's It!**

   The hook will automatically use your new audio file. No configuration needed!

### Option 2: Use Any MP3 File

Have an MP3 file you want to use? Just replace the audio file:

```bash
cp /path/to/your/sound.mp3 ~/claude-code-audio-hooks/audio/hey-chan-please-help-me.mp3
```

**Tips for good notification sounds:**
- Keep it short (2-5 seconds is ideal)
- Make it pleasant but noticeable
- Avoid very loud or jarring sounds
- Test it at different volumes

---

## 🧪 Testing Your Setup

### Quick Test

1. Open Claude Code
2. Type any simple command:
   ```bash
   claude "What is 2+2?"
   ```
3. Wait for Claude to respond
4. You should hear your audio notification! 🎵

### If You Don't Hear Anything

Don't worry! Check the [Troubleshooting](#troubleshooting) section below.

### Running the Check Script

We've included a verification script to check if everything is set up correctly:

```bash
cd ~/claude-code-audio-hooks
./check-setup.sh
```

This will tell you if anything needs fixing.

---

## 🔧 Troubleshooting

### "I don't hear any sound!"

**Check 1: Is your audio file in the right place?**
```bash
ls -lh ~/claude-code-audio-hooks/audio/hey-chan-please-help-me.mp3
```
You should see the file listed. If not, make sure you didn't delete it!

**Check 2: Is the hook script installed?**
```bash
ls -lh ~/.claude/hooks/play_audio.sh
```
If this file doesn't exist, run `./install.sh` again.

**Check 3: Are your speakers on?**
- Make sure your system volume isn't muted
- Try playing the audio file manually to test:
  ```bash
  # For WSL
  powershell.exe -Command "& {Add-Type -AssemblyName presentationCore; \$player = New-Object System.Windows.Media.MediaPlayer; \$player.Open('$(wslpath -w ~/claude-code-audio-hooks/audio/hey-chan-please-help-me.mp3)'); \$player.Play(); Start-Sleep -Seconds 3}"
  ```

**Check 4: Did you restart Claude Code?**
After installation, you MUST restart Claude Code for the hooks to activate.

### "I get a permission denied error"

The hook script needs execute permissions. Fix it with:
```bash
chmod +x ~/.claude/hooks/play_audio.sh
```

### "The installer failed"

Make sure you have Python 3 installed (required for configuration):
```bash
python3 --version
```

If not installed:
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install python3

# macOS
brew install python3
```

### "It worked once but stopped working"

This can happen if you moved the project folder. The hook looks for the audio file at:
```
~/claude-code-audio-hooks/audio/hey-chan-please-help-me.mp3
```

Make sure the project folder is still there:
```bash
ls -la ~/claude-code-audio-hooks/
```

### Still Having Issues?

1. Check the [Issues page](https://github.com/ChanMeng666/claude-code-audio-hooks/issues) on GitHub
2. Create a new issue with:
   - Your operating system
   - The error message you're seeing
   - What you've already tried

We're here to help! 💙

---

## 🗑️ Uninstalling

Changed your mind? No problem! Easy to remove:

### Option 1: Use the Uninstaller (Recommended)

```bash
cd ~/claude-code-audio-hooks
./uninstall.sh
```

Follow the prompts. It will ask if you want to keep the audio file.

### Option 2: Manual Removal

Remove the hook:
```bash
rm ~/.claude/hooks/play_audio.sh
```

Remove from settings (you'll need to edit these files manually):
- `~/.claude/settings.json` - Remove the "Stop" hook section
- `~/.claude/settings.local.json` - Remove the permission for play_audio.sh

Delete the project folder:
```bash
rm -rf ~/claude-code-audio-hooks
```

Then restart Claude Code.

---

## ❓ FAQ

### Q: Will this slow down Claude Code?

**A:** No! The audio plays in the background and doesn't interfere with Claude's performance at all.

### Q: Can I use this with other Claude Code features?

**A:** Absolutely! This hook works alongside all other Claude Code features without any conflicts.

### Q: Can I have different sounds for different types of responses?

**A:** Currently, it plays the same sound every time Claude stops. Advanced users can modify the hook script to add conditional logic based on the response type.

### Q: Does this work with Claude Code's web interface?

**A:** No, this is specifically for the Claude Code CLI (command-line interface). The web interface doesn't support custom hooks.

### Q: Is this safe? Will it access my data?

**A:** Yes, it's completely safe! This script:
- Only plays audio when Claude stops
- Doesn't collect, send, or access any of your data
- Runs locally on your computer
- Is open source - you can review all the code

### Q: Can I contribute or suggest improvements?

**A:** Yes, please! This project is open source. Feel free to:
- Submit bug reports
- Suggest new features
- Contribute code improvements
- Share your custom audio files

### Q: How much does this cost?

**A:** This project is completely **free and open source**! However:
- Claude Code itself may require a subscription
- ElevenLabs has free credits but charges for heavy usage
- You can use any free MP3 file instead

### Q: I'm not technical - is this really for me?

**A:** Yes! We've designed this guide specifically for non-technical users. If you can copy and paste commands, you can set this up. And if you get stuck, we're here to help!

---

## 📚 Technical Details

### How It Works

This project uses Claude Code's built-in **hooks system**:

1. Claude Code has a "Stop" hook that triggers when Claude finishes responding
2. Our hook script (`play_audio.sh`) is registered to run when this happens
3. The script finds the audio file in the project folder
4. It plays the audio using your system's media player
5. The hook exits, and Claude Code continues normally

### File Structure

```
claude-code-audio-hooks/
├── hooks/
│   └── play_audio.sh          # The main hook script
├── audio/
│   └── hey-chan-please-help-me.mp3  # Default notification sound (25KB)
├── examples/
│   ├── settings.json          # Example Claude Code configuration
│   └── settings.local.json    # Example permissions configuration
├── install.sh                  # Automated installer
├── uninstall.sh                # Automated uninstaller
├── check-setup.sh              # Setup verification script
└── README.md                   # This guide
```

### Customization for Linux

If you're on native Linux (not WSL), modify `hooks/play_audio.sh`:

**For mpg123:**
```bash
#!/bin/bash
AUDIO_FILE="$HOME/claude-code-audio-hooks/audio/hey-chan-please-help-me.mp3"
mpg123 -q "$AUDIO_FILE" &
exit 0
```

**For aplay (WAV files):**
```bash
#!/bin/bash
AUDIO_FILE="$HOME/claude-code-audio-hooks/audio/notification.wav"
aplay "$AUDIO_FILE" &
exit 0
```

---

## 🤝 Contributing

We welcome contributions! Here's how you can help:

1. **Report bugs** - Found something not working? [Open an issue](https://github.com/ChanMeng666/claude-code-audio-hooks/issues)
2. **Suggest features** - Have ideas? We'd love to hear them!
3. **Improve documentation** - Help make this guide even clearer
4. **Share your audio files** - Created a great notification sound? Share it!
5. **Code contributions** - Submit pull requests with improvements

---

## 📜 License

MIT License - You're free to use, modify, and distribute this project. See [LICENSE](LICENSE) for details.

---

## 💝 Acknowledgments

- Thanks to Anthropic for creating Claude Code and its extensible hooks system
- Thanks to all contributors and users who help improve this project
- Special thanks to the open source community

---

## 📬 Support

- **Issues:** [GitHub Issues](https://github.com/ChanMeng666/claude-code-audio-hooks/issues)
- **Discussions:** [GitHub Discussions](https://github.com/ChanMeng666/claude-code-audio-hooks/discussions)

---

<div align="center">

Made with ❤️ for the Claude Code community

⭐ **If this helped you, please star this repo!** ⭐

[Report Bug](https://github.com/ChanMeng666/claude-code-audio-hooks/issues) · [Request Feature](https://github.com/ChanMeng666/claude-code-audio-hooks/issues) · [Ask Question](https://github.com/ChanMeng666/claude-code-audio-hooks/discussions)

</div>
