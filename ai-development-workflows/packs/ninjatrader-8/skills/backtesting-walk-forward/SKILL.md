---
name: NT8 Backtesting and Walk-Forward
description: >
  Produce trustworthy NinjaTrader 8 backtests — correct Strategy Analyzer setup,
  realistic fills/slippage/commission, avoiding look-ahead and overfitting,
  in-sample/out-of-sample splits, walk-forward analysis, and backtest/live parity
  checks.
pack: ninjatrader-8
applies_to: NinjaTrader 8 (NinjaScript / C#)
cross_references:
  - ../multi-series-processing/SKILL.md
  - ../strategy-execution-order-handling/SKILL.md
  - ../risk-controls/SKILL.md
  - ../../../../.kiro/steering/verification-loop.md
---

# NT8 Backtesting & Walk-Forward

A backtest exists to produce a *trustworthy* estimate of behavior, not an
impressive equity curve. Most "great" strategies are artifacts of look-ahead
bias, unrealistic fills, or overfitting. This skill is about making results
honest and repeatable. It is about **software and methodology correctness, not
trading advice**.

> Version note: targets NinjaTrader 8 (NinjaScript API as of NT 8.1), Strategy
> Analyzer workflow.

## 1. Make fills realistic

A backtest with frictionless fills overstates results. Configure the test to
reflect reality:

- **Commission** — apply the correct commission template for the instrument.
- **Slippage** — set a non-zero slippage appropriate to the instrument and
  order type; market/stop orders slip, especially on fast bars.
- **Fill resolution** — prefer higher-resolution fill handling (e.g. intrabar/
  tick-based fills via a lower-timeframe added series) over coarse bar-close
  assumptions for stop/target interaction.
- **Order type realism** — a limit that only "fills" because price touched it on
  a historical bar may not fill live; be conservative.

## 2. Eliminate look-ahead bias

Look-ahead is the number-one cause of fake results (see multi-series skill):

- Never reference a value that would not have existed at decision time —
  especially a still-forming higher-timeframe bar; use the prior completed bar.
- With `Calculate.OnBarClose`, decide at bar close on data up to and including
  that closed bar — not the next bar's open as if known.
- Confirm indicator math is identical historical vs realtime (indicator skill);
  divergence here silently biases the test.

## 3. Account for warm-up

- Set `BarsRequiredToTrade` so the strategy does not act before all series and
  indicators have warmed up (lifecycle/multi-series skills). Trades taken during
  warm-up pollute the sample.

## 4. In-sample vs out-of-sample (don't fool yourself)

- Reserve an **out-of-sample** period the strategy/parameters never saw during
  development. Evaluate the final choice only on out-of-sample data.
- Treat every parameter you tuned on in-sample data as a degree of freedom that
  inflates in-sample performance. More knobs → more overfitting risk.
- A strategy that only works on the tuned period is overfit; expect and check
  for performance decay out-of-sample.

## 5. Walk-forward analysis

Walk-forward is the stronger validation: optimize on a rolling in-sample window,
test on the immediately following out-of-sample window, roll forward, repeat.

- Use NT8's walk-forward optimization in the Strategy Analyzer: define
  in-sample/out-of-sample window sizes and step.
- Judge the strategy by **aggregated out-of-sample** results across all folds,
  not the best single in-sample fit.
- Instability of chosen parameters across folds is a red flag (fragile edge).

## 6. Robustness checks

- **Parameter sensitivity:** small parameter changes should not collapse
  results. A knife-edge optimum is overfit.
- **Across instruments/periods:** sanity-check on related instruments or
  adjacent periods.
- **Costs stress:** re-run with higher slippage/commission; a thin edge that
  dies under realistic costs is not tradeable.
- **Risk-limit interaction:** verify the risk-controls kill-switch and sizing
  actually bind in the backtest on worst-case inputs.

## 7. Metrics that matter

Look beyond net profit:

- Risk-adjusted return, max drawdown and its duration, trade count (enough for
  significance), win/loss and payoff ratio, and consistency across folds.
- A high return with a tiny trade count or an enormous drawdown is not a result
  you can rely on.

## 8. Backtest vs live parity

- Run the same strategy on a realtime replay / Market Replay and compare the
  order sequence and signals to the historical backtest. Material divergence
  means hidden historical-vs-realtime logic or look-ahead (execution/lifecycle
  skills). Resolve it before trusting either.

## 9. Verification

Before trusting a backtest (verification-loop steering):

- [ ] Commission + non-zero slippage + realistic fill resolution configured.
- [ ] No look-ahead: higher-TF values use completed bars; decisions use only
      past/known data.
- [ ] Warm-up handled via `BarsRequiredToTrade`; no trades during warm-up.
- [ ] Final evaluation on untouched out-of-sample data; walk-forward judged on
      aggregated OOS results.
- [ ] Parameter-sensitivity and cost-stress checks pass (no knife-edge optimum).
- [ ] Metrics include drawdown and trade count, not just net profit.
- [ ] Backtest vs realtime-replay order sequence matches on sample data.

## Anti-patterns (do not do)

- Zero slippage/commission "backtests".
- Optimizing and reporting results on the same (in-sample) data.
- Chasing the single best in-sample parameter set and ignoring OOS/walk-forward.
- Judging a strategy on net profit alone.
- Ignoring a backtest-vs-live divergence instead of root-causing it.

## Attribution

Original guidance for this repository, informed by public NinjaTrader 8
documentation on the Strategy Analyzer and walk-forward optimization, and
general quantitative-validation practice. No proprietary source or
documentation text is copied. See `../../ATTRIBUTION.md`.
