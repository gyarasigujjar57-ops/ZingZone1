export function classifyIntent(text = "", hasImage = false) {
  const value = String(text || "").toLocaleLowerCase("en-IN");
  if (/(form|application|भरना|फॉर्म|आवेदन|भर्ती|recruitment|scholarship|छात्रवृत्ति|प्रमाणपत्र|certificate|योजना|licence|लाइसेंस|पेंशन|pension)/i.test(value)) {
    return { kind: "form_assistance", requiresTask: true, stage: "understanding_request" };
  }
  if (/(document|दस्तावेज|मार्कशीट|प्रमाण|pdf|ocr|पढ़कर|पढ़कर)/i.test(value) || hasImage) {
    return { kind: "document_help", requiresTask: false, stage: "understanding_input" };
  }
  if (/(photo|image|तस्वीर|फोटो|background|बैकग्राउंड)/i.test(value)) {
    return { kind: "image_help", requiresTask: false, stage: "understanding_request" };
  }
  return { kind: "general_chat", requiresTask: false, stage: "conversation" };
}
