---
name: NT8 Optimization
description: >
  Run NinjaTrader 8 parameter optimization that generalizes — defining sane
  parameter ranges, choosing a robust fitness function, limiting degrees of
  freedom, using genetic vs exhaustive search appropriately, and validating
  results against overfitting with walk-forward and sensitivity analysis.
pack: ninjatrader-8
applies_to: NinjaTrader 8 (NinjaScript / C#)
cross_references:
  - ../backtesting-walk-forward/SKILL.md
  - ../risk-controls/SKILL.md
  - ../lifecycle-state-management/SKILL.md
  - ../../../../.kiro/steering/verification-loop.md
---

# NT8 Optimization

Optimization searches a parameter space for settings that score well on a
fitness function. The danger is that it is a **near-perfect overfitting
machine**: given enough knobs it will find a parameter set that fits the noise
in your in-sample data and fails live. This skill is about optimizing so results
*generalize*. It is about methodology correctness, **not trading advice**.

> Version note: targets NinjaTrader 8 (NinjaScript API as of NT 8.1), Strategy
> Analyzer optimization.

## 1. Prerequisite: a trustworthy backtest

Optimization is only as valid as the backtest it runs on. Everything in the
**backtesting-walk-forward** skill must already hold — realistic fills, no
look-ahead, warm-up handling. Optimizing on a biased backtest multiplies the
bias.

## 2. Minimize degrees of freedom

- Every optimized parameter is a degree of freedom that inflates in-sample
  performance. Fewer parameters generalize better.
- Only optimize parameters with a genuine hypothesis behind them. Fix the rest
  at sensible defaults.
- Rule of thumb: enough trades per parameter so results are statistically
  meaningful; a handful of trades across many parameters is noise-fitting.

## 3. Define sane ranges and steps

- Use ranges grounded in the instrument/strategy logic, not "0 to 1000 step 1".
- Coarse-to-fine: scan a coarse grid first, then refine near promising regions —
  cheaper and less prone to chasing isolated spikes.
- Expose optimizable inputs as public properties validated in `Configure`
  (lifecycle/risk skills) so no optimizer-chosen value can be invalid at
  runtime.

## 4. Choose a robust fitness function

- **Do not optimize raw net profit.** It rewards high-risk, high-drawdown,
  low-trade-count fits.
- Prefer risk-adjusted / drawdown-aware objectives and require a minimum trade
  count. Consider custom fitness that penalizes:
  - excessive max drawdown,
  - too few trades,
  - instability.
- A custom optimization fitness can be implemented so the ranking reflects what
  you actually care about, not just terminal equity.

## 5. Search method: exhaustive vs genetic

- **Exhaustive** (grid): complete but explodes combinatorially; feasible only
  for small spaces. Use for final refinement in a narrow region.
- **Genetic**: scales to large spaces but is stochastic — set a seed/record the
  configuration for reproducibility, and remember it may miss the global
  optimum. Re-run to check stability.
- Match method to space size; document which was used and its settings.

## 6. Validate against overfitting (the whole point)

Never accept the top in-sample row. Validate:

- **Walk-forward:** optimize per rolling in-sample window, score on the
  following out-of-sample window; judge aggregated OOS (backtesting skill). This
  is the primary defense.
- **Parameter sensitivity:** the chosen region should be a broad plateau, not a
  single spiking cell. Inspect neighbors of the "best" result.
- **Stability across folds:** if the optimal parameters jump around between
  folds, the edge is fragile — reject it.
- **Out-of-sample confirmation:** final settings evaluated once on untouched
  data.

## 7. Performance and reproducibility of the run

- Optimization instantiates the strategy thousands of times — honor the
  no-static-mutable-state and clean-`Terminated` rules (lifecycle/standards
  skills) or runs leak memory and corrupt each other.
- Keep per-iteration cost low (indicator skill: incremental math) so large
  sweeps finish.
- Record the exact ranges, steps, fitness, search method, data range, and
  commission/slippage used, so a result can be reproduced.

## 8. Verification

Before accepting an optimization result (verification-loop steering):

- [ ] Underlying backtest already passes the backtesting-skill checks.
- [ ] Only hypothesis-backed parameters optimized; degrees of freedom minimized.
- [ ] Ranges/steps are sane; coarse-to-fine used for large spaces.
- [ ] Fitness is risk/drawdown-aware with a minimum trade count — not raw net
      profit.
- [ ] Search method documented (seed recorded for genetic); re-run is stable.
- [ ] Chosen parameters sit on a plateau (sensitivity check), stable across
      walk-forward folds, and confirmed on untouched OOS data.
- [ ] No static mutable state / leaks across iterations; run reproducible from
      recorded config.

## Anti-patterns (do not do)

- Optimizing many parameters on a small sample (noise-fitting).
- Optimizing raw net profit without drawdown/trade-count constraints.
- Accepting the single best in-sample cell with no OOS/walk-forward check.
- Treating a knife-edge optimum as a real edge.
- Static mutable state that corrupts concurrent optimization iterations.

## Attribution

Original guidance for this repository, informed by public NinjaTrader 8
documentation on Strategy Analyzer optimization (including genetic optimization
and custom fitness) and general quantitative-validation practice. No proprietary
source or documentation text is copied. See `../../ATTRIBUTION.md`.
