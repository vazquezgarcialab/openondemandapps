# marimo — ERIS Nucleus

Launches a [marimo](https://marimo.io/) reactive Python notebook server on an ERIS Nucleus compute
node, opened in the browser via the OnDemand "Connect" button. marimo notebooks are reactive (cells
re-run automatically on change) and stored as plain, git-friendly `.py` files — a modern alternative to
Jupyter (offered alongside it, not as a replacement).

## Form options

- **Partition** — ERIS Nucleus SLURM partition (`normal`, `bigmem`, `long`, `short`, `interactive`)
- **Number of cores / Memory / Number of hours** — job resources
- **Notebook or directory** — optional `.py` notebook to open or a directory to browse (defaults to `$HOME`)
- **marimo binary** — path to the `marimo` executable (a conda env), or `marimo` on PATH

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
