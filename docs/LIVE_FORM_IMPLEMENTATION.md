# Zing Zone Live Form panel

## Added in feature/live-form-chat-panel

- Chat detects form-related requests and opens a live form panel over the chat.
- The panel accepts an HTTPS URL, opens the website inside the app, and can inspect visible form controls.
- The user can review selected values before filling ordinary text/select/textarea fields.
- The panel can send visible page text and detected field labels to the configured Cloudflare Worker for AI guidance; if no Worker URL is configured, it uses Firebase AI Logic.
- Passwords, hidden/file inputs, checkboxes/radios, submit controls, OTP, CAPTCHA, payment and final submission are deliberately excluded from auto-fill.

## Important limitations

- This is an in-app WebView assistant, not a universal server-side browser robot. Some sites block WebView or JavaScript inspection, require an external browser, or use controls that cannot be reliably automated.
- The app does not automatically know a user's identity details or upload their documents yet.
- The Cloudflare Worker must still be deployed and its HTTPS URL saved in Settings. Committing Worker source is not deployment.
- Firebase AI Logic requires the project's AI setup and quota. Device-side testing is still required for authentication, WebView behavior, and each target portal.
- Before public production, restrict the Worker with rate limits/abuse controls and review portal terms and privacy requirements.
