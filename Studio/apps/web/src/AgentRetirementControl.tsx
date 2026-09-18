import {useSyncExternalStore} from 'react';
import type {createAgentRetirement, AgentRetirementPhase} from './agent-retirement';

export type AgentRetirement = ReturnType<typeof createAgentRetirement>;
const labels:Record<AgentRetirementPhase,string>={active:'保存并关闭 Agent',saving:'正在保存…','save-failed':'重试保存',cleaning:'正在清理…','cleanup-failed':'重试清理',closed:'Agent 已关闭'};
const messages:Record<AgentRetirementPhase,string>={
  active:'仅保存 Agent 会话；项目保存与云同步状态需另行确认。',
  saving:'等待任务停止并将会话写入本机。',
  'save-failed':'未确认保存，宿主仍保留。请重试保存。',
  cleaning:'会话已保存到本机，正在清理服务端启动实例。',
  'cleanup-failed':'会话已保存到本机；服务端清理未确认，可单独重试。',
  closed:'Agent 会话已保存到本机并关闭；不代表项目已同步云端。',
};

/** Cleanup remains available after the session transport has closed. */
export function AgentRetirementControl({retirement,disabled=false}:{retirement:AgentRetirement;disabled?:boolean}) {
  const {phase}=useSyncExternalStore(retirement.subscribe,retirement.getSnapshot,retirement.getSnapshot);
  return <div className="agent-pause-control">
    <button disabled={disabled||phase==='saving'||phase==='cleaning'||phase==='closed'} onClick={()=>{void retirement.run().catch(()=>{/* Coordinator exposes the failed stage. */});}}>{labels[phase]}</button>
    <span role="status">{messages[phase]}</span>
  </div>;
}
