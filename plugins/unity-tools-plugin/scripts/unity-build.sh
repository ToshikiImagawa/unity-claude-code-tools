#!/bin/bash
# Unity Build Validation Script for Mac/Linux
# Usage: ./unity-build.sh <project-path> [build-target]

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

UNITY_PATH=$(find_unity)
if [[ -z "$UNITY_PATH" ]]; then
    echo "[ERROR] Unity Editor not found."
    echo "Please install Unity or set the path manually."
    exit 1
fi

echo "Unity: $UNITY_PATH"
echo "Project: $PROJECT_PATH"
echo "Target: $BUILD_TARGET"
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
else
    echo "[ERROR] Log file not created: $LOG_FILE"
    exit 1
fi
