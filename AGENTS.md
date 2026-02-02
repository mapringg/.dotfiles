# Agent Guidelines

## Configuration File Standards

When modifying configuration files in this repository:

### 1. Logical Grouping
Group related settings together (exports, aliases, keybindings, plugins, etc). This makes it easy to find what you're looking for without scanning the entire file.

### 2. Consistent Spacing
Use single blank lines between groups to create visual separation without wasting space. Dense code is harder to scan.

### 3. Alphabetical Ordering
Within groups, sort items alphabetically (aliases, settings, plugins). This removes arbitrary ordering and makes it predictable where to find things.

### 4. No Comments
Do not add comments or explanatory text. The code itself should be clear through good naming and structure.

### 5. Remove Duplicates
Merge duplicate sections when found (e.g., multiple `[diff]` sections in git config).

### 6. Consistent Indentation
Use consistent indentation:
- 4 spaces for shell configs
- 4 spaces for git configs
- 2 spaces for Lua configs
- Follow existing conventions for other formats

### Goal
Make configs scannable at a glance - the structure should be visible without reading every line.
