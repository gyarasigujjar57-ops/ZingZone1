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
  },
  {
    hosts: ["parivahan.gov.in", "sarathi.parivahan.gov.in", "vahan.parivahan.gov.in"],
    id: "parivahan",
    name: "Parivahan — driving licence and vehicle services",
    workflow: "पहचानें कि सेवा learner licence, driving licence, vehicle registration, tax या challan से जुड़ी है; Sarathi और Vahan के चरण अलग हो सकते हैं।",
    checks: ["जन्मतिथि और वाहन/लाइसेंस श्रेणी को अलग रखें", "वाहन मालिक और चालक की पहचान न मिलाएँ", "वाहन नंबर, chassis/engine details और licence number केवल संबंधित फ़ील्ड में रखें", "OTP, शुल्क भुगतान और अंतिम जमा उपयोगकर्ता स्वयं करे"]
  },
  {
    hosts: ["incometax.gov.in"],
    id: "income-tax",
    name: "Income Tax e-Filing",
    workflow: "सेवा को ITR, PAN-related service, refund या अन्य tax filing के रूप में पहचानें; tax year और assessment year को अलग रखें।",
    checks: ["आय, deductions, tax regime या refund का अनुमान न लगाएँ", "PAN, बैंक विवरण, login और OTP न माँगें", "राशि और वित्तीय declarations उपयोगकर्ता से verify कराएँ", "e-Verification और final filing उपयोगकर्ता के नियंत्रण में रहे"]
  },
  {
    hosts: ["gst.gov.in"],
    id: "gst",
    name: "Goods and Services Tax Portal",
    workflow: "Registration, return, payment और refund अलग workflows हैं; taxpayer type और tax period पहले पहचानें।",
    checks: ["GSTIN और PAN को एक ही field न मानें", "HSN/SAC, tax rate या liability स्वयं तय न करें", "Business address और principal place of business अलग रखें", "Credentials, OTP, payment और return filing उपयोगकर्ता स्वयं करे"]
  },
  {
    hosts: ["eshram.gov.in"],
    id: "eshram",
    name: "e-Shram",
    workflow: "Worker registration और profile/update flows में occupation, work category और personal identity अलग-अलग जाँचें।",
    checks: ["Occupation या employment category का अनुमान न लगाएँ", "नाम और जन्मतिथि को user-confirmed document से मिलाएँ", "Aadhaar authentication, OTP और bank details उपयोगकर्ता स्वयं संभाले"]
  },
  {
    hosts: ["ncs.gov.in"],
    id: "national-career-service",
    name: "National Career Service",
    workflow: "Job seeker, employer, vacancy search और career service को अलग पहचानें; profile data को job application facts न मानें।",
    checks: ["Qualification, experience और skills केवल user-confirmed facts से भरें", "किसी नौकरी या चयन की गारंटी न दें", "Contact details और profile visibility उपयोगकर्ता से confirm कराएँ"]
  },
  {
    hosts: ["passportindia.gov.in", "www.passportindia.gov.in"],
    id: "passport-seva",
    name: "Passport Seva",
    workflow: "Fresh passport, re-issue, minor application और appointment workflows अलग रखें; exact application category पहले confirm करें।",
    checks: ["Applicant और parent/guardian के नाम अलग रखें", "Present और permanent address अलग-अलग मिलाएँ", "Police verification या passport approval की गारंटी न दें", "Login, OTP, fee payment और final submission उपयोगकर्ता करे"]
  },
  {
    hosts: ["digilocker.gov.in"],
    id: "digilocker",
    name: "DigiLocker",
    workflow: "Issued documents, uploaded documents और issuer consent को अलग पहचानें; user consent के बिना कोई document access/share न करें।",
    checks: ["OTP, PIN और account credentials न पढ़ें या न भेजें", "Document issuer, owner और document type verify करें", "किसी document को fetch या share करने से पहले उपयोगकर्ता की स्पष्ट सहमति लें"]
  },
  {
    hosts: ["eci.gov.in", "voters.eci.gov.in", "voterportal.eci.gov.in"],
    id: "election-commission-voter-services",
    name: "Election Commission voter services",
    workflow: "New voter registration, correction, address shifting और electoral roll search को अलग workflows मानें।",
    checks: ["Applicant और relative के नाम/रिश्ते न मिलाएँ", "Age, citizenship और residence facts का अनुमान न लगाएँ", "EPIC number और application reference अलग रखें", "OTP और final declaration उपयोगकर्ता स्वयं verify करे"]
  },
  {
    hosts: ["rsmssb.rajasthan.gov.in", "rssb.rajasthan.gov.in"],
    id: "rajasthan-staff-selection-board",
    name: "Rajasthan Staff Selection Board",
    workflow: "Exact recruitment advertisement, corrigendum, post, category and application stage की पुष्टि करें; भर्ती नियम परीक्षा-विशेष होते हैं।",
    checks: ["Advertisement number और post name match करें", "Age cut-off date, qualification cut-off और category relaxation न गढ़ें", "Reservation, domicile और certificate validity उपयोगकर्ता से verify कराएँ", "Fee, OTP, CAPTCHA और final submit उपयोगकर्ता करे"]
  },
  {
    hosts: ["janaadhaar.rajasthan.gov.in"],
    id: "rajasthan-janaadhaar",
    name: "Rajasthan Jan Aadhaar",
    workflow: "Family identity, member details, enrolment और update requests को अलग रखें; family head और individual member की भूमिका स्पष्ट करें।",
    checks: ["परिवार के अलग सदस्यों की पहचान/जन्मतिथि/रिश्ते न मिलाएँ", "नाम या संबंध का अनुमान न लगाएँ", "OTP, identity authentication और final update उपयोगकर्ता स्वयं करे"]
  },
  {
    hosts: ["nrega.nic.in"],
    id: "mgnrega",
    name: "MGNREGA",
    workflow: "Job card, household member, work demand, muster roll और payment status अलग सेवाएँ हैं।",
    checks: ["Household head और worker का नाम अलग रखें", "काम के दिन, भुगतान या job-card status का अनुमान न लगाएँ", "Bank/OTP details न माँगें; आधिकारिक रिकॉर्ड से status उपयोगकर्ता verify करे"]
  },
  {
    hosts: ["nfsa.gov.in"],
    id: "national-food-security",
    name: "National Food Security Portal",
    workflow: "Ration-card and food-security services राज्य-विशेष portals से जुड़ सकती हैं; राज्य और exact service पहचानें।",
    checks: ["Household members और head-of-family details अलग रखें", "Income, category और entitlement का अनुमान न लगाएँ", "राज्य-विशेष नियम आधिकारिक सूचना से verify करें"]
  },
  {
    hosts: ["serviceonline.gov.in"],
    id: "service-plus-edistrict",
    name: "ServicePlus / e-District services",
    workflow: "Certificate or citizen-service workflows राज्य और विभाग के अनुसार बदलते हैं; service name और issuing authority पहले पहचानें।",
    checks: ["Caste, domicile, income और residence certificate को परस्पर न बदलें", "Issuing authority, state and district verify करें", "Declaration, fee, OTP and final submission उपयोगकर्ता करे"]
  }

];

export function resolvePortalAdapter(hostname) {
  const host = String(hostname || "").toLowerCase().replace(/^www\./, "");
  return ADAPTERS.find(adapter => adapter.hosts.some(known => host === known || host.endsWith("." + known))) || null;
}
