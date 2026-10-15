---
name: NinjaScript C# Authoring Standards
description: >
  Conventions for writing correct, maintainable NinjaScript (C#) in
  NinjaTrader 8 — naming, structure, data access, number/price handling,
  threading awareness, and the pitfalls that general C# knowledge misses.
pack: ninjatrader-8
applies_to: NinjaTrader 8 (NinjaScript / C#)
cross_references:
  - ../../../csharp-dotnet/README.md
  - ../../../../.kiro/steering/verification-loop.md
  - ../../../../.kiro/steering/safe-execution.md
---

# NinjaScript / C# Authoring Standards (NT8)

NinjaScript is C#, but it runs inside NinjaTrader 8's component model and event
loop. General C#/.NET standards (see the `csharp-dotnet` pack) still apply; this
skill covers only what is **NT8-specific** and what the platform's execution
model demands. Follow it alongside the verification-loop and safe-execution
steering rules.

> Version note: guidance targets NinjaTrader 8 (NinjaScript API as of NT 8.1).
> State the exact build when an example depends on API surface.

## 1. Where code goes

- Author indicators, strategies, add-ons, etc. as classes deriving from the
  correct NT8 base type (`Indicator`, `Strategy`, …). One component per file;
  file name matches the class name.
- Keep custom helper types in their own files under the appropriate NinjaScript
  folder; do not bury multiple public components in one file.
- Treat the generated designer/partial regions as off-limits for hand edits.

## 2. Naming and style

- Follow the `csharp-dotnet` naming rules (PascalCase types/methods/properties,
  camelCase locals). Do not invent an NT8-specific style.
- Prefix user-facing inputs with clear names and expose them as public
  properties decorated for the UI (see the inputs section). Avoid cryptic
  abbreviations in anything a trader sees.
- Keep methods short and single-purpose; the per-bar hot path (`OnBarUpdate`)
  must stay readable.

## 3. Lifecycle awareness (summary — see the lifecycle skill)

- Do all setup in the correct `State` (`SetDefaults`, `Configure`,
  `DataLoaded`), never in the constructor. The full rules live in the
  **NT8 lifecycle & State management** skill; this standard only requires that
  you never assume construction order or that data exists before `DataLoaded`.

## 4. Accessing bar data safely

- Use the NT8 price series (`Open`, `High`, `Low`, `Close`, `Volume`, `Time`)
  with bounds checks. Never index past the available bars.
- Guard the hot path:

  ```csharp
  protected override void OnBarUpdate()
  {
      // Need enough bars for the lookback you reference.
      if (CurrentBar < BarsRequiredToPlot)
          return;

      double priorClose = Close[1]; // safe: CurrentBar >= 1 guaranteed above
      // ...
  }
  ```

- `Close[0]` is the current bar; `Close[1]` is one bar ago. Off-by-one here is
  a classic NT8 defect — always reason about the index explicitly.

## 5. Prices, numbers, and rounding

- Round prices to the instrument tick size before using them for orders or
  comparisons: use the platform's instrument rounding rather than raw doubles.
- Never compare two doubles for exact equality; compare against a tick-based
  tolerance.
- Use the instrument's `TickSize` / `PointValue` for P&L and distance math;
  do not hard-code contract specs.

## 6. Threading and shared state

- NT8 raises events on specific threads; UI and chart objects have thread
  affinity. Do not touch UI/chart objects from background threads.
- Avoid static mutable state shared across instances — multiple chart tabs or
  optimization runs instantiate your component many times concurrently. Keep
  state in instance fields initialized per `State`.
- No blocking calls, `Thread.Sleep`, long loops, or synchronous network I/O in
  `OnBarUpdate` / event handlers — they stall the platform.

## 7. Inputs and outputs

- Expose configurable parameters as public properties with validation (clamp or
  reject invalid values in `State.Configure`), so a bad input cannot produce
  undefined behavior at runtime.
- Expose computed series as named plots/values; do not overload a single output
  with multiple meanings.

## 8. Logging and errors

- Use the platform's log/print facilities for diagnostics; never write secrets,
  account numbers, or credentials to logs (safe-execution steering).
- Fail safe: if a precondition is violated in a strategy context, prefer to
  stop acting (and flatten, per the risk-controls skill) over continuing in an
  undefined state. Do not swallow exceptions silently.

## 9. Verification

Before considering any NinjaScript change done (verification-loop steering):

- [ ] Compiles cleanly in NT8 (no errors, no new warnings).
- [ ] Hot-path bounds checks present for every historical index referenced.
- [ ] Prices rounded to tick size; no exact double comparisons.
- [ ] No UI/chart access off the correct thread; no blocking in event handlers.
- [ ] Inputs validated; invalid values cannot reach the hot path.

## Anti-patterns (do not do)

- Setup work in the constructor instead of the `State` machine.
- Unchecked `Close[n]` / `High[n]` access causing index-out-of-range.
- Exact `==` comparison of prices or indicator values.
- Static mutable fields shared across instances.
- Heavy or blocking work inside `OnBarUpdate`.

## Attribution

NT8/NinjaScript guidance is original to this repository, informed by the public
NinjaTrader 8 developer documentation. No proprietary NinjaTrader source or
documentation text is copied. See `../../ATTRIBUTION.md`.
