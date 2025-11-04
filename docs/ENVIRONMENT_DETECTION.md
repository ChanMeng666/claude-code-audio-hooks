# 🔍 Environment Detection Guide

> **Comprehensive environment detection and diagnostics for Claude Code Audio Hooks**

---

## 📚 Overview

The Environment Detection Script (`scripts/detect-environment.sh`) is a comprehensive diagnostic tool that:

- ✅ Detects your operating system and environment type
- ✅ Verifies all required dependencies
- ✅ Checks installation status
- ✅ Tests path conversion capabilities
- ✅ Provides actionable recommendations
- ✅ Generates detailed reports for troubleshooting

---

## 🚀 Quick Start

```bash
cd claude-code-audio-hooks
bash scripts/detect-environment.sh
```

**Output:** A comprehensive 12-step analysis of your environment with color-coded status indicators.

---

## 📊 What It Detects

### 1. Operating System (Step 1/12)

Detects and reports:
- Environment type: WSL, Git Bash, Cygwin, macOS, Linux, or Unknown
- OS details: Version numbers, distribution names
- For Windows environments: Windows version

**Example Output:**
```
[1/12] Detecting Operating System...
✓ Windows Subsystem for Linux v2
  Windows: Microsoft Windows [Version 10.0.22000.1219]
  Linux: Ubuntu 20.04.5 LTS

Environment Type: WSL
OS Type: linux-gnu
```

---

### 2. Shell Environment (Step 2/12)

Checks:
- Current shell ($SHELL)
- Bash version
- Zsh version (if applicable)
- Shell configuration files (.bashrc, .bash_profile, .profile)

**Example Output:**
```
[2/12] Detecting Shell Environment...
ℹ Shell: /bin/bash
ℹ Bash Version: 5.0.17(1)-release
✓ .bashrc found
✓ .bash_profile found
```

---

### 3. Python Installation (Step 3/12)

Searches for:
- python3, python, py commands
- Python version validation (must be Python 3)
- Common Windows installation paths:
  - `/c/Python3*/python.exe`
  - `/c/Program Files/Python3*/python.exe`
  - `/d/Python/Python3*/python.exe`
  - `AppData/Local/Programs/Python/`

**Example Output:**
```
[3/12] Detecting Python Installation...
✓ Found: python3 (Python 3.10.6) at /usr/bin/python3
✓ Found: python (Python 3.10.6) at /usr/bin/python
✓ Recommended Python command: python3
```

---

### 4. Audio Player Capabilities (Step 4/12)

Checks for audio playback tools by environment:

**Windows (WSL/Git Bash/Cygwin):**
- PowerShell availability and version
- Windows Media Player

**macOS:**
- afplay (default audio player)

**Linux:**
- mpg123 (recommended for MP3)
- aplay (ALSA)
- ffplay (ffmpeg)
- paplay (PulseAudio)

**Example Output:**
```
[4/12] Detecting Audio Playback Capabilities...
ℹ Windows environment detected, checking PowerShell...
✓ PowerShell available (v7.2.6)
ℹ   Will use Windows Media Player via PowerShell
ℹ   Windows Media Player available as fallback
```

---

### 5. Claude Code Detection (Step 5/12)

Verifies:
- Claude Code installation
- Version number
- Installation path

**Example Output:**
```
[5/12] Detecting Claude Code...
✓ Claude Code installed: 2.0.32 (Claude Code)
ℹ   Location: /usr/local/bin/claude
```

---

### 6. Directory Structure (Step 6/12)

Checks:
- `~/.claude` configuration directory
- `~/.claude/hooks` directory
- Count and list of installed hook scripts
- File permissions

**Example Output:**
```
[6/12] Checking Directory Structure...
✓ Claude config directory exists: ~/.claude
ℹ   Permissions: drwxr-xr-x
✓ Hooks directory exists: ~/.claude/hooks
ℹ   Hook scripts installed: 9
ℹ     - notification_hook.sh (401B)
ℹ     - stop_hook.sh (324B)
ℹ     - pretooluse_hook.sh (346B)
    ...
```

---

### 7. Project Installation (Step 7/12)

Validates:
- `.project_path` file exists and contains valid path
- Project directory structure
- Audio files directory and count
- Audio file sizes
- Config directory and user preferences

**Example Output:**
```
[7/12] Checking Project Installation...
✓ Project path recorded: /home/user/claude-code-audio-hooks
✓ Project directory exists
✓ Audio directory found with 9 MP3 files
ℹ   Audio files:
ℹ     - notification-urgent.mp3 (30.7K)
ℹ     - task-complete.mp3 (20.4K)
    ...
✓ Config directory found
✓ User preferences file exists
```

---

### 8. Claude Settings (Step 8/12)

Examines:
- `~/.claude/settings.json` existence and content
- Hook configuration entries
- `~/.claude/settings.local.json` for permissions
- allowedTools configuration

**Example Output:**
```
[8/12] Checking Claude Settings...
✓ settings.json exists
✓ Hooks configured in settings.json (9 entries)
ℹ   Configured hooks:
ℹ     - ~/.claude/hooks/notification_hook.sh
ℹ     - ~/.claude/hooks/stop_hook.sh
    ...
✓ settings.local.json exists
✓ Hook permissions configured (9 entries)
```

---

### 9. Path Conversion Testing (Step 9/12)

Tests path conversion capabilities:

**For Windows environments (WSL/Git Bash/Cygwin):**
- Tests wslpath / cygpath availability
- Validates path conversion accuracy
- Shows example conversions

**For Unix environments:**
- Confirms no conversion needed

**Example Output:**
```
[9/12] Testing Path Conversion...
ℹ Testing path conversion for Windows environment...
✓ wslpath available
ℹ   Test: /c/Users/test/file.mp3 → C:\Users\test\file.mp3
```

---

### 10. Git Check (Step 10/12)

Verifies:
- Git installation
- Git version
- Git location

**Example Output:**
```
[10/12] Checking Git...
✓ git version 2.34.1
ℹ   Location: /usr/bin/git
```

---

### 11. Dependency Summary (Step 11/12)

Provides a comprehensive dependency checklist:

**Required Dependencies:**
- Claude Code
- Git

**Optional Dependencies:**
- Python 3
- Audio Player

**Example Output:**
```
[11/12] Dependency Summary...

Required Dependencies:
✓ Claude Code: Installed
✓ Git: Installed

Optional Dependencies:
✓ Python 3: Installed (python3)
✓ Audio Player: Available (PowerShell/MediaPlayer)

Status: 4 OK, 0 Missing, 0 Optional
```

---

### 12. Recommendations (Step 12/12)

Provides environment-specific recommendations and next steps:

**Example for Git Bash:**
```
[12/12] Recommendations & Next Steps...

✓ Git Bash detected - Good compatibility

Recommendations:
  1. Ensure Git for Windows is up to date
     Download: https://gitforwindows.org/
  2. If you encounter issues, consider using WSL
     Install: wsl --install (in PowerShell as Administrator)
```

**Example for WSL:**
```
✓ WSL detected - Excellent compatibility

Recommendations:
  1. Ensure wslpath is accessible (should be by default)
  2. If audio doesn't work, ensure PowerShell is accessible:
     $ powershell.exe -Command 'Write-Host "Test"'
```

---

## 📄 Generated Reports

The script generates two report files:

### 1. Full Report

**Location:** `/tmp/claude_hooks_env_report_YYYYMMDD_HHMMSS.txt`

Contains:
- Complete output of all 12 detection steps
- All status messages and checks
- Detailed recommendations

**Use case:** Full troubleshooting, sharing with developers

---

### 2. Compact Summary

**Location:** `/tmp/claude_hooks_env_report_YYYYMMDD_HHMMSS_summary.txt`

Contains:
- Environment type
- Dependency status (one-line summary)
- Installation status
- Quick links to documentation

**Example Content:**
```
Claude Code Audio Hooks - Environment Summary
Generated: 2025-11-04 15:30:45

Environment: WSL (linux-gnu)
Claude Code: Installed (2.0.32 (Claude Code))
Python: Available (python3 Python 3.10.6)
Audio Player: Available (PowerShell/MediaPlayer)
Git: Installed (git version 2.34.1)

Dependencies: 4 OK, 0 Missing, 0 Optional

Installation Status:
  - Hooks Directory: Exists
  - Project Path: /home/user/claude-code-audio-hooks
  - Settings: Configured

For detailed report, see: /tmp/claude_hooks_env_report_20251104_153045.txt
For troubleshooting, see: WINDOWS_FIX_README.md, QUICK_FIX_GUIDE.md
For issues: https://github.com/ChanMeng666/claude-code-audio-hooks/issues
```

**Use case:** Quick status check, including in bug reports

---

## 🎯 Common Use Cases

### Use Case 1: Before Installation

**Purpose:** Verify system compatibility before installing

```bash
# Clone the repository
git clone https://github.com/ChanMeng666/claude-code-audio-hooks.git
cd claude-code-audio-hooks

# Run environment detection
bash scripts/detect-environment.sh

# Review recommendations before proceeding with installation
```

**What to look for:**
- ✅ Claude Code is installed
- ✅ Git is installed
- ⚠️ Note any missing optional dependencies

---

### Use Case 2: Troubleshooting Installation Issues

**Purpose:** Diagnose why installation failed

```bash
# After failed installation, run detection
bash scripts/detect-environment.sh

# Review the report
cat /tmp/claude_hooks_env_report_*.txt

# Look for:
# - Missing dependencies
# - Permission issues
# - Path conversion problems
```

**Common issues revealed:**
- Python not found → Install Python 3
- Hooks directory doesn't exist → Installation didn't complete
- Path conversion failing → Environment detection issue

---

### Use Case 3: Verifying Installation Success

**Purpose:** Confirm everything is properly installed

```bash
# After running install.sh
bash scripts/detect-environment.sh

# Should show:
# ✓ Project path recorded
# ✓ Audio directory found with 9 MP3 files
# ✓ Hooks configured in settings.json
# ✓ Hook permissions configured
```

---

### Use Case 4: Preparing Bug Report

**Purpose:** Gather information for GitHub issue

```bash
# Run detection and generate report
bash scripts/detect-environment.sh

# Copy summary
cat /tmp/claude_hooks_env_report_*_summary.txt

# Attach to GitHub issue along with error messages
```

---

### Use Case 5: Performance Diagnostics

**Purpose:** Check if system is configured optimally

```bash
# Run detection
bash scripts/detect-environment.sh

# Check for:
# - Recommended Python command being used
# - Optimal audio player available
# - Path conversion working correctly
```

---

## 🔧 Advanced Usage

### Running Specific Checks Only

You can modify the script to run specific sections. Edit `scripts/detect-environment.sh` and comment out unwanted sections:

```bash
# Comment out sections you don't need
# print_section "[1/12] Detecting Operating System..."
# ...

print_section "[3/12] Detecting Python Installation..."
# Only run Python detection
...
```

---

### Automating Detection

Run as part of CI/CD or automated testing:

```bash
# Run detection and capture exit code
if bash scripts/detect-environment.sh > /dev/null 2>&1; then
    echo "Environment OK"
    exit 0
else
    echo "Environment issues detected"
    exit 1
fi
```

**Exit Codes:**
- `0` - All required dependencies met
- `1` - Missing required dependencies

---

### Integration with Installation Script

Add detection before installation:

```bash
#!/bin/bash
# Custom installation script

# Run detection first
echo "Checking environment..."
if ! bash scripts/detect-environment.sh; then
    echo "Environment check failed. Please review the report."
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    [[ ! $REPLY =~ ^[Yy]$ ]] && exit 1
fi

# Proceed with installation
bash scripts/install.sh
```

---

## 🐛 Troubleshooting the Detection Script

### Issue: Script fails to run

**Error:**
```
bash: scripts/detect-environment.sh: Permission denied
```

**Solution:**
```bash
chmod +x scripts/detect-environment.sh
bash scripts/detect-environment.sh
```

---

### Issue: Colors not displaying

**Problem:**
Terminal doesn't show colors, output has escape codes like `[0;32m`

**Solution:**
Your terminal doesn't support ANSI colors. Pipe through `cat`:
```bash
bash scripts/detect-environment.sh | cat
```

Or disable colors by editing the script:
```bash
# At the top of detect-environment.sh, add:
FORCE_NO_COLOR=1
```

---

### Issue: wslpath errors in WSL

**Error:**
```
wslpath: command not found
```

**Solution:**
The script will fall back to manual conversion. To fix permanently:
```bash
# Update WSL
wsl --update    # In PowerShell

# Or reinstall WSL utilities
sudo apt-get install --reinstall wslu
```

---

### Issue: Detection takes too long

**Problem:**
Script hangs or takes > 1 minute

**Possible causes:**
1. Slow file system (especially in WSL accessing Windows drives)
2. Network timeout (if checking online resources)
3. Large number of Python installations to check

**Solution:**
```bash
# Run with timeout
timeout 60s bash scripts/detect-environment.sh
```

---

## 📊 Understanding the Output

### Status Indicators

| Symbol | Meaning | Color | Description |
|--------|---------|-------|-------------|
| ✓ | Success | Green | Check passed, no issues |
| ✗ | Error | Red | Critical issue, action required |
| ⚠ | Warning | Yellow | Non-critical issue or missing optional feature |
| ℹ | Info | Cyan | Informational message |
| ▶ | Section | Magenta | Beginning of new section |

---

### Dependency Status

**"4 OK, 0 Missing, 0 Optional"**
- **OK:** Dependencies found and working
- **Missing:** Critical dependencies not found
- **Optional:** Non-critical dependencies missing

**Interpretation:**
- `0 Missing` → Ready to install
- `> 0 Missing` → Install missing dependencies first
- `> 0 Optional` → Some features may not work

---

### Installation Status

**"Project path recorded"**
- ✓ Means `.project_path` file exists
- Shows path to project directory
- Hooks can find audio files

**"Hooks configured"**
- ✓ Means hooks are in `settings.json`
- Shows number of configured hooks
- Claude Code will trigger hooks

---

## 🔗 Related Tools

### Companion Scripts

1. **`scripts/test-path-utils.sh`**
   - Tests path conversion functions
   - Run after environment detection to verify path handling
   ```bash
   bash scripts/test-path-utils.sh
   ```

2. **`scripts/check-setup.sh`**
   - Validates installation completeness
   - Run after installation
   ```bash
   bash scripts/check-setup.sh
   ```

3. **`scripts/test-audio.sh`**
   - Tests audio playback
   - Run to verify audio system works
   ```bash
   bash scripts/test-audio.sh
   ```

---

### Running All Diagnostics

```bash
# Complete diagnostic suite
echo "=== Environment Detection ==="
bash scripts/detect-environment.sh

echo ""
echo "=== Path Utilities Test ==="
bash scripts/test-path-utils.sh

echo ""
echo "=== Audio Test ==="
bash scripts/test-audio.sh

echo ""
echo "=== Installation Check ==="
bash scripts/check-setup.sh
```

---

## 📚 Additional Resources

- **[PATH_UTILITIES.md](PATH_UTILITIES.md)** - Path conversion documentation
- **[WINDOWS_FIX_README.md](../WINDOWS_FIX_README.md)** - Windows-specific fixes
- **[QUICK_FIX_GUIDE.md](../QUICK_FIX_GUIDE.md)** - Quick troubleshooting steps
- **[README.md](../README.md)** - Main project documentation

---

## 💡 Tips

1. **Run before installation** to catch issues early
2. **Save the report** when filing bug reports
3. **Run after system updates** to verify compatibility
4. **Check recommendations** - they're environment-specific
5. **Use the summary** for quick status checks

---

**Script Version:** 2.0.1
**Last Updated:** 2025-11-04
**Compatibility:** WSL, Git Bash, Cygwin, macOS, Linux
