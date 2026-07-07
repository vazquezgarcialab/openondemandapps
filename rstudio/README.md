# RStudio Server — ERIS Nucleus

Launches RStudio Server inside an Apptainer container on an ERIS Nucleus compute
node, opened in the browser via the OnDemand "Connect" button.

## Form options

- **Partition** — ERIS Nucleus SLURM partition (`normal`, `bigmem`, `long`, `short`, `interactive`)
- **Number of cores / Memory / Number of hours** — job resources
- **RStudio image version** — the Apptainer image to run (auto-selects the matching R library)
- **R packages library** — per-version `R_LIBS_USER` (created on first launch)

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
