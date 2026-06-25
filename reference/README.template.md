# <PROJECT NAME>

<One-line description of what this project does.>

## What this repo is

<2–4 sentences: the analysis/tooling, the question it answers, the stack.>

## What's included — and what's deliberately not

This repository contains **code only**. By design it does **not** include:

- raw or processed **data** (sequence, genotype, phenotype, tabular records)
- **sample sheets, manifests, or metadata** that link samples to individuals
- any **identifying or sensitive** information
- credentials, tokens, or environment files

Data lives <where — e.g. "on the institutional HPC / controlled-access archive
under accession X">, not in version control. The scripts here expect it at the
paths described below.

## Reproducing the analysis

1. <environment setup — e.g. `renv::restore()` / `conda env create -f env.yml`>
2. <where to place the input data>
3. <how to run — entry script / pipeline command>

## Structure

```
scripts/      # <what>
src/          # <what>
...
```

## License

<MIT / other>
