---
name: unity-test
description: "Execute Unity tests and analyze the results. Use this skill when the user wants to run unit tests in a Unity project."
allowed-tools: Bash, Task, mcp__unity-mcp__run_tests, mcp__unity-mcp__get_test_job, mcp__unity-mcp__get_tests
---

# Unity Test

Execute Unity tests and analyze the test results. Supports batch mode (when Editor is closed) and Unity MCP (when Editor is open).

## When to Use

Use this skill when:
- User requests to run tests in a Unity project
- User wants to validate unit tests
- User runs the `/test` command

## Prerequisites

- Unity Editor must be installed via Unity Hub
- Current directory must be a valid Unity project (contains `Assets/` folder)
- Test assemblies must be properly configured in the project
- **For MCP mode**: Unity MCP must be installed and running in Unity Editor

## Execution Steps

### Step 1: Check if Unity Editor is running

Execute the test script to check the project state:

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/unity-test.sh "$(pwd)" [test-mode] [filter]
```

The script outputs:
```
LOG_MODE:batch|editor
```

### Step 2: Execute tests based on mode

#### If LOG_MODE is `batch` (Editor is closed)

The script will run tests in batch mode automatically. Extract:
- `LOG_FILE_PATH`: Path to the log file
- `RESULT_FILE_PATH`: Path to XML test results (if available)

Then call the `test-result` agent:
```
Task: test-result agent
Prompt: {log_file_path} batch
```

#### If LOG_MODE is `editor` (Editor is open)

Use Unity MCP to run tests directly in the Editor:

1. **Run tests using MCP**:
   ```
   mcp__unity-mcp__run_tests
   ```
   This returns a `job_id` for tracking the test execution.

2. **Poll for results**:
   ```
   mcp__unity-mcp__get_test_job with job_id
   ```
   Keep polling until the job is complete.

3. **Report the results** directly from the MCP response.

**Test modes** for MCP:
- `EditMode` - Editor-based unit tests
- `PlayMode` - Runtime tests

## Output Format

**Success:**
```
[TEST OK] Ran N tests. All passed.
```

**Failure:**
```
[TEST FAILED] M of N tests failed.
- {TestClass}.{TestMethod}: {FailureReason}
```

## Error Handling

If the script fails to find Unity Editor:
- Inform the user that Unity is not installed or not found
- Suggest installing Unity via Unity Hub

If the project path is invalid:
- Inform the user that the current directory is not a valid Unity project
- Suggest navigating to a Unity project directory

If Unity MCP is not available when Editor is open:
- Inform the user that Unity MCP is required for running tests with Editor open
- Suggest installing Unity MCP from: https://github.com/CoplayDev/unity-mcp
- Or suggest closing Unity Editor to run tests in batch mode
