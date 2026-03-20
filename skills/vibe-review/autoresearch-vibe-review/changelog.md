# Autoresearch Changelog: vibe-review

## Experiment 0 — baseline
**Score:** 20/25 (80.0%)
**Change:** None
**Result:** EVAL 5 (Real Tool Commands) fails all 5 runs. Security scan uses `await scanForSQLInjection(files)` and similar TypeScript pseudo-functions that don't exist. Performance profiling uses `await analyzeComplexity(files)` — also fictional.

---

## Experiment 1 — keep
**Score:** 25/25 (100.0%)
**Change:** Replaced all TypeScript pseudocode with real `rg` and `ast-grep` commands for each OWASP category: SQL injection (`rg "query|sql"`, `ast-grep` dynamic query pattern), XSS (`rg "dangerouslySetInnerHTML"`), sensitive data (`rg "password|secret|token"`), auth gaps, and `npm audit` for dependencies. Performance section also converted to real tool commands.
**Reasoning:** Claude Code runs shell commands, not TypeScript functions. Security scanning must use tools actually available in the environment.
**Result:** EVAL 5 now passes all 5 runs. Review now uses real, executable tool commands.

---

## Stop condition: 95%+ achieved. Complete.
