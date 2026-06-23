# Context — <case-id>

One short paragraph the agent sees alongside the raw evidence. Describe only what a
colleague would tell you when handing over the failure — not the answer.

- **What was being run:** <e.g. variant calling on 200 WGS samples, GATK HaplotypeCaller per-sample>
- **Files that existed at failure time:** <inputs present? indexes present? output partial/empty?>
- **Environment:** <cluster + scheduler, container/conda, tool versions if known>
- **Intended downstream analysis:** <what the output feeds into — sets fitness-for-purpose>

Keep it honest: include what you actually knew at the moment of failure, not
hindsight. Anonymise paths, sample IDs, and anything sensitive.
