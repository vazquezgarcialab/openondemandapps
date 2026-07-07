# QuPath — ERIS Nucleus

Launches the [QuPath](https://qupath.readthedocs.io/en/stable/) GUI inside an
XFCE/VNC session on an ERIS Nucleus compute node, for interactive analysis of large
bioimage / whole-slide image data.

This is a **desktop GUI** app: it uses OnDemand's `vnc` Batch Connect template
(TurboVNC + noVNC) and runs an Apptainer image bundling TurboVNC + XFCE + QuPath.

## Form options

- **Partition** — ERIS Nucleus SLURM partition (`normal`, `bigmem`, `long`, `short`, `interactive`)
- **Number of cores / Memory / Number of hours** — job resources (whole-slide images benefit from more memory)
- **QuPath Apptainer image** — path to the `.sif` (default `~/ondemand/images/qupath/qupath.sif`)

## Build the image

A build recipe is included at [`container/qupath.def`](container/qupath.def) (Ubuntu 22.04 + XFCE +
TurboVNC + websockify + QuPath-with-bundled-JRE):

```bash
module load Apptainer/1.4.2-1.el9
export APPTAINER_CACHEDIR=/data/vazquez/users/$USER/.apptainer/cache
apptainer build ~/ondemand/images/qupath/qupath.sif qupath/container/qupath.def
```

(On ERIS there is no fakeroot mapping, so Apptainer builds unprivileged via proot — no extra flags
needed. `~/ondemand/images` can be a symlink to `/data/vazquez/...` to keep images off the home quota.)

## Prerequisites on ERIS Nucleus

- An **Apptainer image** bundling **TurboVNC + XFCE + QuPath**, staged at the path in the form (build it
  as above). Inside the image, `QuPath` is on `PATH` and TurboVNC under `/opt/TurboVNC/bin`.
- The OnDemand **`vnc` template** enabled on the portal (needs `websockify`/noVNC).
- Apptainer available as a module (`Apptainer/1.4.2-1.el9`, falls back to `singularity/latest`).

The container binds `/data`, `/PHShome`, and SLURM/munge paths.

## Install

Copy this directory into `~/ondemand/dev/` (sandbox) or the admin apps root on the OnDemand host,
then launch **QuPath** from *Interactive Apps*. QuPath starts automatically; if closed, relaunch it
from the XFCE Applications menu.

## Notes

- `cluster: "nucleus"` in `form.yml.erb` must match the cluster id in
  `/etc/ood/config/clusters.d/*.yml` on the portal host.
