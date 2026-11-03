import test from "node:test";
import assert from "node:assert/strict";
import { evaluateFormConfidence } from "../src/form_confidence.js";
import { resolvePortalAdapter } from "../src/portal_adapters.js";

const trustedField = {
  label: "पूरा नाम",
  valuePresent: true,
  labelMatched: true,
  formatValid: true,
  selectOptionMatched: true,
  evidence: [{ kind: "user_confirmed", confirmed: true, confidence: 1, sourceId: "user-confirmation-1" }]
};

test("allows a draft only when every deterministic evidence gate passes", () => {
  const result = evaluateFormConfidence([trustedField]);
  assert.equal(result.results[0].decision, "SAFE_TO_FILL_DRAFT");
  assert.equal(result.mayProceedToReview, true);
});

test("blocks AI-inferred values even when all UI checks pass", () => {
  const result = evaluateFormConfidence([{
    ...trustedField,
    evidence: [{ kind: "ai_inferred", confirmed: true, confidence: 1, sourceId: "model" }]
  }]);
  assert.equal(result.results[0].decision, "NEEDS_USER");
  assert.match(result.results[0].reasons.join(" "), /अनुमान/);
});

test("blocks low-confidence OCR and mismatched select options", () => {
  const ocr = evaluateFormConfidence([{
    ...trustedField,
    evidence: [{ kind: "document_ocr_confirmed", confirmed: true, confidence: 0.90, sourceId: "doc-1" }]
  }]);
  assert.equal(ocr.results[0].decision, "NEEDS_USER");

  const select = evaluateFormConfidence([{ ...trustedField, selectOptionMatched: false }]);
  assert.equal(select.results[0].decision, "NEEDS_USER");
});

test("blocks missing source evidence and malformed requests", () => {
  const missing = evaluateFormConfidence([{ ...trustedField, evidence: [] }]);
  assert.equal(missing.results[0].decision, "BLOCK");
  assert.ok(evaluateFormConfidence([]).error);
});

test("resolves the supported Indian government portal adapters", () => {
  const cases = [
    ["ssc.gov.in", "ssc"],
    ["upsconline.nic.in", "upsc"],
    ["sarathi.parivahan.gov.in", "parivahan"],
    ["incometax.gov.in", "income-tax"],
    ["gst.gov.in", "gst"],
    ["eshram.gov.in", "eshram"],
    ["ncs.gov.in", "national-career-service"],
    ["passportindia.gov.in", "passport-seva"],
    ["digilocker.gov.in", "digilocker"],
    ["voters.eci.gov.in", "election-commission-voter-services"],
    ["rsmssb.rajasthan.gov.in", "rajasthan-staff-selection-board"],
    ["janaadhaar.rajasthan.gov.in", "rajasthan-janaadhaar"],
    ["nrega.nic.in", "mgnrega"],
    ["nfsa.gov.in", "national-food-security"],
    ["serviceonline.gov.in", "service-plus-edistrict"]
  ];
  for (const [host, expected] of cases) {
    assert.equal(resolvePortalAdapter(host)?.id, expected, host);
  }
  assert.equal(resolvePortalAdapter("unknown.gov.in"), null);
  assert.equal(resolvePortalAdapter("fakeparivahan.gov.in"), null);
});
