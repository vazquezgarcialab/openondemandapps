# VS Code Tunnel — ERIS Nucleus

Launches a VS Code tunnel on an ERIS Nucleus compute node, enabling remote access to the compute environment from any VS Code instance.

## Features
- Select ERIS Nucleus partition (`normal`, `bigmem`, `long`, `short`, `interactive`, `gpu-l40s`)
- Request 1–2 NVIDIA L40S GPUs on `gpu-l40s` (48 GB each, 8 h max wall time), or 1–8 H200 (141 GB, 14 days) once MGB grants access
- Specify number of cores and memory
- Load specific environment modules (blank by default)
- **Exclude specific nodes** from the allocation
- Custom tunnel name (default: `nucleus_compute`)
- Custom VS Code binary path (default: `~/.local/bin/code`)
- Automatic extraction of authentication codes displayed in the session card

## GPU sessions

Select the **`gpu-l40s`** partition to land on one of the three NVIDIA L40S nodes (2 GPUs of 48 GB and
~1 TB RAM per node). The form requests at least one GPU there — the partition is reserved for GPU jobs —
and clamps wall time to the partition's 8 h limit. SLURM exports `CUDA_VISIBLE_DEVICES`, and the job log
records the allocation (`nvidia-smi -L`) at startup.

The NVIDIA driver lives on the node itself, so nothing extra is needed to reach the card:
run CUDA code from the integrated terminal or a notebook kernel using a CUDA build of your
framework, or `module load CUDA/12.9.0`.

Partition limits (from `scontrol show partition gpu-l40s`): 1 node per job, max 2 GPUs, 8 h wall time,
and at most two of your jobs running at once.

**H200 (by request).** Once MGB has granted you access to the H200 partition (`devel-gpu`: 8 × H200 of
141 GB and ~2 TB RAM per node, 14-day wall time), an **H200** option appears in the partition list by
itself — the form checks the partition's `AllowGroups` against your groups each time it loads. Until then
it's not shown, because Slurm would reject the job. Request access through the form in MGB's H200 announcement.

## Prerequisites on ERIS Nucleus
Install the standalone VS Code CLI to `~/.local/bin/code`
(https://update.code.visualstudio.com/latest/cli-linux-x64/stable).

## Installation
Copy this directory into `~/ondemand/dev/` (sandbox) or the admin apps root on the OnDemand host.
`cluster: "nucleus"` in `form.yml.erb` must match the cluster id in `/etc/ood/config/clusters.d/*.yml`.

## Usage
1. Open the VS Code Tunnel app from the Interactive Apps menu.
2. Fill in the form (adjust resources, binary path, and tunnel name if needed).
3. If you want to exclude certain nodes, enter them in the "Excluded Nodes" field (e.g., `node01,node02`).
4. Click Launch.
5. Once the session starts, the authentication URL and code will be displayed directly in the session card.
6. **First-time setup:** If this is your first time, visit the displayed URL and enter the code to authorize the tunnel. You can also view the full logs by clicking "View Full Logs".
7. After authentication, you can connect to the tunnel (named as specified in the form) from any VS Code instance (File > Remote-Tunnels: Connect to Tunnel).

## Tunnel Details
- **Tunnel Name:** Configurable (default: `nucleus_compute`)
- **Command:** `code tunnel --name <tunnel_name> --accept-server-license-terms`
- **Default Binary:** `~/.local/bin/code`

## Notes
- The tunnel will remain active for the duration of the job.
- You can connect to it from VS Code on any machine (desktop, laptop, etc.) once authenticated.
- The tunnel uses Microsoft's VS Code tunnel service for secure connections.
