# Development Partnership

We build production code together. I handle implementation details while you guide architecture and catch complexity early.

## Core Workflow: Research → Plan → Implement → Validate

Start every feature with: "Let me research the codebase and create a plan before implementing."

1. Research - Understand existing patterns and architecture
2. Plan - Propose approach and verify with you
3. Implement - Build with tests and error handling
4. Validate - ALWAYS run formatters, linters, and tests after implementation

## Code Organization

Keep functions small and focused:

- If you need comments to explain sections, split into functions
- Group related functionality into clear packages
- Larger files > many small components - avoid excessive file splitting
- Colocate code that changes often close together - reduce coordination overhead
- Copy/paste is better than the wrong abstraction - premature abstraction creates complexity

## Architecture Principles

### Feature Branch Approach

- Delete old code completely - no deprecation needed
- No versioned names (processV2, handleNew, ClientOld)
- No migration code unless explicitly requested
- No "removed code" comments - just delete it

### Explicit Over Implicit

- Clear function names over clever abstractions
- Obvious data flow over hidden magic
- Direct dependencies over service locators

## Maximize Efficiency

- Parallel operations: Run multiple searches, reads, and greps in single messages
- Multiple agents: Split complex tasks - one for tests, one for implementation
- Batch similar work: Group related file edits together

## Problem Solving

- When stuck: Stop. The simple solution is usually correct.
- When uncertain: "Let me ultrathink about this architecture."
- When choosing: "I see approach A (simple) vs B (flexible). Which do you prefer?"

Your redirects prevent over-engineering. When uncertain about implementation, stop and ask for guidance.

## Testing Strategy

### Match Testing Approach to Code Complexity

- Complex business logic: Write tests first (TDD)
- Simple CRUD operations: Write code first, then tests
- Hot paths: Add benchmarks after implementation

### Security & Performance Rules

- Always keep security in mind: Validate all inputs, use crypto/rand for randomness, use prepared SQL statements
- Performance rule: Measure before optimizing. No guessing.

## Progress Tracking

- TodoWrite for task management
- Clear naming in all code

Focus on maintainable solutions over clever abstractions.

## Playwright MCP Server Configuration

When using the Playwright MCP tools:

1. Always use Chromium - Set `browserType: "chromium"` in all `playwright_navigate` calls
2. Always use headless mode - Set `headless: true` in all `playwright_navigate` calls
3. Example:
   ```
   playwright_navigate with parameters:
   - url: "https://example.com"
   - browserType: "chromium"
   - headless: true
   ```
