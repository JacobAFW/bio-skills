#!/usr/bin/env bash
# Deterministic genericity scanner.
#
# Flags UNTAGGED, high-precision hardcoding in CORE pipeline code (workflow rules
# and scripts). It is the pattern-precise subset that a hook can enforce without
# false-positive fatigue; threshold-sanity and organism-assumption judgement live
# in the genericity-lint skill.
#
#   genericity-scan.sh <file> [<file> ...]   scan specific files (hook use)
#   genericity-scan.sh                        scan core code under the repo
#
# A finding is suppressed if its line, or the line directly above it, carries the
# escape-hatch tag  HARDCODE(  . Exempt: config/, test(s)/, example(s)/, docs/,
# legacy/, README, .claude/. Exit 0 = clean or non-core, 1 = findings (stderr).
set -uo pipefail

targets=()
if [ "$#" -gt 0 ]; then
  for a in "$@"; do [ -f "$a" ] && targets+=("$a"); done
else
  while IFS= read -r f; do targets+=("$f"); done < <(
    { git ls-files 2>/dev/null || find . -type f; } | grep -E '(/workflow/rules/|/scripts/)|\.smk$'
  )
fi
[ "${#targets[@]}" -eq 0 ] && exit 0

is_core() {
  case "$1" in
    *"/config/"*|*"/test/"*|*"/tests/"*|*"/examples/"*|*"/example/"*|*"/docs/"*|*"/legacy/"*|*README*|*".claude/"*) return 1 ;;
  esac
  case "$1" in
    *"/workflow/rules/"*|*.smk|*"/scripts/"*) return 0 ;;
    *) return 1 ;;
  esac
}

abs_re='(/home/|/g/data|/scratch|/Users/|/mnt/|(^|[^A-Za-z0-9])~/)'
acc_re='\b[SED]RR[0-9]{5,}\b'
email_re='[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}'
ref_re='["'"'"'][^"'"'"']*\.(fasta|fa|fna|gff|gff3|gtf|dict|fai)["'"'"']'

findings=0
for f in "${targets[@]}"; do
  is_core "$f" || continue
  prev=""
  n=0
  while IFS= read -r line || [ -n "$line" ]; do
    n=$((n+1))
    case "$line$prev" in *"HARDCODE("*) prev="$line"; continue ;; esac
    if printf '%s' "$line" | grep -Eq "$abs_re"; then
      echo "  $f:$n [abs-path] absolute/site path — move to config or profiles/" >&2; findings=$((findings+1))
    fi
    if printf '%s' "$line" | grep -Eq "$acc_re"; then
      echo "  $f:$n [accession] sequence accession hardcoded — lift to config/sample sheet" >&2; findings=$((findings+1))
    fi
    if printf '%s' "$line" | grep -Eq "$email_re"; then
      echo "  $f:$n [email] email in code — move to profiles/" >&2; findings=$((findings+1))
    fi
    if printf '%s' "$line" | grep -Eiq "$ref_re"; then
      case "$line" in
        *config*|*params*|*"{"*) : ;;
        *) echo "  $f:$n [ref-literal] reference file hardcoded — pull from config (verify)" >&2; findings=$((findings+1)) ;;
      esac
    fi
    prev="$line"
  done < "$f"
done

if [ "$findings" -gt 0 ]; then
  echo "genericity-scan: $findings untagged hardcode(s) in core code" >&2
  echo "Lift to config, or tag intentional ones: # HARDCODE(reason; $(date +%F)): ..." >&2
  exit 1
fi
exit 0
