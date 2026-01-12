#!/bin/bash
# Unity Build Validation Script for Mac/Linux
# Usage: ./unity-build.sh <project-path> [build-target]
#
# If Unity Editor is already open with the project, reads Editor.log instead of batch mode.

set -e

PROJECT_PATH="${1:-.}"
BUILD_TARGET="${2:-StandaloneOSX}"
LOG_FILE="/tmp/unity-build-$$.log"

# Resolve absolute path
PROJECT_PATH=$(cd "$PROJECT_PATH" && pwd)

# Validate project path
if [[ ! -d "$PROJECT_PATH/Assets" ]]; then
    echo "[ERROR] Assets folder not found at: $PROJECT_PATH"
    echo "Please specify a valid Unity project path."
    exit 1
fi

# Get Editor.log path based on OS
get_editor_log_path() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "$HOME/Library/Logs/Unity/Editor.log"
    elif [[ "$OSTYPE" == "linux"* ]]; then
        echo "$HOME/.config/unity3d/Editor.log"
    else
        echo ""
    fi
}

# Check if Unity Editor is running with this project
is_editor_running() {
    # Check for Unity lock file
    if [[ -f "$PROJECT_PATH/Temp/UnityLockfile" ]]; then
        return 0
    fi
    return 1
}

# Find Unity Editor
find_unity() {
    # macOS Unity Hub locations
    local unity_paths=(
        "/Applications/Unity/Hub/Editor/*/Unity.app/Contents/MacOS/Unity"
        "/Applications/Unity/Unity.app/Contents/MacOS/Unity"
    )

    # Linux Unity locations
    if [[ "$OSTYPE" == "linux"* ]]; then
        unity_paths=(
            "$HOME/Unity/Hub/Editor/*/Editor/Unity"
            "/opt/Unity/Editor/Unity"
        )
    fi

    for pattern in "${unity_paths[@]}"; do
        # shellcheck disable=SC2086
        for unity in $pattern; do
            if [[ -x "$unity" ]]; then
                echo "$unity"
                return 0
            fi
        done
    done

    # Try which
    if command -v Unity &> /dev/null; then
        which Unity
        return 0
    fi

    return 1
}

echo "Project: $PROJECT_PATH"
echo "Target: $BUILD_TARGET"
echo ""

# Check if Unity Editor is already running
if is_editor_running; then
    echo "[INFO] Unity Editor is running with this project."
    echo "[INFO] Reading Editor.log instead of batch mode."
    echo ""

    EDITOR_LOG=$(get_editor_log_path)

    if [[ -z "$EDITOR_LOG" ]] || [[ ! -f "$EDITOR_LOG" ]]; then
        echo "[ERROR] Editor.log not found at: $EDITOR_LOG"
        echo "Please check if Unity Editor is running."
        exit 1
    fi

    echo "Mode: Editor.log"
    echo "Log: $EDITOR_LOG"
    echo ""
    echo "LOG_FILE_PATH:$EDITOR_LOG"
    echo "LOG_MODE:editor"
else
    # Batch mode
    UNITY_PATH=$(find_unity)
    if [[ -z "$UNITY_PATH" ]]; then
        echo "[ERROR] Unity Editor not found."
        echo "Please install Unity or set the path manually."
        exit 1
    fi

    echo "Mode: Batch"
    echo "Unity: $UNITY_PATH"
    echo "Log: $LOG_FILE"
    echo ""

    # Run Unity build validation
    "$UNITY_PATH" \
        -batchmode \
        -quit \
        -projectPath "$PROJECT_PATH" \
        -buildTarget "$BUILD_TARGET" \
        -logFile "$LOG_FILE" \
        2>&1 || true

    # Check for errors in log
    if [[ -f "$LOG_FILE" ]]; then
        echo "LOG_FILE_PATH:$LOG_FILE"
        echo "LOG_MODE:batch"
    else
        echo "[ERROR] Log file not created: $LOG_FILE"
        exit 1
    fi
fi
