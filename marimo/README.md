# marimo — ERIS Nucleus

Launches a [marimo](https://marimo.io/) reactive Python notebook server on an ERIS Nucleus compute
node, opened in the browser via the OnDemand "Connect" button. marimo notebooks are reactive (cells
re-run automatically on change) and stored as plain, git-friendly `.py` files — a modern alternative to
Jupyter (offered alongside it, not as a replacement).

## Form options

- **Partition** — ERIS Nucleus SLURM partition (`normal`, `bigmem`, `long`, `short`, `interactive`,
  `gpu-l40s`). Picking `gpu-l40s` requests a GPU automatically and caps wall time at 8 h.
- **Number of GPUs** — 0–2 NVIDIA L40S (48 GB each); only meaningful on `gpu-l40s`
- **Number of cores / Memory / Number of hours** — job resources
- **Notebook or directory** — optional `.py` notebook to open or a directory to browse (defaults to `$HOME`)
- **marimo binary** — path to the `marimo` executable (a conda env), or `marimo` on PATH

## GPU sessions

Select the **`gpu-l40s`** partition to land on one of the three NVIDIA L40S nodes (2 GPUs of 48 GB and
~1 TB RAM per node). The form requests at least one GPU there — the partition is reserved for GPU jobs —
and clamps wall time to the partition's 8 h limit. SLURM exports `CUDA_VISIBLE_DEVICES`, and the job log
records the allocation (`nvidia-smi -L`) at startup.

The NVIDIA driver lives on the node itself, so nothing extra is needed to reach the card:
use a CUDA build of PyTorch/JAX/TensorFlow in the conda env the **marimo binary** points at.

Partition limits (from `scontrol show partition gpu-l40s`): 1 node per job, max 2 GPUs, 8 h wall time,
and at most two of your jobs running at once.

## Prerequisites on ERIS Nucleus

- A `marimo` install. The form defaults to a shared conda env
  (`…/miniforge3/envs/marimo_env/bin/marimo`); point it at your own env if you prefer.

## How it works

Launched with `marimo edit --headless --base-url /node/<host>/<port> --token-password <pw>` and served
through OnDemand's `/node` reverse proxy. marimo's built-in token auth gates access (no separate proxy
needed). (`basic` Batch Connect template.)

## Install

Copy this directory into `~/ondemand/dev/` (sandbox) or the admin apps root on the OnDemand host,
then launch **marimo** from *Interactive Apps*.

## Notes

- `cluster: "nucleus"` in `form.yml` must match the cluster id in
  `/etc/ood/config/clusters.d/*.yml` on the portal host.
