# bio-skills

*Agent skills for the bioinformatics research-engineering chores that have no tool and need judgement.*

A small, curated collection of skills for Claude Code (and any skill-capable agent).
They share one philosophy: do the part a human is left holding — the judgement —
and never the part a mature tool already does well.

> **Wrap, don't rebuild.** If a mature tool already computes it, the skill calls
> that tool or reads its output. The value is the judgement layer on top —
> cross-checks, fitness-for-purpose, a committed decision, and the drafted next action.

> **Propose, never execute.** Every skill hands you the command and stops. None of
> them resubmit jobs, commit, push, delete, or rewrite history on their own.

## Pipeline skills

| Skill | The chore it kills |
| --- | --- |
| [`pipeline-triage`](skills/pipeline-triage/SKILL.md) | A run died. Reads the logs, stderr and exit code, commits to the root cause, and drafts the fix — OOM, contig mismatch, truncated input, missing index, version clash. Scheduler-aware (SLURM/PBS/SGE/LSF). |
| [`methods-writer`](skills/methods-writer/SKILL.md) | The analysis is done and now you have to write it up. Turns configs, command history and tool versions into a Methods paragraph, a version table, and a reproducibility checklist. |

A skill that recomputes what FastQC already gives you is noise. A skill that reads
the report and tells you *which samples to drop and why* is the job.

## Repo-hygiene skills

Keep research repos publishable: code only, no data, no secrets, no identifying
information. Both read one shared, genomics-aware
[`reference/sensitive-checklist.md`](reference/sensitive-checklist.md) and follow a
**default-deny** rule — anything that might be data or sensitive is excluded until
you confirm otherwise.

| Skill | When |
| --- | --- |
| [`repo-scaffold`](skills/repo-scaffold/SKILL.md) | Starting a repo. Classifies every file as code-to-include vs data/secret/sensitive-to-exclude (with reasons), generates a tuned `.gitignore` and README, pastes the git commands. |
| [`commit-guard`](skills/commit-guard/SKILL.md) | Before every push. Scans staged and tracked files for data, secrets, and PII, reports each with file/line and a remediation command. |

### Automatic enforcement (for autonomous agents)

The skills above are invoked at the agent's discretion — fine when a human is
driving, not enough in an unattended loop. For that, a **hook** makes the check
unskippable:

- **`hooks/git-guard.sh`** (a Claude Code `PreToolUse` hook, auto-loaded from
  `hooks/hooks.json`) fires before any Bash command the agent runs. On a `git
  commit`/`git push` it runs `scripts/scan.sh` first and **blocks with exit 2** if
  anything trips, handing the findings back to the agent instead of letting the push
  through. Still human-in-the-loop in spirit: it halts and surfaces, it doesn't
  auto-resolve.
- **`git-hooks/pre-push`** is a portable plain-git version that guards *any* push,
  not just the agent's. Enable with `git config core.hooksPath git-hooks`.

The hook does only the deterministic, pattern-detectable subset — data-file
extensions, known secret tokens, sample-sheet names, and it *wraps* `gitleaks` if
installed. The subtle PII/sensitivity judgement stays in `commit-guard`. So:
**hook = automatic guarantee for the catchable stuff; skill = judgement when you're
driving.** Needs `jq`; `gitleaks` optional.

### `pipeline-triage`, concretely

A GATK array task dies overnight. You get this:

```
slurmstepd: error: Detected 1 oom_kill event in StepId=7781234.47.
srun: error: node-c14: task 0: Out Of Memory
Task 47 exited with code 137
```

Instead of you opening the log, the skill returns:

```
ROOT CAUSE: array task 47 OOM-killed (exit 137); 8G below HaplotypeCaller's peak here
EVIDENCE:   oom_kill event in StepId=7781234.47 + exit 137
FIX:        resubmit ONLY task 47 with --mem=16G --java-options "-Xmx14g"
RESUBMIT:   sbatch --array=47 --mem=16G call_variants.sh   # you run this, not me
IF WRONG:   if it re-OOMs at 16G, profile peak RSS before raising further
```

One cause, the evidence for it, a ready command — and it stops there.

## Safety

Both skills **propose, they don't execute.** No resubmitting jobs, deleting files,
or running fixes on their own. They hand you the command; you run it. The CI loop
below opens a pull request or an issue — it never pushes to `main`.

## Evaluation

The point of publishing isn't the code, it's whether it *works* — so
`pipeline-triage` ships with a benchmark harness and a labelled-case format
([`benchmarks/`](benchmarks/README.md)). It scores the same agent with and without
the skill on real failed-run logs with known root causes, on root-cause accuracy,
fix actionability, restraint, and safety.

**Status: harness and case format are in place; results land once the corpus is
filled with real cases.** No numbers are claimed until the eval is run — that
honesty is the point of having an eval at all.

## Continuous integration loop

[`.github/workflows/ci-autotriage.yml`](.github/workflows/ci-autotriage.yml) wires
the skill into CI: when tests fail, `pipeline-triage` reads the failing run,
diagnoses it, and **opens a PR with the fix or an issue with the diagnosis** —
never a push to `main`. Verified against `anthropics/claude-code-action@v1`.

## Install (Claude Code)

```
/plugin marketplace add <your-github-username>/bio-skills
/plugin install bio-skills@bio-skills
```

Or copy a skill folder into `~/.claude/skills/`.

## Layout

```
skills/
  pipeline-triage/SKILL.md     # the debugger skill
  methods-writer/SKILL.md      # the write-up skill
  repo-scaffold/SKILL.md       # scripts-only new repo
  commit-guard/SKILL.md        # pre-push data/secret/PII check
reference/
  sensitive-checklist.md       # shared, genomics-aware rule set
  gitignore.default            # strong default for R / Python / bioinformatics
  README.template.md           # 'what's in / deliberately out' template
scripts/
  scan.sh                      # deterministic data/secret/metadata scanner
hooks/
  hooks.json                   # PreToolUse hook wiring (auto-loaded)
  git-guard.sh                 # blocks agent git commit/push on findings
git-hooks/
  pre-push                     # portable plain-git enforcement
benchmarks/
  README.md                    # eval design
  score_cases.py               # scoring harness (runs; agent hooks are TODO)
  cases/                       # labelled failed-run corpus (_TEMPLATE + example)
.github/workflows/
  ci-autotriage.yml            # tests fail -> triage -> PR/issue
```

## License

[MIT](LICENSE).
