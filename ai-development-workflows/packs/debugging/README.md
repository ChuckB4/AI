# Debugging Pack

Skills and standards for systematic debugging — turning "it's broken" into a
reproducible, root-caused, and verified fix.

## Purpose

Encode a disciplined debugging method so an agent investigates before changing
code, isolates root cause instead of patching symptoms, and proves the fix with
a test. Complements the `verification-loop` steering rule.

## Scope

In scope:

- Reproduction: creating a minimal, reliable repro before attempting a fix.
- Hypothesis-driven investigation: form, test, and discard hypotheses.
- Reading errors, stack traces, and logs effectively.
- Bisection (code and history) and binary-search narrowing.
- Instrumentation: logging, assertions, debuggers, and when to use each.
- Regression protection: capture the bug as a failing test, then make it pass.
- Debugging concurrency, state, and timing issues at a practical level.

Out of scope:

- Domain-specific debugging that belongs in a domain pack (cross-reference,
  e.g. NT8 lifecycle issues live in the NinjaTrader 8 pack).

## Planned contents

| Item | Type | Status |
| --- | --- | --- |
| Reproduce-first method | skill | planned |
| Hypothesis-driven investigation | skill | planned |
| Reading traces & logs | skill | planned |
| Bisection & narrowing | skill | planned |
| Regression test capture | skill | planned |

No item is marked done until its file exists and is reviewed.

## Quality requirements

- The method must put reproduction and root cause before any code change.
- Every fix pattern ends with a regression test, per verification-loop steering.
- Guidance must discourage speculative, unverified edits.

## Completion criteria

- [ ] All planned skills exist as detailed `SKILL.md` files with examples.
- [ ] The regression-test skill ties into the testing pack.
- [ ] This table matches the files on disk.
