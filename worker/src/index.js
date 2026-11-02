export default {
  async fetch(request, env) {
    const cors = {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type, Authorization"
    };
    const json = (data, status = 200) => new Response(JSON.stringify(data), {
      status,
      headers: { ...cors, "Content-Type": "application/json; charset=utf-8" }
    });

    if (request.method === "OPTIONS") return new Response(null, { headers: cors });
    if (request.method === "GET") {
      return json({
        status: "ok",
        service: "Zing Zone AI",
        provider: "Gemini",
        image_support: true,
        form_assist: true,
        configured: Boolean(env.GEMINI_API_KEY)
      });
    }
    if (request.method !== "POST") return json({ error: "Method not allowed" }, 405);
    if (!env.GEMINI_API_KEY) return json({ error: "AI server is not configured." }, 503);

    let body;
    try {
      body = await request.json();
    } catch {
      return json({ error: "Invalid JSON request." }, 400);
    }

    const messages = body && body.messages;
    if (!Array.isArray(messages) || messages.length < 1 || messages.length > 20) {
      return json({ error: "Send between 1 and 20 messages." }, 400);
    }

    const contents = [];
    for (const message of messages) {
      if (!message || !["user", "assistant", "model"].includes(message.role) ||
          typeof message.text !== "string" || !message.text.trim() || message.text.length > 8000) {
        return json({ error: "Invalid message format." }, 400);
      }
      contents.push({
        role: message.role === "assistant" || message.role === "model" ? "model" : "user",
        parts: [{ text: message.text.trim() }]
      });
    }
    while (contents.length && contents[0].role !== "user") contents.shift();
    if (!contents.length || contents[contents.length - 1].role !== "user") {
      return json({ error: "The latest message must be from the user." }, 400);
    }

    if (body.image !== undefined && body.image !== null) {
      const image = body.image;
      const allowedTypes = ["image/jpeg", "image/png", "image/webp"];
      if (!image || !allowedTypes.includes(image.mimeType) ||
          typeof image.data !== "string" || image.data.length < 16 ||
          image.data.length > 6000000 || !/^[A-Za-z0-9+/]+={0,2}$/.test(image.data)) {
        return json({ error: "Image format is unsupported or the image is too large." }, 400);
      }
      try {
        atob(image.data);
      } catch {
        return json({ error: "Image data is not valid base64." }, 400);
      }
      contents[contents.length - 1].parts.push({
        inline_data: { mime_type: image.mimeType, data: image.data }
      });
    }

    try {
      const controller = new AbortController();
      const timer = setTimeout(() => controller.abort(), 35000);
      let upstream;
      try {
        upstream = await fetch(
          "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash-lite:generateContent",
          {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
              "x-goog-api-key": env.GEMINI_API_KEY
            },
            body: JSON.stringify({
              systemInstruction: {
                parts: [{
                  text: "You are Zing AI, a careful Hindi/Hinglish-first assistant for everyday tasks and Indian public-service forms. Understand uploaded images and documents and extract only clearly visible information. Explain form fields and prepare draft values only from facts the user explicitly provides. Never invent names, dates, eligibility, fees, deadlines, official URLs, or missing details. State uncertainty. Never request or process passwords, OTPs, CAPTCHA answers, full bank/card credentials, or biometric secrets. The user must personally handle OTP, CAPTCHA, consent, payments, and final submission. Never claim an action happened unless the connected system confirms it."
                }]
              },
              contents,
              generationConfig: { temperature: 0.3, maxOutputTokens: 1400 }
            }),
            signal: controller.signal
          }
        );
      } finally {
        clearTimeout(timer);
      }

      const data = await upstream.json().catch(() => ({}));
      if (!upstream.ok) {
        return json({
          error: "Gemini could not complete the request.",
          upstream_status: upstream.status
        }, 502);
      }
      const answer = (data && data.candidates && data.candidates[0] &&
        data.candidates[0].content && data.candidates[0].content.parts || [])
        .map(part => part.text || "").join("").trim();
      if (!answer) return json({ error: "AI returned an empty answer." }, 502);
      return json({ answer });
    } catch (error) {
      return json({
        error: error && error.name === "AbortError"
          ? "AI request timed out. Please try again."
          : "AI service is temporarily unavailable."
      }, error && error.name === "AbortError" ? 504 : 502);
    }
  }
};
