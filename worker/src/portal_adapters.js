const ADAPTERS = [
  {
    hosts: ["ssc.gov.in", "ssc.nic.in"],
    id: "ssc",
    name: "Staff Selection Commission",
    workflow: "Recruitment notices, candidate registration, application sections, examination preferences, fee/payment stages and final review may be separate steps.",
    checks: ["Match candidate name and date of birth to the supplied identity document", "Keep examination/post preference choices distinct", "Do not infer category, age relaxation, qualification or fee exemption", "Stop before payment, OTP, CAPTCHA and final submission"]
  },
  {
    hosts: ["upsc.gov.in", "upsconline.nic.in"],
    id: "upsc",
    name: "Union Public Service Commission",
    workflow: "Read the exact examination notification and application instructions before interpreting eligibility, attempts, optional subjects or service preferences.",
    checks: ["Never infer eligibility, attempts, category or age relaxation", "Keep examination-specific details separate", "Ask the user to verify every declaration against the current notification", "Stop before payment, OTP, CAPTCHA and final submission"]
  },
  {
    hosts: ["rpsc.rajasthan.gov.in"],
    id: "rpsc",
    name: "Rajasthan Public Service Commission",
    workflow: "Use the exact recruitment advertisement and its corrigenda; distinguish recruitment details from candidate dashboard and application stages.",
    checks: ["Do not infer domicile, category, reservation or qualification", "Check the advertisement number and recruitment name", "Flag any mismatch between advertisement and application page", "Stop before payment, OTP, CAPTCHA and final submission"]
  },
  {
    hosts: ["sso.rajasthan.gov.in"],
    id: "rajasthan-sso",
    name: "Rajasthan Single Sign-On",
    workflow: "Treat SSO as an identity and service gateway; the selected department/service determines the actual application rules.",
    checks: ["Do not read or transmit credentials, OTP or recovery details", "Never act on login, profile, dashboard or payment pages", "Identify the selected service before giving form-specific advice", "Ask the user to complete authentication personally"]
  },
  {
    hosts: ["uidai.gov.in"],
    id: "uidai",
    name: "UIDAI",
    workflow: "Distinguish public information pages from Aadhaar update or authentication services; never treat an Aadhaar number or OTP as ordinary form text.",
    checks: ["Do not request Aadhaar number, OTP, biometric or authentication secrets", "Do not claim an update or verification has occurred", "Direct the user to official UIDAI instructions for current requirements"]
  },
  {
    hosts: ["epfindia.gov.in"],
    id: "epfo",
    name: "Employees' Provident Fund Organisation",
    workflow: "Distinguish employer, employee, pension and claim services; do not mix UAN profile information with claim-specific declarations.",
    checks: ["Never request UAN password, OTP, bank credentials or full account details", "Do not infer service history, nominee or claim eligibility", "Require the user to verify bank and nominee details personally"]
  },
  {
    hosts: ["pmkisan.gov.in"],
    id: "pm-kisan",
    name: "PM-KISAN",
    workflow: "Distinguish public scheme information, beneficiary status, e-KYC and registration flows.",
    checks: ["Do not infer landholding, eligibility or beneficiary status", "Never handle OTP or authentication secrets", "Verify requirements against the current official scheme instructions"]
  },
  {
    hosts: ["scholarships.gov.in"],
    id: "national-scholarship-portal",
    name: "National Scholarship Portal",
    workflow: "Keep scheme selection, academic details, institution verification and bank details separate.",
    checks: ["Do not infer income, category, marks, course or eligibility", "Never request full bank credentials or OTP", "Ask the user to verify scheme-specific requirements and institution details"]
  }
];

export function resolvePortalAdapter(hostname) {
  const host = String(hostname || "").toLowerCase().replace(/^www\./, "");
  return ADAPTERS.find(adapter => adapter.hosts.includes(host)) || null;
}
