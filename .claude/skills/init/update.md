# Update Init Command

Update existing init command.

Update an existing init helper with new content. Updates:

1. The master init helper at `~/.claude/skills/init/helpers/init-{name}.md`
2. The current project's `.claude/rules/{name}.md` (if it exists)

**Argument**: the name of the init (e.g., `react`, `laravel`, `vue`) — passed from `/init update {name}`

---

## Phase 1: Validate the Init Command

1. Parse the init name from `$ARGUMENTS`
   - If empty, list available init commands (glob `~/.claude/skills/init/helpers/init-*.md`) and ask which one to update
   - Strip any leading `init-` prefix if user included it

2. Check that `~/.claude/skills/init/helpers/init-{name}.md` exists
   - If not found, show available commands and ask user to pick one

---

## Phase 2: Choose Update Source

Ask the user using `AskUserQuestion`:

**Question**: "How would you like to update the {Name} init?"

**Options**:

1. **Extract from conversation** — "I'll analyze our conversation and extract relevant learnings to add"
2. **Manual input** — "You describe or paste the content to add"

---

## Phase 3a: Extract from Conversation Context

If the user chose "Extract from conversation":

1. **Read the current init file** to understand existing content and structure

2. **Analyze the conversation history** for:
   - Problems solved and their solutions
   - Patterns discovered or established
   - Best practices identified
   - Code examples that worked well
   - Gotchas or mistakes to avoid
   - Configuration or setup details

3. **Filter for relevance** to `{name}`:
   - Only extract content directly related to the init's technology
   - Ignore general discussion or unrelated topics

4. **Handle no relevant content**:
   - If nothing relevant found, tell the user: "I didn't find any {Name}-specific learnings in our conversation. Would you like to provide input manually instead?"
   - If user says yes, go to Phase 3b

5. **Draft and present the update**:
   - Show the extracted content formatted as it would appear in the init
   - Ask: "Here's what I found. Should I add this to the {Name} rules?"
   - Let user approve, request modifications, or reject

6. If approved, proceed to Phase 4

---

## Phase 3b: Manual Input

If the user chose "Manual input":

1. **Show current content summary**:
   - Read `~/.claude/skills/init/helpers/init-{name}.md`
   - Display the section headings and a brief overview of what's covered
   - Don't dump the entire content — just enough context

2. **Ask**: "What would you like to update or add to the {Name} rules?"

3. Let the user describe their update (new content, changes, code examples, rules)

4. Proceed to Phase 4

---

## Phase 4: Integrate and Confirm

### 4a. Draft the Integration

1. Read `~/.claude/skills/init/helpers/init-{name}.md`
2. Locate the rules content (between `<!-- RULES_START -->` and `<!-- RULES_END -->` markers under `## Content`)
3. Integrate the update into the existing content:
   - Add new sections where appropriate
   - Update existing sections if the update modifies them
   - Preserve the overall structure and formatting

### 4b. Confirm Before Writing

Show the user the integrated result:

- Display the new/changed sections (not the entire file unless small)
- Ask: "Does this look right? Should I apply these changes?"

If user wants modifications, adjust and confirm again.

### 4c. Apply Updates

Once confirmed:

1. **Update the master init file**: Write to `~/.claude/skills/init/helpers/init-{name}.md`
   - Preserve `<!-- RULES_START -->` and `<!-- RULES_END -->` markers

2. **Update project rules file** (if applicable):
   - Check if `./.claude/rules/{name}.md` exists
   - If yes: overwrite with the new content (rules files are idempotent)
   - If no: skip (the user can run the init command to create it)

---

## Phase 5: Report Changes

```
Updated:
  ✓ ~/.claude/skills/init/helpers/init-{name}.md — master init helper
  ✓ ./.claude/rules/{name}.md — project rules file  (or "skipped — file doesn't exist")

Changes made:
  - [Brief description of what was added/changed]
```

---

## Content Integration Guidelines

1. **Adding new rules**: Place in appropriate subsection, or create new `###` heading
2. **Adding code examples**: Use proper syntax highlighting, place near related rules
3. **Updating existing rules**: Modify in place, don't duplicate
4. **Preserve markers**: Keep `<!-- RULES_START -->` and `<!-- RULES_END -->` intact in the master init file

---

## Notes

- This command modifies the master init helper, affecting future `/init` runs
- If user's update is unclear, ask clarifying questions
- Backup is not needed — git tracks changes to `~/.claude/skills/`
