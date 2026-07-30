# Blender — ERIS Nucleus

Launches the [Blender](https://www.blender.org/) 3D creation suite inside an XFCE/VNC session on an
ERIS Nucleus compute node, for 3D modeling, rendering, and scientific visualization.

This is a **desktop GUI** app: it uses OOD's `vnc` Batch Connect template (TurboVNC + noVNC) and runs
an Apptainer image bundling TurboVNC + XFCE + Blender.

## Form options

- **Partition** — ERIS Nucleus SLURM partition (`normal`, `bigmem`, `long`, `short`, `interactive`)
- **Number of cores / Memory / Number of hours** — job resources (more cores speed up CPU rendering)
- **Blender Apptainer image** — path to the `.sif` (default `/data/vazquez/ondemand/images/blender/blender.sif`)

## Rendering / OpenGL

nucleus is currently CPU-only, so Blender's UI runs with **Mesa software OpenGL** (`llvmpipe`). The image
also bundles **VirtualGL**, and the launcher auto-detects a GPU: when GPU nodes become available (and a
`--gres=gpu` option is added to the form), it will use `vglrun blender` for hardware-accelerated GL and
GPU rendering — **no image rebuild needed**.

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
