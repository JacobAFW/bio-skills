---
name: genericity-lint
description: >-
  Check a bioinformatics pipeline or script for hardcoding and genericity-contract
  violations against ARCHITECTURE.md. Use when reviewing a rule/script for
  reusability, when asked "is this generic", "did I hardcode anything", "lint the
  pipeline", "genericity check", "check for hardcoded paths/organism/samples", "will
  this run on other data", or at a phase boundary before moving on. Reads the
  project's declared genericity level and the architecture contract, runs the
  deterministic scan, then adds judgement the scanner can't — threshold literals
  that belong in config, organism/reference assumptions baked into logic, silent
  defaults, and one-rule-one-step violations. Reports each with file/line and the
  fix (lift to config, tag as HARDCODE, move to profiles). It does NOT edit or run
  anything.
---

# genericity-lint

The on-demand / checkpoint companion to the build-time genericity flag hook. The
hook catches the pattern-precise subset automatically after each edit; this skill
is the fuller, judgement-based review you run when you want it.

## Method

1. **Read the contract.** Load `ARCHITECTURE.md` (the portable rules) and the
   project's `CLAUDE.md` to get the **declared genericity level** (and any
   per-subtree scoping). The level modulates what's allowed.
2. **Deterministic first pass.** Run `scripts/genericity-scan.sh` over the core
   code (`workflow/rules/`, `scripts/`) for untagged absolute/site paths,
   sequence accessions, emails, and hardcoded reference files.
3. **Judgement pass** — the part a scanner can't do:
   - **Threshold literals** in rules/scripts (MAF, coverage, MQ, missingness,
     p-values, K) that should live in config with a rationale.
   - **Organism/reference assumptions** baked into logic (contig names, ploidy,
     species-specific gene lists) rather than a preset/config.
   - **Silent defaults** for consequential choices that should be explicit and
     logged at run start.
   - **One rule = one step** violations, inlined logic that belongs in `scripts/`,
     rules missing `log`/`message`.
4. **Report**, scoped to the declared level (a Specific project may legitimately
   pin more in config than a Generic one).

## Output

```
LEVEL: <Generic | Specific>  (from CLAUDE.md)
CORE SCAN (deterministic):
  workflow/rules/05_introgression.smk:30 [ref-literal] gff hardcoded -> lift to config
JUDGEMENT:
  scripts/R/filter.R:22  threshold MAF<0.01 as a literal -> config with rationale
  workflow/rules/01_qc.smk  species contig list inline -> config/species preset
  workflow/rules/03_structure.smk  rule has no log: / message:
OK: <what's already clean and generic>
```

For each item: the file/line, why it breaks the contract at this level, and the
concrete fix (lift to config / tag `# HARDCODE(reason; date):` / move to
`profiles/` / split the rule).

## Guardrails

- **Propose, never execute.** It reports and hands over fixes; it never edits code,
  moves files, or runs the pipeline.
- **Respect the declared level.** Don't flag a Specific project for pinning what its
  level explicitly permits — flag only what the contract forbids at that level.
- **A tagged hardcode is not a violation.** `# HARDCODE(reason; date):` with a
  `DESIGN.md` entry is the sanctioned escape hatch; note untagged ones only.
- **Don't invent thresholds.** When flagging a value as unusual, say "verify against
  your standard" rather than asserting a "correct" number (threshold-sanity as a
  knowledge base is a later addition).
