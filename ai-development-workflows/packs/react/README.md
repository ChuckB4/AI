# React Pack

Skills and standards for building front-end applications with React and modern
TypeScript tooling.

## Purpose

Encode reliable React practices so an agent produces accessible, performant,
and testable UI code — covering component design, hooks correctness, state
management, data fetching, and the front-end build/test loop.

## Scope

In scope:

- Component structure, composition, and prop/typing conventions (TypeScript).
- Hooks rules and common pitfalls (dependency arrays, stale closures, effect
  cleanup).
- State management choices (local state, context, external stores) and when to
  use each.
- Data fetching, caching, and loading/error states.
- Accessibility (semantic HTML, ARIA, keyboard navigation).
- Front-end testing (component tests, user-centric queries) and the
  build/lint/test loop (e.g. Vite, ESLint, a test runner).

Out of scope:

- Specific design systems unless added as a sub-pack.
- Back-end/API design (see the `apis` pack).

## Planned contents

| Item | Type | Status |
| --- | --- | --- |
| Component design & TypeScript props | skill | planned |
| Hooks correctness | skill | planned |
| State management decision guide | skill | planned |
| Data fetching & async UI states | skill | planned |
| Accessibility baseline | skill | planned |
| Front-end testing & build loop | skill | planned |

No item is marked done until its file exists and is reviewed.

## Quality requirements

- Favor TypeScript and user-centric testing by default.
- Accessibility is a requirement, not an afterthought.
- Performance guidance must be measurable (avoid premature memoization advice).
- Examples run under a stated toolchain and follow verification-loop steering.

## Completion criteria

- [ ] All planned skills exist as detailed `SKILL.md` files with examples.
- [ ] Testing skill demonstrates single-run (non-watch) execution.
- [ ] This table matches the files on disk.
