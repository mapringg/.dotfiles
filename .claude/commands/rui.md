---
allowed-tools: all
description: Review a React component against Refactoring UI best practices and propose concrete fixes
arguments: path to React component file ($ARGUMENTS)
---

# Refactoring UI Review

Evaluate a React component’s structure and styles against Refactoring UI principles, highlight issues with severities, and propose precise fixes with example patches.

## Inputs

- `$ARGUMENTS`: Path to the React component file (e.g., `src/components/Card.tsx`).
- Optional context (if present nearby): co-located styles, Story/MDX, tests, and usage sites.

## Workflow

1. Load context
   - Read the component at `$ARGUMENTS` (and `.tsx/.jsx` siblings like `*.stories.*`, `*.test.*`, `*.module.css|scss`, `styled.*`).
   - Detect styling approach: Tailwind (className tokens), CSS Modules, styled-components/emotion, inline styles.
   - Note framework constraints (Next.js/Remix), i18n, and design tokens if present.

2. Structure and semantics
   - Ensure semantic elements: `button` vs `div role="button"`, `a[href]` for navigation, `label` + `htmlFor` for inputs, `nav/header/main/section/article/aside` where applicable.
   - Verify keyboard/focus: `tabIndex`, visible focus ring, `aria-*` where required (icon-only buttons, landmark roles), `Enter/Space` handlers for button-like elements.
   - Check component API: clear props, reasonable defaults, variant props instead of class toggles explosion, avoid deep prop drilling via composition.

3. Refactoring UI heuristics
   - Typography
     • Use a consistent scale; avoid many sizes/weights.
     • Prefer fewer weights; use color/size/spacing for hierarchy.
     • Adequate line-height; avoid tight body text.
   - Spacing & layout
     • Prefer an 4/8pt scale; avoid arbitrary pixel values.
     • Use `gap` for flex/grid spacing over margin-chaining.
     • Create hierarchy with space; avoid cramming.
     • Constrain readable widths (e.g., `max-w-prose`/`~65ch`) for text blocks.
   - Color & contrast
     • Limited palette; favor neutrals and tints/shades.
     • Use opacity or light borders for separation; avoid harsh #e5e7eb-on-white clones.
     • Verify contrast for text and interactive elements (WCAG AA+ when possible).
   - Borders, radii, shadows
     • Prefer subtle shadows for elevation over thick borders.
     • Use consistent rounding scale; avoid mixing many radii.
     • Separate sections with contrast, spacing, or dividers instead of boxes.
   - States & feedback
     • Provide hover/active/focus/disabled styles; show loading/empty/error states.
     • Icon-only controls need `aria-label` and visible tooltips as needed.
   - Iconography
     • Consistent style (stroke/fill), size, and alignment; balanced with text.
   - Lists/tables
     • Consider zebra or subtle row separation; align numerics; adequate density.

4. Static analysis cues
   - Tailwind: flag non-scale values (e.g., `mt-[5px]`, arbitrary hex not in tokens), missing `focus-visible`, inconsistent `gap-*`, misuse of `space-*` vs `gap`.
   - CSS: repeated magic numbers, hard-coded colors, heavy borders, unclear z-index, deep nesting.
   - JSX: nested wrappers, non-semantic elements, duplicated class variants, unclear prop names.

5. Findings and severities
   - Classify each issue: High (accessibility/contrast/semantics), Medium (readability/hierarchy/interaction), Low (polish/consistency).
   - For each finding, explain why it matters per Refactoring UI and how to fix.

6. Propose fixes
   - Provide concrete suggestions and example code patches (JSX and class/style changes).
   - Prefer design tokens/utilities already present; do not invent new one-off styles.
   - Keep changes minimal and focused; avoid refactors beyond the component surface unless necessary.

7. Validate
   - Cross-check that fixes maintain semantics, a11y, and responsive behavior.
   - Ensure no regressions in tests/stories if present.

## Rules

- Follow existing project conventions (naming, tokens, Tailwind config, CSS approach).
- Prefer utilities/variants over ad-hoc inline styles; reduce visual noise.
- Do not weaken accessibility for aesthetics; focus-visible must remain apparent.
- Keep the component API coherent; use variant props for style changes.
- Respect i18n and RTL if applicable; avoid styling that breaks mirroring.

## Output

- Summary: component, stack/style detection, quick context.
- ✅ Done Well: Concrete positives with references to lines/selectors.
- ⚠️ Issues Found: For each, include Severity, Location, Why (Refactoring UI rationale), and Fix.
- Example Patch: Suggested diff or JSX snippet showing improvements.
- 📊 Verdict: Readiness and priority next steps.
- Offer: Ask permission to apply the patch to `$ARGUMENTS`.

## Example Checklist (apply where relevant)

- Typography: limited sizes/weights, proper hierarchy, readable line-heights.
- Spacing: consistent 4/8pt scale, gaps over margins, breathing room.
- Color: limited palette, sufficient contrast, neutrals and tints.
- Separation: shadows/dividers/contrast instead of heavy borders.
- Radii: consistent rounding scale; avoid mixing.
- States: hover/focus/active/disabled + empty/loading/error.
- Semantics: correct elements, labels, keyboard access, focus-visible.
- Layout: constrained readable widths, alignment, consistent container paddings.
- Icons: consistent style/size, alt/labels for non-text controls.

Begin the review now.
