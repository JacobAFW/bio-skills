---
name: pipeline-triage
description: >-
  Diagnose a failed bioinformatics pipeline run and propose the fix. Use whenever
  a job, script, or workflow step has failed, errored, crashed, or produced no/empty
  output — SLURM/PBS job failures, non-zero exit codes, tool stderr, killed jobs,
  truncated or missing output files. Triggers on "the run died", "job failed", "OOM",
  "killed", "exit code", "this errored", "no output", "empty BAM/VCF", "segfault",
  "why did this crash", or a pasted log/stack trace from samtools, bcftools, GATK,
  bwa, STAR, salmon, Nextflow, Snakemake, or a SLURM/PBS scheduler. Reads logs and
  context, names the most likely root cause, and drafts the corrected command — it
  does NOT resubmit, delete, or run anything on its own.
---

# pipeline-triage

A failed run is a detective job, not a metrics job. No mature tool reads a SLURM
log plus a samtools stderr plus an exit code and tells you *why* it died and *what
to change*. That's this skill.

## What it does

Given the evidence from a failed run, it:

1. Gathers context (see Inputs).
2. Walks the diagnostic ladder and stops at the first cause that fits.
3. Returns a **single most-likely root cause**, the evidence for it, and a **drafted
   fix** (the corrected command / config change / resubmission flags).
4. Lists secondary suspects only if the top call is genuinely ambiguous.

It proposes. It never resubmits, deletes, moves, or overwrites anything.

## Inputs (gather what's available, don't demand all of it)

- The error itself: stderr, scheduler log (`slurm-<jobid>.out`, `.err`), exit code,
  `sacct`/`seff` output if present.
- The command that was run, and the submission script (resources requested).
- File context for the inputs/outputs involved: do they exist, are they non-empty,
  is the expected index present (`.bai`, `.fai`, `.tbi`, `.csi`), are reference and
  reads on the same build/contig naming.
- Tool + version, if recoverable.

If a critical piece is missing, name the one thing to paste — don't guess past it.

## Diagnostic ladder

Stop at the first rung that explains the evidence.

1. **Resource kill.** `oom-kill`, `Killed`, exit 137, `seff` showing memory at/over
   request, walltime `TIMEOUT`/exit 140. → Right-size `--mem`/`--time`, suggest array
   chunking or a streaming flag if the input is large.
2. **Missing / stale index or input.** "could not load index", "fail to open",
   absent `.fai/.bai/.tbi`, zero-byte input, partial download. → Rebuild the index or
   re-stage the input; flag if the index is older than the file it indexes.
3. **Reference / contig mismatch.** `chr1` vs `1`, `chrM` vs `MT`, hg19 vs hg38,
   "contig not found in header", "sequence not found", coordinate beyond contig
   length. → Identify the mismatched pair and draft the rename/liftover, not a blind
   rerun. (See the build-harmonisation pattern — this is the silent-killer class.)
4. **Version / API drift.** "unrecognized argument", "unexpected keyword", a flag that
   moved between tool versions, container tag vs lockfile drift. → Pin the version or
   translate the flag to the installed version.
5. **Format / content violation.** Malformed FASTQ pairing, unsorted BAM where sorted
   is required, non-bgzipped VCF where bgzip is required, header/body sample-count
   mismatch. → Draft the preprocessing step (sort, bgzip+tabix, re-pair).
6. **Environment / scheduler.** Module not loaded, conda env not activated, `$PATH`
   on the non-interactive shell, quota/`No space left on device`, permissions. → Fix
   the env line in the submission script.
7. **Only then: the genuinely novel error.** Summarise what's known, state what single
   probe (a `--debug` rerun, a `head` of the input) would disambiguate, and stop.

## Output format

```
ROOT CAUSE: <one line>
EVIDENCE:   <the lines in the log that prove it>
FIX:        <the corrected command or config change — ready to copy>
RESUBMIT:   <the exact resubmission, NOT auto-run — Jacob runs it>
IF WRONG:   <the single next probe, if the top call doesn't hold>
```

## Guardrails

- **Propose, never execute.** No `sbatch`, no `rm`, no overwrite. Hand over the
  command; the human runs it. (Matches Jacob's standing confirmation gates.)
- **One cause, not a checklist.** Commit to the most-likely root cause. A wall of
  "could be any of these" is the failure mode this skill exists to avoid.
- **Don't invent specifics.** If the version, path, or contig name isn't in the
  evidence, say so and ask — never fabricate a flag or a filename.
- **Cite the evidence.** Every diagnosis points at the actual log line that supports
  it, so the human can sanity-check the call.
