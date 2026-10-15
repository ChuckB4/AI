# C# / .NET Pack

General-purpose skills and standards for writing, testing, and shipping C# and
.NET code. This is the foundation layer that domain packs (e.g. NinjaTrader 8)
build on and cross-reference.

## Purpose

Encode idiomatic, modern C#/.NET practices so an agent produces maintainable,
correct code regardless of the application domain — covering language usage,
project structure, async correctness, error handling, and the .NET tooling
loop.

## Scope

In scope:

- Modern C# language features and idioms (nullable reference types, pattern
  matching, records, `async`/`await` correctness, `IDisposable`/`using`).
- Project and solution layout, dependency management (NuGet), target
  frameworks.
- Error handling, logging, and configuration conventions.
- The .NET CLI loop: `dotnet build`, `dotnet test`, `dotnet format`.
- Analyzer and nullable settings; treating warnings as actionable.

Out of scope:

- Domain-specific frameworks (those live in their own packs, e.g.
  NinjaTrader 8, React for front-end).
- UI frameworks beyond general .NET guidance.

## Planned contents

| Item | Type | Status |
| --- | --- | --- |
| C# coding standards & idioms | skill | planned |
| Async/await correctness | skill | planned |
| Project & dependency structure | skill | planned |
| Error handling & logging | skill | planned |
| .NET build/test/format loop | skill | planned |

No item is marked done until its file exists and is reviewed.

## Quality requirements

- Guidance targets a stated, current LTS .NET version; note the version.
- Prefer compiler- and analyzer-enforceable rules over stylistic preference.
- Async guidance must address deadlock, `ConfigureAwait`, and cancellation.
- Examples must compile and follow the repo's verification-loop steering.

## Completion criteria

- [ ] All planned skills exist as detailed `SKILL.md` files with examples.
- [ ] Each skill cross-references steering (verification, git-workflow).
- [ ] The NinjaTrader 8 pack can reference this pack for non-NT8 C# concerns.
- [ ] This table matches the files on disk.
