# QuPath — ERIS Nucleus

Launches the [QuPath](https://qupath.readthedocs.io/en/stable/) GUI inside an
XFCE/VNC session on an ERIS Nucleus compute node, for interactive analysis of large
bioimage / whole-slide image data.

This is a **desktop GUI** app: it uses OnDemand's `vnc` Batch Connect template
(TurboVNC + noVNC) and runs an Apptainer image bundling TurboVNC + XFCE + QuPath.

## Form options

- **Partition** — ERIS Nucleus SLURM partition (`normal`, `bigmem`, `long`, `short`, `interactive`,
  `gpu-l40s`). Picking `gpu-l40s` requests a GPU automatically and caps wall time at 8 h.
- **Number of GPUs** — 0–2 NVIDIA L40S (48 GB each); only meaningful on `gpu-l40s`
- **Number of cores / Memory / Number of hours** — job resources (whole-slide images benefit from more memory)
- **QuPath Apptainer image** — path to the `.sif` (default `~/ondemand/images/qupath/qupath.sif`)

## GPU sessions (deep learning)

QuPath itself is a CPU viewer, but its deep-learning extensions — **StarDist**, **InstanSeg** and
**WSInfer** — run through the [Deep Java Library (DJL)](https://qupath.readthedocs.io/en/stable/docs/deep/gpu.html),
which does use an NVIDIA GPU. Select the **`gpu-l40s`** partition to get one.

DJL only picks a CUDA build of its PyTorch engine if it can detect a CUDA **runtime** — the driver that
`apptainer --nv` injects is not enough on its own. The launcher therefore also binds `/apps` and puts the
cluster's newest CUDA 12.x runtime on `LD_LIBRARY_PATH` inside the container. Version chain:

| QuPath | DJL | PyTorch | CUDA wanted | On Nucleus |
|--------|-----|---------|-------------|------------|
| 0.7.0 (this image) | 0.36.0 | 2.7.1 | 12.8 | `CUDA/12.9.0` — compatible |

CUDA 13 is deliberately *not* used: DJL would look for an engine flavour that doesn't exist.

Verified inside this image on a `gpu-l40s` node — `cudaRuntimeGetVersion` returns `12090` and one CUDA
device is visible, which is exactly what DJL probes.

**First use downloads the engine.** DJL fetches its PyTorch native (~2 GB) into `~/.djl.ai` on first
request. That lives on your home directory, so it persists across sessions, but the first run is slow and
it counts against your home quota. To confirm you got the GPU build, run in QuPath's script editor:

```groovy
println ai.djl.engine.Engine.getEngine("PyTorch")
```

and look for `CUDA` in the reported capabilities.

> Not verified end to end: an actual StarDist/InstanSeg inference run needs the GUI, so what is proven
> here is that the GPU, the driver and a compatible CUDA runtime are all visible to DJL inside the
> container. If DJL still reports a CPU engine, check `~/.djl.ai` for a partial download from an earlier
> CPU-only session and delete it.

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
