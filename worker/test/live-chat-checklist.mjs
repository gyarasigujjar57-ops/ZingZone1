// Live behavioral checks for the 19 chat/language requirements.
// Run: ZING_WORKER_URL=https://... node worker/test/live-chat-checklist.mjs
// These checks call the deployed Worker and therefore consume real model quota.
const base = (process.env.ZING_WORKER_URL || "").replace(/\/$/, "");
if (!base) {
  console.error("Set ZING_WORKER_URL to the deployed Worker URL.");
  process.exit(2);
}

const has = (re) => (answer) => re.test(answer);
const nontrivial = (answer) => answer.trim().length >= 35;
const cases = [
  ["01 substantive ordinary reply", {messages:[{role:"user",text:"Explain in simple terms why the sky looks blue."}]}, nontrivial],
  ["02 Devanagari Hindi", {messages:[{role:"user",text:"पानी बचाने के तीन आसान तरीके बताओ।"}]}, has(/[\u0900-\u097F]/)],
  ["03 Roman Hindi / Hinglish", {messages:[{role:"user",text:"Mujhe simple Hinglish mein batao ki savings kyun zaroori hai."}]}, has(/(hai|hain|kyunki|paise|bachat|savings|zaroori)/i)],
  ["04 English response", {language:"en",messages:[{role:"user",text:"Explain photosynthesis in two simple sentences."}]}, has(/photosynthesis|plants|sunlight/i)],
  ["05 explicit Gujarati", {language:"gu",messages:[{role:"user",text:"મને પાણી બચાવવાના ત્રણ રસ્તા કહો."}]}, has(/[\u0A80-\u0AFF]/)],
  ["06 automatic latest-language detection", {messages:[{role:"user",text:"Tell me about Rajasthan."},{role:"assistant",text:"Rajasthan is a state in India."},{role:"user",text:"રાજસ્થાનની રાજધાની કઈ છે?"}]}, has(/[\u0A80-\u0AFF]/)],
  ["07 switch language within same chat", {messages:[{role:"user",text:"Answer in English: what is a bank?"},{role:"assistant",text:"A bank is a financial institution."},{role:"user",text:"अब हिंदी में बताओ कि बैंक क्या करता है।"}]}, has(/[\u0900-\u097F]/)],
  ["08 difficult English explained in simple Hindi", {messages:[{role:"user",text:"'Inflation' ka difficult English meaning simple Hindi mein samjhao, ek example bhi do."}]}, has(/[\u0900-\u097F]/)],
  ["09 translation preserves meaning", {language:"en",messages:[{role:"user",text:"Translate into English: मेरा आवेदन अभी अधूरा है और मुझे दो दस्तावेज़ जमा करने हैं।"}]}, (a)=>/application|form/i.test(a)&&/incomplete|not complete|unfinished/i.test(a)&&/two|2/i.test(a)&&/document/i.test(a)],
  ["10 bilingual answer", {messages:[{role:"user",text:"Explain what a deadline means. Give the answer in both Hindi and English."}]}, (a)=>/[\u0900-\u097F]/.test(a)&&/deadline/i.test(a)],
  ["11 long multi-part question", {messages:[{role:"user",text:"Explain these three separately: (1) what is a bank account, (2) why is a passbook useful, and (3) what should I do if an entry looks wrong?"}]}, (a)=>/passbook/i.test(a)&&/(entry|transaction)/i.test(a)&&/(bank account|account)/i.test(a)],
  ["12 short direct question", {messages:[{role:"user",text:"What is the capital of Rajasthan? Reply directly."}]}, has(/Jaipur/i)],
  ["13 previous-message context", {messages:[{role:"user",text:"For this chat, call my sample project Falcon."},{role:"assistant",text:"Okay, I will refer to your sample project as Falcon."},{role:"user",text:"What did I name my sample project?"}]}, has(/Falcon/)],
  ["14 connect related questions", {messages:[{role:"user",text:"I am learning percentages."},{role:"assistant",text:"Okay, we can practise percentages."},{role:"user",text:"If a price is ₹200 and discount is 10%, what is the discount and final price?"}]}, (a)=>/20/.test(a)&&/180/.test(a)],
  ["15 clarify missing/ambiguous information", {messages:[{role:"user",text:"Am I eligible for it?"}]}, (a)=>/(which|what|किस|कौन|details|जानकारी|scheme|योजना|form|भर्ती)/i.test(a)],
  ["16 mathematics with checked calculation", {messages:[{role:"user",text:"A number is 25% of 240. Calculate it and show a short method."}]}, (a)=>/60/.test(a)],
  ["17 science / GK explanation", {messages:[{role:"user",text:"Why does ice float on water? Explain scientifically but simply."}]}, (a)=>/(density|घनत्व)/i.test(a)&&/(water|पानी)/i.test(a)],
  ["18 writing and practical planning", {messages:[{role:"user",text:"Write a polite 3-line Hindi message asking my teacher for one extra day to submit homework."}]}, (a)=>/[\u0900-\u097F]/.test(a)&&a.trim().length>=35],
  ["19 honest uncertainty / no fabrication", {messages:[{role:"user",text:"Who will win the 2043 Rajasthan state election? Give the confirmed winner and exact vote count."}]}, (a)=>/(cannot|can't|not possible|unknown|भविष्य|अभी.*नहीं|पता नहीं|निश्चित नहीं|घोषित नहीं)/i.test(a)]
];

let passed=0;
const failures=[];
for (const [name,payload,check] of cases) {
  try {
    let response, data;
    for (let attempt=1; attempt<=3; attempt++) {
      response=await fetch(base+"/",{
        method:"POST",
        headers:{"content-type":"application/json"},
        body:JSON.stringify(payload)
      });
      data=await response.json();
      if ((response.status!==429 && !(response.status>=500 && data.retryable===true)) || attempt===3) break;
      console.log("RETRYABLE AI CAPACITY/QUOTA ERROR "+name+"; retrying after "+(attempt*12000)+" ms");
      await new Promise(resolve=>setTimeout(resolve,attempt*12000));
    }
    if (!response.ok) throw new Error("HTTP "+response.status+": "+(data.error||"request failed"));
    if (typeof data.answer!=="string" || !data.answer.trim()) throw new Error("empty answer");
    if (!check(data.answer)) throw new Error("answer did not satisfy expected behavior; output: "+data.answer.slice(0,240));
    passed++;
    console.log("PASS "+name+" ["+(data.model||"model unknown")+"]");
  } catch (error) {
    failures.push({name,error:String(error)});
    console.log("FAIL "+name+" — "+String(error));
  }
  if (name!==cases[cases.length-1][0]) await new Promise(resolve=>setTimeout(resolve,1500));
}
console.log("\nRESULT: "+passed+"/"+cases.length+" passed; "+failures.length+" failed.");
if (failures.length) process.exitCode=1;
