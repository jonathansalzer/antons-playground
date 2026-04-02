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

## Recommended Stack

- Reverse proxy: Caddy
- Runtime: Docker Compose
- Shared network: `carbon_apps`
- Per-app metadata file: `carbon.yml`

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

### Public apps
- DNS wildcard `*.carbon.jonathansalzer.com` points to the VPS.
- Caddy terminates TLS and routes by hostname.
- Public apps are reachable at:
  - `https://<app>.carbon.jonathansalzer.com`

Examples:
- `https://habit.carbon.jonathansalzer.com`
- `https://timer.carbon.jonathansalzer.com`

### Private apps
- Private apps are not given public-facing subdomains.
- They are routed by path on the VPS Tailscale hostname.
- Private apps are reachable at:
  - `https://<vps-name>.ts.net/<app>`

Examples:
- `https://anton-vps.tail1234.ts.net/habit`
- `https://anton-vps.tail1234.ts.net/timer`

Generated private Caddy routes use `handle_path` so the app prefix is stripped before proxying to the container.

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

## Current Scaffold Status

- public apps render into `platform/caddy/sites/public/*.caddy`
- private apps render into `platform/caddy/sites/private/*.caddy`
- `render-route.sh` generates host-based routes for public apps and path-based Tailscale routes for private apps
- `smoke-test.sh` resolves the correct target URL based on visibility
- starter template defaults to `visibility: private`

## Deployment Flow

For each generated app:
1. Create app folder
2. Scaffold app
3. Add Dockerfile / compose config
4. Add `carbon.yml`
5. Join shared docker network
6. Register reverse proxy route
7. Deploy container
8. Run smoke tests
9. Report URL and visibility

## Operational Defaults

- small, boring stacks
- one service unless multiple are clearly needed
- SQLite/file storage before heavy databases
- mobile-friendly UI by default
- health endpoint when useful
- explicit visibility field per app
- private-first routing model
