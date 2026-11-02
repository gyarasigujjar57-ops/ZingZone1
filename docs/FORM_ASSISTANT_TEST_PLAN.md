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
- Document OCR and cross-document identity matching inside the form workflow.
- Eligibility checking against current official recruitment/scheme rules.
- Image crop, background removal, signature/thumb processing and portal-specific image resizing.
- Android system-wide floating overlay above other apps.
- Universal handling of custom controls, multi-step forms, shadow DOM, iframes, anti-bot checks or portals that block WebView/JavaScript.
- Real-device tests and real government-portal tests.

## Safety and correctness
A successful APK build is not proof that a real application can be completed. Do not use this assistant to submit an application without a human review. Never automate OTP, CAPTCHA, biometrics, payments or final submission. If a field's meaning or source document is uncertain, leave it empty and ask the user.
