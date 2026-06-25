# Sensitive-content checklist

The single source of truth for both `repo-scaffold` and `commit-guard`. Tune the
rules here and both skills inherit them.

## The governing rule: default-deny

Code, scripts, notebooks **with outputs cleared**, docs, and config **without
secrets** are includable. Everything in the categories below is excluded unless the
human explicitly confirms a specific file is safe (e.g. a tiny synthetic example).
**When unsure, exclude and ask.** It is always cheaper to add a file later than to
scrub it from history.

## A. Research data — exclude by default

Sequence / genomic: `.fastq/.fq(.gz)`, `.bam/.sam/.cram(.crai/.bai)`,
`.vcf(.gz)/.bcf`, `.bed/.bim/.fam/.ped/.gen/.bgen`, `.gff/.gtf`,
`.fasta/.fa/.fna`, `.h5/.hdf5`, `.npy/.npz`.

Tabular data that often holds real records: `.csv`, `.tsv`, `.xlsx`, `.parquet`,
`.feather`, `.rds`, `.RData/.rda`. → flag every one; include only if the human
confirms it is synthetic or already-public.

Notebooks: `.ipynb` can embed real values and figures in their outputs. → require
outputs cleared before commit.

## B. Secrets / credentials — exclude, hard stop

Files: `.env`, `.env.*`, `*.pem`, `*.key`, `id_rsa*`, `*.p12`, `credentials`,
`.netrc`, `.pgpass`, `service-account*.json`, anything under `.aws/` or `.ssh/`.

Content patterns (scan file contents, not just names):
- AWS access key: `AKIA[0-9A-Z]{16}`
- GitHub token: `ghp_…`, `github_pat_…`
- Private key block: `-----BEGIN … PRIVATE KEY-----`
- Slack token: `xox[baprs]-…`
- Generic assignment: `password`, `passwd`, `secret`, `token`, `api_key`,
  `access_key` followed by `=`/`:` and a literal value
- Connection strings carrying credentials: `protocol://user:pass@host`

A secret that is already committed is **not** fixed by deleting the file in a new
commit — it stays in history. Treat any hit as: rotate the secret first, then scrub.

## C. Human-subjects / PII — exclude, hard stop (genomics-aware)

- Individual-level genotype or phenotype data; any sample ID that maps to a person.
- Patient/participant identifiers, DOB or age combined with location, clinical
  metadata.
- Geographic sample-origin that could identify a vulnerable population or
  community. (Cross-population / cross-ethnic data can be sensitive in specific
  jurisdictions — when a project touches this, exclude and ask, do not assume.)
- Names, personal emails, or addresses of participants or collaborators in any
  non-public context.

## D. Sensitive project info — review before including

- Unpublished results, embargoed data, collaborator-private notes.
- Sample collection dates where the date itself is under embargo or could
  re-identify.
- Internal infrastructure leaked in code: absolute paths with usernames
  (`/home/jwestaway/…`, `/users/…`), internal hostnames, cluster/node names,
  private URLs, ticket IDs. → parameterise or redact, don't publish.

## E. Metadata / sample sheets — exclude by default

`sample_sheet*`, `samplesheet*`, `*manifest*`, `*barcodes*`, plate maps. These link
samples to identities even when they look innocuous.

## Output of a scan

For every flagged item, report: the path (and line, for content hits), which
category it tripped, and the one-line remediation (gitignore it / `git rm --cached`
/ clear outputs / rotate + scrub). Never auto-remediate; hand over the command.
