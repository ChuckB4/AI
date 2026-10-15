---
inclusion: always
---

# Repo-Map First

Reverse-engineered from Aider's "repo map" idea: before editing an unfamiliar
codebase, build a compact mental map of its structure instead of reading every
file. Spend context budget on the map and the few files that actually matter,
not on bulk file dumps.

## The rule

Before proposing or making a change to code you do not already understand:

1. **Build a structural map first.** Identify the directory layout, the key
   modules, their public interfaces (exported functions, classes, types,
   routes, schemas), and how they depend on one another.

2. **Locate the relevant slice.** From the map, pick only the files and symbols
   involved in the task. Read those closely; skim or skip the rest.

3. **Trace the execution path.** For a change, follow the call path from entry
   point to the code you will edit, so edits respect existing contracts.

4. **Only then edit.** Never propose changes to code you have not seen. Ground
   every edit in the actual structure, not an assumption about it.

## How to build the map efficiently

- Prefer breadth-first discovery: list directories, grep for symbol
  definitions and references, and read signatures/headers before full bodies.
- Use search over reading: `grep` for a function name across the repo beats
  opening ten files to find where it lives.
- For larger or unfamiliar areas, delegate the exploration (e.g. a
  context-gathering sub-agent) and treat its findings as your file reads —
  do not re-read what it already returned.

## Why

- Keeps context focused and cheap, so more budget is spent on reasoning.
- Reduces the chance of edits that break an interface the agent never saw.
- Mirrors how an experienced engineer navigates a new repo: map, then dig.

## Attribution

The repo-map concept is adapted from the open-source
[Aider](https://aider.chat/) project (Apache-2.0). Only the pattern is reused;
no Aider source code is included. See `ATTRIBUTION.md`.
