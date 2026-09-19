// Run against the static prototype server; no real model or cloud service.
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { chromium } = require(process.env.STUDIO_PLAYWRIGHT_MODULE || 'playwright');
const base = process.env.STUDIO_PROTOTYPE_URL || 'http://127.0.0.1:8897';
(async () => {
  const browser = await chromium.launch({headless:true, ...(process.env.STUDIO_CHROME_PATH ? {executablePath:process.env.STUDIO_CHROME_PATH} : {})});
  const page = await browser.newPage({viewport:{width:1440,height:1000}});
  const errors=[]; page.on('pageerror',error=>errors.push(error.message));
  const click = async action=>{if(action==='generate' && !(await page.locator('#followup').inputValue()).trim()) await page.locator('#followup').fill('继续调整这个游戏（测试描述）');await page.locator(`[data-action="${action}"]`).first().click();};
  const nav = name=>page.locator(`.sidebar [data-page="${name}"]`).click();
  const scenario = async name=>{await page.locator('.scenario-tools').evaluate(el=>el.open=true);await page.locator(`[data-scenario="${name}"]`).click();};
  const finish = ()=>page.waitForFunction(()=>document.getElementById('agent-progress').textContent.includes('此次示意流程结束'));
  await page.goto(base); await nav('workspace'); assert.equal(await page.locator('#send').isDisabled(),true); await nav('home'); await click('create'); await finish();
  assert.match(await page.locator('#run-version').textContent(),/r2/);
  await nav('models'); assert.match(await page.locator('#model-balance').textContent(),/119\.66/);
  await nav('workspace'); await page.locator('[data-tab="code"]').click(); await page.locator('#source').fill('// 手动编辑');
  assert.match(await page.locator('#run-version').textContent(),/有未运行修改/); await click('run');
  assert.doesNotMatch(await page.locator('#run-version').textContent(),/有未运行修改/);
  await click('publish'); await page.locator('#dialog-confirm').click();
  assert.match(await page.locator('#source-state').textContent(),/私有/); await click('clone-work'); assert.match(await page.locator('#toast').textContent(),/拒绝/);
  await page.locator('#open-source').check(); await click('save-sharing'); await click('clone-work'); assert.match(await page.locator('#project-title').textContent(),/Remix/);
  await scenario('quota'); await click('generate'); assert.match(await page.locator('#state-banner').textContent(),/额度不足/);
  await scenario('queued'); await click('generate'); assert.match(await page.locator('#agent-progress').textContent(),/等待/);
  await scenario('normal'); await click('resume'); await finish();
  await scenario('compile'); await click('generate'); await page.waitForFunction(()=>document.getElementById('agent-progress').textContent.includes('编译失败'));
  assert.match(await page.locator('#run-version').textContent(),/有未运行修改/);
  await scenario('normal'); await click('generate'); await click('connection');
  assert.match(await page.locator('#agent-progress').textContent(),/暂停/); assert.equal(await page.locator('#send').isDisabled(),true);
  await click('connection'); await click('resume'); await finish();
  await scenario('usage'); await click('generate'); await finish(); await nav('admin');
  await page.locator('[data-admin-tab="billing"]').click(); assert.match(await page.locator('#pending-billing').textContent(),/0\.80/);
  await click('resolve-billing'); assert.match(await page.locator('#toast').textContent(),/原因/);
  await page.locator('#billing-reason').fill('供应商确认未计费，演示释放'); await click('resolve-billing'); assert.match(await page.locator('#pending-billing').textContent(),/没有暂挂/);
  await nav('home'); await click('import'); await page.locator('#package-file').setInputFiles({name:'native.dora',mimeType:'application/zip',buffer:Buffer.from('not-an-archive-demo')}); await page.locator('#import-incompatible').check(); await page.locator('#dialog-confirm').click(); assert.match(await page.locator('#state-banner').textContent(),/保留可编辑/);
  await nav('home'); await click('clone'); await page.locator('#clone-url').fill('https://arbitrary-host.example.invalid/team/game.git'); await page.locator('#clone-rights').check(); await page.locator('#dialog-confirm').click(); assert.match(await page.locator('#project-title').textContent(),/链接项目/);
  await nav('models'); await click('byok-add'); await page.locator('#model-choice').selectOption('byok'); const before=await page.locator('#model-balance').textContent(); await nav('workspace'); await click('generate'); await finish(); await nav('models'); assert.equal(await page.locator('#model-balance').textContent(),before);
  // Product acceptance: independent drafts, publish gate, and immutable Remix source.
  await nav('workspace'); await click('rename'); await page.locator('#project-name').fill('产品验收项目'); await page.locator('#dialog-confirm').click();
  await page.locator('[data-tab="code"]').click(); await page.locator('#source').fill('// published acceptance source');
  await click('publish'); await page.locator('#dialog-confirm').click(); assert.equal(await page.locator('#dialog').isVisible(),true);
  await page.getByRole('button',{name:'关闭对话框'}).click(); await click('run'); await click('publish'); await page.locator('#dialog-confirm').click();
  assert.equal(await page.locator('#work h1').textContent(),'产品验收项目');
  await page.locator('#open-source').check(); await click('save-sharing');
  await nav('workspace'); await page.locator('[data-tab="code"]').click(); await page.locator('#source').fill('// unpublished draft');
  await nav('work'); await click('clone-work'); await page.locator('[data-tab="code"]').click(); assert.equal(await page.locator('#source').inputValue(),'// published acceptance source');
  await nav('home'); await page.locator('.recent-project').filter({hasText:'产品验收项目'}).last().click(); await page.locator('[data-tab="code"]').click();
  assert.equal(await page.locator('#source').inputValue(),'// unpublished draft');
  await nav('home'); await click('blank'); assert.equal(await page.locator('#game').isVisible(),false); assert.equal(await page.locator('#preview-empty').isVisible(),true);
  await page.locator('#followup').fill('主动暂停测试'); await click('generate'); await click('pause'); assert.equal(await page.locator('#resume').isVisible(),true); await click('resume'); await finish();
  const artifacts=path.join(__dirname,'artifacts');fs.mkdirSync(artifacts,{recursive:true});
  await page.reload(); await nav('home'); await page.screenshot({path:path.join(artifacts,'home-desktop.png'),fullPage:true});
  await click('create'); await finish(); await click('show-preview'); await page.locator('.scenario-tools').evaluate(el=>el.open=false); await page.screenshot({path:path.join(artifacts,'workspace-desktop.png'),fullPage:true});
  for(const width of [1024,736,390,320]){
    await page.setViewportSize({width,height:1000});
    for(const name of ['home','workspace','models','work','admin']){
      await nav(name); const overflow=await page.evaluate(()=>document.documentElement.scrollWidth>innerWidth+1); assert.equal(overflow,false,`${name} overflow at ${width}`);
    }
    if(width===390){
      await nav('workspace');await click('show-preview');await page.waitForTimeout(3500);await page.screenshot({path:path.join(artifacts,'workspace-mobile.png'),fullPage:true});
      await page.locator('[data-mobile-pane="agent"]').filter({hasText:'Dora Agent'}).click();
      assert.equal(await page.locator('.agent-pane').isVisible(),true);
      assert.equal(await page.locator('.preview-pane').isVisible(),false);
      await page.screenshot({path:path.join(artifacts,'agent-mobile.png'),fullPage:true});
      await page.locator('button[data-mobile-pane="preview"]').click();
      assert.equal(await page.locator('.preview-pane').isVisible(),true);
    }
  }
  assert.deepEqual(errors,[]); await browser.close(); console.log('PASS: creation, revisions, publish/privacy, Remix, quota, queue, compilation failure, pause/resume, pending usage, ZIP, generic Git, BYOK, responsive layouts; no page errors.');
})().catch(error=>{console.error(error);process.exit(1);});
