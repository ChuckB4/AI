# Release Engineering Pack

Skills and standards for shipping software safely — versioning, changelogs,
pre-release verification, and controlled, reversible releases.

## Purpose

Encode a disciplined release process so an agent ships changes with the right
checks, clear provenance, and an easy path to roll back. Complements the
`git-workflow` and `safe-execution` steering rules.

## Scope

In scope:

- Semantic versioning and version-bump discipline.
- Changelog generation and release notes from commit history.
- Pre-release checklists: build, tests, lint, security scan all green.
- Tagging, artifact creation, and reproducible builds.
- Controlled rollout and rollback strategy; feature flags where relevant.
- CI/CD gating that enforces the verification loop before release.
- Pre-launch review prompts/scorecards adapted from public launch-prompt sets.

Out of scope:

- Cloud infra provisioning specifics (treat as billable/risky per
  safe-execution; cross-reference infra tooling instead of embedding it).

## Planned contents

| Item | Type | Status |
| --- | --- | --- |
| Semantic versioning & bump policy | skill | planned |
| Changelog & release notes | skill | planned |
| Pre-release verification checklist | skill | planned |
| Tagging & artifact packaging | skill | planned |
| Rollback & controlled rollout | skill | planned |
| Pre-launch review scorecard | skill | planned |

No item is marked done until its file exists and is reviewed.

## Quality requirements

- No release path may bypass the verification loop or security scans.
- Every release must be tagged and reversible; rollback steps are mandatory.
- Any billable/production action is gated per safe-execution steering.

## Completion criteria

- [ ] All planned skills exist as detailed `SKILL.md` files with examples.
- [ ] A reusable pre-release checklist and rollback runbook are included.
- [ ] This table matches the files on disk.
