# Add New Init Helper

Create a new init helper by autonomously researching best practices. The user provides the framework name (or it's inferred from context); you do the research. This workflow is accessed via `/faster` → Init → Create new init.

**Reference**: Follow `~/.claude/skills/faster/reference/init/conventions.md` for the standard rules file workflow.

## Phase 1: Determine Name and Source

1. **Name**: Infer from context, or ask: "What framework/tool should I create an init for?"
   - This becomes `init-{name}.md` in the helpers directory
   - Use lowercase, no spaces
   - Verify it doesn't conflict with existing helpers (glob `~/.claude/skills/faster/reference/init/helpers/init-*.md`)

2. **Source**: Check if the user provided a URL
   - **URL provided** → use it as the primary research source (Phase 2a)
   - **No URL** → do autonomous web research (Phase 2b)

---

## Phase 2a: Research from URL

1. Fetch the URL and extract best practices, guidelines, patterns, and code examples
2. Supplement with a web search if the URL alone doesn't cover:
   - Common mistakes and pitfalls
   - Performance tips
   - TypeScript patterns
   - Detection indicators (what files/packages signal this framework)

---

## Phase 2b: Autonomous Web Research

Search the web for the framework's latest best practices:

1. **Official documentation** — current version features, API patterns, recommended usage
2. **Best practices guides** — from official docs and reputable community sources
3. **Common mistakes** — pitfalls, anti-patterns, things beginners get wrong
4. **Performance tips** — optimization patterns specific to this framework
5. **TypeScript integration** — type patterns, generics usage, common type issues
6. **Code examples** — idiomatic usage patterns (these are the most valuable part)

Also determine:

- **Path pattern**: What file types do these rules apply to? (e.g., `**/*.{tsx,jsx}` for React, blank if broad)
- **Detection indicators**: What files, packages, or config entries signal this framework?

---

## Phase 3: Draft the Init Helper

Create the helper content using this template, then **present it to the user for review**:

```markdown
# Initialize {Name} Best Practices

Add {Name} best practices. **Follow `~/.claude/skills/faster/reference/init/conventions.md` for standard file handling.**

## Detection

- {DETECTION_INDICATORS — files, packages, config entries that signal this framework}
- {ADDITIONAL_INDICATORS}

## Target File

`.claude/rules/{name}.md`

## Path Pattern

`{PATH_PATTERN_OR_BLANK}`

## Content

<!-- RULES_START -->
---
paths: "{PATH_PATTERN}"
---

# {Name} Rules

{RESEARCHED_CONTENT}

### Common Mistakes

{COMMON_MISTAKES}
<!-- RULES_END -->
```

**Notes on the template:**

- `<!-- RULES_START -->` and `<!-- RULES_END -->` markers enable fast programmatic extraction
- Include YAML frontmatter with `paths:` if rules are file-type specific
- Omit the frontmatter section entirely if rules apply broadly
- Keep ALL code examples — these are the most valuable part

**Present the draft to the user** — show the full content and ask: "Does this look right, or would you like me to adjust anything?"

If the user wants changes, revise and confirm again.

---

## Phase 4: Write and Report

Once confirmed, write to `~/.claude/skills/faster/reference/init/helpers/init-{name}.md`, then report:

```
Created:
  - ~/.claude/skills/faster/reference/init/helpers/init-{name}.md

Run `/faster` → Init → Initialize project in any project to auto-detect and apply {Name} best practices.
The rules will be written to `.claude/rules/{name}.md`
```

**Note**: No need to update `setup.md` — it dynamically discovers helpers by scanning the `helpers/` directory and reading each helper's `## Detection` section.

## Guidelines for Content

1. **Keep ALL code examples** — these are the most valuable part
2. **Use tables** for quick reference where appropriate
3. **Structure with ### subheadings** for different topics
4. **Always include a "Common Mistakes" section**
5. **Add "Quick Reference" table** if the content is substantial
6. Ensure code examples have proper syntax highlighting (```typescript, ```php, etc.)

## Notes

- Research autonomously — don't ask the user to provide content
- The user reviews and corrects the output, not the input
- Rules files are idempotent — safe to run repeatedly to update
