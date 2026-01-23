# Git Workflows

## Starting the Day

```fish
gfa                    # Fetch all remotes, prune stale branches
gst                    # Check status - anything left from yesterday?
glog                   # Quick look at recent history
```

## Making Changes

```fish
# Edit some files, then...
gst                    # See what changed
gd                     # Review your changes
gaa                    # Stage everything
gcm "add user auth"    # Commit with message

# Or do it all at once:
gcam "add user auth"   # Stage all + commit in one command
```

## Staying in Sync

```fish
# Before pushing, get latest changes:
gup                    # Pull with rebase (clean history)
gp                     # Push

# If you have uncommitted changes:
gupa                   # Pull with rebase + auto-stash your changes
```

## Working on a Feature Branch

```fish
gswc feature/login     # Create and switch to new branch
# ... do your work ...
gcam "implement login"

# Ready to merge? First update from main:
gfa                    # Fetch latest
grbom                  # Rebase onto origin/main
gp!                    # Force push (safe, uses --force-with-lease)
```

## Oops, I Need to Fix My Last Commit

```fish
# Forgot a file:
gaa                    # Stage the missing file
gcn!                   # Amend without changing message

# Wrong commit message:
gc!                    # Amend and edit message

# Need to undo the commit entirely:
grh                    # Reset HEAD (keeps changes staged)
grhh                   # Reset HEAD --hard (discards everything!)
```

## Interactive Rebase (Cleaning Up History)

```fish
grbi HEAD~3            # Rebase last 3 commits interactively
# In editor: pick, squash, reword, drop...

grba                   # Abort if things go wrong
grbc                   # Continue after resolving conflicts
```

## Fixup Commits (Clean Way to Amend Old Commits)

```fish
# Found a bug in an older commit? Don't amend, fixup:
gaa                    # Stage the fix
gcfx abc123            # Create fixup commit for abc123
grbmia                 # Rebase main --interactive --autosquash
                       # (auto-squashes fixups into their targets)
```

## Stashing Work

```fish
gsta                   # Stash current changes
gsw other-branch       # Switch to another branch
# ... do something ...
gsw -                  # Switch back
gstp                   # Pop stash

gstl                   # List all stashes
gstd                   # Drop top stash
```

## Cherry-Picking

```fish
gcp abc123             # Copy a commit to current branch
gcpc                   # Continue after conflict
gcpa                   # Abort
```

## Debugging with Bisect

```fish
gbss                   # Start bisect
gbsb                   # Mark current as bad
gbsg v1.0              # Mark v1.0 as good
# Git checks out commits, you test each:
gbsb                   # Bad
gbsg                   # Good
# ... until it finds the culprit
gbsr                   # Reset when done
```

## Inspecting History

```fish
glog                   # Oneline graph
gloga                  # Graph with all branches
glom                   # Commits on your branch not in main
gsh abc123             # Show a specific commit
gbl file.txt           # Blame a file
```

## Cleaning Up

```fish
gbda                   # Delete all merged branches
gclean                 # Interactive clean untracked files
gclean!                # Force clean (dangerous)
```

## Quick Reference

| I want to...                | Type      |
| --------------------------- | --------- |
| Status                      | `gst`     |
| Diff                        | `gd`      |
| Stage all                   | `gaa`     |
| Commit                      | `gcm "m"` |
| Stage + commit              | `gcam`    |
| Pull rebase                 | `gup`     |
| Push                        | `gp`      |
| Force push (safe)           | `gp!`     |
| Amend                       | `gc!`     |
| Switch branch               | `gsw`     |
| New branch                  | `gswc`    |
| Fetch all                   | `gfa`     |
| Rebase on main              | `grbom`   |
