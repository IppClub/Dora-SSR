import assert from 'node:assert/strict';
import {createRequire} from 'node:module';
import {mkdir,writeFile} from 'node:fs/promises';

const require=createRequire(import.meta.url);
const {chromium}=require(process.env.STUDIO_PLAYWRIGHT_MODULE||'playwright');
const origin=process.env.STUDIO_ACCEPTANCE_URL;
const hostOrigin=process.env.STUDIO_AGENT_TEST_HOST_URL;
const fixtureURL=process.env.STUDIO_FIXTURE_URL;
const invite=process.env.STUDIO_ACCEPTANCE_INVITE;
if(!origin||!hostOrigin||!fixtureURL||!invite)throw new Error('Studio URL, Agent Host URL, fixture URL and bootstrap invite are required');

const browser=await chromium.launch({headless:true,args:['--enable-unsafe-swiftshader'],...(process.env.STUDIO_CHROME_PATH?{executablePath:process.env.STUDIO_CHROME_PATH}:{})});
const errors=[];
const httpFailures=[];
const report={adminConfigured:false,creatorAuthorized:false,round1Completed:false,round2Completed:false,round3Completed:false,threeWritebacksPassed:false,threeBuildsPassed:false,threePreviewsPassed:false,playerRunPassed:false,pointerInputPassed:false,ledgerSettledEachRound:false,consoleErrors:errors,httpFailures};
async function openStudio(page){
  let lastError;
  for(let attempt=0;attempt<3;attempt++){
    await page.goto(origin,{waitUntil:'domcontentloaded'});
    try{await page.getByRole('button',{name:'登录 / 邀请码注册'}).waitFor({timeout:10000});return;}
    catch(error){lastError=error;}
  }
  throw new Error(`Studio did not render its login entry: ${JSON.stringify({url:page.url(),body:(await page.locator('body').innerText()).slice(0,1000),errors})}`,{cause:lastError});
}
let adminContext,creatorContext;
try{
  adminContext=await browser.newContext({ignoreHTTPSErrors:true});
  const admin=await adminContext.newPage();
  admin.on('pageerror',error=>errors.push(error.message));
  admin.on('console',message=>{if(message.type()==='error'&&!message.text().startsWith('Failed to load resource:'))errors.push(message.text());});
  admin.on('response',response=>{if(response.status()>=400)httpFailures.push({status:response.status(),url:response.url()});});
  await openStudio(admin);
  await admin.getByRole('button',{name:'登录 / 邀请码注册'}).click();
  await admin.getByRole('button',{name:'邀请码注册',exact:true}).click();
  await admin.getByLabel('邀请码').fill(invite);
  await admin.getByLabel('账号名').fill('go-agent-admin');
  await admin.getByLabel('密码').fill('go-agent-admin-password-123');
  await admin.getByRole('button',{name:'创建账号并登录'}).click();
  await admin.getByText('账号已连接').waitFor();

  await admin.getByRole('button',{name:'共享 API 管理',exact:true}).click();
  const pool=admin.getByRole('dialog',{name:'共享 API 管理'});
  await pool.getByRole('button',{name:'导入共享 API 配置'}).click();
  await pool.getByLabel('配置名称').fill('Go Agent 验收模型');
  await pool.getByLabel('共享供应商').selectOption('openai');
  await pool.getByLabel('模型标识').fill('fixture-model');
  await pool.getByLabel('输入单价').fill('1');
  await pool.getByLabel('输出单价').fill('2');
  await pool.getByRole('button',{name:'保存配置（默认停用）'}).click();
  await pool.getByText('尚未导入或已撤销',{exact:false}).waitFor();
  await pool.getByLabel('共享 API Key').fill('test-only-browser-provider-key');
  await pool.getByRole('button',{name:'加密保存密钥'}).click();
  await pool.getByText('已加密托管',{exact:false}).waitFor();
  await pool.getByLabel('API 最大并发').fill('2');
  await pool.getByRole('button',{name:'保存 API 并发'}).click();
  await pool.getByText('0/2 正在使用',{exact:false}).waitFor();
  await pool.getByRole('button',{name:'启用共享配置'}).click();
  await pool.getByText('已启用 · 配置 v',{exact:false}).waitFor();
  assert.equal(await pool.getByText('test-only-browser-provider-key').count(),0);
  await pool.getByRole('button',{name:'关闭共享 API 管理'}).click();
  report.adminConfigured=true;

  await admin.getByRole('button',{name:'账号管理'}).click();
  await admin.getByRole('button',{name:'邀请新账号'}).click();
  await admin.getByRole('button',{name:'生成邀请码'}).click();
  const creatorInvite=await admin.locator('.admin-invitation code').innerText();
  await admin.getByRole('button',{name:'关闭账号管理'}).click();

  creatorContext=await browser.newContext({ignoreHTTPSErrors:true});
  const creator=await creatorContext.newPage();
  creator.on('pageerror',error=>errors.push(error.message));
  creator.on('console',message=>{if(message.type()==='error'&&!message.text().startsWith('Failed to load resource:'))errors.push(message.text());});
  creator.on('response',response=>{if(response.status()>=400)httpFailures.push({status:response.status(),url:response.url()});});
  await openStudio(creator);
  await creator.getByRole('button',{name:'登录 / 邀请码注册'}).click();
  await creator.getByRole('button',{name:'邀请码注册',exact:true}).click();
  await creator.getByLabel('邀请码').fill(creatorInvite);
  await creator.getByLabel('账号名').fill('go-agent-creator');
  await creator.getByLabel('密码').fill('go-agent-creator-password-123');
  await creator.getByRole('button',{name:'创建账号并登录'}).click();
  await creator.getByText('账号已连接').waitFor();

  await admin.getByRole('button',{name:'共享 API 管理',exact:true}).click();
  const allowances=admin.getByRole('dialog',{name:'共享 API 管理'});
  await allowances.getByRole('button',{name:'账号与逐 API 授权'}).click();
  await allowances.getByLabel('搜索额度账号').fill('agent-creator');
  const creatorRow=allowances.locator('.allowance-account-list > div').filter({hasText:'go-agent-creator'});
  await creatorRow.waitFor();await creatorRow.getByRole('checkbox').check();
  await allowances.getByLabel('批量账号金额上限').fill('10');
  await allowances.getByLabel('批量账号模型并发').fill('2');
  await allowances.getByLabel('同时为这些账号设置逐 API 额度').check();
  await allowances.getByLabel('批量授权 API').selectOption({label:'Go Agent 验收模型 · 可用'});
  await allowances.getByLabel('批量逐 API 金额上限').fill('5');
  await allowances.getByLabel('批量逐 API 并发').fill('1');
  await allowances.getByRole('button',{name:'应用到 1 个账号'}).click();
  await allowances.getByText('已为 1 个账号统一保存额度和逐 API 授权。').waitFor();
  await mkdir('apps/web/artifacts/go-agent-multiround',{recursive:true});
  await allowances.getByText('找到 1 个账号').waitFor();
  await allowances.locator('.admin-model-body').evaluate(element=>{element.scrollTop=0;});
  await allowances.evaluate(element=>{element.scrollTop=0;window.scrollTo(0,0);});
  await admin.screenshot({path:'apps/web/artifacts/go-agent-multiround/admin-allowances.png',fullPage:true});
  await allowances.getByRole('button',{name:'关闭共享 API 管理'}).click();
  report.creatorAuthorized=true;

  await creator.reload();
  await creator.getByText('账号已连接').waitFor();
  await creator.locator('.idea-model-select').getByRole('button',{name:'刷新'}).click();
  const grantDiagnostic=await creator.evaluate(async()=>{const response=await fetch('/api/model-grants?after=&limit=20');return {status:response.status,body:await response.text()};});
  if(grantDiagnostic.status!==200)throw new Error(`grant API unavailable: ${JSON.stringify(grantDiagnostic)}`);
  if(!JSON.parse(grantDiagnostic.body).configurations?.some(item=>item.label==='Go Agent 验收模型'&&item.model==='fixture-model'&&item.enabled))throw new Error(`grant is not ready: ${grantDiagnostic.body}`);
  await creator.waitForFunction(()=>[...document.querySelectorAll('#game-model option')].some(option=>option.textContent?.includes('Go Agent 验收模型 · fixture-model')),{timeout:30000});
  await creator.getByLabel('本次创作使用的共享模型').selectOption({label:'Go Agent 验收模型 · fixture-model'});
  const readAllowance=()=>creator.evaluate(async()=>{
    const grants=await (await fetch('/api/model-grants?after=&limit=20')).json();
    const grantId=grants.configurations[0].grantId;
    return (await fetch(`/api/model-grants/${encodeURIComponent(grantId)}/allowance`)).json();
  });
  const assertSettled=(allowance,previousSpent)=>{
    assert.ok(BigInt(allowance.account.spent)>previousSpent&&BigInt(allowance.grant.spent)>previousSpent,JSON.stringify(allowance));
    assert.equal(allowance.account.reserved,'0');assert.equal(allowance.grant.reserved,'0');
  };
  const openResourcesAndWaitFor=async marker=>{
    await creator.getByRole('button',{name:'资源',exact:true}).click();
    await creator.waitForFunction(expected=>document.querySelector('textarea[aria-label="项目代码"]')?.value.includes(expected),marker,{timeout:30000});
    return creator.getByLabel('项目代码').inputValue();
  };
  const returnToAgent=()=>creator.getByRole('button',{name:'Dora Agent',exact:true}).click();
  const roundAllowances=[];

  await creator.getByLabel('游戏创意').fill('先完成基础平台、角色和点击玩法，并使用工具构建和试玩。');
  await creator.getByRole('button',{name:'新建并启动 Agent 创作'}).click();
  try{await creator.locator(`iframe[src^="${hostOrigin}/agent-host/"]`).waitFor({state:'attached',timeout:30000});}
  catch(error){throw new Error(`Agent iframe did not attach: ${JSON.stringify({alerts:await creator.getByRole('alert').allInnerTexts(),body:(await creator.locator('body').innerText()).slice(0,4000)})}`,{cause:error});}
  await creator.getByLabel('当前 Agent 任务').getByText('已完成',{exact:true}).waitFor({timeout:90000});
  const source1=await openResourcesAndWaitFor('RICH_GAME_ROUND1_READY');
  assert.match(source1,/RICH_GAME_ROUND1_READY/);
  const allowance1=await readAllowance();assertSettled(allowance1,0n);roundAllowances.push(allowance1);
  report.round1Completed=true;

  await returnToAgent();
  const rainPrompt='增加雨滴效果和更丰富的场景反馈，并重新构建试玩。';
  await creator.getByLabel('Agent 描述').fill(rainPrompt);
  await creator.getByRole('button',{name:'发送 ↑',exact:true}).click();
  await creator.getByLabel('当前 Agent 任务').getByText(rainPrompt,{exact:true}).waitFor({timeout:30000});
  await creator.getByLabel('当前 Agent 任务').getByText('已完成',{exact:true}).waitFor({timeout:90000});
  const source2=await openResourcesAndWaitFor('RICH_GAME_RAIN_READY');
  assert.match(source2,/RICH_GAME_RAIN_READY/);assert.match(source2,/0xff3b82f6/);
  const allowance2=await readAllowance();assertSettled(allowance2,BigInt(allowance1.account.spent));roundAllowances.push(allowance2);
  report.round2Completed=true;

  await returnToAgent();
  const starsPrompt='再增加星光收集目标、终点标识和更完整的视觉层次，并完成最终构建试玩。';
  await creator.getByLabel('Agent 描述').fill(starsPrompt);
  await creator.getByRole('button',{name:'发送 ↑',exact:true}).click();
  await creator.getByLabel('当前 Agent 任务').getByText(starsPrompt,{exact:true}).waitFor({timeout:30000});
  await creator.getByLabel('当前 Agent 任务').getByText('已完成',{exact:true}).waitFor({timeout:90000});
  const source3=await openResourcesAndWaitFor('RICH_GAME_FINAL_READY');
  assert.match(source3,/RICH_GAME_FINAL_READY/);assert.match(source3,/0xffffc857/);assert.match(source3,/0xffb56cff/);
  const allowance3=await readAllowance();assertSettled(allowance3,BigInt(allowance2.account.spent));roundAllowances.push(allowance3);
  report.round3Completed=true;report.threeWritebacksPassed=true;report.ledgerSettledEachRound=true;

  const statsResponse=await creator.request.get(fixtureURL+'/stats');
  assert.equal(statsResponse.status(),200);
  const stats=await statsResponse.json();
  assert.ok(stats.calls>=9,`expected at least edit/build/preview model turns in each of three rounds, got ${stats.calls}`);
  for(const name of ['initial','rain','stars']){
    assert.equal(stats.rounds[name].buildSucceeded,true,`${name} build failed: ${JSON.stringify(stats.rounds[name].buildReport)}`);
    assert.equal(stats.rounds[name].previewSucceeded,true,`${name} preview failed: ${JSON.stringify(stats.rounds[name].previewReport)}`);
    assert.equal(stats.rounds[name].previewFrameCount,1,`${name} preview frame count`);
  }
  report.threeBuildsPassed=true;report.threePreviewsPassed=true;

  const hostFrame=creator.frames().find(frame=>frame.url().startsWith(hostOrigin+'/agent-host/'));
  assert.ok(hostFrame,'dedicated Agent host must remain connected');
  const captures=await hostFrame.evaluate(async()=>{
    const dir='/user/studio-project/.agent/vision';
    const files=Module.FS.readdir(dir).filter(name=>name.endsWith('.png')).sort();
    if(files.length!==3)throw new Error(`expected three Agent preview captures, got ${files.length}`);
    const results=[];
    for(const name of files){
      const bytes=Module.FS.readFile(dir+'/'+name);
      const bitmap=await createImageBitmap(new Blob([new Uint8Array(bytes)],{type:'image/png'}));
      const canvas=new OffscreenCanvas(bitmap.width,bitmap.height),context=canvas.getContext('2d');
      context.drawImage(bitmap,0,0);const pixels=context.getImageData(0,0,bitmap.width,bitmap.height).data;
      let greenPixels=0,bluePixels=0,yellowPixels=0;const quadrantPixels=[0,0,0,0];
      for(let index=0;index<pixels.length;index+=4){const pixel=index/4,x=pixel%bitmap.width,y=Math.floor(pixel/bitmap.width),r=pixels[index],g=pixels[index+1],b=pixels[index+2];if(g>=30&&g>r+10&&g>b+5)greenPixels++;if(b>150&&b>r+40)bluePixels++;if(r>180&&g>140&&b<130)yellowPixels++;if(Math.abs(r-26)+Math.abs(g-26)+Math.abs(b-26)>12)quadrantPixels[(y>=bitmap.height/2?2:0)+(x>=bitmap.width/2?1:0)]++;}
      results.push({name,bytes:[...bytes],width:bitmap.width,height:bitmap.height,greenPixels,bluePixels,yellowPixels,quadrantPixels});bitmap.close();
    }
    return results;
  });
  const previewMetrics=captures.map(({bytes,...capture})=>capture);
  assert.equal(captures.length,3);assert.ok(captures.every(c=>c.width>0&&c.height>0&&c.greenPixels>5000),JSON.stringify(previewMetrics));
  assert.ok(captures.every(c=>c.quadrantPixels.every(count=>count>1000)),`game scene must be visible in all four viewport quadrants: ${JSON.stringify(previewMetrics)}`);
  assert.ok(captures.slice(1).every(c=>c.bluePixels>100),JSON.stringify(previewMetrics));
  assert.ok(captures.at(-1).yellowPixels>100,JSON.stringify(previewMetrics.at(-1)));

  await creator.getByRole('button',{name:/编译项目/}).click();
  await creator.getByText(/编译成功 · \d+ 个产物文件/).waitFor({timeout:30000});
  await creator.getByRole('button',{name:'运行游戏',exact:true}).click();
  await creator.getByText('正在运行',{exact:true}).waitFor({timeout:30000});
  await creator.locator('.runtime-logs summary').click();
  await creator.getByLabel('游戏运行日志').getByText(/RICH_GAME_FINAL_READY/).waitFor({timeout:30000});
  report.playerRunPassed=true;
  const runtimeCanvas=creator.frameLocator('.runtime-surface iframe').locator('#canvas');
  const canvasBox=await runtimeCanvas.boundingBox();assert.ok(canvasBox,'runtime canvas must be visible');
  await runtimeCanvas.click({position:{x:canvasBox.width*0.65,y:canvasBox.height*0.35}});
  await creator.getByLabel('游戏运行日志').getByText(/RICH_GAME_TAPPED/).waitFor({timeout:10000});
  report.pointerInputPassed=true;
  assert.deepEqual(errors,[]);
  const expectedHTTP=failure=>failure.status===401&&failure.url.endsWith('/api/session')
    ||failure.status===403&&(/\/api\/admin\/(accounts|shared-models)\?limit=1$/.test(failure.url))
    ||failure.status===404&&failure.url.endsWith('/api/admin/model-accounts/go-agent-creator');
  assert.deepEqual(httpFailures.filter(failure=>!expectedHTTP(failure)),[],'unexpected HTTP failures');

  const artifacts='apps/web/artifacts/go-agent-multiround';
  await mkdir(artifacts,{recursive:true});
  for(let index=0;index<captures.length;index++)await writeFile(`${artifacts}/round-${index+1}.png`,Uint8Array.from(captures[index].bytes));
  await creator.screenshot({path:artifacts+'/final-game-running.png',fullPage:true});
  await writeFile(artifacts+'/result.json',JSON.stringify({...report,providerCalls:stats.calls,providerRounds:stats.rounds,previews:previewMetrics,roundAllowances},null,2));
  process.stdout.write(JSON.stringify(report)+'\n');
}finally{
  await creatorContext?.close();
  await adminContext?.close();
  await browser.close();
}
