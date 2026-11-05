import test from "node:test";
import assert from "node:assert/strict";
import { analyzeIntake, assessEligibility, buildChecklist, compareDocuments, detectDocument, extractFields, extractNoticeRules } from "../src/intake.js";

test("extracts common Hindi and English identity fields without exposing full ID numbers", () => {
  assert.deepEqual(extractFields("Candidate Name: Ramesh Kumar\nDOB: 06/06/2007\nFather Name: Suresh"), { name: "Ramesh Kumar", fatherName: "Suresh", dob: "06/06/2007" });
});
test("detects document clues conservatively", () => {
  assert.deepEqual(detectDocument("Senior Secondary Class 12 marksheet"), ["Class 12 marksheet"]);
});
test("notice extraction keeps original evidence lines", () => {
  const r = extractNoticeRules("Age as on 01-01-2026\nLast date 30-06-2026\nMinimum 12th qualification");
  assert.equal(r.age.length, 1); assert.equal(r.dates.length, 1); assert.equal(r.education.length, 1);
});
test("document conflicts stop silent selection", () => {
  const c = compareDocuments([{name:"A",text:"Candidate Name: Ram Singh"},{name:"B",text:"Candidate Name: Ramesh Singh"}]);
  assert.equal(c.length, 1); assert.equal(c[0].status, "needs_user_clarification");
});
test("checklist never invents documents absent from notice", () => {
  assert.deepEqual(buildChecklist("Photo and signature required", [] ).map(x=>x.document), ["Photo","Signature"]);
});
test("eligibility remains incomplete when exact rule or facts are absent", () => {
  assert.equal(assessEligibility({noticeText:"Age limit applies"}).eligible, null);
});
test("analysis reports non-verification and pending eligibility explicitly", () => {
  const a = analyzeIntake({text:"DOB: 01/01/2007"});
  assert.equal(a.safety.authenticityVerified, false); assert.equal(a.eligibility.status, "incomplete");
});
