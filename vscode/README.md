# VS Code — ERISTwo

Launches VS Code (`serve-web`) on an ERISTwo compute node — a browser IDE opened
via the OnDemand "Connect" button.

## Features
- Select ERISTwo partition (`normal`, `bigmem`, `long`, `short`, `interactive`)
- Specify number of cores and memory
- **Exclude specific nodes** from the allocation
- Custom VS Code binary path (default `~/.local/bin/code`)

## Prerequisites on ERISTwo
Install the standalone VS Code CLI to `~/.local/bin/code`
(https://update.code.visualstudio.com/latest/cli-linux-x64/stable).

## Installation
Copy this directory into `~/ondemand/dev/` (sandbox) or the admin apps root on the OnDemand host.
`cluster: "eristwo"` in `form.yml.erb` must match the cluster id in `/etc/ood/config/clusters.d/*.yml`.

## Usage
1. Open the VS Code app from the Interactive Apps menu.
2. Fill in the form.
3. If you want to exclude certain nodes, enter them in the "Excluded Nodes" field (e.g., `node01,node02`).
4. Click Launch.
5. Once the session starts, click "Connect to VS Code".
