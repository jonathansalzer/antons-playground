# Private Router

This is the live private ingress for prototype apps.

## Current behavior

- Tailscale Serve target: `http://127.0.0.1:18080`
- container: `carbon-private-router`
- config file: `platform/private-router/Caddyfile`
- private hostname: `https://anton.tail73de9.ts.net`

## Add a new private app

Add a route:

```caddy
handle_path /myapp* {
  reverse_proxy myapp:3000
}
```

Rules:
- route path should match `routing.privatePathPrefix` in the app's `carbon.yml`
- upstream service name should match the Docker Compose service/container on `carbon_apps`
- use `handle_path` so `/myapp` is stripped before proxying

## Reload

```sh
cd ~/antons-playground/platform/private-router
docker compose up -d
```

## Verify

```sh
curl -i http://127.0.0.1:18080/myapp/
```

Expected external URL:

```text
https://anton.tail73de9.ts.net/myapp
```
