# Zing Zone

Flutter Android citizen-services and AI assistant application.

See [Step 1 implementation status](docs/IMPLEMENTATION_STATUS.md). The Cloudflare Worker is the AI gateway. Keep Gemini API keys in Cloudflare Worker secrets; never put them in Flutter source or public GitHub files.

Required Worker secret: `GEMINI_API_KEY`.

Step 1 adds multilingual chat preference, basic Master Profile, signed-in Firestore chat sync, local Guest Mode history/drafts/tasks, and image-capable AI request support in source. The updated Worker source was deployed on 2026-11-09; CI and physical-device verification are still pending.

Live browser automation, expanded OCR/document intelligence, eligibility decisions and official portal automation are not claimed as active in Step 1.
