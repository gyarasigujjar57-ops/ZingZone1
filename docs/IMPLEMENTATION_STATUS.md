# Zing Zone implementation status

Last updated: 2026-10-12

## Current verified repository state
- Flutter APK build workflow #45 completed successfully for commit `ab32a54ac8368e29e6b00796b4635fa0e80fe4cb`.
- Chat UI now calls the Firebase callable function `askZingAI` in `asia-south1`.
- Google Sign-in and phone SMS OTP flows are wired to Firebase Authentication in the Flutter source.
- These are code integrations only. The live sign-in flows still need device-side testing and correct Firebase/OAuth configuration.
- The callable AI function source exists under `functions/src/index.ts`, but it has not been confirmed deployed; the Gemini secret has not been confirmed set.
- Store catalogue/cart/wishlist still use demo/local data. Wallet, tokens, rewards and Premium are not live financial services.
- Operator workspace, isolated customer sessions, and official portal integrations are not complete.

## Next steps to activate and verify AI
1. Confirm the Firebase project billing plan and current Cloud Functions deployment requirements before enabling billing. Do not enable billing without understanding potential charges.
2. Create/get a Gemini API key through the official Google AI Studio / Google AI API process.
3. Store the key as the Firebase Functions secret `GEMINI_API_KEY`. Never put it in Flutter source, a public GitHub file, or a chat message.
4. Build and deploy the Functions code and Firestore rules using an authenticated Firebase CLI environment.
5. Test `askZingAI` from a signed-in Android account. A successful APK build alone does not prove the function is deployed or callable.
6. Test Phone OTP and Google sign-in on a real Android device; resolve Firebase provider, SHA-1/SHA-256 and OAuth configuration issues if shown.

## Security and product notes
- The callable function currently requires Firebase Authentication, but App Check enforcement is disabled. Before production, add App Check and abuse/rate-limit controls.
- Keep Firestore rules restrictive. Never accept client-submitted wallet balances, token balances, reward grants, purchases or payout status as authoritative.
- Government-form automation must respect portal terms and stop for OTP, CAPTCHA, biometrics, payments and final legal submission.
- Real-money rewards, prize pools, ads and payouts need legal and platform-policy review before activation.
- Passing APK build and tests is not proof that all live integrations work.
