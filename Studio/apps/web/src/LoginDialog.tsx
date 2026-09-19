import {useEffect,useRef,useState} from 'react';
import './login.css';

type Mode='login'|'register';
export function LoginDialog({onClose,onAuthenticated}:{onClose:()=>void;onAuthenticated:(accountId:string)=>void}){
  const dialog=useRef<HTMLDialogElement>(null);
  const [mode,setMode]=useState<Mode>('login'),[accountId,setAccountId]=useState(''),[password,setPassword]=useState(''),[code,setCode]=useState('');
  const [busy,setBusy]=useState(false),[error,setError]=useState('');
  const controller=useRef<AbortController|undefined>(undefined);
  useEffect(()=>{dialog.current?.showModal();return()=>{controller.current?.abort();dialog.current?.close();};},[]);
  const submit=async()=>{
    if(busy)return;
    setBusy(true);setError('');const current=new AbortController();controller.current=current;
    try{
      const body=mode==='login'?{accountId,password}:{code,accountId,password};
      const response=await fetch(mode==='login'?'/api/auth/login':'/api/auth/register',{method:'POST',credentials:'same-origin',cache:'no-store',redirect:'error',headers:{'Content-Type':'application/json'},body:JSON.stringify(body),signal:AbortSignal.any([current.signal,AbortSignal.timeout(15000)])});
      if(!response.ok)throw new Error(response.status===401?'账号或密码不正确，或账号已停用。':response.status===409?'邀请码不可用，或账号名已被使用。':response.status===400?'请检查账号名、邀请码和密码格式。':'登录服务暂时不可用，请稍后重试。');
      const data=await response.json();
      if(data?.version!==1||data?.account?.accountId!==accountId||Object.keys(data).some(key=>!['version','account'].includes(key)))throw new Error('服务响应无法确认登录，请刷新账号核对。');
      setPassword('');setCode('');onAuthenticated(accountId);
    }catch(cause){if(!current.signal.aborted)setError(cause instanceof Error?cause.message:'登录服务暂时不可用，请稍后重试。');}
    finally{if(!current.signal.aborted)setBusy(false);}
  };
  return <dialog ref={dialog} className="login-dialog" aria-label="账号登录" onCancel={event=>{event.preventDefault();if(!busy)onClose();}}>
    <div className="login-heading"><span>DORA STUDIO · ACCOUNT</span><button onClick={onClose} disabled={busy} aria-label="关闭登录">×</button></div>
    <h2>{mode==='login'?'欢迎回来':'使用邀请码加入'}</h2><p>登录后同步项目、管理模型用量；本机草稿不会因切换账号而丢失。</p>
    <div className="login-modes"><button aria-pressed={mode==='login'} onClick={()=>{setMode('login');setError('');}}>登录</button><button aria-pressed={mode==='register'} onClick={()=>{setMode('register');setError('');}}>邀请码注册</button></div>
    <form onSubmit={event=>{event.preventDefault();void submit();}}>
      {mode==='register'&&<label>邀请码<input value={code} onChange={event=>setCode(event.target.value.trim())} autoComplete="off" required maxLength={43} placeholder="由管理员提供"/></label>}
      <label>账号名<input value={accountId} onChange={event=>setAccountId(event.target.value.trim())} autoComplete="username" required minLength={3} maxLength={64} pattern="[a-zA-Z0-9][a-zA-Z0-9._\-]{2,63}" placeholder="3–64 位英文字母、数字及 ._-"/></label>
      <label>密码<input type="password" value={password} onChange={event=>setPassword(event.target.value)} autoComplete={mode==='register'?'new-password':'current-password'} required minLength={mode==='register'?12:1} maxLength={128} placeholder={mode==='register'?'至少 12 个字符':'输入密码'}/></label>
      {error&&<p className="login-error" role="alert">{error}</p>}
      <button className="primary" type="submit" disabled={busy}>{busy?'正在验证…':mode==='login'?'登录账号':'创建账号并登录'}</button>
    </form>
  </dialog>;
}
