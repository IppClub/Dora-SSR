import React, {useLayoutEffect, useMemo, useRef, useState} from 'react';
import ReactMarkdown from 'react-markdown';
import remarkGfm from 'remark-gfm';
import type {AgentQuestionnaire,AgentSessionMessage,AgentSessionStep} from '@dora-studio/agent-contracts/session-patches';

export type AgentModelChoice={id:string|number;name:string};
export type AgentActualUsage={inputTokens:number;outputTokens:number;cachedInputTokens?:number;requestCount?:number};
export type AgentComposerLabels={
  promptPlaceholder:string;planPromptPlaceholder:string;send:string;stop:string;stopping:string;
  planMode:string;planModeInactive:string;networkAccess:string;executeCommand:string;
  selectModel:string;modelForNextRun:string;contextUsage:(used:string,max:string,percent:number)=>string;
  actualUsage:(usage:AgentActualUsage)=>string;
};

const defaultLabels:AgentComposerLabels={
  promptPlaceholder:'继续描述你希望修改的玩法…',planPromptPlaceholder:'描述目标，让 Agent 先制定计划…',send:'发送',stop:'停止',stopping:'正在停止',
  planMode:'计划',planModeInactive:'计划',networkAccess:'网络',executeCommand:'命令',selectModel:'选择模型',modelForNextRun:'下一轮使用的模型',
  contextUsage:(used,max,percent)=>`上下文估算：${used} / ${max}（${percent}%）`,
  actualUsage:usage=>`实际用量：输入 ${compactNumber(usage.inputTokens)}，输出 ${compactNumber(usage.outputTokens)}${usage.cachedInputTokens===undefined?'':`，缓存 ${compactNumber(usage.cachedInputTokens)}`}`,
};

export interface SharedAgentComposerProps{
  compact?:boolean;prompt:string;loading:boolean;running:boolean;stopping?:boolean;canStop?:boolean;
  disabled?:boolean;status?:string;contextRatio?:number;usedTokens?:number;maxTokens?:number;actualUsage?:AgentActualUsage;
  fetchUrlEnabled?:boolean;executeCommandEnabled?:boolean;planMode?:boolean;models?:AgentModelChoice[];modelId?:string|number;
  labels?:Partial<AgentComposerLabels>;ariaLabel?:string;maxLength?:number;
  onPromptChange:(value:string)=>void;onSend:()=>void;onStop?:()=>void;
  onFetchUrlEnabledChange?:(value:boolean)=>void;onExecuteCommandEnabledChange?:(value:boolean)=>void;
  onPlanModeChange?:(value:boolean)=>void;onModelChange?:(value:string|number)=>void;
}

function compactNumber(value:number){if(!Number.isFinite(value))return'0';if(value>=1_000_000)return`${(value/1_000_000).toFixed(1)}m`;if(value>=1_000)return`${(value/1_000).toFixed(1)}k`;return String(Math.max(0,Math.round(value)));}

export function AgentContextUsage({compact=false,contextRatio,usedTokens=0,maxTokens=64000,actualUsage,labels}:Pick<SharedAgentComposerProps,'compact'|'contextRatio'|'usedTokens'|'maxTokens'|'actualUsage'|'labels'>){
  const copy={...defaultLabels,...labels},value=Math.max(0,Math.min(1,contextRatio??(maxTokens>0?usedTokens/maxTokens:0))),percent=Math.round(value*100);
  const title=[copy.contextUsage(compactNumber(usedTokens),compactNumber(maxTokens),percent),actualUsage?copy.actualUsage(actualUsage):''].filter(Boolean).join('\n');
  return <span className={`dora-agent-context${compact?' compact':''}`} style={{'--agent-context-angle':`${percent*3.6}deg`} as React.CSSProperties} title={title} aria-label={title}><i>{percent}%</i></span>;
}

export function SharedAgentComposer(props:SharedAgentComposerProps){
  const copy={...defaultLabels,...props.labels},textArea=useRef<HTMLTextAreaElement>(null),composing=useRef(false),[focused,setFocused]=useState(false);
  const compact=props.compact??false,maxLength=props.maxLength??12000,disabled=props.disabled||props.loading;
  const actionDisabled=disabled||(props.running?!props.canStop:!props.prompt.trim());
  const selected=props.models?.find(item=>String(item.id)===String(props.modelId));
  useLayoutEffect(()=>{const element=textArea.current;if(!element)return;element.style.height='0px';const max=compact?160:220;element.style.height=`${Math.max(compact?44:64,Math.min(element.scrollHeight,max))}px`;element.style.overflowY=element.scrollHeight>max?'auto':'hidden';},[compact,props.prompt]);
  const submit=()=>{if(actionDisabled)return;if(props.running)props.onStop?.();else props.onSend();};
  return <div className={`dora-agent-composer${compact?' compact':''}${focused?' focused':''}`}>
    <div className="dora-agent-composer-box">
      <textarea ref={textArea} aria-label={props.ariaLabel??'Agent 描述'} maxLength={maxLength} disabled={disabled||props.running} value={props.prompt} placeholder={props.planMode?copy.planPromptPlaceholder:copy.promptPlaceholder}
        onFocus={()=>setFocused(true)} onBlur={()=>setFocused(false)} onCompositionStart={()=>{composing.current=true;}} onCompositionEnd={event=>{composing.current=false;props.onPromptChange(event.currentTarget.value);}}
        onChange={event=>props.onPromptChange(event.target.value.slice(0,maxLength))} onKeyDown={event=>{if(composing.current||event.nativeEvent.isComposing)return;if(event.key==='Enter'&&!event.shiftKey){event.preventDefault();submit();}}}/>
      <div className="dora-agent-composer-toolbar"><div className="dora-agent-tools">
        {props.onPlanModeChange&&<button type="button" aria-pressed={!!props.planMode} disabled={disabled||props.running} onClick={()=>props.onPlanModeChange?.(!props.planMode)}>☷ {props.planMode?copy.planMode:copy.planModeInactive}</button>}
        {props.onFetchUrlEnabledChange&&!props.planMode&&<button type="button" aria-pressed={!!props.fetchUrlEnabled} disabled={disabled||props.running} onClick={()=>props.onFetchUrlEnabledChange?.(!props.fetchUrlEnabled)}>↓ {copy.networkAccess}</button>}
        {props.onExecuteCommandEnabledChange&&!props.planMode&&<button type="button" aria-pressed={!!props.executeCommandEnabled} disabled={disabled||props.running} onClick={()=>props.onExecuteCommandEnabledChange?.(!props.executeCommandEnabled)}>›_ {copy.executeCommand}</button>}
      </div><div className="dora-agent-composer-actions">
        {props.status&&<span className="dora-agent-composer-status">{props.status}</span>}
        <AgentContextUsage compact={compact} {...(props.contextRatio===undefined?{}:{contextRatio:props.contextRatio})} {...(props.usedTokens===undefined?{}:{usedTokens:props.usedTokens})} {...(props.maxTokens===undefined?{}:{maxTokens:props.maxTokens})} {...(props.actualUsage===undefined?{}:{actualUsage:props.actualUsage})} {...(props.labels===undefined?{}:{labels:props.labels})}/>
        {props.models&&<select aria-label={copy.modelForNextRun} disabled={!props.models.length||!props.onModelChange} value={selected?String(selected.id):''} onChange={event=>{const item=props.models?.find(model=>String(model.id)===event.target.value);if(item)props.onModelChange?.(item.id);}}><option value="">{copy.selectModel}</option>{props.models.map(model=><option key={String(model.id)} value={String(model.id)}>{model.name}</option>)}</select>}
        <button className={`dora-agent-send${props.running?' stop':''}`} type="button" aria-label={props.stopping?copy.stopping:props.running?copy.stop:copy.send} disabled={actionDisabled} onClick={submit}>{props.stopping?'…':props.running?'■':'↑'}</button>
      </div></div>
    </div>
  </div>;
}

export type AgentTimelineTask={taskId:number;current:boolean;messages:AgentSessionMessage[];steps:AgentSessionStep[]};
export function buildAgentTimeline(messages:readonly AgentSessionMessage[],steps:readonly AgentSessionStep[],currentTaskId?:number){
  const ids=[...new Set([...messages.map(item=>item.taskId),...steps.map(item=>item.taskId)].filter((id):id is number=>typeof id==='number'&&id>0))].sort((a,b)=>a-b);
  return {unboundMessages:messages.filter(item=>!item.taskId),unboundSteps:steps.filter(item=>!item.taskId),tasks:ids.map(taskId=>({taskId,current:taskId===currentTaskId,messages:messages.filter(item=>item.taskId===taskId),steps:steps.filter(item=>item.taskId===taskId)} satisfies AgentTimelineTask))};
}

export function useAgentTimeline(messages:readonly AgentSessionMessage[],steps:readonly AgentSessionStep[],currentTaskId?:number){return useMemo(()=>buildAgentTimeline(messages,steps,currentTaskId),[messages,steps,currentTaskId]);}

type AgentStepParam={label:string;value?:string};
const stepToolNames:Record<string,string>={message:'消息',read_file:'文件读取',edit_file:'编辑文件',delete_file:'删除文件',grep_files:'搜索文件',glob_files:'列出文件',search_dora_doc:'搜索引擎文档',compress_memory:'记忆压缩',merge_memory:'合并记忆',spawn_sub_agent:'派出子代理',list_sub_agents:'列出子代理',sub_agent_handoff:'子代理交接',build:'构建',fetch_url:'网络获取',execute_command:'执行命令',analyze_image:'画面分析',ask_user:'询问用户',finish:'收工'};
const stepStatuses:Record<string,string>={PENDING:'等待中',RUNNING:'进行中',DONE:'已完成',FAILED:'失败',STOPPED:'已停止'};
const stringValue=(value:unknown)=>typeof value==='string'?value:'';
const numberValue=(value:unknown)=>typeof value==='number'&&Number.isFinite(value)?value:undefined;
const stringList=(value:unknown)=>Array.isArray(value)?value.filter((item):item is string=>typeof item==='string'):[];
function lineRange(value:Record<string,unknown>){const start=numberValue(value.startLine)??1,end=numberValue(value.endLine)??(start<0?-1:300),label=(line:number)=>line<0?`倒数 ${Math.abs(line)}`:String(line);return `${label(start)} – ${label(end)}`;}
function summarizeStepParams(step:AgentSessionStep):AgentStepParam[]{
  const params=step.params??{},items:AgentStepParam[]=[],push=(label:string,value?:string)=>{if(value)items.push({label,value});};
  if(step.tool==='read_file'){
    const reads:Record<string,unknown>[]=[];if(stringValue(params.path))reads.push(params);if(Array.isArray(params.reads))reads.push(...params.reads.filter((item):item is Record<string,unknown>=>!!item&&typeof item==='object'&&!Array.isArray(item)));
    reads.forEach(read=>{push('文件',stringValue(read.path));push('行',lineRange(read));});return items;
  }
  if(step.tool==='glob_files'||step.tool==='grep_files'){
    push('基础路径',stringValue(params.path)==='.'?'整个工作区':stringValue(params.path));push(step.tool==='grep_files'?'内容匹配':'文件过滤',step.tool==='grep_files'?stringValue(params.pattern):stringList(params.globs).join(', '));
    if(step.tool==='grep_files')push('文件过滤',stringList(params.globs).join(', '));return items;
  }
  if(step.tool==='search_dora_doc'){push('模式',stringValue(params.pattern));push('文档类型',stringValue(params.docType));push('语言',stringValue(params.programmingLanguage));return items;}
  if(step.tool==='build'){const paths=[stringValue(params.path),...stringList(params.paths)].filter(Boolean);paths.forEach(path=>push('构建目标',path==='.'?'整个工作区':path));return items;}
  if(step.tool==='fetch_url'){push('链接',stringValue(params.url));push('目标',stringValue(params.target));return items;}
  if(step.tool==='execute_command'){push('模式',stringValue(params.mode));if(params.mode==='git')push('命令',stringValue(params.command));push('工作目录',stringValue(params.cwd));const timeout=numberValue(params.timeoutSeconds);if(timeout!==undefined)push('超时',`${timeout} 秒`);return items;}
  if(step.tool==='list_sub_agents'){push('状态',stringValue(params.status));push('查询',stringValue(params.query));return items;}
  if(step.tool==='compress_memory'){const round=numberValue(params.round),messages=numberValue(params.pendingMessages);if(round!==undefined)push('轮次',String(round));if(messages!==undefined)push('消息数',String(messages));return items;}
  return items;
}
function buildResults(step:AgentSessionStep){
  const raw=step.result?.results;if(!Array.isArray(raw))return[];
  return raw.flatMap(value=>{if(!value||typeof value!=='object'||Array.isArray(value))return[];const result=value as Record<string,unknown>,path=stringValue(result.path),messages=Array.isArray(result.messages)?result.messages:[];if(!messages.length)return[{file:path,message:stringValue(result.message),success:result.success===true}];return messages.flatMap(message=>message&&typeof message==='object'&&!Array.isArray(message)?[{file:stringValue((message as Record<string,unknown>).file)||path,message:stringValue((message as Record<string,unknown>).message),success:(message as Record<string,unknown>).success===true}]:[]);});
}
export function SharedAgentMarkdown({content,className=''}:{content:string;className?:string}){
  return <div className={`dora-agent-markdown ${className}`.trim()}><ReactMarkdown remarkPlugins={[remarkGfm]} components={{
    a({href,children}){return href&&/^https?:\/\//i.test(href)?<a href={href} target="_blank" rel="noreferrer">{children}</a>:<span>{children}</span>;},
    img({alt}){return alt?<span>{alt}</span>:null;},
  }}>{content}</ReactMarkdown></div>;
}
function StepCodeBlock({title,content}:{title:string;content:string}){return <details className="dora-agent-step-block"><summary>{title}</summary><pre>{content||'无输出'}</pre></details>;}
export function SharedAgentStepList({steps,onOpenFile}:{steps:readonly AgentSessionStep[];onOpenFile?:(path:string)=>void}){
  return <div className="dora-agent-step-list">{steps.map(step=>{
    const params=summarizeStepParams(step),buildItems=step.tool==='build'?buildResults(step):[],result=step.result??{},failure=step.status==='FAILED'&&result.success===false?stringValue(result.message):'',progress=step.status==='RUNNING'?numberValue(result.progress):undefined;
    const commandCode=step.tool==='execute_command'&&step.params?.mode==='lua'?stringValue(step.params.code):'',commandOutput=step.tool==='execute_command'?stringValue(result.output):'';
    const answer=step.tool==='questionnaire_answer'?stringValue(result.displayText):'';
    return <article key={step.id} className={`dora-agent-step ${step.status.toLowerCase()}`} data-agent-step-id={step.id}>
      <header><span className="dora-agent-step-number">{step.step}</span><span className="dora-agent-step-tool">{stepToolNames[step.tool]??step.tool}</span>{step.status!=='DONE'&&<span className="dora-agent-step-status">{stepStatuses[step.status]??step.status}</span>}</header>
      {answer?<SharedAgentMarkdown className="dora-agent-step-answer" content={answer}/>:<>{(step.reason||step.reasoningContent)&&<SharedAgentMarkdown className="dora-agent-step-reason" content={step.reason||step.reasoningContent}/>}</>}
      {params.length>0&&<dl className="dora-agent-step-params">{params.map((item,index)=><React.Fragment key={`${item.label}:${item.value}:${index}`}><dt>{item.label}</dt><dd>{item.value}</dd></React.Fragment>)}</dl>}
      {progress!==undefined&&<div className="dora-agent-step-progress" aria-label={`进度 ${Math.round(Math.max(0,Math.min(1,progress))*100)}%`}><i style={{width:`${Math.round(Math.max(0,Math.min(1,progress))*100)}%`}}/></div>}
      {commandCode&&<StepCodeBlock title="脚本代码" content={commandCode}/>}{commandOutput&&<StepCodeBlock title="输出结果" content={commandOutput}/>}
      {buildItems.length>0&&<details className="dora-agent-build-results"><summary>构建结果 · {buildItems.length}</summary>{buildItems.map((item,index)=><div key={`${item.file}:${index}`} className={item.success?'success':'failed'}><strong>{item.success?'成功':'失败'}</strong><code>{item.file}</code>{item.message&&<p>{item.message}</p>}</div>)}</details>}
      {failure&&<p className="dora-agent-step-error">{failure}</p>}
      {step.files&&step.files.length>0&&<div className="dora-agent-step-files">{step.files.map((file,index)=><button key={`${file.path}:${index}`} type="button" disabled={!onOpenFile} onClick={()=>onOpenFile?.(file.path)}><span>{file.op}</span>{file.path}</button>)}</div>}
    </article>;
  })}</div>;
}

export type SharedAgentQuestionnaireLabels={questions:string;single:string;multiple:string;text:string;recommended:string;other:string;cancel:string;previous:string;skip:string;next:string;submit:string};
export type AgentQuestionnaireAnswer={questionId:string;status:'answered'|'skipped';selectedOptionIds?:string[];otherText?:string;text?:string};
const questionnaireLabels:SharedAgentQuestionnaireLabels={questions:'问题',single:'单选',multiple:'多选',text:'文字回答',recommended:'推荐',other:'其他答案',cancel:'关闭问卷',previous:'上一步',skip:'跳过',next:'下一步',submit:'提交回答'};
export function SharedAgentQuestionnaire({questionnaire,submitting=false,labels,onSubmit,onCancel}:{questionnaire:AgentQuestionnaire;submitting?:boolean;labels?:Partial<SharedAgentQuestionnaireLabels>;onSubmit:(answers:AgentQuestionnaireAnswer[])=>void;onCancel:()=>void}){
  const copy={...questionnaireLabels,...labels},questions=questionnaire.schema.questions,draftKey=`agent-questionnaire:${questionnaire.id}`;
  const [index,setIndex]=useState(0),[answers,setAnswers]=useState<Record<string,string|string[]>>({}),[otherText,setOtherText]=useState<Record<string,string>>({}),[skipped,setSkipped]=useState<Record<string,boolean>>({}),[draftReady,setDraftReady]=useState(false);
  React.useEffect(()=>{setDraftReady(false);try{const text=sessionStorage.getItem(draftKey),draft=text?JSON.parse(text):undefined;setIndex(Math.min(Math.max(0,draft?.index??0),Math.max(0,questions.length-1)));setAnswers(draft?.answers??{});setOtherText(draft?.otherText??{});setSkipped(draft?.skipped??{});}catch{setIndex(0);setAnswers({});setOtherText({});setSkipped({});}setDraftReady(true);},[draftKey,questions.length]);
  React.useEffect(()=>{if(draftReady)sessionStorage.setItem(draftKey,JSON.stringify({index,answers,otherText,skipped}));},[draftReady,draftKey,index,answers,otherText,skipped]);
  const question=questions[index];if(!question)return null;
  const current=answers[question.id],selected=Array.isArray(current)?current:typeof current==='string'&&current?[current]:[],other=otherText[question.id]??'',isSkipped=skipped[question.id]===true;
  const valid=isSkipped?!question.required:question.type==='text'?!question.required||(typeof current==='string'&&!!current.trim()):!question.required||selected.length>0||!!other.trim(),last=index===questions.length-1;
  const clearSkip=()=>setSkipped(value=>({...value,[question.id]:false}));
  const choose=(id:string)=>{clearSkip();if(question.type==='single_choice'){setAnswers(value=>({...value,[question.id]:id}));setOtherText(value=>({...value,[question.id]:''}));}else setAnswers(value=>({...value,[question.id]:selected.includes(id)?selected.filter(item=>item!==id):[...selected,id]}));};
  const updateOther=(value:string)=>{clearSkip();setOtherText(values=>({...values,[question.id]:value}));if(question.type==='single_choice'&&value.trim())setAnswers(values=>({...values,[question.id]:''}));};
  const submission=():AgentQuestionnaireAnswer[]=>questions.map(item=>{if(skipped[item.id])return{questionId:item.id,status:'skipped'};const value=answers[item.id];if(item.type==='text')return{questionId:item.id,status:'answered',text:typeof value==='string'?value.trim():''};const selectedOptionIds=Array.isArray(value)?value:typeof value==='string'&&value?[value]:[],custom=otherText[item.id]?.trim();return{questionId:item.id,status:'answered',selectedOptionIds,...(custom?{otherText:custom}:{})};});
  const skip=()=>{if(question.required)return;setSkipped(value=>({...value,[question.id]:true}));setAnswers(value=>({...value,[question.id]:question.type==='multiple_choice'?[]:''}));setOtherText(value=>({...value,[question.id]:''}));if(last)onSubmit(submission().map(item=>item.questionId===question.id?{questionId:question.id,status:'skipped'}:item));else setIndex(value=>value+1);};
  return <section className="dora-agent-questionnaire" aria-label={questionnaire.schema.title}>
    <header><div><small>{index+1}/{questions.length} {copy.questions}</small><strong>{questionnaire.schema.title}</strong></div><div className="dora-agent-question-progress">{questions.map((_,i)=><i key={i} className={i===index?'active':''}/>)}</div></header>
    <div className="dora-agent-question-body"><h3>{question.prompt}</h3>{question.description&&<p>{question.description}</p>}<small>{question.type==='multiple_choice'?copy.multiple:question.type==='text'?copy.text:copy.single}</small>
      {question.type==='text'?<textarea rows={4} disabled={submitting} value={typeof current==='string'?current:''} placeholder={question.placeholder} onChange={event=>{clearSkip();setAnswers(value=>({...value,[question.id]:event.target.value}));}}/>:<div className="dora-agent-question-options">{(question.options??[]).map(option=><label key={option.id} className={selected.includes(option.id)?'selected':''}><input disabled={submitting} type={question.type==='single_choice'?'radio':'checkbox'} name={question.id} checked={selected.includes(option.id)} onChange={()=>choose(option.id)}/><span><strong>{option.label}{option.recommended?` (${copy.recommended})`:''}</strong>{option.description&&<small>{option.description}</small>}</span></label>)}{question.allowOther&&<input disabled={submitting} value={other} placeholder={copy.other} onChange={event=>updateOther(event.target.value)}/>}</div>}
    </div><footer><button type="button" disabled={submitting} onClick={onCancel}>{copy.cancel}</button><div><button type="button" disabled={submitting||index===0} onClick={()=>setIndex(value=>Math.max(0,value-1))}>{copy.previous}</button>{!question.required&&<button type="button" disabled={submitting} onClick={skip}>{copy.skip}</button>}<button className="primary" type="button" disabled={submitting||!valid} onClick={()=>last?onSubmit(submission()):setIndex(value=>value+1)}>{last?copy.submit:copy.next}</button></div></footer>
  </section>;
}
