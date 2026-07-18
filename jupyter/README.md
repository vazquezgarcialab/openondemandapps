# Jupyter — ERIS Nucleus

Launches a Jupyter server on an ERIS Nucleus compute node, opened in the browser
via the OnDemand "Connect" button.

## Form options

- **Modules** — modules to load in the job (default `JupyterNotebook`, which provides `jupyter` on ERIS Nucleus)
- **Partition** — ERIS Nucleus SLURM partition (`normal`, `bigmem`, `long`, `short`, `interactive`)
- **Number of cores / Memory / Number of minutes** — job resources
- **Jupyter Binary** — launcher, e.g. `jupyter-notebook` or `jupyter-lab`
- **Conda Environment Name** — optional; a conda env to launch from instead of the module/binary
- **Notebooks directory** — working directory (defaults to `$HOME`)

## Prerequisites on ERIS Nucleus

- Jupyter available in the job, via either:
  - the `JupyterNotebook` module (default — no setup needed), or
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
