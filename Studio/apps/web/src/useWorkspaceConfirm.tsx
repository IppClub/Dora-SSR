import {useEffect,useRef,useState} from 'react';
import './workspace-confirm.css';

type Confirmation={title:string;description:string;confirmLabel:string;cancelLabel?:string};

/** Keep one modal decision outstanding; closing the page resolves it as cancel. */
export function useWorkspaceConfirm(){
 const [request,setRequest]=useState<Confirmation|null>(null);
 const pending=useRef<((accepted:boolean)=>void)|null>(null);
 const dialog=useRef<HTMLDialogElement>(null);
 const ask=(value:Confirmation):Promise<boolean>=>{
  if(pending.current)return Promise.resolve(false);
  return new Promise(resolve=>{pending.current=resolve;setRequest(value);});
 };
 const answer=(accepted:boolean)=>{
  const resolve=pending.current;
  if(!resolve)return;
  pending.current=null;
  setRequest(null);
  resolve(accepted);
 };
 useEffect(()=>{
  if(!request)return;
  const element=dialog.current;
  if(element&&!element.open)element.showModal();
  return()=>{if(element?.open)element.close();};
 },[request]);
 useEffect(()=>()=>{const resolve=pending.current;pending.current=null;resolve?.(false);},[]);
 const node=request&&<dialog ref={dialog} className="workspace-confirm" aria-labelledby="workspace-confirm-title"
   onCancel={event=>{event.preventDefault();answer(false);}}
   onClose={()=>answer(false)}>
  <h2 id="workspace-confirm-title">{request.title}</h2>
  <p>{request.description}</p>
  <div className="workspace-confirm-actions"><button onClick={()=>answer(false)}>{request.cancelLabel??'取消'}</button><button className="primary" onClick={()=>answer(true)}>{request.confirmLabel}</button></div>
 </dialog>;
 return {ask,node};
}
