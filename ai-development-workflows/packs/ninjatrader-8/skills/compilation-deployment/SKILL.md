---
name: NT8 Compilation and Deployment
description: >
  Compile, package, and deploy NinjaTrader 8 NinjaScript reliably — the F5
  compile model, resolving build errors/warnings, references and external DLLs,
  exporting/importing as NinjaScript archives, versioning, and clean install on
  a target machine.
pack: ninjatrader-8
applies_to: NinjaTrader 8 (NinjaScript / C#)
cross_references:
  - ../ninjascript-csharp-standards/SKILL.md
  - ../lifecycle-state-management/SKILL.md
  - ../release-verification/SKILL.md
  - ../../../../.kiro/steering/safe-execution.md
  - ../../../../.kiro/steering/verification-loop.md
---

# NT8 Compilation & Deployment

NinjaScript compiles inside NinjaTrader, not through a standalone `dotnet build`.
The whole NinjaScript assembly is rebuilt as one unit, so a single bad file
breaks every custom component. Deployment then moves a *clean, versioned*
artifact to the target machine. This skill makes both steps repeatable and
safe (safe-execution + verification-loop steering).

> Version note: targets NinjaTrader 8 (NinjaScript Editor / NinjaScript archive
> workflow, API as of NT 8.1).

## 1. The compile model

- NinjaScript compiles via the NinjaScript Editor (Compile / **F5**). NT8
  builds a single `NinjaTrader.Custom` assembly from **all** custom source.
- Because it's one assembly, **one file with an error fails the entire
  compile** — including unrelated indicators/strategies. A broken project means
  nothing custom loads.
- Treat the compile as the first gate: no component is "done" until the whole
  custom assembly compiles cleanly.

## 2. Resolve errors — and warnings

- Fix all compile errors; do not leave a half-migrated file in the source tree
  that blocks the build for everything else.
- Treat warnings as actionable (standards / csharp-dotnet packs). Common NT8
  causes: unused usings, obsolete API calls, nullable mismatches, shadowed
  members.
- Do not suppress a warning to force a green build; fix the cause or justify the
  suppression explicitly.

## 3. References and external DLLs

- Extra references are added via the Editor's reference manager. Keep the set
  minimal; every external dependency is a deployment liability.
- Bundle external DLLs with the export (see archives below) so the target
  machine has them; a missing reference compiles on your box and fails on
  theirs.
- Vet third-party DLLs for provenance/security (security pack); never add an
  unverified binary. No secrets or license keys hard-coded in source
  (safe-execution).

## 4. Package as a NinjaScript archive

- Export via **Tools → Export → NinjaScript** to produce a `.zip` NinjaScript
  archive containing the selected components (and optionally compiled
  assemblies / referenced DLLs).
- Export only the components you intend to ship, with their dependencies — not
  the entire custom folder — so the package is clean and reviewable.
- For protected distribution, NT8 can export a compiled assembly rather than
  source; decide source vs compiled deliberately and record which.

## 5. Versioning the artifact

- Stamp a version in the component (e.g. a `const string Version` and the
  `Name`/description) so a deployed build is identifiable at a glance.
- Name the archive with the version and date; keep prior archives for rollback
  (release-engineering pack).
- Tie the version to the git tag/commit of the source used to build it
  (release-verification skill) so a running build maps back to exact source.

## 6. Clean deployment to a target machine

- Install via **Tools → Import → NinjaScript** using the archive. Prefer a
  clean target: back up the existing custom folder first (reversible step,
  safe-execution).
- After import, **recompile on the target** and confirm a clean build there —
  the source-of-truth is the target machine's compile, not yours.
- Restart NinjaTrader if required so the new assembly loads; verify the
  component appears and instantiates.

## 7. Rollback

- Because you kept the previous archive and the git tag, rollback is: reimport
  the prior archive (or restore the backed-up custom folder) and recompile.
- Never hand-edit files on the target to "patch" a bad deploy; redeploy a known
  archive instead.

## 8. Verification

Before considering a build/deploy done (verification-loop steering):

- [ ] Entire custom assembly compiles with no errors and no new warnings.
- [ ] No broken/half-migrated files left in the source tree.
- [ ] External references minimal, vetted, and bundled; no missing-DLL risk on
      target.
- [ ] Archive contains exactly the intended components + dependencies.
- [ ] Artifact is versioned and tied to a git commit/tag.
- [ ] Imported on target, recompiled cleanly there, component loads and
      instantiates.
- [ ] Previous archive retained; rollback path confirmed.

## Anti-patterns (do not do)

- Leaving a file with compile errors in the project (breaks all custom code).
- Suppressing warnings to get a green build.
- Shipping without bundling required external DLLs.
- Deploying an unversioned archive with no link back to source.
- Hand-patching files on the target machine instead of redeploying an archive.
- Hard-coding secrets/keys in NinjaScript source.

## Attribution

Original guidance for this repository, informed by public NinjaTrader 8
documentation on compiling and importing/exporting NinjaScript. No proprietary
source or documentation text is copied. See `../../ATTRIBUTION.md`.
