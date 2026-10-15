# Security Pack

Skills and standards for building and reviewing software with security in mind,
and for keeping the development pipeline itself safe.

## Purpose

Encode practical, checkable security practices so an agent avoids common
vulnerability classes, handles secrets correctly, and vets dependencies and
execution risk before release. Complements the `safe-execution` steering rule.

## Scope

In scope:

- Secret management: no secrets in code/logs/commits; detection and rotation.
- Input validation, output encoding, and common vulnerability classes
  (injection, XSS, SSRF, auth/session flaws) — framed by OWASP guidance.
- Dependency and supply-chain risk (known-vuln scanning, provenance).
- Static analysis integration and triage of findings.
- Secure handling of untrusted input consistent with safe-execution steering.
- LLM/agent-specific risks (prompt injection, tool misuse) at a practical
  level.

Out of scope:

- Formal compliance/audit certification work.
- Offensive/exploit development — this pack is defensive only.

## Planned contents

| Item | Type | Status |
| --- | --- | --- |
| Secret management & scanning | skill | planned |
| Input validation & common vuln classes (OWASP) | skill | planned |
| Dependency & supply-chain risk | skill | planned |
| Static analysis & finding triage | skill | planned |
| Untrusted-input & agent-safety practices | skill | planned |

No item is marked done until its file exists and is reviewed.

## Quality requirements

- Every recommendation must be actionable and, where possible, tool-enforceable
  (scanner, analyzer, CI gate).
- Reference recognized sources (e.g. OWASP) with attribution; copy no text.
- Guidance must align with, and reference, the `safe-execution` steering.

## Completion criteria

- [ ] All planned skills exist as detailed `SKILL.md` files with examples.
- [ ] A secret-scanning and a dependency-scanning step are specified for CI.
- [ ] This table matches the files on disk.
