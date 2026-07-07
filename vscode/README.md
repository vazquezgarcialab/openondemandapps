# VS Code Open OnDemand App

This app allows users to launch a VS Code server on a compute node.

## Features
- Select queue (CPU/GPU)
- Specify number of cores, GPUs, and memory
- **Exclude specific nodes** from the allocation
- Custom VS Code binary and working directory

## Installation
Copy this directory to your Open OnDemand dev or sys apps directory.

## Usage
1. Open the VS Code app from the Interactive Apps menu.
2. Fill in the form.
3. If you want to exclude certain nodes, enter them in the "Excluded Nodes" field (e.g., `node01,node02`).
4. Click Launch.
5. Once the session starts, click "Connect to VS Code".
