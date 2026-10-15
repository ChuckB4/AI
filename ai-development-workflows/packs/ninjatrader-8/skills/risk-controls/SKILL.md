---
name: NT8 Risk Controls and Kill-Switch
description: >
  Enforce hard risk limits in NinjaTrader 8 strategies — position sizing, max
  contracts, per-trade stops, daily loss/profit limits, consecutive-loss and
  error kill-switches, and a fail-safe flatten-and-halt that cannot be bypassed
  by signal logic.
pack: ninjatrader-8
applies_to: NinjaTrader 8 (NinjaScript / C#)
cross_references:
  - ../strategy-execution-order-handling/SKILL.md
  - ../lifecycle-state-management/SKILL.md
  - ../../../../.kiro/steering/safe-execution.md
  - ../../../../.kiro/steering/verification-loop.md
---

# NT8 Risk Controls & Kill-Switch

Risk controls are the non-negotiable safety layer that sits **above** signal
logic. A strategy may be wrong about the market; it must never be wrong about
how much it can lose. These controls must be *hard* — enforced before any order
is submitted, impossible for signal code to skip, and biased toward stopping.

This skill pairs with **strategy-execution** (which references it for fail-safe
behavior) and the **safe-execution** steering rule. It is about software
correctness and capital protection, **not trading advice**.

> Version note: targets NinjaTrader 8 (NinjaScript API as of NT 8.1).

## 1. Layered limits (defense in depth)

Enforce limits at multiple layers so a bug in one does not remove all
protection:

1. **Platform/account layer** — configure account-level max position, max order
   size, and daily loss where available. This backstops the strategy.
2. **Strategy layer** — the checks in this skill, evaluated before every
   submission.
3. **Per-order layer** — every entry has a stop (protective order) so a single
   trade's loss is bounded even if higher layers fail.

Never rely on a single layer.

## 2. Validate limit inputs in `Configure`

All risk parameters are inputs; clamp/reject invalid values before any data
flows (lifecycle skill). An unvalidated risk input is itself a risk.

```csharp
else if (State == State.Configure)
{
    if (MaxContracts   < 1) MaxContracts   = 1;
    if (MaxDailyLoss   < 0) MaxDailyLoss   = 0;   // 0 = disabled, documented
    if (PerTradeStopTicks < 1) PerTradeStopTicks = 1;
}
```

## 3. Position sizing (bounded, tick-aware)

- Compute quantity from a risk budget and the per-trade stop distance, then
  **clamp to `MaxContracts`**. Round down, never up.
- Use the instrument's `TickSize`/`PointValue` for the money math (standards
  skill); do not hard-code contract specs.

```csharp
private int SizePosition(double stopTicks)
{
    if (stopTicks <= 0) return 0;
    double riskPerContract = stopTicks * TickSize * Instrument.MasterInstrument.PointValue;
    if (riskPerContract <= 0) return 0;

    int qty = (int)Math.Floor(RiskBudgetDollars / riskPerContract);
    return Math.Max(0, Math.Min(qty, MaxContracts)); // hard cap
}
```

A size of `0` must mean "do not trade", not "trade default".

## 4. Pre-submission gate (single choke point)

Route **every** entry through one guard so no signal path can bypass it. The
guard returns false → no order is submitted.

```csharp
private bool CanOpenNewPosition(int desiredQty)
{
    if (tradingHalted)                      return false; // kill-switch tripped
    if (desiredQty < 1)                     return false;
    if (Position.Quantity + desiredQty > MaxContracts) return false;
    if (DailyRealizedPnL() <= -MaxDailyLoss && MaxDailyLoss > 0) return false;
    if (ConsecutiveLosses >= MaxConsecutiveLosses && MaxConsecutiveLosses > 0) return false;
    return true;
}
```

In `OnBarUpdate`, entries look like:

```csharp
int qty = SizePosition(PerTradeStopTicks);
if (EntrySignal() && CanOpenNewPosition(qty))
    EnterLong(qty, "LE");
```

## 5. Per-trade stop is mandatory

- Every entry attaches a protective stop (`SetStopLoss` / OCO) sized by
  `PerTradeStopTicks` — see the execution skill for correct pairing. An entry
  with no stop must never reach submission.

## 6. Daily and streak limits

- Track realized P&L for the session; when it breaches `MaxDailyLoss` (or an
  optional daily profit target), **trip the kill-switch**.
- Track consecutive losing trades via `OnExecutionUpdate`/trade completion; trip
  on `MaxConsecutiveLosses`.
- Reset session counters deliberately (e.g. at session start), not implicitly.

## 7. The kill-switch (fail-safe halt)

A single state flag that, once set, stops all new activity and flattens:

```csharp
private bool tradingHalted;

private void TripKillSwitch(string reason)
{
    if (tradingHalted) return;
    tradingHalted = true;

    CancelAllWorkingOrders();   // cancel pending entries/exits you own
    FlattenEverything();        // close open positions to go flat
    Log($"KILL-SWITCH: {reason}", LogLevel.Warning); // no secrets in logs
}
```

Trip it on: daily loss limit, max consecutive losses, order **rejection**, an
unexpected exception, data/connection loss, or any invariant violation. Once
tripped, `CanOpenNewPosition` returns false for the rest of the session —
signal code cannot re-enable it.

- **Fail toward flat.** On any doubt about state, prefer flattening and halting
  over continuing (safe-execution steering).
- Make flatten/cancel idempotent and null-safe; it may run from an error path
  or `Terminated`.

## 8. Verification

Before considering risk controls done (verification-loop steering):

- [ ] Risk inputs validated/clamped in `Configure`.
- [ ] Position size is bounded by `MaxContracts`, rounds down, and `0` means no
      trade.
- [ ] Every entry passes through the single `CanOpenNewPosition` gate.
- [ ] Every entry has a mandatory protective stop.
- [ ] Daily-loss and consecutive-loss limits trip the kill-switch.
- [ ] Kill-switch cancels working orders, flattens, and blocks re-entry for the
      session; it is idempotent/null-safe.
- [ ] Error/rejection/disconnect paths trip the kill-switch (fail toward flat).
- [ ] Backtest shows limits actually binding on constructed worst-case inputs.

## Anti-patterns (do not do)

- Signal paths that submit entries without passing the risk gate.
- Position sizing that can round up or exceed `MaxContracts`.
- Treating a computed size of `0` as "use default quantity".
- A kill-switch that signal logic can clear and resume mid-session.
- Entries without a protective stop.
- Continuing to trade after a rejection, exception, or disconnect.

## Attribution

Original guidance for this repository, informed by public NinjaTrader 8
developer documentation on account/strategy risk settings and order handling.
No proprietary source or documentation text is copied. See `../../ATTRIBUTION.md`.
