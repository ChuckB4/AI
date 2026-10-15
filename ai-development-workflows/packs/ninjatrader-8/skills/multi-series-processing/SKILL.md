---
name: NT8 Multi-Series and Multi-Timeframe Processing
description: >
  Correctly add and consume multiple data series in NinjaTrader 8 — AddDataSeries
  in Configure, routing OnBarUpdate by BarsInProgress, per-series indexing,
  avoiding look-ahead and cross-series misalignment, and syncing bars.
pack: ninjatrader-8
applies_to: NinjaTrader 8 (NinjaScript / C#)
cross_references:
  - ../lifecycle-state-management/SKILL.md
  - ../ninjascript-csharp-standards/SKILL.md
  - ../../../../.kiro/steering/verification-loop.md
---

# NT8 Multi-Series / Multi-Timeframe Processing

NT8 lets a strategy or indicator consume several data series at once — a higher
timeframe for trend, a lower one for entries, or a second instrument for a
spread. The platform multiplexes all of them through a **single
`OnBarUpdate`**, so the hard part is knowing *which* series fired and reading
each series at the right index. Mistakes here cause silent look-ahead bias,
cross-series misalignment, and backtests that don't match live.

> Version note: targets NinjaTrader 8 (NinjaScript API as of NT 8.1).

## 1. Add series only in `Configure`

Per the lifecycle skill, `AddDataSeries` must be called in `State.Configure`,
in a fixed order. The **primary** series is index `0` (added implicitly); each
`AddDataSeries` call appends the next index in call order.

```csharp
protected override void OnStateChange()
{
    if (State == State.Configure)
    {
        // index 0 = primary (the chart's series)
        AddDataSeries(BarsPeriodType.Minute, 15); // index 1 = 15-min
        AddDataSeries(BarsPeriodType.Day, 1);      // index 2 = daily
        // AddDataSeries("ES 12-25", BarsPeriodType.Minute, 5); // another instrument
    }
}
```

Record the index-to-series mapping in a comment or `const int` fields; every
later line of code depends on it.

```csharp
private const int PRIMARY = 0;
private const int TF_15M  = 1;
private const int TF_DAY  = 2;
```

## 2. Route `OnBarUpdate` by `BarsInProgress`

`OnBarUpdate` is called for **every** series. `BarsInProgress` (BIP) tells you
which one. Always branch on it — code that ignores BIP runs duplicated or
against the wrong series.

```csharp
protected override void OnBarUpdate()
{
    switch (BarsInProgress)
    {
        case PRIMARY:
            OnPrimaryBar();
            break;
        case TF_15M:
            Update15mState();
            break;
        case TF_DAY:
            UpdateDailyState();
            break;
        default:
            return;
    }
}
```

Put trade/decision logic on the series that defines your decision cadence
(often the primary or the fastest series), and treat the others as context you
*read*, not drive.

## 3. Per-series indexing with `BarsArray` / `Closes`

To read a non-current series, index by series then by bar — use the
series-qualified accessors, not the bare `Close[]` (which refers to whatever
series is currently in progress).

```csharp
// Current close of each series:
double primClose = Closes[PRIMARY][0];
double close15   = Closes[TF_15M][0];
double closeDay  = Closes[TF_DAY][0];

// BarsArray[i].Count for availability checks
if (BarsArray[TF_DAY].Count < 1) return;
```

- `Closes[series][barsAgo]`, `Highs`, `Lows`, `Opens`, `Volumes`, `Times` give
  per-series access. `Close[barsAgo]` (singular) is only safe when you know
  which series is current.
- Each series has its own `CurrentBars[series]`. Guard with
  `CurrentBars[series] < required` before indexing.

## 4. Avoid look-ahead bias (the big one)

A higher-timeframe bar is only *final* when it closes. During a lower-timeframe
bar, the current higher-TF bar (`Closes[TF_DAY][0]`) is **still forming** and
would leak future information if used as if complete.

- To use a *completed* higher-TF value from lower-TF logic, read the **prior**
  higher-TF bar: `Closes[TF_DAY][1]`.
- Only treat `Closes[series][0]` as final inside the `BarsInProgress == series`
  branch at bar close (`Calculate.OnBarClose`).
- Never let a backtest "see" a value that would not have existed in real time.
  Look-ahead makes results look great and fail live.

## 5. Timestamp alignment

Different series advance at different times. Do not assume index `0` of two
series refers to the same wall-clock moment.

- Compare `Times[seriesA][0]` and `Times[seriesB][0]` when alignment matters.
- When you need "the higher-TF bar in effect at this lower-TF bar's time," find
  it by timestamp, not by a fixed `barsAgo` offset.

## 6. Warm-up and `BarsRequiredToTrade`

- Each series needs enough bars before its lookbacks are valid; guard every
  series independently.
- For strategies, ensure all required series have warmed up before acting;
  gate on the slowest series.

## 7. Indicators on secondary series

- You can run an indicator on a specific series by passing that series'
  `BarsArray` (e.g. `SMA(BarsArray[TF_15M], 20)`), so the indicator consumes the
  intended timeframe rather than the primary.
- Instantiate such indicators in `DataLoaded` (data must exist), per the
  lifecycle skill.

## 8. Verification

Before considering multi-series code done (verification-loop steering):

- [ ] All `AddDataSeries` calls are in `Configure`, in a documented order; index
      constants defined.
- [ ] Every `OnBarUpdate` path branches on `BarsInProgress`.
- [ ] Non-current series read via `Closes[series][barsAgo]` etc., with
      `CurrentBars[series]`/`BarsArray[series].Count` guards.
- [ ] No look-ahead: higher-TF values used from lower-TF logic reference the
      prior (completed) bar.
- [ ] Timestamp alignment handled where series cadence differs.
- [ ] Backtest vs a realtime replay produce consistent signals.

## Anti-patterns (do not do)

- Using bare `Close[0]` while another series is in progress.
- Ignoring `BarsInProgress` and running logic for all series indiscriminately.
- Reading a still-forming higher-TF bar as if it were final (look-ahead).
- Assuming `[0]` of two series share the same timestamp.
- Adding data series outside `Configure`.

## Attribution

Original guidance for this repository, informed by public NinjaTrader 8
developer documentation on multi-series scripting. No proprietary source or
documentation text is copied. See `../../ATTRIBUTION.md`.
