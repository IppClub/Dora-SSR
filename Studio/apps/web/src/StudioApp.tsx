import {useEffect,useRef,useState} from 'react';
import {App} from './App';
import {loadSession} from './session-client';
import {AdminAccountsEntry} from './AdminAccounts';
import {LoginDialog} from './LoginDialog';
import {AdminModelsEntry} from './AdminModels';

/** Session refresh never remounts the local workspace or discards its draft. */
export function StudioApp(){
  const agentHostOrigin=import.meta.env.VITE_STUDIO_AGENT_HOST_ORIGIN as string|undefined;
  const [accountId,setAccountId]=useState<string>(),[status,setStatus]=useState('正在核对账号…'),[refresh,setRefresh]=useState(0);
  const [loggingOut,setLoggingOut]=useState(false);
  const [loginOpen,setLoginOpen]=useState(false);
  const generation=useRef(0),logoutBusy=useRef(false),logoutController=useRef<AbortController|undefined>(undefined);
  const sessionChannel=useRef<BroadcastChannel|undefined>(undefined);
  useEffect(()=>()=>logoutController.current?.abort(),[]);
  useEffect(()=>{
    let active=true,controller:AbortController|undefined;
    const update=()=>{
      if(logoutBusy.current)return;
      const currentGeneration=++generation.current;
      controller?.abort();const current=new AbortController();controller=current;
      // Keep the previous projection while rechecking; a focus refresh is not
      // an identity change and must not tear down a live Agent iframe.
      setStatus('正在核对账号…');
      void loadSession(current.signal).then(id=>{
        if(!active||controller!==current||generation.current!==currentGeneration)return;
        setAccountId(id??undefined);setStatus(id?'账号已连接':'尚未登录，可继续本地编辑');
      },()=>{if(active&&controller===current&&generation.current===currentGeneration)setStatus('账号暂时无法读取，可继续本地编辑');});
    };
    const visibility=()=>{if(document.visibilityState==='visible')update();};
    const restore=(event:PageTransitionEvent)=>{if(event.persisted)update();};
    let channel:BroadcastChannel|undefined;
    try{
      channel=new BroadcastChannel('dora-studio-session');sessionChannel.current=channel;
      // An invalidation is only a request to recheck the server, never identity.
      channel.onmessage=event=>{if(event.data?.type==='session-invalidated')update();};
    }catch{/* Focus/manual checks remain available when channels are unavailable. */}
    update();window.addEventListener('focus',update);document.addEventListener('visibilitychange',visibility);window.addEventListener('pageshow',restore);
    return()=>{active=false;controller?.abort();channel?.close();if(sessionChannel.current===channel)sessionChannel.current=undefined;window.removeEventListener('focus',update);document.removeEventListener('visibilitychange',visibility);window.removeEventListener('pageshow',restore);};
  },[refresh]);
  const logout=()=>{
    if(logoutBusy.current||!accountId)return;
    logoutBusy.current=true;++generation.current;setLoggingOut(true);setAccountId(undefined);setStatus('正在退出…');
    const controller=new AbortController();logoutController.current=controller;
    void fetch('/api/session/logout',{method:'POST',credentials:'same-origin',cache:'no-store',redirect:'error',signal:AbortSignal.any([controller.signal,AbortSignal.timeout(10000)])}).then(response=>{
      if(response.status!==204)throw new Error('Logout unconfirmed');
      if(!controller.signal.aborted){
        setStatus('已退出，可继续本地编辑');
        try{sessionChannel.current?.postMessage({type:'session-invalidated'});}catch{/* Logout already committed; notification failure cannot undo it. */}
      }
    }).catch(()=>{if(!controller.signal.aborted)setStatus('未能确认退出，请刷新账号核对；本地草稿仍保留');}).finally(()=>{
      logoutBusy.current=false;if(!controller.signal.aborted)setLoggingOut(false);
    });
  };
  const sessionActions=<div className="session-status"><span role="status">{status}</span><button disabled={loggingOut} onClick={()=>setRefresh(value=>value+1)}>刷新账号</button>{accountId?<><AdminAccountsEntry key={accountId} accountId={accountId} onAccessChanged={()=>setRefresh(value=>value+1)}/><AdminModelsEntry key={`models:${accountId}`} accountId={accountId}/><button onClick={logout}>退出登录</button></>:<button className="primary" onClick={()=>setLoginOpen(true)}>登录 / 邀请码注册</button>}</div>;
  return <><App topbarActions={sessionActions} {...(accountId?{accountId,...(agentHostOrigin?{agentHostOrigin}:{})}:{})}/>{loginOpen&&<LoginDialog onClose={()=>setLoginOpen(false)} onAuthenticated={()=>{setLoginOpen(false);setRefresh(value=>value+1);try{sessionChannel.current?.postMessage({type:'session-invalidated'});}catch{/* Other tabs recheck on focus. */}}}/>}</>;
}
