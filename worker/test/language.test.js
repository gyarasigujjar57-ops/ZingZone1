import test from "node:test";
import assert from "node:assert/strict";
import { languageInstruction, supportedLanguageCodes } from "../src/language.js";

test("supports auto, English and all 22 scheduled Indian languages", () => {
  const codes = supportedLanguageCodes();
  assert.equal(codes.length, 24);
  for (const code of ["auto","en","as","bn","brx","doi","gu","hi","kn","ks","kok","mai","ml","mni","mr","ne","or","pa","sa","sat","sd","ta","te","ur"]) assert.ok(codes.includes(code), code);
});
test("automatic mode mirrors latest language, Roman Hindi and Hinglish", () => {
  const policy = languageInstruction("auto");
  assert.match(policy, /latest user message/);
  assert.match(policy, /Hinglish/);
  assert.match(policy, /Roman letters/);
});
test("explicit Hindi and Gujarati specify native language scripts", () => {
  assert.match(languageInstruction("hi"), /Devanagari/);
  assert.match(languageInstruction("gu"), /ગુજરાતી/);
});
test("unknown selections safely fall back to automatic detection", () => {
  assert.equal(languageInstruction("xx"), languageInstruction("auto"));
  assert.equal(languageInstruction(null), languageInstruction("auto"));
});
