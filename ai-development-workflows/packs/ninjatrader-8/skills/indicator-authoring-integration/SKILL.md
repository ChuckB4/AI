---
name: NT8 Indicator Authoring and Integration
description: >
  Write correct NinjaTrader 8 indicators (plots, values, hosting indicators in
  strategies, reusing built-ins) with deterministic series math, proper warm-up,
  and backtest/realtime parity.
pack: ninjatrader-8
applies_to: NinjaTrader 8 (NinjaScript / C#)
cross_references:
  - ../lifecycle-state-management/SKILL.md
  - ../multi-series-processing/SKILL.md
  - ../ninjascript-csharp-standards/SKILL.md
  - ../../../../.kiro/steering/verification-loop.md
---

# NT8 Indicator Authoring & Integration

Indicators are the computation layer in NT8: they turn bar data into named
output series that charts display and strategies consume. The goals are
**determinism** (same inputs → same outputs, historical and realtime),
**correct warm-up**, and **clean reuse** from strategies and other indicators.

> Version note: targets NinjaTrader 8 (NinjaScript API as of NT 8.1).

## 1. Declaring plots and values

Declare outputs once in `SetDefaults` (per the lifecycle skill). Plots are
visual; `Values[i]` series carry the numbers consumers read.

```csharp
protected override void OnStateChange()
{
    if (State == State.SetDefaults)
    {
        Name      = "MyMovingAverage";
        IsOverlay = true;             // draws on price panel
        Calculate = Calculate.OnBarClose;

        AddPlot(Brushes.DodgerBlue, "MA");   // Values[0], Plots[0]
        Period = 14;                          // input default
    }
}
```

- Expose a named accessor so consumers read a meaningful property, not a raw
  index:

  ```csharp
  [Browsable(false)]
  [XmlIgnore]
  public Series<double> MA => Values[0];
  ```

## 2. Computing the series in `OnBarUpdate`

- Guard warm-up before referencing any lookback (standards skill):

  ```csharp
  protected override void OnBarUpdate()
  {
      if (CurrentBar < Period - 1)
          return; // not enough bars yet; leave the plot unset

      double sum = 0;
      for (int i = 0; i < Period; i++)
          sum += Close[i];

      Values[0][0] = sum / Period; // assign the current bar's output
  }
  ```

- Assign to `Values[i][0]` for the current bar only. Never write to historical
  indices you have already finalized.
- Keep the math pure and deterministic — no wall-clock, no RNG, no external
  I/O. Determinism is what makes backtests match live (verification-loop).

## 3. `IsOverlay`, panels, and scaling

- `IsOverlay = true` draws on the price panel; `false` creates a separate
  panel. Choose based on the output's units.
- Set reasonable plot styles and, where needed, fixed scale ranges so the
  display is readable; do not let an outlier value distort the chart.

## 4. Hosting indicators inside strategies / other indicators

A strategy can consume an indicator rather than reimplementing it.

```csharp
private MyMovingAverage ma;

protected override void OnStateChange()
{
    if (State == State.DataLoaded)        // data must exist (lifecycle skill)
        ma = MyMovingAverage(Close, 20);  // factory instantiation
}

protected override void OnBarUpdate()
{
    if (CurrentBar < BarsRequiredToTrade) return;
    double maNow  = ma[0];
    double maPrev = ma[1];
    // use maNow/maPrev for signals
}
```

- Instantiate hosted indicators in `DataLoaded`, not `SetDefaults`.
- To run an indicator on a non-primary series, pass that series' `BarsArray`
  (see multi-series skill): `SMA(BarsArray[TF_15M], 20)`.
- Reuse NT8 built-ins (`SMA`, `EMA`, `ATR`, …) instead of hand-rolling unless
  you need behavior they don't provide; built-ins are tested and warm up
  correctly.

## 5. Multi-output and dependent indicators

- An indicator with several outputs declares one `AddPlot` per output and
  writes each `Values[i][0]` every bar it is valid.
- If output B depends on output A, compute A first within the same
  `OnBarUpdate` pass; don't rely on a second indicator reading a half-written
  series.

## 6. Performance

- The body of `OnBarUpdate` runs on every bar (and every tick in intrabar
  modes). Keep per-bar cost bounded: prefer incremental updates (rolling sums)
  over recomputing a full window each bar for large periods.
- No allocations in the hot path where avoidable; no blocking calls
  (standards skill).

## 7. Verification

Before considering an indicator done (verification-loop steering):

- [ ] Plots/values declared in `SetDefaults`; named accessor exposed for
      consumers.
- [ ] Warm-up guarded; no index-out-of-range on the first `Period-1` bars.
- [ ] Output assigned only to `Values[i][0]` for the current bar.
- [ ] Math is deterministic (no clock/RNG/I/O); historical == realtime values.
- [ ] Hosted indicators instantiated in `DataLoaded`; correct series passed.
- [ ] Spot-check values against a known reference (e.g. built-in SMA) on sample
      data.

## Anti-patterns (do not do)

- Declaring plots or instantiating indicators in `SetDefaults`.
- Writing to finalized historical output indices.
- Non-deterministic indicator math that breaks backtest/live parity.
- Recomputing a full window every bar when an incremental update suffices.
- Reimplementing a built-in incorrectly instead of reusing it.

## Attribution

Original guidance for this repository, informed by public NinjaTrader 8
developer documentation on indicator development. No proprietary source or
documentation text is copied. See `../../ATTRIBUTION.md`.
