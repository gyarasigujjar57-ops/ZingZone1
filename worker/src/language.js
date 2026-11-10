// Supported response-language policy for Zing Zone.
// Auto mode mirrors the latest message, including Roman Hindi and Hinglish.
const LANGUAGES = {
  auto: "Automatic detection: identify the language and script of the latest user message. Reply in that language. If the user writes Hindi in Roman letters or mixes Hindi and English, naturally mirror that Hinglish style and script. Keep earlier conversation context.",
  en: "English (use clear, simple English)",
  as: "Assamese (অসমীয়া)", bn: "Bengali (বাংলা)", brx: "Bodo (बड़ो)", doi: "Dogri (डोगरी)",
  gu: "Gujarati (ગુજરાતી)", hi: "Hindi (हिन्दी, Devanagari script)", kn: "Kannada (ಕನ್ನಡ)",
  ks: "Kashmiri (कॉशुर; follow the user's script where possible)", kok: "Konkani (कोंकणी; follow the user's script where possible)",
  mai: "Maithili (मैथिली)", ml: "Malayalam (മലയാളം)", mni: "Manipuri/Meitei (মৈতৈলোন্; follow the user's script where possible)",
  mr: "Marathi (मराठी)", ne: "Nepali (नेपाली)", or: "Odia (ଓଡ଼ିଆ)", pa: "Punjabi (ਪੰਜਾਬੀ, Gurmukhi script)",
  sa: "Sanskrit (संस्कृतम्)", sat: "Santali (ᱥᱟᱱᱛᱟᱲᱤ; Ol Chiki where supported)",
  sd: "Sindhi (سنڌي; use the user's preferred script where possible)", ta: "Tamil (தமிழ்)", te: "Telugu (తెలుగు)", ur: "Urdu (اردو script)"
};
export function languageInstruction(value = "auto") {
  const code = typeof value === "string" ? value.trim().toLowerCase() : "auto";
  return LANGUAGES[code] || LANGUAGES.auto;
}
export function supportedLanguageCodes() { return Object.keys(LANGUAGES); }
