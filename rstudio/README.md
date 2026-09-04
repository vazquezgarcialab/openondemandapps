# RStudio Server — ERIS Nucleus

Launches RStudio Server inside an Apptainer container on an ERIS Nucleus compute
node, opened in the browser via the OnDemand "Connect" button.

## Form options

- **Partition** — ERIS Nucleus SLURM partition (`normal`, `bigmem`, `long`, `short`, `interactive`,
  `gpu-l40s`). Picking `gpu-l40s` requests a GPU automatically and caps wall time at 8 h.
- **Number of GPUs** — 0–2 NVIDIA L40S (48 GB each); only meaningful on `gpu-l40s`
- **Number of cores / Memory / Number of hours** — job resources
- **RStudio image version** — the Apptainer image to run (auto-selects the matching R library)
- **R packages library** — per-version `R_LIBS_USER` (created on first launch)

## GPU sessions

Select the **`gpu-l40s`** partition to land on one of the three NVIDIA L40S nodes (2 GPUs of 48 GB and
~1 TB RAM per node). The form requests at least one GPU there — the partition is reserved for GPU jobs —
and clamps wall time to the partition's 8 h limit. SLURM exports `CUDA_VISIBLE_DEVICES`, and the job log
records the allocation (`nvidia-smi -L`) at startup.

The NVIDIA driver lives on the node itself, so nothing extra is needed to reach the card:
the container is started with `apptainer --nv`, and the launcher re-exports `CUDA_VISIBLE_DEVICES`
into the `rsession` environment (rserver otherwise strips it), so R packages such as `torch` see
the card.

Partition limits (from `scontrol show partition gpu-l40s`): 1 node per job, max 2 GPUs, 8 h wall time,
and at most two of your jobs running at once.

## Prerequisites on ERIS Nucleus

- An **Apptainer/Singularity RStudio image** staged at the path the form expects
  (default `~/ondemand/images/rstudio/rstudio-<ver>.sif`; edit `form.yml.erb` to point at a
  shared `/data/vazquez/...` location if preferred).
- Apptainer available as a module (`Apptainer/1.4.2-1.el9`, falls back to `singularity/latest`).

The container bind-mounts `/data`, `/PHShome`, and SLURM/munge paths
(`/run/munge`, `/lib64/libmunge.so.2`, `/usr/lib64/slurm`, and `/etc/slurm` if present) so that
`rsession` can submit SLURM jobs from within RStudio. Verify these paths on a compute node.

## Install

Copy this directory into `~/ondemand/dev/` (sandbox) or the admin apps root on the OnDemand host,
then launch **RStudio Server** from *Interactive Apps*.

## Notes

- `cluster: "nucleus"` in `form.yml.erb` must match the cluster id in
  `/etc/ood/config/clusters.d/*.yml` on the portal host.
- Session logs: `output.log` and `rsession.log` in the job's staged directory.
