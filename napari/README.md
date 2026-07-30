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

The image renders via **software OpenGL** (Mesa `llvmpipe`) on CPU nodes and is **VirtualGL-ready**:
on a GPU node the launcher runs napari under `vglrun` automatically. PyTorch is currently the **CPU**
build (GPU partitions aren't available yet) — when GPU nodes arrive, rebuild swapping the CUDA PyTorch
wheel so cellpose can use the GPU.

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
