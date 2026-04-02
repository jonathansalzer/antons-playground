# Prototype Builder Platform Architecture

## Overview

The prototype-builder platform hosts many small apps on the same VPS as OpenClaw.

Each app:
- lives in `~/antons-playground/apps/<app-name>`
- runs in its own container or compose project
- is routed through a shared reverse proxy
- is reachable either publicly or privately depending on visibility
- is private by default
- may optionally be made public

## Current Stack

- Private ingress: Tailscale Serve -> local Caddy router on `127.0.0.1:18080`
- App runtime: Docker Compose
- Shared network: `carbon_apps`
- Per-app metadata file: `carbon.yml`
- Public ingress: Caddy scaffold exists, not yet the live path

## Directory Model

```text
~/antons-playground/
  apps/
    myapp/
      Dockerfile
      compose.yml
      carbon.yml
      README.md
      src/...
  platform/
    caddy/
      Caddyfile
      sites/
        public/
        private/
    contracts/
      carbon.example.yml
      carbon.schema.md
    scripts/
      validate-carbon.sh
      render-route.sh
      register-app.sh
      deploy-app.sh
      smoke-test.sh
    templates/
      starter-web-app/
```

## Routing Model

### Private apps — live now
- Tailscale Serve owns `https://anton.tail73de9.ts.net`
- it forwards to `http://127.0.0.1:18080`
- the local private router uses `handle_path` to map `/<app>` to the app container

Example:
- `https://anton.tail73de9.ts.net/starter-web-app`

### Public apps — next layer
- intended public URL: `https://<app>.carbon.jonathansalzer.com`
- public Caddy routing remains scaffolded in-repo, but is not the current live ingress

## App Metadata

Each app should include a `carbon.yml` file with fields like:

```yaml
version: 1
name: myapp
slug: myapp
stack: vite-react
visibility: private

domain:
  publicHost: myapp.carbon.jonathansalzer.com
  privateTailnetHost: anton-vps.tail1234.ts.net

runtime:
  service: myapp
  internalPort: 3000
  healthcheckPath: /
  docker:
    composeFile: compose.yml
    dockerfile: Dockerfile
    network: carbon_apps

routing:
  privatePathPrefix: /myapp
  stripPrefix: true
```

## Visibility Modes

### Private
Default mode.

Intended behavior:
- app is for Jonathan's use over Tailscale
- app is reached via the VPS MagicDNS host and a path prefix
- deployment flow should assume private unless the request explicitly says public

### Public
Explicit opt-in.

Intended behavior:
- app is reachable from the public internet
- reverse proxy exposes it normally with TLS at `<app>.carbon.jonathansalzer.com`

## Current live status

- live private router config: `platform/private-router/Caddyfile`
- live private ingress host: `anton.tail73de9.ts.net`
- starter proof app: `apps/starter-web-app`
- public route generation under `platform/caddy/` remains scaffold-only for now
- starter template defaults to `visibility: private`

## Deployment Flow

For each new private app:
1. Create `apps/<app-name>/`
2. Add `Dockerfile`, `compose.yml`, and `carbon.yml`
3. Join shared Docker network `carbon_apps`
4. Add `handle_path /<app>* { reverse_proxy <service>:<port> }` to `platform/private-router/Caddyfile`
5. Run `docker compose up -d --build` in the app folder
6. Run `docker compose up -d` in `platform/private-router`
7. Verify `https://anton.tail73de9.ts.net/<app>`
8. Report URL, stack, and visibility

## Operational Defaults

- small, boring stacks
- one service unless multiple are clearly needed
- SQLite/file storage before heavy databases
- mobile-friendly UI by default
- health endpoint when useful
- explicit visibility field per app
- private-first routing model
