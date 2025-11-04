#!/bin/bash
# Claude Code Audio Hooks - Environment Detection Script
# Automatically detect the runtime environment and provide recommendations
# Version: 2.0.1

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
RESET='\033[0m'

# Helper functions
print_header() { echo -e "${BLUE}${BOLD}$1${RESET}"; }
print_success() { echo -e "${GREEN}✓${RESET} $1"; }
print_warning() { echo -e "${YELLOW}⚠${RESET} $1"; }
print_error() { echo -e "${RED}✗${RESET} $1"; }
print_info() { echo -e "${CYAN}ℹ${RESET} $1"; }
print_section() { echo -e "\n${MAGENTA}▶${RESET} ${BOLD}$1${RESET}"; }

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Output file for report
REPORT_FILE="/tmp/claude_hooks_env_report_$(date +%Y%m%d_%H%M%S).txt"

# Start output capture for report
exec > >(tee "$REPORT_FILE")

echo ""
echo "================================================"
print_header "  Claude Code Audio Hooks"
print_header "  Environment Detection & Diagnostics"
echo "================================================"
echo ""
print_info "Report will be saved to: $REPORT_FILE"
echo ""

# =============================================================================
# STEP 1: Operating System Detection
# =============================================================================

print_section "[1/12] Detecting Operating System..."

ENV_TYPE="UNKNOWN"
OS_DETAILS=""

# Detect OS type
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if grep -qi microsoft /proc/version 2>/dev/null; then
        ENV_TYPE="WSL"
        WSL_VERSION=$(grep -oP 'WSL\s*\K\d+' /proc/version 2>/dev/null || echo "1")
        OS_DETAILS="Windows Subsystem for Linux v$WSL_VERSION"

        # Get Windows version
        if command -v cmd.exe &> /dev/null; then
            WIN_VER=$(cmd.exe /c ver 2>/dev/null | tr -d '\r\n')
            OS_DETAILS="$OS_DETAILS\n  Windows: $WIN_VER"
        fi

        # Get Linux distribution
        if [ -f /etc/os-release ]; then
            LINUX_DIST=$(grep PRETTY_NAME /etc/os-release | cut -d'"' -f2)
            OS_DETAILS="$OS_DETAILS\n  Linux: $LINUX_DIST"
        fi

        print_success "$OS_DETAILS"
    else
        ENV_TYPE="LINUX"
        if [ -f /etc/os-release ]; then
            OS_DETAILS=$(grep PRETTY_NAME /etc/os-release | cut -d'"' -f2)
            print_success "Native Linux: $OS_DETAILS"
        else
            print_success "Native Linux"
        fi
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    ENV_TYPE="MACOS"
    MACOS_VERSION=$(sw_vers -productVersion 2>/dev/null || echo "Unknown")
    OS_DETAILS="macOS $MACOS_VERSION"
    print_success "$OS_DETAILS"
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "mingw"* ]]; then
    ENV_TYPE="GIT_BASH"
    OS_DETAILS="Git Bash / MSYS / MINGW (Windows)"

    # Get Windows version
    if command -v cmd.exe &> /dev/null || command -v cmd &> /dev/null; then
        WIN_VER=$(cmd.exe /c ver 2>/dev/null || cmd /c ver 2>/dev/null | tr -d '\r\n')
        OS_DETAILS="$OS_DETAILS\n  $WIN_VER"
    fi

    print_success "$OS_DETAILS"
elif [[ "$OSTYPE" == "cygwin" ]]; then
    ENV_TYPE="CYGWIN"
    OS_DETAILS="Cygwin (Windows compatibility layer)"
    print_success "$OS_DETAILS"
else
    ENV_TYPE="UNKNOWN"
    OS_DETAILS="Unknown OS: $OSTYPE"
    print_warning "$OS_DETAILS"
fi

echo "  Environment Type: $ENV_TYPE"
echo "  OS Type: $OSTYPE"
echo ""

# =============================================================================
# STEP 2: Shell Detection
# =============================================================================

print_section "[2/12] Detecting Shell Environment..."

print_info "Shell: $SHELL"
print_info "Bash Version: $BASH_VERSION"

if [ -n "$ZSH_VERSION" ]; then
    print_info "Zsh Version: $ZSH_VERSION"
fi

# Check for common shell configurations
if [ -f "$HOME/.bashrc" ]; then
    print_success ".bashrc found"
fi

if [ -f "$HOME/.bash_profile" ]; then
    print_success ".bash_profile found"
fi

if [ -f "$HOME/.profile" ]; then
    print_success ".profile found"
fi

echo ""

# =============================================================================
# STEP 3: Python Detection
# =============================================================================

print_section "[3/12] Detecting Python Installation..."

PYTHON_CMD=""
PYTHON_VERSION=""
PYTHON_PATHS=()

# Try different Python commands
for cmd in python3 python py; do
    if command -v "$cmd" &> /dev/null; then
        version=$("$cmd" --version 2>&1)
        path=$(command -v "$cmd")

        if [[ "$version" == *"Python 3"* ]]; then
            if [ -z "$PYTHON_CMD" ]; then
                PYTHON_CMD="$cmd"
                PYTHON_VERSION="$version"
            fi
            print_success "Found: $cmd ($version) at $path"
            PYTHON_PATHS+=("$cmd:$path:$version")
        else
            print_info "Found: $cmd ($version) - Python 2 (not compatible)"
        fi
    fi
done

# Check common Windows installation paths
if [[ "$ENV_TYPE" == "WSL" ]] || [[ "$ENV_TYPE" == "GIT_BASH" ]] || [[ "$ENV_TYPE" == "CYGWIN" ]]; then
    print_info "Checking common Windows Python installation paths..."

    for py_pattern in \
        "/c/Python3*/python.exe" \
        "/c/Program Files/Python3*/python.exe" \
        "/d/Python/Python3*/python.exe" \
        "/c/Users/*/AppData/Local/Programs/Python/Python3*/python.exe"
    do
        for py_path in $py_pattern; do
            if [ -f "$py_path" ]; then
                version=$("$py_path" --version 2>&1)
                print_info "  Found at: $py_path ($version)"
                PYTHON_PATHS+=("$py_path:$py_path:$version")
            fi
        done
    done
fi

if [ -z "$PYTHON_CMD" ]; then
    print_error "No Python 3 found"
    print_warning "Recommendation: Install Python 3 from https://www.python.org/downloads/"
    PYTHON_AVAILABLE=false
else
    print_success "Recommended Python command: $PYTHON_CMD"
    PYTHON_AVAILABLE=true
fi

echo ""

# =============================================================================
# STEP 4: Audio Player Detection
# =============================================================================

print_section "[4/12] Detecting Audio Playback Capabilities..."

AUDIO_PLAYERS=()

case "$ENV_TYPE" in
    WSL|GIT_BASH|CYGWIN)
        print_info "Windows environment detected, checking PowerShell..."

        if command -v powershell.exe &> /dev/null; then
            PS_VERSION=$(powershell.exe -Command "\$PSVersionTable.PSVersion.ToString()" 2>/dev/null | tr -d '\r\n')
            print_success "PowerShell available (v$PS_VERSION)"
            print_info "  Will use Windows Media Player via PowerShell"
            AUDIO_PLAYERS+=("PowerShell/MediaPlayer")
        else
            print_error "PowerShell not found"
            print_warning "Audio playback may not work"
        fi

        # Check for Windows Media Player
        if command -v powershell.exe &> /dev/null; then
            WMP_CHECK=$(powershell.exe -Command "Test-Path 'C:\Program Files\Windows Media Player\wmplayer.exe'" 2>/dev/null | tr -d '\r\n')
            if [ "$WMP_CHECK" = "True" ]; then
                print_info "  Windows Media Player available as fallback"
            fi
        fi
        ;;

    MACOS)
        if command -v afplay &> /dev/null; then
            print_success "afplay available (default macOS audio player)"
            AUDIO_PLAYERS+=("afplay")
        else
            print_error "afplay not found (unusual for macOS)"
        fi
        ;;

    LINUX)
        audio_found=false

        # Check for various Linux audio players
        if command -v mpg123 &> /dev/null; then
            print_success "mpg123 available (recommended for MP3)"
            AUDIO_PLAYERS+=("mpg123")
            audio_found=true
        else
            print_info "mpg123 not found"
        fi

        if command -v aplay &> /dev/null; then
            print_success "aplay available (ALSA)"
            AUDIO_PLAYERS+=("aplay")
            audio_found=true
        else
            print_info "aplay not found"
        fi

        if command -v ffplay &> /dev/null; then
            print_success "ffplay available (ffmpeg)"
            AUDIO_PLAYERS+=("ffplay")
            audio_found=true
        else
            print_info "ffplay not found"
        fi

        if command -v paplay &> /dev/null; then
            print_success "paplay available (PulseAudio)"
            AUDIO_PLAYERS+=("paplay")
            audio_found=true
        else
            print_info "paplay not found"
        fi

        if [ "$audio_found" = false ]; then
            print_error "No audio player found"
            print_warning "Recommendation: Install mpg123"
            print_info "  Ubuntu/Debian: sudo apt-get install mpg123"
            print_info "  Fedora/RHEL: sudo dnf install mpg123"
            print_info "  Arch: sudo pacman -S mpg123"
        fi
        ;;
esac

echo ""

# =============================================================================
# STEP 5: Claude Code Detection
# =============================================================================

print_section "[5/12] Detecting Claude Code..."

if command -v claude &> /dev/null; then
    CLAUDE_VERSION=$(claude --version 2>&1)
    CLAUDE_PATH=$(command -v claude)
    print_success "Claude Code installed: $CLAUDE_VERSION"
    print_info "  Location: $CLAUDE_PATH"
    CLAUDE_AVAILABLE=true
else
    print_error "Claude Code not found"
    print_warning "Recommendation: Install Claude Code"
    print_info "  See: https://docs.anthropic.com/claude/docs/claude-code"
    CLAUDE_AVAILABLE=false
fi

echo ""

# =============================================================================
# STEP 6: Directory Structure Check
# =============================================================================

print_section "[6/12] Checking Directory Structure..."

# Check Claude config directory
if [ -d ~/.claude ]; then
    print_success "Claude config directory exists: ~/.claude"

    # Check permissions
    CLAUDE_PERMS=$(ls -ld ~/.claude | awk '{print $1}')
    print_info "  Permissions: $CLAUDE_PERMS"
else
    print_error "Claude config directory not found: ~/.claude"
    print_info "  Will be created on first Claude Code run"
fi

# Check hooks directory
if [ -d ~/.claude/hooks ]; then
    print_success "Hooks directory exists: ~/.claude/hooks"

    # Count hook scripts
    hook_count=$(ls -1 ~/.claude/hooks/*.sh 2>/dev/null | wc -l)
    print_info "  Hook scripts installed: $hook_count"

    # List installed hooks
    if [ $hook_count -gt 0 ]; then
        for hook in ~/.claude/hooks/*.sh; do
            hook_name=$(basename "$hook")
            hook_size=$(ls -lh "$hook" | awk '{print $5}')
            print_info "    - $hook_name ($hook_size)"
        done
    fi
else
    print_warning "Hooks directory not found: ~/.claude/hooks"
    print_info "  Will be created during installation"
fi

echo ""

# =============================================================================
# STEP 7: Project Installation Check
# =============================================================================

print_section "[7/12] Checking Project Installation..."

# Check if .project_path file exists
if [ -f ~/.claude/hooks/.project_path ]; then
    PROJECT_PATH=$(cat ~/.claude/hooks/.project_path)
    print_success "Project path recorded: $PROJECT_PATH"

    # Check if project directory exists
    if [ -d "$PROJECT_PATH" ]; then
        print_success "Project directory exists"

        # Check audio directory
        if [ -d "$PROJECT_PATH/audio/default" ]; then
            audio_count=$(ls -1 "$PROJECT_PATH/audio/default"/*.mp3 2>/dev/null | wc -l)
            print_success "Audio directory found with $audio_count MP3 files"

            # List audio files
            if [ $audio_count -gt 0 ]; then
                print_info "  Audio files:"
                for audio in "$PROJECT_PATH/audio/default"/*.mp3; do
                    audio_name=$(basename "$audio")
                    audio_size=$(ls -lh "$audio" | awk '{print $5}')
                    print_info "    - $audio_name ($audio_size)"
                done
            fi
        else
            print_error "Audio directory not found: $PROJECT_PATH/audio/default"
        fi

        # Check config directory
        if [ -d "$PROJECT_PATH/config" ]; then
            print_success "Config directory found"

            if [ -f "$PROJECT_PATH/config/user_preferences.json" ]; then
                print_success "User preferences file exists"
            else
                print_warning "User preferences file not found"
            fi
        else
            print_error "Config directory not found"
        fi
    else
        print_error "Project directory not found at recorded path"
        print_info "  Expected: $PROJECT_PATH"
        print_info "  Actual project may be at: $PROJECT_DIR"
    fi
else
    print_warning "Project path not recorded (.project_path not found)"
    print_info "  This may indicate hooks are not installed yet"
fi

echo ""

# =============================================================================
# STEP 8: Claude Settings Check
# =============================================================================

print_section "[8/12] Checking Claude Settings..."

# Check settings.json
if [ -f ~/.claude/settings.json ]; then
    print_success "settings.json exists"

    # Check if hooks are configured
    if grep -q "hook.sh" ~/.claude/settings.json 2>/dev/null; then
        hook_entries=$(grep -c "hook.sh" ~/.claude/settings.json)
        print_success "Hooks configured in settings.json ($hook_entries entries)"

        # List configured hooks
        print_info "  Configured hooks:"
        grep "hook.sh" ~/.claude/settings.json | sed 's/.*"\(.*\)".*/    - \1/'
    else
        print_warning "No hooks configured in settings.json"
        print_info "  Run the installation script to configure hooks"
    fi
else
    print_error "settings.json not found"
    print_info "  Will be created on first Claude Code run"
fi

# Check settings.local.json
if [ -f ~/.claude/settings.local.json ]; then
    print_success "settings.local.json exists"

    # Check for hook permissions
    if grep -q "allowedTools" ~/.claude/settings.local.json 2>/dev/null; then
        allowed_count=$(grep -c "Bash.*hook" ~/.claude/settings.local.json)
        print_success "Hook permissions configured ($allowed_count entries)"
    else
        print_warning "No allowedTools configuration found"
        print_info "  Hook permissions may not be set"
    fi
else
    print_warning "settings.local.json not found"
    print_info "  Hook permissions need to be configured"
fi

echo ""

# =============================================================================
# STEP 9: Path Conversion Test
# =============================================================================

print_section "[9/12] Testing Path Conversion..."

if [[ "$ENV_TYPE" == "WSL" ]] || [[ "$ENV_TYPE" == "GIT_BASH" ]] || [[ "$ENV_TYPE" == "CYGWIN" ]]; then
    print_info "Testing path conversion for Windows environment..."

    # Test path
    test_unix_path="/c/Users/test/file.mp3"

    case "$ENV_TYPE" in
        WSL)
            if command -v wslpath &> /dev/null; then
                test_win_path=$(wslpath -w "$test_unix_path" 2>/dev/null)
                print_success "wslpath available"
                print_info "  Test: $test_unix_path → $test_win_path"
            else
                print_error "wslpath not available (unusual for WSL)"
            fi
            ;;

        GIT_BASH)
            # Test sed-based conversion
            test_win_path=$(echo "$test_unix_path" | sed 's|^/\([a-zA-Z]\)/|\U\1:/|')
            print_success "sed-based conversion"
            print_info "  Test: $test_unix_path → $test_win_path"
            ;;

        CYGWIN)
            if command -v cygpath &> /dev/null; then
                test_win_path=$(cygpath -w "$test_unix_path" 2>/dev/null)
                print_success "cygpath available"
                print_info "  Test: $test_unix_path → $test_win_path"
            else
                print_error "cygpath not available"
            fi
            ;;
    esac
else
    print_info "Path conversion not needed for $ENV_TYPE"
fi

echo ""

# =============================================================================
# STEP 10: Git Check
# =============================================================================

print_section "[10/12] Checking Git..."

if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version)
    GIT_PATH=$(command -v git)
    print_success "$GIT_VERSION"
    print_info "  Location: $GIT_PATH"
    GIT_AVAILABLE=true
else
    print_error "Git not found"
    print_warning "Git is required for project installation"
    GIT_AVAILABLE=false
fi

echo ""

# =============================================================================
# STEP 11: Dependency Summary
# =============================================================================

print_section "[11/12] Dependency Summary..."

DEPS_OK=0
DEPS_MISSING=0
DEPS_OPTIONAL=0

# Required dependencies
echo "Required Dependencies:"
if [ "$CLAUDE_AVAILABLE" = true ]; then
    print_success "Claude Code: Installed"
    ((DEPS_OK++))
else
    print_error "Claude Code: Not Found"
    ((DEPS_MISSING++))
fi

if [ "$GIT_AVAILABLE" = true ]; then
    print_success "Git: Installed"
    ((DEPS_OK++))
else
    print_error "Git: Not Found"
    ((DEPS_MISSING++))
fi

echo ""
echo "Optional Dependencies:"

if [ "$PYTHON_AVAILABLE" = true ]; then
    print_success "Python 3: Installed ($PYTHON_CMD)"
    ((DEPS_OK++))
else
    print_warning "Python 3: Not Found (will use defaults)"
    ((DEPS_OPTIONAL++))
fi

if [ ${#AUDIO_PLAYERS[@]} -gt 0 ]; then
    print_success "Audio Player: Available (${AUDIO_PLAYERS[*]})"
    ((DEPS_OK++))
else
    print_warning "Audio Player: Not Found"
    ((DEPS_OPTIONAL++))
fi

echo ""
echo "Status: $DEPS_OK OK, $DEPS_MISSING Missing, $DEPS_OPTIONAL Optional"

echo ""

# =============================================================================
# STEP 12: Recommendations
# =============================================================================

print_section "[12/12] Recommendations & Next Steps..."

echo ""
case "$ENV_TYPE" in
    GIT_BASH)
        print_success "Git Bash detected - Good compatibility"
        echo ""
        echo "Recommendations:"
        echo "  1. Ensure Git for Windows is up to date"
        echo "     Download: https://gitforwindows.org/"

        if [ "$PYTHON_AVAILABLE" = false ]; then
            echo "  2. Install Python 3 and add to PATH"
            echo "     Download: https://www.python.org/downloads/"
            echo "     ⚠️  Make sure to check 'Add Python to PATH' during installation"
        fi

        echo "  3. If you encounter issues, consider using WSL"
        echo "     Install: wsl --install (in PowerShell as Administrator)"
        ;;

    WSL)
        print_success "WSL detected - Excellent compatibility"
        echo ""
        echo "Recommendations:"

        if [ "$PYTHON_AVAILABLE" = false ]; then
            echo "  1. Install Python 3:"
            echo "     $ sudo apt-get update"
            echo "     $ sudo apt-get install python3 python3-pip"
        fi

        if [ ${#AUDIO_PLAYERS[@]} -eq 0 ]; then
            echo "  2. Ensure PowerShell is accessible:"
            echo "     $ powershell.exe -Command 'Write-Host \"Test\"'"
        fi
        ;;

    LINUX)
        print_success "Native Linux - Excellent compatibility"
        echo ""
        echo "Recommendations:"

        if [ "$PYTHON_AVAILABLE" = false ]; then
            echo "  1. Install Python 3:"
            echo "     Ubuntu/Debian: $ sudo apt-get install python3"
            echo "     Fedora/RHEL:   $ sudo dnf install python3"
            echo "     Arch:          $ sudo pacman -S python"
        fi

        if [ ${#AUDIO_PLAYERS[@]} -eq 0 ]; then
            echo "  2. Install an audio player:"
            echo "     Ubuntu/Debian: $ sudo apt-get install mpg123"
            echo "     Fedora/RHEL:   $ sudo dnf install mpg123"
            echo "     Arch:          $ sudo pacman -S mpg123"
        fi
        ;;

    MACOS)
        print_success "macOS - Excellent compatibility"
        echo ""
        echo "Recommendations:"

        if [ "$PYTHON_AVAILABLE" = false ]; then
            echo "  1. Install Python 3 via Homebrew:"
            echo "     $ brew install python3"
        fi

        echo "  2. afplay should work out of the box"
        ;;

    CYGWIN)
        print_success "Cygwin detected - Good compatibility"
        echo ""
        echo "Recommendations:"
        echo "  1. Consider using WSL or Git Bash for better compatibility"

        if [ "$PYTHON_AVAILABLE" = false ]; then
            echo "  2. Install Python 3 via Cygwin package manager"
        fi
        ;;

    *)
        print_warning "Unknown environment - May have compatibility issues"
        echo ""
        echo "Recommendations:"
        echo "  1. Report your environment at:"
        echo "     https://github.com/ChanMeng666/claude-code-audio-hooks/issues"
        echo "  2. Include this detection output"
        ;;
esac

echo ""

# =============================================================================
# INSTALLATION STATUS
# =============================================================================

print_section "Installation Status"

if [ -d ~/.claude/hooks ] && [ -f ~/.claude/hooks/.project_path ]; then
    PROJECT_PATH=$(cat ~/.claude/hooks/.project_path)

    if [ -d "$PROJECT_PATH" ] && [ -d "$PROJECT_PATH/audio/default" ]; then
        print_success "Project appears to be installed"
        echo ""
        echo "  Next steps:"
        echo "    1. Test audio: $ bash $PROJECT_PATH/scripts/test-audio.sh"
        echo "    2. Use Claude:  $ claude 'test'"
        echo "    3. Configure:   $ bash $PROJECT_PATH/scripts/configure.sh"
    else
        print_warning "Project partially installed"
        echo ""
        echo "  Next steps:"
        echo "    1. Re-run installation: $ bash $PROJECT_DIR/scripts/install.sh"
        echo "    2. Check project path: $ cat ~/.claude/hooks/.project_path"
    fi
else
    print_info "Project not yet installed"
    echo ""
    echo "  Next steps:"
    echo "    1. Clone repository:"
    echo "       $ git clone https://github.com/ChanMeng666/claude-code-audio-hooks.git"
    echo "    2. Run installation:"
    echo "       $ cd claude-code-audio-hooks"
    echo "       $ bash scripts/install.sh"
fi

echo ""

# =============================================================================
# SUMMARY & REPORT
# =============================================================================

print_section "Summary"

echo ""
echo "Environment Report saved to:"
echo "  $REPORT_FILE"
echo ""
echo "You can share this report when seeking help or reporting issues."
echo ""

# Create a compact summary
cat > "${REPORT_FILE%.txt}_summary.txt" << EOF
Claude Code Audio Hooks - Environment Summary
Generated: $(date)

Environment: $ENV_TYPE ($OSTYPE)
Claude Code: $([ "$CLAUDE_AVAILABLE" = true ] && echo "Installed ($CLAUDE_VERSION)" || echo "Not Found")
Python: $([ "$PYTHON_AVAILABLE" = true ] && echo "Available ($PYTHON_CMD $PYTHON_VERSION)" || echo "Not Found")
Audio Player: $([ ${#AUDIO_PLAYERS[@]} -gt 0 ] && echo "Available (${AUDIO_PLAYERS[*]})" || echo "Not Found")
Git: $([ "$GIT_AVAILABLE" = true ] && echo "Installed ($GIT_VERSION)" || echo "Not Found")

Dependencies: $DEPS_OK OK, $DEPS_MISSING Missing, $DEPS_OPTIONAL Optional

Installation Status:
  - Hooks Directory: $([ -d ~/.claude/hooks ] && echo "Exists" || echo "Not Found")
  - Project Path: $([ -f ~/.claude/hooks/.project_path ] && cat ~/.claude/hooks/.project_path || echo "Not Recorded")
  - Settings: $([ -f ~/.claude/settings.json ] && echo "Configured" || echo "Not Found")

For detailed report, see: $REPORT_FILE
For troubleshooting, see: WINDOWS_FIX_README.md, QUICK_FIX_GUIDE.md
For issues: https://github.com/ChanMeng666/claude-code-audio-hooks/issues
EOF

print_info "Compact summary saved to: ${REPORT_FILE%.txt}_summary.txt"

echo ""
echo "================================================"
print_header "  Detection Complete"
echo "================================================"
echo ""

# Return success if all required dependencies are met
if [ $DEPS_MISSING -eq 0 ]; then
    exit 0
else
    exit 1
fi
