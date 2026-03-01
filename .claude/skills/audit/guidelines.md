
# Guidelines Audit

Audit codebase against coding guidelines using parallel subagents.

## Phase 1: Discover & Select Guidelines

1. **Scan for guidelines**:
   - Check `.claude/rules/*.md` in current project
   - For monorepos, also check `../../.claude/rules/` at root

2. **Use AskUserQuestion** with `multiSelect: true`:
   - First option: "All guidelines"
   - List each found guideline file
   - If no guidelines found, suggest running an init command

3. **Report what was found** (e.g., `Found in .claude/rules/: laravel.md, react.md, tailwind.md`)

## Phase 2: Extract & Categorize Rules

Read selected guidelines and categorize into:

| Category | What to Extract |
|----------|-----------------|
| **Style** | Naming, file structure, formatting |
| **Architecture** | Patterns, anti-patterns, code locations |
| **Framework** | Framework-specific rules, common mistakes |
| **Testing** | Test patterns, naming, coverage |
| **Security** | Validation, auth, injection prevention |
| **Performance** | Caching, queries, optimization |

**Skip**: Setup instructions, command references, general descriptions.

## Phase 3: Parallel Audit

**Only launch subagents for categories that have extracted rules.**

Use `Agent` tool with `subagent_type=general-purpose`. Launch all applicable subagents in a single tool call.

Each subagent prompt should follow this structure:

```
Audit this codebase for [CATEGORY] guideline compliance.

## Rules to Check
[List the ACTUAL extracted rules - be specific]

## Search Strategy
- Use Grep to find pattern violations
- Use Glob to check file organization
- Read key files to verify patterns
- Focus on src/, app/, lib/ - skip vendor/, node_modules/

## Output Format
For each violation found:
- file:line reference
- The rule being violated
- What was found
- Suggested fix

If compliant, list what was checked.
```

## Phase 4: Report

Aggregate subagent findings into:

```markdown
## Audit Results

### Critical (fix now)
- **[Rule]** `file.php:42` — Found X, should be Y

### Warnings (fix soon)
- **[Rule]** `file.php:50` — Found X, consider Y

### Suggestions
- **[Improvement]** `dir/` — Could add X

### Compliant
- Area checked and passing
```

## Phase 5: Fix

Present options:

1. Fix critical only
2. Fix critical + warnings
3. Fix all
4. Choose specific items
5. Report only

When fixing: show before/after, skip items needing manual decisions.

## Notes

- For large codebases, prioritize `git diff --name-only HEAD~20` recent changes
- Always include file:line references
- Offer actionable fixes, not complaints
