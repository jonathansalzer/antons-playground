# Platform Scaffold

This directory holds the shared conventions for hosting many small prototype apps from the same VPS.

## Goals

- one folder per app under `apps/`
- one metadata contract per app via `carbon.yml`
- one shared Docker network: `carbon_apps`
- one shared Caddy deployment with generated site snippets
- private-by-default app exposure

## Layout

```text
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
    deploy-app.sh
    register-app.sh
    render-route.sh
    smoke-test.sh
    validate-carbon.sh
  templates/
    starter-web-app/
```

## Expected App Contract

Each app should include:

- `carbon.yml` metadata
- `compose.yml` service definition
- `Dockerfile` when building locally
- `README.md`

## Visibility Model

- `public`: app is routed publicly at `https://<app>.carbon.jonathansalzer.com`
- `private`: app is routed only over Tailscale at `https://<vps-name>.ts.net/<app>`

Private apps are path-routed on the VPS Tailscale hostname instead of getting public-facing subdomains. This keeps the private model simple:
- public apps use normal DNS + TLS via Caddy
- private apps stay on the tailnet and are reachable from Jonathan's phone/computers while connected to Tailscale

The Caddy scaffold expects a `PRIVATE_TAILNET_HOST` value such as `anton-vps.tail1234.ts.net` when rendering private routes.

## Typical Flow

1. Copy `platform/templates/starter-web-app/` into `apps/<app-name>/`
2. Edit app code and `carbon.yml`
3. Run `platform/scripts/deploy-app.sh apps/<app-name>`
4. Review the generated route snippet in `platform/caddy/sites/`
5. Reload or redeploy the shared Caddy service

## URL Model

### Public app example
- `https://timer.carbon.jonathansalzer.com`

### Private app example
- `https://anton-vps.tail1234.ts.net/timer`

Private apps should be built to work behind a path prefix. The generated Caddy routes strip the prefix before proxying to the container.
