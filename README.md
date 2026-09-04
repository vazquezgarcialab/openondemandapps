# Open OnDemand apps — ERIS Nucleus (MGB)

[Open OnDemand](https://openondemand.org) interactive apps (Batch Connect) for the **ERIS Nucleus**
SLURM cluster at Mass General Brigham, served from the portal at
<https://openondemand.research.mgb.org>. The OnDemand cluster id is **`nucleus`**.

## Apps

| App | Notes |
|-----|-------|
| `jupyter` | JupyterLab server via the `JupyterLab` module (or `JupyterNotebook` / conda env / binary). GPU-capable. |
| `rstudio` | RStudio Server inside an Apptainer image; per-version R libraries. GPU-capable. |
| `vscode` | VS Code `serve-web` (browser IDE, opened via the OOD "Connect" button). GPU-capable. |
| `vscode_tunnel` | VS Code tunnel (connect from a local VS Code / vscode.dev). GPU-capable. |
| `igv` | IGV desktop GUI in an XFCE/VNC session (large genomic data). |
| `qupath` | QuPath desktop GUI in an XFCE/VNC session (large bioimage / whole-slide data). GPU-capable (StarDist/InstanSeg/WSInfer via DJL). |
| `blender` | Blender 3D suite desktop GUI in an XFCE/VNC session (software GL on CPU nodes, VirtualGL + Cycles GPU on `gpu-l40s`). |
| `napari` | napari n-dimensional image viewer in an XFCE/VNC session; bundles cellpose (deep-learning segmentation, GPU-capable). |
| `fiji` | Fiji (ImageJ) image-analysis desktop in an XFCE/VNC session; Trainable Weka built in, StarDist/DeepImageJ via update sites. GPU-capable. |
| `cellxgene` | cellxgene viewer for an `.h5ad` file (path entered in the form). |
| `tensorboard` | TensorBoard server for ML training logs (scalars, graphs, embeddings). |
| `marimo` | marimo reactive Python notebook server (git-friendly `.py` notebooks). GPU-capable. |
| `mlflow` | MLflow Tracking server to browse ML experiments, runs, metrics, and artifacts. |

`igv`, `qupath`, `blender`, `napari`, and `fiji` are **desktop GUI** apps: they use OOD's `vnc` Batch
Connect template (TurboVNC + noVNC) and run an Apptainer image that bundles TurboVNC + XFCE + the
application, rather than the web-server template the other apps use.

## Install these apps on your account

These run as OnDemand **sandbox** apps out of your home directory — no admin packaging needed.

**1. Get Develop mode enabled.** Email the MGB ERIS team
and ask them to enable OnDemand **app-development mode** for your username. Once done, a **Develop** menu
appears in the dashboard top bar.

**2. Clone this repo into `~/ondemand/dev`.** OnDemand scans the direct children of `~/ondemand/dev`
for apps, so the repo must be that directory (apps as its top-level folders):

```bash
git clone https://github.com/vazquezgarcialab/openondemandapps.git ~/ondemand/dev
```

(If `~/ondemand/dev` already exists, clone elsewhere and symlink each app dir into it instead.)

**3. Set up the backend(s)** for the app(s) you want — details in [Backends](#backends) below. Quick guide:

| App | What you need |
|-----|---------------|
| `jupyter` | Nothing — uses the `JupyterLab` module. ✅ works out of the box |
| `vscode`, `vscode_tunnel` | Install the VS Code CLI to `~/.local/bin/code` |
| `cellxgene` | A conda env with `cellxgene`; set its path in the **cellxgene Binary** field |
| `tensorboard` | A conda env with `tensorboard`; the form defaults to a shared `tensorboard_env` |
| `marimo` | A conda env with `marimo`; the form defaults to a shared `marimo_env` |
| `mlflow` | A conda env with `mlflow`; the form defaults to a shared `mlflow_env` |
| `rstudio`, `igv`, `qupath`, `blender`, `napari`, `fiji` | Nothing for lab members — the forms point at **shared images** under `/data/vazquez/ondemand/images/` (group-readable). ✅ |

The container images are built once and shared at `/data/vazquez/ondemand/images/{rstudio,igv,qupath,blender,napari,fiji}/`,
so lab members need no image setup. Building your own instead? Point the app's **image** field at your
own `.sif` (see [Building the container images](#building-the-container-images)).

**4. Launch.** In the portal go to **Develop → My Sandbox Apps**, pick an app, submit the form. If a new
app or icon doesn't show up, hard-refresh the page (icons are cached aggressively).

> Editing an app? The changes are live on the next launch — no reinstall. `git pull` in `~/ondemand/dev`
> to get updates to this repo.

## Cluster specifics

- **Cluster id:** every app declares `cluster: "nucleus"` — this matches the OOD cluster config in
  `/etc/ood/config/clusters.d/*.yml` on the portal host.
- **Partitions:** forms offer `normal` (default, 1 day), `bigmem` (2 days, ~1 TB), `long` (7 days),
  `short` (3 h), `interactive` (12 h), and — on the GPU-capable apps — `gpu-l40s` (8 h, NVIDIA L40S).
  Jobs run under the user's SLURM account (QOS `nuc_default`); the forms don't pin an account, so the
  user's default is used.
- **Filesystems:** `/data` (lab data) and `/PHShome` (home).
- **Containers:** Apptainer via `module load Apptainer/1.4.2-1.el9` (falls back to `singularity/latest`).

## GPUs (`gpu-l40s`)

Nucleus has **three GPU nodes** (`erishpc-gpu-003..005`), each with **2 × NVIDIA L40S** (48 GB) and
~1 TB RAM, in the **`gpu-l40s`** partition. Limits from `scontrol show partition gpu-l40s`: **1 node per
job, at most 2 GPUs, 8 h wall time**, and at most **two running jobs** per user. The partition is
**reserved for GPU jobs** (partition QOS `gpu_required`) — don't send CPU-only work there.

**Which apps offer it.** `gpu-l40s` is listed only where a GPU actually does something:

| GPU partition offered | Why |
|---|---|
| `jupyter`, `marimo`, `vscode`, `vscode_tunnel` | run CUDA code (PyTorch/JAX/TensorFlow) from a notebook or terminal |
| `rstudio` | CUDA-backed R packages (`torch`, `keras`) |
| `napari` | cellpose segmentation on the GPU + hardware OpenGL |
| `fiji` | GPU plugins via update sites (StarDist, DeepImageJ) + 3D Viewer OpenGL |
| `blender` | Cycles GPU rendering (CUDA/OptiX) + hardware OpenGL |
| `qupath` | StarDist / InstanSeg / WSInfer via the Deep Java Library |
| **not offered:** `tensorboard`, `mlflow`, `cellxgene`, `igv` | pure viewers / tracking UIs — nothing in them uses a GPU |

To enable it for one of the excluded apps, copy the `gpu-l40s` option row plus the `num_gpus` attribute
from e.g. `jupyter/form.yml`, and the `gpus` block from its `submit.yml.erb`.

**How it's wired.** Each GPU-capable app gains a **Number of GPUs** field (0–2), and its
`submit.yml.erb` derives the SLURM request server-side:

```erb
gpus  = queue.to_s.start_with?("gpu") ? [num_gpus.to_i, 1].max : 0
hours = [hours, 8].min if gpus > 0
```

so a `gpu-l40s` job always carries `--gpus` (never rejected by `gpu_required`), a CPU partition never
does, and wall time can't exceed the partition's 8 h — regardless of what the form's dynamic JS did. The
partition dropdown also drives `data-set-num-gpus` / `data-max-num-hours` / `data-max-num-cores` so the
form shows the right bounds (128 cores on `gpu-l40s` vs 96 elsewhere).

**Inside the session.** The NVIDIA driver is installed on the node, so CUDA works directly; SLURM sets
`CUDA_VISIBLE_DEVICES` and the launchers log `nvidia-smi -L` at startup. For CUDA toolkits/cuDNN the
cluster has modules `CUDA/12.9.0`, `CUDA/13.3.0`, `cuDNN/9.23.0.39-CUDA-13.3.0`.

**Containerized apps** (`rstudio`, `napari`, `fiji`, `blender`, `qupath`) add `apptainer --nv` when —
and only when — a GPU was allocated, bind-mounting the host driver and its userspace libraries into the
image. RStudio additionally re-exports `CUDA_VISIBLE_DEVICES` into the `rsession` wrapper, since
`rserver` starts sessions with a stripped environment.

**QuPath needs one thing more.** Its deep-learning extensions go through the Deep Java Library, which
selects a CUDA engine only if it detects a CUDA *runtime* — the driver alone is not enough. So the
`qupath` launcher also binds `/apps` and puts the cluster's newest CUDA 12.x on `LD_LIBRARY_PATH`
(QuPath 0.7.0 → DJL 0.36.0 → PyTorch 2.7.1 → CUDA 12.8; `CUDA/12.9.0` is compatible, CUDA 13 is not).
See [`qupath/README.md`](qupath/README.md).

**Hardware OpenGL in the VNC apps.** `napari`, `fiji`, and `blender` render through **VirtualGL's EGL
back end** (`vglrun -d egl`) on a GPU node — the compute nodes are headless, so VirtualGL's default GLX
back end has no X server on the GPU to attach to. Verified inside the shared image on `gpu-l40s`:

```
OpenGL renderer string: NVIDIA L40S/PCIe/SSE2
OpenGL core profile version string: 4.6.0 NVIDIA 595.91.07
```

Each launcher probes `vglrun -d egl glxinfo` first and falls back to Mesa software GL (`llvmpipe`) if it
fails, so a session never dies over graphics.

> **Rebuild needed for cellpose on GPU:** [`napari/container/napari.def`](napari/container/napari.def)
> now installs the **CUDA 12.8** PyTorch wheels instead of the CPU-only ones. The shared
> `napari.sif` must be rebuilt (see [Building the container images](#building-the-container-images))
> before cellpose will use the card. Display acceleration works with the current image either way.

## Backends

Each app calls an external backend:

- **jupyter:** the `JupyterLab` module (default; `JupyterNotebook` for the classic UI), or any conda env / `jupyter` on PATH.
- **vscode / vscode_tunnel:** the standalone VS Code CLI at `~/.local/bin/code`
  (<https://update.code.visualstudio.com/latest/cli-linux-x64/stable>).
- **cellxgene:** a conda env with cellxgene (form points at
  `…/miniforge3/envs/cellxgene_env/bin/cellxgene`).
- **tensorboard:** a conda env with tensorboard (form points at
  `…/miniforge3/envs/tensorboard_env/bin/tensorboard`); served behind OOD's `/node` proxy with
  `--path_prefix`.
- **marimo:** a conda env with marimo (form points at
  `…/miniforge3/envs/marimo_env/bin/marimo`); served behind OOD's `/node` proxy with `--base-url`,
  gated by marimo's built-in token auth.
- **mlflow:** a conda env with mlflow (form points at
  `…/miniforge3/envs/mlflow_env/bin/mlflow`); served behind OOD's `/node` proxy with `--static-prefix`.
  The launcher sets `MLFLOW_ALLOW_FILE_STORE=true` (MLflow 3.x file-store opt-in) and
  `--allowed-hosts "*"` (so the proxy's Host header passes the DNS-rebinding check); point the tracking
  field at a `sqlite:///…` URI for the model registry.
- **rstudio / igv / qupath / blender / napari / fiji:** Apptainer images, **shared for the lab** under
  `/data/vazquez/ondemand/images/{app}/` (group-readable; built once, no per-user copy):
  - `rstudio/rstudio-4.4.1.sif` — pulled from `docker://rocker/rstudio:4.4.1`. R libraries stay
    per-user at `~/R/rstudio-apptainer/<ver>` (writable, created on first launch).
  - `igv/igv.sif` — built from [`igv/container/igv.def`](igv/container/igv.def) (TurboVNC + XFCE + IGV).
  - `qupath/qupath.sif` — built from [`qupath/container/qupath.def`](qupath/container/qupath.def)
    (TurboVNC + XFCE + QuPath v0.7.0).
  - `blender/blender.sif` — built from [`blender/container/blender.def`](blender/container/blender.def)
    (TurboVNC + XFCE + Blender 4.2 LTS + VirtualGL; software GL on CPU, `vglrun -d egl` on `gpu-l40s`).
  - `napari/napari.sif` — built from [`napari/container/napari.def`](napari/container/napari.def)
    (TurboVNC + xfwm4 + napari + cellpose on CUDA PyTorch + VirtualGL; software GL on CPU,
    `vglrun -d egl` on `gpu-l40s`).
  - `fiji/fiji.sif` — built from [`fiji/container/fiji.def`](fiji/container/fiji.def)
    (TurboVNC + xfwm4 + Fiji/ImageJ + VirtualGL; launched from a writable node-local copy so update
    sites work; software GL on CPU, `vglrun -d egl` on `gpu-l40s`).

  The RStudio container bind-mounts `/run/munge`, `/lib64/libmunge.so.2`, `/usr/lib64/slurm` (and
  `/etc/slurm` if present) so `rsession` can submit SLURM jobs. The `igv`/`qupath` apps also require the
  OOD **`vnc` template** to be enabled on the portal (needs `websockify`/noVNC).

### Building the container images

Build recipes live in each app's `container/*.def`. **Build on a compute node, not the login node** —
the login node's memory cap kills `mksquashfs` ("Out of memory") and its Panasas tmpdir breaks the build
bundle. Use a node-local `APPTAINER_TMPDIR`:

```bash
srun -p interactive -A <account> -n 8 --mem 48G -t 2:00:00 --pty bash
module load Apptainer/1.4.2-1.el9
export APPTAINER_CACHEDIR=/data/vazquez/users/$USER/.apptainer/cache
export APPTAINER_TMPDIR=/tmp/aptbuild-$USER   # node-local
IMG=/data/vazquez/ondemand/images       # the shared lab location the forms point at
apptainer build "$IMG/igv/igv.sif"        igv/container/igv.def
apptainer build "$IMG/qupath/qupath.sif"  qupath/container/qupath.def
apptainer pull  "$IMG/rstudio/rstudio-4.4.1.sif" docker://rocker/rstudio:4.4.1
```

To refresh a shared image, rebuild it to the same path (group-readable). Building your own instead?
Write to `~/ondemand/images/<app>/` and point the app's **image** field there.

## Verify a launch

After installing, check an app end to end:

1. Launch it from the portal with default form values (sandbox apps are under **Develop → My Sandbox
   Apps** — see [Install](#install-these-apps-on-your-account) above).
2. Confirm the SLURM job submits (`squeue -u $USER`), reaches *Running*, and the "Connect" button opens a
   working UI. Check the
   Apptainer bind mounts and the job's `output.log` / `rsession.log`.
3. Confirm `/data/vazquez` is reachable inside each session.

## System-wide install (admins)

To publish these for everyone instead of per-user, an admin copies the app directories into the OOD
system app root (e.g. `/var/www/ood/apps/sys/`), where they appear directly under **Interactive Apps** —
no Develop mode needed. The shared images and backends above apply unchanged.
