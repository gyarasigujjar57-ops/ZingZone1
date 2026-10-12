# Zing Zone implementation status

Last updated: 2026-10-12

## Current app status
- Flutter UI exists for Welcome, Chat, Store, Rewards, Profile, settings, notifications, Premium, tokens and wallet.
- The current Chat response is still demo text; this does not yet call the backend.
- Mobile OTP and Google sign-in UI are not yet connected to real Firebase Authentication.
- Store catalog/cart/wishlist are currently local/demo data; there is no live merchant catalogue or affiliate attribution yet.
- Wallet, tokens, rewards and Premium are not live financial services.
- Operator workspace, customer isolation and official-portal integrations are not yet complete.

## Added in this integration step
- `firestore.rules`: deny-by-default rules with user-scoped reads and no client writes to wallet/token/reward ledgers.
- `functions/`: authenticated Firebase callable function scaffold for Gemini chat. The API key is intended to be stored as a Firebase Functions secret, never in Flutter source.
- The Flutter client still needs to call `askZingAI`; creating the function source alone does not activate AI in the app.

## Required setup before live AI works
1. Deploy Firestore rules.
2. Set the Gemini key as a Functions secret using the Firebase CLI: `firebase functions:secrets:set GEMINI_API_KEY`. Enter the key only in the CLI prompt, never in chat or GitHub source.
3. Deploy Cloud Functions. Firebase may require the Blaze billing plan for Cloud Functions deployment; check the project's current billing requirements before enabling billing.
4. Connect the Flutter Chat UI to the callable function and test with a signed-in account.
5. Configure Firebase Phone/Google sign-in fully, including OAuth/SHA configuration as required by Android, and test on a real device.

## Security and product notes
- Do not publish open Firestore rules.
- Never trust client-submitted wallet balances, token balances, rewards, purchases, or payout status.
- Government form automation must respect portal terms and stop for OTP, CAPTCHA, biometric checks, payments and final legal submission.
- Real-money rewards, prize pools, ads and payouts require legal and platform-policy review before activation.
- Passing an APK build is not proof that these live integrations work.
