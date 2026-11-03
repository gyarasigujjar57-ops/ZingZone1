# Zing Zone Cloudflare AI Worker

This Worker exposes a `POST` endpoint returning `{"answer":"..."}` for Zing Zone's existing chat client. It uses the Cloudflare Workers AI binding; no Gemini API key is embedded in the app or this source file.

## Deploy

1. Sign in to the Cloudflare dashboard and open **Workers & Pages**.
2. Create a Worker named `zing-zone-ai`.
3. Deploy the code from `src/index.js` (or deploy this folder using Wrangler from a computer with Wrangler installed).
4. In the Worker settings, enable/bind **Workers AI** with binding name `AI`. If deploying with the included `wrangler.toml`, the binding is declared there.
5. Deploy and copy the real HTTPS Worker URL, usually ending in `.workers.dev`.
6. In the Zing Zone app, open **Profile/Settings → ZING AI SERVER → Free Cloudflare AI server**, paste that deployed HTTPS URL, and save.
7. Test chat with `Namaste, apna parichay do`. The Worker URL must be deployed and the Workers AI account must have available quota.

## Important

- Adding this source code to GitHub does **not** deploy the Worker or connect a phone automatically.
- Do not put API keys, account tokens, or passwords in the app or in this file.
- This endpoint is publicly reachable. Before a public production launch, add abuse protection/rate limiting and review Cloudflare account usage limits.
- The existing app currently uses the saved Worker URL for text-only chat; image/document messages use the Firebase AI Logic path instead.
