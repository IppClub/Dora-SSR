import {useStudioI18n} from './i18n';
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
  const {t} = useStudioI18n();
  const [allowed,setAllowed]=useState(false),[open,setOpen]=useState(false);
  useEffect(()=>{
    let active=true;const controller=new AbortController();
    void requestConfiguration('/api/admin/accounts?limit=1',controller.signal).then(value=>{decode(value);if(active)setAllowed(true);}).catch(()=>{if(active)setAllowed(false);});
    return()=>{active=false;controller.abort();};
  },[]);
  return <>{allowed&&<button onClick={()=>setOpen(true)}>{t('admin.accounts')}</button>}{open&&<AdminAccountsDialog accountId={accountId} onAccessChanged={()=>{setAllowed(false);setOpen(false);onAccessChanged();}} onClose={()=>setOpen(false)}/>}</>;
}
function AdminAccountsDialog({onClose,accountId,onAccessChanged}:{onClose:()=>void;accountId:string;onAccessChanged:()=>void}){
  const {t} = useStudioI18n();
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
  return <dialog ref={dialog} className="model-settings-dialog" aria-label={t('admin.accounts')} onCancel={event=>{event.preventDefault();onClose();}}><header><h2>{t('admin.accounts')}</h2><button autoFocus onClick={onClose}>{t('admin.closeAccounts')}</button></header>
    <div className="model-settings"><div className="model-config-toolbar"><button aria-pressed={!audit&&!invite} onClick={()=>{setAudit(false);setInvite(false);}}>{t('admin.accountList')}</button><button aria-pressed={invite} onClick={()=>{setInvite(true);setAudit(false);}}>{t('admin.inviteAccount')}</button><button aria-pressed={audit} onClick={()=>{setAudit(true);setInvite(false);}}>{t('admin.audit')}</button></div>{invite?<AdminInvitation/>:audit?<AdminAccountAudit/>:<><p>{t('admin.accountPolicy')}</p>
      <button onClick={()=>setRefresh(value=>value+1)}>{t('admin.refreshAccounts')}</button>
      {!page?<p role="status">{failed?t('admin.accountListFailed'):t('admin.loadingAccounts')}</p>:<>
        <ul className="admin-account-list">{page.items.map(row=><li key={`${row.accountId}:${row.version}`}><strong>{row.accountId}</strong><span>{row.administrator?t('admin.administrator'):t('admin.creator')} · {row.enabled?t('admin.enabled'):t('admin.disabled')} · v{row.version}</span><AccountToggle row={row} onSaved={saved=>{
          if(saved.accountId===accountId&&(!saved.enabled||!saved.administrator)){onAccessChanged();return;}
          setPage(current=>current?{...current,items:current.items.map(item=>item.accountId===saved.accountId?saved:item)}:current);
        }}/></li>)}</ul>
        {!page.items.length&&<p>{t('admin.noAccounts')}</p>}
        <div className="model-config-toolbar">{after&&<button onClick={()=>setAfter('')}>{t('admin.firstAccounts')}</button>}{page.nextCursor&&<button onClick={()=>setAfter(page.nextCursor!)}>{t('admin.nextAccounts')}</button>}</div>
      </>}
    </>}</div></dialog>;
}
type Invitation={invitationId:string;label:string;administrator:boolean;expiresAt:number;maxUses:number;useCount:number;revokedAt:number|null;createdBy:string;createdAt:number};
type Registration={accountId:string;registeredAt:number};
function decodeInvitation(value:unknown):Invitation{
  const row=value as Invitation;
  if(!row||typeof row.invitationId!=='string'||!/^[a-f0-9]{64}$/.test(row.invitationId)||typeof row.label!=='string'||row.label.length>100||typeof row.administrator!=='boolean'||!Number.isSafeInteger(row.expiresAt)||!Number.isSafeInteger(row.maxUses)||row.maxUses<1||row.maxUses>1000||!Number.isSafeInteger(row.useCount)||row.useCount<0||row.useCount>row.maxUses||row.revokedAt!==null&&!Number.isSafeInteger(row.revokedAt)||typeof row.createdBy!=='string'||!Number.isSafeInteger(row.createdAt))throw new Error('Invalid invitation');
  return {...row};
}
async function loadInvitations(signal:AbortSignal){
  const items:Invitation[]=[];let after='';
  for(let page=0;page<10;page++){
    const value=await requestConfiguration(`/api/admin/invitations?limit=100&after=${encodeURIComponent(after)}`,signal);
    if(value?.version!==1||!Array.isArray(value.items)||value.items.length>100||value.nextCursor!==null&&typeof value.nextCursor!=='string')throw new Error('Invalid invitation page');
    items.push(...value.items.map(decodeInvitation));
    if(value.nextCursor===null)return items;
    if(!/^[a-f0-9]{64}$/.test(value.nextCursor)||value.nextCursor===after)throw new Error('Invalid invitation cursor');after=value.nextCursor;
  }
  throw new Error('Too many invitations');
}
async function loadInvitationRegistrations(id:string,signal:AbortSignal){
  const items:Registration[]=[];let after='';
  for(let page=0;page<10;page++){
    const value=await requestConfiguration(`/api/admin/invitations/${id}/registrations?limit=100&after=${encodeURIComponent(after)}`,signal);
    if(value?.version!==1||!Array.isArray(value.items)||value.items.length>100||value.nextCursor!==null&&typeof value.nextCursor!=='string')throw new Error('Invalid registrations');
    for(const row of value.items as Registration[]){if(!row||typeof row.accountId!=='string'||!Number.isSafeInteger(row.registeredAt))throw new Error('Invalid registration');items.push(row);}
    if(value.nextCursor===null)return items;
    if(!value.nextCursor||value.nextCursor===after)throw new Error('Invalid registration cursor');after=value.nextCursor;
  }
  throw new Error('Too many registrations');
}
function AdminInvitation(){
  const {t, date} = useStudioI18n();
  const [administrator,setAdministrator]=useState(false),[maxUses,setMaxUses]=useState(10),[validDays,setValidDays]=useState(7),[label,setLabel]=useState('');
  const [busy,setBusy]=useState(false),[result,setResult]=useState<{code:string;expiresAt:number;maxUses:number}>(),[error,setError]=useState(false),[refresh,setRefresh]=useState(0);
  const create=async()=>{
    if(busy)return;setBusy(true);setError(false);setResult(undefined);
    try{
      const response=await fetch('/api/admin/invitations',{method:'POST',credentials:'same-origin',cache:'no-store',redirect:'error',headers:{'Content-Type':'application/json'},body:JSON.stringify({administrator,maxUses:administrator?1:maxUses,validDays,label:label.trim()}),signal:AbortSignal.timeout(10000)});
      if(response.status!==201)throw new Error('Invitation failed');
      const value=await response.json();if(value?.version!==1||typeof value.code!=='string'||!/^[A-Za-z0-9_-]{43}$/.test(value.code)||!Number.isSafeInteger(value.expiresAt)||!Number.isSafeInteger(value.maxUses))throw new Error('Invalid invitation');
      setResult({code:value.code,expiresAt:value.expiresAt,maxUses:value.maxUses});setRefresh(value=>value+1);
    }catch{setError(true);}finally{setBusy(false);}
  };
  return <section className="admin-invitation"><p>{t('admin.invitePolicy')}</p>
    <label className="model-config-select">{t('admin.inviteLabel')}<input value={label} maxLength={100} disabled={busy} onChange={event=>setLabel(event.target.value)} placeholder={t('admin.inviteExample')}/></label>
    <label><input type="checkbox" checked={administrator} onChange={event=>setAdministrator(event.target.checked)} disabled={busy}/> {t('admin.inviteAdministrator')}</label>
    <label className="model-config-select">{t('admin.maxRegistrations')}<input type="number" min={1} max={1000} value={administrator?1:maxUses} disabled={busy||administrator} onChange={event=>setMaxUses(Number(event.target.value))}/></label>
    <label className="model-config-select">{t('admin.validDays')}<input type="number" min={1} max={30} value={validDays} disabled={busy} onChange={event=>setValidDays(Number(event.target.value))}/></label>
    <button className="primary" onClick={()=>void create()} disabled={busy||(!administrator&&(maxUses<1||maxUses>1000))||validDays<1||validDays>30}>{busy?t('admin.creating'):t('admin.createInvite')}</button>
    {error&&<p role="alert">{t('admin.createInviteFailed')}</p>}
    {result&&<div><p>{t('admin.inviteCodeLimit', {count: result.maxUses})}</p><code>{result.code}</code><p>{t('admin.expiresOn', {date: date(result.expiresAt, true)})}</p><button onClick={()=>void navigator.clipboard.writeText(result.code)}>{t('admin.copyInvite')}</button></div>}
    <InvitationList refresh={refresh}/>
  </section>;
}
function InvitationList({refresh}:{refresh:number}){
  const {t} = useStudioI18n();
  const [items,setItems]=useState<Invitation[]>(),[failed,setFailed]=useState(false);
  useEffect(()=>{let active=true;const controller=new AbortController();setFailed(false);void loadInvitations(controller.signal).then(value=>{if(active)setItems(value);}).catch(()=>{if(active)setFailed(true);});return()=>{active=false;controller.abort();};},[refresh]);
  if(!items)return <p role="status">{failed?t('admin.invitesFailed'):t('admin.loadingInvites')}</p>;
  return <div><h3>{t('admin.issuedInvites')}</h3>{!items.length?<p>{t('admin.noInvites')}</p>:<ul className="admin-account-list">{items.map(item=><InvitationRow key={`${item.invitationId}:${item.maxUses}:${item.useCount}:${item.revokedAt??0}`} item={item} onSaved={saved=>setItems(current=>current?.map(row=>row.invitationId===saved.invitationId?saved:row))}/>)}</ul>}</div>;
}
function InvitationRow({item,onSaved}:{item:Invitation;onSaved:(item:Invitation)=>void}){
  const {t, date} = useStudioI18n();
  const [limit,setLimit]=useState(item.maxUses),[busy,setBusy]=useState(false),[registrations,setRegistrations]=useState<Registration[]>(),[error,setError]=useState(false);
  const expired=item.expiresAt<=Date.now(),state=item.revokedAt!==null?t('admin.revoked'):expired?t('admin.expired'):item.useCount>=item.maxUses?t('admin.full'):t('admin.available');
  const save=async(revoke:boolean)=>{if(busy)return;setBusy(true);setError(false);const controller=new AbortController();try{const value=await requestConfiguration(`/api/admin/invitations/${item.invitationId}`,controller.signal,{maxUses:limit,revoke});onSaved(decodeInvitation(value));}catch{setError(true);}finally{setBusy(false);}};
  const loadRegistrations=async()=>{if(busy)return;setBusy(true);setError(false);const controller=new AbortController();try{setRegistrations(await loadInvitationRegistrations(item.invitationId,controller.signal));}catch{setError(true);}finally{setBusy(false);}};
  return <li><strong>{item.label||t('admin.unnamedInvite')}</strong><span>{t('admin.inviteUsage', {role: t(item.administrator?'admin.administrator':'admin.creator'), used: item.useCount, limit: item.maxUses, status: state})}</span><span>{t('admin.inviteMetadata', {actor: item.createdBy, date: date(item.expiresAt, true)})}</span>
    {!item.administrator&&item.revokedAt===null&&<label>{t('admin.registrationLimit')}<input type="number" min={item.useCount||1} max={1000} value={limit} disabled={busy} onChange={event=>setLimit(Number(event.target.value))}/></label>}
    <div className="model-config-toolbar"><button disabled={busy} onClick={()=>void loadRegistrations()}>{busy?t('admin.processing'):t('admin.viewRegistrations')}</button>{!item.administrator&&item.revokedAt===null&&<button disabled={busy||limit<item.useCount||limit<1||limit>1000||limit===item.maxUses} onClick={()=>void save(false)}>{t('admin.saveRegistrationLimit')}</button>}{item.revokedAt===null&&<button disabled={busy} onClick={()=>void save(true)}>{t('admin.revokeInvite')}</button>}</div>
    {registrations&&<p>{registrations.length?registrations.map(row=>t('admin.registration', {account: row.accountId, date: date(row.registeredAt, true)})).join(', '):t('admin.noRegistrations')}</p>}{error&&<p role="alert">{t('admin.inviteActionUnconfirmed')}</p>}
  </li>;
}
function AccountToggle({row,onSaved}:{row:Account;onSaved:(row:Account)=>void}){
  const {t} = useStudioI18n();
  const [field,setField]=useState<'enabled'|'administrator'>('enabled');
  const [state,setState]=useState<'idle'|'confirm'|'saving'|'uncertain'>('idle');
  const [checking,setChecking]=useState(false);
  const context=useRef<{active:boolean;busy:boolean;controller:AbortController}|undefined>(undefined);
  useEffect(()=>{const value={active:true,busy:false,controller:new AbortController()};context.current=value;return()=>{value.active=false;value.controller.abort();};},[]);
  const toggleEnabled=t(row.enabled?'admin.disableAccount':'admin.enableAccount', {account: row.accountId});
  const toggleAdmin=t(row.administrator?'admin.removeAdminAccount':'admin.grantAdminAccount', {account: row.accountId});
  const action=field==='enabled'?toggleEnabled:toggleAdmin;
  const next={enabled:row.enabled,administrator:row.administrator,[field]:!row[field]};
  return <div>{state==='idle'?<><button onClick={()=>{setField('enabled');setState('confirm');}}>{toggleEnabled}</button><button onClick={()=>{setField('administrator');setState('confirm');}}>{toggleAdmin}</button></>:state==='confirm'?<>
    {field==='administrator'&&<p>{t('admin.administratorPolicy')}</p>}
    <p>{t('admin.confirmAccountChange', {action})}</p><button onClick={()=>{
      const current=context.current;if(!current?.active||current.busy)return;
      current.busy=true;setState('saving');
      void requestConfiguration(`/api/admin/accounts/${encodeURIComponent(row.accountId)}`,current.controller.signal,{...next,expectedVersion:row.version}).then(value=>{
        const saved=decode({version:1,items:[value],nextCursor:null}).items[0];
        if(!saved||saved.accountId!==row.accountId||saved.enabled!==next.enabled||saved.administrator!==next.administrator||saved.version!==row.version+1)throw new Error('Invalid account receipt');
        if(current.active)onSaved(saved);
      }).catch(()=>{if(current.active)setState('uncertain');}).finally(()=>{current.busy=false;});
    }}>{t('admin.confirm')}</button><button onClick={()=>setState('idle')}>{t('admin.cancelAccountChange')}</button>
  </>:<><p role="status">{state==='saving'?t('admin.savingAccount'):t('admin.accountChangeUnconfirmed')}</p>{state==='uncertain'&&<button disabled={checking} onClick={()=>{
    const current=context.current;if(!current?.active||current.busy)return;
    current.busy=true;setChecking(true);
    void requestConfiguration(`/api/admin/accounts/${encodeURIComponent(row.accountId)}`,current.controller.signal).then(value=>{
      const saved=decode({version:1,items:[value],nextCursor:null}).items[0];
      if(!saved||saved.accountId!==row.accountId||saved.version<=row.version||saved.enabled!==next.enabled||saved.administrator!==next.administrator)throw new Error('Current state does not match');
      if(current.active)onSaved(saved);
    }).catch(()=>{}).finally(()=>{current.busy=false;if(current.active)setChecking(false);});
  }}>{checking?t('admin.verifyingAccount'):t('admin.verifyAccountChange')}</button>}</>}</div>;
}
