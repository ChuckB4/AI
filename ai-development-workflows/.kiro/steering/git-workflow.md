---
inclusion: always
---

# Git Workflow (Aider-style)

Reverse-engineered from Aider's git discipline: keep every change small,
reviewable, and trivially reversible. The goal is that a human can read the
history and undo any single step without untangling unrelated edits.

## Core rules

1. **One logical change per commit.** Do not bundle unrelated edits. If a task
   has distinct steps (refactor, feature, test), commit each separately.

2. **Commit after each completed logical change** — not once at the very end.
   Each commit should leave the repo in a working (or clearly intermediate)
   state.

3. **Write descriptive commit messages.** Use the imperative mood and explain
   *why*, not just *what*:
   - Format: `<type>: <concise summary>` (e.g. `fix:`, `feat:`, `refactor:`,
     `test:`, `docs:`, `chore:`).
   - First line ≤ 72 characters. Add a body when the reason isn't obvious.

4. **Stage files explicitly by name.** Prefer `git add <path>` over `git add -A`
   or `git add .` so no unintended file is swept into a commit.

5. **Keep diffs reviewable.** Avoid mixing formatting-only churn with logic
   changes in the same commit. If a reformat is needed, isolate it.

6. **Make undo easy.** Because each commit is self-contained, reverting is a
   single `git revert <sha>`. Never force-push or rewrite shared history to
   "clean up" unless the user explicitly asks.

## Before committing

- Confirm the change actually builds / the relevant check passes (see the
  verification steering).
- Review the staged diff (`git diff --staged`) and make sure it contains only
  what the commit message describes.

## Branching

- Never commit directly to `main` / `master`. Work on a feature branch and open
  a pull request for review.
- Keep branch names short and descriptive (e.g. `feat/repo-map-steering`).

## Attribution

Workflow discipline reverse-engineered from the open-source
[Aider](https://aider.chat/) project (Apache-2.0). No Aider source code is
included; only the behavioral patterns are adapted. See `ATTRIBUTION.md`.
