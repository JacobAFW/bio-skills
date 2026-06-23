# Context — example-oom-001

Worked example so the corpus shape is concrete. Replace with your own real cases.

- **What was being run:** GATK HaplotypeCaller, per-sample, on 200 WGS BAMs via a SLURM array.
- **Files that existed at failure time:** input BAM present and non-empty; `.bai` present; output `.g.vcf.gz` absent for the failed array task; partial `.g.vcf.gz.tmp` left behind.
- **Environment:** university HPC, SLURM; GATK 4.5.0 in a singularity container; `--mem=8G`, `--time=24:00:00` per array task.
- **Intended downstream analysis:** joint genotyping across all 200 samples (GenomicsDBImport → GenotypeGVCFs).
