# TODOs Audit — Subagent Prompts

Reference file for audit-todo. Contains detailed prompts for each parallel subagent.

## Subagent 1: TODO Inventory & Age Analysis

```
Audit this codebase for all TODO/FIXME markers and their age.

## DETECTION PATTERNS
Universal marker regex:
```regex
(?://|#|<!--|/\*|--)\\s*@?(TODO|FIXME|HACK|XXX|BUG|OPTIMIZE|REFACTOR|REVIEW|NOTE|DEPRECATED)\\s*(?:\\(([^)]+)\\))?\\s*:?\\s*(.*)
```

## METADATA EXTRACTION

Look for structured formats:

With author:

```
TODO(username): message
TODO(@username): message
```

With issue reference:

```
TODO PROJ-123: message
TODO #123: message
TODO (PROJ-123): message
```

With date:

```
TODO (2024-01-15): message
TODO [2024-01-15]: message
```

## AGE SCORING (via git blame)

| Age | Score | Priority Boost |
|-----|-------|----------------|
| 0-30 days | 0 | None (fresh) |
| 31-90 days | 1 | +0.5 |
| 91-180 days | 2 | +1.0 |
| 180-365 days | 3 | +1.5 |
| >365 days | 4 | +2.0 (stale) |

## INVENTORY OUTPUT

For each TODO found:

- file:line reference
- Marker type (TODO/FIXME/etc)
- Full text
- Author (from marker or git blame)
- Age in days
- Issue reference (if found)
- Age score

Sort by age descending (oldest first).

```

## Subagent 2: Security & Bug Markers

```

Audit this codebase for high-priority security and bug-related TODOs.

## SECURITY CONCERNS (Critical Priority)

Search for TODOs containing security keywords:

```regex
(TODO|FIXME|HACK|XXX).*(security|auth|password|credential|token|encrypt|decrypt|injection|XSS|CSRF|sanitize|validate|escape|permission|access.?control|vulnerability)
```

Examples:

```typescript
// TODO: add CSRF protection
// FIXME: password not hashed
// HACK: skipping auth check for now
// XXX: SQL injection possible here
// TODO: sanitize user input
```

## BUG & DEFECT MARKERS (Critical/High)

Search for bug-related content:

```regex
(TODO|FIXME|BUG|XXX).*(bug|crash|error|exception|race|deadlock|corrupt|memory.?leak|overflow|infinite.?loop|null.?pointer|undefined|NaN|broken)
```

Examples:

```typescript
// BUG: crashes when input is empty
// FIXME: race condition in concurrent access
// XXX: memory leak - objects not freed
// TODO: handle null case
```

## LOCATION MODIFIERS

Boost priority based on file location:

| Path Contains | Priority Modifier |
|---------------|-------------------|
| /core/, /lib/core/ | +2 (critical path) |
| /auth/, /security/ | +3 (security code) |
| /api/, /public/ | +2 (exposed surface) |
| /payment/, /billing/ | +3 (financial) |
| /test/, /spec/, /**tests**/ | -1 (test code) |
| /examples/, /demo/ | -2 (non-production) |
| /vendor/, /node_modules/ | Skip entirely |

Report each finding with:

- file:line reference
- Marker and full text
- Security/bug keywords found
- Priority (base + modifiers)
- Suggested action

```

## Subagent 3: Issue Tracker Integration

```

Audit this codebase for TODOs referencing issues, and check their status.

## ISSUE REFERENCE EXTRACTION

Patterns to detect:

GitHub:

```regex
(TODO|FIXME)\s*[:\(]?\s*#(\d+)
```

Jira/Linear style:

```regex
(TODO|FIXME)\s*[:\(]?\s*([A-Z]{2,10}-\d+)
```

URL references:

```regex
(TODO|FIXME).*https?://[^\s]+/(issues?|pull|PR)/(\d+)
```

## STALE REFERENCE DETECTION (Critical)

A TODO is stale if it references a closed issue:

1. Extract issue reference from TODO
2. Check issue status via:
   - `gh issue view <number>` for GitHub
   - API call for Jira/Linear
3. If issue is CLOSED/DONE:
   - TODO should be resolved or removed
   - Flag as Critical priority

Examples:

```typescript
// TODO #123: wait for API changes
// ^ If #123 is closed, this TODO is stale!

// FIXME PROJ-456: blocked by backend
// ^ If PROJ-456 is done, this should be resolved
```

## ORPHANED REFERENCES

Flag TODOs referencing:

- Issues that don't exist (404)
- Issues in archived projects
- Very old closed issues (>1 year ago)

Report each finding with:

- file:line reference
- TODO text
- Issue reference
- Issue status (open/closed/not found)
- Issue close date (if closed)
- Priority (closed = Critical)

```

## Subagent 4: Quality & Context Analysis

```

Audit this codebase for low-quality TODOs lacking context.

## MISSING EXPLANATION (High)

Flag TODOs with minimal content:

```typescript
// BAD - no context
// TODO
// TODO:
// TODO fix this
// FIXME

// GOOD - has context
// TODO: Add retry logic for transient network failures
// FIXME: Race condition when two users edit simultaneously - see #123
```

Detection:

- TODO with <3 words after marker
- TODO with only generic words: "fix", "this", "later", "soon"

## MISSING OWNER

Flag TODOs without attribution:

```typescript
// BAD - no owner
// TODO: refactor this module

// GOOD - has owner
// TODO(alice): refactor this module
// TODO @bob: refactor this module
```

Note: If codebase doesn't use owner convention, don't flag this.

## VAGUE ACTION

Flag TODOs with unclear actions:

Vague words to detect:

```
"fix this", "clean up", "refactor", "improve", "make better",
"optimize", "handle this", "do something", "check this",
"look into", "figure out", "think about", "maybe"
```

```typescript
// BAD - vague
// TODO: clean this up
// TODO: make this better
// TODO: fix

// GOOD - specific
// TODO: Extract validation logic into UserValidator class
// TODO: Add index on users.email for query performance
// TODO: Replace polling with WebSocket for real-time updates
```

## QUALITY SCORE

Calculate quality score (0-100):

- Has explanation (>5 words): +40
- Has owner: +20
- Has issue reference: +20
- Has specific action verb: +10
- Not vague: +10

Flag TODOs with score <50.

Report each finding with:

- file:line reference
- TODO text
- Quality score
- What's missing (explanation/owner/specificity)
- Suggested improvement

```

## Subagent 5: Prioritization & Categorization

```

Analyze all TODOs and produce prioritized report.

## PRIORITY SCORING FORMULA

```
Priority Score =
  (Age_Score × 1.0) +
  (Location_Score × 1.5) +
  (Content_Score × 2.0) +
  (Quality_Penalty × 1.0) +
  (Closed_Issue_Bonus × 3.0)
```

## CONTENT SCORE BY KEYWORDS

| Keywords | Score |
|----------|-------|
| security, vulnerability, injection, auth | +3 |
| bug, crash, memory leak, race condition | +2 |
| performance, slow, bottleneck | +1 |
| cleanup, refactor, style | -1 |
| maybe, someday, nice-to-have | -2 |

## CATEGORIZATION

Group TODOs into actionable categories:

**Resolve Now** (Score >= 8):

- Security issues
- Known bugs in production
- Closed issue references
- Very old (>1 year)

**Plan Soon** (Score 5-7):

- Bugs in non-critical paths
- Performance issues
- 6-12 month old items

**Backlog** (Score 2-4):

- Code quality improvements
- Refactoring suggestions
- Nice-to-have features

**Archive/Delete** (Score < 2):

- Vague with no context
- In deprecated code
- Author left, no one understands

## OUTPUT FORMAT

```markdown
## TODOs by Priority

### Critical (Resolve This Sprint)
| Location | Age | Type | Description | Action |
|----------|-----|------|-------------|--------|

### High (Plan for Next Sprint)
...

### Medium (Add to Backlog)
...

### Low (Consider Deleting)
...

## Statistics
- Total TODOs: X
- Average age: X days
- Oldest: X days (file:line)
- By type: TODO: X, FIXME: X, HACK: X, etc.
- Quality score distribution: ...
```

```
