<!-- gitnexus:start -->
# GitNexus — Code Intelligence

This project is indexed by GitNexus as **Fladder-Custom** (16662 symbols, 32901 relationships, 300 execution flows). Use the GitNexus MCP tools to understand code, assess impact, and navigate safely.

> Index stale? Run `node .gitnexus/run.cjs analyze` from the project root — it auto-selects an available runner. No `.gitnexus/run.cjs` yet? `npx gitnexus analyze` (npm 11 crash → `npm i -g gitnexus`; #1939).

## Always Do

- **MUST run impact analysis before editing any symbol.** Before modifying a function, class, or method, run `impact({target: "symbolName", direction: "upstream"})` and report the blast radius (direct callers, affected processes, risk level) to the user.
- **MUST run `detect_changes()` before committing** to verify your changes only affect expected symbols and execution flows. For regression review, compare against the default branch: `detect_changes({scope: "compare", base_ref: "master"})`.
- **MUST warn the user** if impact analysis returns HIGH or CRITICAL risk before proceeding with edits.
- When exploring unfamiliar code, use `query({query: "concept"})` to find execution flows instead of grepping. It returns process-grouped results ranked by relevance.
- When you need full context on a specific symbol — callers, callees, which execution flows it participates in — use `context({name: "symbolName"})`.

## Never Do

- NEVER edit a function, class, or method without first running `impact` on it.
- NEVER ignore HIGH or CRITICAL risk warnings from impact analysis.
- NEVER rename symbols with find-and-replace — use `rename` which understands the call graph.
- NEVER commit changes without running `detect_changes()` to check affected scope.

## Resources

| Resource | Use for |
|----------|---------|
| `gitnexus://repo/Fladder-Custom/context` | Codebase overview, check index freshness |
| `gitnexus://repo/Fladder-Custom/clusters` | All functional areas |
| `gitnexus://repo/Fladder-Custom/processes` | All execution flows |
| `gitnexus://repo/Fladder-Custom/process/{name}` | Step-by-step execution trace |

<!-- gitnexus:end -->

## Agent skills

### Issue tracker

Issues tracked on GitHub (`wenqieqiu/Fladder-Custom`). See `docs/agents/issue-tracker.md`.

### Triage labels

Five canonical roles use default label names. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context layout (`CONTEXT.md` + `docs/adr/` at repo root). See `docs/agents/domain.md`.

## Development environment

- Flutter SDK: `D:\flutter-sdk\flutter`

## Version auto-bump

A `pre-commit` hook at `.githooks/pre-commit` automatically increments the
build number in `pubspec.yaml` on every `git commit`.

- Format: `version: x.y.z+N` → each commit bumps `N` by 1
- Version name `x.y.z` is left unchanged (update manually for new releases)
- If the version line has no `+N` suffix (e.g. `version: 1.0.0`), the hook
  initializes the build number at 1, producing `version: 1.0.0+1`

### Install

```bash
bash .githooks/install.sh
# or manually:
git config core.hooksPath .githooks
```

### Verify

```bash
git config core.hooksPath
# expected output: .githooks
```

### Uninstall

```bash
git config --unset core.hooksPath
```

### Bypass

```bash
git commit --no-verify
```
