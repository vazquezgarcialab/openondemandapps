# Open OnDemand apps — ERISTwo (MGH)

[Open OnDemand](https://openondemand.org) interactive apps (Batch Connect) for the **ERISTwo** SLURM
cluster at MGH.

## Apps

| App | Notes |
|-----|-------|
| `jupyter` | JupyterLab server via conda (`conda_env`) or a `jupyter_binary` on PATH. |
| `rstudio` | RStudio Server inside an Apptainer image; per-version R libraries. |
| `cellxgene` | cellxgene viewer for an `.h5ad` file (path entered in the form). |
| `vscode` | VS Code `serve-web` (browser IDE, opened via the OOD "Connect" button). |
| `vscode_tunnel` | VS Code tunnel (connect from a local VS Code / vscode.dev). |
| `igv` | IGV desktop GUI in an XFCE/VNC session (large genomic data). |
| `qupath` | QuPath desktop GUI in an XFCE/VNC session (large bioimage / whole-slide data). |

`igv` and `qupath` are **desktop GUI** apps: they use OOD's `vnc` Batch Connect template (TurboVNC +
noVNC) and run an Apptainer image that bundles TurboVNC + XFCE + the application, rather than the
web-server template the other apps use.

## ERISTwo specifics

- **Cluster id:** every app declares `cluster: "eristwo"`. **This must match the id of an OOD cluster
  config in `/etc/ood/config/clusters.d/*.yml` on the ERISTwo portal host** — change it if the portal
  uses a different id.
- **Partitions:** forms offer `normal` (default, 1 day), `bigmem` (2 days, ~1 TB), `long` (7 days),
  `short` (3 h), `interactive` (12 h) — from `sinfo` on ERISTwo.
- **No GPU:** GPU form fields / `--gpus` args are omitted (no GPU partition in the standard `sinfo`
  list). Re-add `--gres=gpu:...` if/when a GPU partition exists.
- **Filesystems:** `/data` (lab data) and `/PHShome` (home).
- **Containers:** Apptainer via `module load Apptainer/1.4.2-1.el9` (falls back to `singularity/latest`).

## Per-app setup required on ERISTwo

- **rstudio:** stage RStudio Apptainer images at the paths the form expects
  (`~/ondemand/images/rstudio/rstudio-<ver>.sif`, or edit `rstudio/form.yml.erb` to a shared
  `/data/vazquez/...` location). The RStudio container bind-mounts `/run/munge`, `/lib64/libmunge.so.2`,
  `/usr/lib64/slurm` (and `/etc/slurm` if present) so `rsession` can submit SLURM jobs — verify these
  paths on an ERISTwo compute node.
- **jupyter:** ensure the default `conda_env` (`jupyterlab`) exists, or users override it in the form.
- **vscode / vscode_tunnel:** install the standalone VS Code CLI to `~/.local/bin/code`
  (https://update.code.visualstudio.com/latest/cli-linux-x64/stable).
- **cellxgene:** provide a `cellxgene` binary (e.g. a conda env under `/data/vazquez`) or set its path in
  the form.
- **igv / qupath:** stage an Apptainer image bundling **TurboVNC + XFCE + the app** at the path the form
  expects (`~/ondemand/images/igv/igv.sif`, `~/ondemand/images/qupath/qupath.sif`). Inside the container,
  `igv` / `QuPath` must be on PATH and TurboVNC under `/opt/TurboVNC/bin`. These apps also require the OOD
  `vnc` template to be enabled on the ERISTwo portal (needs `websockify`/noVNC).

## Deploy & verify

1. Copy this repo into `~/ondemand/dev/` on the ERISTwo OOD host (appears under *Interactive Apps →
   Sandbox* → *My Sandbox Apps*), or into the admin app root for a shared install.
2. Launch each app from the portal with default form values.
3. Confirm the SLURM job submits (`squeue -u $USER`), reaches *Running*, and the "Connect" button opens a
   working UI. **RStudio is the highest-risk** — check the Apptainer bind mounts and `rsession` launch in
   the job's `output.log` / `rsession.log`.
4. Confirm `/data/vazquez` is reachable inside each session.
