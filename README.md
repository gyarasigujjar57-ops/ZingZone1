# Zing Zone

Zing Zone is a Flutter Android prototype with Firebase sign-in, AI chat, and an in-app Live Form panel.

## Backend
- Cloudflare Worker: `https://zing-zone-ai.gyarasigujjar57.workers.dev`
- AI provider: Gemini API via the Cloudflare secret binding `GEMINI_API_KEY`.
- Live Worker health, text reply, and image OCR tests passed in GitHub Actions on 2026-11-02.

## Live Form scope
The current feature branch can open an HTTPS website in an in-app WebView, inspect visible page labels and normal controls, ask the AI for draft values, and fill selected ordinary fields after user review. It does not submit forms. OTP, passwords, CAPTCHA, payments, consent and final submission stay with the user.

PDF upload/OCR, external floating overlay, broad portal compatibility, cloud-synced history, real Store payments and wallet payouts are not yet verified.

## Development
- Flutter APK workflow: `.github/workflows/build-apk.yml`
- Worker source: `worker/src/index.js`
- Worker config: `worker/wrangler.toml`
- Current detailed status: `docs/IMPLEMENTATION_STATUS.md`

Do not treat a green CI run as proof of real-device behavior. Test sign-in, text chat, image reading and each target portal on an Android device before release.
