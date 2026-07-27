# Bioinformatics pipeline & script architecture

The portable design contract for how pipelines and scripts are built. It does not
change project to project. Each project keeps a thin `CLAUDE.md` that declares its
genericity level and scope and points here; the baseline rules below are not
optional at any level.

Read this at the start of a session before writing pipeline code.

## 1. How this is used

Three consumers share this one document, so there is a single source of truth:

- **You (or an agent)** follow it while building.
- The **genericity guard** enforces the parts of it that are machine-checkable.
- The **project setup** deploys it into new projects unchanged.

The project's own `CLAUDE.md` sets what is project-specific: the chosen level, the
scope, data/embargo rules, and escalations.

## 2. Genericity levels

A project declares one level in its `CLAUDE.md`. A mixed repository may scope a
level per subtree (e.g. a `Specific` analysis with a `Generic` pipeline maturing
inside it — see the Indonesia layout). Reusability is considered at every level;
the level only sets how far it is taken.

| Dimension | Generic / Reusable | Specific / One-off |
| --- | --- | --- |
| Organism / reference | chosen via preset, no default | may be pinned — in config |
| Sample lists / IDs | derived from inputs or config | may be listed in config |
| Thresholds | config, with rationale | config; analysis-specific values allowed |
| Presets (species / build) | required, no silent default | may fix one, stated in config |
| Example / test data | isolated under `test/`, never referenced by core | analysis data under `data/` (gitignored), referenced only via config |

The rows below the table are the baseline — they hold identically at both levels.

## 3. Baseline rules (all levels)

- No hardcoded paths, thresholds, sample IDs, organism, or reference in rules or
  scripts. Lift them to config. Paths are relative to the project root.
- Cluster/site specifics (accounts, storage, queues, emails) live in `profiles/`,
  never in a rule or script body.
- No silent defaults for consequential choices. Force an explicit choice (the
  species-preset pattern) and log the resolved choice loudly at run start.
- One rule = one scientific step. Every rule has `input`, `output`, `log`, and a
  short `message`; rules call `scripts/`, they do not inline analysis logic.
- Scripts take inputs and outputs as command-line arguments, load packages/imports
  at the top, and are commented for a domain-comfortable reader new to the method.
- Data never enters version control. `.gitignore` is default-deny; data lives
  outside VCS and is referenced only through config.
- The environment is pinned (pixi / vvg-box or equivalent), the install is scripted
  and documented, and any version deviation is recorded with its reason.
- Never state a number, sample count, or citation not derived from a file. Read or
  stream the data.
- Prefer deriving facts from inputs (contigs from the VCF header, samples from the
  VCF) over restating them in code.

## 4. Canonical directory structure

```
project/
  workflow/
    Snakefile          # orchestrator; includes rules/*, loads config
    rules/             # one .smk per scientific step
    config/            # or top-level config/ — see §5
  scripts/
    R/                 # each script: CLI args in, one job
    sh/
  config/
    config.yaml        # run & site-facing choices
    params.yaml        # tool params, organism-agnostic
    species/           # per-organism presets, no default
  profiles/            # PBS / SLURM / local — all site-specific resource config
  reference/           # reference-handling helpers/docs (not the data itself)
  test/                # small example data + scenario configs
  envs/                # environment definition + install script
  outputs/  logs/  reports/    # run artefacts — gitignored
  docs/                # schedulers, versions, methods, migration notes
  DESIGN.md            # architecture notes + "known specifics" ledger (§6)
  CLAUDE.md            # thin project contract; declares level, points here
```

Tracked: everything under `workflow/`, `scripts/`, `config/`, `profiles/`,
`envs/`, `docs/`, `test/` (small example inputs only), and the top-level docs.
Gitignored: `data/`, `outputs/`, `logs/`, `reports/`, `.snakemake/`, and all
data/genomics/secret patterns (default-deny).

## 5. Config architecture

Three layers, so every assumption is visible and changeable in one place:

- `config/config.yaml` — run and site-facing choices for this run: input directory,
  which reference/preset, mode switches. No tool internals.
- `config/params.yaml` — tool parameters as organism-agnostic defaults.
- `config/species/*.yaml` — per-organism/reference presets (priors, contig sets).
  No default: the run must name one, so data can never be silently processed under
  the wrong organism's assumptions.

Thresholds live in config with a one-line rationale, not as literals in rules or
scripts. Where a fact can be read from the inputs (contig names, sample IDs),
derive it rather than restating it.

## 6. The escape hatch (documented hardcoding)

Reality forces a hardcode sometimes — a step that only reveals a species-specific
quirk halfway through. That is allowed, but it is a dated debt, not a decision, and
it is never silent:

- Tag it exactly, on the line above:
  `# HARDCODE(reason; YYYY-MM-DD): <what and why>`
- Keep it contained: prefer config over a rule, one location, smallest scope.
- Add a matching `TODO(generalise): <what would lift it>`.
- Record it in `DESIGN.md` under "Known specifics" with the path and reason.

Every hardcode is then greppable (`HARDCODE(`), reviewable, and recoverable — which
is exactly what the genericity guard keys off.

## 7. Style & docs

- Naming: `snake_case`; `{sample}` wildcards; outputs under `outputs/<stage>/`.
- Each rule has a short README or `message` stating its input, output, and how to
  read the result.
- `DESIGN.md` holds the architecture and the known-specifics ledger; `docs/` holds
  schedulers, versions, methods, and migration notes.
- Doc style: dense and scannable. Prose where it flows, tables where comparison
  matters, code blocks only for things the reader will run. Minimal bolding, no
  decorative headers.
