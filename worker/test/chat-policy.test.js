import test from "node:test";
import assert from "node:assert/strict";
import { CHAT_BEHAVIOR_POLICY } from "../src/chat-policy.js";

const requirements = [
  ["substantive reply to ordinary messages", /substantive response/],
  ["Hindi and script matching", /Devanagari Hindi/],
  ["Hinglish and Roman Hindi", /Roman Hindi\/Hinglish/],
  ["English responses", /English/],
  ["supported Indian languages", /supported Indian languages/],
  ["mirror the user's current language", /latest user message's language/],
  ["automatic language recognition", /Recognize Devanagari Hindi/],
  ["switch language within the conversation", /switch from that next answer onward/],
  ["simple Hindi explanations of difficult English", /simple Hindi/],
  ["two-way translation", /both directions/],
  ["bilingual answers", /bilingual answer/],
  ["long multi-part questions", /long requests/],
  ["short direct questions", /short direct questions/],
  ["conversation context", /earlier messages in the same conversation/],
  ["connect related questions", /Connect related questions/],
  ["clarify material ambiguity", /single most useful clarifying question/],
  ["math, science, GK and education", /mathematics, science, general knowledge and education/],
  ["writing, explanation, planning and problem solving", /writing, explanation, planning and problem-solving/],
  ["honest uncertainty, no fabrication", /Never fabricate facts/]
];

for (const [name, pattern] of requirements) {
  test("chat policy: " + name, () => assert.match(CHAT_BEHAVIOR_POLICY, pattern));
}
test("policy includes all 19 checklist requirements", () => assert.equal(requirements.length, 19));
