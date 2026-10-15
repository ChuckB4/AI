# Testing Pack

Skills and standards for designing and running tests that actually verify
behavior — the practical backbone of the `verification-loop` steering rule.

## Purpose

Encode a testing philosophy and concrete practices so an agent writes tests
that catch real defects, chooses the right test level for the risk, and runs
suites correctly in automated/sandbox contexts.

## Scope

In scope:

- The test pyramid: unit, integration, end-to-end — and when to use each.
- Writing behavior-focused tests (test outcomes, not implementation detail).
- Test data, fixtures, mocking/stubbing, and their trade-offs.
- Determinism: eliminating flakiness, controlling time/randomness/network.
- Running suites in single-run (non-watch) mode for CI/sandbox.
- Coverage as a signal, not a target; meaningful assertions.
- Framework-agnostic principles with examples across common runners.

Out of scope:

- Framework install/config beyond what a skill example needs.
- Load/perf testing specifics unless added as a sub-pack.

## Planned contents

| Item | Type | Status |
| --- | --- | --- |
| Testing philosophy & test pyramid | skill | planned |
| Behavior-focused unit tests | skill | planned |
| Integration & end-to-end tests | skill | planned |
| Fixtures, mocking & determinism | skill | planned |
| Running suites in CI/sandbox | skill | planned |

No item is marked done until its file exists and is reviewed.

## Quality requirements

- Tests must assert behavior/outcomes, not restate implementation.
- Every example runs in single-run mode (no watchers) per platform guidance.
- Flakiness sources (time, randomness, network, order) must be addressed.

## Completion criteria

- [ ] All planned skills exist as detailed `SKILL.md` files with examples.
- [ ] The pack is referenced by debugging (regression tests) and domain packs.
- [ ] This table matches the files on disk.
