---
description: generate prd.json
---

Convert my feature requirements into structured PRD items.
Each item should have: category, description, steps to verify, and passes: false.
Output as a JSON array to prd.json in the project root.

Guidelines:

- Each item should be atomic: completable in a single focused session
- Description should imply scope: mention what changes, not just what it does
- Steps should be verifiable via code: tests, types, or observable behavior
- Order items by dependency: foundational work before features that need it
- If a requirement is large, break it into multiple items

Example:

```json
{
  "category": "functional",
  "description": "New chat button creates fresh conversation and resets state",
  "steps": [
    "Click 'New Chat' button",
    "Verify conversation ID changes",
    "Verify message history is empty",
    "Verify input is focused"
  ],
  "passes": false
}
```
