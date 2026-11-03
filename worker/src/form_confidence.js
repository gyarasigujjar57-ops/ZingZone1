const ALLOWED_EVIDENCE = new Set(["user_confirmed", "document_ocr_confirmed", "verified_profile"]);
const BLOCKED_EVIDENCE = new Set(["ai_inferred", "page_existing_value", "unknown"]);

function validEvidence(item) {
  if (!item || typeof item !== "object") return false;
  if (BLOCKED_EVIDENCE.has(item.kind) || !ALLOWED_EVIDENCE.has(item.kind)) return false;
  if (item.confirmed !== true) return false;
  if (typeof item.confidence !== "number" || !Number.isFinite(item.confidence) || item.confidence < 0 || item.confidence > 1) return false;
  if (typeof item.sourceId !== "string" || !item.sourceId.trim() || item.sourceId.length > 120) return false;
  if (item.kind === "user_confirmed") return item.confidence === 1;
  if (item.kind === "document_ocr_confirmed") return item.confidence >= 0.95;
  return item.kind === "verified_profile" && item.confidence >= 0.99;
}

export function evaluateFormConfidence(fields) {
  if (!Array.isArray(fields) || fields.length < 1 || fields.length > 160) {
    return { error: "Form confidence request must contain 1 to 160 fields." };
  }
  const results = fields.map((field, index) => {
    if (!field || typeof field !== "object" ||
        typeof field.label !== "string" || !field.label.trim() || field.label.length > 300 ||
        typeof field.valuePresent !== "boolean" ||
        typeof field.labelMatched !== "boolean" ||
        typeof field.formatValid !== "boolean" ||
        typeof field.selectOptionMatched !== "boolean" ||
        !Array.isArray(field.evidence) || field.evidence.length < 1 || field.evidence.length > 5) {
      return { index, decision: "BLOCK", score: 0, reasons: ["आवश्यक field जाँच अधूरी है।"] };
    }

    const reasons = [];
    const evidence = field.evidence.filter(validEvidence);
    const hasTrustedEvidence = evidence.length > 0;
    const bestEvidence = evidence.reduce((best, item) => Math.max(best, item.confidence), 0);

    if (!field.valuePresent) reasons.push("जानकारी उपलब्ध नहीं है।");
    if (!field.labelMatched) reasons.push("फॉर्म के field का अर्थ पक्का नहीं हुआ।");
    if (!field.formatValid) reasons.push("जानकारी का format सही साबित नहीं हुआ।");
    if (!field.selectOptionMatched) reasons.push("चुना गया विकल्प वेबसाइट की सूची से exact match नहीं है।");
    if (!hasTrustedEvidence) reasons.push("पुष्ट user/document source नहीं मिला; AI का अनुमान स्वीकार नहीं है।");

    const score = Math.round(100 * (
      (hasTrustedEvidence ? 0.45 * bestEvidence : 0) +
      (field.labelMatched ? 0.20 : 0) +
      (field.formatValid ? 0.20 : 0) +
      (field.selectOptionMatched ? 0.15 : 0)
    ));
    const safe = reasons.length === 0 && score >= 95;
    return {
      index,
      label: field.label,
      decision: safe ? "SAFE_TO_FILL_DRAFT" : "NEEDS_USER",
      score,
      evidenceKinds: evidence.map(item => item.kind),
      reasons: safe ? ["स्रोत, field पहचान, format और विकल्प की जाँच पास हुई; final review फिर भी आवश्यक है।"] : reasons
    };
  });

  const safeCount = results.filter(item => item.decision === "SAFE_TO_FILL_DRAFT").length;
  return {
    engine: "deterministic-evidence-gate-v1",
    total: results.length,
    safeDrafts: safeCount,
    needsUser: results.length - safeCount,
    mayProceedToReview: results.length > 0 && safeCount === results.length,
    results
  };
}
