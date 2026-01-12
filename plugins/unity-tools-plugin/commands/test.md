---
description: "Execute Unity tests in the current directory"
---

# /test Command

Execute Unity tests for the current Unity project.

## Arguments

$ARGUMENTS

Optional arguments:
- **Test mode**: `EditMode`, `PlayMode`, or `All` (default)
- **Filter**: Test name pattern to run specific tests

## Usage Examples

```
/test
/test EditMode
/test PlayMode
/test All MyNamespace.MyTestClass
```

## Execution

Follow the `unity-test` skill to execute the tests:

1. Run the test script to check if Unity Editor is running
2. Based on the mode:
   - **Batch mode** (Editor closed): Tests run automatically via script, analyze with `test-result` agent
   - **Editor mode** (Editor open): Use Unity MCP's `run_tests` tool to execute tests directly

## Expected Output

The test result will be displayed in one of these formats:

**Success:**
```
[TEST OK] Ran N tests. All passed.
```

**Failure:**
```
[TEST FAILED] M of N tests failed.
- {TestClass}.{TestMethod}: {FailureReason}
```

If tests fail, analyze the failure reasons and suggest fixes based on the error messages.

## Notes

- When Unity Editor is open, tests are executed via Unity MCP
- Unity MCP must be installed in the Unity project for Editor mode
- If Unity MCP is not available, suggest closing Unity Editor to run in batch mode
