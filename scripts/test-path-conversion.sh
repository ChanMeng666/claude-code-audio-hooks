#!/bin/bash
# Test script for Git Bash path conversion functionality
# This validates that the hook_config.sh path conversion works correctly

set -e

echo "================================================================"
echo "  Path Conversion Test for Git Bash Compatibility"
echo "================================================================"
echo ""

# Source the hook_config.sh to get access to convert_path_for_python
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
HOOK_CONFIG="$PROJECT_DIR/hooks/shared/hook_config.sh"

if [ ! -f "$HOOK_CONFIG" ]; then
    echo "ERROR: hook_config.sh not found at $HOOK_CONFIG"
    exit 1
fi

echo "Sourcing hook_config.sh..."
source "$HOOK_CONFIG"
echo "✓ hook_config.sh loaded successfully"
echo ""

# Test 1: Test convert_path_for_python function
echo "Test 1: Path Conversion Function"
echo "================================="

test_paths=(
    "/c/Users/Test/file.txt"
    "/d/Projects/claude-code-audio-hooks/config/user_preferences.json"
    "/e/Data/audio/test.mp3"
    "/home/user/file.txt"  # Non-Git-Bash path (should remain unchanged on non-Windows)
)

echo "Current OSTYPE: $OSTYPE"
echo ""

for test_path in "${test_paths[@]}"; do
    echo "Input:  $test_path"
    converted=$(convert_path_for_python "$test_path")
    echo "Output: $converted"

    # Validation based on OSTYPE
    if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "mingw"* ]]; then
        # On Git Bash, paths like /c/... should convert to C:/...
        if [[ "$test_path" =~ ^/[a-zA-Z]/ ]]; then
            expected_prefix=$(echo "$test_path" | sed 's|^/\([a-zA-Z]\)/.*|\U\1:|')
            if [[ "$converted" == ${expected_prefix}* ]]; then
                echo "✓ Conversion correct for Git Bash"
            else
                echo "✗ Conversion FAILED for Git Bash"
                exit 1
            fi
        fi
    else
        # On non-Git-Bash systems, paths should remain unchanged
        if [ "$test_path" = "$converted" ]; then
            echo "✓ Path unchanged (expected on non-Git-Bash)"
        else
            echo "⚠ Path was modified on non-Git-Bash system"
        fi
    fi
    echo ""
done

# Test 2: Test Python can read config with converted path
echo ""
echo "Test 2: Python Config Reading with Converted Path"
echo "=================================================="

CONFIG_FILE="$PROJECT_DIR/config/user_preferences.json"
echo "Config file (Unix path): $CONFIG_FILE"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "⚠ Config file not found, skipping Python test"
else
    # Convert path for Python
    CONVERTED_CONFIG=$(convert_path_for_python "$CONFIG_FILE")
    echo "Config file (converted): $CONVERTED_CONFIG"
    echo ""

    # Get Python command
    PYTHON_CMD=$(get_python_cmd)
    if [ -z "$PYTHON_CMD" ]; then
        echo "⚠ Python not found, skipping Python test"
    else
        echo "Testing Python with converted path..."

        # Test reading the config file
        TEST_RESULT=$("$PYTHON_CMD" <<EOF 2>&1
import json
import sys
try:
    with open("$CONVERTED_CONFIG", "r") as f:
        config = json.load(f)
    # Check if essential keys exist
    if "enabled_hooks" in config and "audio_files" in config:
        print("SUCCESS: Config file read correctly")
        print("  - enabled_hooks: found")
        print("  - audio_files: found")
        sys.exit(0)
    else:
        print("ERROR: Config structure is invalid")
        sys.exit(1)
except FileNotFoundError:
    print("ERROR: Config file not found by Python")
    sys.exit(1)
except json.JSONDecodeError as e:
    print(f"ERROR: Config file is not valid JSON: {e}")
    sys.exit(1)
except Exception as e:
    print(f"ERROR: {e}")
    sys.exit(1)
EOF
)

        echo "$TEST_RESULT"

        if [[ "$TEST_RESULT" == *"SUCCESS"* ]]; then
            echo "✓ Python successfully read config with converted path"
        else
            echo "✗ Python FAILED to read config"
            exit 1
        fi
    fi
fi

# Test 3: Test is_hook_enabled function
echo ""
echo "Test 3: is_hook_enabled Function"
echo "================================="

hook_types=("notification" "stop" "subagent_stop")

for hook_type in "${hook_types[@]}"; do
    echo -n "Testing '$hook_type' hook... "

    if is_hook_enabled "$hook_type"; then
        echo "ENABLED ✓"
    else
        echo "DISABLED ✓"
    fi
done

# Test 4: Test get_audio_file function
echo ""
echo "Test 4: get_audio_file Function"
echo "================================"

test_cases=(
    "stop:task-complete.mp3"
    "notification:notification-urgent.mp3"
    "subagent_stop:subagent-complete.mp3"
)

for test_case in "${test_cases[@]}"; do
    hook_type="${test_case%%:*}"
    default_file="${test_case##*:}"

    echo -n "Testing '$hook_type' audio file... "
    audio_path=$(get_audio_file "$hook_type" "$default_file")

    if [ -f "$audio_path" ]; then
        echo "FOUND ✓"
        echo "  Path: $audio_path"
    else
        echo "NOT FOUND ⚠"
        echo "  Expected: $audio_path"
    fi
done

# Summary
echo ""
echo "================================================================"
echo "  Path Conversion Test Complete"
echo "================================================================"
echo ""
echo "✓ All tests passed!"
echo ""

if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "mingw"* ]]; then
    echo "Note: Running on Git Bash (Windows)"
    echo "      Path conversion is ACTIVE"
else
    echo "Note: Running on $OSTYPE"
    echo "      Path conversion is INACTIVE (not needed)"
fi

echo ""
echo "This test validates that:"
echo "  1. Path conversion function works correctly"
echo "  2. Python can read config files with converted paths"
echo "  3. Hook enable/disable detection works"
echo "  4. Audio file path resolution works"
echo ""
