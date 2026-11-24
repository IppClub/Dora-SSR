import type {AgentSessionState} from './agent-session-state';
import type {AgentSessionConnection} from './agent-session-controller';
import './agent-panel.css';
import {useLayoutEffect,useRef,useState,type ReactNode} from 'react';
import {ModelAllowance} from './ModelAllowance';
import {agentStatusLabel,useStudioAgentLabels,useStudioI18n} from './i18n';
import {SharedAgentComposer,SharedAgentMarkdown,SharedAgentUserMessage,SharedAgentQuestionnaire,SharedAgentStepList,useAgentTimeline,type AgentQuestionnaireAnswer,type AgentInputControls,type AgentInputDelivery} from '@dora-studio/agent-ui';
import '@dora-studio/agent-ui/style.css';
import type {AgentModelQueueState} from './agent-model-queue';

export interface AgentComposer extends AgentInputControls {
  value:string;onChange:(value:string)=>void;onSubmit:(delivery?:AgentInputDelivery)=>void|Promise<void>;disabled:boolean;busy:boolean;placeholder?:string;submitLabel?:string;
	status?:string;
  stopping?:boolean;onStop?:()=>void|Promise<void>;
  planMode?:boolean;
  models?:Array<{id:string;name:string}>;modelId?:string;
  onPlanModeChange?:(value:boolean)=>void;onModelChange?:(value:string)=>void;
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
  const {t,toolName} = useStudioI18n();
  const {composerLabels,questionnaireLabels} = useStudioAgentLabels();
  const stepLabels = {toolName,statusName:(status:string)=>agentStatusLabel(t,status),you:t('you')};
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
  const messageView=(message:typeof messages[number])=>message.role==='user'?<SharedAgentUserMessage key={`message-${message.id}`} message={message} youLabel={stepLabels.you}/>:<article key={`message-${message.id}`} className={`agent-message ${message.role}`}><header>Dora Agent</header><SharedAgentMarkdown content={message.displayContent ?? message.content}/></article>;
  return <aside className="agent-pane" aria-label="Dora Agent">
    <div className="pane-header"><h2><span>✦</span> Dora Agent</h2><span className="badge">{state?.deleted ? t('sessionDeleted') : active ? connection === 'closed' ? t('disconnected') : connection === 'resync-required' ? t('resyncRequired') : agentStatusLabel(t,state.session.status) : t('waitingForAgent')}</span></div>
    {controls}
    {!active ? <div className="agent-body"><div className="agent-mark">✦</div><h2>{state?.deleted ? t('deletedHeading') : t('emptyHeading')}</h2><p>{t('emptyDescription')}</p><div className="agent-note">{t('emptyNote')}</div></div> :
      <div className="agent-transcript-wrap"><div ref={transcript} className="agent-transcript" aria-label={t('transcript')} onScroll={event=>{const atBottom=isAgentTranscriptAtBottom(event.currentTarget);followTail.current=atBottom;setShowLatest(!atBottom);}}>
        {connection !== 'live' && <div className="agent-question" role="status">{connection === 'resync-required' ? t('resyncDescription') : t('disconnectDescription')}</div>}
        <div className="agent-session-heading"><strong>{state.session.title}</strong><span>{state.session.workMode === 'plan' ? t('planMode') : t('createMode')}</span></div>
        {state.hasEarlierMessages && <button className="agent-history" disabled={!onLoadHistory || loadingHistory || connection !== 'live'} onClick={onLoadHistory}>{loadingHistory ? t('loadingHistory') : t('loadHistory')}</button>}
        {timeline.unboundMessages.filter(message=>message.role==='user').map(messageView)}
        {timeline.unboundSteps.length>0&&<section className="agent-activity" aria-label={t('steps')}><SharedAgentStepList labels={stepLabels} steps={timeline.unboundSteps}/></section>}
        {timeline.unboundMessages.filter(message=>message.role!=='user').map(messageView)}
        {timeline.tasks.map(task=>{
          return <section key={task.taskId} className={`agent-task${task.current?' current':''}`} aria-label={task.current?t('currentTask'):`${t('task')}${task.taskId}`}><h3><span>{task.current?t('currentTask'):`${t('task')}${task.taskId}`}</span>{task.current&&<small>{agentStatusLabel(t,state.session.currentTaskStatus??state.session.status)}</small>}</h3>{task.messages.filter(message=>message.role==='user'&&message.inputKind!=='steer').map(messageView)}{(task.steps.length>0||task.messages.some(message=>message.inputKind==='steer'))&&<div className="agent-activity" aria-label={task.current?t('currentTaskSteps'):`${t('task')}${task.taskId} · ${t('steps')}`}><SharedAgentStepList labels={stepLabels} steps={task.steps} steeringMessages={task.messages.filter(message=>message.inputKind==='steer')} running={task.current&&state.session.currentTaskStatus==='RUNNING'}/></div>}{task.current&&state.session.currentTaskStatus==='RUNNING'&&modelQueue?.state==='queued'&&<div className="agent-task-waiting model-queue" role="status"><i/>{t('queue')}{modelQueue.position-1}</div>}{task.current&&state.session.currentTaskStatus==='RUNNING'&&task.steps.length===0&&modelQueue?.state!=='queued'&&<div className="agent-task-waiting" role="status"><i/>{t('preparing')}</div>}{task.messages.filter(message=>message.role!=='user').map(messageView)}</section>;
        })}
        {state.checkpoints.orderedIds.length > 0 && <details className="agent-activity"><summary>{t('checkpoints')} · {state.checkpoints.orderedIds.length}</summary>{state.checkpoints.orderedIds.map(id => <p key={id}>{state.checkpoints.byId.get(id)!.summary}</p>)}</details>}
        {(state.session.metrics?.usage||modelGrantId)&&<div className="agent-usage"><span>{t('tokenTotal')} {state.session.metrics?.usage?.totalTokens ?? t('unreported')}</span>{modelGrantId&&<ModelAllowance compact grantId={modelGrantId} refreshSignal={`${state.session.currentTaskId??''}:${state.session.currentTaskStatus??state.session.status}:${state.session.metrics?.usage?.requestCount??0}:${state.session.metrics?.usage?.totalTokens??0}`}/>}</div>}
      </div>{showLatest&&<button type="button" className="agent-scroll-latest" onClick={()=>{const element=transcript.current;if(!element)return;followTail.current=true;element.scrollTop=element.scrollHeight;setShowLatest(false);}}>↓ {t('latest')}</button>}</div>}
    {state?.pendingQuestionnaire&&questionnaire?<SharedAgentQuestionnaire questionnaire={state.pendingQuestionnaire} labels={questionnaireLabels} submitting={questionnaire.submitting} onSubmit={questionnaire.onSubmit} onCancel={questionnaire.onCancel}/>:<SharedAgentComposer compact prompt={composer?.value??''} loading={composer?.busy??false} running={running} stopping={composer?.stopping??false} canStop={!!composer?.onStop&&!composer.stopping&&!state?.session.currentTaskFinalizing} disabled={!composer||composer.disabled} ariaLabel={t('prompt')} maxLength={5000}
      planMode={composer?.planMode??state?.session.workMode==='plan'}
      {...(composer?.models?{models:composer.models}:{})} {...(composer?.modelId?{modelId:composer.modelId}:{})}
      usedTokens={state?.session.metrics?.context?.usedTokens??0} maxTokens={state?.session.metrics?.context?.maxTokens??64000} contextRatio={state?.session.metrics?.context?.ratio??0}
      {...(state?.session.metrics?.usage?{actualUsage:{inputTokens:state.session.metrics.usage.inputTokens,outputTokens:state.session.metrics.usage.outputTokens,...(state.session.metrics.usage.cachedInputTokens===undefined?{}:{cachedInputTokens:state.session.metrics.usage.cachedInputTokens}),requestCount:state.session.metrics.usage.requestCount}}:{})}
      labels={{...composerLabels,promptPlaceholder:composer?.placeholder??(composer?t('promptPlaceholder'):t('noAgentPlaceholder')),send:composer?.submitLabel??`${t('send')} ↑`}}
	  {...(composer?.status?{status:composer.status}:{})}
      onPromptChange={value=>composer?.onChange(value)} onSend={delivery=>composer?.onSubmit(delivery)}
      pendingInputs={state?.session.pendingInputs??[]} canSteer={composer?.canSteer!==false}
      {...(composer?.onInputAction?{onInputAction:composer.onInputAction}:{})}
      {...(composer?.onStop?{onStop:composer.onStop}:{})}
      {...(composer?.onPlanModeChange?{onPlanModeChange:composer.onPlanModeChange}:{})}
      {...(composer?.onModelChange?{onModelChange:(value:string|number)=>composer.onModelChange?.(String(value))}:{})}
    />}
  </aside>;
}
