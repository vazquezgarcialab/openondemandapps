# Blender — ERIS Nucleus

Launches the [Blender](https://www.blender.org/) 3D creation suite inside an XFCE/VNC session on an
ERIS Nucleus compute node, for 3D modeling, rendering, and scientific visualization.

This is a **desktop GUI** app: it uses OOD's `vnc` Batch Connect template (TurboVNC + noVNC) and runs
an Apptainer image bundling TurboVNC + XFCE + Blender.

## Form options

- **Partition** — ERIS Nucleus SLURM partition (`normal`, `bigmem`, `long`, `short`, `interactive`,
  `gpu-l40s`). Picking `gpu-l40s` requests a GPU automatically and caps wall time at 8 h.
- **Number of GPUs** — 0–2 NVIDIA L40S (48 GB each); only meaningful on `gpu-l40s`
- **Number of cores / Memory / Number of hours** — job resources (more cores speed up *CPU* rendering;
  on a GPU node let Cycles use the card instead)
- **Blender Apptainer image** — path to the `.sif` (default `/data/vazquez/ondemand/images/blender/blender.sif`)

## Rendering / OpenGL

On the CPU partitions Blender's UI runs with **Mesa software OpenGL** (`llvmpipe`).

On **`gpu-l40s`** the launcher detects the allocated GPU (`CUDA_VISIBLE_DEVICES`) and runs Blender under
**VirtualGL's EGL back end** — `vglrun -d egl blender` — giving hardware-accelerated OpenGL 4.6 on the
L40S. The EGL back end is required because the compute nodes are headless: there is no X server bound to
the GPU for VirtualGL's default GLX back end to attach to. If the probe fails for any reason the launcher
falls back to software GL, so a session never dies over graphics.

For **Cycles GPU rendering** you still have to select the device once per session:
*Edit → Preferences → System → Cycles Render Devices → CUDA* (or *OptiX*), tick the L40S, then set
*Render Properties → Device → GPU Compute*. Blender stores that in `~/.config/blender`, so it persists
across sessions.

## Build the image

Recipe at [`container/blender.def`](container/blender.def) (Ubuntu 22.04 + XFCE + TurboVNC + VirtualGL +
Blender 4.2 LTS). Build on a **compute node** (login node OOMs on `mksquashfs`):

```bash
srun -p interactive -A <account> -n 8 --mem 48G -t 2:00:00 --pty bash
module load Apptainer/1.4.2-1.el9
export APPTAINER_CACHEDIR=/data/vazquez/users/$USER/.apptainer/cache
export APPTAINER_TMPDIR=/tmp/aptbuild-$USER
apptainer build /data/vazquez/ondemand/images/blender/blender.sif blender/container/blender.def
```

## Install

Copy this directory into `~/ondemand/dev/` (sandbox) or the admin apps root on the OnDemand host,
then launch **Blender** from *Interactive Apps*.

## Notes

- `cluster: "nucleus"` in `form.yml.erb` must match the cluster id in
  `/etc/ood/config/clusters.d/*.yml` on the portal host.
