---
name: repo-scaffold
description: >-
  Set up a new, publishable Git repository for a research project — scripts only,
  no data, no secrets, no sensitive or identifying information. Use when starting a
  GitHub repo for a project, sharing a project's code publicly, or preparing an
  existing local folder for version control. Triggers on "set up a repo for this
  project", "make a GitHub repo", "scaffold a repo", "I want to share this code",
  "put this project on GitHub", "clean repo for X", "scripts-only repo". Scans the
  folder, classifies every file as include (code) or exclude (data/secret/sensitive)
  with reasons, generates a tuned .gitignore and a README, and pastes the exact git
  commands for the human to run. It NEVER creates the remote, commits, or pushes on
  its own.
---

# repo-scaffold

Turns a messy project folder into a clean, publishable repo that contains code and
nothing it shouldn't. Built for the recurring "I only want the scripts, none of the
data or sensitive stuff" setup.

## Method

1. **Scan** the project folder (recursively, but read `.gitignore`-style intent).
2. **Classify** every file and directory against
   [`reference/sensitive-checklist.md`](../../reference/sensitive-checklist.md)
   into INCLUDE (code/scripts/docs/safe-config) or EXCLUDE (data, secrets,
   human-subjects/PII, sensitive project info, metadata). Default-deny: when unsure,
   EXCLUDE and ask.
3. **Show the manifest** for review before anything is staged (see Output).
4. **Generate** a `.gitignore` (start from
   [`reference/gitignore.default`](../../reference/gitignore.default), then add
   anything project-specific the scan found) and a `README.md` from
   [`reference/README.template.md`](../../reference/README.template.md), filled in
   for this project — including the "what's included / deliberately excluded" section.
5. **Hand over the commands** — `git init`, add of the INCLUDE set only, first
   commit, and the remote/push lines left for the human to run.

## Output (in chat, for the human to review and run)

```
INCLUDE (will be committed)
  scripts/        code
  README.md       generated
  .gitignore      generated
  env.yml         config, no secrets found

EXCLUDE (kept out + gitignored)
  data/           [A] research data
  sample_sheet.csv[E] metadata linking samples
  .env            [B] secret — do NOT commit; rotate if it was ever shared
  notes_internal.md [D] unpublished/internal — review

FLAGS needing your call
  results/figs/fig1.csv  [A] looks like real data embedded in a figure export

--- .gitignore ---            <full file>
--- README.md ---             <filled draft>
--- commands ---              <git init / add INCLUDE only / commit ; remote+push left to you>
```

## Guardrails

- **Propose, never execute.** No `git init`-and-commit on your behalf, no remote
  creation, no `git push`. Output the commands; the human runs them. (Matches
  Jacob's standing confirmation gates.)
- **Default-deny.** Anything that might be data, a secret, or sensitive is EXCLUDED
  until the human confirms otherwise. Err toward leaving things out.
- **Stage the INCLUDE set explicitly**, never `git add -A` / `git add .`, so an
  un-ignored stray can't sneak in.
- **Secrets are a stop.** If a secret is found, say so plainly, advise rotating it,
  and do not produce any command that would commit it.
- **Clear notebook outputs** before including any `.ipynb`.
- **Don't invent the README.** Fill only what the project actually shows; mark
  unknowns as `<...>` for the human, never fabricate methods or data locations.
