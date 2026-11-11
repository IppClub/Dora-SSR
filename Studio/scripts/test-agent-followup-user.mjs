import assert from 'node:assert/strict';
import {writeFile} from 'node:fs/promises';
import {resolve} from 'node:path';

/** Browser actions against the production composer and real Lua/WASM Session. */
export async function runUserTest({browser,baseUrl,output,requests}){
 const page=await browser.newPage({viewport:{width:1280,height:900}}),checks=[],errors=[];
 page.on('pageerror',error=>errors.push(error.message));
 const input=page.getByRole('textbox',{name:'Agent 描述'}),queue=()=>page.getByLabel('后续消息',{exact:true});
 const row=text=>queue().locator('[data-agent-input-id]').filter({hasText:text});
 const delivered=()=>page.getByRole('region',{name:'已投递消息'});
 async function check(name,action){await action();checks.push({name,result:'passed'});console.log('PASS: '+name);}
 async function sent(text,key='Enter'){await input.fill(text);await input.press(key);await page.waitForFunction(()=>document.querySelector('textarea[aria-label="Agent 描述"]')?.value==='');}
 async function idle(){await page.waitForFunction(()=>window.userTestState?.idle&&!(window.userTestState.detail.session.pendingInputs?.length),null,{timeout:30000});}

 try{
  await page.goto(baseUrl+'/user-test');
  await page.getByRole('status').filter({hasText:'Agent 已空闲'}).waitFor({timeout:30000});
  const modifier=await page.evaluate(()=>/Mac|iPhone|iPad/.test(navigator.platform))?'Meta':'Control';
  await check('点击发送启动任务，运行中仍可输入',async()=>{
   await input.fill('创建一个躲避小游戏');await page.getByRole('button',{name:'发送',exact:true}).click();
   await page.getByRole('status').filter({hasText:'Agent 正在运行'}).waitFor();assert.equal(await input.isEnabled(),true);
   assert.equal(await row('创建一个躲避小游戏').count(),0,'initial prompt must only appear in conversation');
   await delivered().getByText('创建一个躲避小游戏',{exact:true}).waitFor();
   assert.equal(await page.getByRole('button',{name:'停止',exact:true}).count(),1);assert.equal(await page.getByRole('button',{name:'加入队列',exact:true}).count(),0);
   await input.fill('未发送草稿');assert.equal(await page.getByRole('button',{name:'停止',exact:true}).count(),0);assert.equal(await page.getByRole('button',{name:'加入队列',exact:true}).count(),1);await input.fill('');
  });
  await check('Enter 排队、点击排队，发送后清空输入',async()=>{
   await sent('完成后补充玩法测试');await row('完成后补充玩法测试').waitFor();
   await input.fill('需要兼容触屏');await page.getByRole('button',{name:'加入队列',exact:true}).click();await row('需要兼容触屏').waitFor();
   assert.equal(await input.inputValue(),'');assert.equal(await delivered().getByText('完成后补充玩法测试',{exact:true}).count(),0);
   assert.equal(await page.getByRole('button',{name:/上移消息|下移消息/}).count(),0);
  });
  await check('编辑保存原地更新，取消编辑保留原文',async()=>{
   await row('完成后补充玩法测试').getByRole('button',{name:'编辑消息'}).click();
   const edit=page.getByRole('textbox',{name:'编辑排队消息'});await edit.fill('完成后补充碰撞测试');await edit.press(modifier+'+Enter');
   await edit.waitFor({state:'hidden'});assert.equal(await row('完成后补充玩法测试').count(),0);await row('完成后补充碰撞测试').waitFor();
   await row('完成后补充碰撞测试').getByRole('button',{name:'编辑消息'}).click();await edit.fill('这段修改应当取消');await edit.press('Escape');await edit.waitFor({state:'hidden'});
   await row('完成后补充碰撞测试').waitFor();assert.equal(await row('这段修改应当取消').count(),0);
  });
  await check('删除队列消息后不会投递',async()=>{
   await sent('这条临时要求请删除');await row('这条临时要求请删除').getByRole('button',{name:'删除消息'}).click();await row('这条临时要求请删除').waitFor({state:'hidden'});
  });
  await check('排队转引导、修饰键临时引导',async()=>{
   await row('需要兼容触屏').getByRole('button',{name:'引导',exact:true}).click();
   await row('需要兼容触屏').getByText('等待引导…',{exact:true}).waitFor();
   assert.equal(await page.getByRole('group',{name:'引导确认'}).count(),0);
   await sent('角色移动速度调慢一点',modifier+'+Enter');await row('角色移动速度调慢一点').getByText('等待引导…',{exact:true}).waitFor();
   await page.screenshot({path:resolve(output,'user-test-active-desktop.png')});
  });
  await check('引导留在当前任务，队列随后新开任务且保持顺序',async()=>{
   await idle();const state=await page.evaluate(()=>window.userTestState),users=state.history.filter(item=>item.role==='user');
   assert.deepEqual(users.map(item=>item.content),['创建一个躲避小游戏','需要兼容触屏','角色移动速度调慢一点','完成后补充碰撞测试']);
   assert.equal(users[0].taskId,users[1].taskId);assert.equal(users[0].taskId,users[2].taskId);assert.notEqual(users[0].taskId,users[3].taskId);
   assert.ok(!requests.some(request=>request.messages.some(item=>item.content?.includes('这条临时要求请删除'))));
   assert.ok(!requests[1].messages.some(item=>item.content?.includes('完成后补充碰撞测试')));
  });
  await check('Esc 停止，待执行消息保留并暂停',async()=>{
   await sent('继续调整小游戏');await page.getByRole('status').filter({hasText:'Agent 正在运行'}).waitFor();
   await sent('停止后也要保留的要求');await input.focus();await input.press('Escape');
   await page.waitForFunction(()=>window.userTestState?.idle);await row('停止后也要保留的要求').waitFor();
   assert.equal(await page.getByText('队列已暂停，消息仍保留',{exact:true}).count(),0);assert.equal(await page.getByRole('button',{name:'继续队列',exact:true}).count(),0);
   const count=requests.length;await page.waitForTimeout(300);assert.equal(requests.length,count);
  });
  await check('中断后保持暂停，原有继续任务入口恢复任务及后续消息',async()=>{
   await sent('暂停期间补充的要求');await row('暂停期间补充的要求').waitFor();
   assert.ok((await page.evaluate(()=>window.userTestState.detail.session.pendingInputs)).every(item=>item.held));
   await page.screenshot({path:resolve(output,'user-test-paused-desktop.png')});
   const stoppedTaskId=await page.evaluate(()=>window.userTestState.detail.session.currentTaskId);
   await page.getByRole('button',{name:'继续任务',exact:true}).click();
   await page.getByRole('status').filter({hasText:'Agent 正在运行'}).waitFor();
   assert.equal(await page.evaluate(()=>window.userTestState.detail.session.currentTaskId),stoppedTaskId,'Continue must resume the interrupted task before draining its queue');
   assert.ok((await page.evaluate(()=>window.userTestState.detail.session.pendingInputs)).every(item=>!item.held));
   await idle();
   assert.deepEqual((await page.evaluate(()=>window.userTestState.history)).filter(item=>item.role==='user').slice(-2).map(item=>item.content),['停止后也要保留的要求','暂停期间补充的要求']);
  });
  await check('Shift+Enter 换行、中文组合输入期间 Enter 不发送',async()=>{
   await input.fill('第一行');await input.press('Shift+Enter');await input.pressSequentially('第二行');assert.equal(await input.inputValue(),'第一行\n第二行');
   const count=await page.evaluate(()=>window.userTestCommands.length);await input.dispatchEvent('compositionstart',{data:'测'});await input.press('Enter');assert.equal(await page.evaluate(()=>window.userTestCommands.length),count);await input.dispatchEvent('compositionend',{data:'测试'});await input.fill('');
  });
  await check('固定发送规则，旧偏好不再生效，引导不改变后续默认',async()=>{
   await page.evaluate(()=>localStorage.setItem('dora-agent-followup',JSON.stringify({delivery:'steer',sendKey:'modifier'})));
   assert.equal(await page.getByRole('button',{name:'后续消息设置'}).count(),0);
   await sent('测试固定发送规则');await page.getByRole('status').filter({hasText:'Agent 正在运行'}).waitFor();
   await sent('修饰键明确引导',modifier+'+Enter');await row('修饰键明确引导').getByText('等待引导…',{exact:true}).waitFor();
   await input.fill('点击发送仍然排队');await page.getByRole('button',{name:'加入队列',exact:true}).click({modifiers:[modifier]});await row('点击发送仍然排队').getByText('排队 1',{exact:true}).waitFor();
   await sent('引导后 Enter 仍然排队');await row('引导后 Enter 仍然排队').getByText('排队 2',{exact:true}).waitFor();await idle();
  });
  await check('手机视口一键引导可用，无横向溢出',async()=>{
   await page.setViewportSize({width:390,height:844});await sent('手机视口操作检查',modifier+'+Enter');await page.getByRole('status').filter({hasText:'Agent 正在运行'}).waitFor();
   await sent('手机视口排队');await row('手机视口排队').waitFor();await row('手机视口排队').getByRole('button',{name:'编辑消息'}).click();
   const edit=page.getByRole('textbox',{name:'编辑排队消息'});await edit.fill('手机编辑后的要求');await page.getByRole('button',{name:'保存',exact:true}).click();await edit.waitFor({state:'hidden'});
   await row('手机编辑后的要求').getByRole('button',{name:'引导',exact:true}).click();
   await row('手机编辑后的要求').getByText('等待引导…',{exact:true}).waitFor();
   assert.equal(await page.getByRole('group',{name:'引导确认'}).count(),0);
   await page.screenshot({path:resolve(output,'user-test-mobile-one-click-guide.png')});
   assert.ok(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth));await page.screenshot({path:resolve(output,'user-test-mobile-queue.png')});await idle();
  });
  await check('刷新后固定规则不受旧偏好影响',async()=>{
   await page.reload();await page.getByRole('status').filter({hasText:'Agent 已空闲'}).waitFor({timeout:30000});
   assert.equal(await page.getByRole('button',{name:'后续消息设置'}).count(),0);
   await sent('刷新后 Enter 直接发送');await page.getByRole('status').filter({hasText:'Agent 正在运行'}).waitFor();
   await sent('刷新后修饰键仍然引导',modifier+'+Enter');await row('刷新后修饰键仍然引导').getByText('等待引导…',{exact:true}).waitFor();
   await sent('刷新后 Enter 仍然排队');await row('刷新后 Enter 仍然排队').getByText('排队 1',{exact:true}).waitFor();await idle();
   assert.deepEqual(await page.evaluate(()=>window.userTestErrors),[]);assert.deepEqual(errors,[]);
  });
 }catch(error){await page.screenshot({path:resolve(output,'user-test-failure.png'),fullPage:true});checks.push({name:'User test failure',result:'failed',error:String(error)});throw error;}
 finally{await writeFile(resolve(output,'user-test-report.json'),JSON.stringify({checks,errors,commands:await page.evaluate(()=>window.userTestCommands),state:await page.evaluate(()=>window.userTestState),requests},null,2));await page.close();}
 console.log(`PASS: ${checks.length} browser user scenarios against production composer + real Lua/WASM Agent.`);
}
