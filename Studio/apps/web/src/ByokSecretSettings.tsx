import {useEffect,useRef,useState} from 'react';
import {requestByokSecret,SecretRequestError,type SecretMetadata} from './byok-secret-client';
import './byok-secret-settings.css';

/** The account settings owner supplies its authenticated account and selected
 * configuration. accountId only resets local UI; the server authorizes itself. */
export function ByokSecretSettings({accountId,configurationId,label='自带 API'}:{accountId:string;configurationId:string;label?:string}) {
  return <SecretForm key={JSON.stringify([accountId,configurationId])} configurationId={configurationId} label={label}/>;
}
function SecretForm({configurationId,label}:{configurationId:string;label:string}) {
  const input=useRef<HTMLInputElement>(null);
  const context=useRef<{controller:AbortController;active:boolean;busy:boolean}|undefined>(undefined);
  const [metadata,setMetadata]=useState<SecretMetadata>();
  const [busy,setBusy]=useState(true),[notice,setNotice]=useState('正在读取托管状态…');
  const [consent,setConsent]=useState(false),[hasInput,setHasInput]=useState(false),[confirmRevoke,setConfirmRevoke]=useState(false);
  async function perform(operation:Parameters<typeof requestByokSecret>[1]) {
    const current=context.current;if(!current?.active||current.busy)return;
    current.busy=true;setBusy(true);setConfirmRevoke(false);
    if(operation.method==='GET'){setMetadata(undefined);setNotice('正在读取托管状态…');}
    try{
      const next=await requestByokSecret(configurationId,operation,current.controller.signal);
      if(!current.active||context.current!==current)return;
      setMetadata(next);setNotice(operation.method==='GET'?'':operation.method==='PUT'?'密钥已加密保存；尚未验证供应商连接。':'已撤销托管密钥；不会撤销供应商端的 Key。');
    }catch(error){
      if(!current.active||context.current!==current)return;
      setMetadata(undefined);setNotice(error instanceof SecretRequestError?error.message:'状态未确认，请刷新后再操作。');
    }finally{if(current.active&&context.current===current){current.busy=false;setBusy(false);}}
  }
  useEffect(()=>{
    const current={controller:new AbortController(),active:true,busy:false};context.current=current;
    void perform({method:'GET'});
    return()=>{current.active=false;current.controller.abort();if(input.current)input.current.value='';};
  },[configurationId]);
  return <section className="byok-settings" aria-label="自带 API 密钥设置">
    <header><div><span className="byok-eyebrow">模型设置 / BYOK</span><h2>{label}</h2></div><span className="byok-state">{metadata?metadata.available?'已托管':'未托管':'待确认'}</span></header>
    <p>使用你自己的 API Key。供应商费用由你承担，不扣平台共享额度。</p>
    <form onSubmit={event=>{
      event.preventDefault();if(busy||!metadata||!consent||!input.current?.value)return;
      const key=input.current.value;input.current.value='';setHasInput(false);setConsent(false);
      void perform({method:'PUT',expectedVersion:metadata.version,key,consent:true});
    }}>
      <label className="byok-key-label">{metadata?.available?'替换 API Key':'API Key'}<input ref={input} type="password" autoComplete="new-password" spellCheck={false} aria-label="API Key" disabled={busy||!metadata} onChange={event=>setHasInput(Boolean(event.target.value))} placeholder="输入后加密托管，不会回显旧密钥"/></label>
      <label className="byok-consent"><input type="checkbox" checked={consent} disabled={busy||!metadata} onChange={event=>setConsent(event.target.checked)}/><span>我同意 Studio 加密保存此 Key，用于我授权的模型调用。</span></label>
      <div className="byok-actions"><button className="byok-save" type="submit" disabled={busy||!metadata||!consent||!hasInput}>{metadata?.available?'保存替换':'加密保存'}</button><button type="button" disabled={busy} onClick={()=>void perform({method:'GET'})}>刷新状态</button>{metadata?.available&&<button type="button" disabled={busy} onClick={()=>setConfirmRevoke(true)}>撤销托管</button>}</div>
    </form>
    {confirmRevoke&&metadata&&<div className="byok-revoke"><p>撤销后 Studio 不能再用此托管密钥发起新调用。供应商端密钥及已有在途请求不会因此取消。</p><button disabled={busy} onClick={()=>void perform({method:'DELETE',expectedVersion:metadata.version})}>确认撤销托管</button><button disabled={busy} onClick={()=>setConfirmRevoke(false)}>保留</button></div>}
    {notice&&<p className="byok-notice" role="status">{notice}</p>}
    <small>仅显示托管状态，不显示供应商余额。使用记录将区分已知用量与待补记用量。</small>
  </section>;
}
