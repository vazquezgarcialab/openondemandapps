# JupyterLab — ERIS Nucleus

Launches a JupyterLab server on an ERIS Nucleus compute node, opened in the browser
via the OnDemand "Connect" button.

## Form options

- **Modules** — modules to load in the job (default `JupyterLab`, which provides `jupyter-lab`;
  use `JupyterNotebook` for the classic Notebook 7 UI)
- **Partition** — ERIS Nucleus SLURM partition (`normal`, `bigmem`, `long`, `short`, `interactive`,
  `gpu-l40s`). Picking `gpu-l40s` requests a GPU automatically and caps wall time at 8 h.
- **Number of GPUs** — up to 2 L40S (48 GB) on `gpu-l40s`, up to 8 H200 (141 GB) on H200; forced to 0 elsewhere
- **Number of cores / Memory / Number of minutes** — job resources
- **Jupyter Binary** — launcher (default `jupyter-lab`; `jupyter-notebook` for the classic UI)
- **Conda Environment Name** — optional; a conda env to launch from instead of the module/binary
- **Notebooks directory** — working directory (defaults to `$HOME`)

## GPU sessions

Select the **`gpu-l40s`** partition to land on one of the three NVIDIA L40S nodes (2 GPUs of 48 GB and
~1 TB RAM per node). The form requests at least one GPU there — the partition is reserved for GPU jobs —
and clamps wall time to the partition's 8 h limit. SLURM exports `CUDA_VISIBLE_DEVICES`, and the job log
records the allocation (`nvidia-smi -L`) at startup.

The NVIDIA driver lives on the node itself, so nothing extra is needed to reach the card:
use a CUDA build of PyTorch/JAX/TensorFlow in your conda env, or add `CUDA/12.9.0` (or
`CUDA/13.3.0`, `cuDNN/9.23.0.39-CUDA-13.3.0`) to the **Modules** field.

Partition limits (from `scontrol show partition gpu-l40s`): 1 node per job, max 2 GPUs, 8 h wall time,
and at most two of your jobs running at once.

**H200 (by request).** Once MGB has granted you access to the H200 partition (`devel-gpu`: 8 × H200 of
141 GB and ~2 TB RAM per node, 14-day wall time), an **H200** option appears in the partition list by
itself — the form checks the partition's `AllowGroups` against your groups each time it loads. Until then
it's not shown, because Slurm would reject the job. Request access through the form in MGB's H200 announcement.

## Prerequisites on ERIS Nucleus

- Jupyter available in the job, via either:
  - the `JupyterLab` module (default — no setup needed), or
  - a conda env named in the **Conda Environment Name** field, or
  - a `jupyter_binary` on `PATH`.

## Install

Copy this directory into `~/ondemand/dev/` (sandbox) or the admin apps root on the OnDemand host,
then launch **Jupyter** from *Interactive Apps*.

## Notes

- `cluster: "nucleus"` in `form.yml` must match the cluster id in
  `/etc/ood/config/clusters.d/*.yml` on the portal host.
- The server password and connection are handled automatically by OnDemand (see
  `template/before.sh.erb`).
