export type AgentWorkMode='code'|'plan';
export type AgentOptionalTool='fetch_url'|'execute_command';
export interface AgentPromptOptions {workMode:AgentWorkMode;disabledAgentTools:AgentOptionalTool[]}

export const defaultAgentPromptOptions=():AgentPromptOptions=>({workMode:'code',disabledAgentTools:['fetch_url']});

export function isAgentPromptOptions(value:unknown):value is AgentPromptOptions {
  if(!value||typeof value!=='object'||Array.isArray(value))return false;
  const options=value as Record<string,unknown>,tools=options.disabledAgentTools;
  return (options.workMode==='code'||options.workMode==='plan')&&Array.isArray(tools)&&tools.length<=2
    &&new Set(tools).size===tools.length&&tools.every(tool=>tool==='fetch_url'||tool==='execute_command');
}
