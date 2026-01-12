---
name: unity-build
description: "Execute Unity build validation and analyze the results. Use this skill when the user wants to build or validate a Unity project."
allowed-tools: Bash, Task, mcp__unity-mcp__validate_script, mcp__unity-mcp__manage_editor, mcp__unity-mcp__read_console
---

# Unity Build

Execute Unity build validation and analyze the results. Supports batch mode (when Editor is closed) and Unity MCP (when Editor is open).

## When to Use

Use this skill when:
- User requests to build a Unity project
- User wants to validate compilation of Unity project
- User runs the `/build` command

## Prerequisites

- Unity Editor must be installed via Unity Hub
- Current directory must be a valid Unity project (contains `Assets/` folder)
- **For MCP mode**: Unity MCP must be installed and running in Unity Editor

## Execution Steps

### Step 1: Check if Unity Editor is running

Execute the build script to check the project state:

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/unity-build.sh "$(pwd)" [build-target]
```

The script outputs:
```
LOG_MODE:batch|editor
```

### Step 2: Execute build validation based on mode

#### If LOG_MODE is `batch` (Editor is closed)

The script will run batch build automatically. Extract:
- `LOG_FILE_PATH`: Path to the log file

Then call the `build-result` agent:
```
Task: build-result agent
Prompt: {log_file_path} batch
```

#### If LOG_MODE is `editor` (Editor is open)

Use Unity MCP to validate and test the build:

**Step 2a: Validate scripts**
```
mcp__unity-mcp__validate_script
```
Check for compilation errors in all scripts. This returns validation results including any syntax errors.

**Step 2b: Enter Play mode (optional, for runtime validation)**
```
mcp__unity-mcp__manage_editor with action: "play"
```
This enters Play mode to check for runtime errors.

**Step 2c: Read console logs**
```
mcp__unity-mcp__read_console
```
Read the Unity console to get compilation results, warnings, and errors.

**Step 2d: Exit Play mode (if entered)**
```
mcp__unity-mcp__manage_editor with action: "stop"
```

**Step 2e: Report results**
Parse the console output and report in the standard format.

## Output Format

**Success:**
```
[BUILD OK] Compilation succeeded with no errors.
```

**With warnings:**
```
[BUILD OK] Compilation succeeded with N warning(s).
- {FilePath}({Line},{Column}): {WarningCode} {Message}
```

**Failure:**
```
[BUILD FAILED] N error(s) found.
- {FilePath}({Line},{Column}): {ErrorCode} {Message}
```

## Error Handling

If the script fails to find Unity Editor:
- Inform the user that Unity is not installed or not found
- Suggest installing Unity via Unity Hub

If the project path is invalid:
- Inform the user that the current directory is not a valid Unity project
- Suggest navigating to a Unity project directory

If Unity MCP is not available when Editor is open:
- Inform the user that Unity MCP is required for build validation with Editor open
- Suggest installing Unity MCP from: https://github.com/CoplayDev/unity-mcp
- Or suggest closing Unity Editor to run in batch mode
