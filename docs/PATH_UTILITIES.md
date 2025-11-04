# 🛣️ Path Utilities Documentation

> **Cross-platform path conversion and handling for Claude Code Audio Hooks**

---

## 📚 Overview

The Path Utilities module provides robust, cross-platform path conversion functions to handle the complexities of working with file paths across different environments:

- **WSL** (Windows Subsystem for Linux): `/mnt/c/...` ↔ `C:/...`
- **Git Bash/MSYS**: `/c/...` ↔ `C:/...`
- **Cygwin**: Cygwin paths ↔ Windows paths
- **macOS/Linux**: Native Unix paths

---

## 🚀 Quick Start

```bash
# Source the path utilities
source hooks/shared/path_utils.sh

# Detect environment
ENV=$(detect_environment)
echo "Running on: $ENV"  # e.g., "WSL", "GIT_BASH", "LINUX"

# Convert path for PowerShell audio playback
AUDIO_FILE="/c/Users/name/audio.mp3"
WIN_PATH=$(smart_path_convert "$AUDIO_FILE" "audio_playback")
echo "$WIN_PATH"  # Output: C:/Users/name/audio.mp3

# Check if file exists (cross-platform)
if path_exists "$AUDIO_FILE"; then
    echo "File exists!"
fi
```

---

## 📖 Function Reference

### 1. detect_environment

Detects the current runtime environment.

**Signature:**
```bash
detect_environment
```

**Returns:**
- `WSL` - Windows Subsystem for Linux
- `GIT_BASH` - Git Bash / MSYS / MINGW
- `CYGWIN` - Cygwin
- `MACOS` - macOS
- `LINUX` - Native Linux
- `UNKNOWN` - Unrecognized environment

**Example:**
```bash
ENV=$(detect_environment)
case "$ENV" in
    WSL)
        echo "Running on Windows Subsystem for Linux"
        ;;
    GIT_BASH)
        echo "Running on Git Bash"
        ;;
    LINUX)
        echo "Running on native Linux"
        ;;
esac
```

**Caching:**
Result is cached in `$CLAUDE_HOOKS_ENV_TYPE` environment variable for performance.

---

### 2. to_windows_path

Converts Unix/Linux path to Windows path format.

**Signature:**
```bash
to_windows_path <path> [format]
```

**Parameters:**
- `path` - The path to convert
- `format` - (Optional) Output format:
  - `forward` - Forward slashes (default): `C:/Users/name`
  - `backslash` - Backslashes: `C:\Users\name`

**Returns:**
Windows-formatted path string

**Examples:**
```bash
# WSL: Convert /mnt/c/ or /c/ to C:/
to_windows_path "/c/Users/name/file.txt" "forward"
# Output: C:/Users/name/file.txt

to_windows_path "/mnt/c/Users/name/file.txt" "backslash"
# Output: C:\Users\name\file.txt

# Git Bash: Convert /c/ to C:/
to_windows_path "/c/Program Files/app.exe" "forward"
# Output: C:/Program Files/app.exe
```

**Behavior by Environment:**

| Environment | Input | Output (forward) | Output (backslash) |
|-------------|-------|------------------|---------------------|
| WSL | `/c/Users/file.txt` | `C:/Users/file.txt` | `C:\Users\file.txt` |
| WSL | `/mnt/c/Users/file.txt` | `C:/Users/file.txt` | `C:\Users\file.txt` |
| Git Bash | `/c/Users/file.txt` | `C:/Users/file.txt` | `C:\Users\file.txt` |
| Linux/macOS | `/home/user/file.txt` | `/home/user/file.txt` | `/home/user/file.txt` |

---

### 3. to_unix_path

Converts Windows path to Unix/Linux path format.

**Signature:**
```bash
to_unix_path <path>
```

**Parameters:**
- `path` - The Windows path to convert

**Returns:**
Unix-formatted path string

**Examples:**
```bash
# WSL: Convert to /mnt/c/ format
to_unix_path "C:\Users\name\file.txt"
# Output: /mnt/c/Users/name/file.txt

to_unix_path "D:/projects/app"
# Output: /mnt/d/projects/app

# Git Bash: Convert to /c/ format
to_unix_path "C:\Program Files\app.exe"
# Output: /c/Program Files/app.exe
```

**Behavior by Environment:**

| Environment | Input | Output |
|-------------|-------|--------|
| WSL | `C:\Users\file.txt` | `/mnt/c/Users/file.txt` |
| WSL | `C:/Users/file.txt` | `/mnt/c/Users/file.txt` |
| Git Bash | `C:\Users\file.txt` | `/c/Users/file.txt` |
| Cygwin | `C:\Users\file.txt` | `/cygdrive/c/Users/file.txt` |
| Linux/macOS | `C:\Users\file.txt` | `C:\Users\file.txt` (unchanged) |

---

### 4. normalize_path

Normalizes path separators to forward slashes.

**Signature:**
```bash
normalize_path <path>
```

**Parameters:**
- `path` - The path to normalize

**Returns:**
Path with all backslashes converted to forward slashes

**Examples:**
```bash
normalize_path "C:\Users\name\file.txt"
# Output: C:/Users/name/file.txt

normalize_path "/c/Users\name/file.txt"
# Output: /c/Users/name/file.txt
```

**Use Case:**
Useful for consistent path display and comparison:
```bash
path1=$(normalize_path "$user_input_path")
path2=$(normalize_path "$config_path")

if [ "$path1" = "$path2" ]; then
    echo "Paths match!"
fi
```

---

### 5. path_exists

Checks if a path exists, handling both Unix and Windows path formats.

**Signature:**
```bash
path_exists <path>
```

**Parameters:**
- `path` - The path to check (can be Unix or Windows format)

**Returns:**
- Exit code `0` if path exists
- Exit code `1` if path doesn't exist

**Examples:**
```bash
# Check with Unix path
if path_exists "/c/Users/name/file.txt"; then
    echo "File exists!"
fi

# Check with Windows path
if path_exists "C:\Users\name\file.txt"; then
    echo "File exists!"
fi

# Use in conditional
[ path_exists "$audio_file" ] && play_audio "$audio_file"
```

**How it works:**
1. First tries the path as-is
2. If not found, converts to Unix format and tries again
3. Returns success if found in either format

---

### 6. get_absolute_path

Resolves a relative path to an absolute path.

**Signature:**
```bash
get_absolute_path <path>
```

**Parameters:**
- `path` - The relative or absolute path

**Returns:**
Absolute path string

**Examples:**
```bash
# Resolve relative path
get_absolute_path "./audio/file.mp3"
# Output: /home/user/project/audio/file.mp3

# Handle already absolute path
get_absolute_path "/home/user/file.txt"
# Output: /home/user/file.txt

# Resolve parent directory references
get_absolute_path "../config/settings.json"
# Output: /home/user/config/settings.json
```

**Methods used (in order of preference):**
1. `realpath` command (if available)
2. `readlink -f` command (if available)
3. Fallback: `cd` and `pwd`

---

### 7. smart_path_convert

Automatically converts path based on context and environment.

**Signature:**
```bash
smart_path_convert <path> [context]
```

**Parameters:**
- `path` - The path to convert
- `context` - (Optional) The use case:
  - `audio_playback` - For audio player tools
  - `file_operation` - For file operations
  - `powershell` - For PowerShell commands
  - `auto` - Auto-detect (default)

**Returns:**
Appropriately formatted path for the context

**Examples:**
```bash
# Audio playback (needs Windows path on Windows systems)
AUDIO_FILE="/c/Users/name/notification.mp3"
WIN_PATH=$(smart_path_convert "$AUDIO_FILE" "audio_playback")
powershell.exe -Command "Play-Audio '$WIN_PATH'"

# File operation (needs Unix path in Unix-like environments)
FILE="/c/Users/name/config.json"
UNIX_FILE=$(smart_path_convert "$FILE" "file_operation")
cat "$UNIX_FILE"

# PowerShell command (always needs Windows path with forward slashes)
SCRIPT="/c/Users/name/script.ps1"
PS_PATH=$(smart_path_convert "$SCRIPT" "powershell")
powershell.exe -File "$PS_PATH"
```

**Behavior Matrix:**

| Environment | Context | Input | Output |
|-------------|---------|-------|--------|
| WSL | audio_playback | `/c/Users/file.mp3` | `C:/Users/file.mp3` |
| WSL | file_operation | `C:/Users/file.txt` | `/mnt/c/Users/file.txt` |
| Git Bash | audio_playback | `/c/Users/file.mp3` | `C:/Users/file.mp3` |
| Linux | audio_playback | `/home/user/file.mp3` | `/home/user/file.mp3` |

---

### 8. test_path_conversion

Runs test suite on path conversion functions.

**Signature:**
```bash
test_path_conversion
```

**Returns:**
Prints test results to stdout

**Example:**
```bash
source hooks/shared/path_utils.sh
test_path_conversion
```

**Output:**
```
Testing path conversion utilities...

Environment: WSL

Test Results:
-------------
Input: /c/Users/test/file.txt
  → to_windows_path: C:/Users/test/file.txt
  → to_unix_path: /c/Users/test/file.txt
  → normalize_path: /c/Users/test/file.txt
  → smart_path_convert (audio): C:/Users/test/file.txt
...
```

---

### 9. print_path_help

Prints help information for path utilities.

**Signature:**
```bash
print_path_help
```

**Returns:**
Prints help text to stdout

**Example:**
```bash
source hooks/shared/path_utils.sh
print_path_help
```

---

## 🧪 Testing

### Run Full Test Suite

```bash
bash scripts/test-path-utils.sh
```

**Expected Output:**
```
================================================
  Path Utilities Test Suite
================================================

=== Environment Detection ===
Environment Type: WSL

=== Path Conversion Tests ===
Testing WSL environment path conversions...

Testing WSL: /c/ to Windows (forward)... ✓ PASS
Testing WSL: /c/ to Windows (backslash)... ✓ PASS
...

================================================
  Test Results
================================================

Environment: WSL
Tests Run:   13
Passed:      13
Failed:      0

✓ All tests passed!
```

### Manual Testing

```bash
# Interactive testing
source hooks/shared/path_utils.sh

# Test environment detection
detect_environment

# Test path conversion
to_windows_path "/c/Users/test/file.txt" "forward"
to_unix_path "C:\Users\test\file.txt"

# Run built-in tests
test_path_conversion
```

---

## 🔧 Integration Example

### Using in Hook Scripts

```bash
#!/bin/bash
# Example hook script using path utilities

# Source path utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shared/path_utils.sh"

# Get audio file path
AUDIO_FILE="/home/user/project/audio/notification.mp3"

# Convert for PowerShell audio playback
WIN_PATH=$(smart_path_convert "$AUDIO_FILE" "audio_playback")

# Detect environment
ENV=$(detect_environment)

# Play audio based on environment
case "$ENV" in
    WSL|GIT_BASH|CYGWIN)
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

### Using in Configuration Scripts

```bash
#!/bin/bash
# Configuration script example

source hooks/shared/path_utils.sh

# Get project directory (may be in various path formats)
PROJECT_DIR=$(cat ~/.claude/hooks/.project_path)

# Normalize for consistent handling
PROJECT_DIR=$(normalize_path "$PROJECT_DIR")

# Check if project exists
if path_exists "$PROJECT_DIR"; then
    echo "Project found at: $PROJECT_DIR"

    # Get absolute path for audio directory
    AUDIO_DIR=$(get_absolute_path "$PROJECT_DIR/audio/default")

    echo "Audio files location: $AUDIO_DIR"
else
    echo "Error: Project directory not found"
    exit 1
fi
```

---

## 🐛 Troubleshooting

### Issue: Path conversion returns wrong format

**Problem:**
```bash
to_windows_path "/c/Users/file.txt" "forward"
# Expected: C:/Users/file.txt
# Got: /c/Users/file.txt
```

**Solution:**
Check environment detection:
```bash
detect_environment
# Should return: WSL, GIT_BASH, etc.
# If returns LINUX or UNKNOWN, path conversion won't work
```

---

### Issue: wslpath not found in WSL

**Problem:**
```
wslpath: command not found
```

**Solution:**
The function will fall back to manual conversion. Update WSL:
```bash
# In PowerShell (as Administrator)
wsl --update

# Or reinstall WSL utilities
sudo apt-get install --reinstall wsl
```

---

### Issue: Performance is slow

**Problem:**
Path conversion taking too long (> 10ms per conversion)

**Solution:**
Environment detection is cached. Force re-detection:
```bash
unset CLAUDE_HOOKS_ENV_TYPE
detect_environment
```

Or check for command availability issues:
```bash
# Check if path tools are available
command -v wslpath   # For WSL
command -v cygpath   # For Cygwin
command -v realpath  # For absolute paths
```

---

### Issue: Paths with spaces fail

**Problem:**
```bash
AUDIO="/c/Program Files/audio.mp3"
WIN_PATH=$(smart_path_convert "$AUDIO" "audio_playback")
# Path gets truncated at space
```

**Solution:**
Always quote variables:
```bash
WIN_PATH=$(smart_path_convert "$AUDIO" "audio_playback")
powershell.exe -Command "Play-Audio '$WIN_PATH'"
#                                     ^-------^  Quote the variable
```

---

## 📊 Performance Characteristics

Based on benchmarks on WSL2 / Ubuntu 20.04:

| Function | Average Time | Operations/sec |
|----------|--------------|----------------|
| detect_environment (cached) | < 0.1ms | 10,000+ |
| detect_environment (uncached) | ~5ms | 200 |
| to_windows_path | 3-5ms | 200-300 |
| to_unix_path | 3-5ms | 200-300 |
| normalize_path | < 0.5ms | 2,000+ |
| smart_path_convert | 3-6ms | 170-300 |
| path_exists | 1-3ms | 300-1,000 |

**Optimization Tips:**
1. Environment detection is cached - first call is slower
2. Use `normalize_path` when you just need consistent separators (fastest)
3. Avoid calling `smart_path_convert` in loops - convert once, reuse result

---

## 🔗 Related Documentation

- **[WINDOWS_FIX_README.md](../WINDOWS_FIX_README.md)** - Windows compatibility overview
- **[QUICK_FIX_GUIDE.md](../QUICK_FIX_GUIDE.md)** - Quick fixes for path issues
- **[Environment Detection Script](../scripts/detect-environment.sh)** - Full environment diagnostics

---

## 📝 API Summary

```bash
# Environment
detect_environment              → string

# Path Conversion
to_windows_path <path> [format] → string
to_unix_path <path>             → string
normalize_path <path>           → string

# Path Operations
path_exists <path>              → exit code (0 or 1)
get_absolute_path <path>        → string

# Smart Conversion
smart_path_convert <path> [ctx] → string

# Testing & Help
test_path_conversion            → void (prints to stdout)
print_path_help                 → void (prints to stdout)
```

---

**Version:** 2.0.1
**Last Updated:** 2025-11-04
**Compatibility:** WSL, Git Bash, Cygwin, macOS, Linux
