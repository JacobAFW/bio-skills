#!/usr/bin/env bash
# Stand up a bioinformatics project skeleton per ARCHITECTURE.md.
#
#   new-project.sh [target-dir] [Generic|Specific]
#
# Non-destructive: it creates directories (safe) and only writes a template file
# if that file does not already exist — it never overwrites your work. It does NOT
# run git; publishing is repo-scaffold's job.
set -euo pipefail

target="${1:-.}"
level="${2:-Generic}"
root="${CLAUDE_PLUGIN_ROOT:-}"
[ -n "$root" ] || { echo "CLAUDE_PLUGIN_ROOT not set — run this via the plugin." >&2; exit 2; }
case "$level" in Generic|Specific) ;; *) echo "level must be Generic or Specific" >&2; exit 2 ;; esac

name="$(basename "$(cd "$target" 2>/dev/null && pwd || echo "$target")")"

mkdir -p "$target"/workflow/rules "$target"/scripts/R "$target"/scripts/sh \
  "$target"/config/species "$target"/profiles/local "$target"/profiles/pbs \
  "$target"/profiles/slurm "$target"/reference "$target"/test "$target"/envs \
  "$target"/docs "$target"/outputs "$target"/logs "$target"/reports

[ -f "$target/ARCHITECTURE.md" ] || cp "$root/reference/architecture.md" "$target/ARCHITECTURE.md"
[ -f "$target/.gitignore" ]      || cp "$root/reference/gitignore.default" "$target/.gitignore"

created=()

if [ ! -f "$target/CLAUDE.md" ]; then
  cat > "$target/CLAUDE.md" <<EOF
# $name

<One line: what this project is.>

## Who you are

You are my bioinformatics research assistant for $name.

## Genericity level

**$level.**

This project obeys \`ARCHITECTURE.md\` (in this folder). The baseline rules there are
not optional. The level above sets how far the generic-vs-specific rows are taken.

## Scope / success criteria

<What "done" means for the current increment, and what is out of scope for now.>

## Data & embargo rules

<Project-specific handling: what can't leave the folder, sample-ID rules, etc.>

## Escalations

Ping me before: changing scope; version deviations; re-running a completed slow step.

## Memory

Read \`MEMORY.md\` at session start; update it at session end.
EOF
  created+=("CLAUDE.md")
fi

if [ ! -f "$target/DESIGN.md" ]; then
  cat > "$target/DESIGN.md" <<'EOF'
# Design

Architecture notes for this project. See ARCHITECTURE.md for the portable rules.

## Overview

<What the pipeline does, stage by stage.>

## Known specifics (escape-hatch ledger)

Every `# HARDCODE(reason; date):` in the code is recorded here with its path and
reason, so intentional specifics are visible and revisitable.

| Path | What | Why | Lift-to-generic TODO |
| --- | --- | --- | --- |
EOF
  created+=("DESIGN.md")
fi

if [ ! -f "$target/workflow/Snakefile" ]; then
  cat > "$target/workflow/Snakefile" <<'EOF'
# Top-level orchestrator. Everything site/organism-specific lives in config/.
configfile: "config/config.yaml"

include: "rules/example.smk"

rule all:
    input:
        "outputs/example/done.txt",
EOF
  created+=("workflow/Snakefile")
fi

if [ ! -f "$target/workflow/rules/example.smk" ]; then
  cat > "$target/workflow/rules/example.smk" <<'EOF'
# Example rule — one step, config-driven, nothing hardcoded. Replace with real work.
rule example:
    input:
        vcf = config["paths"]["vcf"],
    output:
        "outputs/example/done.txt",
    log:
        "logs/example.log",
    message:
        "example step on {input.vcf}"
    shell:
        "scripts/sh/example.sh {input.vcf} {output} 2> {log}"
EOF
  created+=("workflow/rules/example.smk")
fi

if [ ! -f "$target/config/config.yaml" ]; then
  cat > "$target/config/config.yaml" <<'EOF'
# Run & site-facing choices. No tool internals, no hardcoded specifics in rules.
paths:
  vcf: "data/example.vcf.gz"
reference:
  preset: ""   # name a file in config/species/ — no silent default
EOF
  created+=("config/config.yaml")
fi

if [ ! -f "$target/config/params.yaml" ]; then
  cat > "$target/config/params.yaml" <<'EOF'
# Tool parameters — organism-agnostic defaults. Per-organism priors go in
# config/species/*.yaml, not here.
EOF
  created+=("config/params.yaml")
fi

if [ ! -f "$target/config/species/README.md" ]; then
  cat > "$target/config/species/README.md" <<'EOF'
One YAML per organism/reference (priors, contig set). No default: a run must name
one, so data is never silently processed under the wrong organism's assumptions.
EOF
  created+=("config/species/README.md")
fi

[ -f "$target/scripts/sh/example.sh" ] || { cat > "$target/scripts/sh/example.sh" <<'EOF'
#!/usr/bin/env bash
# Takes inputs/outputs as CLI args — no hardcoding.
set -euo pipefail
in="$1"; out="$2"
echo "would process $in -> $out"
: > "$out"
EOF
chmod +x "$target/scripts/sh/example.sh" 2>/dev/null || true; created+=("scripts/sh/example.sh"); }

[ -f "$target/profiles/README.md" ] || { printf '%s\n' "Site-specific resource config only (accounts, storage, queues, walltime). Never in rules." > "$target/profiles/README.md"; created+=("profiles/README.md"); }
[ -f "$target/envs/install.sh" ]    || { printf '%s\n' '#!/usr/bin/env bash' 'set -euo pipefail' 'echo "Add environment install steps (pixi / conda). Document every command."' > "$target/envs/install.sh"; created+=("envs/install.sh"); }
[ -f "$target/README.md" ]          || { cp "$root/reference/README.template.md" "$target/README.md"; created+=("README.md"); }

echo "Project skeleton ready in: $target  (level: $level)"
if [ "${#created[@]}" -gt 0 ]; then
  echo "Wrote: ${created[*]}"
else
  echo "All template files already existed — nothing overwritten."
fi
echo "Next: fill CLAUDE.md scope, then build in workflow/ + scripts/. Publish later with repo-scaffold."
