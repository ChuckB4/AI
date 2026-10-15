---
inclusion: always
---

# Verification Loop (Edit → Lint → Test)

Reverse-engineered from Aider's post-edit lint/test loop and the broader
principle: **verify the changed system — do not trust generated code.** Code
that compiles or runs without error is not proof that it does the right thing.

## The loop

After every meaningful edit, run this loop before considering the change done:

1. **Edit** — make the smallest change that advances the goal.
2. **Lint / format** — run the project's linter and formatter on the changed
   files. Fix what they report. Do not disable rules to make them pass.
3. **Build / type-check** — compile or type-check if the stack supports it.
4. **Test** — run the tests that cover the changed code. If none exist and the
   change is behavioral, add or ask about adding a test.
5. **Read the output** — actually inspect results. A clean exit code is not
   success; confirm the output matches the intended behavior.
6. **Repeat** — if a check fails, fix and rerun from the relevant step.

## Rules

- **No "silent" success claims.** Never report a task complete based solely on
  an exit code. State what was verified and how.
- **Match the check to the stack.** Use the project's existing tooling (its
  test runner, linter, build command). Discover these from config files, not
  assumptions.
- **Single-run, not watch mode.** In automated/sandbox contexts, run checks
  once (e.g. `--run`) rather than starting watchers or dev servers.
- **Scope the tests.** Prefer running the tests closest to the change first for
  fast feedback, then the broader suite before finishing.
- **Fix the cause, not the check.** Do not weaken assertions, skip tests, or
  loosen lint rules to get green. If a check is genuinely wrong, say so and
  explain.
- **Report honestly.** If a criterion could not be verified (missing tests, no
  runnable environment), state that explicitly instead of implying success.

## Finishing checklist

Before marking work done:

- [ ] Re-read the original goal and its concrete success criteria.
- [ ] Lint/format clean on changed files.
- [ ] Build/type-check passes (where applicable).
- [ ] Relevant tests pass, and their output was inspected.
- [ ] Each success criterion is confirmed, or any gap is stated plainly.

## Attribution

The post-edit lint/test loop is adapted from the open-source
[Aider](https://aider.chat/) project (Apache-2.0). Pattern only; no source code
copied. See `ATTRIBUTION.md`.
