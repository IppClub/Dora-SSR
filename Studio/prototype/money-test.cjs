// Amount-first prototype acceptance. Example CNY rates, never a real model call.
const assert = require('node:assert/strict');
const {chromium} = require(process.env.STUDIO_PLAYWRIGHT_MODULE || 'playwright');
(async()=>{
  const browser=await chromium.launch({headless:true,...(process.env.STUDIO_CHROME_PATH?{executablePath:process.env.STUDIO_CHROME_PATH}:{})});
  try {
    const page=await browser.newPage({viewport:{width:1440,height:1000}});
    const errors=[];page.on('pageerror',e=>errors.push(e.message));
    const nav=n=>page.locator('.sidebar [data-page="'+n+'"]').click();
    const act=n=>page.locator('[data-action="'+n+'"]').first().click();
    const text=id=>page.locator('#'+id).textContent();
    const finish=()=>page.getByText('此次示意流程结束 · 示意运行已就绪',{exact:true}).waitFor();
    const generate=async()=>{await page.locator('#followup').fill('演示费用检查');await act('generate');};
    const scenario=async n=>{if(await page.locator('.scenario-tools').getAttribute('open')===null)await page.locator('.scenario-tools summary').click();await page.locator('[data-scenario="'+n+'"]').click();};
    await page.goto(process.env.STUDIO_PROTOTYPE_URL || 'http://127.0.0.1:8897');
    await nav('models');assert.equal(await text('usable-credit'),'¥80.00');assert.equal(await text('model-balance'),'¥120.00');
    await nav('workspace');await generate();await act('pause');await nav('models');
    assert.equal(await text('held-credit'),'¥0.80');assert.equal(await text('spent-credit'),'¥0.00');assert.equal(await text('usable-credit'),'¥79.20');
    await nav('workspace');await act('resume');await finish();await nav('models');
    assert.equal(await text('model-balance'),'¥119.66');assert.equal(await text('usable-credit'),'¥79.66');assert.equal(await text('spent-credit'),'¥0.34');assert.equal(await text('held-credit'),'¥0.00');
    await nav('admin');await page.locator('[data-admin-tab="grants"]').click();
    await page.locator('#account-quota').fill('10.00');await page.locator('#grant-quota').fill('50.00');await act('save-grants');await nav('models');
    assert.equal(await text('usable-credit'),'¥10.00');
    await nav('admin');await page.locator('[data-admin-tab="pool"]').click();
    await page.locator('#input-rate').fill('2');await page.locator('#output-rate').fill('6');await act('save-pool');await nav('models');
    assert.match(await text('request-price'),/¥0\.68/);assert.match(await text('request-reserve'),/¥1\.60/);
    await nav('workspace');await generate();await finish();await nav('models');
    assert.equal(await text('usable-credit'),'¥9.32');assert.equal(await text('spent-credit'),'¥1.02');
    assert.match(await text('ledger'),/¥0\.34/);assert.match(await text('ledger'),/¥0\.68/);
    await nav('workspace');await scenario('usage');await generate();await finish();await nav('models');
    assert.equal(await text('usable-credit'),'¥7.72');assert.match(await text('held-credit'),/¥1\.60.*待核对/);assert.equal(await text('spent-credit'),'¥1.02');
    await nav('admin');await page.locator('[data-admin-tab="billing"]').click();await page.locator('#billing-reason').fill('示例：供应商确认无需计费');await act('resolve-billing');
    await nav('models');assert.equal(await text('usable-credit'),'¥9.32');
    await act('byok-add');await page.locator('#model-choice').selectOption('byok');assert.equal(await text('usable-credit'),'0');
    const balance=await text('model-balance');await nav('workspace');await scenario('normal');await generate();await finish();await nav('models');
    assert.equal(await text('model-balance'),balance);assert.equal(await text('usable-credit'),'180,000');
    assert.equal(await text('byok-calls'),'1');assert.equal(await text('byok-input'),'100,000');assert.equal(await text('byok-output'),'80,000');
    assert.match(await text('ledger'),/100,000/);assert.match(await text('ledger'),/80,000/);
    await nav('workspace');await scenario('usage');await generate();await finish();await nav('models');
    assert.equal(await text('byok-calls'),'2');assert.equal(await text('usable-credit'),'180,000');
    assert.match(await text('byok-coverage'),/1 次未返回/);assert.match(await text('ledger'),/用量待补记/);
    assert.equal(await text('model-balance'),balance);assert.equal(await text('held-credit'),'¥0.00');
    await nav('workspace');await scenario('normal');await generate();await act('pause');await act('resume');await finish();await nav('models');
    assert.equal(await text('byok-calls'),'3');assert.equal(await text('usable-credit'),'360,000');
    assert.equal(await text('byok-input'),'200,000');assert.equal(await text('byok-output'),'160,000');
    assert.equal(await text('spent-credit'),'¥1.02');
    await page.screenshot({path:require('node:path').join(__dirname,'artifacts','byok-usage.png'),fullPage:true});
    await page.locator('#model-choice').selectOption('shared');
    await nav('admin');await page.locator('[data-admin-tab="pool"]').click();await act('pool-toggle');await nav('models');assert.equal(await text('usable-credit'),'¥0.00');
    await nav('admin');await act('pool-toggle');await page.locator('#input-rate').fill('0');await page.locator('#output-rate').fill('0');await act('save-pool');
    await nav('workspace');await generate();await act('pause');assert.equal(await page.locator('#cancel-queue').isVisible(),false);await act('resume');await finish();
    await nav('models');assert.equal(await text('model-balance'),balance);
    await page.screenshot({path:require('node:path').join(__dirname,'artifacts','money-desktop.png'),fullPage:true});
    for(const width of [1024,736,390,320]){
      await page.setViewportSize({width,height:1000});
      for(const route of ['home','workspace','models','admin']){
        await nav(route);assert.equal(await page.evaluate(()=>document.documentElement.scrollWidth>innerWidth+1),false,route+' overflow '+width);
      }
    }
    assert.deepEqual(errors,[]);console.log('PASS: CNY balances, min-cap, reservation/refund, actual spend, rate changes, pending review, BYOK unknown cost, disabled config, zero-rate resume, responsive layouts.');
  } finally {await browser.close();}
})().catch(e=>{console.error(e);process.exit(1);});
