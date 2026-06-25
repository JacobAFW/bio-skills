---
name: commit-guard
description: >-
  Check a repository for data, secrets, or sensitive/identifying information before
  it is committed or pushed. Use before `git commit`/`git push`, when asked "is this
  safe to push", "did I leak anything", "check before I push", "pre-commit check",
  "scan for secrets", or after staging changes. Scans staged and tracked files (and
  flags anything already committed) against the sensitive-content checklist, reports
  each risk with its file and line and category, and gives the exact remediation
  command. It NEVER pushes, and never rewrites history on its own.
---

# commit-guard

The pre-flight check so nothing you shouldn't publish leaves your machine. Pairs with
`repo-scaffold` (which sets a repo up clean); this keeps it clean over time.

## Method

1. **Gather** what's about to go out: `git diff --cached --name-only` (staged),
   `git ls-files` (already tracked), and untracked files not covered by `.gitignore`.
2. **Scan** each against
   [`reference/sensitive-checklist.md`](../../reference/sensitive-checklist.md) —
   filenames *and* file contents (the secret patterns matter most here).
3. **Report** every hit: path, line (for content matches), category, and the
   one-line fix.
4. **Hand over remediation commands** — never run them.

## Output

```
CLEAN: <n> staged / <n> tracked files scanned, no issues.
```

or

```
BLOCK — do not push yet:
  config/keys.env:3   [B] AWS key (AKIA…)   -> rotate the key NOW, then: git rm --cached config/keys.env && echo 'config/keys.env' >> .gitignore
  data/cohort.csv     [A] research data      -> git rm --cached data/cohort.csv ; add data/ to .gitignore
  analysis.ipynb      [A] notebook outputs    -> clear outputs, then re-stage

ALREADY COMMITTED (history):
  secrets.env (commit a1b2c3) [B] -> rotate the secret; history rewrite needed (see below) — confirm before running
```

## Remediation guidance

- **Not yet committed:** `git rm --cached <file>`, add to `.gitignore`, re-commit.
- **Already committed but local-only / not pushed:** can be amended or the history
  rewritten before pushing.
- **Already pushed:** the secret is compromised — **rotate it first**, then rewrite
  history (`git filter-repo` or BFG) and force-push. State this is destructive and
  needs explicit confirmation; provide the command but do not run it.

## Guardrails

- **Propose, never execute.** No `git push`, no `git filter-repo`, no force-push, no
  `git rm` run on the human's behalf. Output commands only. (Matches Jacob's standing
  confirmation gates — history rewrites and pushes are exactly the irreversible
  actions to confirm first.)
- **Default-deny.** Treat ambiguous files as risky until cleared.
- **Secrets: rotate before scrub.** Always say to rotate the credential first;
  removing the file does not un-leak an exposed secret.
- **Don't claim "clean" loosely.** Only report CLEAN after actually scanning the
  staged + tracked set; if something couldn't be scanned (binary, too large), say so.
