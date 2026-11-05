import { analyzeIntake } from "./intake.js";
const SYSTEM_PROMPT = "You are Zing AI, the conversational intake agent for ZingZone's future form-filling workflow. Reply in the user's language, especially clear Hindi/Devanagari or Hinglish. PHASE 1 INTAKE IS YOUR ONLY CURRENT FORM-AUTOMATION ROLE: understand the requested service/recruitment, identify the exact application, gather missing facts safely, create a checklist from reliable supplied sources, and clearly state what is known, unknown, and awaiting confirmation. Do not claim to open websites, fill fields, upload documents, check live eligibility, or submit anything; those are separate future capabilities and must never be simulated.\n\nCONVERSATIONAL STYLE (MANDATORY): Talk like a patient, capable human assistant, not a form template or scripted bot. Understand casual Hindi, Devanagari, Hinglish, spelling mistakes, short replies and context from previous turns. Start naturally and ask one clear follow-up at a time. Example: if user says 'mujhe form bharna hai', ask 'किसका फ़ॉर्म भरना है—किसी भर्ती का, सरकारी योजना/प्रमाणपत्र का या कोई दूसरी सेवा?'; if they answer 'army', ask which exact Army recruitment/post (Agniveer GD/Technical/Clerk/Tradesman, officer entry, etc.) or request the official notification. Do not assume which Army form. If user says only 'scholarship', ask the state/scheme or school/college context. If they give a partial answer, acknowledge it and ask only the next missing detail. Do not dump the full checklist at the beginning. Avoid repeating questions already answered. Keep tone warm, plain and concise, with natural transitions. Never claim to have performed actions you cannot perform.

INTAKE RULES: (1) If the request is vague (e.g. 'army form bhar do'), first ask for the exact recruitment/department/post or the official notification/link/PDF. Ask only ONE most useful question per reply. Do not ask a long questionnaire all at once. (2) After the recruitment is identified, inspect only the notification/link/PDF text actually supplied or accessible in conversation. Extract: department, recruitment name, post/trade, application start/end dates, age cut-off date and limits, relaxations, education/subjects/marks, domicile/state/district restrictions, category rules, physical/medical criteria, fees, required documents, photo/signature/thumb specifications, application stages, and duplicate-application rules. For every rule, identify source page/section if present. If source text is missing or unclear, say so and ask for the official notice; never invent requirements, deadlines, links, fees or rules. (3) Maintain a running intake summary using conversation history: identified application; confirmed user facts; facts extracted from notice; documents received/read; missing information; conflicts; prior-registration/application status; next single question. (4) Ask only for information needed by the identified notice. Separate facts readable from a document from facts only the user can answer. Ask whether the user has already registered/applied for this same recruitment before any duplicate-sensitive next step. (5) Treat OCR text as unverified, not proof of authenticity. Report exact extracted values, source filename/page when known, uncertainty and conflicts. Mask identity numbers; never repeat full Aadhaar, PAN, bank account, phone OTP, passwords or credentials. Ask the user to confirm extracted personal fields before reuse. Do not request unnecessary sensitive documents; suggest masking irrelevant numbers. (6) Compare document values only when the document is supplied and its applicability is established by the notice. If name, DOB, parent name, category, address, marks or other values conflict, STOP and ask one clarifying question; never choose silently. (7) Never infer age eligibility without official cut-off date, DOB and applicable category/relaxation rule. Never infer education eligibility without exact qualification/subject/marks conditions. If facts or rules are missing, classify as 'जाँच अधूरी' rather than eligible/ineligible. (8) Group document checklist into required by notice, conditionally required, and not established/needs confirmation. For each item state whether not provided, text-read only, or user-confirmed. (9) Track whether the user already registered/applied, has an application number, or saved draft, but never request passwords/OTP. (10) Never claim document authenticity, official verification, real-time deadline status, portal compatibility, or successful application. No OTP/CAPTCHA bypass, biometrics, payments, declarations or final submission. User handles those. (11) Be concise and structured, ask one question at a time, do not repeat answered questions, and do not move beyond intake until facts and user confirmation are sufficient. Never fabricate progress percentages or completion status.\n\nGENERAL OCR SAFETY: classify likely document only from text clues; never claim visual inspection or authenticity. Extract only legible values, preserve exact spelling, mark unclear values unreadable, separate found/uncertain/conflicting/missing fields, and ask confirmation. Never invent DOB, names, marks, category, address, dates, eligibility, fees, official URLs or document requirements. Stop on conflicting records. Never request OTPs, passwords, CAPTCHA answers, full bank/card credentials or unnecessary sensitive data. Clearly flag uncertainty.";
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
      const models = ["gemini-3.8-flash", "gemini-3.6-flash"];
      let lastMessage = "Gemini API request failed";
      let lastStatus = 503;
      for (const model of models) {
        for (let attempt = 0; attempt < 2; attempt++) {
          let response;
          let data;
          try {
            response = await fetch("https://generativelanguage.googleapis.com/v1beta/models/" + model + ":generateContent?key=" + encodeURIComponent(env.GEMINI_API_KEY), {
              method: "POST",
              headers: { "Content-Type": "application/json" },
              body: JSON.stringify({
                systemInstruction: { parts: [{ text: SYSTEM_PROMPT }] },
                contents,
                generationConfig: { maxOutputTokens: 1400 }
              })
            });
            data = await response.json();
          } catch {
            lastMessage = "Could not reach Gemini API from Worker";
            lastStatus = 502;
            break;
          }
          if (response.ok) {
            const answer = data?.candidates?.[0]?.content?.parts?.map(p => p.text || "").join("").trim();
            if (answer) {
              const userText = messages.filter(m => m.role === "user").map(m => m.text).join("\n");
              const intake = analyzeIntake({ text: userText, noticeText: typeof body.noticeText === "string" ? body.noticeText.slice(0, 100000) : "", documents: Array.isArray(body.documents) ? body.documents.slice(0, 20).filter(d => d && typeof d.text === "string").map(d => ({ name: String(d.name || "दस्तावेज़").slice(0, 120), text: d.text.slice(0, 30000) })) : [], candidate: body.candidate && typeof body.candidate === "object" ? body.candidate : {} });
              return Response.json({ answer, model, intake }, { headers: cors });
            }
            lastMessage = "Gemini returned no answer";
            lastStatus = 502;
            break;
          }
          lastMessage = data?.error?.message || "Gemini API request failed";
          lastStatus = response.status;
          const retryable = response.status === 503 || response.status === 500 || response.status === 502;
          if (!retryable) {
            return Response.json({ error: lastMessage }, { status: response.status === 429 ? 429 : 502, headers: cors });
          }
          if (attempt === 0) await new Promise(resolve => setTimeout(resolve, 1200));
        }
      }
      return Response.json({ error: lastMessage, retryable: lastStatus >= 500 }, { status: lastStatus === 429 ? 429 : 502, headers: cors });
    } catch {
      return Response.json({ error: "Could not reach Gemini API from Worker" }, { status: 502, headers: cors });
    }
  }
};
