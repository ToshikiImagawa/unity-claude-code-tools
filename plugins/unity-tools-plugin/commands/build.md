---
description: "Execute Unity build validation in the current directory"
---

# /build Command

Execute Unity build validation for the current Unity project.

## Arguments

$ARGUMENTS

Optional build target can be specified:
- `StandaloneOSX` (default) - macOS
- `StandaloneLinux64` - Linux
- `StandaloneWindows64` - Windows
- `iOS` - iOS
- `Android` - Android
- `WebGL` - WebGL

## Usage Examples

```
/build
/build StandaloneLinux64
/build iOS
```

## Execution

Follow the `unity-build` skill to execute the build validation:

1. Run the build script to check if Unity Editor is running
2. Based on the mode:
   - **Batch mode** (Editor closed): Full batch build via script, analyze with `build-result` agent
   - **Editor mode** (Editor open): Use Unity MCP to:
     - `validate_script` - Check for compilation errors
     - `manage_editor` - Enter/exit Play mode for runtime validation
     - `read_console` - Read compilation results and errors

## Expected Output

The build result will be displayed in one of these formats:

**Success:**
```
[BUILD OK] Compilation succeeded with no errors.
```

**Failure:**
```
[BUILD FAILED] N error(s) found.
- {FilePath}({Line},{Column}): {ErrorCode} {Message}
```

If errors are found, suggest fixes based on the error messages.

## Notes

- When Unity Editor is open, build validation is performed via Unity MCP
- Unity MCP must be installed in the Unity project for Editor mode
- If Unity MCP is not available, suggest closing Unity Editor to run in batch mode
