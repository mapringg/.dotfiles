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

## 3. Code Collaboration

### Merge Requests

- `gmr` - Create GitLab merge request
- `gmwps` - Create MR with pipeline merge

### Code Review

- `glg` - Show commit log with stats
- `glo` - One-line commit log
- `gd` - Show changes
- `gdt` - List changed files

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

## 6. Team-Specific

### GitLab Integration

- `gmr` - Create merge request
- `gmwps` - Create MR with pipeline merge

---

### Helper Functions

- `git_current_branch()` - Get current branch name
- `git_default_branch()` - Get default branch name
