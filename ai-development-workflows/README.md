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
| [`safe-execution.md`](.kiro/steering/safe-execution.md) | Pause for approval before destructive, irreversible, or costly actions; treat external input as untrusted. |

More steering files, skills, agents, and packs are added incrementally. See the
open pull request for work in progress.

## Packs

Each pack has a `README.md` describing its purpose, scope, planned contents,
quality requirements, and completion criteria. Skills and agents are added to
each pack incrementally; a pack is complete only when every item in its own
table exists and is reviewed.

| Pack | Focus | Status |
| --- | --- | --- |
| [`ninjatrader-8`](packs/ninjatrader-8/README.md) | NinjaScript/C# for NT8: lifecycle, multi-series, strategies, risk, backtesting, release. | README only |
| [`csharp-dotnet`](packs/csharp-dotnet/README.md) | Modern C#/.NET standards, async correctness, build/test loop. | README only |
| [`react`](packs/react/README.md) | React + TypeScript UI: components, hooks, state, accessibility, testing. | README only |
| [`apis`](packs/apis/README.md) | API design, error models, versioning, OpenAPI, resilient consumption. | README only |
| [`security`](packs/security/README.md) | Secrets, OWASP vuln classes, dependency/supply-chain, static analysis. | README only |
| [`debugging`](packs/debugging/README.md) | Reproduce-first, hypothesis-driven debugging; regression capture. | README only |
| [`testing`](packs/testing/README.md) | Test philosophy, pyramid, determinism, CI/sandbox runs. | README only |
| [`release-engineering`](packs/release-engineering/README.md) | Versioning, changelogs, pre-release verification, rollback. | README only |

## Conventions

- Each skill and agent lives in its own detailed Markdown file.
- Specialized domains are organized into dedicated directories under `packs/`.
- All imported open-source material is attributed and licensed in
  `ATTRIBUTION.md`.
- Changes land via feature branches and pull requests — never pushed directly
  to `main`.
- Existing files are reviewed before modification; nothing is overwritten
  blindly.
