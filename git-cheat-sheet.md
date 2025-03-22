# Git Cheat Sheet for Team Collaboration

## 1. Core Workflow (Daily Use)

### Status & Basics

- `gst` - Show current status
- `gss` - Short status format
- `g` - Git command shortcut

### Committing

- `gc` - Commit with message
- `gca` - Commit all changes
- `gc!` - Amend last commit

### Pushing/Pulling

- `gl` - Pull changes
- `gp` - Push changes
- `gup` - Pull with rebase
- `ggp` - Push to current branch

## 2. Branch Management

### Branch Operations

- `gb` - List branches
- `gba` - List all branches
- `gco` - Checkout branch
- `gcb` - Create & checkout new branch
- `gbd` - Delete branch

### Rebase Workflows

- `grb` - Start rebase
- `grba` - Abort rebase
- `grbc` - Continue rebase
- `grbi` - Interactive rebase

## 3. GitHub Collaboration Workflows

### Pull Requests

1. Create Feature Branch:

```bash
gcb feature/new-login
gp -u origin feature/new-login
```

2. Make Changes & Push:

```bash
gc "Add new login functionality"
gp
```

3. Create PR:

```bash
gh pr create --title "New login feature" --body "Implements new login flow"
```

4. Review & Merge:

```bash
gh pr checkout 123  # Checkout PR branch
gh pr review --approve  # Approve PR
gh pr merge --squash  # Merge PR
```

### Code Review

- `glg` - Show commit log with stats
- `glo` - One-line commit log
- `gd` - Show changes
- `gdt` - List changed files
- `gh pr diff` - Show PR changes
- `gh pr comment` - Add review comment

## 4. Conflict Resolution

### Stashing

- `gsta` - Stash changes
- `gstp` - Apply stash
- `gstl` - List stashes

### Merging

- `gmt` - Launch merge tool
- `gm` - Merge branch

## 5. Advanced Tools

### Cleanup

- `gclean` - Interactive clean
- `grpo` - Prune remote branches

### Debugging

- `gbl` - Blame with whitespace ignore
- `gsh` - Show commit details

## 6. GitHub-Specific Tools

### GitHub CLI

- `gh pr status` - Show PR status
- `gh pr list` - List open PRs
- `gh pr checkout` - Checkout PR branch
- `gh issue create` - Create new issue
- `gh repo fork` - Create fork of repository

### Troubleshooting

1. Fixing Broken PR:

```bash
gup  # Update with rebase
# Fix conflicts
gc "Fix merge conflicts"
gp -f  # Force push fixed branch
```

2. Stashing Workflow:

```bash
gsta  # Stash current work
gco main  # Switch to main
gup  # Update main
gco feature/branch  # Back to feature
gstp  # Apply stash
# Resolve conflicts if any
```

---

### Helper Functions

- `git_current_branch()` - Get current branch name
- `git_default_branch()` - Get default branch name
