# Zing Zone – Step 1 AI Foundation

Updated: 2026-11-09

## Implemented in this branch
- Flutter chat uses a dedicated Cloudflare AI service client.
- Selected JPG, PNG or WEBP images are sent to the Worker for Gemini image understanding (5 MB client-side limit); OCR text remains user-reviewed before sending. Image-only questions can still be sent if local OCR finds no readable text.
- Language preference persists locally and syncs to the signed-in user's profile where Firestore is available. The selector includes Hindi-English mode and India's 22 scheduled languages; actual response quality varies by model support.
- Basic Master Profile fields (display name, state, district) persist locally and sync for signed-in users. Sensitive identity numbers are not collected in this Step 1 profile.
- Signed-in users sync the current chat and archived chats to their own Firestore user path; Guest Mode retains local history and drafts.
- Form-related messages are recorded in a local AI Task Center.
- Worker source adds language/profile context, image input, intent classification, bounded payload sizes and explicit capability limits.
- Worker source uses current Gemini 3.x model IDs, with fallback.
- CI workflow is enabled for this implementation branch.

## Not claimed as complete
- Cloudflare Worker `zing-zone-ai` was updated through the Cloudflare API on 2026-11-09 at 18:08:08 UTC (deployment/version `e6d20276-89ba-4f83-aff4-30ae2304c278`). The `GEMINI_API_KEY` secret binding was confirmed present without reading its value. A live end-to-end request from this environment could not be completed; CI smoke verification is still pending.
- Firestore sync requires the correct Firebase project configuration, signed-in account and deployed Firestore rules. Guest data remains local.
- This branch does not provide server-side Firebase token verification, App Check enforcement, distributed rate limiting, push notifications, live website automation, advanced OCR, eligibility decisions or document vault storage.
- Firebase Firestore rules in this branch have not yet been deployed to the Firebase project. Until deployment, cloud profile/chat writes may be rejected; local Guest Mode remains available.
- APK build success alone does not prove live AI, image understanding, Firestore sync or all languages on a physical phone.

## Verification
The branch CI workflow runs Flutter analysis/tests, Worker unit tests, live Worker health/chat smoke test and release APK build. The live smoke test targets the currently deployed Worker, which may differ from GitHub source until deployment.
