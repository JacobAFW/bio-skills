---
name: project-setup
description: >-
  Stand up a new bioinformatics project skeleton the way Jacob likes it — canonical
  directory structure, the ARCHITECTURE.md design contract, a project CLAUDE.md with
  the genericity level declared, a default-deny .gitignore, and config/params/species
  stubs. Use when STARTING a new project, pipeline, or analysis from scratch, or when
  asked to "set up a new project", "scaffold a new pipeline", "start a bioinformatics
  project", "new project skeleton", "bootstrap a project", "set up an RA workspace",
  or "set this empty folder up the way I like". This is for a NEW skeleton; to publish
  an EXISTING folder as a clean git repo, use repo-scaffold instead. It creates files
  (non-destructively) but never runs git.
---

# project-setup

The one-shot that deploys the whole architecture system into a new project: the
structure, the contract, and the project's declared level. It's the deployment end
of the trio — `ARCHITECTURE.md` is the rules, `genericity-lint`/the guard enforce
them, and this stands a project up already obeying them.

## Method

1. **Confirm three things** (ask, don't assume): the target folder, the genericity
   level (`Generic` or `Specific` — see ARCHITECTURE.md; a mixed repo can be scoped
   per subtree), and a one-line scope/goal.
2. **Run the scaffold:** `scripts/new-project.sh <target> <level>`. It creates the
   canonical skeleton, copies in `ARCHITECTURE.md` and a default-deny `.gitignore`,
   and writes template `CLAUDE.md`, `DESIGN.md`, `Snakefile`, and `config/` stubs.
   It is non-destructive — it never overwrites an existing file.
3. **Fill the specifics** the scaffold left as placeholders: the one-line project
   description and scope in `CLAUDE.md`, and the overview in `DESIGN.md`, from what
   the user told you. Don't invent scope — use their words or leave the placeholder.
4. **Arm enforcement:** remind the user that the genericity and git-guard hooks are
   active only if the `bio-skills` plugin is installed. Offer the portable pre-push
   hook for defence-in-depth: `git config core.hooksPath` pointing at bio-skills'
   `git-hooks/` — propose the command, don't run it.
5. **Report** what was created and the next step (build in `workflow/` + `scripts/`;
   publish later with `repo-scaffold`).

## Output

A created skeleton plus a short summary: the level set, the files written, the
placeholders still needing the user's input, and the next action.

## Guardrails

- **Non-destructive.** Never overwrites an existing file; if the folder already has
  a project in it, say what's already there and only add what's missing.
- **No git actions.** It does not `git init`, commit, or push — publishing is
  `repo-scaffold`'s job. Any git config change (the pre-push wiring) is proposed,
  not run.
- **Confirm before creating.** Show what will be created and the chosen level before
  scaffolding; don't guess the level or scope.
- **Don't invent content.** Placeholders that need the user's specifics stay as
  placeholders until the user provides them.
