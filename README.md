# Open OnDemand apps — ERIS Nucleus (MGB)

[Open OnDemand](https://openondemand.org) interactive apps (Batch Connect) for the **ERIS Nucleus**
SLURM cluster at Mass General Brigham, served from the portal at
<https://openondemand.research.mgb.org>. The OnDemand cluster id is **`nucleus`**.

## Apps

| App | Notes |
|-----|-------|
| `jupyter` | Jupyter server via the `JupyterNotebook` module (or a conda env / binary). |
| `rstudio` | RStudio Server inside an Apptainer image; per-version R libraries. |
| `cellxgene` | cellxgene viewer for an `.h5ad` file (path entered in the form). |
| `vscode` | VS Code `serve-web` (browser IDE, opened via the OOD "Connect" button). |
| `vscode_tunnel` | VS Code tunnel (connect from a local VS Code / vscode.dev). |
| `igv` | IGV desktop GUI in an XFCE/VNC session (large genomic data). |
| `qupath` | QuPath desktop GUI in an XFCE/VNC session (large bioimage / whole-slide data). |

`igv` and `qupath` are **desktop GUI** apps: they use OOD's `vnc` Batch Connect template (TurboVNC +
noVNC) and run an Apptainer image that bundles TurboVNC + XFCE + the application, rather than the
web-server template the other apps use.

## Cluster specifics

- **Cluster id:** every app declares `cluster: "nucleus"` — this matches the OOD cluster config in
  `/etc/ood/config/clusters.d/*.yml` on the portal host.
- **Partitions:** forms offer `normal` (default, 1 day), `bigmem` (2 days, ~1 TB), `long` (7 days),
  `short` (3 h), `interactive` (12 h). Jobs run under the user's SLURM account (QOS `nuc_default`);
  the forms don't pin an account, so the user's default is used.
- **No GPU:** GPU form fields / `--gpus` args are omitted (no GPU partition in the standard `sinfo`
  list). Re-add `--gres=gpu:...` if/when a GPU partition exists.
- **Filesystems:** `/data` (lab data) and `/PHShome` (home).
- **Containers:** Apptainer via `module load Apptainer/1.4.2-1.el9` (falls back to `singularity/latest`).

## Backends (already staged on this account; paths to reproduce elsewhere)

Each app calls an external backend. On the `iv064` account these are already installed and the forms
point at them; for a shared/multi-user install, stage them at a common location and update the form
defaults.

- **jupyter:** the `JupyterNotebook` module (default), or any conda env / `jupyter` on PATH.
- **vscode / vscode_tunnel:** the standalone VS Code CLI at `~/.local/bin/code`
  (<https://update.code.visualstudio.com/latest/cli-linux-x64/stable>).
- **cellxgene:** a conda env with cellxgene (form points at
  `…/miniforge3/envs/cellxgene_env/bin/cellxgene`).
- **rstudio / igv / qupath:** Apptainer images under `~/ondemand/images/{app}/…` (this is a symlink to
  `/data/vazquez/…/ondemand/images` so the images stay off the home quota):
  - `rstudio/rstudio-4.4.1.sif` — pulled from `docker://rocker/rstudio:4.4.1`.
  - `igv/igv.sif` — built from [`igv/container/igv.def`](igv/container/igv.def) (TurboVNC + XFCE + IGV).
  - `qupath/qupath.sif` — built from [`qupath/container/qupath.def`](qupath/container/qupath.def)
    (TurboVNC + XFCE + QuPath v0.7.0).

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
export APPTAINER_TMPDIR=/tmp/aptbuild-$USER   # node-local, NOT /data (Panasas)
apptainer build ~/ondemand/images/igv/igv.sif        igv/container/igv.def
apptainer build ~/ondemand/images/qupath/qupath.sif  qupath/container/qupath.def
apptainer pull  ~/ondemand/images/rstudio/rstudio-4.4.1.sif docker://rocker/rstudio:4.4.1
```

## Deploy & verify

1. Copy this repo into `~/ondemand/dev/` on the OOD host — it appears under **Develop → My Sandbox
   Apps** (app-development mode must be enabled on the portal) — or into the admin app root for a shared
   install under **Interactive Apps**.
2. Launch each app from the portal with default form values.
3. Confirm the SLURM job submits (`squeue -u $USER`), reaches *Running*, and the "Connect" button opens a
   working UI. **RStudio and the two VNC desktops (igv/qupath) are the highest-risk** — check the
   Apptainer bind mounts and the job's `output.log` / `rsession.log`.
4. Confirm `/data/vazquez` is reachable inside each session.
