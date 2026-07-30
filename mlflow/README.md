# MLflow — ERIS Nucleus

Launches an [MLflow](https://mlflow.org/) Tracking server on an ERIS Nucleus compute node, opened in the
browser via the OnDemand "Connect" button. Browse experiments, runs, parameters, metrics, and artifacts
from an MLflow tracking directory.

## Form options

- **Partition** — ERIS Nucleus SLURM partition (`normal`, `bigmem`, `long`, `short`, `interactive`)
- **Number of cores / Memory / Number of hours** — job resources (the tracking server is light)
- **Tracking directory (mlruns)** — full path to your MLflow tracking directory (the `mlruns` dir a
  training run writes). Defaults to a small shared example so you can try the app immediately.
- **MLflow binary** — path to the `mlflow` executable (a conda env), or `mlflow` on PATH

## Prerequisites on ERIS Nucleus

- An `mlflow` install. The form defaults to a shared conda env
  (`…/miniforge3/envs/mlflow_env/bin/mlflow`); point it at your own env if you prefer.

## How it works

Launched with `mlflow server --backend-store-uri file:<dir> --static-prefix /node/<host>/<port>` and
served through OnDemand's `/node` reverse proxy. MLflow's `--static-prefix` makes the UI's asset and API
URLs resolve under the proxy subpath (the `/node` proxy does not strip the prefix), analogous to
TensorBoard's `--path_prefix`. (`basic` Batch Connect template.)

Point a training script at the same directory to populate it, e.g.:

```python
import mlflow
mlflow.set_tracking_uri("file:/path/to/mlruns")   # same dir as the form field
with mlflow.start_run():
    mlflow.log_param("lr", 0.01)
    mlflow.log_metric("loss", 0.1)
```

## Notes

- A **file-based** backend store shows runs/metrics/artifacts. The MLflow **model registry** needs a
  database backend (e.g. sqlite/postgres) and is disabled with a file store — point `--backend-store-uri`
  at a database if you need it.
- Access is gated by the OnDemand login + reverse proxy (no separate MLflow auth).
- `cluster: "nucleus"` in `form.yml` must match the cluster id in
  `/etc/ood/config/clusters.d/*.yml` on the portal host.
