---
name: tracer-bullets
description: Build features using tracer bullets, tiny end-to-end vertical slices that validate assumptions early before expanding. Use when building multi-layer features where wrong assumptions could cascade into wasted work.
---

# Tracer Bullets

Build features as tiny, end-to-end vertical slices that validate assumptions early before expanding. From _The Pragmatic Programmer_ — write code that gets feedback as quickly as possible by going through all layers of the system first.

## Phase 1: Task Breakdown

1. **Identify the layers** involved in the feature (e.g., database, backend, API, frontend)
2. **Define the tracer bullet** — the smallest possible slice that touches all layers end-to-end
3. **List subsequent expansions** — each one builds on the validated tracer bullet
4. **Present the breakdown** to the user before writing any code

## Phase 2: Build the Tracer Bullet

Build only the tracer bullet — one path through all layers, nothing more.

- Just enough to validate that the architecture and assumptions are correct
- No error handling, no edge cases, no extra endpoints — just the critical path
- No authentication, rate limiting, logging, or middleware until the core path works

## Phase 3: Validate and Get Feedback

1. **Stop and verify** — run, test, or demonstrate the tracer bullet
2. **Confirm with the user** that the core path works before continuing
3. **Adjust the plan** if assumptions turned out to be wrong

## Phase 4: Expand One Slice at a Time

1. **Pick the next expansion** from the breakdown in Phase 1
2. **Build it**, then stop and verify
3. **Repeat** until the feature is complete

## Notes

- **Avoid horizontal layers** — do not build all endpoints, all models, or all middleware in isolation before connecting them
- **Each expansion should be independently verifiable** — the user should be able to confirm it works before moving on
- **Adjust the plan as you go** — earlier slices may reveal that later ones need to change
