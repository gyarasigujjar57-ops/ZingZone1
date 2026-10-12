import { initializeApp } from "firebase-admin/app";
import { defineSecret } from "firebase-functions/params";
import { HttpsError, onCall } from "firebase-functions/v2/https";

initializeApp();

const geminiApiKey = defineSecret("GEMINI_API_KEY");

type ChatMessage = { role: "user" | "model"; text: string };

export const askZingAI = onCall(
  {
    region: "asia-south1",
    secrets: [geminiApiKey],
    enforceAppCheck: false
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Please sign in to use Zing AI.");
    }

    const raw = request.data?.messages;
    if (!Array.isArray(raw) || raw.length < 1 || raw.length > 20) {
      throw new HttpsError("invalid-argument", "Send between 1 and 20 recent messages.");
    }

    const messages: ChatMessage[] = raw.map((item: unknown) => {
      if (!item || typeof item !== "object") {
        throw new HttpsError("invalid-argument", "Invalid message format.");
      }
      const candidate = item as Record<string, unknown>;
      if ((candidate.role !== "user" && candidate.role !== "model") ||
          typeof candidate.text !== "string" ||
          candidate.text.trim().length === 0 ||
          candidate.text.length > 8000) {
        throw new HttpsError("invalid-argument", "Invalid message content.");
      }
      return { role: candidate.role, text: candidate.text.trim() };
    });

    if (messages[messages.length - 1].role !== "user") {
      throw new HttpsError("invalid-argument", "The latest message must be from the user.");
    }

    const apiKey = geminiApiKey.value();
    if (!apiKey) {
      throw new HttpsError("failed-precondition", "AI service is not configured yet.");
    }

    const response = await fetch(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent",
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-goog-api-key": apiKey
        },
        body: JSON.stringify({
          systemInstruction: {
            parts: [{
              text: "You are Zing AI, a helpful assistant for Indian users. Respond in the user's language, including Hindi/Hinglish when appropriate. For government forms, explain requirements and guide the user carefully; never claim a form was submitted unless a trusted integration confirms it. Do not ask users to share passwords, OTPs, or full payment credentials in chat. Flag uncertainty and direct users to official portals for final verification."
            }]
          },
          contents: messages.map((message) => ({
            role: message.role,
            parts: [{ text: message.text }]
          })),
          generationConfig: {
            temperature: 0.4,
            maxOutputTokens: 1200
          }
        })
      }
    );

    if (!response.ok) {
      // Do not return upstream response bodies because they may expose implementation details.
      console.error("Gemini request failed", response.status);
      throw new HttpsError("unavailable", "Zing AI could not answer right now. Please try again.");
    }

    const result = await response.json() as {
      candidates?: Array<{ content?: { parts?: Array<{ text?: string }> } }>;
    };
    const answer = result.candidates?.[0]?.content?.parts
      ?.map((part) => part.text ?? "")
      .join("")
      .trim();

    if (!answer) {
      throw new HttpsError("unavailable", "Zing AI returned an empty answer. Please try again.");
    }

    return { answer };
  }
);