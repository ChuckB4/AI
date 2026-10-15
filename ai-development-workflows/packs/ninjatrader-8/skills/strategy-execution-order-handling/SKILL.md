---
name: NT8 Strategy Execution and Order Handling
description: >
  Submit and manage orders correctly in NinjaTrader 8 strategies — managed vs
  unmanaged approach, order lifecycle via OnOrderUpdate/OnExecutionUpdate,
  position tracking, OCO brackets, avoiding duplicate/overfill orders, and
  intrabar-safe submission.
pack: ninjatrader-8
applies_to: NinjaTrader 8 (NinjaScript / C#)
cross_references:
  - ../lifecycle-state-management/SKILL.md
  - ../ninjascript-csharp-standards/SKILL.md
  - ../risk-controls/SKILL.md
  - ../../../../.kiro/steering/safe-execution.md
  - ../../../../.kiro/steering/verification-loop.md
---

# NT8 Strategy Execution & Order Handling

This is the skill where mistakes cost money: duplicated orders, phantom
positions, fills during historical replay, or a strategy that keeps trading
after an error. The rules below bias toward **determinism and fail-safe
behavior** and must be read together with the **risk-controls** skill and the
**safe-execution** steering rule.

> Version note: targets NinjaTrader 8 (NinjaScript API as of NT 8.1).
> Any guidance about live orders is about *correctness*, not trading advice.

## 1. Choose managed vs unmanaged deliberately

- **Managed approach** (default): use `EnterLong`/`EnterShort`,
  `ExitLong`/`ExitShort`, `SetStopLoss`/`SetProfitTarget`. NT8 tracks position
  and enforces one-order-per-direction semantics. Prefer this unless you have a
  concrete reason not to.
- **Unmanaged approach** (`SubmitOrderUnmanaged`): full control, full
  responsibility — you track every order and position yourself. Only use when
  managed cannot express the strategy; document why.
- Never mix the two in one strategy.

## 2. Gate submission to realtime (and bar close)

- Do not submit live orders during historical replay unless you explicitly and
  safely intend historical fills. Default: act only when
  `State == State.Realtime` (lifecycle skill), or rely on the managed engine's
  historical simulation for backtests.
- With `Calculate.OnBarClose`, submit at bar close (deterministic). In intrabar
  modes (`OnEachTick`/`OnPriceChange`), submission logic must be **idempotent
  per bar** — guard with a "already submitted this bar" flag so a repeated tick
  does not fire a second entry.

```csharp
protected override void OnBarUpdate()
{
    if (BarsInProgress != 0) return;
    if (CurrentBar < BarsRequiredToTrade) return;

    bool isLive = State == State.Realtime;

    if (Position.MarketPosition == MarketPosition.Flat && EntrySignal())
    {
        // one entry per signal; managed engine prevents stacking same-direction
        EnterLong(Quantity, "LE");
    }
}
```

## 3. Use signal names consistently

- Name every entry/exit (`"LE"`, `"SE"`, `"LX"`, …). Stops/targets attach to the
  named entry; mismatched names leave orphaned protective orders.
- Exit using the same signal name that opened the position so the engine pairs
  them correctly.

## 4. Track order state via events, not assumptions

Do not assume an order filled just because you submitted it. React to the
engine's callbacks:

- `OnOrderUpdate` — order state transitions (Submitted → Accepted → Working →
  Filled / Cancelled / Rejected). Handle `Rejected` and `Cancelled` explicitly;
  a rejected entry must not leave dangling stops/targets.
- `OnExecutionUpdate` — actual fills (price, quantity). Use this for fill-based
  logic and realized-position math, not `OnOrderUpdate`.
- Keep references to live `Order` objects you need to modify/cancel; set them
  null when terminal.

```csharp
protected override void OnOrderUpdate(Order order, double limitPrice, double stopPrice,
    int quantity, int filled, double averageFillPrice,
    OrderState orderState, DateTime time, ErrorCode error, string nativeError)
{
    if (orderState == OrderState.Rejected)
    {
        // fail safe: cancel any paired protective orders, stop acting, log
        // (see risk-controls for kill-switch behavior)
    }
}
```

## 5. Position and quantity truth

- Read position from `Position.MarketPosition` and `Position.Quantity`
  (managed) rather than a hand-maintained counter that can drift.
- For multi-instrument strategies, use `Positions[series]`.
- Reconcile after every fill via `OnExecutionUpdate`; never let an internal
  "I think I'm long" diverge from the engine.

## 6. Brackets and OCO

- Attach protective orders with `SetStopLoss` / `SetProfitTarget` (managed), or
  submit a true OCO group (unmanaged) so that filling one leg cancels the other.
- Ensure stop and target are **both** placed before (or atomically with) the
  entry's exposure window; never leave a filled entry unprotected.
- On a manual/early exit, cancel outstanding protective orders for that signal
  so they can't fire against a flat/opposite position.

## 7. Avoid duplicate and overfill orders

- One logical entry per signal per bar (idempotency flag in intrabar modes).
- Do not resubmit on every tick while an order is Working.
- When modifying an order, use `ChangeOrder` on the existing reference rather
  than cancel+new, which risks a race where both exist briefly.

## 8. Fail-safe on error

- On rejection, exception, data loss, or a tripped risk limit: stop opening new
  positions, cancel working orders, and (per risk-controls) flatten if required.
  Never continue submitting in an undefined state (safe-execution steering).
- Make `Terminated` cancel outstanding orders you own if appropriate for the
  strategy's deployment model.

## 9. Verification

Before considering strategy execution code done (verification-loop steering):

- [ ] Managed vs unmanaged chosen and not mixed; rationale documented if
      unmanaged.
- [ ] Live submission gated to realtime / handled via managed backtest; intrabar
      submission is idempotent per bar.
- [ ] Order/exit signal names consistent; protective orders paired correctly.
- [ ] `OnOrderUpdate` handles Rejected/Cancelled; `OnExecutionUpdate` drives
      fill logic.
- [ ] Position read from `Position`/`Positions`, reconciled on fills.
- [ ] No path leaves a filled entry unprotected or duplicates an entry.
- [ ] Error paths fail safe (cancel/flatten), consistent with risk-controls.
- [ ] Backtest and realtime replay produce the same order sequence on sample
      data.

## Anti-patterns (do not do)

- Submitting orders every tick without an idempotency guard.
- Assuming submit == fill; ignoring Rejected/Cancelled states.
- Maintaining a private position counter instead of reading `Position`.
- Leaving a filled entry without a stop/target, or orphaning protective orders
  after an exit.
- Cancel+new to "modify" an order (race) instead of `ChangeOrder`.
- Continuing to trade after an error or a tripped risk limit.

## Attribution

Original guidance for this repository, informed by public NinjaTrader 8
developer documentation on managed/unmanaged order handling. No proprietary
source or documentation text is copied. See `../../ATTRIBUTION.md`.
