import React, {useMemo, useState} from 'react';
import ReactMarkdown from 'react-markdown';
import remarkGfm from 'remark-gfm';
import type {AgentQuestionnaire,AgentSessionMessage,AgentSessionStep} from '@dora-studio/agent-contracts/session-patches';

export {AgentContextUsage,SharedAgentComposer} from './AgentComposer';
export type {AgentActualUsage,AgentComposerLabels,AgentModelChoice,SharedAgentComposerProps} from './AgentComposer';

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
