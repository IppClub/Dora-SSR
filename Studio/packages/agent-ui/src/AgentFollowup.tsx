import {isImeKeyEvent} from './InputEvents';
import React from 'react';
import {parseAgentMessageAttachments,replaceAgentMessageText} from './AgentMessageAttachments';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import IconButton from '@mui/material/IconButton';
import Tooltip from '@mui/material/Tooltip';
import {AgentColor as Color} from './agent-theme';
import {AGENT_COMPOSER_MAX_WIDTH,agentInputSurface,agentTextAreaStyle} from './AgentInputStyle';

export type AgentInputDelivery='queue'|'steer';
export interface AgentInputCommand {action:'cancel'|'edit'|'steer'|'resume'|'hold'|'release';inputId?:number}
export interface AgentPendingInput {id:number;content:string;delivery:AgentInputDelivery;held:boolean;status:string}
export interface AgentInputControls {
  pendingInputs?:AgentPendingInput[];
  canSteer?:boolean;
  onInputAction?:(command:AgentInputCommand,content?:string)=>Promise<void>|void;
}

/** The host owns the queue; only an unsubmitted edit is local state. */
export function AgentFollowupQueue({pendingInputs=[],canSteer=true,onInputAction,compact=false}:AgentInputControls&{compact?:boolean}){
  const [editing,setEditing]=React.useState<{id:number;text:string}|null>(null);
  const [busy,setBusy]=React.useState(false),[error,setError]=React.useState('');
  const perform=async(command:AgentInputCommand,content?:string)=>{
    if(!onInputAction||busy)return false;
    setBusy(true);setError('');
    try{await onInputAction(command,content);return true;}
    catch(reason){setError(reason instanceof Error?reason.message:'队列操作未完成，请重试');return false;}
    finally{setBusy(false);}
  };
  const finishEdit=async(save:boolean)=>{
    if(!editing)return;
    if(save&&!await perform({action:'edit',inputId:editing.id},replaceAgentMessageText(pendingInputs.find(item=>item.id===editing.id)?.content??'',editing.text)))return;
    if(!await perform({action:'release',inputId:editing.id}))return;
    setEditing(null);
  };
  React.useEffect(()=>{if(editing&&!pendingInputs.some(item=>item.id===editing.id))setEditing(null);},[pendingInputs,editing]);
  if(!pendingInputs.length&&!error)return null;
  return <Box aria-label="后续消息" sx={{width:'100%',maxWidth:AGENT_COMPOSER_MAX_WIDTH,mx:'auto',boxSizing:'border-box',pt:1,mb:1,maxHeight:280,overflowY:'auto',color:Color.TextPrimary}}>
    {pendingInputs.map((item,index)=><Box key={item.id} data-agent-input-id={item.id} sx={{borderLeft:`2px solid ${item.delivery==='steer'?Color.Theme:Color.Line}`,pl:1.25,py:.5,mb:.5,backgroundColor:Color.BackgroundDark,borderRadius:'0 6px 6px 0'}}>
      <Box sx={{display:'flex',alignItems:'center',gap:.5,pr:.5}}>
        <Box sx={{fontSize:10,color:item.delivery==='steer'?Color.Theme:Color.TextSecondary,minWidth:60}}>{item.delivery==='steer'?'等待引导…':`排队 ${pendingInputs.slice(0,index+1).filter(input=>input.delivery==='queue').length}`}</Box>
        {editing?.id!==item.id&&<Box sx={{fontSize:12,flex:1,overflow:'hidden',textOverflow:'ellipsis',whiteSpace:'nowrap'}} title={parseAgentMessageAttachments(item.content).text}>{parseAgentMessageAttachments(item.content).text||'附件消息'}</Box>}
        {item.status==='editing'&&!editing&&<Button size="small" disabled={busy||!onInputAction} onClick={()=>void perform({action:'release',inputId:item.id})}>解除编辑</Button>}
        {item.status==='pending'&&!editing&&<>
          {item.delivery==='queue'&&canSteer&&<Button size="small" disabled={busy||!onInputAction} onClick={()=>void perform({action:'steer',inputId:item.id})} sx={{fontSize:11,minWidth:0}}>引导</Button>}
          <Tooltip title="编辑消息"><IconButton size="small" aria-label="编辑消息" disabled={busy||!onInputAction} onClick={async()=>{if(await perform({action:'hold',inputId:item.id}))setEditing({id:item.id,text:parseAgentMessageAttachments(item.content).text});}} sx={{fontSize:13,color:Color.TextSecondary}}>✎</IconButton></Tooltip>
          <Tooltip title="删除消息"><IconButton size="small" aria-label="删除消息" disabled={busy||!onInputAction} onClick={()=>void perform({action:'cancel',inputId:item.id})} sx={{fontSize:15,color:Color.TextSecondary}}>×</IconButton></Tooltip>
        </>}
      </Box>
      {editing?.id===item.id&&<Box sx={{mr:1,mt:.5,...agentInputSurface(compact)}}><textarea autoFocus aria-label="编辑排队消息" value={editing.text} disabled={busy||!onInputAction} onChange={event=>setEditing({...editing,text:event.target.value})} maxLength={5000} rows={3} style={{...agentTextAreaStyle(compact),overflowY:'auto'}} onKeyDown={event=>{if(isImeKeyEvent(event.nativeEvent))return;if(event.key==='Escape'){event.preventDefault();void finishEdit(false);}if(event.key==='Enter'&&(event.metaKey||event.ctrlKey)){event.preventDefault();void finishEdit(true);}}}/><Box sx={{display:'flex',justifyContent:'flex-end',px:1,pb:.5}}><Button size="small" disabled={busy||!onInputAction} onClick={()=>void finishEdit(false)}>取消</Button><Button size="small" disabled={busy||!onInputAction||!editing.text.trim()} onClick={()=>void finishEdit(true)}>保存</Button></Box></Box>}
    </Box>)}
    {error&&<Box role="alert" sx={{fontSize:12,color:Color.Warning,py:.5}}>{error}</Box>}
  </Box>;
}
