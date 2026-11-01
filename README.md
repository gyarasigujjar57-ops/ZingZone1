# ZingZone1

AI chat backend: Cloudflare Worker `zing-zone-ai` proxies requests to Gemini. The app uses the Worker HTTPS endpoint for text chat.

## APK build

GitHub Actions builds the Android release APK on pushes to `feature/live-form-chat-panel` or `main`. The artifact is named `zing-zone-release-apk`.

## Live AI status

A successful APK build verifies the Android package, not the external Gemini API. The Worker must separately pass the live chat test before the app can return AI answers.
