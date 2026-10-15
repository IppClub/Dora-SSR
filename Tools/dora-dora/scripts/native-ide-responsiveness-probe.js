// QA only: append this script to a disposable copy of www/index.html after
// defining window.DORA_NATIVE_IDE_PROBE = {outputPath: '/absolute/result.json'}.
// Never ship the instrumented page or inject it into a user's browser session.
(async () => {
 const config = window.DORA_NATIVE_IDE_PROBE;
 if (!config?.outputPath) throw new Error('Missing probe outputPath');
 const post = async (path, body = {}) => {
  const response = await fetch(path, {
   method: 'POST', headers: {'Content-Type': 'application/json'},
   body: JSON.stringify(body), signal: AbortSignal.timeout(45000),
  });
  if (!response.ok) throw new Error(`${path}: HTTP ${response.status}`);
  return response.json();
 };
 const sleep = ms => new Promise(resolve => setTimeout(resolve, ms));
 const deadline = performance.now() + 45000;
 while (!(await post('/status')).typescriptCompiler.webIDEReady) {
  if (performance.now() > deadline) throw new Error('IDE compiler not ready');
  await sleep(500);
 }
 await sleep(config.warmupMs ?? 15000);
 const frames = [], timers = [], longFrames = [], inputToFrame = [], wheelToFrame = [];
 const observe = values => () => { const at = performance.now(); requestAnimationFrame(() => values.push(performance.now() - at)); };
 const onInput = observe(inputToFrame), onWheel = observe(wheelToFrame);
 window.addEventListener("input", onInput, true);
 window.addEventListener("wheel", onWheel, true);
 const started = performance.now();
 let previous = started, lastTimer = started, stopped = false;
 let stressAccepted = 0, stressFailed = 0;
 function frame(now) {
  if (stopped) return;
  const delta = now - previous;
  frames.push(delta);
  if (delta > 100) longFrames.push({at: now - started, delta});
  previous = now;
  requestAnimationFrame(frame);
 }
 requestAnimationFrame(frame);
 const timer = setInterval(() => {
  const now = performance.now();
  timers.push(now - lastTimer); lastTimer = now;
 }, 20);
 const jobs = [];
 const stress = config.stress === false ? null : setInterval(() => {
  jobs.push(post('/command', {
   code: 'local deadline = Dora.App.runningTime + 0.30\nwhile Dora.App.runningTime < deadline\n  _ = 1',
   log: false,
  }).then(result => { if (result.success) stressAccepted++; else stressFailed++; })
    .catch(() => { stressFailed++; }));
 }, 2000);
 await post("/write", {path: config.outputPath + ".ready", content: "recording"});
 await sleep(config.durationMs ?? 20000);
 stopped = true; clearInterval(timer); if (stress !== null) clearInterval(stress);
 window.removeEventListener("input", onInput, true); window.removeEventListener("wheel", onWheel, true);
 await Promise.all(jobs);
 const stats = values => {
  values.sort((a, b) => a - b);
  return {count: values.length, p50: values[Math.floor(values.length * .5)],
   p95: values[Math.floor(values.length * .95)], max: values.at(-1),
   over100: values.filter(value => value > 100).length};
 };
 await post('/write', {path: config.outputPath, content: JSON.stringify({
  raf: stats(frames), timer20ms: stats(timers), inputToFrame: stats(inputToFrame), wheelToFrame: stats(wheelToFrame), longFrames,
  stressAccepted, stressFailed, userAgent: navigator.userAgent,
  viewport: {devicePixelRatio: window.devicePixelRatio, width: window.innerWidth,
   height: window.innerHeight, screenWidth: window.screen.width, screenHeight: window.screen.height},
 })});
})();
