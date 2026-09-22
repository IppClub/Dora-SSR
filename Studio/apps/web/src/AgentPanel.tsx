import type {AgentSessionState} from './agent-session-state';
import type {AgentSessionConnection} from './agent-session-controller';
import './agent-panel.css';
import {useLayoutEffect,useRef,useState,type ReactNode} from 'react';
import {ModelAllowance} from './ModelAllowance';
import {SharedAgentComposer,SharedAgentMarkdown,SharedAgentQuestionnaire,SharedAgentStepList,useAgentTimeline,type AgentQuestionnaireAnswer} from '@dora-studio/agent-ui';
import '@dora-studio/agent-ui/style.css';
import type {AgentModelQueueState} from './agent-model-queue';

const statuses: Record<string, string> = {IDLE:'就绪', RUNNING:'进行中', WAITING_USER:'等待回答', DONE:'已完成', FAILED:'失败', STOPPED:'已停止', PENDING:'等待中'};
export interface AgentComposer {
  value:string;onChange:(value:string)=>void;onSubmit:()=>void;disabled:boolean;busy:boolean;placeholder?:string;submitLabel?:string;
	status?:string;
  stopping?:boolean;onStop?:()=>void;
  planMode?:boolean;fetchUrlEnabled?:boolean;executeCommandEnabled?:boolean;
  models?:Array<{id:string;name:string}>;modelId?:string;
  onPlanModeChange?:(value:boolean)=>void;onFetchUrlEnabledChange?:(value:boolean)=>void;onExecuteCommandEnabledChange?:(value:boolean)=>void;onModelChange?:(value:string)=>void;
}
export interface AgentQuestionnaireControl {submitting:boolean;onSubmit:(answers:AgentQuestionnaireAnswer[])=>void;onCancel:()=>void}
export function isAgentTranscriptAtBottom(element:Pick<HTMLElement,'scrollHeight'|'scrollTop'|'clientHeight'>,threshold=48){return element.scrollHeight-element.scrollTop-element.clientHeight<threshold;}

/** Presentation only. Commands remain disabled until an authenticated host is connected. */
export function AgentPanel({state, onLoadHistory, loadingHistory = false, connection = 'live',controls,modelGrantId,modelQueue,composer,questionnaire}: {
  modelGrantId?:string|undefined;
  modelQueue?:AgentModelQueueState;
  controls?:ReactNode;
  state?: AgentSessionState;
  onLoadHistory?: () => void;
  loadingHistory?: boolean;
  connection?: AgentSessionConnection;
  composer?:AgentComposer;
  questionnaire?:AgentQuestionnaireControl;
}) {
  const active = state && !state.deleted;
  const transcript=useRef<HTMLDivElement>(null),followTail=useRef(true),lastTaskId=useRef<number|undefined>(undefined),[showLatest,setShowLatest]=useState(false);
  const currentTaskId=state?.session.currentTaskId;
  const running=state?.session.currentTaskStatus==='RUNNING';
  useLayoutEffect(()=>{
    const element=transcript.current;if(!element)return;
    if(lastTaskId.current!==currentTaskId){lastTaskId.current=currentTaskId;followTail.current=true;setShowLatest(false);}
    const align=()=>{if(followTail.current){element.scrollTop=element.scrollHeight;setShowLatest(false);}};
    align();
    // A restored session may first render while its Agent tab is hidden. Align
    // again after layout so the initial history opens at the latest message.
    let second=0;const first=requestAnimationFrame(()=>{align();second=requestAnimationFrame(align);});
    return()=>{cancelAnimationFrame(first);if(second)cancelAnimationFrame(second);};
  },[state,currentTaskId]);
  useLayoutEffect(()=>{
    const element=transcript.current;if(!element||typeof ResizeObserver==='undefined')return;
    const observer=new ResizeObserver(()=>{if(followTail.current&&element.clientHeight>0){element.scrollTop=element.scrollHeight;setShowLatest(false);}});
    observer.observe(element);return()=>observer.disconnect();
  },[active]);
  const messages=state?state.messages.orderedIds.map(id=>state.messages.byId.get(id)!):[];
  const steps=state?state.steps.orderedIds.map(id=>state.steps.byId.get(id)!):[];
  const timeline=useAgentTimeline(messages,steps,currentTaskId);
  const messageView=(message:typeof messages[number])=><article key={`message-${message.id}`} className={`agent-message ${message.role}`}><header>{message.role === 'user' ? '你' : 'Dora Agent'}</header><SharedAgentMarkdown content={message.displayContent ?? message.content}/></article>;
  return <aside className="agent-pane" aria-label="Dora Agent">
    <div className="pane-header"><h2><span>✦</span> Dora Agent</h2><span className="badge">{state?.deleted ? '会话已删除' : active ? connection === 'closed' ? '已断开' : connection === 'resync-required' ? '待同步' : statuses[state.session.status] ?? state.session.status : '待接入'}</span></div>
    {controls}
    {!active ? <div className="agent-body"><div className="agent-mark">✦</div><h2>{state?.deleted ? '这个会话已删除' : '和你的想法一起成长'}</h2><p>描述玩法、调整细节，<br/>让 Agent 帮你把游戏做出来。</p><div className="agent-note">当前版本尚未连接 Agent 服务，不会调用模型或产生模型费用。</div></div> :
      <div className="agent-transcript-wrap"><div ref={transcript} className="agent-transcript" aria-label="Agent 会话记录" onScroll={event=>{const atBottom=isAgentTranscriptAtBottom(event.currentTarget);followTail.current=atBottom;setShowLatest(!atBottom);}}>
        {connection !== 'live' && <div className="agent-question" role="status">{connection === 'resync-required' ? '会话更新中断，需要重新同步。下方保留最后收到的记录。' : '会话连接已关闭。下方记录不再实时更新。'}</div>}
        <div className="agent-session-heading"><strong>{state.session.title}</strong><span>{state.session.workMode === 'plan' ? '计划模式' : '创作模式'}</span></div>
        {state.hasEarlierMessages && <button className="agent-history" disabled={!onLoadHistory || loadingHistory || connection !== 'live'} onClick={onLoadHistory}>{loadingHistory ? '正在读取历史…' : '加载更早的消息'}</button>}
        {timeline.unboundMessages.filter(message=>message.role==='user').map(messageView)}
        {timeline.unboundSteps.length>0&&<section className="agent-activity" aria-label="执行步骤"><SharedAgentStepList steps={timeline.unboundSteps}/></section>}
        {timeline.unboundMessages.filter(message=>message.role!=='user').map(messageView)}
        {timeline.tasks.map(task=>{
          return <section key={task.taskId} className={`agent-task${task.current?' current':''}`} aria-label={task.current?'当前 Agent 任务':`Agent 任务 ${task.taskId}`}><h3><span>{task.current?'当前任务':`任务 #${task.taskId}`}</span>{task.current&&<small>{statuses[state.session.currentTaskStatus??state.session.status]??state.session.currentTaskStatus??state.session.status}</small>}</h3>{task.messages.filter(message=>message.role==='user').map(messageView)}{task.steps.length>0&&<div className="agent-activity" aria-label={task.current?'当前任务执行步骤':`任务 ${task.taskId} 执行步骤`}><SharedAgentStepList steps={task.steps}/></div>}{task.current&&state.session.currentTaskStatus==='RUNNING'&&modelQueue?.state==='queued'&&<div className="agent-task-waiting model-queue" role="status"><i/>共享模型繁忙，正在自动排队等待（前方 {modelQueue.position-1} 个请求）…</div>}{task.current&&state.session.currentTaskStatus==='RUNNING'&&task.steps.length===0&&modelQueue?.state!=='queued'&&<div className="agent-task-waiting" role="status"><i/>正在准备上下文并请求模型…</div>}{task.messages.filter(message=>message.role!=='user').map(messageView)}</section>;
        })}
        {state.checkpoints.orderedIds.length > 0 && <details className="agent-activity"><summary>修改检查点 · {state.checkpoints.orderedIds.length}</summary>{state.checkpoints.orderedIds.map(id => <p key={id}>{state.checkpoints.byId.get(id)!.summary}</p>)}</details>}
        {(state.session.metrics?.usage||modelGrantId)&&<div className="agent-usage"><span>累计 Token {state.session.metrics?.usage?.totalTokens ?? '未报告'}</span>{modelGrantId&&<ModelAllowance compact grantId={modelGrantId} refreshSignal={`${state.session.currentTaskId??''}:${state.session.currentTaskStatus??state.session.status}:${state.session.metrics?.usage?.requestCount??0}:${state.session.metrics?.usage?.totalTokens??0}`}/>}</div>}
      </div>{showLatest&&<button type="button" className="agent-scroll-latest" onClick={()=>{const element=transcript.current;if(!element)return;followTail.current=true;element.scrollTop=element.scrollHeight;setShowLatest(false);}}>↓ 滚动到最新消息</button>}</div>}
    {state?.pendingQuestionnaire&&questionnaire?<SharedAgentQuestionnaire questionnaire={state.pendingQuestionnaire} submitting={questionnaire.submitting} onSubmit={questionnaire.onSubmit} onCancel={questionnaire.onCancel}/>:<SharedAgentComposer compact prompt={composer?.value??''} loading={composer?.busy??false} running={running} stopping={composer?.stopping??false} canStop={!!composer?.onStop&&!composer.stopping&&!state?.session.currentTaskFinalizing} disabled={!composer||composer.disabled} ariaLabel="Agent 描述" maxLength={5000}
      planMode={composer?.planMode??state?.session.workMode==='plan'} fetchUrlEnabled={composer?.fetchUrlEnabled??false} executeCommandEnabled={composer?.executeCommandEnabled??true}
      {...(composer?.models?{models:composer.models}:{})} {...(composer?.modelId?{modelId:composer.modelId}:{})}
      usedTokens={state?.session.metrics?.context?.usedTokens??0} maxTokens={state?.session.metrics?.context?.maxTokens??64000} contextRatio={state?.session.metrics?.context?.ratio??0}
      {...(state?.session.metrics?.usage?{actualUsage:{inputTokens:state.session.metrics.usage.inputTokens,outputTokens:state.session.metrics.usage.outputTokens,...(state.session.metrics.usage.cachedInputTokens===undefined?{}:{cachedInputTokens:state.session.metrics.usage.cachedInputTokens}),requestCount:state.session.metrics.usage.requestCount}}:{})}
      labels={{promptPlaceholder:composer?.placeholder??(composer?'继续描述你希望修改的玩法…':'连接 Agent 后可继续描述修改…'),send:composer?.submitLabel??'发送 ↑'}}
	  {...(composer?.status?{status:composer.status}:{})}
      onPromptChange={value=>composer?.onChange(value)} onSend={()=>composer?.onSubmit()}
      {...(composer?.onStop?{onStop:composer.onStop}:{})}
      {...(composer?.onPlanModeChange?{onPlanModeChange:composer.onPlanModeChange}:{})}
      {...(composer?.onFetchUrlEnabledChange?{onFetchUrlEnabledChange:composer.onFetchUrlEnabledChange}:{})}
      {...(composer?.onExecuteCommandEnabledChange?{onExecuteCommandEnabledChange:composer.onExecuteCommandEnabledChange}:{})}
      {...(composer?.onModelChange?{onModelChange:(value:string|number)=>composer.onModelChange?.(String(value))}:{})}
    />}
  </aside>;
}
