# Anton's Playground

A repo for small isolated apps and the shared platform that hosts them.

## Purpose

This repository is for building and hosting many small apps on one VPS.

Rules of the road:
- each app lives in its own folder under `apps/`
- optimize for fast prototypes and useful internal tools
- Dockerize apps where it makes sense
- keep deployments consistent
- default to private access unless an app is intentionally made public

## Layout

```text
antons-playground/
  apps/
  platform/
    caddy/
    contracts/
    scripts/
    templates/
  prototype-builder/
```

## Platform

The shared platform lives under `platform/`.

Key pieces:
- `platform/contracts/` — per-app metadata contract (`carbon.yml`)
- `platform/scripts/` — validation, route rendering, deploy, and smoke-test helpers
- `platform/templates/starter-web-app/` — minimal app template
- `platform/private-router/` — live private ingress for Tailscale path routing
- `platform/caddy/` — public ingress scaffold for future public apps

Current live model:
1. app lives in `apps/<app-name>/`
2. app joins Docker network `carbon_apps`
3. private apps are routed by `platform/private-router/Caddyfile`
4. Tailscale Serve points to `http://127.0.0.1:18080`
5. the private router forwards `/<app>` to the app container

## Routing Model

### Private apps — live now
- `https://anton.tail73de9.ts.net/<app>`
- Tailscale Serve forwards to `http://127.0.0.1:18080`
- `platform/private-router/Caddyfile` strips the prefix and proxies to the app container

Example:
- `https://anton.tail73de9.ts.net/starter-web-app`

### Public apps — scaffolded, not yet live
- `https://<app>.carbon.jonathansalzer.com`
- intended to be handled by Caddy on the public side

## Prototype Builder System

The prototype-builder system is intended to turn rough app ideas into working MVPs with very little back-and-forth.

### Goals

- User gives an app or tool idea in chat
- Agent asks at most 1-2 short clarification rounds if needed
- Agent then builds the app without requiring more hand-holding
- Apps live in `~/antons-playground/apps/<app-name>`
- Public apps get `https://<app>.carbon.jonathansalzer.com`
- Private apps get `https://<vps-name>.ts.net/<app>`
- Apps are private by default for Tailscale use
- Selected apps can be made public on the internet

### Hosting Model

- Same VPS as OpenClaw
- Shared reverse proxy for multi-app routing
- Dockerized apps where sensible
- One shared deployment convention
- One visibility setting per app: `private` or `public`

### Current deployment contract

- private-first
- app folder: `apps/<app-name>/`
- shared Docker network: `carbon_apps`
- app metadata: `carbon.yml`
- private router target: service name on `carbon_apps`
- private ingress host: `anton.tail73de9.ts.net`

### Documents

- `prototype-builder/PLAN.md`
- `prototype-builder/PLATFORM_ARCHITECTURE.md`
- `prototype-builder/AGENT_SPEC.md`

### Agent Behavior

The specialized builder agent should:
- infer sensible defaults
- ask only the minimum necessary questions
- prefer MVPs over polished products
- choose boring, fast-to-ship stacks
- create and deploy apps consistently
- report back with app folder, URL, visibility, stack, and next steps

### Important Default

Apps should be private by default. Public exposure should be an explicit choice per app.
