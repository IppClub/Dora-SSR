import {useEffect, useRef, useState} from 'react';

/** Owner must close the connection on unmount; changing UI cannot undo a stop. */
export function AgentPauseControl({persist,disabled}:{persist:()=>Promise<void>;disabled:boolean}) {
  const [state,setState]=useState<{owner:typeof persist;phase:'idle'|'pending'|'saved'|'failed'}>({owner:persist,phase:'idle'});
  const token=useRef(0),busy=useRef(false);
  useEffect(()=>{busy.current=false;return ()=>{token.current++;busy.current=false;};},[persist]);
  const phase=state.owner===persist?state.phase:'idle';
  const save=async()=>{
    if(disabled || busy.current || phase==='saved')return;
    busy.current=true;const request=++token.current;
    setState({owner:persist,phase:'pending'});
    try {await persist();if(token.current===request)setState({owner:persist,phase:'saved'});}
    catch {if(token.current===request)setState({owner:persist,phase:'failed'});}
    finally {if(token.current===request)busy.current=false;}
  };
  return <div className="agent-pause-control">
    <button onClick={save} disabled={disabled || phase==='pending' || phase==='saved'}>{phase==='pending'?'正在停止并保存…':phase==='saved'?'已保存到本机':phase==='failed'?'重试保存':'暂停并保存'}</button>
    <span role="status">{phase==='failed'?'未能确认保存完成，当前记录已保留。':phase==='saved'?'会话已在本机保存，尚未同步到云端。':phase==='pending'?'等待任务结束并写入浏览器存储。':''}</span>
  </div>;
}
