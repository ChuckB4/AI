---
name: NT8 Lifecycle and State Management
description: >
  How to use the NinjaTrader 8 component State machine correctly — what belongs
  in SetDefaults, Configure, DataLoaded, Historical, Realtime, Transition, and
  Terminated, plus historical-vs-realtime processing and safe teardown.
pack: ninjatrader-8
applies_to: NinjaTrader 8 (NinjaScript / C#)
cross_references:
  - ../ninjascript-csharp-standards/SKILL.md
  - ../../../../.kiro/steering/verification-loop.md
  - ../../../../.kiro/steering/safe-execution.md
---

# NT8 Lifecycle & State Management

Every NinjaScript component (indicator, strategy, add-on) is driven by a
`State` machine. NT8 calls `OnStateChange()` repeatedly as the component moves
through states. **Doing the right work in the wrong state is the single most
common source of NT8 bugs** — resources that don't exist yet, settings that get
overwritten, handlers that leak, or realtime logic that fires during a
historical backfill.

> Version note: targets NinjaTrader 8 (NinjaScript API as of NT 8.1). State the
> exact build if an example depends on specific API surface.

## 1. The state sequence

A component typically transitions through these states, in order:

| State | When it runs | What belongs here |
| --- | --- | --- |
| `SetDefaults` | Once, at construction/template load | Defaults for inputs, `Name`, `Calculate`, plots, flags. **No external resources.** |
| `Configure` | After defaults, before data | Add data series (`AddDataSeries`), add indicators, validate inputs, allocate buffers. |
| `DataLoaded` | Once bar data is available | Instantiate indicators that need data, read instrument/tick info, size data-dependent structures. |
| `Historical` | Entering historical processing | Mark that subsequent `OnBarUpdate` calls are historical. |
| `Transition` | Switching historical → realtime | One-time handoff work; reconcile any historical-only state. |
| `Realtime` | Live data begins | Enable realtime-only behavior (e.g. live alerts/orders if intended). |
| `Terminated` | Teardown | Dispose resources, detach event handlers, close connections. |

Not every component sees every state, but the ordering never reverses. Never
assume a later state's resources exist in an earlier state.

## 2. Canonical `OnStateChange` skeleton

```csharp
protected override void OnStateChange()
{
    if (State == State.SetDefaults)
    {
        Name                 = "MyComponent";
        Calculate            = Calculate.OnBarClose; // choose deliberately
        IsOverlay            = false;
        // input defaults only — no file/network/indicator work here
        Lookback             = 14;
    }
    else if (State == State.Configure)
    {
        // validate inputs; reject/clamp invalid values before any data flows
        if (Lookback < 1) Lookback = 1;
        // AddDataSeries(...) for multi-series work goes here
    }
    else if (State == State.DataLoaded)
    {
        // indicators that need data, instrument/tick reads, buffer sizing
    }
    else if (State == State.Terminated)
    {
        // dispose + detach: see teardown section
    }
}
```

## 3. What must NOT go where

- **No external resources in `SetDefaults`.** It runs during template scanning;
  files, network, indicators, or data access here will fail or hang the UI.
- **No data access before `DataLoaded`.** Bars, instrument details, and tick
  size are not reliably available in `SetDefaults`/`Configure`.
- **No `AddDataSeries` outside `Configure`.** Series must be added in
  `Configure`; adding later throws or is ignored.
- **No order submission from historical state** unless you explicitly intend
  (and have guarded) historical fills. Default to realtime-only for live
  actions.
- **No setup in the constructor.** Use the `State` machine; constructor order
  is not a contract you control.

## 4. Historical vs realtime processing

NT8 replays historical bars to "warm up" before live data. The same
`OnBarUpdate` runs for both phases.

- Distinguish them explicitly. Use `State == State.Historical` transitions and
  the realtime flag (e.g. `State >= State.Realtime` once reached) to gate
  behavior that must only happen live — alerts, external notifications, and
  (depending on strategy design) order submission.
- Do not send messages, play sounds, or hit external systems during historical
  replay (safe-execution: no unintended external side effects).
- Indicator math should generally be identical historical and realtime so that
  backtests match live; only *side effects* are gated.

```csharp
protected override void OnBarUpdate()
{
    if (CurrentBar < BarsRequiredToPlot) return;

    double signal = ComputeSignal(); // same in both phases

    bool isLive = State == State.Realtime; // only act live
    if (isLive && signal > Threshold)
        Alert("sig", Priority.High, "Signal fired", "", 0, Brushes.Transparent, Brushes.Transparent);
}
```

## 5. `Calculate` mode affects everything

- `Calculate.OnBarClose` — `OnBarUpdate` fires once per closed bar
  (deterministic; preferred for signal/order logic).
- `Calculate.OnPriceChange` / `OnEachTick` — fires intrabar; `Close[0]` is the
  forming bar and can change. Logic must be idempotent across repeated calls
  within the same bar, and orders must not be duplicated.
- Choose `Calculate` in `SetDefaults` and document why. Intrabar modes require
  extra care in the strategy-execution and risk skills.

## 6. Teardown (`Terminated`) — prevent leaks

- Dispose any `IDisposable` you created (timers, streams, custom indicators you
  own).
- **Detach every event handler** you attached (`-=`), or the instance leaks and
  may keep firing. Leaks compound badly during optimization (thousands of
  instances).
- Make `Terminated` idempotent and null-safe: it can run even if setup failed
  partway, so guard against half-initialized state.

## 7. Multi-instance / optimization safety

- Optimization and multiple chart tabs create many instances concurrently.
  Keep all mutable state in instance fields initialized per state — never in
  static fields (see the standards skill).
- Everything allocated in `Configure`/`DataLoaded` must be released in
  `Terminated` so repeated runs don't accumulate memory.

## 8. Verification

Before considering a lifecycle change done (verification-loop steering):

- [ ] Each setup action is in the correct state (defaults vs configure vs
      data-loaded).
- [ ] No external resource access in `SetDefaults`; no data access before
      `DataLoaded`; `AddDataSeries` only in `Configure`.
- [ ] Historical-only side effects are gated to realtime.
- [ ] `Calculate` mode is set deliberately and logic matches it.
- [ ] `Terminated` disposes resources, detaches all handlers, and is null-safe.
- [ ] Compiles with no new warnings; a quick historical+realtime run behaves as
      expected.

## Anti-patterns (do not do)

- Allocating indicators or reading tick size in `SetDefaults`.
- Calling `AddDataSeries` in `DataLoaded` or `OnBarUpdate`.
- Firing alerts/orders/notifications during historical replay unintentionally.
- Forgetting to detach handlers in `Terminated` (instance + memory leak).
- Relying on constructor or static initialization order.

## Attribution

Original guidance for this repository, informed by public NinjaTrader 8
developer documentation on the component lifecycle. No proprietary source or
documentation text is copied. See `../../ATTRIBUTION.md`.
