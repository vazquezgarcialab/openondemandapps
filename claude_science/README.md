# Claude Science — ERIS Nucleus

[Claude Science](https://www.anthropic.com/news/claude-science-ai-workbench) is Anthropic's AI research
workbench: a local daemon serving a browser UI, with ~60 scientific databases and analysis specialists
built in. This app runs it on a Nucleus **compute node** and opens it through OnDemand, so your data
stays on the cluster and only the conversation goes to the Anthropic API.

> **This app runs Claude WITHOUT its security sandbox.** That is not a configuration choice — the
> sandbox cannot work on Nucleus compute nodes at all. Claude gets full read/write access to your
> home directory and unrestricted network from the job. Read
> [Sandbox: a hard blocker on Nucleus](#sandbox-a-hard-blocker-on-nucleus) before using it, and
> think about what you point it at.

**You need a Claude Pro, Max, Team or Enterprise account** to sign in. Whether MGB's licence covers
running it against MGB data is a separate question from whether it works — confirm before lab-wide use.

## Form options

- **Partition / cores / memory / hours** — job resources. CPU-only: Claude Science drives the Anthropic
  API and runs analysis code locally. Add a GPU option by copying the `num_gpus` attribute and the GPU
  table from `jupyter/` if you need one.
- **Claude Science data directory** — conversations, artifacts and the database; persists between
  sessions. Defaults to `~/.claude-science`; **move it to `/data/vazquez/users/$USER/...` if your home
  quota is tight**, as it grows.
- **Project folder** — optional directory to start in. You still grant Claude access to folders from
  inside the UI.
- **claude-science binary** — the shared lab install (see below).

## Sandbox: a hard blocker on Nucleus

Claude Science confines the code the agent runs using **bubblewrap**. On Nucleus that cannot work,
so **the app always passes `--dangerously-no-sandbox`**. There is no form option for it: offering a
choice that only ever has one working answer just hid the real situation.

`pivot_root` cannot escape the initial rootfs, and the compute nodes boot stateless, so there is
nothing to pivot into. Measured on every partition:

| Where | `/` is | bubblewrap |
|---|---|---|
| `short` / `normal` / `bigmem` / `gpu-l40s` | `rootfs` | `pivot_root: Invalid argument` |
| Inside Apptainer (incl. `--fakeroot`) | overlay, `unbindable` | `Can't bind mount /oldroot/` |
| **Login node** | `/dev/mapper/vg_root-lv_root` | **works** |

Rooting bwrap somewhere else does not help either — `--bind /data /`, `--bind $TMPDIR /` and
`--unshare-all` all fail with the same `pivot_root` error. No rootless podman or docker is
installed. The login node is the only place the sandbox works, and that is not where jobs run.

**What this means in practice.** Anthropic's own banner calls this equivalent to
`--dangerously-skip-permissions` in Claude Code: a prompt-injected or misbehaving agent can read
secrets, modify or delete files, and exfiltrate data. Given what sits on `/data/vazquez`, scope each
session — a short partition, a short wall time, and a **Project folder** pointing at the directory
you actually need rather than everything you can reach.

The real fixes are upstream: MGB supporting `pivot_root` on compute nodes, or Anthropic supporting a
sandbox backend that works on stateless HPC nodes. Neither has been raised yet.

## Shared install

The lab keeps the binary at `/data/vazquez/ondemand/claude-science/` (group-readable):
`claude-science`, the 136 MB single-file binary, v0.1.50.

`bin/` alongside it holds `bwrap` (bubblewrap 0.11.0, built from source — EL9 ships only 0.6.3) and
`socat`, both of which the sandbox would need. They are kept for the day the sandbox becomes usable,
but the app does not put them on `PATH` and does not need them: with `--dangerously-no-sandbox` the
daemon starts with neither on `PATH` (verified).

## Reverse proxy

`--base-path` makes the UI generate its URLs under the proxy prefix while the daemon still answers at
`/`, so it needs a **prefix-stripping** endpoint. OnDemand's `/node/...` does *not* strip (which is why
`tensorboard` and `mlflow` in this repo use `--path_prefix` / `--static-prefix`); `/rnode/...` does.

The app is fixed to `rnode`, confirmed working on the MGB portal by a real sign-in. It is not a form
field: `node` would leave the daemon 404ing on its own assets, so offering the choice would only mean
offering a broken one. If MGB ever drops the `rnode` endpoint, change `proxy_path` in
`template/before.sh.erb` — it is carried to `view.html.erb` through `conn_params`, so that one line is
the only place it is set.

`--allow-origin https://openondemand.research.mgb.org` is passed so the portal's origin clears the
CSRF/WebSocket gate; without it sign-in, writes and the live connection are refused.

## Sign-in

Sign-in links are **single-use and expire in ~3 minutes**, so one generated at job start would be stale
before anyone clicks Connect. While the session runs, `script.sh` writes a fresh nonce every 60 s to
`~/.cache/<node>/claude_science_nonce.txt`, and `view.html.erb` reads it each time the Sessions page
renders. If a link is rejected, reload the Sessions page and click Connect again.

## Network behaviour on Nucleus

Measured from `erishpc-compute-038`, and worth knowing before you read too much into a
failed connector:

| Host | 6 requests back-to-back | Spaced 15 s apart |
|---|---|---|
| `api.anthropic.com` | 2/6 | **5/6** |
| `prefix.dev` | 1–3/4 | **3/3** |
| `conda.anaconda.org` | 0/6 | **0/3** |
| `repo.anaconda.com` | 0/6 | **0/3** |

Two separate things:

- **Egress is connection-rate limited, not broken.** Ordinary use is fine — the difference
  between the two columns is entirely the rate of connection attempts. Rapid bursts get
  dropped, which is why a naive `curl` loop makes the network look far worse than it is.
- **Only the Anaconda hosts are genuinely blocked**, failing even when spaced. `prefix.dev`
  works, and the lab `~/.condarc` already sets `channel_alias: https://prefix.dev/`, so conda
  operations that do not pin `anaconda.org` still resolve.

The practical consequence: **on a cold first launch, expect some of the 24 MCP connectors to
fail**. The daemon starts them simultaneously, which is exactly the burst pattern the limiter
drops — typically the network-dependent ones (`pubmed`, `clinical-trials`, `biorxiv`) time out
at 60 s. Later launches reuse the cached conda environments and fare better. Relaunching is a
reasonable response; the app is usable with the remaining connectors in the meantime.

Two things that sound plausible but are **not** the cause, both checked: IPv6 preference
(forcing IPv4 made reachability *worse*, 1/6 vs 2/6) and per-node variation (all four
`interactive` nodes behave alike, so excluding nodes does not help). The daemon's own
`micromamba execution blocked (Santa/Gatekeeper/AppArmor?)` message is macOS-oriented
boilerplate and misleading here — nothing is blocking the binary; it is the conda downloads
behind it that fail.

## Known limitations

- **HTML previews are not reachable through OnDemand.** Claude Science serves previews on a second port,
  and it binds that one to `127.0.0.1` regardless of `--host` — verified with `ss`. Only the main app
  port is exposed.
- **HTML previews** remain the one confirmed gap (above). The proxy path itself is now verified:
  a real portal launch signed in successfully through `/rnode`, which confirms the prefix is
  stripped as `--base-path` requires and that `--allow-origin` clears the CSRF gate.

## Verified

End to end from the portal, sandbox disabled: the job starts, the daemon comes up on the compute
node, the Connect button signs in through `/rnode`, and the UI is usable. With the sandbox
required, the job exits with the explanatory error above.

The sandbox-required path was removed after being verified to behave correctly (clean error, exit 1,
no half-started daemon) — it was simply never a usable mode on this cluster.

Two bugs found by real launches that `srun` testing had missed:

- `template/script.sh.erb` was committed **644**. OnDemand execs the staged script directly and
  preserves the mode, so the job died with `Permission denied` before the launcher ran. Every
  other app in this repo tracks it 755. Testing via `bash script.sh` ignores the exec bit, which
  is why it slipped through.
- The keep-alive loop polled `claude-science status` every 60 s. The daemon spends ~40 s warming
  MCP connectors and can report `running:false` while busy, so one false negative ended the loop
  and killed the job ~100 s in — seconds after the user had signed in. It now reads the daemon
  pid once and holds the job open on `kill -0`.
