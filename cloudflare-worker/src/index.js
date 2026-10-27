export default {
  async fetch(request, env) {
    const cors = {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "POST, OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type",
      "Content-Type": "application/json; charset=utf-8"
    };

    if (request.method === "OPTIONS") {
      return new Response(null, { status: 204, headers: cors });
    }
    if (request.method !== "POST") {
      return Response.json({ error: "Use POST" }, { status: 405, headers: cors });
    }
    if (!env.AI) {
      return Response.json({ error: "Cloudflare Workers AI binding is missing" }, { status: 503, headers: cors });
    }

    try {
      const body = await request.json();
      const incoming = body?.messages;
      if (!Array.isArray(incoming) || incoming.length < 1 || incoming.length > 20) {
        return Response.json({ error: "Send 1 to 20 messages" }, { status: 400, headers: cors });
      }

      const messages = incoming.map((item) => {
        const role = item?.role;
        const text = typeof item?.text === "string" ? item.text.trim() : "";
        if (!text || text.length > 8000) throw new Error("Invalid message");
        const mappedRole = role === "assistant" || role === "model" ? "assistant" : role === "user" ? "user" : null;
        if (!mappedRole) throw new Error("Invalid message role");
        return { role: mappedRole, content: text };
      });
      if (messages[messages.length - 1].role !== "user") {
        return Response.json({ error: "Last message must be from the user" }, { status: 400, headers: cors });
      }

      messages.unshift({
        role: "system",
        content: "You are Zing AI, a helpful India-focused citizen-services and form assistant. Reply in the user's language, especially Hindi/Hinglish. Help explain forms and official processes, but never invent eligibility, fees, deadlines, or official URLs. Never claim you opened a website, filled fields, uploaded documents, paid, or submitted anything unless a verified integration confirms it. Never ask users to share passwords, OTPs, CAPTCHA answers, or full bank/card credentials. Guide users to official portals and ask them to enter sensitive details there. Ask one clear question at a time when essential details are missing."
      });

      const result = await env.AI.run("@cf/meta/llama-3.1-8b-instruct", {
        messages,
        max_tokens: 900,
        temperature: 0.4
      });
      const answer = (result?.response ?? "").toString().trim();
      if (!answer) {
        return Response.json({ error: "AI returned an empty answer" }, { status: 502, headers: cors });
      }
      return Response.json({ answer }, { status: 200, headers: cors });
    } catch (error) {
      const message = error?.message === "Invalid message" || error?.message === "Invalid message role"
        ? error.message
        : "AI request failed. Check the Workers AI binding and account quota.";
      return Response.json({ error: message }, { status: 500, headers: cors });
    }
  }
};
