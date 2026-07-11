# devstack

Global launcher for multi-repo local dev stacks. You register a project once
— its services, where they live, and how each one is run (`docker compose`,
`yarn`, `pnpm`, `poetry`, or any custom command) — and from then on boot the
whole thing from anywhere with one command:

```bash
devstack run lawial
```

Each service gets its own tmux pane (its actual live output — docker compose
logs, Vite/webpack output, whatever it prints), started in the order you
registered them, each one waited on before the next starts if you gave it a
port. A shared Dozzle container gives a web-based view of every project's
docker logs regardless of which one is currently running.

## Install

```bash
git clone git@github.com:Carlstain/devstack.git ~/tools/devstack
~/tools/devstack/install.sh
```

This symlinks `devstack` onto `~/.local/bin`, wires up shell completion (see
below), and checks for `docker` (required) and `tmux` (optional — `run` falls
back to a sequential, no-split-panes mode without it).

## Shell completion

`install.sh` adds a sourcing line to `~/.bashrc` and/or `~/.zshrc` (whichever
exist) — open a new shell afterward and `devstack <TAB>` completes
subcommands, `devstack run <TAB>` completes registered project names (pulled
live from the registry), and `devstack infra <TAB>` completes `up`/`down`.
The scripts live in `completions/` if you want to source them manually
instead.

## Commands

```bash
devstack register <project>   # interactive: add services one at a time
devstack edit <project>       # open the raw config in $EDITOR
devstack list                 # show every registered project + live up/down status
devstack run <project>        # boot it: one tmux pane per service, in order
devstack down <project>       # tear down its docker-compose services, kill the tmux session
devstack infra up / down      # manage the shared Dozzle log viewer directly
```

### `register` walks you through each service

For every service it asks:
- **name** (e.g. `back`, `front`, `keycloak`)
- **path** — must already exist
- **how it's run** — `docker-compose`, `yarn`, `pnpm`, `npm`, `poetry`, or `custom`,
  with follow-up questions specific to that choice (compose project name,
  script name, the command to run, etc.)
- **port** to wait on before starting the next service (optional — leave blank
  for a service with nothing to poll, e.g. a background worker)

Register in the order services should start. Run it again on an already-registered
project to add more services, or start over from scratch.

### Editing later

`devstack edit <project>` opens just that project's config (not the whole
registry) as JSON in `$EDITOR` and validates it on save. You can also edit
`~/.config/devstack/registry.json` directly — it's plain JSON, one entry per
project.

## What `run` actually does

0. If another registered project already has something running (checked by
   port and, for docker-compose services, by whether its compose project has
   containers up), it asks what to do: stop the other one first, keep it
   running and start this one too, or cancel. Skipped entirely if nothing
   else is running, and auto-continues (leaving the other one running) when
   stdin isn't a terminal.
1. Makes sure the shared Dozzle container is running
   (`infra/docker-compose.yml`, published at http://localhost:9999 — shows
   live logs for every container on the machine, grouped by compose project).
2. Creates the project's shared docker network if it declared one.
3. Opens (or reattaches to) a tmux session named `devstack-<project>`, adding
   one pane per service in registration order:
   - `docker-compose` services: `up -d --build` then `logs -f` in the same pane
   - everything else: the service's actual run command, directly, in the foreground
   - if the service has a port, `run` polls it before moving on to the next one
4. Attaches you to that session if run from an interactive terminal.

If `tmux` isn't installed, services start sequentially with output logged to
files under the system temp dir instead of panes, and the last service (if
it's not a `docker-compose` one) runs directly in your terminal.

## Where things live

- **Code** (this repo): `~/tools/devstack` (or wherever you clone it).
- **Runtime state** (not in git): `~/.config/devstack/registry.json` — the
  project → services config that every command reads/writes.

See `CLAUDE.md` for the internals if you're editing this tool with Claude Code.
