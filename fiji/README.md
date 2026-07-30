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

Fiji's **3D Viewer** renders via OpenGL — **software** Mesa (`llvmpipe`) on CPU nodes, and the launcher
runs Fiji under `vglrun` automatically on GPU nodes (the image is VirtualGL-ready).

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
