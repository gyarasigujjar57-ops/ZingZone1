import test from "node:test";
import assert from "node:assert/strict";
import { classifyIntent } from "../src/intent.js";

test("recognizes Hindi and Hinglish form requests", () => {
  assert.equal(classifyIntent("mujhe army ka form bharna hai").kind, "form_assistance");
  assert.equal(classifyIntent("छात्रवृत्ति का आवेदन करना है").kind, "form_assistance");
});
test("recognizes document and image help", () => {
  assert.equal(classifyIntent("इस मार्कशीट को पढ़कर बताओ").kind, "document_help");
  assert.equal(classifyIntent("", true).kind, "document_help");
});
test("keeps ordinary questions in general chat", () => {
  assert.equal(classifyIntent("भारत की राजधानी क्या है").kind, "general_chat");
});
