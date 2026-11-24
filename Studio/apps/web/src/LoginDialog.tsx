import type {en as loginMessages} from './locales/login';
import {useStudioI18n} from './i18n';
import {preventImeSubmit} from '@dora-studio/agent-ui';
import {useEffect,useRef,useState} from 'react';
import './login.css';

type Mode='login'|'register';
export function LoginDialog({onClose,onAuthenticated}:{onClose:()=>void;onAuthenticated:(accountId:string)=>void}){
  const {t} = useStudioI18n();
  const dialog=useRef<HTMLDialogElement>(null);
  const [mode,setMode]=useState<Mode>('login'),[accountId,setAccountId]=useState(''),[password,setPassword]=useState(''),[code,setCode]=useState('');
  const [busy,setBusy]=useState(false),[error,setError]=useState<'' | `login.${keyof typeof loginMessages}`>('');
  const controller=useRef<AbortController|undefined>(undefined);
  useEffect(()=>{dialog.current?.showModal();return()=>{controller.current?.abort();dialog.current?.close();};},[]);
  const submit=async()=>{
    if(busy)return;
    setBusy(true);setError('');const current=new AbortController();controller.current=current;
    try{
      const body=mode==='login'?{accountId,password}:{code,accountId,password};
      const response=await fetch(mode==='login'?'/api/auth/login':'/api/auth/register',{method:'POST',credentials:'same-origin',cache:'no-store',redirect:'error',headers:{'Content-Type':'application/json'},body:JSON.stringify(body),signal:AbortSignal.any([current.signal,AbortSignal.timeout(15000)])});
      if(!response.ok){
        setError(response.status===401?'login.unauthorized':response.status===409?'login.conflict':response.status===400?'login.invalid':'login.unavailable');
        return;
      }
      const data=await response.json();
      if(data?.version!==1||data?.account?.accountId!==accountId||Object.keys(data).some(key=>!['version','account'].includes(key))){setError('login.unconfirmed');return;}
      setPassword('');setCode('');onAuthenticated(accountId);
    }catch{if(!current.signal.aborted)setError('login.unavailable');}
    finally{if(!current.signal.aborted)setBusy(false);}
  };
  return <dialog ref={dialog} className="login-dialog" aria-label={t('login.title')} onCancel={event=>{event.preventDefault();if(!busy)onClose();}}>
    <div className="login-heading"><span>{t('login.heading')}</span><button onClick={onClose} disabled={busy} aria-label={t('login.close')}>×</button></div>
    <h2>{mode==='login'?t('login.welcome'):t('login.join')}</h2><p>{t('login.description')}</p>
    <div className="login-modes"><button aria-pressed={mode==='login'} onClick={()=>{setMode('login');setError('');}}>{t('login.signIn')}</button><button aria-pressed={mode==='register'} onClick={()=>{setMode('register');setError('');}}>{t('login.register')}</button></div>
    <form onKeyDownCapture={preventImeSubmit} onSubmit={event=>{event.preventDefault();void submit();}}>
      {mode==='register'&&<label>{t('login.inviteCode')}<input value={code} onChange={event=>setCode(event.target.value.trim())} autoComplete="off" required maxLength={43} placeholder={t('login.invitePlaceholder')}/></label>}
      <label>{t('login.accountName')}<input value={accountId} onChange={event=>setAccountId(event.target.value.trim())} autoComplete="username" required minLength={3} maxLength={64} pattern="[a-zA-Z0-9][a-zA-Z0-9._\-]{2,63}" placeholder={t('login.accountPlaceholder')}/></label>
      <label>{t('login.password')}<input type="password" value={password} onChange={event=>setPassword(event.target.value)} autoComplete={mode==='register'?'new-password':'current-password'} required minLength={mode==='register'?12:1} maxLength={128} placeholder={mode==='register'?t('login.newPasswordPlaceholder'):t('login.passwordPlaceholder')}/></label>
      {error&&<p className="login-error" role="alert">{t(error)}</p>}
      <button className="primary" type="submit" disabled={busy}>{busy?t('login.verifying'):mode==='login'?t('login.submitSignIn'):t('login.submitRegister')}</button>
    </form>
  </dialog>;
}
