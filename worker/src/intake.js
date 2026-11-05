// Deterministic Phase-1 intake helpers. OCR and AI output are never treated as official verification.
const FIELD_PATTERNS = {
  name: [/\b(?:candidate|applicant|student)\s*name\s*[:=-]\s*([^\n|,]{2,80})/i, /(?:नाम|अभ्यर्थी का नाम)\s*[:：=-]\s*([^\n|,]{2,80})/],
  fatherName: [/\bfather(?:'s)?\s*name\s*[:=-]\s*([^\n|,]{2,80})/i, /पिता का नाम\s*[:：=-]\s*([^\n|,]{2,80})/],
  motherName: [/\bmother(?:'s)?\s*name\s*[:=-]\s*([^\n|,]{2,80})/i, /माता का नाम\s*[:：=-]\s*([^\n|,]{2,80})/],
  dob: [/\b(?:date of birth|dob)\s*[:=-]\s*([0-9./-]{6,12})/i, /जन्म तिथि\s*[:：=-]\s*([0-9./-]{6,12})/],
  category: [/\b(?:category|caste)\s*[:=-]\s*([^\n|,]{2,50})/i, /वर्ग|श्रेणी\s*[:：=-]\s*([^\n|,]{2,50})/],
  percentage: [/\b(?:percentage|aggregate|marks)\s*[:=-]\s*([0-9]{1,3}(?:\.\d{1,2})?\s*%?)/i, /प्रतिशत\s*[:：=-]\s*([0-9]{1,3}(?:\.\d{1,2})?\s*%?)/]
};
const clean = v => String(v || "").normalize("NFKC").trim().replace(/\s+/g, " ").replace(/[.,;]+$/, "");
const norm = v => clean(v).toLocaleLowerCase("en-IN").replace(/[^\p{L}\p{N}]/gu, "");
function extractFields(text) {
  const fields = {};
  for (const [key, patterns] of Object.entries(FIELD_PATTERNS)) {
    for (const re of patterns) { const m = re.exec(text); if (m) { fields[key] = clean(m[1]); break; } }
  }
  return fields;
}
function detectDocument(text) {
  const t = text.toLowerCase();
  const types = [
    ["Aadhaar (masked)", /aadhaar|आधार|uidai/],
    ["PAN", /\bpan\b|income tax department/],
    ["Class 10 marksheet", /secondary school|class\s*10|दसवीं|मैट्रिक|matriculation/],
    ["Class 12 marksheet", /senior secondary|class\s*12|बारहवीं|इंटरमीडिएट/],
    ["Caste/category certificate", /caste certificate|जाति प्रमाण|category certificate/],
    ["Domicile/residence certificate", /domicile|residence certificate|मूल निवास|निवास प्रमाण/],
    ["Date of birth proof", /birth certificate|जन्म प्रमाण|date of birth/],
    ["Photo", /photograph|passport size photo|फोटो/],
    ["Signature", /signature|हस्ताक्षर/]
  ];
  return types.filter(([, re]) => re.test(t)).map(([name]) => name);
}
function extractNoticeRules(text) {
  const lines = String(text || "").split(/\r?\n/).map(clean).filter(Boolean);
  const find = re => lines.filter(line => re.test(line)).slice(0, 12);
  return {
    age: find(/age|आयु|उम्र|born between|जन्म.*बीच/i),
    education: find(/educat|qualification|10th|12th|degree|marks|अंक|शैक्षणिक|योग्यता/i),
    dates: find(/last date|closing date| आवेदन.*अंतिम|अंतिम तिथि|from date|opening date/i),
    categoryRelaxation: find(/relaxation|छूट|sc\/st|obc|ews|आरक्षण/i),
    domicile: find(/domicile|residence|मूल निवास|स्थानीय निवासी/i),
    physicalMedical: find(/physical|height|chest|running|medical|शारीरिक|ऊंचाई|दौड़/i),
    fees: find(/fee| शुल्क|application charge/i),
    documents: find(/document|certificate|प्रमाण पत्र|marksheet|फोटो|हस्ताक्षर/i)
  };
}
function compareDocuments(documents) {
  const seen = new Map(), conflicts = [];
  for (const doc of documents || []) {
    const fields = extractFields(doc.text || "");
    for (const [field, value] of Object.entries(fields)) {
      const n = norm(value);
      if (!n) continue;
      if (seen.has(field) && seen.get(field).normalized !== n) {
        conflicts.push({ field, first: seen.get(field).value, second: value, documents: [seen.get(field).document, doc.name || "दूसरा दस्तावेज़"], status: "needs_user_clarification" });
      } else if (!seen.has(field)) seen.set(field, { value, normalized: n, document: doc.name || "दस्तावेज़" });
    }
  }
  return conflicts;
}
function buildChecklist(noticeText, suppliedDocuments) {
  const t = String(noticeText || "").toLowerCase();
  const supplied = new Set((suppliedDocuments || []).flatMap(d => detectDocument(d.text || "")));
  const rules = [
    ["Photo", /photo|photograph|फोटो/],
    ["Signature", /signature|हस्ताक्षर/],
    ["Class 10 marksheet", /10th|class\s*10|दसवीं|मैट्रिक/],
    ["Class 12 marksheet", /12th|class\s*12|बारहवीं|इंटरमीडिएट/],
    ["Caste/category certificate", /caste|category certificate|जाति प्रमाण/],
    ["Domicile/residence certificate", /domicile|residence certificate|मूल निवास/],
    ["Aadhaar (masked)", /aadhaar|आधार/]
  ];
  return rules.filter(([, re]) => re.test(t)).map(([name]) => ({
    document: name, requirement: "mentioned_in_supplied_notice",
    status: supplied.has(name) ? "text_read_unconfirmed" : "not_provided",
    authenticity: "not_verified"
  }));
}
function assessEligibility({ noticeText = "", candidate = {} } = {}) {
  const missing = [];
  if (!noticeText.trim()) missing.push("official_notice_text");
  if (!candidate.dateOfBirth) missing.push("date_of_birth");
  if (!candidate.category) missing.push("category_and_relaxation_applicability");
  // Deliberately do not calculate eligibility unless the notice's exact cut-off,
  // age band, relaxations and candidate facts have been structured and verified.
  const ageRulePresent = /age.*(?:as on|cut.?off)|आयु.*(?:तिथि|दिनांक)/i.test(noticeText);
  if (!ageRulePresent) missing.push("official_age_cutoff_and_rule");
  return { status: "incomplete", eligible: null, missing, reason: "सिर्फ OCR या अधूरे नोटिस से पात्रता का फैसला सुरक्षित/विश्वसनीय नहीं है।" };
}
function analyzeIntake({ text = "", noticeText = "", documents = [], candidate = {} } = {}) {
  const docInfo = documents.map(d => ({ name: d.name || "दस्तावेज़", detectedTypes: detectDocument(d.text || ""), extractedFields: extractFields(d.text || ""), state: "text_read_unconfirmed" }));
  const allDocs = [...documents, ...(text ? [{ name: "chat_or_ocr_text", text }] : [])];
  return {
    version: 1,
    notice: { supplied: Boolean(noticeText.trim()), extractedRules: extractNoticeRules(noticeText), sourceEvidence: "पेज/सेक्शन नंबर तभी दिखेंगे जब अपलोड किए गए टेक्स्ट में मौजूद हों" },
    candidateFacts: { ...candidate, extractedFromCurrentText: extractFields(text) },
    documents: docInfo,
    checklist: buildChecklist(noticeText, documents),
    conflicts: compareDocuments(allDocs),
    eligibility: assessEligibility({ noticeText, candidate }),
    safety: { authenticityVerified: false, portalChecked: false, applicationSubmitted: false, sensitiveValuesMasked: true },
    nextAction: "आधिकारिक नोटिस/पीडीएफ या उसका टेक्स्ट दें; फिर नियम और दस्तावेज़ एक-एक करके जाँचे जाएँगे।"
  };
}
export { analyzeIntake, assessEligibility, buildChecklist, compareDocuments, detectDocument, extractFields, extractNoticeRules };
