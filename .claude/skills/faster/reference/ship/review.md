# Review Changes

Structured review of a PR, diff, or set of changes.

## Phase 1: Identify the Changes

Determine what to review based on user input:

**If PR number or URL provided:**

```
gh pr view <number> --json title,body,baseRefName,headRefName,additions,deletions,changedFiles
gh pr diff <number>
```

**If branch/diff range provided:**

```
git diff <base>...<head> --stat
git diff <base>...<head>
git log <base>...<head> --oneline
```

**If no target specified, ask:**

- **Question**: "What should I review?"
- **Options**:
  1. **Open PR** — "Review a pull request by number"
  2. **Staged changes** — "Review what's about to be committed"
  3. **Branch diff** — "Review current branch vs main"
  4. **Recent commits** — "Review the last N commits"

## Phase 2: Understand Context

1. **Read the PR description/commit messages** to understand intent
2. **Identify the scope** — which areas of the codebase are touched
3. **Check for project rules** — read `.claude/rules/*.md` for relevant guidelines
4. **Note the size** — flag if the diff is unusually large (>500 lines) and suggest splitting

## Phase 3: Parallel Review (Using Subagents)

Launch up to 4 subagents depending on what's relevant to the changes:

### Subagent 1: Correctness & Logic

```
Review these changes for correctness issues.

## Changes
[diff content]

## Check For
- Logic errors, off-by-one, wrong conditions
- Missing edge cases (null, empty, boundary values)
- Race conditions or concurrency issues
- State management bugs (stale closures, missing deps)
- Error handling gaps (uncaught exceptions, missing error states)
- Regressions — does this break existing behavior?

## Report Format
For each issue:
- file:line reference
- Severity (bug / potential-bug / concern)
- What's wrong and why
- Suggested fix
```

### Subagent 2: Security & Data Safety

```
Review these changes for security concerns.

## Changes
[diff content]

## Check For
- Input validation gaps (user input, API params, file uploads)
- Injection risks (SQL, XSS, command injection, path traversal)
- Authentication/authorization bypasses
- Secrets or credentials in code
- Unsafe deserialization
- CORS or CSRF issues
- Information leakage in error messages or logs

## Report Format
For each issue:
- file:line reference
- Severity (critical / high / medium)
- The vulnerability
- Exploitation scenario
- Suggested fix
```

### Subagent 3: Guidelines Compliance

Only launch if `.claude/rules/*.md` files exist.

```
Review these changes against project coding guidelines.

## Changes
[diff content]

## Guidelines
[content from relevant .claude/rules/*.md files]

## Check For
- Violations of project conventions (naming, patterns, file structure)
- Anti-patterns explicitly called out in guidelines
- Missing patterns that guidelines require (error handling, testing, etc.)

## Report Format
For each violation:
- file:line reference
- The guideline being violated (quote the rule)
- What was found
- Suggested fix
```

### Subagent 4: Test Coverage

```
Review these changes for testing gaps.

## Changes
[diff content]

## Check For
- New functions/methods without corresponding tests
- Changed behavior without updated tests
- Edge cases that should be tested but aren't
- Test quality issues (testing implementation details, brittle assertions)
- Missing error case tests

## Also Check
- Are existing tests still valid after these changes?
- Do test names accurately describe what they test?

## Report Format
For each gap:
- file:line reference — the untested code
- What test is missing
- Suggested test case (brief description, not full code)
```

## Phase 4: Aggregate & Prioritize

Combine subagent findings into a single review:

```markdown
## Review Summary

**PR**: #123 — Title
**Files changed**: X | **Additions**: +Y | **Deletions**: -Z

### Blocking Issues (must fix)
Issues that would cause bugs, security vulnerabilities, or data loss.

| # | File | Line | Issue | Type |
|---|------|------|-------|------|
| 1 | ... | ... | ... | Bug/Security |

### Suggestions (should fix)
Guideline violations, missing tests, code quality concerns.

| # | File | Line | Issue | Type |
|---|------|------|-------|------|
| 1 | ... | ... | ... | Guidelines/Tests |

### Nits (optional)
Minor style or preference items. Skip if the diff is otherwise clean.

### What Looks Good
Briefly note well-done aspects (good patterns, thorough error handling, clean abstractions).
```

## Phase 5: Present & Offer Actions

After presenting the review:

- **Question**: "What would you like to do?"
- **Options**:
  1. **Fix blocking issues** — "I'll fix the bugs and security issues"
  2. **Fix all** — "I'll fix everything including suggestions"
  3. **Post as PR comment** — "Post the review as a GitHub PR comment"
  4. **Report only** — "Just the summary, no changes"

### If posting as PR comment

```
gh pr review <number> --comment --body "$(cat <<'EOF'
## Review

[formatted review content]
EOF
)"
```

## Notes

- Don't nitpick formatting if a linter/formatter is configured
- Focus on what the diff changes, not pre-existing issues in unchanged code
- If the PR is too large (>1000 lines), suggest reviewing in parts or splitting the PR
- For draft PRs, focus on architecture and approach rather than details
- Be specific — "this could crash" is useless; "null dereference on line 42 when user has no email" is useful
