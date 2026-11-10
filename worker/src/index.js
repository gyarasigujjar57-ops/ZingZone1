import { analyzeIntake } from "./intake.js";
import { classifyIntent } from "./intent.js";
import { languageInstruction } from "./language.js";

const SYSTEM_PROMPT = `You are Zing AI inside Zing Zone, an all-India multilingual AI assistant with a strong public-service and form-assistance focus.
Reply in the user's selected language when supplied; otherwise follow the language and script the user used. Understand Hindi, Devanagari, Hinglish, spelling mistakes, short replies and conversational context. Keep explanations clear and practical.
You can answer general questions, explain official public-service processes, understand user-provided text and images, help prepare a form checklist, and ask for missing information one question at a time.
For government services: distinguish official verified information from general guidance and uncertainty. Do not invent official URLs, deadlines, fees, eligibility rules, document requirements or application status. Ask which state, department, scheme, recruitment or exact form only when needed. Prefer official government sources supplied in the conversation; do not claim a live website was opened or checked unless a connected tool actually confirms it.
When a user supplies an image, describe only what is visibly readable and mark uncertainty. Do not claim document authenticity or government verification. Never expose or repeat full identity numbers, bank details, passwords, OTPs or CAPTCHA values. Do not ask users to send OTPs, passwords or CAPTCHA answers in chat.
Do not claim to fill a live website, upload files, submit an application, or perform actions that are not connected and confirmed. Website automation is not enabled in this Step 1 foundation. Never simulate progress or invent a task completion state.
For eligibility, ask for the exact current official notification and required facts. If the age cut-off, qualification rules, relaxations or candidate facts are incomplete, say that eligibility is not yet determined. Never guess.
For forms, take one useful next step at a time, preserve context, and avoid dumping long questionnaires. The user must handle OTP, CAPTCHA, biometric steps, payment, declarations and final submission themselves.
Be respectful, concise, and useful. `;

function jsonResponse(data, status, cors) {
  return Response.json(data, { status, headers: { ...cors, "Cache-Control": "no-store" } });
}
export default {
  async fetch(request, env) {
    const cors = {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type, Authorization",
      "Content-Type": "application/json; charset=utf-8"
    };
    if (request.method === "OPTIONS") return new Response(null, { headers: cors });
    if (request.method === "GET") return jsonResponse({ service: "Zing Zone AI", status: "online", version: "step-1-foundation", capabilities: ["multilingual-chat", "image-understanding", "form-intake", "task-intent"] }, 200, cors);
    if (request.method !== "POST") return jsonResponse({ error: "Use POST" }, 405, cors);
    if (!env.GEMINI_API_KEY) return jsonResponse({ error: "Server Gemini key is not configured" }, 503, cors);

    let body;
    try { body = await request.json(); } catch { return jsonResponse({ error: "Invalid JSON" }, 400, cors); }
    const messages = body?.messages;
    if (!Array.isArray(messages) || messages.length < 1 || messages.length > 20) return jsonResponse({ error: "Send 1–20 messages" }, 400, cors);
    const contents = [];
    let totalChars = 0;
    for (const m of messages) {
      if (!m || !["user", "assistant"].includes(m.role) || typeof m.text !== "string" || !m.text.trim() || m.text.length > 30000) return jsonResponse({ error: "Invalid message" }, 400, cors);
      totalChars += m.text.length;
      contents.push({ role: m.role === "assistant" ? "model" : "user", parts: [{ text: m.text.trim() }] });
    }
    if (totalChars > 100000) return jsonResponse({ error: "Conversation is too large; start a new chat or send fewer messages." }, 413, cors);
    if (contents[contents.length - 1].role !== "user") return jsonResponse({ error: "Last message must be user" }, 400, cors);

    let image = null;
    if (body.image !== undefined && body.image !== null) {
      const mimeType = body.image?.mimeType;
      const data = body.image?.data;
      if (!["image/jpeg", "image/png", "image/webp", "application/pdf"].includes(mimeType) || typeof data !== "string" || data.length > 7_000_000 || !/^[A-Za-z0-9+/]+={0,2}$/.test(data)) {
        return jsonResponse({ error: "File format or size is not supported. Use JPG, PNG, WEBP or PDF under 5 MB." }, 400, cors);
      }
      image = { inlineData: { mimeType, data } };
      contents[contents.length - 1].parts.push(image);
    }

    const language = typeof body.language === "string" ? body.language.slice(0, 20) : "auto";
    const languagePolicy = languageInstruction(language);
    const profile = body.profile && typeof body.profile === "object" ? {
      displayName: typeof body.profile.displayName === "string" ? body.profile.displayName.slice(0, 100) : "",
      state: typeof body.profile.state === "string" ? body.profile.state.slice(0, 100) : "",
      district: typeof body.profile.district === "string" ? body.profile.district.slice(0, 100) : ""
    } : {};
    const systemInstruction = SYSTEM_PROMPT + "\n\nUSER LANGUAGE PREFERENCE (" + language + "): " + languagePolicy + "\nDo not switch languages unless the user asks. For official names and form field labels, preserve the original wording and explain it in the selected language." +
      "\n\nOPTIONAL BASIC PROFILE (user-provided; treat as unverified context, do not assume missing values): " + JSON.stringify(profile);

    try {
      const models = ["gemini-3.8-flash", "gemini-3.5-flash-lite"];
      let lastMessage = "Gemini API request failed";
      let lastStatus = 503;
      for (const model of models) {
        let response;
        let data;
        try {
          response = await fetch("https://generativelanguage.googleapis.com/v1beta/models/" + model + ":generateContent?key=" + encodeURIComponent(env.GEMINI_API_KEY), {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
              systemInstruction: { parts: [{ text: systemInstruction }] },
              contents,
              generationConfig: { maxOutputTokens: 1800, temperature: 0.4 }
            })
          });
          data = await response.json();
        } catch {
          lastMessage = "Could not reach Gemini API from Worker";
          lastStatus = 502;
          continue;
        }
        if (response.ok) {
          const answer = data?.candidates?.[0]?.content?.parts?.map(p => p.text || "").join("").trim();
          if (answer) {
            const latestUserText = messages.filter(m => m.role === "user").slice(-1)[0]?.text || "";
            const intent = classifyIntent(latestUserText, Boolean(image));
            const taskId = intent.requiresTask ? crypto.randomUUID() : null;
            const intake = analyzeIntake({
              text: latestUserText,
              noticeText: typeof body.noticeText === "string" ? body.noticeText.slice(0, 100000) : "",
              documents: Array.isArray(body.documents) ? body.documents.slice(0, 20).filter(d => d && typeof d.text === "string").map(d => ({ name: String(d.name || "दस्तावेज़").slice(0, 120), text: d.text.slice(0, 30000) })) : [],
              candidate: {}
            });
            return jsonResponse({ answer, model, language, intent, task: taskId ? { id: taskId, status: "in_progress" } : null, intake }, 200, cors);
          }
          lastMessage = "Gemini returned no answer";
          lastStatus = 502;
          continue;
        }
        lastMessage = data?.error?.message || "Gemini API request failed";
        lastStatus = response.status;
        if (response.status === 429) return jsonResponse({ error: "AI service is busy or rate-limited. Please retry shortly." }, 429, cors);
        if (![500, 502, 503, 504].includes(response.status)) return jsonResponse({ error: "AI service rejected the request. Check the server model/key configuration." }, 502, cors);
      }
      return jsonResponse({ error: lastMessage, retryable: lastStatus >= 500 }, 502, cors);
    } catch {
      return jsonResponse({ error: "Could not complete the AI request" }, 502, cors);
    }
  }
};
