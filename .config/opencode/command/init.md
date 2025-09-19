---
description: create agents
agent: build
---

Please analyze this codebase and create an AGENTS.md file with the following structure:

# [Project Name]

Brief description of the project.

## Project Structure

- Key directories and their purposes
- Important files and their roles

## Code Standards

- Build/lint/test commands - especially for running a single test
- TypeScript/language specific guidelines
- Import conventions, formatting, types, naming conventions
- Error handling patterns

## Conventions

- Monorepo conventions if applicable
- File organization patterns
- Any project-specific patterns or practices

The file you create will be given to agentic coding agents (such as yourself) that operate in this repository. Make it about 20 lines long.
If there are Cursor rules (in .cursor/rules/ or .cursorrules) or Copilot rules (in .github/copilot-instructions.md), make sure to include them.

If there's already an AGENTS.md, improve it if it's located in ${path}
