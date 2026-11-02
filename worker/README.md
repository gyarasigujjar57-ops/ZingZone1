# Zing Zone Cloudflare AI Worker

This is the live AI backend used by the Zing Zone Android app.

## Configuration
- Worker name: `zing-zone-ai`
- Provider: Google Gemini API
- Secret binding: `GEMINI_API_KEY` (stored in Cloudflare; never put the key in Flutter or GitHub)
- App endpoint: `https://zing-zone-ai.gyarasigujjar57.workers.dev`

## API
- `GET /` returns a health/configuration response.
- `POST /` accepts `{"messages":[{"role":"user","text":"..."}]}` and returns `{"answer":"..."}`.
- An optional `image` object accepts base64 `image/jpeg`, `image/png`, or `image/webp` data. The image is attached to the latest user message for Gemini vision/document reading.
- Text-only form guidance and draft field-value suggestions use the same Worker endpoint.

## Deploy
The Wrangler configuration is `worker/wrangler.toml`. Deploy the Worker named `zing-zone-ai` and retain the existing `GEMINI_API_KEY` secret binding.

## Current limits
- The Android Live Form panel opens an HTTPS portal in an in-app WebView, reads visible labels and ordinary controls, and lets the user review draft values before filling.
- It currently fills ordinary text, select, and textarea fields only.
- PDF upload/OCR is not yet implemented in the Android app.
- OTP, passwords, CAPTCHA, file uploads, checkboxes/radios, payments, consent, and final submission remain user-controlled.
- Government portals may block WebView access or use controls that cannot be inspected/fill reliably.
- The public Worker endpoint needs production abuse/rate-limit protection before broad public release.

A successful Worker test proves the backend route tested in that workflow; it does not prove Android device integration or compatibility with every portal.
