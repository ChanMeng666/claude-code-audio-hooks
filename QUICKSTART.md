# Quick Start Guide 🚀

> **Get audio notifications in Claude Code in just 2 minutes!**

This is the fastest way to get started. For detailed explanations, see the [full README](README.md).

---

## Step 1: Open Your Terminal

### Windows Users:
1. Press `Windows + R`
2. Type `wsl` and press Enter

### Mac/Linux Users:
Open your Terminal app

---

## Step 2: Install (Copy & Paste These 3 Commands)

```bash
cd ~
git clone https://github.com/ChanMeng666/claude-code-audio-hooks.git
cd claude-code-audio-hooks && chmod +x install.sh && ./install.sh
```

**What this does:**
- Downloads the project
- Runs the automatic installer
- Sets up everything for you

---

## Step 3: Restart Claude Code

Close your terminal completely and open it again.

---

## Step 4: Test It!

```bash
claude "Hello!"
```

**You should hear a sound when Claude finishes!** 🎉

---

## Didn't Work?

Run the checker to see what's wrong:

```bash
cd ~/claude-code-audio-hooks
./check-setup.sh
```

---

## Want a Custom Sound?

### Easy Way: Use AI to Create Your Sound

1. Go to [elevenlabs.io](https://elevenlabs.io) (free account)
2. Click "Text to Speech"
3. Type your notification message:
   - "I'm done!"
   - "Task complete!"
   - "Ready for you!"
4. Download the audio file
5. Replace the audio file:

**Windows/WSL:**
```bash
cp /mnt/c/Users/YourName/Downloads/your-audio.mp3 ~/claude-code-audio-hooks/audio/hey-chan-please-help-me.mp3
```

**Mac/Linux:**
```bash
cp ~/Downloads/your-audio.mp3 ~/claude-code-audio-hooks/audio/hey-chan-please-help-me.mp3
```

That's it! The new audio will play automatically.

---

## Common Issues

### No sound?
1. Check your speakers are on and not muted
2. Make sure you restarted Claude Code after installing
3. Run `./check-setup.sh` to diagnose

### Permission error?
```bash
chmod +x ~/.claude/hooks/play_audio.sh
```

### Can't find git?
Install git first:
```bash
# Ubuntu/Debian
sudo apt-get install git

# Mac
brew install git
```

---

## Need More Help?

- 📖 [Full Documentation](README.md)
- 💬 [Ask Questions](https://github.com/ChanMeng666/claude-code-audio-hooks/discussions)
- 🐛 [Report Issues](https://github.com/ChanMeng666/claude-code-audio-hooks/issues)

---

**That's it! Enjoy your audio notifications! 🎵**

If this helped you, please ⭐ star the repo on GitHub!
