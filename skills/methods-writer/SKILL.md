---
name: methods-writer
description: >-
  Draft the Methods section and reproducibility record for a finished bioinformatics
  analysis from its actual artifacts. Use when the analysis is done and it needs
  writing up, or when someone asks "what versions/parameters did we use", "write the
  methods", "document this pipeline", "make this reproducible", or needs a methods
  paragraph, a software/version table, or a reproducibility checklist for a paper,
  report, or repo. Reads configs, command history, submission scripts, env/lock files,
  container tags, and `--version` output, then writes prose with exact versions and
  parameters. NEVER invents a version, parameter, or reference build it cannot find —
  it flags the gap and asks.
---

# methods-writer

The analysis is finished; now there's the tedious, error-prone job of reconstructing
exactly what was run, at which versions, with which parameters, and writing it in a
form a reviewer accepts. Provenance tools capture the data but don't write the prose.
This skill does the synthesis.

## What it does

From the run's own artifacts, it produces three things:

1. **A Methods paragraph** — publication-register prose, tools named with versions,
   key non-default parameters stated, reference genome/build and annotation named,
   in logical pipeline order.
2. **A software & version table** — tool, version, and where the version was read
   from (so it's auditable).
3. **A reproducibility checklist** — what someone would need to rerun it, and a
   flagged list of anything that couldn't be pinned down.

## Inputs (gather, don't demand)

- Command history / submission scripts / Nextflow or Snakemake configs.
- Environment provenance: `environment.yml`, `conda list`, lock files,
  `renv.lock`, `requirements.txt`, container image tags/digests.
- Tool versions: `--version` output, module load lines, container manifests.
- Reference & annotation: genome build, FASTA, GTF/GFF, dbSNP/known-sites versions.
- The intended audience: journal Methods vs internal report vs repo README (sets
  register and depth).

## Output format

```
METHODS (draft)
<ordered prose paragraph(s) — tools, versions, key params, reference build>

SOFTWARE & VERSIONS
| Tool | Version | Source of version |
| ---- | ------- | ----------------- |

REPRODUCIBILITY CHECKLIST
[ ] reference build + annotation named and versioned
[ ] all non-default parameters captured
[ ] random seeds recorded (where applicable)
[ ] environment pinned (lock file / container digest)
[ ] input data accession / location stated

GAPS — need confirmation before this is submission-ready
- <each thing that could not be found in the artifacts>
```

## Guardrails

- **Cite-or-ask. Never invent.** A version, parameter, build, or accession that isn't
  in the artifacts goes in the GAPS list as a question — it is never fabricated or
  guessed. (This is the single rule that makes the output trustworthy.)
- **Source every version.** The table records *where* each version came from, so the
  human can verify rather than take it on faith.
- **Draft, not final.** Output is explicitly a draft for the human to check and own,
  not a finished Methods section to paste unread.
- **Match the register to the audience.** Journal Methods, internal report, and repo
  README are different documents; ask which if it isn't obvious.
