(() => {
  'use strict';
  const $ = id => document.getElementById(id);
  const mobileTabs = document.createElement('div');
  mobileTabs.className = 'mobile-work-tabs';
  mobileTabs.innerHTML = '<button type="button" data-mobile-pane="preview" aria-pressed="true">试玩与编辑</button><button type="button" data-mobile-pane="agent" aria-pressed="false">Dora Agent</button>';
  $('workspace').insertBefore(mobileTabs, document.querySelector('.workspace-grid'));
  $('workspace').dataset.mobilePane = 'preview';
  mobileTabs.addEventListener('click', event => { const button=event.target.closest('[data-mobile-pane]');if(!button)return;$('workspace').dataset.mobilePane=button.dataset.mobilePane;mobileTabs.querySelectorAll('button').forEach(item=>item.setAttribute('aria-pressed',String(item===button))); });
  const state = { page: 'home', online: true, revision: 1, run: 1, running: true, scenario: 'normal', busy: false, paused: false, token: 0, balance: 12000, apiBalance: 8000, reserved: 0, pending: false, published: false, openSource: false, poolEnabled: true, byok: false, model: 'shared', logs: [], ledger: [], checkpoints: [], project: '月光花园', phase: 0 };
  // Demo accounting uses integer fen (CNY 0.01); no floating-point balance arithmetic.
  state.rates={input:100,output:300}; // hundredths of yuan per million tokens
  state.requestCost=0; state.requestReserve=0; state.requestModel='';
  const tokens = n => n.toLocaleString('en-US');
  const money = fen => '¥'+(fen/100).toFixed(2);
  const modelName = () => state.model==='byok'?'个人 API':state.model==='vision'?'Dora 视觉配置':'Dora 创作模型';
  const quote = (input,output) => Math.ceil((input*state.rates.input+output*state.rates.output)/1000000);
  const estimate = () => quote(100000,80000);
  const reservation = () => quote(200000,200000);
  const allowed = () => state.poolEnabled && $('grant-enabled').checked;
  const usable = () => allowed()?Math.min(state.balance,state.apiBalance):0;
  function yuanToFen(text) {
    if(!/^\d+(\.\d{1,2})?$/.test(text))return null;
    const value=Math.round(Number(text)*100);
    return Number.isSafeInteger(value) && value<=100000000 ? value : null;
  }
  const projects = new Map();
  state.publishedSource=''; state.requestStarted=false; state.id = 'sample'; state.request = ''; state.failed = false; state.incompatible = false;
  const recentTemplate = document.querySelector('.recent-project').cloneNode(true);
  document.querySelector('.recent-project').remove();
  let timer, toastTimer;
  function locked() { return state.busy || state.paused || state.reserved; }
  function selectPane(name) { mobileTabs.querySelector('[data-mobile-pane="'+name+'"]').click(); }
  function saveProject() {
    projects.set(state.id, {
      id:state.id, project:state.project, revision:state.revision, run:state.run,
      published:state.published, publishedSource:state.publishedSource, openSource:state.openSource, failed:state.failed,
      incompatible:state.incompatible, source:$('source').value, followup:$('followup').value,
      request:state.request, checkpoints:structuredClone(state.checkpoints), logs:[...state.logs],
      messages:[...$('messages').children].map(el=>({role:el.classList.contains('user')?'user':'agent',text:el.lastElementChild.textContent})),
      progress:$('agent-progress').textContent
    });
  }
  function renderProjects() {
    const list=$('recent-projects'); list.replaceChildren();
    for(const item of [...projects.values()].reverse()){
      const card=recentTemplate.cloneNode(true);
      card.removeAttribute('data-action'); card.dataset.projectId=item.id;
      card.querySelector('strong').textContent=item.project;
      card.querySelector('small').textContent=(item.run?'可试玩 · ':'尚未运行 · ')+'仅本次会话';
      card.querySelector('.pill').textContent=item.openSource?'允许 Remix':'源码私有';
      list.append(card);
    }
    const recent=document.querySelector('.side-project button');
    recent.textContent=state.project; recent.title=state.project;
    document.querySelector('.side-project>span').textContent='当前项目 · 仅本次会话';
  }
  function openProject(id) {
    if(id===state.id){page('workspace');return;}
    if(locked()){toast('先完成或恢复当前创作，再切换项目。');return;}
    saveProject(); const item=projects.get(id); if(!item)return;
    Object.assign(state,structuredClone(item),{running:!!item.run,scenario:'normal',phase:0});
    $('source').value=item.source; $('followup').value=item.followup;
    $('messages').replaceChildren(); for(const m of item.messages)message(m.role,m.text);
    $('agent-progress').textContent=item.progress; $('open-source').checked=state.openSource;
    $('logs').textContent=state.logs.join('\n'); $('log-count').textContent=state.logs.length+' 条';
    document.querySelectorAll('[data-scenario]').forEach(el=>el.classList.remove('active'));
    banner(''); page('workspace'); resetGame();
  }
  function nameFromPrompt(text) {
    return text.replace(/^(请)?(帮我)?(做|制作|生成|创建)(一[个款])?/,'').split(/[，。！？\n]/)[0].trim().slice(0,24) || '新游戏';
  }
  function runnable() {
    if(state.incompatible || state.scenario==='incompatible'){banner('此项目包含 Web 不支持的能力。代码仍可编辑；需要适配后才能试玩。');return false;}
    if(state.scenario==='compile'){state.failed=true;banner('编译失败（模拟），保留上一运行快照。请修复代码后重试。');sync();return false;}
    return true;
  }
  function available() {
    if(!state.online){banner('已断线。请恢复连接后继续；你的描述不会清空。');return false;}
    if(state.model==='byok' && !state.byok){banner('个人 API 尚未授权，请到“模型与额度”配置。描述已保留。');return false;}
    if(state.model!=='byok' && (!state.poolEnabled || !$('grant-enabled').checked)){banner('共享配置已停用或授权已撤销。请手动选择其他配置。');return false;}
    return true;
  }
  function pauseAgent() {
    if(!state.busy)return;
    clearTimeout(timer);state.token++;state.busy=false;state.paused=true;
    $('agent-progress').textContent='创作已暂停 · 保留当前阶段';
    banner('任务已暂停。点击“从检查点继续”接着完成；不会重新提交你的描述。');sync();
  }
  const phases = ['建立修改前检查点', '直接修改项目文件', '编译当前项目快照', '浏览器试玩与工具反馈'];
  function toast(text) { $('toast').textContent = text; $('toast').hidden = false; clearTimeout(toastTimer); toastTimer = setTimeout(() => $('toast').hidden = true, 3200); }
  function banner(text) { $('state-banner').textContent = text; $('state-banner').hidden = !text; }
  function addLog(text) { state.logs.push(text); if (state.logs.length > 9) state.logs.shift(); $('logs').textContent = state.logs.join('\n'); $('log-count').textContent = `${state.logs.length} 条`; }
  function message(role, text) { const el = document.createElement('div'); el.className = `message ${role}`; const label = document.createElement('small'); label.textContent = role === 'user' ? '你' : 'DORA'; const body = document.createElement('div'); body.textContent = text; el.append(label, body); $('messages').append(el); requestAnimationFrame(()=>{$('messages').scrollTop=$('messages').scrollHeight;}); }
  function sync() {
    $('project-title').textContent = state.project;
    document.querySelector('#work .page-heading h1').textContent=state.project;
    document.querySelector('.work-art small').textContent=state.project+' · 示意作品封面';
    document.querySelector('.work-art>span').textContent='示意试玩封面';
    $('save-state').textContent='会话草稿 · 刷新后清空';
    const modelText=state.model==='byok'?'个人 API':state.model==='vision'?'Dora 视觉配置':'Dora 创作模型';
    document.querySelector('.prompt-footer .text-button').textContent=modelText+' ▾';
    $('create-game').disabled=!!locked() || !$('idea').value.trim();
    $('pause-agent').hidden=!state.busy;
    $('cancel-queue').hidden=!(state.paused && !state.requestStarted);
    $('agent-play').hidden=state.busy || state.paused || !state.run;
    const progress=state.busy || state.paused;
    $('task-status').hidden=!progress && !state.run;
    $('task-status-text').textContent=progress?$('agent-progress').textContent:state.run===state.revision?'示意运行已就绪 · r'+state.run:'草稿已修改 · 试玩仍为 r'+state.run;
    $('ready-preview').hidden=progress || !state.run;
    $('preview-empty').hidden=!!state.run;
    $('game').hidden=!state.run;
    document.querySelector('.game-control').hidden=!state.run;
    $('preview-empty-title').textContent=state.busy?'正在准备首次试玩':state.failed?'首次编译未通过':state.incompatible?'此项目暂不支持 Web 试玩':'等待第一次运行';
    $('preview-empty-copy').textContent=state.busy?'在 Agent 中查看生成进度。完成后会在这里显示示意游戏。':'当前没有可运行快照。先通过 Agent 创作，或编辑代码后运行。';
    $('source').readOnly=!!(state.busy || state.paused);
    document.querySelector('[data-action="run"]').disabled=!!(state.busy || state.paused);
    document.querySelector('[data-action="stop"]').disabled=!state.run || !state.running;
    const personal=state.model==='byok', funds=usable();
    const personalCalls=state.ledger.filter(item=>item.personal);
    const knownCalls=personalCalls.filter(item=>!item.usageMissing);
    const missingCalls=personalCalls.length-knownCalls.length;
    const inputTotal=knownCalls.reduce((n,item)=>n+item.inputTokens,0);
    const outputTotal=knownCalls.reduce((n,item)=>n+item.outputTokens,0);
    const total=inputTotal+outputTotal;
    $('models-title').textContent=personal?'你的 API 用量':'你的创作经费';
    $('models-subtitle').textContent=personal?'记录通过 Studio 使用个人 API 的消耗，不管理服务商余额。':'看清还能用多少，再选择适合的创作模型。';
    $('platform-stats').hidden=personal;$('personal-stats').hidden=!personal;
    $('byok-calls').textContent=tokens(personalCalls.length);
    $('byok-input').textContent=tokens(inputTotal);$('byok-output').textContent=tokens(outputTotal);
    $('byok-summary').textContent=tokens(total)+' Token · '+personalCalls.length+' 次调用';
    $('byok-coverage').textContent=missingCalls?missingCalls+' 次未返回用量，未计入 Token 合计；不代表零消耗。':'只统计通过 Studio 发起且返回用量的调用（本次会话模拟数据）。';
    $('model-balance').textContent=money(state.balance);
    $('api-balance').textContent=personal?'不适用':money(state.apiBalance);
    $('account-quota').value=(state.balance/100).toFixed(2);$('grant-quota').value=(state.apiBalance/100).toFixed(2);
    $('limits').textContent=`API ${$('pool-limit').value} / 账号 ${$('account-limit').value} / 授权 ${$('grant-limit').value}`;
    $('active-model').textContent=modelName()+' ▾';
    $('credit-label').textContent=personal?'个人 API · 已记录 Token':'当前模型可用额度';
    $('usable-credit').textContent=personal?tokens(total):money(funds);
    $('usable-credit').classList.toggle('unknown',personal);
    $('credit-explanation').textContent=personal?`本次会话 · ${knownCalls.length} 次已记录${missingCalls?' · '+missingCalls+' 次用量待补记':''} · 不扣平台额度`:'平台提供 · 人民币使用额度，不是现金余额';
    $('held-credit').textContent=money(state.reserved)+(state.pending?' · 待核对':'');
    $('spent-credit').textContent=money(state.ledger.reduce((sum,item)=>sum+(item.cost || 0),0));
    $('funding-source').textContent=personal?'个人付费':'平台提供';
    $('model-availability').textContent=personal?(state.byok?'个人 API 已连接（模拟）。':'尚未连接，请先连接演示 API。'):!allowed()?'此共享配置已停用或未获授权。':`本模型现在可用 ${money(funds)}，已排除预留金额。额度用完后联系管理员追加。`;
    $('request-price').textContent=personal?'按调用记录用量 · 不扣平台额度':`本次演示预计使用 ${money(estimate())}`;
    $('request-reserve').textContent=personal?'记录输入、输出 Token；金额需明确单价才能估算，以服务商账单为准。':`开始时暂时预留 ${money(reservation())}，完成后退回差额。仅为示例调用，不是整款游戏报价。`;
    $('model-rates').textContent=personal?'以服务商账单为准':`${money(state.rates.input)} / ${money(state.rates.output)} 每百万 Token（演示）`;
    const creditText=personal?`个人 API · 已记录 ${tokens(total)} Token${missingCalls?' · '+missingCalls+' 次待补记':''}`:`可用 ${money(funds)} · 平台提供`;
    $('creation-credit').textContent=creditText;
    $('agent-credit').textContent=state.reserved?`已预留 ${money(state.reserved)}${state.pending?' · 待核对':' · 不是实际扣费'}`:creditText;
    $('connection').textContent = state.online ? '● 已连接' : '○ 已断线';
    $('send').disabled = state.busy || state.paused || !state.online || !$('followup').value.trim();
    $('resume').hidden = !state.paused; $('resume').disabled = !state.online;
    $('run-version').textContent = state.run ? `运行快照 r${state.run}${state.run !== state.revision ? ' · 有未运行修改' : ''}` : '尚无运行快照';
    $('publish-state').textContent = state.published ? `公开试玩 · 发布快照 r${state.published}` : '尚未发布';
    $('source-state').textContent = state.openSource ? '开放 · 允许 Remix' : '私有 · 不允许 clone';
    $('share-url').value = state.published ? `https://studio.example.invalid/play/${state.id}?v=${state.published}` : '发布后生成（模拟）';
    $('sharing-status').textContent = state.openSource ? '已人工开放源码，访客可以 clone 为独立项目。' : '当前源码私有，访客只能试玩。';
    $('pending-billing').textContent = state.pending ? `待核对 · 预留 ${money(state.reserved)} · 等待供应商用量确认。` : '当前没有暂挂调用。可在工作室选择“缺失 usage”演练。';
    saveProject(); renderProjects();
    $('ledger-title').textContent=personal?'个人 API 用量记录':'平台费用明细';
    $('ledger-caption').textContent=personal?'本次会话 · 用量为模拟值 · 不含平台调用':'人民币 · 演示账单，非真实扣费';
    const headers=personal?['调用 / 时间','模型 / 项目','输入 Token','输出 Token','状态']:['调用','模型','开始时预留','实际使用','状态'];
    $('ledger-head').replaceChildren(...headers.map(label=>{const th=document.createElement('th');th.textContent=label;return th;}));
    const tbody=$('ledger');tbody.replaceChildren();
    const rows=state.ledger.filter(item=>item.personal===personal);
    for(const item of [...rows].reverse()){
      const cells=personal?[item.id+' · '+item.time,item.model+' / '+item.project,item.usageMissing?'未返回':tokens(item.inputTokens),item.usageMissing?'未返回':tokens(item.outputTokens),item.usageMissing?'用量待补记':'已记录（模拟）']:
        [item.id,item.model,money(item.reserve),item.cost===null?'待核对':money(item.cost),item.status];
      const tr=document.createElement('tr');
      for(const value of cells){const td=document.createElement('td');td.textContent=value;tr.append(td);}tbody.append(tr);
    }
    if(!rows.length){const tr=document.createElement('tr'),td=document.createElement('td');td.colSpan=5;td.textContent=personal?'尚无个人 API 调用。连接并选择个人 API，创作后会记录用量。':'暂无平台费用。使用平台模型创作后会显示预留与结算。';tr.append(td);tbody.append(tr);}

  }
  function page(name) { if (!$(name)) return; const changed=state.page!==name; state.page = name; document.querySelectorAll('.page').forEach(p => p.hidden = p.id !== name); document.querySelectorAll('[data-page]').forEach(b => b.classList.toggle('active', b.dataset.page === name)); $('breadcrumb').textContent = {home:'创作 / 开始',workspace:'项目 / 工作室',models:'账号 / 模型与额度',work:'作品 / 分享设置',admin:'管理 / API 与授权'}[name]; location.hash = name; sync(); if(changed)requestAnimationFrame(()=>window.scrollTo(0,0)); }
  function dialog(title, markup, callback, confirm = '确认') { $('dialog-title').textContent = title; $('dialog-body').innerHTML = markup; $('dialog-confirm').textContent = confirm; $('dialog-confirm').onclick = () => { if (callback() !== false) $('dialog').close(); }; $('dialog').showModal(); }
  function checkpoint() { state.checkpoints.push({revision:state.revision,source:$('source').value,project:state.project}); if (state.checkpoints.length > 10) state.checkpoints.shift(); }
  function reserve() {
    state.requestProject=state.project;state.requestTime=new Date().toLocaleTimeString('zh-CN',{hour12:false});
    if(state.model==='byok'){state.requestCost=0;state.requestReserve=0;state.requestModel=modelName();return true;}
    if(state.reserved || state.pending){banner('已有预留金额等待结算，请先核对，不重复生成。');return false;}
    const amount=reservation();
    if(state.balance<amount || state.apiBalance<amount || state.scenario==='quota'){
      banner(`额度不足：本次演示需暂时预留 ${money(amount)}，当前模型可用 ${money(usable())}。联系管理员追加，或手动选择个人 API。`);return false;
    }
    state.requestCost=estimate();state.requestReserve=amount;state.requestModel=modelName();
    state.balance-=amount;state.apiBalance-=amount;state.reserved=amount;sync();return true;
  }
  function settle(pending=false) {
    const personal=state.model==='byok', reserved=state.requestReserve, cost=personal?0:state.requestCost;
    const usageMissing=pending;
    pending=pending && !personal;
    if(!pending){if(!personal){state.balance+=reserved-cost;state.apiBalance+=reserved-cost;}state.reserved=0;}
    state.pending=pending;
    state.ledger.push({id:`call-${state.ledger.length+1}`,model:state.requestModel,project:state.requestProject,time:state.requestTime,personal,usageMissing,inputTokens:usageMissing?null:100000,outputTokens:usageMissing?null:80000,reserve:reserved,cost:pending?null:cost,status:pending?'待核对 · 仍占预留':personal?'平台不扣费':'已结算（模拟）'});sync();
  }
  function advance(token) {
    if (token !== state.token || !state.online || !state.busy) return;
    $('agent-progress').textContent = `${state.phase + 1}/4 · ${phases[state.phase]}（模拟）`;
    addLog(`[模拟] ${phases[state.phase]}`);
    sync();
    if (state.phase === 1) { state.revision++; $('source').value += `\n// Agent 示意修改 r${state.revision}：增加星光与收集音效。`; $('save-state').textContent = '会话草稿已更新 · 刷新后清空'; sync(); }
    if (state.phase === 2 && (state.scenario === 'compile' || state.incompatible || state.scenario === 'incompatible')) { settle(); state.busy = false; state.requestStarted=false; state.failed = true; $('agent-progress').textContent = '编译失败（模拟），保留上一运行快照'; banner('init.ts:12 示例编译错误。修改已保存，旧预览仍在运行；可编辑代码或要求 Agent 修复。'); message('agent','编译遇到错误，未把新版本作为试玩成功。请在代码和日志中查看。'); sync(); return; }
    if (state.phase === 3) {
      state.busy = false; state.requestStarted=false; state.failed=false; state.running = true; state.run = state.revision; resetGame(); settle(state.scenario === 'usage');
      $('agent-progress').textContent = '此次示意流程结束 · 示意运行已就绪';
      message('agent','本轮演示已完成：展示代码已更新，示意试玩已刷新。点击“试玩结果”查看，或继续描述修改。当前固定展示花园游戏，不代表已按描述生成实际玩法。');
      banner(state.pending ? '供应商未返回 usage（模拟）：预留暂挂待核，不自动免费，管理员可处理。' : state.model==='byok' && state.scenario==='usage' ? '个人 API 未返回用量，已标记待补记；未计入 Token 合计，不扣平台额度。' : ''); sync(); return;
    }
    state.phase++; timer = setTimeout(() => advance(token), 700);
  }
  function generate(text, retry=false) {
    text=(text || '').trim();
    if(state.busy || (state.paused && !retry))return;
    if(!text){toast('请先输入想修改的内容。');$('followup').focus();return;}
    page('workspace'); selectPane('agent');
    if(!retry){state.request=text;$('followup').value=text;}
    if(!available()){sync();return;}
    if(state.scenario==='queued' && state.model!=='byok'){
      if(!retry)message('user',text);
      state.paused=true;state.requestStarted=false;$('followup').value='';
      $('agent-progress').textContent='等待模型并发槽位';
      banner('正在排队（模拟），描述已保留，不切换模型。恢复正常后点击继续。');sync();return;
    }
    if(!reserve()){sync();return;} state.requestStarted=true;
    if(!retry)message('user',text);
    banner(''); checkpoint(); state.busy=true; state.paused=false;state.phase=0;state.token++;
    $('followup').value='';sync();advance(state.token);
  }
  function connection() {
    state.online = !state.online;
    if (!state.online) { clearTimeout(timer); state.token++; if (state.busy || state.paused) { state.busy = false; state.paused = true; checkpoint(); $('agent-progress').textContent = '检查点已保存 · 暂停'; } banner('连接中断：Agent 和关联任务暂停，不再派发调用。在途调用保留结算状态。'); }
    else banner(state.paused ? '连接已恢复。点击“从检查点继续”，不会重新执行已完成阶段。' : ''); sync();
  }
  function resume() { if (!state.online || !state.paused) return; if (state.scenario === 'queued') { toast('仍在排队，请先选择“恢复正常”。'); return; } if (state.requestStarted) { state.busy = true; state.paused = false; state.token++; sync(); banner(''); advance(state.token); } else generate(state.request,true); }
  function newProject(name) { if (state.busy || state.reserved || state.paused) { toast('请先完成或恢复当前任务，再切换项目。'); return false; } saveProject(); state.id='project-'+crypto.randomUUID(); state.project = name; state.revision = 1; state.run = 0; state.failed=false; state.incompatible=false; state.request=''; $('followup').value=''; state.published = false; state.publishedSource=''; state.openSource = false; state.running = false; state.scenario = 'normal'; state.phase = 0; $('open-source').checked = false; state.checkpoints = []; state.logs = []; $('logs').textContent = '[原型] 新项目尚未接入真实编译器。'; $('log-count').textContent = '0 条'; $('agent-progress').textContent = '等待你的描述'; $('save-state').textContent = '会话草稿 · 刷新后清空'; banner(''); document.querySelectorAll('[data-scenario]').forEach(x=>x.classList.remove('active')); document.querySelector('[data-tab="preview"]').click(); $('source').value = "// 新项目展示代码，不执行输入代码。\nimport { Node } from 'Dora';\nconst garden = Node();"; $('messages').replaceChildren(); message('agent','项目已建立。描述你想做的玩法，我会直接修改；原型中所有调用都是模拟。'); page('workspace'); resetGame(); return true; }
  const actions = {
    create: () => { const text = $('idea').value.trim(); if (!text) return toast('先描述你想做的游戏。'); if (newProject(nameFromPrompt(text))) generate(text); },
    blank: () => {if(newProject('未命名项目')){selectPane('agent');$('followup').focus();}},
    'show-agent': () => {selectPane('agent');$('followup').focus();},
    'show-preview': () => {selectPane('preview');document.querySelector('[data-tab="preview"]').click();$('game').focus();},
    pause: pauseAgent,
    'cancel-queue': () => { if(!state.paused || state.requestStarted)return;state.paused=false;$('followup').value=state.request;$('agent-progress').textContent='已退出排队 · 描述保留在输入框';banner('');sync(); },
    rename: () => {
      dialog('重命名项目','<label for="project-name">项目名称</label><input id="project-name" maxlength="40" autocomplete="off">',()=>{
        const name=$('project-name').value.trim();if(!name){toast('项目名称不能为空。');return false;}
        state.project=name;sync();toast('项目名称已更新。');
      },'保存名称');
      $('project-name').value=state.project; $('project-name').focus();
    },
    'open-project': () => page('workspace'),
    generate: () => generate($('followup').value.trim()), resume, connection,
    run: () => { if(locked() || !runnable())return; state.failed=false; state.running = true; state.run = state.revision; resetGame(); sync(); addLog('[示意] 重新运行当前快照，不执行输入的代码。'); },
    stop: () => { state.running = false; drawGame(); sync(); toast('示意试玩已停止；这不是停止 Agent 任务。'); },
    checkpoint: () => dialog('修改记录与恢复', '<p>自动修改前建立检查点。当前演示可恢复最近的代码与版本，不会变更公开发布版本。</p>', () => { if (state.busy || state.paused || state.reserved) { toast('先完成当前任务，避免恢复与在途修改冲突。'); return false; } const cp = state.checkpoints.pop(); if (!cp) { toast('暂无检查点，先生成一次示意修改。'); return false; } state.revision = cp.revision; $('source').value = cp.source; sync(); toast('已恢复代码检查点，点击重新运行查看。'); }, '恢复最近检查点'),
    publish: () => dialog('发布当前快照', '<p>发布后可通过公开链接试玩。源码仍默认私有，不自动允许 Remix。</p><p>本原型只生成 example.invalid 演示链接，不上传项目。</p>', () => { if (state.busy || state.paused) { toast('请先完成或恢复当前创作。'); return false; } if(!state.run || state.failed || state.run!==state.revision || state.incompatible){toast('请先成功运行当前草稿，再发布这个已验证的快照。');return false;} state.published = state.run; state.publishedSource=$('source').value; page('work'); toast('模拟发布完成，源码保持当前人工设置。'); }, '确认发布（模拟）'),
    'save-sharing': () => { state.openSource = $('open-source').checked; sync(); toast(state.openSource?'已人工开放源码并允许 Remix（模拟）。':'源码已设为私有（模拟）。'); },
    'copy-link': async () => {if(!state.published)return toast('先发布一个快照。');try{await navigator.clipboard.writeText($('share-url').value);toast('已复制演示链接（不能真实访问）。');}catch{$('share-url').focus();$('share-url').select();toast('无法访问剪贴板，已选中链接，请手动复制。');}},
    'clone-work': () => { if (!state.published) return toast('作品尚未发布。'); if (!state.openSource) return toast('clone 被拒绝：公开试玩不提供私有源码。'); const source=state.publishedSource; if (newProject(state.project+' · Remix')) { $('source').value=source; state.run=1;state.running=true;sync();resetGame();toast('已复制发布版本为独立私有草稿（模拟），不会复制未发布修改。'); } },
    clone: () => dialog('从项目链接开始', '<label for="clone-url">公开 Git / ZIP / Studio 分享链接</label><input id="clone-url" placeholder="https://你的托管商/作者/项目.git"><label class="check"><input id="clone-rights" type="checkbox">我已确认具有复制/改编授权</label><p>不限制 Git 托管商。Studio 私有源码链接不能 clone。原型不请求网络、不下载仓库。</p>', () => { const url = $('clone-url').value.trim(); let parsed; try { parsed = new URL(url); } catch { toast('请输入完整 HTTPS 链接。'); return false; } if (parsed.protocol !== 'https:' || parsed.username || parsed.password) { toast('演示仅接受不含凭据的 HTTPS 链接。'); return false; } if (!$('clone-rights').checked) { toast('公开链接不等于开源授权，请确认许可。'); return false; } if (parsed.hostname==='studio.example.invalid') {
      saveProject(); const id=parsed.pathname.match(/^\/play\/([^/]+)$/)?.[1], original=projects.get(id);
      if(!original || !original.published || !original.openSource){toast('该 Studio 作品不存在或源码私有，不能 clone。');return false;}
      if(!newProject(original.project+' · Remix'))return false;
      $('source').value=original.publishedSource;state.run=1;state.running=true;sync();resetGame();return;
    } if (!newProject('链接项目 · Remix')) return false; banner('链接识别完成（模拟），项目为独立快照。实际下载、提交解析、许可证及 SSRF 校验尚未实现。'); }, '复制项目（模拟）'),
    import: () => dialog('上传游戏包', '<label for="package-file">.dora 或 ZIP</label><input id="package-file" type="file" accept=".dora,.zip"><label class="check"><input id="import-incompatible" type="checkbox">演练：项目包含 Web 不支持的能力</label><p>新建和导入并存。原型只读取文件名，不读取文件内容、不解包、不上传。</p>', () => { const file = $('package-file').files[0]; if (!file || !/\.(dora|zip)$/i.test(file.name)) { toast('请选择 .dora 或 ZIP 文件。'); return false; } const incompatible = $('import-incompatible').checked; if (!newProject(file.name.replace(/\.(dora|zip)$/i,''))) return false; state.incompatible=incompatible;sync(); banner(incompatible?'项目已保留可编辑（模拟）。Web 不支持的模块阻止试玩；不会自动改写玩法，可主动要求 Agent 适配。':'包导入流程完成（模拟）。实际解包/入口/兼容性检查尚未实现。'); }, '导入项目（模拟）'),
    'asset-upload': () => dialog('上传素材', '<input id="asset-file" type="file" aria-label="选择素材"><p>此原型仅展示上传流程，不读取或保存素材内容。</p>', () => { if (!$('asset-file').files.length) { toast('请选择素材。'); return false; } toast('素材上传示意完成，未保存文件。'); }),
    'byok-add': () => { state.byok = true; $('byok-status').textContent = '演示配置已授权；没有保存任何真实 Key。'; sync(); toast('已模拟授权。'); },
    'byok-revoke': () => { state.byok = false; $('byok-status').textContent = '演示配置已撤销。'; sync(); toast('已模拟撤销，个人 API 不会再派发新请求。'); },
    'pool-import': () => dialog('导入共享 API 配置', '<p>管理员导入连接信息、模型参数、人民币单价和最大并发。凭据加密保存，用户只看到获授权配置。</p><p>本原型不接收真实配置或 Key。</p>', () => toast('演示配置导入完成；未写入数据库。'), '导入示例'),
    'pool-toggle': () => { state.poolEnabled = !state.poolEnabled; $('pool-toggle').textContent = state.poolEnabled?'已启用':'已停用'; sync(); toast('配置状态已模拟更新。'); },
    'save-pool': () => {
      if(state.busy || state.paused || state.pending){toast('请先完成当前调用或核对，再调整计价。');return;}
      const input=yuanToFen($('input-rate').value),output=yuanToFen($('output-rate').value);
      if(!Number.isInteger(+$('pool-limit').value) || +$('pool-limit').value<1 || input===null || output===null)return toast('并发须为正整数；单价须为非负金额，最多两位小数且不超过 100 万元。');
      state.rates={input,output};sync();toast('已保存人民币演示单价，后续预留和结算按新费率计算。');
    },
    'save-grants': () => {
      if(state.reserved || state.busy || state.pending || state.paused)return toast('请先完成调用或核对，避免覆盖账务。');
      const account=yuanToFen($('account-quota').value),grant=yuanToFen($('grant-quota').value);
      if(!['account-limit','grant-limit'].every(id=>Number.isInteger(+$(id).value) && +$(id).value>=1) || account===null || grant===null)return toast('并发须为正整数；金额须非负、最多两位小数且不超过 100 万元。');
      state.balance=account;state.apiBalance=grant;sync();toast('人民币使用额度已更新，不自动按月重置。');
    },
    'resolve-billing': () => { if (!state.pending) return toast('没有暂挂调用。'); if (!$('billing-reason').value.trim()) return toast('请输入核对处理原因。'); state.balance += state.reserved; state.apiBalance += state.reserved; state.reserved = 0; state.pending = false; const item = state.ledger.findLast(x=>x.cost===null); if (item) { item.cost=0; item.status='人工核对后释放（模拟）'; } sync(); toast('已模拟释放预留，处理原因仅在此界面填写，不保存。'); }
  };
  document.addEventListener('click', event => { const b = event.target.closest('button'); if (!b || b.disabled) return; if (b.dataset.projectId)openProject(b.dataset.projectId); if (b.dataset.page) page(b.dataset.page); if (b.dataset.action && actions[b.dataset.action]) actions[b.dataset.action](); if (b.dataset.idea) {$('idea').value = b.dataset.idea;sync();$('idea').focus();} if (b.dataset.tab) { document.querySelectorAll('[data-tab]').forEach(x=>x.setAttribute('aria-selected',String(x===b))); ['preview','code','assets'].forEach(id=>$(id).hidden=id!==b.dataset.tab); } if (b.dataset.adminTab) { document.querySelectorAll('[data-admin-tab]').forEach(x=>x.setAttribute('aria-pressed',String(x===b))); ['pool','grants','billing'].forEach(id=>$(id).hidden=id!==b.dataset.adminTab); } if (b.dataset.move) move(b.dataset.move); if (b.dataset.scenario) { if (state.busy || state.reserved) { toast('先完成或恢复/核对当前调用，再切换演练状态。'); return; } state.scenario=b.dataset.scenario; sync(); document.querySelectorAll('[data-scenario]').forEach(x=>x.classList.toggle('active',x===b)); banner({normal:'',queued:'并发排队演练：发送描述后显示等待槽位。',quota:'额度不足演练：发送描述后不会派发调用。',compile:'编译失败演练：发送描述后保留旧预览。',incompatible:'项目已导入可编辑，但示例原生模块不支持 Web。不会自动改写原玩法。',usage:'缺失 usage 演练：发送后将预留暂挂，管理员可核对。'}[state.scenario]); } });
  $('model-choice').addEventListener('change', event => { if (state.busy || state.reserved || state.paused) { event.target.value=state.model; toast('请先完成当前调用或检查点恢复，再切换模型。'); return; } state.model=event.target.value; sync(); });
  for(const id of ['idea','followup']) {
    $(id).addEventListener('input',sync);
    $(id).addEventListener('keydown',event=>{
      if(event.key==='Enter' && (event.metaKey || event.ctrlKey) && !event.isComposing){
        event.preventDefault(); if(id==='idea')actions.create();else actions.generate();
      }
    });
  }
  $('source').addEventListener('input', () => { state.revision++; $('save-state').textContent='草稿已修改（模拟），运行快照未变化'; sync(); });
  window.addEventListener('offline', () => { if (state.online) connection(); });
  window.addEventListener('hashchange', () => { const name=location.hash.slice(1); if (['home','workspace','models','work','admin'].includes(name) && state.page!==name) page(name); });
  window.addEventListener('pagehide', () => { clearTimeout(timer); state.token++; });
  const canvas = $('game'), ctx = canvas.getContext('2d');
  let player = {x:340,y:260}, score=0, stars=[];
  function resetGame() { player={x:340,y:260}; score=0; stars=[{x:170,y:150},{x:520,y:145},{x:210,y:330},{x:560,y:310}]; $('score').textContent='0'; drawGame(); }
  function drawGame() {
    const sky=ctx.createLinearGradient(0,0,0,430);sky.addColorStop(0,'#20263e');sky.addColorStop(1,'#59677d');ctx.fillStyle=sky;ctx.fillRect(0,0,720,430);
    for(let i=0;i<45;i++){ctx.fillStyle=i%3?'#cbd4e34a':'#ede3cba0';ctx.beginPath();ctx.arc((i*137+21)%720,(i*53)%210, i%3?1:1.6,0,Math.PI*2);ctx.fill();}
    const glow=ctx.createRadialGradient(566,76,10,566,76,100);glow.addColorStop(0,'#f9e9bd28');glow.addColorStop(1,'#f9e9bd00');ctx.fillStyle=glow;ctx.fillRect(460,0,220,185);ctx.fillStyle='#eee5c7';ctx.beginPath();ctx.arc(566,76,25,0,Math.PI*2);ctx.fill();
    for(const [y,color] of [[240,'#39465d'],[290,'#435868'],[355,'#527274']]){ctx.fillStyle=color;ctx.beginPath();ctx.moveTo(0,y);ctx.bezierCurveTo(160,y-85,330,y+70,470,y-8);ctx.bezierCurveTo(610,y-75,650,y,720,y-40);ctx.lineTo(720,430);ctx.lineTo(0,430);ctx.fill();}
    ctx.strokeStyle='#92a8942b';ctx.lineWidth=45;ctx.beginPath();ctx.moveTo(320,440);ctx.bezierCurveTo(430,335,220,310,360,240);ctx.stroke();
    for(const [x,y,s] of [[35,310,1.2],[90,350,.8],[654,270,1.2],[690,345,1],[410,380,.6]]){ctx.fillStyle='#263f4e';ctx.fillRect(x-3,y-10,6,42*s);ctx.fillStyle='#2e4b58';for(let i=0;i<3;i++){ctx.beginPath();ctx.moveTo(x,y-80*s+i*22);ctx.lineTo(x-30*s+i*4,y-15*s+i*15);ctx.lineTo(x+30*s-i*4,y-15*s+i*15);ctx.fill();}}
    for(let i=0;i<55;i++){const x=(i*83+9)%720,y=275+(i*47)%145;ctx.fillStyle=i%3?'#afbbc249':'#c7b6df88';ctx.fillRect(x,y,2,4);}
    stars.forEach(s=>{const light=ctx.createRadialGradient(s.x,s.y,0,s.x,s.y,25);light.addColorStop(0,'#fbe6a557');light.addColorStop(1,'#fbe6a500');ctx.fillStyle=light;ctx.fillRect(s.x-25,s.y-25,50,50);ctx.fillStyle='#f5dfa1';ctx.beginPath();ctx.moveTo(s.x,s.y-9);ctx.lineTo(s.x+3,s.y-3);ctx.lineTo(s.x+9,s.y);ctx.lineTo(s.x+3,s.y+3);ctx.lineTo(s.x,s.y+9);ctx.lineTo(s.x-3,s.y+3);ctx.lineTo(s.x-9,s.y);ctx.lineTo(s.x-3,s.y-3);ctx.closePath();ctx.fill();});
    ctx.fillStyle='#17283e55';ctx.beginPath();ctx.ellipse(player.x,player.y+14,13,5,0,0,Math.PI*2);ctx.fill();ctx.fillStyle='#dcb497';ctx.beginPath();ctx.arc(player.x,player.y-8,8,0,Math.PI*2);ctx.fill();ctx.fillStyle='#b5a4d8';ctx.fillRect(player.x-8,player.y-1,16,15);ctx.fillStyle='#424057';ctx.fillRect(player.x-7,player.y+13,5,5);ctx.fillRect(player.x+2,player.y+13,5,5);ctx.fillStyle='#f5ecd4';ctx.fillRect(player.x+9,player.y+2,5,7);
    if (!state.running || score===4) { ctx.fillStyle='#e5ecdfdd';ctx.fillRect(0,0,720,430);ctx.fillStyle='#375d4c';ctx.font='22px sans-serif';ctx.textAlign='center';ctx.fillText(state.running?'星光收集完成':'试玩已停止',360,215);ctx.textAlign='left'; }
  }
  function move(direction) { if (!state.running || score===4) return; const [dx,dy]={left:[-20,0],right:[20,0],up:[0,-20],down:[0,20]}[direction];player.x=Math.max(20,Math.min(700,player.x+dx));player.y=Math.max(80,Math.min(410,player.y+dy));stars=stars.filter(s=>{if(Math.hypot(s.x-player.x,s.y-player.y)<25){score++;return false;}return true;});$('score').textContent=String(score);drawGame(); }
  canvas.addEventListener('click',()=>{canvas.setAttribute('tabindex','0');canvas.focus();});
  document.addEventListener('keydown',event=>{const dir={ArrowLeft:'left',ArrowRight:'right',ArrowUp:'up',ArrowDown:'down'}[event.key];if(dir && document.activeElement===canvas && state.page==='workspace' && !$('preview').hidden){event.preventDefault();move(dir);}});
  message('agent','月光花园已经打开。描述你想改变的玩法、氛围或细节，我来帮你实现。');
  page(['home','workspace','models','work','admin'].includes(location.hash.slice(1))?location.hash.slice(1):'home'); resetGame();
})();
