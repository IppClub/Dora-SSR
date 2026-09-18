import {useSyncExternalStore} from 'react';
import type {AgentSessionController} from './agent-session-controller';
import {AgentPanel,type AgentComposer,type AgentQuestionnaireControl} from './AgentPanel';
import {AgentPauseControl} from './AgentPauseControl';
import {AgentRetirementControl, type AgentRetirement} from './AgentRetirementControl';

/** The project owner supplies an authenticated, project-bound controller. */
export function AgentSessionPanel({controller,persist,retirement,reconnect,synchronization,writeback,busy=false,modelGrantId,composer,questionnaire}: {modelGrantId?:string|undefined;controller: AgentSessionController;persist?:()=>Promise<void>;retirement?:AgentRetirement;busy?:boolean;reconnect?:{run:()=>void;disabled:boolean;status:string}|undefined;synchronization?:{run:()=>void;disabled:boolean;status:string}|undefined;writeback?:{run:()=>void;disabled:boolean;status:string}|undefined;composer?:AgentComposer;questionnaire?:AgentQuestionnaireControl}) {
  const snapshot = useSyncExternalStore(controller.subscribe, controller.getSnapshot, controller.getSnapshot);
  return <AgentPanel modelGrantId={modelGrantId} state={snapshot.state} connection={snapshot.connection} {...(composer?{composer}:{})} {...(questionnaire?{questionnaire}:{})} controls={<>
    {reconnect && <div className="agent-reconnect-control"><button disabled={busy||reconnect.disabled} onClick={reconnect.run}>重新连接 Agent</button><span role="status">{reconnect.status}</span></div>}
    {synchronization && <div className="agent-pause-control"><button disabled={busy||synchronization.disabled||snapshot.connection!=='live'||snapshot.state.deleted} onClick={synchronization.run}>同步已保存项目到 Agent</button><span role="status">{synchronization.status}</span></div>}
    {writeback && <div className="agent-pause-control"><button disabled={busy||writeback.disabled||snapshot.connection!=='live'||snapshot.state.deleted} onClick={writeback.run}>核对并接收 Agent 修改</button><span role="status">{writeback.status}</span></div>}
    {retirement ? <AgentRetirementControl retirement={retirement} disabled={busy}/> : persist && <AgentPauseControl persist={persist} disabled={busy||snapshot.connection!=='live' || snapshot.state.deleted}/>}
  </>}/>;
}
