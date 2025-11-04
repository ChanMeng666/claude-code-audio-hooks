# 🤖 AI-Assisted Installation Guide

> **Complete, AI-friendly installation guide for Claude Code Audio Hooks**
>
> This document is designed to be read and executed by AI assistants like Claude Code.
> Every step is clearly defined, testable, and includes success criteria.

---

## 📋 Installation Summary

**What:** Claude Code Audio Hooks v2.1 - Audio notification system for Claude Code
**Why:** Get audio notifications when Claude completes tasks, needs input, or encounters issues
**How:** One command: `bash scripts/install-complete.sh`

---

## 🚀 Quick Install (Recommended)

### For AI Assistants: Single Command Installation

```bash
# Clone and install in one go
git clone https://github.com/ChanMeng666/claude-code-audio-hooks.git && \
cd claude-code-audio-hooks && \
bash scripts/install-complete.sh
```

**Expected Output:**
```
✓ Environment check passed
✓ Dependencies verified
✓ Hooks installed (9/9)
✓ Settings configured
✓ Permissions granted
✓ Installation complete!

Next: Restart Claude Code and test with: claude "test"
```

**If successful:** Skip to [Verification](#verification) section
**If failed:** Continue to [Detailed Installation](#detailed-installation)

---

## 🔍 Pre-Installation Check

### Step 0: Verify Prerequisites

Run this BEFORE attempting installation:

```bash
# Quick environment check
bash -c '
echo "Checking prerequisites..."
echo ""

# Check 1: Claude Code
if command -v claude &> /dev/null; then
    echo "✓ Claude Code: $(claude --version)"
else
    echo "✗ Claude Code not found"
    echo "  Install from: https://docs.anthropic.com/claude/docs/claude-code"
    exit 1
fi

# Check 2: Git
if command -v git &> /dev/null; then
    echo "✓ Git: $(git --version)"
else
    echo "✗ Git not found"
    echo "  Install: sudo apt-get install git (Linux/WSL)"
    echo "  Install: https://gitforwindows.org/ (Windows)"
    exit 1
fi

# Check 3: Python (optional but recommended)
PYTHON_CMD=""
for cmd in python3 python py; do
    if command -v $cmd &> /dev/null; then
        version=$($cmd --version 2>&1)
        if [[ "$version" == *"Python 3"* ]]; then
            echo "✓ Python: $version"
            PYTHON_CMD="$cmd"
            break
        fi
    fi
done

if [ -z "$PYTHON_CMD" ]; then
    echo "⚠ Python 3 not found (optional)"
    echo "  Some features will use defaults"
    echo "  Install: sudo apt-get install python3 (Linux/WSL)"
    echo "  Install: https://www.python.org/downloads/ (Windows)"
fi

echo ""
echo "✓ Prerequisites check passed"
echo "You can proceed with installation"
'
```

**Success Criteria:**
- ✓ Claude Code is installed
- ✓ Git is installed
- ⚠ Python is optional (recommended)

---

## 📦 Detailed Installation

### Method 1: Automatic Installation (Recommended for AI)

Use the complete installation script that handles everything:

```bash
# Step 1: Clone repository (if not already cloned)
if [ ! -d "claude-code-audio-hooks" ]; then
    git clone https://github.com/ChanMeng666/claude-code-audio-hooks.git
    cd claude-code-audio-hooks
else
    cd claude-code-audio-hooks
    git pull origin master
fi

# Step 2: Run complete installation script
bash scripts/install-complete.sh

# The script will:
# 1. Detect your environment (WSL, Git Bash, Linux, macOS, etc.)
# 2. Check all dependencies
# 3. Install hook scripts
# 4. Configure Claude settings
# 5. Set up permissions
# 6. Test the installation
# 7. Provide next steps

# Step 3: Follow the on-screen instructions
```

**Expected Duration:** 2-5 minutes

**Log Location:** `/tmp/claude_hooks_install_YYYYMMDD_HHMMSS.log`

---

### Method 2: Step-by-Step Installation (For Troubleshooting)

If automatic installation fails, follow these steps:

#### Step 1: Clone Repository

```bash
git clone https://github.com/ChanMeng666/claude-code-audio-hooks.git
cd claude-code-audio-hooks
```

**Verify:**
```bash
ls -la
# Should see: hooks/, scripts/, audio/, config/, README.md, etc.
```

---

#### Step 2: Run Environment Detection

```bash
bash scripts/detect-environment.sh
```

**Success Criteria:**
- ✓ All 12 detection steps complete
- ✓ 0 missing required dependencies
- ✓ Report generated in `/tmp/`

**If issues found:** Review recommendations at end of report

---

#### Step 3: Test Path Utilities

```bash
bash scripts/test-path-utils.sh
```

**Success Criteria:**
- ✓ All path conversion tests pass
- ✓ Environment correctly detected

**If tests fail:** Check the error messages and see [Troubleshooting](#troubleshooting)

---

#### Step 4: Install Hook Scripts

```bash
# Create hooks directory
mkdir -p ~/.claude/hooks
mkdir -p ~/.claude/hooks/shared

# Record project path
pwd > ~/.claude/hooks/.project_path

# Copy shared utilities
cp hooks/shared/path_utils.sh ~/.claude/hooks/shared/
cp hooks/shared/hook_config.sh ~/.claude/hooks/shared/
chmod +x ~/.claude/hooks/shared/*.sh

# Copy hook scripts
for hook in hooks/*_hook.sh; do
    cp "$hook" ~/.claude/hooks/
    chmod +x ~/.claude/hooks/$(basename "$hook")
done

# Verify
ls -la ~/.claude/hooks/
# Should see: 9 *_hook.sh files + shared/ directory
```

**Success Criteria:**
- ✓ 9 hook scripts in ~/.claude/hooks/
- ✓ shared/ directory with utilities
- ✓ All scripts executable (chmod +x)

---

#### Step 5: Configure Claude Settings

```bash
# Backup existing settings
if [ -f ~/.claude/settings.json ]; then
    cp ~/.claude/settings.json ~/.claude/settings.json.backup
fi

# Update settings with Python script
python3 << 'EOF'
import json
import os

settings_file = os.path.expanduser('~/.claude/settings.json')

# Read existing settings or create new
if os.path.exists(settings_file):
    with open(settings_file, 'r') as f:
        settings = json.load(f)
else:
    settings = {}

# Add hooks
if 'hooks' not in settings:
    settings['hooks'] = {}

hooks = {
    'Notification': '~/.claude/hooks/notification_hook.sh',
    'Stop': '~/.claude/hooks/stop_hook.sh',
    'PreToolUse': '~/.claude/hooks/pretooluse_hook.sh',
    'PostToolUse': '~/.claude/hooks/posttooluse_hook.sh',
    'UserPromptSubmit': '~/.claude/hooks/userprompt_hook.sh',
    'SubagentStop': '~/.claude/hooks/subagent_hook.sh',
    'PreCompact': '~/.claude/hooks/precompact_hook.sh',
    'SessionStart': '~/.claude/hooks/session_start_hook.sh',
    'SessionEnd': '~/.claude/hooks/session_end_hook.sh'
}

for hook_name, hook_path in hooks.items():
    settings['hooks'][hook_name] = hook_path

# Save settings
with open(settings_file, 'w') as f:
    json.dump(settings, f, indent=2)

print('✓ Settings updated successfully')
EOF
```

**Success Criteria:**
- ✓ settings.json contains all 9 hooks
- ✓ Backup created (settings.json.backup)

---

#### Step 6: Configure Permissions

```bash
# Update settings.local.json for hook permissions
python3 << 'EOF'
import json
import os

settings_local = os.path.expanduser('~/.claude/settings.local.json')

# Read existing or create new
if os.path.exists(settings_local):
    with open(settings_local, 'r') as f:
        settings = json.load(f)
else:
    settings = {}

# Add allowed tools
if 'allowedTools' not in settings:
    settings['allowedTools'] = []

# Add permissions for each hook
hooks = [
    '~/.claude/hooks/notification_hook.sh',
    '~/.claude/hooks/stop_hook.sh',
    '~/.claude/hooks/pretooluse_hook.sh',
    '~/.claude/hooks/posttooluse_hook.sh',
    '~/.claude/hooks/userprompt_hook.sh',
    '~/.claude/hooks/subagent_hook.sh',
    '~/.claude/hooks/precompact_hook.sh',
    '~/.claude/hooks/session_start_hook.sh',
    '~/.claude/hooks/session_end_hook.sh'
]

for hook in hooks:
    bash_entry = f'Bash({hook})'
    if bash_entry not in settings['allowedTools']:
        settings['allowedTools'].append(bash_entry)

# Save settings
with open(settings_local, 'w') as f:
    json.dump(settings, f, indent=2)

print('✓ Permissions configured successfully')
EOF
```

**Success Criteria:**
- ✓ settings.local.json contains allowedTools
- ✓ All 9 hooks listed in allowedTools

---

#### Step 7: Initialize Configuration

```bash
# Copy default configuration to user preferences
if [ ! -f config/user_preferences.json ]; then
    cp config/default_preferences.json config/user_preferences.json
fi

# Verify configuration
python3 << 'EOF'
import json
with open('config/user_preferences.json', 'r') as f:
    config = json.load(f)
    enabled = config['enabled_hooks']
    print(f"✓ Configuration loaded: {sum(enabled.values())} hooks enabled")
EOF
```

**Success Criteria:**
- ✓ user_preferences.json exists
- ✓ Configuration is valid JSON

---

## ✅ Verification

### Test Installation Success

Run these tests to verify everything works:

#### Test 1: Check Installation

```bash
bash scripts/check-setup.sh
```

**Expected Output:**
```
✓ Claude Code is installed
✓ Hooks directory exists
✓ All 9 hook scripts installed
✓ Settings configured
✓ Permissions set
✓ Audio files present (9 files)

Installation Status: COMPLETE
```

---

#### Test 2: Test Audio Playback

```bash
bash scripts/test-audio.sh
```

**Expected:** You should hear "Task completed successfully!"

**If no audio:**
- Check audio output device is working
- Check volume is not muted
- See [Audio Troubleshooting](#audio-troubleshooting)

---

#### Test 3: Test with Claude Code

```bash
# Start a new Claude session (restart if already running)
claude "What is 2+2?"
```

**Expected:**
- Claude responds with "4"
- You hear audio notification when response completes

**If no audio:**
- Hooks may not be triggering
- Check `~/.claude/settings.json` has hooks configured
- Check hook permissions in `~/.claude/settings.local.json`

---

#### Test 4: Check Hook Logs

```bash
# View hook trigger log
cat /tmp/claude_hooks_log/hook_triggers.log

# Should show recent hook triggers, e.g.:
# [2025-11-04 15:30:45] stop -> task-complete.mp3
```

---

## 🐛 Troubleshooting

### Issue 1: Installation Script Fails

**Symptoms:**
- Script exits with error
- Incomplete installation

**Solutions:**

1. **Check prerequisites:**
   ```bash
   bash scripts/detect-environment.sh
   # Review all checks, especially failed ones
   ```

2. **Check installation log:**
   ```bash
   ls -lt /tmp/claude_hooks_install_*.log | head -1 | awk '{print $NF}'
   # Read the most recent log file
   ```

3. **Try step-by-step installation:**
   Follow [Method 2: Step-by-Step Installation](#method-2-step-by-step-installation-for-troubleshooting)

---

### Issue 2: Hooks Not Triggering

**Symptoms:**
- No audio notifications
- No entries in hook_triggers.log

**Solutions:**

1. **Verify settings.json:**
   ```bash
   grep -A 10 '"hooks"' ~/.claude/settings.json
   # Should show all 9 hooks
   ```

2. **Verify permissions:**
   ```bash
   grep 'allowedTools' ~/.claude/settings.local.json
   # Should show Bash(~/.claude/hooks/*_hook.sh) entries
   ```

3. **Check hook scripts are executable:**
   ```bash
   ls -l ~/.claude/hooks/*.sh
   # All should have 'x' permission (e.g., -rwxr-xr-x)
   ```

4. **Restart Claude Code:**
   Settings changes require restart

---

### Issue 3: Audio Not Playing

**Symptoms:**
- Hooks trigger (visible in logs)
- But no sound

**Solutions:**

1. **Test audio system:**
   ```bash
   bash scripts/test-audio.sh
   ```

2. **Check audio player:**
   ```bash
   # WSL/Git Bash: Check PowerShell
   powershell.exe -Command "Write-Host 'Test'"

   # Linux: Check mpg123
   which mpg123

   # macOS: Check afplay
   which afplay
   ```

3. **Check audio files exist:**
   ```bash
   PROJECT_PATH=$(cat ~/.claude/hooks/.project_path)
   ls -lh "$PROJECT_PATH/audio/default/"
   # Should show 9 MP3 files
   ```

4. **Test manual playback:**
   ```bash
   # WSL/Git Bash
   PROJECT_PATH=$(cat ~/.claude/hooks/.project_path)
   AUDIO="$PROJECT_PATH/audio/default/task-complete.mp3"
   powershell.exe -Command "
       Add-Type -AssemblyName presentationCore
       \$player = New-Object System.Windows.Media.MediaPlayer
       \$player.Open('$(echo $AUDIO | sed 's|^/\([a-z]\)/|\U\1:/|')')
       \$player.Play()
       Start-Sleep -Seconds 3
   "
   ```

---

### Issue 4: Python Not Found

**Symptoms:**
- "python3: command not found"
- Configuration features not working

**Solutions:**

1. **Install Python:**
   ```bash
   # Ubuntu/Debian/WSL
   sudo apt-get update && sudo apt-get install python3

   # macOS
   brew install python3

   # Windows
   # Download from https://www.python.org/downloads/
   # Make sure to check "Add Python to PATH" during installation
   ```

2. **Use defaults (fallback):**
   Hooks will work with default configuration even without Python

---

### Issue 5: Path Conversion Errors

**Symptoms:**
- "system cannot find the specified path" errors
- Audio files not found

**Solutions:**

1. **Test path utilities:**
   ```bash
   bash scripts/test-path-utils.sh
   ```

2. **Check environment detection:**
   ```bash
   source hooks/shared/path_utils.sh
   detect_environment
   # Should return: WSL, GIT_BASH, LINUX, MACOS, or CYGWIN
   ```

3. **Verify project path:**
   ```bash
   cat ~/.claude/hooks/.project_path
   # Should show valid path to project directory

   # Test if path exists
   ls -la "$(cat ~/.claude/hooks/.project_path)"
   ```

4. **Apply Windows fixes:**
   ```bash
   bash scripts/apply-windows-fix.sh
   ```

---

## 🔧 Advanced Configuration

### Customize Which Hooks Are Enabled

```bash
# Run interactive configuration
bash scripts/configure.sh

# Or manually edit config
nano config/user_preferences.json

# Set "enabled_hooks" -> "hook_name": true/false
# Example: disable PreToolUse and PostToolUse for less noise
```

---

### Change Audio Files

```bash
# Replace audio files in audio/default/ directory
# Keep same filenames:
# - notification-urgent.mp3
# - notification-info.mp3
# - task-complete.mp3
# - task-starting.mp3
# - task-progress.mp3
# - prompt-received.mp3
# - subagent-complete.mp3
# - session-start.mp3
# - session-end.mp3

# Or update config to point to custom files
nano config/user_preferences.json
# Edit "audio_files" section
```

---

### Adjust Audio Queue Settings

```bash
# Edit config/user_preferences.json
nano config/user_preferences.json

# Modify "playback_settings":
# - queue_enabled: true/false (prevent overlapping sounds)
# - debounce_ms: milliseconds to wait between sounds (default: 500)
```

---

## 🚫 Uninstallation

To completely remove Claude Code Audio Hooks:

```bash
# Run uninstall script
bash scripts/uninstall.sh

# This will:
# - Remove all hook scripts from ~/.claude/hooks/
# - Remove hooks from settings.json
# - Remove permissions from settings.local.json
# - Restore backups (if available)
# - Clean up temporary files

# Manual uninstall (if script fails):
rm -rf ~/.claude/hooks/*.sh
rm -rf ~/.claude/hooks/shared
rm -f ~/.claude/hooks/.project_path

# Then manually edit ~/.claude/settings.json to remove "hooks" section
# And ~/.claude/settings.local.json to remove hook permissions
```

---

## 📚 Additional Resources

### Documentation

- **[README.md](README.md)** - Project overview
- **[UTILITIES_README.md](UTILITIES_README.md)** - Utilities guide
- **[docs/PATH_UTILITIES.md](docs/PATH_UTILITIES.md)** - Path API reference
- **[docs/ENVIRONMENT_DETECTION.md](docs/ENVIRONMENT_DETECTION.md)** - Environment diagnostics

### Troubleshooting Guides

- **[WINDOWS_FIX_README.md](WINDOWS_FIX_README.md)** - Windows-specific issues
- **[QUICK_FIX_GUIDE.md](QUICK_FIX_GUIDE.md)** - Common quick fixes
- **[WINDOWS_INSTALLATION_ANALYSIS.md](WINDOWS_INSTALLATION_ANALYSIS.md)** - Detailed analysis

### Support

- **GitHub Issues:** https://github.com/ChanMeng666/claude-code-audio-hooks/issues
- **Discussions:** https://github.com/ChanMeng666/claude-code-audio-hooks/discussions

---

## 🤖 For AI Assistants

### Recommended Installation Procedure

When helping a user install this project, follow this sequence:

1. **Assess Environment:**
   ```bash
   bash scripts/detect-environment.sh
   ```
   Review output to understand user's setup.

2. **Run Complete Installation:**
   ```bash
   bash scripts/install-complete.sh
   ```
   This handles everything automatically.

3. **Verify Success:**
   ```bash
   bash scripts/check-setup.sh
   bash scripts/test-audio.sh
   ```

4. **If Issues:**
   - Check installation log: `/tmp/claude_hooks_install_*.log`
   - Run step-by-step installation (Method 2)
   - Consult troubleshooting section above

### Common AI Assistant Mistakes to Avoid

❌ **Don't:** Run individual steps out of order
✅ **Do:** Use install-complete.sh or follow exact order in Method 2

❌ **Don't:** Assume Python is python3 (might be python or py on Windows)
✅ **Do:** Use the get_python_cmd() function from path_utils.sh

❌ **Don't:** Use hardcoded paths like /c/Users/...
✅ **Do:** Use smart_path_convert() for cross-platform compatibility

❌ **Don't:** Forget to chmod +x hook scripts
✅ **Do:** Always make scripts executable after copying

❌ **Don't:** Skip environment detection
✅ **Do:** Always run detect-environment.sh first to understand the system

---

## 📊 Success Criteria

Installation is successful when ALL of these are true:

- ✅ `bash scripts/check-setup.sh` reports all checks passed
- ✅ `bash scripts/test-audio.sh` plays audio successfully
- ✅ `claude "test"` triggers audio notification
- ✅ Hook trigger log shows entries: `cat /tmp/claude_hooks_log/hook_triggers.log`
- ✅ No errors in installation log: `/tmp/claude_hooks_install_*.log`

---

## 🎯 Quick Reference

### One-Line Install (for AI to execute)

```bash
git clone https://github.com/ChanMeng666/claude-code-audio-hooks.git && cd claude-code-audio-hooks && bash scripts/install-complete.sh && bash scripts/test-audio.sh
```

### Verification Commands

```bash
# Check installation
bash scripts/check-setup.sh

# Test audio
bash scripts/test-audio.sh

# Test with Claude
claude "What is 2+2?"

# Check logs
cat /tmp/claude_hooks_log/hook_triggers.log
```

### Troubleshooting Commands

```bash
# Environment diagnostic
bash scripts/detect-environment.sh

# Path utilities test
bash scripts/test-path-utils.sh

# View installation log
ls -t /tmp/claude_hooks_install_*.log | head -1 | xargs cat

# Check settings
cat ~/.claude/settings.json | grep -A 10 hooks
cat ~/.claude/settings.local.json | grep -A 10 allowedTools
```

---

**Document Version:** 2.1.0
**Last Updated:** 2025-11-04
**Compatible With:** Claude Code 2.0+, All platforms (WSL, Git Bash, Cygwin, macOS, Linux)
**Installation Time:** 2-5 minutes
**Difficulty:** Easy (fully automated)
