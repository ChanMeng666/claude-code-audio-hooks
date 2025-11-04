# 🛠️ Utilities Overview

> **New cross-platform utilities for Claude Code Audio Hooks v2.1**

---

## 📋 Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Available Utilities](#available-utilities)
- [Installation](#installation)
- [Usage Examples](#usage-examples)
- [Documentation](#documentation)
- [Testing](#testing)

---

## 🎯 Overview

Version 2.1 introduces powerful new utilities to enhance cross-platform compatibility and debugging capabilities:

| Utility | Purpose | Status |
|---------|---------|--------|
| **Path Utilities** | Cross-platform path conversion | ✅ Complete |
| **Environment Detection** | Comprehensive environment diagnostics | ✅ Complete |
| **Test Suites** | Automated testing and validation | ✅ Complete |

These utilities were developed in response to user feedback about Windows PowerShell installation issues and provide:
- ✅ Robust path conversion for WSL, Git Bash, Cygwin, macOS, and Linux
- ✅ Intelligent environment detection and recommendations
- ✅ Comprehensive testing and validation tools
- ✅ Better error messages and diagnostics

---

## 🚀 Quick Start

### 1. Path Conversion (for developers)

```bash
# Source path utilities
source hooks/shared/path_utils.sh

# Detect environment
ENV=$(detect_environment)
echo "Running on: $ENV"

# Convert path for Windows audio playback
AUDIO_FILE="/c/Users/name/audio.mp3"
WIN_PATH=$(smart_path_convert "$AUDIO_FILE" "audio_playback")
powershell.exe -Command "Play-Audio '$WIN_PATH'"
```

### 2. Environment Detection (for users)

```bash
# Run comprehensive environment check
bash scripts/detect-environment.sh

# Generates:
# - Color-coded terminal output
# - Full report: /tmp/claude_hooks_env_report_*.txt
# - Compact summary: /tmp/claude_hooks_env_report_*_summary.txt
```

### 3. Testing (for verification)

```bash
# Test path conversion
bash scripts/test-path-utils.sh

# Test complete system
bash scripts/detect-environment.sh
bash scripts/test-audio.sh
```

---

## 🔧 Available Utilities

### 1. Path Utilities (`hooks/shared/path_utils.sh`)

**Purpose:** Cross-platform path conversion and handling

**Key Functions:**
- `detect_environment` - Detects OS/environment type
- `to_windows_path` - Convert Unix → Windows path
- `to_unix_path` - Convert Windows → Unix path
- `normalize_path` - Normalize path separators
- `smart_path_convert` - Context-aware conversion
- `path_exists` - Cross-platform path checking
- `get_absolute_path` - Resolve relative paths

**Why you need it:**
- Different environments use different path formats:
  - WSL: `/mnt/c/...` ↔ `C:/...`
  - Git Bash: `/c/...` ↔ `C:/...`
  - Cygwin: `/cygdrive/c/...` ↔ `C:/...`
- PowerShell requires Windows paths
- File operations require native paths
- Eliminates path-related errors

**Documentation:** [docs/PATH_UTILITIES.md](docs/PATH_UTILITIES.md)

---

### 2. Environment Detection (`scripts/detect-environment.sh`)

**Purpose:** Comprehensive environment diagnostics

**What it detects (12 steps):**
1. ✅ Operating system and environment type
2. ✅ Shell environment and configuration
3. ✅ Python installation (multiple locations)
4. ✅ Audio player capabilities
5. ✅ Claude Code installation
6. ✅ Directory structure and permissions
7. ✅ Project installation status
8. ✅ Claude settings configuration
9. ✅ Path conversion capabilities
10. ✅ Git installation
11. ✅ Dependency summary
12. ✅ Environment-specific recommendations

**Why you need it:**
- Diagnose installation issues
- Verify system compatibility
- Get actionable recommendations
- Generate bug reports
- Validate installation success

**Documentation:** [docs/ENVIRONMENT_DETECTION.md](docs/ENVIRONMENT_DETECTION.md)

---

### 3. Path Utilities Test Suite (`scripts/test-path-utils.sh`)

**Purpose:** Automated testing of path conversion functions

**What it tests:**
- ✅ Environment detection accuracy
- ✅ Unix to Windows path conversion
- ✅ Windows to Unix path conversion
- ✅ Path normalization
- ✅ Smart path conversion
- ✅ Real project path handling
- ✅ Performance benchmarks

**Output:**
```
================================================
  Path Utilities Test Suite
================================================

Environment: WSL
Tests Run:   13
Passed:      13
Failed:      0

✓ All tests passed!
```

**Why you need it:**
- Verify path utilities work on your system
- Catch compatibility issues early
- Performance benchmarking
- Regression testing

---

### 4. Updated Hook Configuration (`hooks/shared/hook_config_with_path_utils.sh`)

**Purpose:** Enhanced hook configuration with integrated path utilities

**Improvements:**
- ✅ Automatically loads path utilities
- ✅ Smart path conversion for audio playback
- ✅ Better Windows environment detection
- ✅ Fallback mechanisms for missing dependencies
- ✅ Improved error handling

**Why you need it:**
- More reliable audio playback on Windows
- Better error recovery
- Consistent behavior across environments

---

## 📦 Installation

### Option 1: Fresh Installation (Recommended)

If you're installing for the first time:

```bash
# Clone repository
git clone https://github.com/ChanMeng666/claude-code-audio-hooks.git
cd claude-code-audio-hooks

# Run environment detection (optional but recommended)
bash scripts/detect-environment.sh

# Install (includes all new utilities)
bash scripts/install.sh
```

---

### Option 2: Update Existing Installation

If you already have v2.0.0 installed:

```bash
# Navigate to existing installation
cd claude-code-audio-hooks

# Pull latest changes
git pull origin master

# No reinstallation needed! New utilities are standalone
# Test path utilities
bash scripts/test-path-utils.sh

# Run environment detection
bash scripts/detect-environment.sh
```

---

### Option 3: Manual Integration

If you want to integrate utilities into your own scripts:

```bash
# Copy path utilities
cp hooks/shared/path_utils.sh /your/project/

# Source in your script
source /your/project/path_utils.sh

# Use functions
ENV=$(detect_environment)
WIN_PATH=$(to_windows_path "/c/file.txt" "forward")
```

---

## 💡 Usage Examples

### Example 1: Audio Playback Script

```bash
#!/bin/bash
# Play audio with cross-platform path handling

source hooks/shared/path_utils.sh

AUDIO_FILE="/c/Users/name/notification.mp3"

# Detect environment
ENV=$(detect_environment)

# Convert path appropriately
case "$ENV" in
    WSL|GIT_BASH|CYGWIN)
        WIN_PATH=$(smart_path_convert "$AUDIO_FILE" "powershell")
        powershell.exe -Command "
            Add-Type -AssemblyName presentationCore
            \$player = New-Object System.Windows.Media.MediaPlayer
            \$player.Open('$WIN_PATH')
            \$player.Play()
            Start-Sleep -Seconds 3
        " &
        ;;
    MACOS)
        afplay "$AUDIO_FILE" &
        ;;
    LINUX)
        mpg123 -q "$AUDIO_FILE" &
        ;;
esac
```

---

### Example 2: Configuration Validator

```bash
#!/bin/bash
# Validate configuration files exist with cross-platform paths

source hooks/shared/path_utils.sh

CONFIG_FILE="C:\Users\name\.claude\settings.json"

# Convert to native path for file operations
NATIVE_PATH=$(to_unix_path "$CONFIG_FILE")

if path_exists "$NATIVE_PATH"; then
    echo "Configuration found: $NATIVE_PATH"

    # Get absolute path for logging
    ABS_PATH=$(get_absolute_path "$NATIVE_PATH")
    echo "Absolute path: $ABS_PATH"
else
    echo "Configuration not found!"
    exit 1
fi
```

---

### Example 3: Pre-Installation Check

```bash
#!/bin/bash
# Run checks before attempting installation

echo "Checking environment compatibility..."

if ! bash scripts/detect-environment.sh; then
    echo ""
    echo "⚠️ Environment check found issues."
    echo "Please review the report above."
    echo ""
    read -p "Continue with installation anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 1
    fi
fi

echo ""
echo "Running installation..."
bash scripts/install.sh
```

---

### Example 4: Automated Testing

```bash
#!/bin/bash
# Run all tests and generate report

REPORT_FILE="test_results_$(date +%Y%m%d_%H%M%S).txt"

echo "Running Test Suite" | tee "$REPORT_FILE"
echo "==================" | tee -a "$REPORT_FILE"
echo "" | tee -a "$REPORT_FILE"

# Test 1: Environment Detection
echo "Test 1: Environment Detection" | tee -a "$REPORT_FILE"
if bash scripts/detect-environment.sh >> "$REPORT_FILE" 2>&1; then
    echo "✓ PASS" | tee -a "$REPORT_FILE"
else
    echo "✗ FAIL" | tee -a "$REPORT_FILE"
fi

echo "" | tee -a "$REPORT_FILE"

# Test 2: Path Utilities
echo "Test 2: Path Utilities" | tee -a "$REPORT_FILE"
if bash scripts/test-path-utils.sh >> "$REPORT_FILE" 2>&1; then
    echo "✓ PASS" | tee -a "$REPORT_FILE"
else
    echo "✗ FAIL" | tee -a "$REPORT_FILE"
fi

echo "" | tee -a "$REPORT_FILE"

# Test 3: Audio Playback
echo "Test 3: Audio Playback" | tee -a "$REPORT_FILE"
if bash scripts/test-audio.sh >> "$REPORT_FILE" 2>&1; then
    echo "✓ PASS" | tee -a "$REPORT_FILE"
else
    echo "✗ FAIL" | tee -a "$REPORT_FILE"
fi

echo "" | tee -a "$REPORT_FILE"
echo "Report saved to: $REPORT_FILE"
```

---

## 📚 Documentation

### Complete Documentation

| Document | Description | Audience |
|----------|-------------|----------|
| **[docs/PATH_UTILITIES.md](docs/PATH_UTILITIES.md)** | Complete API reference for path utilities | Developers |
| **[docs/ENVIRONMENT_DETECTION.md](docs/ENVIRONMENT_DETECTION.md)** | Guide to environment detection | Users & Developers |
| **[WINDOWS_FIX_README.md](WINDOWS_FIX_README.md)** | Windows compatibility guide | Windows Users |
| **[QUICK_FIX_GUIDE.md](QUICK_FIX_GUIDE.md)** | Quick troubleshooting steps | All Users |
| **[WINDOWS_INSTALLATION_ANALYSIS.md](WINDOWS_INSTALLATION_ANALYSIS.md)** | Detailed problem analysis | Developers |

---

### Quick Reference

#### Path Utilities API

```bash
# Load utilities
source hooks/shared/path_utils.sh

# Environment
detect_environment                          # → WSL|GIT_BASH|LINUX|MACOS|CYGWIN

# Conversion
to_windows_path "/c/file.txt" "forward"    # → C:/file.txt
to_unix_path "C:\file.txt"                  # → /c/file.txt (or /mnt/c/ in WSL)
normalize_path "C:\foo\bar"                 # → C:/foo/bar

# Operations
path_exists "/c/file.txt"                   # → 0 (exists) or 1 (not found)
get_absolute_path "./relative"              # → /full/absolute/path

# Smart
smart_path_convert "/c/file" "audio_playback"  # → Context-aware conversion
```

#### Environment Detection

```bash
# Run detection
bash scripts/detect-environment.sh

# Check specific dependency
bash scripts/detect-environment.sh | grep "Python"
bash scripts/detect-environment.sh | grep "Claude Code"

# Get just the environment type
source hooks/shared/path_utils.sh
detect_environment  # → WSL|GIT_BASH|etc
```

---

## 🧪 Testing

### Test Path Utilities

```bash
bash scripts/test-path-utils.sh
```

**Expected:** All tests pass (13/13 on WSL, varies by platform)

---

### Test Environment Detection

```bash
bash scripts/detect-environment.sh
```

**Expected:**
- All 12 steps complete
- 0 missing required dependencies
- Report files generated in `/tmp/`

---

### Manual Testing

```bash
# Start interactive bash session
bash

# Load utilities
source hooks/shared/path_utils.sh

# Test functions interactively
detect_environment
to_windows_path "/c/Users/test/file.txt" "forward"
to_unix_path "C:\Users\test\file.txt"

# Test with real paths
AUDIO="/home/user/project/audio/file.mp3"
smart_path_convert "$AUDIO" "audio_playback"
```

---

## 🐛 Troubleshooting

### Path Utilities Issues

**Problem:** Path conversion returns unexpected format

**Solution:**
```bash
# Check environment detection
source hooks/shared/path_utils.sh
detect_environment  # Should return correct env type

# If wrong, force refresh
unset CLAUDE_HOOKS_ENV_TYPE
detect_environment
```

---

### Environment Detection Issues

**Problem:** Script hangs or takes too long

**Solution:**
```bash
# Run with timeout
timeout 60s bash scripts/detect-environment.sh

# Or check specific sections by editing the script
```

---

### Test Failures

**Problem:** Path utility tests fail

**Solution:**
1. Check that you're running tests in the correct environment (WSL, Git Bash, etc.)
2. Test expectations vary by environment - review test output carefully
3. File a bug report with test output and environment summary

---

## 🎯 Performance

### Benchmarks

Measured on WSL2 / Ubuntu 20.04:

| Operation | Time | Ops/sec |
|-----------|------|---------|
| detect_environment (cached) | < 0.1ms | 10,000+ |
| to_windows_path | 3-5ms | 200-300 |
| to_unix_path | 3-5ms | 200-300 |
| normalize_path | < 0.5ms | 2,000+ |
| smart_path_convert | 3-6ms | 170-300 |

### Optimization Tips

1. **Cache environment detection** - First call is slower
2. **Convert once, reuse** - Don't convert in loops
3. **Use normalize_path** for simple cases - Fastest option
4. **Batch path operations** - Convert multiple paths together

---

## 🔗 Integration with Existing Code

### Updating hook_config.sh

The new utilities are designed to integrate seamlessly:

```bash
# Option 1: Use updated version (recommended)
cp hooks/shared/hook_config_with_path_utils.sh hooks/shared/hook_config.sh

# Option 2: Add to existing hook_config.sh
# At the top of hook_config.sh, add:
source "$(dirname "${BASH_SOURCE[0]}")/path_utils.sh"

# Then use smart_path_convert in audio playback functions
```

---

## 🌟 Benefits

### For Users

- ✅ More reliable installation on Windows
- ✅ Better error messages
- ✅ Comprehensive diagnostics
- ✅ Easier troubleshooting
- ✅ Clear next steps when issues occur

### For Developers

- ✅ Robust cross-platform path handling
- ✅ Reusable utility functions
- ✅ Comprehensive test suite
- ✅ Better code maintainability
- ✅ Easier to add new features

---

## 📈 Version History

### v2.1 (Current)

- ✅ Added path utilities module
- ✅ Added environment detection script
- ✅ Added comprehensive test suites
- ✅ Enhanced hook configuration with path utilities
- ✅ Complete documentation

### v2.0

- Multiple hook support
- Configuration system
- Initial cross-platform support

### v1.0

- Single hook (stop_hook)
- Basic audio playback

---

## 🤝 Contributing

Found a bug or want to contribute?

1. **Report Issues:** https://github.com/ChanMeng666/claude-code-audio-hooks/issues
2. **Submit Pull Requests:** Include test results from all platforms
3. **Improve Documentation:** Help others understand the utilities

---

## 📞 Getting Help

1. **Check Documentation:**
   - [PATH_UTILITIES.md](docs/PATH_UTILITIES.md) for API reference
   - [ENVIRONMENT_DETECTION.md](docs/ENVIRONMENT_DETECTION.md) for diagnostics guide

2. **Run Diagnostics:**
   ```bash
   bash scripts/detect-environment.sh
   bash scripts/test-path-utils.sh
   ```

3. **File an Issue:**
   Include output from environment detection and test suites

---

**Utilities Version:** 2.1.0
**Last Updated:** 2025-11-04
**Compatibility:** WSL, Git Bash, Cygwin, macOS, Linux
**License:** MIT
