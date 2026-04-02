# starter-web-app

Minimal starter template for a small static prototype app.

## What you should customize

- `carbon.yml`
- `public/index.html`
- service name in `compose.yml`

## Routing model

### Private mode
Default private URL pattern:
- `https://<your-vps>.ts.net/<app>`

Example:
- `https://anton-vps.tail1234.ts.net/starter-web-app`

### Public mode
If you switch `visibility` to `public`, the app should be routed at:
- `https://starter-web-app.carbon.jonathansalzer.com`

## Local run

```sh
docker compose up --build
```

Then open <http://localhost:8080>.
