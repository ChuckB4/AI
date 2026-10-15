# AGENTS.md — Repository-wide instructions for coding agents

This file gives any coding agent (Kiro, Claude Code, Codex, Cursor, etc.) the
durable rules for working in this repository. It follows the
[AGENTS.md](https://agents.md/) convention.

## What this repo is

A curated library of AI development workflows: steering files, agent and skill
definitions, coding standards, and domain packs. Treat the contents as reusable
reference material, not application code.

## Core working rules

1. **Map before you edit.** Understand the structure of the area you are
   touching before changing it. Do not edit files you have not read.

2. **Small, reviewable commits.** One logical change per commit, with a
   descriptive imperative message (`feat:`, `fix:`, `docs:`, `refactor:`,
   `test:`, `chore:`). Stage files explicitly by name.

3. **Branches and PRs only.** Never commit directly to `main`. Create a feature
   branch and open a pull request.

4. **Never overwrite work blindly.** Review existing files before modifying
   them. Preserve unrelated content (e.g. other top-level directories).

5. **Verify before claiming done.** Confirm the change meets the stated goal.
   A command exiting without error is not proof of success.

6. **Attribute imported material.** Any pattern or text adapted from an
   open-source project must be credited in `ATTRIBUTION.md` with its license.

## File organization

- Steering files: `.kiro/steering/*.md`
- Skills: `skills/<skill-name>/SKILL.md` (or `skills/<skill-name>.md`)
- Agents: `agents/<agent-name>.md`
- Domain packs: `packs/<domain>/`

## Packaging

When asked, package a complete agent or skill collection into a ZIP file for
distribution.
