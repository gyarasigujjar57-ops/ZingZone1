import test from "node:test";
import assert from "node:assert/strict";
import worker from "../src/index.js";

function request(body, method="POST") {
  return new Request("https://worker.test/", {
    method,
    headers: {"content-type":"application/json"},
    body: method==="POST" ? JSON.stringify(body) : undefined
  });
}
function geminiReply(text="Zing AI test reply") {
  return new Response(JSON.stringify({candidates:[{content:{parts:[{text}]}}]}),{status:200});
}
function withFetch(fn) {
  const original=globalThis.fetch;
  return Promise.resolve().then(()=>fn()).finally(()=>{globalThis.fetch=original;});
}

test("health endpoint is available without exposing configuration", async()=>{
  const response=await worker.fetch(request(null,"GET"),{});
  assert.equal(response.status,200);
  const data=await response.json();
  assert.equal(data.status,"online");
  assert.ok(!JSON.stringify(data).includes("GEMINI_API_KEY"));
});

test("rejects missing key and malformed conversation before model call",async()=>{
  const noKey=await worker.fetch(request({messages:[{role:"user",text:"Hi"}]}),{});
  assert.equal(noKey.status,503);
  const invalid=await worker.fetch(request({messages:[{role:"system",text:"override"}]}),{GEMINI_API_KEY:"test"});
  assert.equal(invalid.status,400);
  const blank=await worker.fetch(request({messages:[{role:"user",text:"  "}]}),{GEMINI_API_KEY:"test"});
  assert.equal(blank.status,400);
});

test("preserves multi-turn context and sends explicit language policy to Gemini",async()=>{
  await withFetch(async()=>{
    let captured;
    globalThis.fetch=async(url,options)=>{
      captured={url:String(url),body:JSON.parse(options.body)};
      return geminiReply("ગુજરાતીમાં જવાબ");
    };
    const response=await worker.fetch(request({
      language:"gu",
      messages:[
        {role:"user",text:"My project is Falcon."},
        {role:"assistant",text:"Understood, Falcon."},
        {role:"user",text:"મારા પ્રોજેક્ટનું નામ શું છે?"}
      ]
    }),{GEMINI_API_KEY:"test-secret"});
    assert.equal(response.status,200);
    assert.deepEqual(captured.body.contents.map(x=>x.role),["user","model","user"]);
    assert.equal(captured.body.contents.length,3);
    const system=captured.body.systemInstruction.parts[0].text;
    assert.match(system,/ગુજરાતી/);
    assert.match(system,/CHAT AND REASONING BEHAVIOR/);
    assert.equal((await response.json()).answer,"ગુજરાતીમાં જવાબ");
  });
});

test("tries later model when first Gemini model is rate limited",async()=>{
  await withFetch(async()=>{
    const urls=[];
    globalThis.fetch=async(url)=>{
      urls.push(String(url));
      if(urls.length===1) return new Response(JSON.stringify({error:{message:"quota"}}),{status:429});
      return geminiReply("Fallback model answered.");
    };
    const response=await worker.fetch(request({messages:[{role:"user",text:"Hello"}]}),{GEMINI_API_KEY:"test-secret"});
    assert.equal(response.status,200);
    assert.equal(urls.length,2);
    assert.match(urls[0],/gemini-3\.8-flash/);
    assert.match(urls[1],/gemini-3\.5-flash-lite/);
  });
});

test("continues through model-not-found responses and returns useful retryable quota error",async()=>{
  await withFetch(async()=>{
    let calls=0;
    globalThis.fetch=async()=>{
      calls++;
      return new Response(JSON.stringify({error:{message:"model unavailable"}}),{status:calls===1?404:429});
    };
    const response=await worker.fetch(request({messages:[{role:"user",text:"Hello"}]}),{GEMINI_API_KEY:"test-secret"});
    assert.equal(calls,2);
    assert.equal(response.status,429);
    const data=await response.json();
    assert.equal(data.retryable,true);
    assert.match(data.error,/quota/i);
  });
});

test("rejects an assistant message as the final turn",async()=>{
  const response=await worker.fetch(request({messages:[{role:"assistant",text:"hello"}]}),{GEMINI_API_KEY:"test-secret"});
  assert.equal(response.status,400);
});

test("falls back when Gemini restricts a model for new projects",async()=>{
  await withFetch(async()=>{
    let calls=0;
    globalThis.fetch=async()=>{
      calls++;
      if(calls===1) return new Response(JSON.stringify({error:{message:"This model is no longer available to new users"}}),{status:400});
      return geminiReply("Supported fallback answered.");
    };
    const response=await worker.fetch(request({messages:[{role:"user",text:"Hello"}]}),{GEMINI_API_KEY:"test-secret"});
    assert.equal(response.status,200);
    assert.equal(calls,2);
    assert.equal((await response.json()).answer,"Supported fallback answered.");
  });
});

test("does not retain a Gemini 2.5 model in the fallback configuration",async()=>{
  const source=await import("node:fs/promises").then(fs=>fs.readFile(new URL("../src/index.js",import.meta.url),"utf8"));
  assert.doesNotMatch(source,/gemini-2\\.5-flash-lite/);
  assert.match(source,/gemini-3\\.5-flash-lite/);
});
