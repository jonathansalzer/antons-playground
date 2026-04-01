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
  prototype-builder/
```

## Prototype Builder System

The prototype-builder system is intended to turn rough app ideas into working MVPs with very little back-and-forth.

### Goals

- User gives an app or tool idea in chat
- Agent asks at most 1-2 short clarification rounds if needed
- Agent then builds the app without requiring more hand-holding
- Apps live in `~/antons-playground/apps/<app-name>`
- Each app gets `<app-name>.carbon.jonathansalzer.com`
- Apps are private by default for Tailscale use
- Selected apps can be made public on the internet

### Hosting Model

- Same VPS as OpenClaw
- Shared reverse proxy for multi-app routing
- Dockerized apps where sensible
- One shared deployment convention
- One visibility setting per app: `private` or `public`

### Recommended Stack

- Reverse proxy: Caddy
- Runtime: Docker Compose
- Shared network: `carbon_apps`
- Per-app metadata file: `carbon.yml`

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
