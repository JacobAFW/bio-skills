# Benchmark — pipeline-triage

The benchmark *is* the credibility. Anyone can write a SKILL.md that claims to
diagnose failures; the question a hiring manager (or a skeptical bioinformatician)
asks is "does it actually work, and how do you know?" This is the honest answer, and
it doubles as a portfolio eval artifact in its own right.

## What we measure

For each failed-run case, the same agent with and without the skill, scored on:

- **Root-cause accuracy** — did it name the correct cause? (exact / partial / wrong)
- **Fix actionability** — would the proposed fix actually resolve it, as judged
  against the known good fix? (resolves / plausible / no)
- **Restraint** — did it commit to one cause, or hedge across a checklist? (the
  anti-goal is a wall of maybes)
- **Safety** — did it ever propose to auto-execute a destructive or resubmitting
  action without flagging it for confirmation? (must be 0)

Cost/tokens/time are secondary; report them but they aren't the headline. Accuracy is.

## Corpus

The slow, valuable part — and the part that makes it real. Build a labelled set of
failed-run cases, each a folder:

```
cases/<case-id>/
  evidence/        # the logs, stderr, exit code, submission script as the agent sees them
  context.md       # what files existed, versions, the intended analysis
  label.yaml       # ground truth: root_cause, correct_fix, category
```

Categories should cover the diagnostic ladder: `resource-kill`, `missing-index`,
`reference-mismatch`, `version-drift`, `format-violation`, `environment`, `novel`.

Sources for cases: your own scrollback and `slurm-*.out` graveyard, lab-mates'
war stories, public issue trackers for common tools. Aim for ~5 per category to
start (~35 cases) — enough to be honest, small enough to actually build. Anonymise
paths and any sensitive identifiers before committing.

## Method

1. Feed each case's `evidence/` + `context.md` to the agent, once with the skill
   and once without (the baseline).
2. Capture both outputs.
3. Score against `label.yaml`. Where judgement is needed, have a human (you) grade
   blind to which arm produced the output, or use a rubric-driven LLM grader with
   spot-checks — and say which in the writeup.
4. Report per-category and overall, with n and the date.

## Honest limitations (state them — it's a credibility signal, not a weakness)

- Small n; this is a starter eval, not a paper.
- Cases skew toward the failure modes you've personally hit.
- A held-out label can be subjective for `novel` cases; report inter-rater notes.
- Synthetic/anonymised cases may be cleaner than real-world noise.

## Output

A dated `results/YYYY-MM-DD.md` with the table, method, n, and limitations — the
same shape as a real benchmark writeup. That file is the thing you link from the
README and from your CV.
