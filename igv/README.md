# IGV — ERISTwo

Launches the IGV (Integrative Genomics Viewer) desktop GUI inside an XFCE/VNC
session on an ERISTwo compute node, for interactive visualization of large
genomic data (BAM/CRAM, VCF, BED, bigWig, ...).

This is a **desktop GUI** app: it uses OnDemand's `vnc` Batch Connect template
(TurboVNC + noVNC) and runs an Apptainer image bundling TurboVNC + XFCE + IGV.

## Form options

- **Partition** — ERISTwo SLURM partition (`normal`, `bigmem`, `long`, `short`, `interactive`)
- **Number of cores / Memory / Number of hours** — job resources
- **IGV Apptainer image** — path to the `.sif` (default `~/ondemand/images/igv/igv.sif`)

## Prerequisites on ERISTwo

- An **Apptainer image** bundling **TurboVNC + XFCE + IGV**, staged at the path in the form.
  Inside the image, `igv` must be on `PATH` and TurboVNC under `/opt/TurboVNC/bin`.
- The OnDemand **`vnc` template** enabled on the portal (needs `websockify`/noVNC).
- Apptainer available as a module (`Apptainer/1.4.2-1.el9`, falls back to `singularity/latest`).

The container binds `/data`, `/PHShome`, and SLURM/munge paths.

## Install

Copy this directory into `~/ondemand/dev/` (sandbox) or the admin apps root on the OnDemand host,
then launch **IGV** from *Interactive Apps*. IGV starts automatically; if closed, relaunch it from
the XFCE Applications menu.

## Notes

- `cluster: "eristwo"` in `form.yml.erb` must match the cluster id in
  `/etc/ood/config/clusters.d/*.yml` on the portal host.
