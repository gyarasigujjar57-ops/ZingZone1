import test from "node:test";
import assert from "node:assert/strict";
import { resolvePortalAdapter } from "../src/portal_adapters.js";

test("resolves registered government portal adapters", () => {
  for (const host of [
    "ssc.gov.in",
    "upsc.gov.in",
    "rpsc.rajasthan.gov.in",
    "sso.rajasthan.gov.in",
    "uidai.gov.in",
    "epfindia.gov.in",
    "pmkisan.gov.in",
    "scholarships.gov.in",
    "parivahan.gov.in",
    "incometax.gov.in",
    "gst.gov.in",
    "eshram.gov.in",
    "ncs.gov.in",
    "passportindia.gov.in",
    "digilocker.gov.in",
    "voters.eci.gov.in",
    "rssb.rajasthan.gov.in",
    "janaadhaar.rajasthan.gov.in",
    "nrega.nic.in",
    "nfsa.gov.in",
    "serviceonline.gov.in"
  ]) {
    assert.ok(resolvePortalAdapter(host), `expected adapter for ${host}`);
  }
});

test("resolves www and official subdomains without matching lookalike domains", () => {
  assert.equal(resolvePortalAdapter("www.ssc.gov.in").id, "ssc");
  assert.equal(resolvePortalAdapter("candidate.ssc.gov.in").id, "ssc");
  assert.equal(resolvePortalAdapter("ssc.gov.in.example.com"), null);
  assert.equal(resolvePortalAdapter("not-gov.in"), null);
  assert.equal(resolvePortalAdapter("example.com"), null);
});
