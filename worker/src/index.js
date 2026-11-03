const SYSTEM_PROMPT = "You are Zing AI, an all-India citizen-services and recruitment-form assistant. Reply in the user's language, especially clear Hindi/Devanagari or Hinglish. When OCR text is included, classify the likely document using text clues only and give confidence (high/medium/low); never claim visual inspection, authenticity, or official verification. Extract only legible values, preserve exact spelling, mask identity numbers, and mark unclear values unreadable. Separate fields found, uncertain fields, conflicts, and missing information. For extracted fields, show field, value, source document/page when available, and confidence; ask the user to confirm/correct before reuse. Never invent DOB, names, marks, category, address, dates, eligibility, fees, official URLs, or document requirements. For recruitment forms, ask for the official notification/link if exact recruitment is unclear; then extract post, department, dates, age cut-off, qualifications, category relaxations, domicile, fee, documents and photo/signature/thumb specifications only from supplied notice. Cite page/section only when source supplies it. Stop on conflicting records and ask one question at a time. Never claim a live portal was opened, fields filled, files uploaded, or application submitted unless a verified integration confirms it. Never request OTPs, passwords, CAPTCHA answers, full bank/card credentials or unnecessary sensitive data. User personally handles OTP, CAPTCHA, biometrics, declarations, payment and final submission. Clearly flag uncertainty.";
export default {
  async fetch(request, env) {
    const cors = { "Access-Control-Allow-Origin": "*", "Access-Control-Allow-Methods": "POST, OPTIONS", "Access-Control-Allow-Headers": "Content-Type, Authorization", "Content-Type": "application/json; charset=utf-8" };
    if (request.method === "OPTIONS") return new Response(null, { headers: cors });
    if (request.method === "GET") return Response.json({ service: "Zing Zone AI", status: "online", provider: "Gemini API" }, { headers: cors });
    if (request.method !== "POST") return Response.json({ error: "Use POST" }, { status: 405, headers: cors });
    if (!env.GEMINI_API_KEY) return Response.json({ error: "Server Gemini key is not configured" }, { status: 503, headers: cors });
    let body;
    try { body = await request.json(); } catch { return Response.json({ error: "Invalid JSON" }, { status: 400, headers: cors }); }
    const messages = body?.messages;
    if (!Array.isArray(messages) || messages.length < 1 || messages.length > 20) return Response.json({ error: "Send 1–20 messages" }, { status: 400, headers: cors });
    const contents = [];
    for (const m of messages) {
      if (!m || !["user", "assistant"].includes(m.role) || typeof m.text !== "string" || !m.text.trim() || m.text.length > 30000) return Response.json({ error: "Invalid message" }, { status: 400, headers: cors });
      contents.push({ role: m.role === "assistant" ? "model" : "user", parts: [{ text: m.text.trim() }] });
    }
    if (contents[contents.length - 1].role !== "user") return Response.json({ error: "Last message must be user" }, { status: 400, headers: cors });
    try {
      const response = await fetch("https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=" + encodeURIComponent(env.GEMINI_API_KEY), {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          systemInstruction: { parts: [{ text: SYSTEM_PROMPT }] },
          contents,
          generationConfig: { maxOutputTokens: 1400, temperature: 0.3 }
        })
      });
      const data = await response.json();
      if (!response.ok) {
        const message = data?.error?.message || "Gemini API request failed";
        return Response.json({ error: message }, { status: response.status === 429 ? 429 : 502, headers: cors });
      }
      const answer = data?.candidates?.[0]?.content?.parts?.map(p => p.text || "").join("").trim();
      if (!answer) return Response.json({ error: "Gemini returned no answer" }, { status: 502, headers: cors });
      return Response.json({ answer }, { headers: cors });
    } catch {
      return Response.json({ error: "Could not reach Gemini API from Worker" }, { status: 502, headers: cors });
    }
  }
};
