# GitHub Actions — Diagnose and Fix

Check GitHub Actions for the current branch, diagnose any failures, and fix them.

## Phase 1: Identify Failures

1. **Get the current branch**:

   ```
   git branch --show-current
   ```

2. **If on main/master, create a fix branch**:
   - Check if the current branch is `main` or `master`
   - If so, create and switch to a new branch for the fix:

     ```
     git checkout -b fix/gha-<short-description-or-timestamp>
     ```

   - You'll push this branch and create a PR later instead of pushing directly to main/master

3. **Find the latest workflow run(s) for the original branch** (use main/master if you just branched off):

   ```
   gh run list --branch <branch> --limit 5
   ```

4. **If no runs exist**, inform the user and stop.

5. **If all runs are passing**, inform the user that everything is green and stop.

6. **If there are failed runs**, identify the most recent failed run and proceed.

## Phase 2: Gather Failure Data

1. **Get details of the failed run**:

   ```
   gh run view <run_id>
   ```

2. **Fetch the failed job logs**:

   ```
   gh run view <run_id> --log-failed
   ```

3. **Get the workflow file** to understand the CI configuration:

   ```
   cat .github/workflows/<workflow-file>.yml
   ```

4. **Check recent runs for flakiness pattern**:

   ```
   gh run list --branch <branch> --limit 10 --json status,conclusion,name
   ```

## Phase 3: Parallel Diagnosis (Using Subagents)

Based on the failure type, launch relevant subagents. Not all are needed every time — launch only the ones matching the failure signals.

### Subagent 1: Build & Compilation Errors

Launch if: logs contain compile errors, type errors, missing modules, or build step failures.

```
Diagnose this CI build failure.

## Failed Logs
[insert failed job logs]

## Workflow Config
[insert workflow YAML]

## Check For
- TypeScript/compilation errors (read the exact file:line from error)
- Missing dependencies (check package.json vs imports)
- Version mismatches (Node version in CI vs local, package version conflicts)
- Build script issues (wrong command, missing env vars during build)
- Import path errors (case sensitivity on Linux CI vs macOS local)

## Diagnosis Steps
1. Parse the exact error message and file:line reference
2. Read the failing file to understand the error in context
3. Check if the error reproduces locally (same command from workflow)
4. Identify root cause: code error vs config error vs dependency error

Report: exact error, root cause, and specific fix with file:line.
```

### Subagent 2: Test Failures

Launch if: logs show test runner output with failed assertions.

```
Diagnose this CI test failure.

## Failed Logs
[insert failed job logs]

## Check For
- Which specific test(s) failed and their assertion messages
- Test isolation issues (tests pass alone, fail together)
- Environment-dependent tests (hardcoded paths, timezone, locale)
- Snapshot mismatches (intentional change vs regression)
- Missing test fixtures or seed data
- Timing-dependent assertions (race conditions, timeouts)

## Flakiness Detection
- Check if the same test failed in recent runs: [insert recent run history]
- If the test passes sometimes and fails others, identify the non-deterministic element

## Diagnosis Steps
1. Identify the failing test file and test name
2. Read the test and the code it tests
3. Compare the expected vs actual values from the assertion
4. Determine: is this a real bug, a flaky test, or a test that needs updating?

Report: failing test, root cause, and whether to fix the code or fix the test.
```

### Subagent 3: Environment & Dependencies

Launch if: logs show package install failures, action version errors, permission denied, or "not found" for system tools.

```
Diagnose this CI environment/dependency failure.

## Failed Logs
[insert failed job logs]

## Workflow Config
[insert workflow YAML]

## Check For
- Package install failures (registry timeouts, version conflicts, peer deps)
- Action version issues (deprecated actions, breaking changes in major versions)
- Node/Python/Go version mismatches between CI and project requirements
- Missing system dependencies (native modules, OS packages)
- Cache issues (corrupted cache, cache key mismatch)
- Permission errors (file access, Docker, npm global installs)

## Diagnosis Steps
1. Identify the failing step in the workflow
2. Check if the action/tool versions in the workflow match project requirements
3. Check lock file consistency (package-lock.json, pnpm-lock.yaml committed?)
4. Look for recently deprecated or updated dependencies

Report: failing step, root cause, and specific fix to workflow or config.
```

### Subagent 4: Secrets, Permissions & Deployment

Launch if: logs show auth errors, 403/401 responses, missing secrets, or deployment step failures.

```
Diagnose this CI secrets/permissions/deployment failure.

## Failed Logs
[insert failed job logs]

## Workflow Config
[insert workflow YAML]

## Check For
- Missing or expired secrets (API tokens, deploy keys)
- Insufficient GitHub token permissions (GITHUB_TOKEN scope)
- Protected environment rules blocking deployment
- Third-party service auth failures (npm publish, cloud deploy, Docker registry)
- Branch protection rules preventing push/merge

## Diagnosis Steps
1. Identify which secret or permission is missing from the error
2. Check if the workflow has correct permissions block
3. Determine if this is a new secret requirement or an expired credential
4. Check if the failure is branch-specific (PRs from forks can't access secrets)

Report: which secret/permission is missing, whether it's a config fix or requires
the user to update repository settings.
```

## Phase 4: Fix the Issue

1. **Summarize the diagnosis to the user**:
   - What failed and why
   - Which files are likely involved
   - Your proposed fix approach

2. **Locate the relevant code** based on the failure:
   - For test failures: find the failing test and the code it tests
   - For build errors: find the file and line mentioned in the error
   - For workflow issues: the `.github/workflows/*.yml` file
   - For dependency issues: `package.json`, lock files, or action versions

3. **Implement the fix**:
   - Make the minimum changes necessary
   - Follow existing code patterns and conventions

4. **Verify locally if possible**:
   - Run the same command that failed (test, build, lint)
   - Ensure the fix works before pushing

5. **Commit and push the fix** (only after user confirms the approach):

   ```
   git add <relevant-files>
   git commit -m "fix: <description of what was fixed>"
   git push -u origin HEAD
   ```

## Phase 5: Monitor

1. **Watch for the new run to complete**:

   ```
   gh run watch
   ```

2. **If the fix didn't work** (new run also fails):
   - Fetch the new failure logs
   - Diagnose again — it may be a different issue or the fix was incomplete
   - Return to Phase 3 with new logs

3. **Once all checks pass**:
   - If you created a fix branch from main/master, create a PR using `gh pr create` and return the PR URL
   - Otherwise, inform the user that the issue is resolved

## Notes

- If the failure appears to be a flaky test or infrastructure issue (not caused by code in this branch), inform the user and ask how they want to proceed (retry, skip, investigate further).
- If multiple different jobs failed, address them one at a time, starting with the most fundamental (e.g., build before test, lint before build).
- If you cannot determine the cause of a failure, present what you found and ask the user for guidance.
- For secrets/permissions issues, you can diagnose but often can't fix — clearly tell the user what they need to update in repository settings.
- A `gh run rerun <run_id> --failed` can re-run only failed jobs — useful for suspected flakes.
