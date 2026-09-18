import {useEffect,useRef,useState} from 'react';
import {requestConfiguration} from './ByokCreateConfiguration';
import './model-settings.css';
import {AdminAccountAudit} from './AdminAccountAudit';

type Account={accountId:string;enabled:boolean;administrator:boolean;version:number};
type Page={items:Account[];nextCursor:string|null};
function decode(value:unknown):Page{
  const data=value as {version?:number;items?:Account[];nextCursor?:unknown};
  if(!data||data.version!==1||!Array.isArray(data.items)||data.items.length>100||data.nextCursor!==null&&typeof data.nextCursor!=='string')throw new Error('Invalid account page');
  const ids=new Set<string>();
  const items=data.items.map(row=>{
    if(!row||Object.keys(row).some(key=>!['accountId','enabled','administrator','version'].includes(key))||typeof row.accountId!=='string'||!row.accountId.trim()||row.accountId.length>256||typeof row.enabled!=='boolean'||typeof row.administrator!=='boolean'||!Number.isSafeInteger(row.version)||row.version<1||ids.has(row.accountId))throw new Error('Invalid account');
    ids.add(row.accountId);return {...row};
  });
  if(data.nextCursor!==null&&(!items.length||data.nextCursor!==items.at(-1)!.accountId))throw new Error('Invalid account cursor');
  return {items,nextCursor:data.nextCursor as string|null};
}
export function AdminAccountsEntry({accountId,onAccessChanged}:{accountId:string;onAccessChanged:()=>void}){
  const [allowed,setAllowed]=useState(false),[open,setOpen]=useState(false);
  useEffect(()=>{
    let active=true;const controller=new AbortController();
    void requestConfiguration('/api/admin/accounts?limit=1',controller.signal).then(value=>{decode(value);if(active)setAllowed(true);}).catch(()=>{if(active)setAllowed(false);});
    return()=>{active=false;controller.abort();};
  },[]);
  return <>{allowed&&<button onClick={()=>setOpen(true)}>账号管理</button>}{open&&<AdminAccountsDialog accountId={accountId} onAccessChanged={()=>{setAllowed(false);setOpen(false);onAccessChanged();}} onClose={()=>setOpen(false)}/>}</>;
}
function AdminAccountsDialog({onClose,accountId,onAccessChanged}:{onClose:()=>void;accountId:string;onAccessChanged:()=>void}){
  const dialog=useRef<HTMLDialogElement>(null);
  const [audit,setAudit]=useState(false),[invite,setInvite]=useState(false);
  const [after,setAfter]=useState(''),[refresh,setRefresh]=useState(0),[page,setPage]=useState<Page>(),[failed,setFailed]=useState(false);
  useEffect(()=>{dialog.current?.showModal();return()=>dialog.current?.close();},[]);
  useEffect(()=>{
    let active=true;const controller=new AbortController();setPage(undefined);setFailed(false);
    if(audit)return()=>{active=false;controller.abort();};
    void requestConfiguration(`/api/admin/accounts?limit=20&after=${encodeURIComponent(after)}`,controller.signal).then(value=>{const result=decode(value);if(result.nextCursor===after)throw new Error('Cursor did not advance');if(active)setPage(result);}).catch(()=>{if(active)setFailed(true);});
    return()=>{active=false;controller.abort();};
  },[after,refresh,audit]);
  return <dialog ref={dialog} className="model-settings-dialog" aria-label="账号管理" onCancel={event=>{event.preventDefault();onClose();}}><header><h2>账号管理</h2><button autoFocus onClick={onClose}>关闭账号管理</button></header>
    <div className="model-settings"><div className="model-config-toolbar"><button aria-pressed={!audit&&!invite} onClick={()=>{setAudit(false);setInvite(false);}}>账号列表</button><button aria-pressed={invite} onClick={()=>{setInvite(true);setAudit(false);}}>邀请新账号</button><button aria-pressed={audit} onClick={()=>{setAudit(true);setInvite(false);}}>操作记录</button></div>{invite?<AdminInvitation/>:audit?<AdminAccountAudit/>:<><p>停用后账号不能访问云端功能，不删除作品或撤销所有会话。重新启用后有效会话可恢复访问。请谨慎授予管理权限。</p>
      <button onClick={()=>setRefresh(value=>value+1)}>刷新账号列表</button>
      {!page?<p role="status">{failed?'无法读取账号列表，请确认管理权限后重试。':'正在读取账号列表…'}</p>:<>
        <ul className="admin-account-list">{page.items.map(row=><li key={`${row.accountId}:${row.version}`}><strong>{row.accountId}</strong><span>{row.administrator?'管理员':'创作者'} · {row.enabled?'已启用':'已停用'} · v{row.version}</span><AccountToggle row={row} onSaved={saved=>{
          if(saved.accountId===accountId&&(!saved.enabled||!saved.administrator)){onAccessChanged();return;}
          setPage(current=>current?{...current,items:current.items.map(item=>item.accountId===saved.accountId?saved:item)}:current);
        }}/></li>)}</ul>
        {!page.items.length&&<p>本页没有账号。</p>}
        <div className="model-config-toolbar">{after&&<button onClick={()=>setAfter('')}>返回账号首页</button>}{page.nextCursor&&<button onClick={()=>setAfter(page.nextCursor!)}>下一页账号</button>}</div>
      </>}
    </>}</div></dialog>;
}
function AdminInvitation(){
  const [administrator,setAdministrator]=useState(false),[busy,setBusy]=useState(false),[result,setResult]=useState<{code:string;expiresAt:number}>(),[error,setError]=useState(false);
  const create=async()=>{
    if(busy)return;setBusy(true);setError(false);setResult(undefined);
    try{
      const response=await fetch('/api/admin/invitations',{method:'POST',credentials:'same-origin',cache:'no-store',redirect:'error',headers:{'Content-Type':'application/json'},body:JSON.stringify({administrator}),signal:AbortSignal.timeout(10000)});
      if(response.status!==201)throw new Error('Invitation failed');
      const value=await response.json();if(value?.version!==1||typeof value.code!=='string'||!/^[A-Za-z0-9_-]{43}$/.test(value.code)||!Number.isSafeInteger(value.expiresAt))throw new Error('Invalid invitation');
      setResult({code:value.code,expiresAt:value.expiresAt});
    }catch{setError(true);}finally{setBusy(false);}
  };
  return <section className="admin-invitation"><p>邀请码只显示一次，有效期 7 天。请通过可信渠道发给受邀人；拥有邀请码的人可以自行创建账号。管理员邀请会授予管理权限。</p>
    <label><input type="checkbox" checked={administrator} onChange={event=>setAdministrator(event.target.checked)} disabled={busy}/> 邀请管理员</label>
    <button className="primary" onClick={()=>void create()} disabled={busy}>{busy?'正在创建…':'生成邀请码'}</button>
    {error&&<p role="alert">未能确认邀请码创建，请重新核对账号权限。</p>}
    {result&&<div><p>邀请码（仅此一次可见）</p><code>{result.code}</code><p>有效期至 {new Date(result.expiresAt).toLocaleString()}</p><button onClick={()=>void navigator.clipboard.writeText(result.code)}>复制邀请码</button></div>}
  </section>;
}
function AccountToggle({row,onSaved}:{row:Account;onSaved:(row:Account)=>void}){
  const [field,setField]=useState<'enabled'|'administrator'>('enabled');
  const [state,setState]=useState<'idle'|'confirm'|'saving'|'uncertain'>('idle');
  const [checking,setChecking]=useState(false);
  const context=useRef<{active:boolean;busy:boolean;controller:AbortController}|undefined>(undefined);
  useEffect(()=>{const value={active:true,busy:false,controller:new AbortController()};context.current=value;return()=>{value.active=false;value.controller.abort();};},[]);
  const verb=field==='enabled'?(row.enabled?'停用':'启用'):(row.administrator?'撤销管理权限':'授予管理权限');
  const next={enabled:row.enabled,administrator:row.administrator,[field]:!row[field]};
  return <div>{state==='idle'?<><button onClick={()=>{setField('enabled');setState('confirm');}}>{row.enabled?'停用':'启用'}账号 {row.accountId}</button><button onClick={()=>{setField('administrator');setState('confirm');}}>{row.administrator?'撤销管理权限':'授予管理权限'} {row.accountId}</button></>:state==='confirm'?<>
    {field==='administrator'&&<p>管理员可以查看和修改其他账号。此操作会改变该账号的管理权限；最后一名有效管理员受服务端保护。</p>}
    <p>确认{verb}账号“{row.accountId}”？</p><button onClick={()=>{
      const current=context.current;if(!current?.active||current.busy)return;
      current.busy=true;setState('saving');
      void requestConfiguration(`/api/admin/accounts/${encodeURIComponent(row.accountId)}`,current.controller.signal,{...next,expectedVersion:row.version}).then(value=>{
        const saved=decode({version:1,items:[value],nextCursor:null}).items[0];
        if(!saved||saved.accountId!==row.accountId||saved.enabled!==next.enabled||saved.administrator!==next.administrator||saved.version!==row.version+1)throw new Error('Invalid account receipt');
        if(current.active)onSaved(saved);
      }).catch(()=>{if(current.active)setState('uncertain');}).finally(()=>{current.busy=false;});
    }}>确认{verb}</button><button onClick={()=>setState('idle')}>取消修改</button>
  </>:<><p role="status">{state==='saving'?'正在保存账号…':'未能确认修改结果，可能发生版本冲突、权限变化或最后管理员保护。可核对当前状态，不要重复提交。'}</p>{state==='uncertain'&&<button disabled={checking} onClick={()=>{
    const current=context.current;if(!current?.active||current.busy)return;
    current.busy=true;setChecking(true);
    void requestConfiguration(`/api/admin/accounts/${encodeURIComponent(row.accountId)}`,current.controller.signal).then(value=>{
      const saved=decode({version:1,items:[value],nextCursor:null}).items[0];
      if(!saved||saved.accountId!==row.accountId||saved.version<=row.version||saved.enabled!==next.enabled||saved.administrator!==next.administrator)throw new Error('Current state does not match');
      if(current.active)onSaved(saved);
    }).catch(()=>{}).finally(()=>{current.busy=false;if(current.active)setChecking(false);});
  }}>{checking?'正在核对…':'核对账号修改结果'}</button>}</>}</div>;
}
