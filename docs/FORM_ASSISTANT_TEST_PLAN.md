# Zing Zone Form Assistant — Test Plan and Current Limits

## Changes in this revision
- Improve visible form-field labels using associated labels, ARIA labels, placeholders, titles, fieldset legends, names and IDs.
- Capture form metadata useful for matching: autocomplete, pattern, max length, min/max, owning form and select options.
- Give the AI explicit rules to distinguish applicant, father, mother and guardian names; DOB versus issue date; permanent versus correspondence address; qualification versus marks; and photo/signature/thumb fields.
- Leave ambiguous or unknown values blank rather than guessing.
- Before autofill, reject values that do not match an enabled select option, exceed max length, fail basic email format, or fall outside numeric min/max.
- Continue to exclude password, hidden, file, submit, button, reset, checkbox, radio and image input types from ordinary autofill.
- Autofill does not submit the form.

## Required manual test before any real application
1. Open a harmless test form, not a live application.
2. Confirm labels and field types are detected correctly.
3. Provide deliberately distinct test facts: applicant name, father's name, date of birth, qualification, marks and address.
4. Confirm each suggestion is mapped to the matching field; ambiguous fields must remain blank.
5. Test a select field with one valid option and one invalid value. Invalid values must not be filled.
6. Test email, numeric bounds and max-length rejection.
7. Confirm checkbox/radio, file upload, password, OTP, CAPTCHA and submit controls are never changed.
8. Reload the page and verify no form was submitted automatically.

## Not implemented / not verified
- A general-purpose all-India portal catalogue and reliable portal-specific adapters.
- On-device OCR for a user-selected image is now wired for Latin and Devanagari text; the text is shown in the AI field-preparation dialog for user review. OCR accuracy, multi-page PDF support, and cross-document identity reconciliation remain unverified/not implemented.
- A preliminary eligibility comparison button now compares user-confirmed facts against the visible page text only. It is not a live official-rules database and must not be treated as an official eligibility decision.
- Image cropping and JPEG compression are wired for chat images and document OCR. Automatic background removal, signature/thumb-specific processing, portal-specific pixel/file-size presets and end-to-end image upload remain unimplemented.
- Android system-wide floating overlay above other apps is not implemented; the current live form runs inside the app's WebView panel.
- Portal-specific adapters for individual government sites are not implemented. Universal handling of custom controls, multi-step forms, shadow DOM, iframes, anti-bot checks or portals that block WebView/JavaScript is not supported.
- Real-device tests and real government-portal tests remain required.

## Safety and correctness
A successful APK build is not proof that a real application can be completed. Do not use this assistant to submit an application without a human review. Never automate OTP, CAPTCHA, biometrics, payments or final submission. If a field's meaning or source document is uncertain, leave it empty and ask the user.


## Latest implementation additions (2026-11-02)
- Added `image_cropper` for manual crop/rotate and compressed JPEG output.
- Added on-device ML Kit text recognition for Latin and Devanagari, with a user review step before sending extracted text to Gemini.
- Added a preliminary eligibility comparison against the currently visible official notice text, with explicit unknowns and no invented rules.
- These changes still require a successful APK build and manual phone tests before they can be considered working in production.
