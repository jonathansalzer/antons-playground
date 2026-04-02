# `carbon.yml` Schema Guide

This repo uses a lightweight human-editable contract instead of a strict JSON Schema for now.

## Required fields

| Field | Type | Meaning |
| --- | --- | --- |
| `version` | integer | Contract version. Start with `1`. |
| `name` | string | Human-readable app name. |
| `slug` | string | URL-safe app identifier and default service name. |
| `stack` | string | Coarse stack label like `static-html`, `vite-react`, `nextjs`, `node-express`. |
| `visibility` | string | `private` or `public`. |
| `runtime.service` | string | Docker Compose service name exposed to Caddy. |
| `runtime.internalPort` | integer | Port Caddy should reverse proxy to. |
| `runtime.healthcheckPath` | string | Path used for smoke checks, usually `/`. |

## Optional fields

- `owner`
- `domain.publicHost`
- `domain.publicBaseDomain`
- `domain.privateTailnetHost`
- `runtime.docker.composeFile`
- `runtime.docker.dockerfile`
- `runtime.docker.network`
- `routing.privatePathPrefix`
- `routing.stripPrefix`
- `routing.tls`
- `privacy.mode`
- `privacy.note`
- `build.install`
- `build.build`
- `build.run`
- `metadata.description`
- `metadata.tags`

## Visibility semantics

### `private`
Default mode.

Use this for internal tools and prototypes that should only be reachable over Tailscale.
Private apps should be routed at:
- `https://<vps-name>.ts.net/<app>`

Private routes are path-based rather than subdomain-based.

### `public`
Use only when the app is intentionally internet-accessible.
Public apps should be routed at:
- `https://<slug>.carbon.jonathansalzer.com`

## Naming rules

- `slug` should be lowercase letters, numbers, and hyphens only.
- `runtime.service` should normally match `slug`.
- `domain.publicHost` should normally be `<slug>.carbon.jonathansalzer.com`.
- `routing.privatePathPrefix` should normally be `/<slug>`.

## Minimal example

```yaml
version: 1
name: Tiny Notes
slug: tiny-notes
stack: vite-react
visibility: private

domain:
  publicHost: tiny-notes.carbon.jonathansalzer.com
  privateTailnetHost: anton-vps.tail1234.ts.net

runtime:
  service: tiny-notes
  internalPort: 3000
  healthcheckPath: /
  docker:
    composeFile: compose.yml
    dockerfile: Dockerfile
    network: carbon_apps

routing:
  privatePathPrefix: /tiny-notes
  stripPrefix: true
```
