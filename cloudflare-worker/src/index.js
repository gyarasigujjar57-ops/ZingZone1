export default {
  async fetch(request, env) {
    const cors = {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "POST, OPTIONS, GET",
      "Access-Control-Allow-Headers": "Content-Type",
      "Content-Type": "application/json; charset=utf-8"
    };

    if (request.method === "OPTIONS") return new Response(null, { status: 204, headers: cors });
    if (request.method === "GET") {
      return Response.json({ status: "ok", service: "Zing Zone Gemini Worker", provider: "Gemini", configured: Boolean(env.GEMINI_API_KEY) }, { headers: cors });
    }
    if (request.method !== "POST") return Response.json({ error: "Use POST" }, { status: 405, headers: cors });
    if (!env.GEMINI_API_KEY) {
      return Response.json({ error: "Gemini API key is not configured on this Worker. Add GEMINI_API_KEY as a Worker secret." }, { status: 503, headers: cors });
    }

    try {
      const body = await request.json();
      const incoming = body?.messages;
      if (!Array.isArray(incoming) || incoming.length < 1 || incoming.length > 20) {
        return Response.json({ error: "Send 1 to 20 messages" }, { status: 400, headers: cors });
      }

      const contents = incoming.map((item) => {
        const role = item?.role;
        const text = typeof item?.text === "string" ? item.text.trim() : "";
        if (!text || text.length > 8000) throw new Error("Invalid message");
        if (role !== "user" && role !== "assistant" && role !== "model") throw new Error("Invalid message role");
        return { role: role === "assistant" || role === "model" ? "model" : "user", parts: [{ text }] };
      });
      if (contents[contents.length - 1].role !== "user") {
        return Response.json({ error: "Last message must be from the user" }, { status: 400, headers: cors });
      }

      const image = body?.image;
      if (image != null) {
        const mimeType = typeof image.mimeType === "string" ? image.mimeType : "image/jpeg";
        const data = typeof image.data === "string" ? image.data : "";
        if (!["image/jpeg", "image/png", "image/webp"].includes(mimeType) || !data || data.length > 8_000_000) {
          return Response.json({ error: "Image format or size is not supported." }, { status: 400, headers: cors });
        }
        contents[contents.length - 1].parts.push({ inlineData: { mimeType, data } });
      }

      const upstream = await fetch("https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent", {
        method: "POST",
        headers: { "Content-Type": "application/json", "x-goog-api-key": env.GEMINI_API_KEY },
        body: JSON.stringify({
          systemInstruction: { parts: [{ text: "You are Zing AI, a capable and friendly general-purpose AI assistant for users in India. Answer general knowledge, education, maths, writing, reasoning, everyday questions and Indian citizen-service questions. Reply naturally in the user's language, especially Hindi or Hinglish. Use the supplied conversation for context. Explain clearly and give useful detail. Never invent eligibility, fees, deadlines or official URLs. Never claim you opened a website, filled fields, uploaded documents, paid or submitted anything unless a verified integration confirms it. Never ask for passwords, OTPs, CAPTCHA answers or full bank/card credentials. Ask one clear question at a time when essential details are missing." }] },
          contents,
          generationConfig: { temperature: 0.5, maxOutputTokens: 1800 }
        })
      });

      if (!upstream.ok) {
        console.error("Gemini API returned HTTP", upstream.status);
        return Response.json({ error: upstream.status === 429 ? "Gemini request limit reached. Please try again shortly." : "Gemini could not answer right now. Check the API key and Gemini API access." }, { status: upstream.status === 429 ? 429 : 502, headers: cors });
      }
      const result = await upstream.json();
      const answer = result.candidates?.[0]?.content?.parts?.map((part) => part.text ?? "").join("").trim();
      if (!answer) return Response.json({ error: "Gemini returned an empty answer. Please try again." }, { status: 502, headers: cors });
      return Response.json({ answer }, { status: 200, headers: cors });
    } catch (error) {
      const message = error?.message === "Invalid message" || error?.message === "Invalid message role" ? error.message : "AI request failed. Please try again.";
      return Response.json({ error: message }, { status: 400, headers: cors });
    }
  }
};
