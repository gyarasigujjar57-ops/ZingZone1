import test from "node:test";
import assert from "node:assert/strict";
import { classifyIntent } from "../src/intent.js";

test("classifies Hindi and Hinglish government form requests", () => {
  assert.equal(classifyIntent("Mujhe army ka form bharna hai").kind, "form_assistance");
  assert.equal(classifyIntent("छात्रवृत्ति के लिए आवेदन करना है").kind, "form_assistance");
});

test("classifies document requests and image-only input", () => {
  assert.equal(classifyIntent("मेरी मार्कशीट पढ़कर बताओ").kind, "document_help");
  assert.equal(classifyIntent("", true).kind, "document_help");
});

test("keeps unrelated prompts in general chat", () => {
  assert.equal(classifyIntent("भारत का संविधान समझाओ").kind, "general_chat");
});
