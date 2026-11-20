export type AgentWorkMode='code'|'plan';
export interface AgentPromptOptions {workMode:AgentWorkMode;
 submission?:{delivery?:'queue'|'steer';action?:'cancel'|'edit'|'steer'|'resume'|'hold'|'release';inputId?:number}}


export const defaultAgentPromptOptions=():AgentPromptOptions=>({workMode:'code'});

export function isAgentPromptOptions(value:unknown):value is AgentPromptOptions {
  if(!value||typeof value!=='object'||Array.isArray(value))return false;
  const options=value as Record<string,unknown>;
  const submission=options.submission;
  if(submission!==undefined){
    if(!submission||typeof submission!=='object'||Array.isArray(submission))return false;
    const item=submission as Record<string,unknown>;
    if(item.delivery!==undefined&&item.delivery!=='queue'&&item.delivery!=='steer')return false;
    if(item.action!==undefined&&!['cancel','edit','steer','resume','hold','release'].includes(String(item.action)))return false;
    if(item.inputId!==undefined&&(!Number.isSafeInteger(item.inputId)||Number(item.inputId)<=0))return false;
  }
  return options.workMode==='code'||options.workMode==='plan';
}
