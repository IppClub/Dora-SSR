export type AgentWorkMode='code'|'plan';
export type AgentOptionalTool='fetch_url'|'execute_command';
export interface AgentPromptOptions {workMode:AgentWorkMode;disabledAgentTools:AgentOptionalTool[];
 submission?:{delivery?:'queue'|'steer';action?:'cancel'|'edit'|'steer'|'resume'|'hold'|'release';inputId?:number}}


export const defaultAgentPromptOptions=():AgentPromptOptions=>({workMode:'code',disabledAgentTools:['fetch_url']});

export function isAgentPromptOptions(value:unknown):value is AgentPromptOptions {
  if(!value||typeof value!=='object'||Array.isArray(value))return false;
  const options=value as Record<string,unknown>,tools=options.disabledAgentTools;
  const submission=options.submission;
  if(submission!==undefined){
    if(!submission||typeof submission!=='object'||Array.isArray(submission))return false;
    const item=submission as Record<string,unknown>;
    if(item.delivery!==undefined&&item.delivery!=='queue'&&item.delivery!=='steer')return false;
    if(item.action!==undefined&&!['cancel','edit','steer','resume','hold','release'].includes(String(item.action)))return false;
    if(item.inputId!==undefined&&(!Number.isSafeInteger(item.inputId)||Number(item.inputId)<=0))return false;
  }
  return (options.workMode==='code'||options.workMode==='plan')&&Array.isArray(tools)&&tools.length<=2
    &&new Set(tools).size===tools.length&&tools.every(tool=>tool==='fetch_url'||tool==='execute_command');
}
