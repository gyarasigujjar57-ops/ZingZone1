# Zing Zone — Free AI Worker

This is a no-Firebase-Blaze alternative for the Zing AI text-chat backend. It uses the Cloudflare Workers AI binding and does not require a Gemini API key or Firebase Functions.

## Deploy on the free tier
1. Sign in/create a Cloudflare account and open Workers & Pages.
2. Create a Worker named `zingzone-ai`.
3. Copy `worker/src/index.js` into its editor and deploy.
4. In Worker settings, add a Workers AI binding named exactly `AI`.
5. Test the deployed `.workers.dev` endpoint with a POST JSON body:
```json
{"messages":[{"role":"user","text":"Rajasthan domicile form ke documents batao"}]}
```
Expected response shape: `{"answer":"..."}`.

Cloudflare controls free-tier model availability and quotas; these can change.

## Status and limitations
Adding these source files does not deploy the Worker or connect the Android app automatically. The deployed `.workers.dev` URL must be configured in the app before it can call this backend. Do not put API secrets in Flutter. This Worker currently handles text chat only: portal automation, OCR/PDF parsing, and form-field filling require separate integrations. OTP, CAPTCHA, payment, and final submission must remain under the user's control.
