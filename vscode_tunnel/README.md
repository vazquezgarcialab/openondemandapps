# VS Code Tunnel Open OnDemand App

This app allows users to launch a VS Code tunnel on a compute node, enabling remote access to the compute environment from any VS Code instance.

## Features
- Select queue (CPU/GPU)
- Specify number of cores, GPUs (including type), and memory
- Load specific environment modules (default: `cuda/12.0`)
- **Exclude specific nodes** from the allocation
- Custom tunnel name (default: `iris_compute`)
- Custom VS Code binary path (default: `~/.local/bin/code`)
- Automatic extraction of authentication codes displayed in the session card

## Installation
Copy this directory to your Open OnDemand dev or sys apps directory.

## Usage
1. Open the VS Code Tunnel app from the Interactive Apps menu.
2. Fill in the form (adjust resources, binary path, and tunnel name if needed).
3. If you want to exclude certain nodes, enter them in the "Excluded Nodes" field (e.g., `node01,node02`).
4. Click Launch.
5. Once the session starts, the authentication URL and code will be displayed directly in the session card.
6. **First-time setup:** If this is your first time, visit the displayed URL and enter the code to authorize the tunnel. You can also view the full logs by clicking "View Full Logs".
7. After authentication, you can connect to the tunnel (named as specified in the form) from any VS Code instance (File > Remote-Tunnels: Connect to Tunnel).

## Tunnel Details
- **Tunnel Name:** Configurable (default: `iris_compute`)
- **Command:** `code tunnel --name <tunnel_name> --accept-server-license-terms`
- **Default Binary:** `~/.local/bin/code`

## Notes
- The tunnel will remain active for the duration of the job.
- You can connect to it from VS Code on any machine (desktop, laptop, etc.) once authenticated.
- The tunnel uses Microsoft's VS Code tunnel service for secure connections.
