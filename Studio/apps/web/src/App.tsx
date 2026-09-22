import { useEffect, useRef, useState } from 'react';
import type {CSSProperties,KeyboardEvent as ReactKeyboardEvent,PointerEvent as ReactPointerEvent,ReactNode} from 'react';
import { createBrowserCompiler, type CompilerClient } from '@dora-studio/compiler-web';
import { authoredProjectFiles, generatedLuaPathForSource, generatedLuaSourcePath, isProjectPath, serializeArtifactContent, type BuildArtifact, type Diagnostic, type ProjectFile, type ProjectSnapshot } from '@dora-studio/contracts';
import { prepareTealSnapshot, TealBuildError } from './teal-build';
import { LocalWorkspace, WorkspaceError, type AgentIteration, type LocalProject } from './workspace';
import {CloudProjectSync} from './CloudProjectSync';
import {resumeCloudUpload,startCloudUpload} from './cloud-project-sync';
import {ProjectBackups} from './ProjectBackups';
import {deleteCloudProject,loadCloudProject} from './cloud-project-client';
import {useProjectCatalog} from './use-project-catalog';
import {synchronizeProjectForOpen} from './project-open-sync';
import { RuntimePreview, type RuntimePreviewHandle } from './RuntimePreview';
import {resolveWorkspaceRuntimeArtifact} from './workspace-runtime-artifact';
import { appendResources } from './resource-upload';
import { ResourcePreview } from './ResourcePreview';
import { exportProject } from './project-export';
import { importStudioBackup, importDoraProject } from './project-import';
import { AgentPanel } from './AgentPanel';
import { AgentSessionPanel } from './AgentSessionPanel';
import {startWorkspaceAgent, AgentStartupFailure, isLiveWorkspaceAgent, type WorkspaceAgentBinding} from './workspace-agent';
import {reconcileAgentProject} from './agent-project-writeback-flow';
import {commitAgentWriteback} from './agent-project-writeback';
import {initialPromptTerminal,shouldAutoWriteback,type AgentTaskTerminal} from './agent-auto-writeback';
import {ModelSettingsDialog} from './ModelSettings';
import {loadModelGrants,type ModelGrantChoice} from './model-grants-client';
import {ProjectCompatibility} from './ProjectCompatibility';
import {useWorkspaceConfirm} from './useWorkspaceConfirm';
import type {AgentQuestionnaireAnswer} from '@dora-studio/agent-ui';
import {defaultAgentPromptOptions,type AgentPromptOptions,type AgentWorkMode} from './agent-prompt-options';

const assetURL = (path: string) => `${import.meta.env.BASE_URL}${path}`;
const seed = '// Dora Studio · TypeScript\nimport { Vec2 } from "Dora";\n\nexport const start = Vec2(0, 0);\n';
const updatedTime=(value:number)=>new Intl.DateTimeFormat('zh-CN',{year:'numeric',month:'2-digit',day:'2-digit',hour:'2-digit',minute:'2-digit'}).format(value);
type WorkspaceView='resources'|'agent';
const splitPreferenceKey='dora-studio:workbench-split';
const viewPreferenceKey=(projectId:string)=>`dora-studio:project-view:${projectId}`;
const readSplitPreference=()=>{try{const value=Number(localStorage.getItem(splitPreferenceKey));return Number.isFinite(value)&&value>=.25&&value<=.72?value:.45;}catch{return .45;}};
const readViewPreference=(projectId:string):WorkspaceView=>{try{return localStorage.getItem(viewPreferenceKey(projectId))==='resources'?'resources':'agent';}catch{return 'agent';}};
const savePreference=(key:string,value:string)=>{try{localStorage.setItem(key,value);}catch{/* UI preferences must never block project work. */}};
const agentMaintenanceSignal=()=>AbortSignal.timeout(15000);
const agentDispatchSignal=()=>AbortSignal.timeout(30000);
type ProjectOpenProgress={projectId:string;value:number;label:string};
const describeError = (error: unknown) => error instanceof WorkspaceError ? ({
  conflict: '其他标签页已修改这个项目。当前草稿仍保留，请另存副本或重新打开后合并。',
  quota: '浏览器存储空间不足，未保存的修改仍在此页。请保留页面并释放空间后重试。',
  closed: '本地存储连接已关闭。请保留草稿，刷新前先另存或备份。',
  unavailable: '本地存储不可用，保存未完成。请检查浏览器隐私或存储设置。',
  blocked: '请关闭其他 Studio 标签页后重试。', corrupt: '本地项目数据不完整，请从备份恢复。', invalid: error.message,
}[error.code]) : error instanceof Error ? error.message : '操作未完成，请重试。';

export function App({agent:providedAgent,agentHostOrigin,modelGrantId,accountId,topbarActions}: {agent?:WorkspaceAgentBinding;agentHostOrigin?:string;modelGrantId?:string;accountId?:string;topbarActions?:ReactNode} = {}) {
  const [modelSettingsOpen,setModelSettingsOpen]=useState(false);
  const [projectInfoOpen,setProjectInfoOpen]=useState(false),[projectInfoAttention,setProjectInfoAttention]=useState(false);
  const [projectNameDraft,setProjectNameDraft]=useState('');
  useEffect(()=>setModelSettingsOpen(false),[accountId]);
  const [ownedAgent,setOwnedAgent]=useState<WorkspaceAgentBinding>();
  const ownedAgentAccount=useRef<string|undefined>(undefined);
  const currentAccount=useRef(accountId);currentAccount.current=accountId;
  const agent=providedAgent ?? ownedAgent;
  const [agentSynced,setAgentSynced]=useState<{owner:WorkspaceAgentBinding;revision:number}>();
  const [agentSyncing,setAgentSyncing]=useState(false);
  const [agentSyncFailure,setAgentSyncFailure]=useState(false),[writebackRecoveryNeeded,setWritebackRecoveryNeeded]=useState(false);
  const [agentBaseline,setAgentBaseline]=useState<{owner:WorkspaceAgentBinding;snapshot:ProjectSnapshot}>();
  const [writebackStatus,setWritebackStatus]=useState<{owner:WorkspaceAgentBinding;revision:number;hostConfirmed:boolean;text:string}>();
  const [finishedIdea,setFinishedIdea]=useState<{owner:WorkspaceAgentBinding;projectId:string;taskId:number;status:AgentTaskTerminal}>();
  const automaticWritebackAttempts=useRef(new WeakMap<WorkspaceAgentBinding,Set<number>>());
  const liveWritebackCheckpoints=useRef(new WeakMap<WorkspaceAgentBinding,Set<number>>());
  const liveWritebackActive=useRef(false);
  const [startupFailure,setStartupFailure]=useState<AgentStartupFailure>();
  const [agentConnecting,setAgentConnecting]=useState(false);
  const [preparationFailure,setPreparationFailure]=useState(false);
  const automaticPreparationProject=useRef('');
  const automaticReconnectAttempts=useRef(new WeakSet<WorkspaceAgentBinding>());
  const startupAbort=useRef<AbortController|null>(null);
  const startupAccount=useRef<string|undefined>(undefined);
  const hostContainer=useRef<HTMLDivElement>(null);
  const agentPreview=useRef<RuntimePreviewHandle>(null);
  const storage = useRef<LocalWorkspace | null>(null);
  const compiler = useRef<CompilerClient | null>(null);
  const compileAbort = useRef<AbortController | null>(null);
  const generation = useRef(0), session = useRef(crypto.randomUUID());
  const [ready, setReady] = useState(false);
  const [project, setProject] = useState<LocalProject | null>(null), [draft, setDraft] = useState<ProjectSnapshot | null>(null);
  const [dirty, setDirty] = useState(false), [busy, setBusy] = useState(false), [error, setError] = useState('');
  const [workspaceView,setWorkspaceView]=useState<WorkspaceView>('agent');
  const [splitRatio,setSplitRatio]=useState(readSplitPreference);
  const workbench=useRef<HTMLDivElement>(null);
  const [selected, setSelected] = useState('main.ts'), [compiling, setCompiling] = useState(false);
  const [diagnostics, setDiagnostics] = useState<readonly Diagnostic[]>([]), [artifact, setArtifact] = useState<BuildArtifact | null>(null);
  const [buildStatus, setBuildStatus] = useState('尚未编译'), [createName, setCreateName] = useState('');
  const [projectStart,setProjectStart]=useState<'closed'|'choose'|'create'>('closed');
  const doraImportInput=useRef<HTMLInputElement>(null),studioBackupInput=useRef<HTMLInputElement>(null),resourceUploadInput=useRef<HTMLInputElement>(null);
  const [idea,setIdea]=useState(''),[preparingIdea,setPreparingIdea]=useState(false);
  const [followupPrompt,setFollowupPrompt]=useState(''),[sendingFollowup,setSendingFollowup]=useState(false),[stoppingAgent,setStoppingAgent]=useState(false);
  const [agentWorkMode,setAgentWorkMode]=useState<AgentWorkMode>('code');
  const [agentFetchUrlEnabled,setAgentFetchUrlEnabled]=useState(false),[agentExecuteCommandEnabled,setAgentExecuteCommandEnabled]=useState(true);
  const [questionnaireSubmitting,setQuestionnaireSubmitting]=useState(false);
  const [grantChoices,setGrantChoices]=useState<ModelGrantChoice[]>([]),[chosenGrantId,setChosenGrantId]=useState(''),[grantLoading,setGrantLoading]=useState(false),[grantFailed,setGrantFailed]=useState(false),[grantRefresh,setGrantRefresh]=useState(0);
  const selectedGrantId=modelGrantId??chosenGrantId;
  const activeGrantId=modelGrantId??(chosenGrantId||project?.creation?.grantId);
  const agentPromptOptions:AgentPromptOptions={workMode:agentWorkMode,disabledAgentTools:[...(agentFetchUrlEnabled?[]:['fetch_url'] as const),...(agentExecuteCommandEnabled?[]:['execute_command'] as const)]};
  const catalog=useProjectCatalog(ready?storage.current:null,accountId);
  const [openingProjectId,setOpeningProjectId]=useState('');
  const [projectOpenProgress,setProjectOpenProgress]=useState<ProjectOpenProgress>();
  const editor = useRef<HTMLTextAreaElement>(null);
  const [checkpoints, setCheckpoints] = useState<{revision:number;updatedAt:number}[] | null>(null);
  const confirmation=useWorkspaceConfirm();
  const confirmingAction=useRef(false);
  useEffect(()=>setProjectNameDraft(project?.name??''),[project?.snapshot.projectId,project?.name]);

  useEffect(() => {
    let alive = true;
    compiler.current = createBrowserCompiler(new URL(assetURL('compiler/worker.js'), location.href));
    void LocalWorkspace.open().then(async store => {
      if (!alive) { store.close(); return; }
      storage.current = store; setReady(true);
    }).catch(e => { if (alive) setError(describeError(e)); });
    return () => { alive = false; startupAbort.current?.abort(); compileAbort.current?.abort(); storage.current?.close(); compiler.current?.dispose(); };
  }, []);
  useEffect(()=>{
    const projectId=project?.snapshot.projectId,visibleRevision=project?.snapshot.revision;
    if(!projectId||visibleRevision===undefined||dirty||busy)return;
    let alive=true,reading=false;
    const refresh=async()=>{
      if(reading||!alive||document.visibilityState==='hidden'||!storage.current)return;
      reading=true;
      try{
        const latest=await storage.current.load(projectId);
        if(!alive||!latest||latest.snapshot.revision<=visibleRevision)return;
        setProject(latest);setDraft(latest.snapshot);setDirty(false);setCheckpoints(null);
        if(!latest.snapshot.files.some(file=>file.path===selected))setSelected(latest.snapshot.entry);
      }catch{/* Keep the visible snapshot; normal project actions surface storage failures. */}
      finally{reading=false;}
    };
    const onVisible=()=>{if(document.visibilityState==='visible')void refresh();};
    const timer=setInterval(()=>void refresh(),1500);
    addEventListener('focus',refresh);document.addEventListener('visibilitychange',onVisible);void refresh();
    return()=>{alive=false;clearInterval(timer);removeEventListener('focus',refresh);document.removeEventListener('visibilitychange',onVisible);};
  },[project?.snapshot.projectId,project?.snapshot.revision,dirty,busy,selected]);
  useEffect(()=>{
    setChosenGrantId('');setGrantChoices([]);setGrantFailed(false);
    if(!accountId)return;
    const abort=new AbortController();let active=true;setGrantLoading(true);
    void (async()=>{
      const choices:ModelGrantChoice[]=[];let after='',pages=0;
      do{const page=await loadModelGrants(after,abort.signal);choices.push(...page.configurations);after=page.nextCursor??'';pages++;if(!page.nextCursor)break;}while(pages<5);
      if(active)setGrantChoices(choices);
    })().catch(()=>{if(active)setGrantFailed(true);}).finally(()=>{if(active)setGrantLoading(false);});
    return()=>{active=false;abort.abort();};
  },[accountId,grantRefresh]);
  useEffect(()=>{
    if(modelGrantId||grantLoading||grantFailed||!grantChoices.length)return;
    const enabled=grantChoices.filter(choice=>choice.enabled);
    if(!enabled.length)return;
    const projectGrant=project?.creation?.grantId;
    const preferred=enabled.find(choice=>choice.grantId===projectGrant)?.grantId??enabled[0]?.grantId;
    if(preferred&&(!chosenGrantId||!enabled.some(choice=>choice.grantId===chosenGrantId)))setChosenGrantId(preferred);
  },[modelGrantId,grantLoading,grantFailed,grantChoices,chosenGrantId,project?.creation?.grantId]);
  useEffect(()=>{
    if(!agent)return;
    setAgentWorkMode(agent.controller.getSnapshot().state.session.workMode);
  },[agent]);
  useEffect(()=>{
    if(!agent||!stoppingAgent)return;
    const observe=()=>{if(agent.controller.getSnapshot().state.session.currentTaskStatus!=='RUNNING')setStoppingAgent(false);};
    const unsubscribe=agent.controller.subscribe(observe);observe();return unsubscribe;
  },[agent,stoppingAgent]);
  useEffect(() => {
    const protect = (event: BeforeUnloadEvent) => { if (dirty || busy || startupFailure?.cleanupPending || (agent && !agent.controller.closed && agent.retirement.getSnapshot().phase !== 'closed')) { event.preventDefault(); event.returnValue = ''; } };
    addEventListener('beforeunload', protect); return () => removeEventListener('beforeunload', protect);
  }, [dirty, busy, agent, startupFailure]);
  useEffect(()=>{
    if(projectStart==='closed')return;
    const close=(event:KeyboardEvent)=>{if(event.key==='Escape')setProjectStart('closed');};
    addEventListener('keydown',close);return()=>removeEventListener('keydown',close);
  },[projectStart]);
  useEffect(()=>{
    if(!projectInfoOpen)return;
    const close=(event:KeyboardEvent)=>{if(event.key==='Escape')setProjectInfoOpen(false);};
    addEventListener('keydown',close);return()=>removeEventListener('keydown',close);
  },[projectInfoOpen]);
  useEffect(()=>{
    if(startupAbort.current && startupAccount.current!==accountId)startupAbort.current.abort();
    if(ownedAgent && ownedAgentAccount.current!==accountId){
      startupAbort.current?.abort();ownedAgent.close?.();setOwnedAgent(undefined);
      setAgentSynced(undefined);setAgentBaseline(undefined);setWritebackStatus(undefined);
      setError('账号已变化，旧 Agent 会话已在浏览器中关闭；未确认的宿主修改请从原账号重新核对。');
    }
  },[accountId,ownedAgent]);
  useEffect(()=>{
    const projectId=project?.snapshot.projectId;
    if(!agent?.setPreviewHandler||!agent.setLuaHandler||!accountId||!projectId||agent.projectId!==projectId)return;
    agent.setPreviewHandler(async(artifact,times,signal)=>{
      if(currentAccount.current!==accountId||agent.projectId!==projectId)throw new Error('Agent 试玩所属项目或账号已变化');
      const deadline=performance.now()+5000;
      while(!agentPreview.current?.ready()){
        signal.throwIfAborted();
        if(performance.now()>=deadline)throw new Error('试玩区域尚未就绪');
        await new Promise<void>(resolve=>setTimeout(resolve,16));
      }
      signal.throwIfAborted();
      return agentPreview.current.previewAgent(artifact,times,signal);
    });
    agent.setLuaHandler(async(artifact,commandId,_timeoutSeconds,signal)=>{
      if(currentAccount.current!==accountId||agent.projectId!==projectId)throw new Error('Agent Lua 命令所属项目或账号已变化');
      const deadline=performance.now()+5000;
      while(!agentPreview.current?.ready()){
        signal.throwIfAborted();
        if(performance.now()>=deadline)throw new Error('试玩区域尚未就绪');
        await new Promise<void>(resolve=>setTimeout(resolve,16));
      }
      signal.throwIfAborted();
      return agentPreview.current.executeAgentLua(artifact,commandId,signal);
    });
    return()=>{agent.setPreviewHandler?.(undefined);agent.setLuaHandler?.(undefined);};
  },[agent,accountId,project?.snapshot.projectId]);
  useEffect(()=>{
    const task=project?.iterations?.at(-1)??project?.creation;
    // A receipt confirms the durable transaction, not that this React view is
    // still showing the committed snapshot (another tab/HMR may be stale).
    // Re-capture once per live binding so the visible workspace self-heals.
    if(!agent||!project||task?.dispatchState!=='confirmed'||!task.taskId)return;
    const projectId=project.snapshot.projectId,taskId=task.taskId;
    const observe=()=>{
      const snapshot=agent.controller.getSnapshot();
      const terminal=snapshot.connection==='live'&&!snapshot.state.deleted?initialPromptTerminal(snapshot.state.session,taskId):undefined;
      if(shouldAutoWriteback(terminal))setFinishedIdea(prior=>prior?.owner===agent&&prior.projectId===projectId&&prior.taskId===taskId?prior:{owner:agent,projectId,taskId,status:terminal});
    };
    const unsubscribe=agent.controller.subscribe(observe);observe();return unsubscribe;
  },[agent,project?.snapshot.projectId,project?.creation?.taskId,project?.creation?.dispatchState,project?.creation?.writebackState,project?.iterations]);
  useEffect(()=>{
    if(!agent?.captureLiveProject||!project||!storage.current||dirty||busy||agentBaseline?.owner!==agent||agent.projectId!==project.snapshot.projectId)return;
    const projectId=project.snapshot.projectId;
    const observe=()=>{
      const snapshot=agent.controller.getSnapshot();
      if(snapshot.connection!=='live'||snapshot.state.deleted||snapshot.state.session.currentTaskStatus!=='RUNNING'||liveWritebackActive.current)return;
      const ids=snapshot.state.checkpoints.orderedIds;
      let received=liveWritebackCheckpoints.current.get(agent);if(!received){received=new Set();liveWritebackCheckpoints.current.set(agent,received);}
      if(!ids.some(id=>!received!.has(id)))return;
      liveWritebackActive.current=true;setBusy(true);
	  void agent.captureLiveProject!(agentMaintenanceSignal()).then(captured=>commitAgentWriteback(storage.current!,agentBaseline.snapshot,captured.files)).then(async result=>{
        for(const id of ids)received!.add(id);
        setProject(result.project);setDraft(result.project.snapshot);setDirty(false);setCheckpoints(null);
        if(!result.project.snapshot.files.some(file=>file.path===selected))setSelected(result.project.snapshot.entry);
        setAgentBaseline({owner:agent,snapshot:structuredClone(result.project.snapshot)});
        setAgentSynced(undefined);await catalog.refreshLocal();
      }).catch(()=>{for(const id of ids)received!.delete(id);setWritebackRecoveryNeeded(true);setError('Agent 文件即时更新失败；任务结束后会再次自动核对。');})
        .finally(()=>{liveWritebackActive.current=false;setBusy(false);});
    };
    const unsubscribe=agent.controller.subscribe(observe);observe();return unsubscribe;
  },[agent,project,dirty,busy,agentBaseline,selected]);
  useEffect(()=>{
    const task=project?.iterations?.at(-1)??project?.creation;
    if(!finishedIdea||finishedIdea.owner!==agent||finishedIdea.projectId!==project?.snapshot.projectId||task?.taskId!==finishedIdea.taskId
      ||project?.creation?.accountId!==accountId||busy||dirty||!storage.current||!agent?.captureProject||!agent.syncProject
      ||agentBaseline?.owner!==agent)return;
    let tasks=automaticWritebackAttempts.current.get(agent);
    if(!tasks){tasks=new Set();automaticWritebackAttempts.current.set(agent,tasks);}
    if(tasks.has(finishedIdea.taskId))return;
    tasks.add(finishedIdea.taskId);
    void receiveAgentProject();
  },[finishedIdea,agent,project,accountId,busy,dirty,agentBaseline]);

  async function retireAgent() {
    // Retire even a stale binding before changing workspace ownership.
    // The host owner must not replace this binding until retirement succeeds.
    if(startupFailure?.cleanupPending){await startupFailure.retryCleanup();setStartupFailure(undefined);}
    if (agent) await agent.retirement.run();
    setOwnedAgent(undefined);
  }

  async function syncAgentProject() {
    if(busy || dirty || !agent?.syncProject || agent.controller.closed || !project || agent.projectId!==project.snapshot.projectId)return;
    setBusy(true);setAgentSyncing(true);setError('');
    try{
	  await agent.syncProject(project.snapshot,agentMaintenanceSignal());
      setAgentSynced({owner:agent,revision:project.snapshot.revision});
      setAgentBaseline({owner:agent,snapshot:structuredClone(project.snapshot)});
      setAgentSyncFailure(false);
      setWritebackStatus(undefined);
    }catch{setAgentSyncFailure(true);setError('Agent 自动同步失败。前端工作区内容仍是准确信息，可在侧栏重试。');}
    finally{setAgentSyncing(false);setBusy(false);}
  }

  async function receiveAgentProject() {
    if(busy||dirty||!storage.current||!project||!agent?.captureProject||!agent.syncProject||agent.controller.closed||agentBaseline?.owner!==agent||agent.projectId!==project.snapshot.projectId)return;
    setBusy(true);setError('');
    try{
      const iteration=project.iterations?.at(-1),task=iteration??project.creation;
      if(task?.dispatchState==='confirmed'&&task.requestId&&task.taskId&&!task.writebackState
        &&initialPromptTerminal(agent.controller.getSnapshot().state.session,task.taskId)){
        if(iteration){
          const attempted=await storage.current.markAgentIterationWriteback(project.snapshot.projectId,task.requestId,task.taskId,'attempted');
          setProject(current=>current?.snapshot.projectId===project.snapshot.projectId?{...current,iterations:(current.iterations??[]).map(item=>item.requestId===attempted.requestId?attempted:item)}:current);
        }else{
          const attempted=await storage.current.markAgentWriteback(project.snapshot.projectId,task.requestId,task.taskId,'attempted');
          setProject(current=>current?.snapshot.projectId===project.snapshot.projectId?{...current,creation:attempted}:current);
        }
      }
	  const result=await reconcileAgentProject(storage.current,{projectId:agent.projectId,captureProject:agent.captureProject,syncProject:agent.syncProject},agentBaseline.snapshot,agentMaintenanceSignal());
      if(result.committed)markBuildStale();
      setProject(result.project);setDraft(result.project.snapshot);setDirty(false);setCheckpoints(null);
      setWritebackRecoveryNeeded(false);setAgentSyncFailure(!result.hostConfirmed);
      if(!result.project.snapshot.files.some(file=>file.path===selected))setSelected(result.project.snapshot.entry);
      setAgentBaseline({owner:agent,snapshot:structuredClone(result.project.snapshot)});
      setAgentSynced(result.hostConfirmed?{owner:agent,revision:result.project.snapshot.revision}:undefined);
      setWritebackStatus({owner:agent,revision:result.project.snapshot.revision,hostConfirmed:result.hostConfirmed,text:result.hostConfirmed?result.committed?`已核对并于 ${updatedTime(result.project.updatedAt)} 保存到本机；构建与试玩由 Agent 工具自行触发。`:`Agent 任务已核对，没有检测到文件修改；可继续创作。`:`已保存到本机；Agent 确认未完成，任务准入保持关闭，请手动重试核对。`});
      await catalog.refreshLocal();
      const resultIteration=result.project.iterations?.at(-1);
      if(result.hostConfirmed&&resultIteration?.writebackState==='attempted'&&resultIteration.taskId){
        const confirmed=await storage.current.markAgentIterationWriteback(result.project.snapshot.projectId,resultIteration.requestId,resultIteration.taskId,'confirmed',result.project.snapshot.revision);
        setProject(current=>current?.snapshot.projectId===result.project.snapshot.projectId?{...current,iterations:(current.iterations??[]).map(item=>item.requestId===confirmed.requestId?confirmed:item)}:current);
      }else if(result.hostConfirmed&&result.project.creation?.writebackState==='attempted'&&result.project.creation.requestId&&result.project.creation.taskId){
        const confirmed=await storage.current.markAgentWriteback(result.project.snapshot.projectId,result.project.creation.requestId,result.project.creation.taskId,'confirmed',result.project.snapshot.revision);
        setProject(current=>current?.snapshot.projectId===result.project.snapshot.projectId?{...current,creation:confirmed}:current);
      }
    }catch{setWritebackRecoveryNeeded(true);setError('Agent 自动回写失败。前端工作区未被覆盖，可在侧栏重试接收。');}
    finally{setBusy(false);}
  }

  async function sendFollowupPrompt(){
    const creation=project?.creation;
    if(!storage.current||!project||!draft||!accountId||creation?.accountId!==accountId||!activeGrantId||!agentHostOrigin||busy||sendingFollowup||!followupPrompt.trim())return;
    setBusy(true);setSendingFollowup(true);setError('');
    try{
      let current=project;
      if(dirty){
        current=await storage.current.save(project.name,draft,project.snapshot.revision,true);
        setProject(current);setDraft(current.snapshot);setDirty(false);setCheckpoints(null);await catalog.refreshLocal();
      }
      let binding=isLiveWorkspaceAgent(agent,current.snapshot.projectId)?agent:undefined;
      if(!binding)binding=await prepareCreatedProject(current,accountId);
      const live=binding?.controller.getSnapshot();
      if(!binding?.sendPrompt||!binding.syncProject||live?.connection!=='live'||live.state.deleted)throw new Error('Agent 会话暂时无法连接');
      if(dirty||agentBaseline?.owner!==binding||agentBaseline.snapshot.revision!==current.snapshot.revision){
		await binding.syncProject(current.snapshot,agentMaintenanceSignal());
        setAgentSynced({owner:binding,revision:current.snapshot.revision});setAgentBaseline({owner:binding,snapshot:structuredClone(current.snapshot)});setAgentSyncFailure(false);
      }
      const next=await storage.current.beginAgentIteration(current.snapshot.projectId,accountId,followupPrompt,activeGrantId);
      setFollowupPrompt('');
      setProject(value=>value?.snapshot.projectId===current.snapshot.projectId?{...value,iterations:[...(value.iterations??[]),next]}:value);
      const attempted=await storage.current.markAgentIterationDispatch(current.snapshot.projectId,next.requestId,'attempted');
      setProject(value=>value?.snapshot.projectId===current.snapshot.projectId?{...value,iterations:(value.iterations??[]).map(item=>item.requestId===attempted.requestId?attempted:item)}:value);
	  const taskId=await binding.sendPrompt(next.prompt,next.grantId,next.requestId,agentPromptOptions,agentDispatchSignal());
      const confirmed=await storage.current.markAgentIterationDispatch(current.snapshot.projectId,next.requestId,'confirmed',taskId);
      setFinishedIdea(undefined);
      setProject(value=>value?.snapshot.projectId===current.snapshot.projectId?{...value,iterations:(value.iterations??[]).map(item=>item.requestId===confirmed.requestId?confirmed:item)}:value);
    }catch(e){setError(`继续创作未完成：${describeError(e)} 已保存本轮描述；投递结果不明时不会自动重发，请核对 Agent 会话。`);}
    finally{setSendingFollowup(false);setBusy(false);}
  }
  async function stopAgentTask(){
    if(!agent?.stopTask||stoppingAgent)return;
    setStoppingAgent(true);setError('');
    try{await agent.stopTask(crypto.randomUUID(),agentMaintenanceSignal());}
    catch(error){setStoppingAgent(false);setError(`停止 Agent 未完成：${describeError(error)}`);}
  }
  async function handleAgentQuestionnaire(action:'respond'|'cancel',questionnaireId:number,answers:AgentQuestionnaireAnswer[]=[]){
    if(!agent?.handleQuestionnaire||!activeGrantId||questionnaireSubmitting)return;
    if(action==='cancel'&&!await confirmation.ask({title:'关闭这份问卷？',description:'Agent 会把未作答视为你的反馈，并根据现有信息继续当前任务。',confirmLabel:'关闭并继续'}))return;
    setQuestionnaireSubmitting(true);setError('');
    try{await agent.handleQuestionnaire(action,questionnaireId,answers,activeGrantId,crypto.randomUUID(),agentDispatchSignal());setFinishedIdea(undefined);sessionStorage.removeItem(`agent-questionnaire:${questionnaireId}`);}
    catch(error){setError(`问卷提交未完成：${describeError(error)} 投递结果不明时不会自动重发，请先查看 Agent 会话。`);}
    finally{setQuestionnaireSubmitting(false);}
  }

  function abortCompilation(){generation.current++;compileAbort.current?.abort();compiler.current?.cancel();setCompiling(false);}
  function resetBuild(){abortCompilation();setArtifact(null);setDiagnostics([]);setBuildStatus('尚未编译');}
  function markBuildStale(){abortCompilation();setDiagnostics([]);setBuildStatus('有未编译更改');}
  function activate(next: LocalProject) {
    setCheckpoints(null);setFollowupPrompt('');setFinishedIdea(undefined);setProjectInfoOpen(false);setProjectInfoAttention(false);
    setPreparationFailure(false);
    setChosenGrantId(next.creation?.grantId??'');
    setAgentWorkMode('code');setAgentFetchUrlEnabled(false);setAgentExecuteCommandEnabled(true);
    resetBuild(); setProject(next); setDraft(next.snapshot); setDirty(false); setSelected(next.snapshot.entry); setError('');setWorkspaceView(readViewPreference(next.snapshot.projectId));
  }
  function selectWorkspaceView(view:WorkspaceView){
    setWorkspaceView(view);
    if(draft)savePreference(viewPreferenceKey(draft.projectId),view);
  }
  const canLeave = () => !dirty || confirmation.ask({title:'放弃未保存修改？',description:'当前草稿还没有保存到本机。放弃后，这些修改将无法从当前项目恢复。',confirmLabel:'放弃修改'});
  async function resolveRemoteUpdate(remote:{cloudRevision:number;updatedAt:number;name:string;snapshot:ProjectSnapshot},useRemote:boolean){
    if(!storage.current||!project||!accountId||busy||dirty||remote.snapshot.projectId!==project.snapshot.projectId)throw new Error('工作区已变化');
    setBusy(true);setError('');
    try{
      await retireAgent();
      await storage.current.acceptCloudBaseline(accountId,project.snapshot.projectId,remote.cloudRevision);
      if(useRemote){
        const next=await storage.current.save(remote.name,{...remote.snapshot,projectId:project.snapshot.projectId,revision:project.snapshot.revision+1},project.snapshot.revision,true,undefined,undefined,{accountId,expectedCloudRevision:remote.cloudRevision,cloudRevision:remote.cloudRevision,synced:true});
        activate(next);
      }
      await catalog.refresh();
    }finally{setBusy(false);}
  }
  async function openCatalogProject(id:string){
    const item=catalog.items.find(projectItem=>projectItem.projectId===id);
    if(!item||!storage.current||busy||confirmingAction.current)return;
    confirmingAction.current=true;
    try{
      if(!await canLeave())return;
      setBusy(true);setOpeningProjectId(id);setError('');
      try{
        setProjectOpenProgress({projectId:id,value:8,label:accountId?'正在准备同步…':'正在打开项目…'});
        const next=await synchronizeProjectForOpen({store:storage.current,projectId:id,...(accountId?{accountId}:{}),signal:new AbortController().signal,
          progress:stage=>setProjectOpenProgress({projectId:id,...stage}),
          chooseNewer:()=>confirmation.ask({title:'发现较新的项目内容',description:'其他设备上的内容更新时间更晚。是否用较新的内容更新当前浏览器中的项目？',confirmLabel:'使用较新内容',cancelLabel:'保留当前内容'}),
        });
        setProjectOpenProgress({projectId:id,value:94,label:'同步完成，正在打开…'});
        await retireAgent();await catalog.refreshLocal();activate(next);void catalog.refreshRemote().catch(()=>{});
        if(accountId&&agentHostOrigin){
          // Keep project opening and Agent startup in one deterministic chain.
          // A later effect can be skipped while the open operation owns `busy`.
          automaticPreparationProject.current=`${accountId}:${next.snapshot.projectId}`;
          setProjectOpenProgress({projectId:id,value:97,label:'同步完成，正在连接 Agent…'});
          try{
            await prepareCreatedProject(next,accountId);
          }catch(agentError){
            setPreparationFailure(true);
            if(agentError instanceof AgentStartupFailure)setStartupFailure(agentError);
            setError(`项目已打开，但 Agent 自动连接失败：${describeError(agentError)} 发起下一轮会话时会再次连接。`);
          }
        }
        setProjectOpenProgress({projectId:id,value:100,label:'项目已就绪'});
      }catch(error){setError(`项目打开失败：${describeError(error)}`);}
      finally{setProjectOpenProgress(undefined);setOpeningProjectId('');setBusy(false);}
    }finally{confirmingAction.current=false;}
  }
  async function goHome() {
    if(busy||confirmingAction.current)return;
    confirmingAction.current=true;
    try{
      if(!await canLeave())return;
      setBusy(true);setError('');
      try{
        await retireAgent();
        resetBuild();setProject(null);setDraft(null);setDirty(false);setCheckpoints(null);setFollowupPrompt('');setFinishedIdea(undefined);setSelected('main.ts');setWorkspaceView('agent');
      }catch(e){setError(describeError(e));}
      finally{setBusy(false);}
    }finally{confirmingAction.current=false;}
  }
  async function create() {
    if (!storage.current || busy || !createName.trim() || confirmingAction.current) return;
    confirmingAction.current=true;
    try{
      if(!await canLeave())return;
      setBusy(true);
      try {
        await retireAgent();
        const snapshot: ProjectSnapshot = { version: 1, projectId: crypto.randomUUID(), revision: 0, entry: 'main.ts', files: [{ path: 'main.ts', kind: 'text', text: seed }] };
        const next = await storage.current.save(createName.trim(), snapshot, null);
        await catalog.refreshLocal(); activate(next); setCreateName('');setProjectStart('closed');
      } catch (e) { setError(describeError(e)); } finally { setBusy(false); }
    }finally{confirmingAction.current=false;}
  }
  async function prepareCreatedProject(next:LocalProject,ownerAccount:string):Promise<WorkspaceAgentBinding|undefined> {
    if(!storage.current||!agentHostOrigin||!hostContainer.current)throw new Error('Agent 服务尚未就绪，请稍后在同一项目重试。');
    const abort=new AbortController();startupAbort.current=abort;startupAccount.current=ownerAccount;
    try{
      const sync=await storage.current.cloudSync(ownerAccount,next.snapshot.projectId);
      if(sync?.pending)await resumeCloudUpload(storage.current,ownerAccount,next.snapshot.projectId,abort.signal);
      else if(!sync?.cloudRevision){
        if(sync?.rejected)throw new Error('其他设备上的内容发生冲突；请在项目信息中核对，不能重新创建或覆盖。');
        await startCloudUpload(storage.current,ownerAccount,next.snapshot,abort.signal,next.name);
      }
      if(currentAccount.current!==ownerAccount||abort.signal.aborted)return undefined;
      let binding=isLiveWorkspaceAgent(agent,next.snapshot.projectId)?agent:undefined;
      if(!binding){
        setAgentConnecting(true);
        try{
          binding=await startWorkspaceAgent(hostContainer.current,next.snapshot.projectId,agentHostOrigin,abort.signal);
        }finally{setAgentConnecting(false);}
        if(currentAccount.current!==ownerAccount||abort.signal.aborted){binding.close?.();return undefined;}
        ownedAgentAccount.current=ownerAccount;setOwnedAgent(binding);
      }
      if(!binding.syncProject)throw new Error('Agent 宿主暂不支持项目文件同步。');
      setAgentSyncing(true);
      await binding.syncProject(next.snapshot,AbortSignal.any([abort.signal,agentMaintenanceSignal()]));
      if(currentAccount.current!==ownerAccount||abort.signal.aborted)return;
      setAgentSynced({owner:binding,revision:next.snapshot.revision});
      setAgentBaseline({owner:binding,snapshot:structuredClone(next.snapshot)});
      setAgentSyncFailure(false);
      setWritebackStatus(undefined);
      if(next.creation?.grantId&&next.creation.requestId&&!next.creation.dispatchState){
        if(!binding.sendPrompt)throw new Error('Agent 宿主尚不支持投递游戏描述。');
        const attempted=await storage.current.markPromptDispatch(next.snapshot.projectId,next.creation.requestId,'attempted');
        setProject(current=>current?.snapshot.projectId===next.snapshot.projectId?{...current,creation:attempted}:current);
        const taskId=await binding.sendPrompt(next.creation.prompt,next.creation.grantId,next.creation.requestId,defaultAgentPromptOptions(),AbortSignal.any([abort.signal,agentDispatchSignal()]));
        const confirmed=await storage.current.markPromptDispatch(next.snapshot.projectId,next.creation.requestId,'confirmed',taskId);
        setProject(current=>current?.snapshot.projectId===next.snapshot.projectId?{...current,creation:confirmed}:current);
      }
      setPreparationFailure(false);
      return binding;
    }finally{void catalog.refreshRemote().catch(()=>{});setAgentSyncing(false);startupAbort.current=null;startupAccount.current=undefined;}
  }
  async function createFromIdea() {
    if(!storage.current||busy||confirmingAction.current||!accountId||!agentHostOrigin||!selectedGrantId||!idea.trim())return;
    confirmingAction.current=true;
    try{
      if(!await canLeave())return;
      setBusy(true);setPreparingIdea(true);setPreparationFailure(false);setError('');
      let created=false;
      try{
        await retireAgent();
        const title=createName.trim()||(idea.trim().split(/[。！？.!?\n]/,1)[0]??'').slice(0,32).trim()||'我的新游戏';
        const snapshot:ProjectSnapshot={version:1,projectId:crypto.randomUUID(),revision:0,entry:'main.ts',files:[{path:'main.ts',kind:'text',text:seed}]};
        const next=await storage.current.createFromPrompt(title,snapshot,accountId,idea,selectedGrantId);
        created=true;activate(next);setWorkspaceView('agent');setCreateName('');setIdea('');
        await catalog.refreshLocal();
        await prepareCreatedProject(next,accountId);
      }catch(e){
        setPreparationFailure(true);
        if(e instanceof AgentStartupFailure)setStartupFailure(e);
        setError(`准备生成未完成：${describeError(e)} ${created?'已创建的项目与原描述仍保留，可在该项目继续。':'未创建项目，输入描述仍保留，可直接重试。'}`);
      }finally{setPreparingIdea(false);setBusy(false);}
    }finally{confirmingAction.current=false;}
  }
  async function startProjectAgent() {
	const foreignCreation=Boolean(project?.creation&&project.creation.accountId!==accountId);
	if(!storage.current||!project||!draft||project.creation&&!foreignCreation||busy||!accountId||!agentHostOrigin||!selectedGrantId||!followupPrompt.trim())return;
    setBusy(true);setPreparingIdea(true);setPreparationFailure(false);setError('');
    try{
	  let current:LocalProject;
	  if(foreignCreation){
		await retireAgent();
		current=await storage.current.save(`${project.name} · 当前账号副本`,{...draft,projectId:crypto.randomUUID(),revision:0},null,false);
		activate(current);setWorkspaceView('agent');await catalog.refreshLocal();
	  }else{
		current=dirty?await storage.current.save(project.name,draft,project.snapshot.revision,true):project;
		if(dirty){setDraft(current.snapshot);setDirty(false);setCheckpoints(null);await catalog.refreshLocal();}
	  }
      const creation=await storage.current.beginProjectAgent(current.snapshot.projectId,current.snapshot.revision,accountId,followupPrompt,selectedGrantId);
      const next={...current,creation};
      setProject(next);setFollowupPrompt('');selectWorkspaceView('agent');
      await prepareCreatedProject(next,accountId);
    }catch(e){
      setPreparationFailure(true);
      if(e instanceof AgentStartupFailure)setStartupFailure(e);
      setError(`Agent 创作启动未完成：${describeError(e)} 首次描述已保留时，可在当前项目继续准备。`);
    }finally{setPreparingIdea(false);setBusy(false);}
  }
  async function retryIdeaPreparation() {
    if(!project||!accountId||(project.creation&&project.creation.accountId!==accountId)||busy||dirty||!agentHostOrigin)return;
    setBusy(true);setPreparingIdea(true);setPreparationFailure(false);setError('');
    try{
      if(startupFailure?.cleanupPending){await startupFailure.retryCleanup();setStartupFailure(undefined);}
      await prepareCreatedProject(project,accountId);
      setPreparationFailure(false);
    }catch(e){setPreparationFailure(true);if(e instanceof AgentStartupFailure)setStartupFailure(e);}
    finally{setPreparingIdea(false);setBusy(false);}
  }
  useEffect(()=>{automaticPreparationProject.current='';},[accountId,project?.snapshot.projectId]);
  useEffect(()=>{
    const creation=project?.creation,key=project&&accountId?`${accountId}:${project.snapshot.projectId}`:'';
    const live=project?isLiveWorkspaceAgent(agent,project.snapshot.projectId):false;
    const reconnect=!!agent&&!!project&&agent.projectId===project.snapshot.projectId&&agent.controller.closed&&!automaticReconnectAttempts.current.has(agent);
    if(!project||(creation&&creation.accountId!==accountId)||!agentHostOrigin||!accountId||live||busy||dirty||preparingIdea||(!reconnect&&automaticPreparationProject.current===key))return;
    if(reconnect)automaticReconnectAttempts.current.add(agent);
    automaticPreparationProject.current=key;
    void retryIdeaPreparation();
  // Connection is attempted once for every opened account/project pair. A
  // failed start is retried by the next prompt instead of requiring a connect button.
  // eslint-disable-next-line react-hooks/exhaustive-deps
  },[accountId,project?.snapshot.projectId,project?.creation,agentHostOrigin,agent,busy,dirty,preparingIdea]);
  async function save(copy = false) {
    if (!storage.current || !draft || !project || busy) return;
    setBusy(true); setError('');
    try {
      if (copy) await retireAgent();
      const next = await storage.current.save(copy ? `${project.name} · 副本` : project.name,
        copy ? { ...draft, projectId: crypto.randomUUID(), revision: 0 } : draft,
        copy ? null : project.snapshot.revision, !copy);
      // Editing is disabled during this transaction, so the submitted draft is still current.
      if (copy) activate(next); else {
        setProject(next); setDraft(next.snapshot); setDirty(false);
        if(agent?.syncProject&&agent.projectId===next.snapshot.projectId&&!agent.controller.closed){
          setAgentSyncing(true);
          try{
            await agent.syncProject(next.snapshot,agentMaintenanceSignal());
            setAgentSynced({owner:agent,revision:next.snapshot.revision});setAgentBaseline({owner:agent,snapshot:structuredClone(next.snapshot)});setAgentSyncFailure(false);
          }catch{setAgentSyncFailure(true);setError('项目已保存到前端工作区，但 Agent 自动同步失败，可在侧栏重试。');}
          finally{setAgentSyncing(false);}
        }
      }
      await catalog.refreshLocal(); setCheckpoints(null);
    } catch (e) { setError(describeError(e)); } finally { setBusy(false); }
  }
  async function renameProject(){
    const name=projectNameDraft.trim();
    if(!storage.current||!project||!draft||dirty||busy||!name||name===project.name)return;
    setBusy(true);setError('');
    try{
      const next=await storage.current.save(name,{...project.snapshot,revision:project.snapshot.revision+1},project.snapshot.revision,true);
      setProject(next);setDraft(next.snapshot);setDirty(false);setCheckpoints(null);await catalog.refreshLocal();
      if(agent?.syncProject&&agent.projectId===next.snapshot.projectId&&!agent.controller.closed){
        setAgentSyncing(true);
        try{await agent.syncProject(next.snapshot,agentMaintenanceSignal());setAgentSynced({owner:agent,revision:next.snapshot.revision});setAgentBaseline({owner:agent,snapshot:structuredClone(next.snapshot)});setAgentSyncFailure(false);}
        catch{setAgentSyncFailure(true);setError('项目名称已保存，但 Agent 作者基线同步失败，可在侧栏重试。');}
        finally{setAgentSyncing(false);}
      }
    }catch(error){setError(describeError(error));}
    finally{setBusy(false);}
  }
  async function deleteCurrentProject(){
    if(!storage.current||!project||busy||confirmingAction.current)return;
    confirmingAction.current=true;
    try{
      const accepted=await confirmation.ask({title:`删除项目“${project.name}”？`,description:`将删除${accountId?'浏览器工作区、云端内容及':'浏览器工作区中的'}项目文件和历史记录。此操作不能撤销，请先下载 ZIP 备份需要保留的内容。`,confirmLabel:'删除项目'});
      if(!accepted)return;
      setBusy(true);setError('');
      const deleting=project;
      try{
        await retireAgent();
        if(accountId)await deleteCloudProject(accountId,deleting.snapshot.projectId,new AbortController().signal);
        await storage.current.remove(deleting.snapshot.projectId,deleting.snapshot.revision);
        resetBuild();setProject(null);setDraft(null);setDirty(false);setCheckpoints(null);setFollowupPrompt('');setFinishedIdea(undefined);setSelected('main.ts');setWorkspaceView('agent');setProjectInfoOpen(false);setProjectInfoAttention(false);
        await catalog.refresh();
      }catch(error){setError(`项目删除失败：${describeError(error)} 未完成的部分不会被隐藏，请重试。`);}
      finally{setBusy(false);}
    }finally{confirmingAction.current=false;}
  }
  function changeFiles(files: readonly ProjectFile[]) {
    if (!draft || !project || busy) return;
    markBuildStale(); setDraft({ ...draft, revision: project.snapshot.revision + 1, files }); setDirty(true);
  }
  async function showCheckpoints() {
    if (!storage.current || !project || busy) return;
    if (checkpoints !== null) { setCheckpoints(null); return; }
    setBusy(true);
    try { setCheckpoints(await storage.current.listCheckpointSummaries(project.snapshot.projectId)); }
    catch (error) { setError(describeError(error)); } finally { setBusy(false); }
  }
  async function restoreRevision(revision: number) {
    if (!storage.current || !project || busy || confirmingAction.current) return;
    confirmingAction.current=true;
    try{
      if(!await canLeave())return;
      const checkpoint=checkpoints?.find(item=>item.revision===revision);
      if(!await confirmation.ask({title:`恢复 ${checkpoint?updatedTime(checkpoint.updatedAt):'所选时间'} 的内容？`,description:'当前已保存内容会先保留到历史记录，再恢复所选内容。',confirmLabel:'恢复内容'}))return;
      setBusy(true);
      try {
        await retireAgent();
        const next = await storage.current.restoreCheckpoint(project.snapshot.projectId, revision, project.snapshot.revision);
        activate(next); await catalog.refreshLocal();
      } catch (error) { setError(describeError(error)); } finally { setBusy(false); }
    }finally{confirmingAction.current=false;}
  }
  function addFile() {
    if (!draft) return;
    const path = prompt('新文件路径，例如 logic/player.ts');
    if (path === null) return;
    if (!isProjectPath(path) || draft.files.some(f => f.path === path || f.path.startsWith(path + '/') || path.startsWith(f.path + '/'))) { setError('路径无效或与现有文件冲突。'); return; }
    changeFiles([...draft.files, { path, kind: 'text', text: '' }]); setSelected(path); selectWorkspaceView('resources');
  }
  async function deleteSelectedFile(){
    if(!draft||!project||!file||busy||confirmingAction.current)return;
    const generatedPath=generatedLuaPathForSource(file.path);
    const removedPaths=new Set([file.path,...(generatedPath?[generatedPath]:[])]);
    const remaining=draft.files.filter(item=>!removedPaths.has(item.path)),authored=authoredProjectFiles(remaining);
    const deletesEntry=removedPaths.has(draft.entry);
    if(deletesEntry&&!authored.length){setError('入口文件是项目最后一个可编辑资源，不能删除。请先新建或上传替代文件。');return;}
    const nextEntry=deletesEntry?authored[0]!.path:draft.entry;
    confirmingAction.current=true;
    try{
      const generatedNote=generatedPath&&draft.files.some(item=>item.path===generatedPath)?` 同时会删除它生成的 ${generatedPath}。`:'';
      const accepted=await confirmation.ask({title:`删除 ${file.path}？`,description:(deletesEntry?`该文件是当前入口。删除后会把 ${nextEntry} 设为新入口；`:'文件会从当前草稿移除；')+generatedNote+' 保存项目后生效，已保存版本仍可从历史记录恢复。',confirmLabel:'删除资源'});
      if(!accepted)return;
      markBuildStale();setDraft({...draft,revision:project.snapshot.revision+1,entry:nextEntry,files:remaining});setDirty(true);setSelected(nextEntry);
    }finally{confirmingAction.current=false;}
  }
  async function uploadResources(files: File[]) {
    if (!draft || busy || !files.length) return;
    const current = generation.current;
    setBusy(true); setError('');
    try {
      const updated = await appendResources(draft.files, files);
      if (current === generation.current) changeFiles(updated);
    } catch (error) { setError(describeError(error)); }
    finally { setBusy(false); }
  }
  async function downloadProject() {
    if (!draft || !project || busy) return;
    setBusy(true); setError('');
    try {
      const bytes = await exportProject(project.name, draft);
      const url = URL.createObjectURL(new Blob([new Uint8Array(bytes)], { type: 'application/zip' }));
      const link = document.createElement('a');
      link.href = url; link.download = `${project.name.replace(/[\\/:*?"<>|\x00-\x1f]/g, '_').slice(0, 100) || 'project'}.zip`;
      link.click(); setTimeout(() => URL.revokeObjectURL(url), 10000);
    } catch (error) { setError(describeError(error)); }
    finally { setBusy(false); }
  }
  async function restoreBackup(file: File | undefined, dora = false) {
    if (!file || busy || !storage.current || confirmingAction.current) return;
    confirmingAction.current=true;
    try{
      if(!await canLeave())return;
      setBusy(true); setError('');
      try {
        const imported = await (dora ? importDoraProject(file) : importStudioBackup(file));
        await retireAgent();
        const next = await storage.current.save(imported.name, imported.snapshot, null);
        await catalog.refreshLocal(); activate(next);
      } catch (error) { setError(describeError(error)); }
      finally { setBusy(false); }
    }finally{confirmingAction.current=false;}
  }
  async function compile() {
    if (!draft || !compiler.current || compiling) return;
    await compileSnapshot(draft);
  }
  async function compileSnapshot(input:ProjectSnapshot) {
    if(!compiler.current)return;
    const current = generation.current, snapshot = structuredClone(input), requestId = crypto.randomUUID();
    const controller = new AbortController(); compileAbort.current = controller;
    setCompiling(true); setBuildStatus('正在编译…'); setError(''); setDiagnostics([]);
    try {
      const authoredFiles=authoredProjectFiles(snapshot.files);
      const needsScriptPreflight = authoredFiles.some(file => file.kind === 'text' && (file.path.endsWith('.lua') || (file.path.endsWith('.tl') && !file.path.endsWith('.d.tl'))));
      const compilerSnapshot = needsScriptPreflight ? await prepareTealSnapshot(snapshot, controller.signal) : snapshot;
      const declarations = await Promise.all(['Dora.d.ts', 'es6-subset.d.ts', 'lua.d.ts', 'jsx.d.ts', 'lualib_bundle.lua'].map(async path => {
        const response = await fetch(assetURL(`declarations/${path}`)); if (!response.ok) throw new Error(`无法加载编译声明：${path}`);
        return { path, kind: 'text' as const, text: await response.text() };
      }));
      if (current !== generation.current) return;
      const result = await compiler.current.compile({ version: 1, sessionId: session.current, projectId: snapshot.projectId,
        revision: snapshot.revision, requestId, buildId: crypto.randomUUID(), compilerVersion: 'dora-tstl-0.1.0-ts5.9.3',
        type: 'compile', snapshot:compilerSnapshot, declarations, options: {}, timeoutMs: 30000 }, controller.signal);
      if (result.type === 'compiled' && needsScriptPreflight) {
        const composite = {...result.artifact,compilerVersion:result.artifact.compilerVersion + '+teal-0.15.3+dora'};
        const digest = await crypto.subtle.digest('SHA-256',new TextEncoder().encode(serializeArtifactContent(composite)));
        Object.assign(result.artifact,composite,{sha256:[...new Uint8Array(digest)].map(byte=>byte.toString(16).padStart(2,'0')).join('')});
      }
      if (current !== generation.current) return;
      if (result.type === 'compiled') { const warnings=result.diagnostics.filter(item=>item.severity==='warning').length;setArtifact(result.artifact); setDiagnostics(result.diagnostics); setBuildStatus(`编译成功 · ${result.artifact.files.length} 个产物文件${warnings?` · ${warnings} 条警告`:''}`); }
      else if (result.type === 'compileFailed') { setDiagnostics(result.diagnostics); setBuildStatus('编译失败，请查看问题列表'); }
      else if (result.type === 'cancelled') setBuildStatus('编译已取消');
      else { setBuildStatus('编译未完成'); setError(result.message); }
    } catch (e) { if (current === generation.current) { setError(describeError(e)); setBuildStatus(e instanceof TealBuildError?'编译失败，请查看问题列表':'编译未完成'); if (e instanceof TealBuildError) setDiagnostics(e.diagnostics); } }
    finally { if (current === generation.current) setCompiling(false); }
  }
  function cancel() { abortCompilation(); setBuildStatus('编译已取消'); }
  function locate(d: Diagnostic) {
    if (!d.path || !draft?.files.some(f => f.path === d.path && f.kind === 'text')) return;
    setSelected(d.path); selectWorkspaceView('resources');
    requestAnimationFrame(() => { editor.current?.focus(); editor.current?.setSelectionRange(d.start ?? 0, (d.start ?? 0) + (d.length ?? 0)); });
  }
  const splitBounds=()=>{
    const width=workbench.current?.getBoundingClientRect().width??0;
    if(!width)return {width:0,min:.25,max:.72};
    const compact=width<=820,minPreview=compact?270:300,minWorkspace=compact?360:410,gutter=6;
    return {width,min:Math.max(.25,minPreview/width),max:Math.min(.72,(width-minWorkspace-gutter)/width)};
  };
  function setRememberedSplit(next:number){
    const bounds=splitBounds(),value=Math.max(bounds.min,Math.min(Math.max(bounds.min,bounds.max),next));
    setSplitRatio(value);savePreference(splitPreferenceKey,String(value));
  }
  function beginSplitResize(event:ReactPointerEvent<HTMLDivElement>){
    if(matchMedia('(max-width: 800px)').matches)return;
    event.preventDefault();const handle=event.currentTarget;handle.setPointerCapture(event.pointerId);let latest=splitRatio;
    const move=(next:PointerEvent)=>{const rect=workbench.current?.getBoundingClientRect();if(!rect)return;const bounds=splitBounds();latest=Math.max(bounds.min,Math.min(Math.max(bounds.min,bounds.max),(next.clientX-rect.left)/rect.width));setSplitRatio(latest);};
    const finish=()=>{savePreference(splitPreferenceKey,String(latest));handle.removeEventListener('pointermove',move);handle.removeEventListener('pointerup',finish);handle.removeEventListener('pointercancel',finish);};
    handle.addEventListener('pointermove',move);handle.addEventListener('pointerup',finish);handle.addEventListener('pointercancel',finish);
  }
  function resizeWithKeyboard(event:ReactKeyboardEvent<HTMLDivElement>){
    if(event.key!=='ArrowLeft'&&event.key!=='ArrowRight'&&event.key!=='Home')return;
    event.preventDefault();setRememberedSplit(event.key==='Home'?.45:splitRatio+(event.key==='ArrowLeft'?-.03:.03));
  }
  const projectFiles=draft?authoredProjectFiles(draft.files):[];
  const diagnosticErrors=diagnostics.filter(item=>item.severity==='error').length;
  const diagnosticWarnings=diagnostics.filter(item=>item.severity==='warning').length;
  const visibleSelected=draft?(generatedLuaSourcePath(selected,draft.files)??selected):selected;
  const file = projectFiles.find(f => f.path === visibleSelected);
  const ideaSynced=Boolean(agentSynced&&agent&&agentSynced.owner===agent&&agentSynced.revision===project?.snapshot.revision);
  const latestIteration=project?.iterations?.at(-1);
  const sessionSnapshot=agent?.controller.getSnapshot();
  const showAgentReconnect=Boolean(project&&accountId&&agentHostOrigin&&preparationFailure&&!isLiveWorkspaceAgent(agent,project.snapshot.projectId));
  const reconnectStatus=dirty?'请先保存当前资源修改，再重新连接。':'自动连接失败；项目内容仍保存在浏览器工作区。';
  const reconnectControl=showAgentReconnect?<div className="agent-reconnect-control"><button disabled={busy||dirty||preparingIdea} onClick={()=>void retryIdeaPreparation()}>重新连接 Agent</button><span role="status">{reconnectStatus}</span></div>:undefined;
	const foreignAgentProject=Boolean(project?.creation&&project.creation.accountId!==accountId);
  const followupReady=Boolean(project?.creation&&!foreignAgentProject&&activeGrantId&&accountId&&agentHostOrigin);
	const startOrMigrateReady=Boolean(project&&(!project.creation||foreignAgentProject)&&accountId&&agentHostOrigin&&selectedGrantId&&!grantLoading&&!grantFailed);
	const followupDisabled=!(project?.creation&&!foreignAgentProject?followupReady:startOrMigrateReady)||busy||sendingFollowup;
	const followupStatus=sendingFollowup?'正在发送…'
	  :busy?'正在完成项目保存或同步…'
	  :!accountId?'账号未登录'
	  :foreignAgentProject?'发送时会保留原项目，并创建当前账号副本'
	  :!agentHostOrigin?'Agent 服务未配置'
	  :!activeGrantId?'尚未选择可用模型'
	  :undefined;
  const ideaAvailability=!accountId?'请先登录受邀账号'
    :!agentHostOrigin?'Agent 服务尚未配置'
    :grantLoading?'正在读取可用模型…'
    :grantFailed?'可用模型读取失败，请刷新重试'
    :!grantChoices.some(item=>item.enabled)?'当前账号没有可用模型，请联系管理员分配额度'
    :!selectedGrantId?'请选择授权模型'
    :'描述与模型选择会保存到新项目';
  const agentComposerSettings={
    planMode:agentWorkMode==='plan',fetchUrlEnabled:agentFetchUrlEnabled,executeCommandEnabled:agentExecuteCommandEnabled,
    models:grantChoices.filter(item=>item.enabled).map(item=>({id:item.grantId,name:`${item.label} · ${item.model}`})),
    ...(activeGrantId?{modelId:activeGrantId}:{}),
    onPlanModeChange:(enabled:boolean)=>setAgentWorkMode(enabled?'plan':'code'),onFetchUrlEnabledChange:setAgentFetchUrlEnabled,onExecuteCommandEnabledChange:setAgentExecuteCommandEnabled,
    ...(modelGrantId?{}:{onModelChange:setChosenGrantId}),
  };
  return <div className={`app-shell${!draft||!project?' home-shell':''}`}>
    <aside className="sidebar">
      <a className="brand" href="#" aria-label="返回首页" onClick={e => {e.preventDefault();void goHome();}}><img src={assetURL('dora-symbol.svg')} alt="Dora"/><span>Dora<small>STUDIO</small></span></a>
      <div className="local-label"><i/>创作空间 <span>ALPHA</span></div>
      <button className="project-start-trigger" disabled={!ready||busy} onClick={()=>setProjectStart('choose')}><span>＋</span><span>新建 / 导入<small>空白项目或 Dora 游戏包</small></span></button>
      <div className="section-label">项目 <span>{catalog.items.length}</span></div>
      <nav aria-label="项目列表">{catalog.items.length ? catalog.items.map(p => {
        const progress=projectOpenProgress?.projectId===p.projectId?projectOpenProgress:undefined,opening=openingProjectId===p.projectId;
        return <button className={`${p.projectId === draft?.projectId ? 'active ' : ''}project-link${opening?' opening':''}`} title={p.projectId} key={p.projectId} disabled={busy} aria-busy={opening} onClick={() => void openCatalogProject(p.projectId)}><span className={opening?'project-opening-spinner':undefined}>{opening?'':'◇'}</span><span>{p.name}<small>{progress?.label??`更新于 ${updatedTime(p.updatedAt)}`}</small></span>{progress&&<span className="project-link-progress" role="progressbar" aria-label={`${p.name} 同步进度`} aria-valuemin={0} aria-valuemax={100} aria-valuenow={progress.value}><i style={{width:`${progress.value}%`}}/></span>}</button>;
      }) : <p className="muted">{catalog.state==='loading'?'正在读取项目…':<>还没有项目。<br/>从一个空白项目开始。</>}</p>}</nav>
      {catalog.state==='failed'&&<p className="project-catalog-status" role="status">暂时无法读取其他设备上的项目；当前项目仍可正常使用，恢复连接后会自动重试。</p>}
      <button disabled={!accountId} onClick={()=>setModelSettingsOpen(true)}>模型与用量{accountId?'':' · 登录后可用'}</button>
    </aside>
    <main className={!draft||!project?'home-main':undefined}>
      <header className="topbar"><span>创作 / 工作室</span><div className="topbar-controls"><span className="connection">{ready ? '● 本地存储可用' : '○ 正在连接本地存储'}</span>{topbarActions}</div></header>
      {error&&<div className="toast-stack">
        {error&&<div className="floating-alert warning" role="alert"><i aria-hidden="true">!</i><span>{error}</span><div>{dirty&&<button disabled={busy} onClick={()=>void save(true)}>另存副本</button>}<button aria-label="关闭错误提示" onClick={()=>setError('')}>×</button></div></div>}
      </div>}
      {!draft || !project ? <section className="welcome"><div className="eyebrow">DORA STUDIO · 创作工作区</div><h1>从一个想法，<br/>开始<span>你的游戏。</span></h1><p>描述你想创作的玩法。Studio 会为这句话建立独立项目，保留原描述，连接受邀 Agent 并投递创作任务。</p><form className="idea-form" onSubmit={e=>{e.preventDefault();void createFromIdea();}}><label htmlFor="game-idea">游戏创意</label><textarea id="game-idea" value={idea} maxLength={5000} onChange={e=>setIdea(e.target.value)} placeholder="例如：做一个小猫在雨夜屋顶收集星光的横版小游戏，点击跳跃，碰到云朵会改变重力…"/>
        <div className="idea-model-select"><label htmlFor="game-model">本次创作使用的共享模型</label><div><select id="game-model" aria-label="本次创作使用的共享模型" value={selectedGrantId} disabled={!accountId||busy||!!modelGrantId} onChange={event=>setChosenGrantId(event.target.value)}><option value="">请选择已授权模型</option>{grantChoices.filter(item=>item.enabled).map(item=><option key={item.grantId} value={item.grantId}>{item.label} · {item.model}</option>)}</select><button type="button" disabled={!accountId||grantLoading||busy} onClick={()=>setGrantRefresh(value=>value+1)}>刷新</button></div><small>{grantLoading?'正在读取授权…':grantFailed?'授权读取失败，请刷新重试。':!grantChoices.some(item=>item.enabled)?'尚无可用授权，请管理员先配置共享模型和账号额度。':'模型不会自动切换；每次请求按账号及逐 API 额度准入。'}</small></div>
        <div className="idea-form-footer"><span>{ideaAvailability}</span><button className="primary" disabled={!ready||busy||!accountId||!agentHostOrigin||grantLoading||grantFailed||!selectedGrantId||!idea.trim()}>{preparingIdea?'正在创建项目并启动 Agent…':'✦ 新建并启动 Agent 创作'}</button></div></form><div className="welcome-card"><span>✦</span><div><strong>由原 Dora Agent 执行创作</strong><p>任务开始后可在侧栏查看进展；当前一轮完成或停止后，再发起下一轮修改。Agent 仍通过原有工具触发构建和试玩，文件检查点会自动更新到 Studio。</p></div></div><p className="hint">也可从左侧新建空白 TypeScript 项目，或导入 Dora 游戏包。</p></section> : <>
        <div className="project-header"><div><h1>{agentConnecting&&<i className="project-agent-spinner" aria-hidden="true"/>}{project.name}</h1><span role="status">{busy ? '正在处理项目…' : dirty ? '有未保存修改' : `更新于 ${updatedTime(project.updatedAt)}`}</span></div><div className="actions"><button className={projectInfoAttention?'attention':''} aria-expanded={projectInfoOpen} onClick={()=>setProjectInfoOpen(true)}>项目信息{projectInfoAttention?' · 需处理':''}</button><button disabled={busy} onClick={() => void downloadProject()}>下载 ZIP</button><button disabled={busy} onClick={() => void save(true)}>另存副本</button><button className="primary" disabled={!dirty || busy} onClick={() => void save()}>保存项目</button></div></div>
        <div ref={workbench} className="studio-workbench" data-workspace-view={workspaceView} style={{'--preview-pane-ratio':`${splitRatio*100}%`} as CSSProperties}>
          <section className="preview-pane" aria-label="试玩区">
            <RuntimePreview ref={agentPreview} key={draft.projectId} artifact={artifact} resolveArtifact={()=>resolveWorkspaceRuntimeArtifact(draft,artifact)} controls={<button className="compile-button" onClick={compiling ? cancel : () => void compile()}>{compiling ? '取消编译' : '▷ 编译项目'}</button>}/>
            <div className="build-status" role="status">{buildStatus}{artifact && <span>SHA-256 {artifact.sha256.slice(0, 10)}…</span>}</div>
          </section>
          <div className="workbench-resizer" role="separator" aria-label="调整试玩与工作区宽度" aria-orientation="vertical" aria-valuemin={25} aria-valuemax={72} aria-valuenow={Math.round(splitRatio*100)} tabIndex={0} onPointerDown={beginSplitResize} onKeyDown={resizeWithKeyboard} onDoubleClick={()=>setRememberedSplit(.45)}/>
          <section className="workspace-pane" aria-label="创作工作区">
            <div className="pane-header workspace-heading"><div className="tabs">{(['agent','resources'] as const).map(view => <button key={view} aria-pressed={workspaceView === view} onClick={() => selectWorkspaceView(view)}>{({resources:'资源',agent:'Dora Agent'})[view]}</button>)}</div>{workspaceView === 'resources' && <small>{visibleSelected}</small>}</div>
            {workspaceView === 'resources' && <div className="workspace-code-view workspace-resource-view">
              <div className="code-pane"><div className="files"><div className="section-label">项目资源<div className="resource-file-actions"><button aria-label="选择资源上传" disabled={busy} onClick={()=>resourceUploadInput.current?.click()}>⇧</button><button aria-label="新建文件" disabled={busy} onClick={addFile}>＋</button></div></div>{projectFiles.map(f => <button aria-label={f.path} title={f.path} key={f.path} className={f.path === visibleSelected ? 'active' : ''} onClick={() => setSelected(f.path)}><span aria-hidden="true">{f.kind === 'text' ? '≡' : '▧'}</span>{f.path}</button>)}</div><div className="editor-pane"><div className="editor-heading"><span>{visibleSelected}</span><div><small>{file?.kind === 'text' ? 'UTF-8' : file?.kind === 'binary'?`${file.bytes.byteLength} 字节`:'未选择资源'}</small><button className="delete-resource" disabled={busy||!file} onClick={()=>void deleteSelectedFile()}>删除</button></div></div>{file?.kind === 'text' ? <textarea ref={editor} aria-label="项目代码" spellCheck={false} disabled={busy} value={file.text} onChange={e => changeFiles(draft.files.map(f => f.path === visibleSelected ? { path: f.path, kind: 'text', text: e.target.value } : f))}/> : <div className="resource-binary-editor"><ResourcePreview file={file}/></div>}</div></div>
              <div className="diagnostics"><div className="section-label">构建消息 <span>{diagnosticErrors} 错误 · {diagnosticWarnings} 警告</span></div>{diagnostics.map((d, i) => <button key={i} onClick={() => locate(d)}><span className={`diagnostic-kind ${d.severity}`}>{d.severity==='error'?'错误':d.severity==='warning'?'警告':'提示'}</span><span>{d.message}<small>{d.path ?? '编译器'} · {d.code}</small></span></button>)}</div>
            </div>}
            <div className="agent-workspace-view" hidden={workspaceView !== 'agent'}>
              {agent && agent.projectId === project.snapshot.projectId ? <AgentSessionPanel modelGrantId={activeGrantId} {...(agent.modelQueue?{modelQueue:agent.modelQueue}:{})} controller={agent.controller} busy={busy} {...(showAgentReconnect?{reconnect:{run:()=>void retryIdeaPreparation(),disabled:dirty||preparingIdea,status:reconnectStatus}}:{})} composer={{value:followupPrompt,onChange:setFollowupPrompt,onSubmit:()=>void (project.creation&&!foreignAgentProject?sendFollowupPrompt():startProjectAgent()),disabled:followupDisabled,busy:sendingFollowup||preparingIdea,...(followupStatus?{status:followupStatus}:{}),placeholder:project.creation&&!foreignAgentProject?'继续描述你希望修改的玩法…':'描述希望 Agent 为当前项目实现的玩法…',submitLabel:foreignAgentProject?'创建当前账号副本并启动 ↑':project.creation?'发送 ↑':'启动 Agent ↑',...(agent.stopTask?{onStop:()=>void stopAgentTask(),stopping:stoppingAgent}:{}),...agentComposerSettings}} {...(agent.handleQuestionnaire&&activeGrantId&&sessionSnapshot?.state.pendingQuestionnaire?{questionnaire:{submitting:questionnaireSubmitting,onSubmit:(answers:AgentQuestionnaireAnswer[])=>void handleAgentQuestionnaire('respond',sessionSnapshot.state.pendingQuestionnaire!.id,answers),onCancel:()=>void handleAgentQuestionnaire('cancel',sessionSnapshot.state.pendingQuestionnaire!.id)}}:{})} synchronization={agentSyncFailure&&agent.syncProject?{
                run:()=>void syncAgentProject(),disabled:dirty,
                status:agentSyncing?'正在重试同步…':'Agent 自动同步失败；前端工作区内容未丢失。',
			  }:undefined} writeback={writebackRecoveryNeeded&&agent.captureProject&&agent.syncProject?{run:()=>void receiveAgentProject(),disabled:dirty||agentBaseline?.owner!==agent,status:'Agent 自动回写失败；请重试接收，前端现有内容不会被直接覆盖。'}:undefined}/> : <AgentPanel modelGrantId={activeGrantId} controls={reconnectControl} composer={{value:followupPrompt,onChange:setFollowupPrompt,onSubmit:()=>void (project.creation&&!foreignAgentProject?sendFollowupPrompt():startProjectAgent()),disabled:followupDisabled,busy:sendingFollowup||preparingIdea,...(followupStatus?{status:followupStatus}:{}),placeholder:project.creation&&!foreignAgentProject?'继续描述你希望修改的玩法…':'描述希望 Agent 为当前项目实现的玩法…',submitLabel:foreignAgentProject?'创建当前账号副本并启动 ↑':project.creation?'发送 ↑':'启动 Agent ↑',...agentComposerSettings}}/>}
            </div>
          </section>
        </div>
      </>}
      <div ref={hostContainer} className="agent-host-runtime" aria-hidden="true" />
      {confirmation.node}
      {modelSettingsOpen&&accountId&&
        <ModelSettingsDialog key={accountId} accountId={accountId} modelGrantId={activeGrantId} onClose={()=>setModelSettingsOpen(false)}/>
      }
    </main>
    {project&&draft&&<>
      {projectInfoOpen&&<div className="project-info-backdrop" onMouseDown={event=>{if(event.target===event.currentTarget)setProjectInfoOpen(false);}}/>}
      <aside className={`project-info-drawer ${projectInfoOpen?'open':''}`} role="dialog" aria-modal="true" aria-hidden={!projectInfoOpen} aria-labelledby="project-info-title" inert={!projectInfoOpen}>
        <div className="project-info-heading"><div><small>项目信息</small><h2 id="project-info-title">{project.name}</h2></div><button aria-label="关闭项目信息" onClick={()=>setProjectInfoOpen(false)}>×</button></div>
        <div className="project-info-body">
          <section><h3>项目名称</h3><form className="project-rename" onSubmit={event=>{event.preventDefault();void renameProject();}}><input aria-label="修改项目名称" maxLength={200} disabled={busy} value={projectNameDraft} onChange={event=>setProjectNameDraft(event.target.value)}/><button disabled={busy||dirty||!projectNameDraft.trim()||projectNameDraft.trim()===project.name}>保存名称</button></form>{dirty&&<small className="project-info-note">请先保存当前资源修改，再更改项目名称。</small>}</section>
          <section><h3>兼容性</h3><ProjectCompatibility snapshot={draft}/></section>
          {accountId&&storage.current&&<section><h3>自动保存</h3><CloudProjectSync key={`${accountId}:${project.snapshot.projectId}`} store={storage.current} accountId={accountId} name={project.name} snapshot={project.snapshot} localUpdatedAt={project.updatedAt} disabled={busy||dirty||Boolean(project.creation&&!ideaSynced&&!preparationFailure)} onResolveRemote={resolveRemoteUpdate} onAttentionChange={setProjectInfoAttention} onSynchronized={()=>void catalog.refreshRemote().catch(()=>{})}/><ProjectBackups accountId={accountId} projectId={project.snapshot.projectId}/></section>}
          <section><h3>历史记录</h3><div className="checkpoint-bar"><button disabled={busy} aria-expanded={checkpoints !== null} onClick={() => void showCheckpoints()}>{checkpoints===null?'查看历史记录':'收起历史记录'}</button>{checkpoints !== null && <div aria-label="历史记录列表">{checkpoints.length ? checkpoints.map(item => <button key={item.revision} disabled={busy} onClick={() => void restoreRevision(item.revision)}>恢复 {updatedTime(item.updatedAt)}</button>) : <span>暂无历史记录，保存修改后会自动保留先前内容。</span>}</div>}</div></section>
          <section className="project-danger-zone"><h3>删除项目</h3><p>永久删除当前项目、历史记录及已同步的云端内容。</p><button disabled={busy} onClick={()=>void deleteCurrentProject()}>删除项目</button></section>
        </div>
      </aside>
    </>}
    <input ref={doraImportInput} className="visually-hidden" type="file" accept=".dora,.zip" disabled={!ready||busy} aria-label="导入 Dora 游戏包" onChange={event=>{const file=event.target.files?.[0];event.target.value='';setProjectStart('closed');void restoreBackup(file,true);}}/>
    <input ref={studioBackupInput} className="visually-hidden" type="file" accept=".zip" disabled={!ready||busy} aria-label="恢复 Studio ZIP" onChange={event=>{const file=event.target.files?.[0];event.target.value='';setProjectStart('closed');void restoreBackup(file);}}/>
    <input ref={resourceUploadInput} className="visually-hidden" type="file" multiple disabled={!draft||busy} aria-label="上传资源" onChange={event=>{const files=Array.from(event.target.files??[]);event.target.value='';void uploadResources(files);}}/>
    {projectStart!=='closed'&&<div className="project-start-backdrop" onMouseDown={event=>{if(event.target===event.currentTarget)setProjectStart('closed');}}>
      <section className="project-start-sheet" role="dialog" aria-modal="true" aria-labelledby="project-start-title">
        <div className="project-start-heading">
          {projectStart==='create'&&<button className="sheet-back" type="button" onClick={()=>setProjectStart('choose')}>‹ 返回</button>}
          <div><small>DORA STUDIO</small><h2 id="project-start-title">{projectStart==='choose'?'新建或导入项目':'新建项目'}</h2></div>
          <button className="sheet-close" type="button" aria-label="关闭新建或导入面板" onClick={()=>setProjectStart('closed')}>×</button>
        </div>
        {projectStart==='choose'?<>
          <p className="project-start-intro">像 Dora Go 模式一样，先选择你要开始的方式。</p>
          <div className="project-start-options">
            <button type="button" onClick={()=>setProjectStart('create')}><span className="option-icon">＋</span><span><strong>新建空白项目</strong><small>从 TypeScript 基础项目开始创作</small></span><b>›</b></button>
            <button type="button" className="primary-option" disabled={busy} onClick={()=>doraImportInput.current?.click()}><span className="option-icon">⇧</span><span><strong>导入游戏包</strong><small>打开 .dora 或普通源码 ZIP</small></span><b>›</b></button>
          </div>
          <div className="project-start-more"><span>项目迁移</span><button type="button" disabled={busy} onClick={()=>studioBackupInput.current?.click()}>恢复 Studio 备份 ZIP</button></div>
          <p className="project-start-note">导入后会创建新项目，不会覆盖现有内容；运行兼容性会在进入项目后显示。</p>
        </>:<form className="project-create-form" onSubmit={event=>{event.preventDefault();void create();}}>
          <div className="project-language"><span>TS</span><div><strong>TypeScript</strong><small>Dora Studio 当前的默认创作语言</small></div><b>✓</b></div>
          <label htmlFor="project-name">项目名称</label>
          <input id="project-name" autoFocus placeholder="给你的游戏起个名字" maxLength={200} value={createName} onChange={event=>setCreateName(event.target.value)}/>
          <div className="project-create-actions"><button type="button" onClick={()=>setProjectStart('closed')}>取消</button><button className="primary" disabled={!ready||busy||!createName.trim()}>{busy?'正在创建…':'创建并进入 Studio'}</button></div>
        </form>}
      </section>
    </div>}
  </div>;
}
