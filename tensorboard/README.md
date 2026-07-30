# TensorBoard — ERIS Nucleus

Launches a [TensorBoard](https://www.tensorflow.org/tensorboard) server on an ERIS Nucleus compute
node to explore ML training logs (scalars, graphs, histograms, embeddings) in the browser, opened via
the OnDemand "Connect" button.

## Form options

- **Partition** — ERIS Nucleus SLURM partition (`normal`, `bigmem`, `long`, `short`, `interactive`)
- **Number of cores / Memory / Number of hours** — job resources (TensorBoard is light)
- **Log directory** — **required**; full path to the directory containing your event logs
- **Extra TensorBoard args** — optional, passed verbatim to `tensorboard`
- **TensorBoard binary** — path to the `tensorboard` executable (a conda env), or `tensorboard` on PATH

## Prerequisites on ERIS Nucleus

- A `tensorboard` install. The form defaults to a shared conda env
  (`…/miniforge3/envs/tensorboard_env/bin/tensorboard`); point it at your own env if you prefer.

## How it works

TensorBoard has no authentication of its own, so access is gated by the OnDemand login. It is served
through OnDemand's `/node` reverse proxy and launched with `--path_prefix=/node/<host>/<port>` so its
asset URLs resolve correctly behind the proxy. (`basic` Batch Connect template.)

## Install

Copy this directory into `~/ondemand/dev/` (sandbox) or the admin apps root on the OnDemand host,
then launch **TensorBoard** from *Interactive Apps*.

## Notes

- `cluster: "nucleus"` in `form.yml` must match the cluster id in
  `/etc/ood/config/clusters.d/*.yml` on the portal host.
