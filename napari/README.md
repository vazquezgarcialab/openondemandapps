# napari — ERIS Nucleus

Launches the [napari](https://napari.org/) multi-dimensional image viewer inside an XFCE/VNC session
on an ERIS Nucleus compute node — for interactive visualization and analysis of large n-dimensional
imaging data (microscopy, whole-slide, volumetric). The image also bundles
[cellpose](https://www.cellpose.org/) for deep-learning cell/nucleus segmentation.

This is a **desktop GUI** app: it uses OnDemand's `vnc` Batch Connect template (TurboVNC + noVNC) and
runs an Apptainer image bundling TurboVNC + a minimal XFCE window manager + napari.

## Form options

- **Partition** — ERIS Nucleus SLURM partition (`normal`, `bigmem`, `long`, `short`, `interactive`)
- **Number of cores / Memory / Number of hours** — job resources (napari benefits from more memory for
  large multi-dimensional images)
- **napari Apptainer image** — path to the `.sif` (default the shared lab image under
  `/data/vazquez/ondemand/images/napari/`)

## Build the image

A build recipe is included at [`container/napari.def`](container/napari.def) (Ubuntu 22.04 + XFCE
window manager + TurboVNC + VirtualGL + napari + cellpose):

```bash
module load Apptainer/1.4.2-1.el9
export APPTAINER_CACHEDIR=/data/vazquez/users/$USER/.apptainer/cache
apptainer build /data/vazquez/ondemand/images/napari/napari.sif napari/container/napari.def
```

Build on a compute node (the login node's memory cap kills `mksquashfs`); use a node-local
`APPTAINER_TMPDIR` (see the repo README).

## GPU note

Pick the **`gpu-l40s`** partition to run on an NVIDIA L40S (48 GB); the form then requests a GPU
automatically and caps wall time at 8 h.

- **Display:** software OpenGL (Mesa `llvmpipe`) on the CPU partitions; on `gpu-l40s` the launcher runs
  napari under `vglrun -d egl` for hardware-accelerated OpenGL. (The EGL back end is required — the
  compute nodes are headless, so VirtualGL's default GLX back end has no X server on the GPU to attach
  to.) It falls back to software GL if the probe fails.
- **cellpose:** the image ships the **CUDA 12.8 PyTorch** wheels, so cellpose segmentation runs on the
  GPU when one is allocated and on the CPU otherwise. The container is started with `apptainer --nv`,
  which exposes the host NVIDIA driver inside it.

> The CUDA PyTorch switch landed in [`container/napari.def`](container/napari.def) — **the shared
> `napari.sif` must be rebuilt** for cellpose to use the GPU. Until then the running image still has the
> CPU-only build (display acceleration works either way).

## Prerequisites on ERIS Nucleus

- An **Apptainer image** bundling **TurboVNC + XFCE WM + napari**, staged at the path in the form.
  Inside the image, `napari` is on `PATH` and TurboVNC under `/opt/TurboVNC/bin`.
- The OnDemand **`vnc` template** enabled on the portal (needs `websockify`/noVNC).
- Apptainer available as a module (`Apptainer/1.4.2-1.el9`, falls back to `singularity/latest`).

The container binds `/data`, `/PHShome`, and `/PHShome_actual`.

## Install

Copy this directory into `~/ondemand/dev/` (sandbox) or the admin apps root on the OnDemand host,
then launch **napari** from *Interactive Apps*. napari starts automatically; if closed, relaunch it
from a terminal (`xterm` is available).

## Notes

- The session runs only the `xfwm4` window manager (no `xfce4-panel`): a single full-screen app
  doesn't need a taskbar, and it sidesteps a gdk-pixbuf/PNG issue on this base image that crashes the
  panel.
- `cluster: "nucleus"` in `form.yml.erb` must match the cluster id in
  `/etc/ood/config/clusters.d/*.yml` on the portal host.
