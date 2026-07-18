# cellxgene — ERIS Nucleus

Launches a [cellxgene](https://cellxgene.cziscience.com/) viewer for an AnnData
`.h5ad` file on an ERIS Nucleus compute node, opened in the browser via the OnDemand
"Connect" button.

## Form options

- **Partition** — ERIS Nucleus SLURM partition (`normal`, `bigmem`, `long`, `short`, `interactive`)
- **Number of cores / Memory / Number of hours** — job resources
- **cellxgene Binary** — path to the `cellxgene` executable (e.g. from a conda env under
  `/data/vazquez`), or just `cellxgene` if on `PATH`
- **Dataset (.h5ad)** — full path to the AnnData file to visualize

## Prerequisites on ERIS Nucleus

- A working `cellxgene` install (e.g. a conda env under `/data/vazquez`).

## Install

Copy this directory into `~/ondemand/dev/` (sandbox) or the admin apps root on the OnDemand host,
then launch **cellxgene** from *Interactive Apps*.

## Notes

- `cluster: "nucleus"` in `form.yml` must match the cluster id in
  `/etc/ood/config/clusters.d/*.yml` on the portal host.
