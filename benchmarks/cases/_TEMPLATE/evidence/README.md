Put the raw evidence the agent is allowed to see here, exactly as it appeared:

- the scheduler log (`slurm-<jobid>.out` / `.err`)
- the tool's stderr
- the submission script (so resources requested are visible)
- `seff`/`sacct` output if you have it
- a `tree`/`ls -l` of the relevant input/output dir at failure time

No ground truth in this folder — the correct cause and fix live in `../label.yaml`.
