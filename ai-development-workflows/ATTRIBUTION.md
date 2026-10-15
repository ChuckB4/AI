# Attribution & Licenses

This library adapts ideas and patterns from open-source projects. Where a
workflow is reverse-engineered from an external project, only the *behavioral
pattern* is reused — **no source code is copied** — and the origin is credited
here.

## Adapted patterns

| Pattern | Source project | License | How it is used |
| --- | --- | --- | --- |
| Git discipline (small, reviewable, reversible commits; auto-commit per logical change) | [Aider](https://aider.chat/) ([repo](https://github.com/Aider-AI/aider)) | Apache-2.0 | Distilled into `.kiro/steering/git-workflow.md`. Pattern only. |
| Repo map (map a codebase before editing instead of bulk-reading files) | [Aider](https://aider.chat/) | Apache-2.0 | Distilled into `.kiro/steering/repo-map-first.md`. Pattern only. |
| Post-edit lint/test loop (verify the changed system) | [Aider](https://aider.chat/) | Apache-2.0 | Distilled into `.kiro/steering/verification-loop.md`. Pattern only. |
| Approval-gating of risky/costly commands | [Agent Cost Guard](https://github.com/incline-ltd/agent-cost-guard) | see upstream | Distilled into `.kiro/steering/safe-execution.md`. Pattern only. |

## Reference lists consulted

The following curated "awesome" lists were used only as directories to discover
tools and patterns. No content was copied from them:

- Awesome Agentic Engineering — https://github.com/incline-ltd/awesome-agentic-engineering
- Awesome AI Coding Agents (various community lists)

## Notes

- Apache-2.0 permits derivative work and adaptation of ideas with attribution.
  This file provides that attribution.
- If any file in this repository later includes material under a different
  license, add a row above and include the upstream `LICENSE` text alongside the
  imported file.
