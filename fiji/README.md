# Fiji (ImageJ) — ERIS Nucleus

Launches [Fiji](https://fiji.sc/) — the "Fiji Is Just ImageJ" scientific image-analysis distribution —
inside an XFCE/VNC session on an ERIS Nucleus compute node, for interactive analysis of microscopy and
bioimaging data.

This is a **desktop GUI** app: it uses OnDemand's `vnc` Batch Connect template (TurboVNC + noVNC) and
runs an Apptainer image bundling TurboVNC + a minimal XFCE window manager + Fiji (which ships its own JRE).

## Form options

- **Partition** — ERIS Nucleus SLURM partition (`normal`, `bigmem`, `long`, `short`, `interactive`)
- **Number of cores / Memory / Number of hours** — job resources (larger images/stacks benefit from more
  memory; Fiji sizes its JVM heap from the available memory)
- **Fiji Apptainer image** — path to the `.sif` (default the shared lab image under
  `/data/vazquez/ondemand/images/fiji/`)

## Machine-learning plugins

- **Trainable Weka Segmentation** ships with Fiji (Plugins ▸ Segmentation) — interactive pixel
  classification, no setup.
- **StarDist**, **DeepImageJ**, and **CSBDeep** (deep-learning segmentation/restoration) are available via
  Fiji's **update sites** (Help ▸ Update ▸ Manage update sites), which fetch the plugins at runtime and
  require a Fiji restart.

## Build the image

A build recipe is included at [`container/fiji.def`](container/fiji.def) (Ubuntu 22.04 + XFCE window
manager + TurboVNC + VirtualGL + Fiji):

```bash
module load Apptainer/1.4.2-1.el9
export APPTAINER_CACHEDIR=/data/vazquez/users/$USER/.apptainer/cache
apptainer build /data/vazquez/ondemand/images/fiji/fiji.sif fiji/container/fiji.def
```

Build on a compute node (the login node's memory cap kills `mksquashfs`); use a node-local
`APPTAINER_TMPDIR` (see the repo README).

## GPU note

Pick the **`gpu-l40s`** partition to run on an NVIDIA L40S (48 GB); the form then requests a GPU
automatically and caps wall time at 8 h.

Fiji's **3D Viewer** renders via OpenGL — **software** Mesa (`llvmpipe`) on the CPU partitions, and on
`gpu-l40s` the launcher runs Fiji under `vglrun -d egl` for hardware-accelerated OpenGL. (The EGL back
end is required: the compute nodes are headless, so VirtualGL's default GLX back end has no X server on
the GPU to attach to.) The launcher falls back to software GL if that probe fails.

The container is started with `apptainer --nv`, so the host NVIDIA driver is visible inside it.

### Deep learning on the GPU: expect CPU

Unlike QuPath, **Fiji's deep-learning plugins will not use these GPUs**, and the app deliberately does
not pretend otherwise. Their engines are pinned to CUDA versions Nucleus does not have — and, in the
StarDist case, to a CUDA too old to drive an Ada card at all:

| Update site | Engine | CUDA it wants | On Nucleus |
|---|---|---|---|
| StarDist, CSBDeep | `imagej-tensorflow`, TF 1.15/1.16 | 10.1 + cuDNN 7.5 | absent — and CUDA 10 predates Ada (`sm_89`, needs ≥ 11.8), so it could never drive an L40S |
| DeepImageJ | JDLL, newest Linux GPU PyTorch engine 2.0.0 (DJL 0.22.1) | 11.7 / 11.8 | absent — the cluster has only CUDA 12.9 and 13.3 |

Sources: [ImageJ TensorFlow-GPU notes](https://imagej.net/develop/tensorflow) ("`CSBDeep` … comes with
TensorFlow 1.16.0, which requires CUDA 10.1 and cuDNN >= 7.5.1") and
[JDLL's engine list](https://github.com/bioimage-io/JDLL/blob/main/src/main/resources/availableDLVersions.json).

This is why the launcher does **not** put a CUDA runtime on `LD_LIBRARY_PATH` the way the `qupath` app
does. Exposing the cluster's CUDA 12.9 here would be worse than doing nothing: JDLL's DJL layer would
detect CUDA 12.x, look for a `cu12` build of PyTorch 2.0.0 that does not exist, and fall back to the CPU
anyway — just more slowly and more confusingly.

**If you want to try it regardless**, DJL can be told to skip detection and fetch a specific flavour,
which bundles its own CUDA runtime (the driver from `--nv` is then enough):

```bash
export PYTORCH_FLAVOR=cu118   # before launching Fiji, for DeepImageJ/JDLL only
```

Untested here — if it works for you, please open an issue and we will wire it into the app.

## Prerequisites on ERIS Nucleus

- An **Apptainer image** bundling **TurboVNC + XFCE WM + Fiji**, staged at the path in the form. Inside
  the image, `fiji` is on `PATH` and TurboVNC under `/opt/TurboVNC/bin`.
- The OnDemand **`vnc` template** enabled on the portal (needs `websockify`/noVNC).
- Apptainer available as a module (`Apptainer/1.4.2-1.el9`, falls back to `singularity/latest`).

The container binds `/data`, `/PHShome`, and `/PHShome_actual`.

## Install

Copy this directory into `~/ondemand/dev/` (sandbox) or the admin apps root on the OnDemand host, then
launch **Fiji** from *Interactive Apps*. Fiji starts automatically; if closed, relaunch it from a
terminal (`xterm` is available) with `fiji`.

## Notes

- The session runs only the `xfwm4` window manager (no `xfce4-panel`): a single full-screen app doesn't
  need a taskbar, and it sidesteps a gdk-pixbuf/PNG issue on this base image that crashes the panel.
- `cluster: "nucleus"` in `form.yml.erb` must match the cluster id in
  `/etc/ood/config/clusters.d/*.yml` on the portal host.
