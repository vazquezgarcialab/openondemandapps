# Open OnDemand apps — ERIS Nucleus (MGB)

[Open OnDemand](https://openondemand.org) interactive apps (Batch Connect) for the **ERIS Nucleus**
SLURM cluster at Mass General Brigham, served from the portal at
<https://openondemand.research.mgb.org>. The OnDemand cluster id is **`nucleus`**.

## Apps

| App | Notes |
|-----|-------|
| `jupyter` | JupyterLab server via the `JupyterLab` module (or `JupyterNotebook` / conda env / binary). |
| `rstudio` | RStudio Server inside an Apptainer image; per-version R libraries. |
| `vscode` | VS Code `serve-web` (browser IDE, opened via the OOD "Connect" button). |
| `vscode_tunnel` | VS Code tunnel (connect from a local VS Code / vscode.dev). |
| `igv` | IGV desktop GUI in an XFCE/VNC session (large genomic data). |
| `qupath` | QuPath desktop GUI in an XFCE/VNC session (large bioimage / whole-slide data). |
| `cellxgene` | cellxgene viewer for an `.h5ad` file (path entered in the form). |

`igv` and `qupath` are **desktop GUI** apps: they use OOD's `vnc` Batch Connect template (TurboVNC +
noVNC) and run an Apptainer image that bundles TurboVNC + XFCE + the application, rather than the
web-server template the other apps use.

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
| `rstudio`, `igv`, `qupath` | Nothing for lab members — the forms point at **shared images** under `/data/vazquez/ondemand/images/` (group-readable). ✅ |

The container images are built once and shared at `/data/vazquez/ondemand/images/{rstudio,igv,qupath}/`,
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
  `short` (3 h), `interactive` (12 h). Jobs run under the user's SLURM account (QOS `nuc_default`);
  the forms don't pin an account, so the user's default is used.
- **Filesystems:** `/data` (lab data) and `/PHShome` (home).
- **Containers:** Apptainer via `module load Apptainer/1.4.2-1.el9` (falls back to `singularity/latest`).
- **No GPU:** GPU form fields / `--gpus` args are omitted (no GPU partition in the standard `sinfo`
  list). Re-add `--gres=gpu:...` if/when a GPU partition exists.

## Backends

Each app calls an external backend:

- **jupyter:** the `JupyterLab` module (default; `JupyterNotebook` for the classic UI), or any conda env / `jupyter` on PATH.
- **vscode / vscode_tunnel:** the standalone VS Code CLI at `~/.local/bin/code`
  (<https://update.code.visualstudio.com/latest/cli-linux-x64/stable>).
- **cellxgene:** a conda env with cellxgene (form points at
  `…/miniforge3/envs/cellxgene_env/bin/cellxgene`).
- **rstudio / igv / qupath:** Apptainer images, **shared for the lab** under
  `/data/vazquez/ondemand/images/{app}/` (group-readable; built once, no per-user copy):
  - `rstudio/rstudio-4.4.1.sif` — pulled from `docker://rocker/rstudio:4.4.1`. R libraries stay
    per-user at `~/R/rstudio-apptainer/<ver>` (writable, created on first launch).
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
