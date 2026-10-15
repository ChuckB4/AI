# NinjaTrader 8 Pack

Production-oriented skills and agent definitions for building, testing, and
releasing NinjaTrader 8 (NT8) components written in NinjaScript / C#.

## Purpose

Give a coding agent the domain knowledge and guardrails to work safely inside
the NT8 ecosystem — where a subtle lifecycle or threading mistake can silently
corrupt indicator values, double-fill orders, or blow through risk limits in
live trading. This pack encodes the NT8-specific rules that general C#
knowledge does not cover.

## Scope

In scope:

- NinjaScript / C# authoring conventions specific to NT8.
- The NT8 component lifecycle and `State` machine (`SetDefaults`,
  `Configure`, `DataLoaded`, `Historical` vs `Realtime`, `Terminated`).
- Multi-series / multi-timeframe data handling and `BarsInProgress`.
- Indicator authoring and indicator reuse inside strategies.
- Strategy execution: order methods, order state, position handling, OCO.
- Risk controls: position sizing, max loss/contracts, kill-switch patterns.
- Backtesting, walk-forward, and optimization workflows.
- Compilation, deployment, and pre-release verification.

Out of scope:

- Broker-specific account setup and non-NT8 platforms.
- Financial or trading advice. This pack is about correct software, not
  strategy profitability.

## Planned contents

Delivered incrementally; this README is updated as each item lands.

| Item | Type | Status |
| --- | --- | --- |
| NinjaScript / C# authoring standards | skill | [done](skills/ninjascript-csharp-standards/SKILL.md) |
| NT8 lifecycle & `State` management | skill | [done](skills/lifecycle-state-management/SKILL.md) |
| Multi-series / multi-timeframe processing | skill | [done](skills/multi-series-processing/SKILL.md) |
| Indicator authoring & integration | skill | [done](skills/indicator-authoring-integration/SKILL.md) |
| Strategy execution & order handling | skill | [done](skills/strategy-execution-order-handling/SKILL.md) |
| Risk controls & kill-switch | skill | planned |
| Backtesting & walk-forward | skill | planned |
| Optimization | skill | planned |
| Compilation & deployment | skill | planned |
| Release verification | skill | planned |
| NT8 strategy-development agent | agent | planned |

No item is marked done until its file exists and is reviewed.

## Quality requirements

- Every rule must be NT8-specific and actionable; omit generic C# advice that
  the `csharp-dotnet` pack already covers (cross-reference instead).
- Lifecycle guidance must distinguish historical vs realtime processing and
  call out thread-affinity hazards.
- Order/risk guidance must be fail-safe by default (flatten/stop on error,
  never widen risk silently).
- Any example code must compile against a stated NT8 version and note that
  version.

## Completion criteria

The pack is considered complete when:

- [ ] All planned skills exist as detailed `SKILL.md` files with examples.
- [ ] The strategy-development agent is defined with explicit guardrails
      referencing the risk-control skill.
- [ ] Each skill links to the relevant steering rules (verification, safe
      execution).
- [ ] A release-verification checklist for NT8 artifacts is included.
- [ ] This table shows every item as done, matching the files on disk.
