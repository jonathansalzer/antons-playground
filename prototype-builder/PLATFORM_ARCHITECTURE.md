# Prototype Builder Platform Architecture

## Overview

The prototype-builder platform hosts many small apps on the same VPS as OpenClaw.

Each app:
- lives in `~/antons-playground/apps/<app-name>`
- runs in its own container or compose project
- is routed through a shared reverse proxy
- is reachable at `<app-name>.carbon.jonathansalzer.com`
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
    scripts/
      register-app.sh
      deploy-app.sh
      smoke-test.sh
    templates/
      web-app/
```

## Routing Model

- DNS wildcard `*.carbon.jonathansalzer.com` points to the VPS.
- Caddy terminates TLS and routes by hostname.
- Each app is reachable internally by service name and port on a shared docker network.
- Example:
  - `habit.carbon.jonathansalzer.com` -> `habit:3000`
  - `timer.carbon.jonathansalzer.com` -> `timer:8080`

## App Metadata

Each app should include a `carbon.yml` file similar to:

```yaml
name: myapp
domain: myapp.carbon.jonathansalzer.com
visibility: private
port: 3000
healthcheck: /
stack: vite-react
```

## Visibility Modes

### Private
Default mode.

Intended behavior:
- app is for Jonathan's use over Tailscale
- app should not be openly reachable from the public internet by default
- deployment flow should assume private unless the request explicitly says public

### Public
Explicit opt-in.

Intended behavior:
- app is reachable from the public internet
- reverse proxy exposes it normally with TLS

## Important Design Constraint

Using a public DNS name alone does not make an app truly private. Private-mode apps therefore need a deliberate protection layer.

Recommended implementation approaches to evaluate during build:

1. Proxy-level access control for private apps
2. Only publishing public routes in the main proxy
3. Separate private and public entrypoints

The final implementation should prioritize safety over convenience and avoid accidental public exposure.

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
