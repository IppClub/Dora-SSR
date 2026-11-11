import React from 'react';
import {createRoot} from 'react-dom/client';
import {SharedAgentComposer} from '../../packages/agent-ui/src/AgentComposer';
import type {AgentInputCommand,AgentInputDelivery} from '../../packages/agent-ui/src/AgentFollowup';

declare global {interface Window {Module:any; userTestState:any; userTestErrors:string[]; userTestCommands:any[]}}
const pending=new Map<string,{resolve:()=>void;reject:(error:Error)=>void}>();
window.userTestErrors=[];window.userTestCommands=[];
function Test(){
 const [state,setState]=React.useState<any>(null),[prompt,setPrompt]=React.useState(''),[busy,setBusy]=React.useState(false),[error,setError]=React.useState('');
 React.useEffect(()=>{const receive=(event:MessageEvent)=>{
  if(event.origin!==location.origin||event.source!==(document.getElementById('runtime') as HTMLIFrameElement)?.contentWindow||!event.data?.agentUserTest)return;
  const value=event.data.agentUserTest;
  if(value.kind==='state'){window.userTestState=value;setState(value);}
  if(value.kind==='ack'){const waiter=pending.get(value.requestId);if(waiter){pending.delete(value.requestId);value.result.success?waiter.resolve():waiter.reject(new Error(value.result.message));}}
 };window.addEventListener('message',receive);return()=>window.removeEventListener('message',receive);},[]);
 async function command(operation:string,text='',submission?:any){
  const requestId=crypto.randomUUID(),request={operation,prompt:text,submission,requestId};window.userTestCommands.push(request);
  const frame=(document.getElementById('runtime') as HTMLIFrameElement).contentWindow!;
  await new Promise<void>((resolve,reject)=>{const timer=setTimeout(()=>{pending.delete(requestId);reject(new Error('宿主未响应'));},10000);pending.set(requestId,{resolve:()=>{clearTimeout(timer);resolve();},reject:error=>{clearTimeout(timer);reject(error);}});frame.Module.ccall('dora_web_agent_request',null,['string'],[JSON.stringify(request)]);});
 }
 async function send(delivery?:AgentInputDelivery){
  const sent=prompt;setBusy(true);setError('');try{await command('prompt',sent,{delivery});setPrompt(value=>value===sent?'':value);}catch(reason){const text=String(reason);window.userTestErrors.push(text);setError(text);}finally{setBusy(false);}
 }
 async function inputAction(action:AgentInputCommand,content?:string){await command('prompt',content??'',action);}
 const session=state?.detail?.session,running=session?.currentTaskStatus==='RUNNING';
 return <main style={{maxWidth:760,margin:'24px auto',color:'#ddd',fontFamily:'system-ui',padding:'0 8px'}}>
  <h1 style={{fontSize:18}}>Dora Agent · 隔离用户测试</h1>
  <p role="status" style={{fontSize:12,color:'#aaa'}}>{!state?'连接测试宿主…':running?'Agent 正在运行':state.idle?'Agent 已空闲':'任务正在收尾'}</p>
  {error&&<p role="alert">{error}</p>}
  <section aria-label="已投递消息" style={{height:190,overflowY:'auto',padding:12,background:'#151515',borderRadius:8}}>
   {state?.detail?.messages?.filter((item:any)=>item.role==='user').map((item:any)=><p key={item.id} style={{fontSize:13,whiteSpace:'pre-wrap',borderLeft:item.inputKind==='steer'?'2px solid #ffc13d':'2px solid #555',paddingLeft:10}}>{item.content}</p>)}
  </section>
  {(session?.currentTaskStatus==='STOPPED'||session?.currentTaskStatus==='FAILED')&&state?.idle&&<button onClick={()=>void command('continue').catch(error=>setError(String(error)))}>继续任务</button>}
  <SharedAgentComposer prompt={prompt} running={running} loading={busy} disabled={!state} onPromptChange={setPrompt} onSend={delivery=>void send(delivery)} onStop={()=>void command('stop').catch(error=>setError(String(error)))} pendingInputs={session?.pendingInputs??[]} onInputAction={inputAction} models={[{id:'fixture',name:'隔离测试模型'}]} modelId="fixture"/>
  <iframe id="runtime" title="隔离 Agent 引擎" src="/runtime-uat" style={{position:'fixed',bottom:0,left:0,width:16,height:16,opacity:0,pointerEvents:'none',border:0}}/>
 </main>;
}
createRoot(document.getElementById('root')!).render(<Test/>);
