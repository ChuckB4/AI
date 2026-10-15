# AI Development Workflows

Master library for AI-assisted development: reusable Kiro steering files,
agent definitions, `SKILL.md` skills, coding standards, testing procedures,
Git workflows, and multi-agent development systems.

This library is tool-agnostic where possible. Where a pattern originates from
an open-source project, it is adapted (not copied) and credited in
[`ATTRIBUTION.md`](ATTRIBUTION.md).

## Layout

```
ai-development-workflows/
├── README.md               # this file
├── AGENTS.md               # repo-wide instructions for coding agents
├── ATTRIBUTION.md          # credits & licenses for imported/adapted material
├── .kiro/
│   └── steering/           # Kiro steering files (always-on workflow rules)
├── skills/                 # one SKILL.md per skill
├── agents/                 # one Markdown file per agent definition
└── packs/                  # specialized domain packs
    ├── ninjatrader-8/
    ├── csharp-dotnet/
    ├── react/
    ├── apis/
    ├── security/
    ├── debugging/
    ├── testing/
    └── release-engineering/
```

## Steering files

| File | Purpose |
| --- | --- |
| [`git-workflow.md`](.kiro/steering/git-workflow.md) | Aider-style git discipline: small, reviewable, reversible commits. |
| [`repo-map-first.md`](.kiro/steering/repo-map-first.md) | Map a codebase before editing instead of bulk-reading files. |
| [`verification-loop.md`](.kiro/steering/verification-loop.md) | Edit → lint → test loop; verify the changed system, don't trust generated code. |

More steering files, skills, agents, and packs are added incrementally. See the
open pull request for work in progress.

## Conventions

- Each skill and agent lives in its own detailed Markdown file.
- Specialized domains are organized into dedicated directories under `packs/`.
- All imported open-source material is attributed and licensed in
  `ATTRIBUTION.md`.
- Changes land via feature branches and pull requests — never pushed directly
  to `main`.
- Existing files are reviewed before modification; nothing is overwritten
  blindly.
