export default {
  async fetch(request, env) {
    const cors = { "Access-Control-Allow-Origin": "*", "Access-Control-Allow-Methods": "POST, OPTIONS", "Access-Control-Allow-Headers": "Content-Type, Authorization", "Content-Type": "application/json; charset=utf-8" };
    if (request.method === "OPTIONS") return new Response(null, { headers: cors });
    if (request.method !== "POST") return Response.json({ error: "Use POST" }, { status: 405, headers: cors });
    let body;
    try { body = await request.json(); } catch { return Response.json({ error: "Invalid JSON" }, { status: 400, headers: cors }); }
    const messages = body?.messages;
    if (!Array.isArray(messages) || messages.length < 1 || messages.length > 20) return Response.json({ error: "Send 1–20 messages" }, { status: 400, headers: cors });
    const contents = [];
    for (const m of messages) {
      if (!m || !["user", "assistant"].includes(m.role) || typeof m.text !== "string" || !m.text.trim() || m.text.length > 8000) return Response.json({ error: "Invalid message" }, { status: 400, headers: cors });
      contents.push({ role: m.role, content: m.text.trim() });
    }
    if (contents[contents.length - 1].role !== "user") return Response.json({ error: "Last message must be user" }, { status: 400, headers: cors });
    try {
      const result = await env.AI.run("@cf/meta/llama-3.3-70b-instruct-fp8-fast", {
        messages: [
          { role: "system", content: "You are Zing AI, an all-India citizen-services and government-form assistant. Reply in the user's language, including Hindi/Hinglish and regional languages when possible. Use conversation for continuity. Help identify services, official portals, eligibility, document checklists, field meanings, and safe next steps. Never invent official URLs, fees, deadlines, or eligibility. Never claim you opened a live website, inspected a page, filled a form, uploaded a document, or submitted anything unless a real integration confirms it. Never request OTPs, passwords, CAPTCHA answers, or full bank/card credentials in chat. User must personally handle OTP, CAPTCHA, consent, payment, and final submission. Clearly flag uncertainty." },
          ...contents
        ], max_tokens: 1200, temperature: 0.3
      });
      const answer = result?.response?.trim();
      if (!answer) return Response.json({ error: "AI returned no answer" }, { status: 502, headers: cors });
      return Response.json({ answer }, { headers: cors });
    } catch {
      return Response.json({ error: "AI service temporarily unavailable" }, { status: 502, headers: cors });
    }
  }
};