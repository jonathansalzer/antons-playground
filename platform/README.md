# Platform

This directory holds the shared conventions for hosting small prototype apps on the same VPS.

## Live deployment model

- apps live in `apps/`
- all app containers join Docker network `carbon_apps`
- private ingress is live today via Tailscale Serve -> `127.0.0.1:18080`
- `platform/private-router/Caddyfile` routes `/<app>` to the correct container
- public Caddy config exists as scaffold, but is not the live path yet

## Layout

```text
platform/
  caddy/                 # public ingress scaffold
  contracts/             # carbon.yml contract
  private-router/        # live private router config
  scripts/               # helper scripts
  templates/
    starter-web-app/
```

## Expected App Contract

Each app should include:

- `carbon.yml` metadata
- `compose.yml` service definition
- `Dockerfile` when building locally
- `README.md`

## Visibility model

- `private` — live now at `https://anton.tail73de9.ts.net/<app>`
- `public` — planned at `https://<app>.carbon.jonathansalzer.com`

Private apps are path-routed on the Tailscale hostname and should work when the prefix is stripped before proxying.

## How to deploy a new private app

1. Copy `platform/templates/starter-web-app/` to `apps/<app-name>/`
2. Set in `carbon.yml`:
   - `slug`
   - `runtime.service`
   - `runtime.internalPort`
   - `domain.privateTailnetHost: anton.tail73de9.ts.net`
   - `routing.privatePathPrefix: /<app-name>`
3. Ensure the app container joins `carbon_apps`
4. Add a route to `platform/private-router/Caddyfile`:
   - `handle_path /<app-name>* { reverse_proxy <service>:<port> }`
5. Start or rebuild the app with `docker compose up -d --build`
6. Regenerate the root landing page with `platform/private-router/render-index.sh`
7. Restart the private router with `docker compose up -d` in `platform/private-router`
8. Verify `https://anton.tail73de9.ts.net/` and `https://anton.tail73de9.ts.net/<app-name>`

## Live example

- app: `apps/starter-web-app`
- URL: `https://anton.tail73de9.ts.net/starter-web-app`

## Notes

- root `/` on the Tailscale host currently belongs to the private router, not OpenClaw
- public Caddy config should be treated as scaffold until public ingress is wired for real
