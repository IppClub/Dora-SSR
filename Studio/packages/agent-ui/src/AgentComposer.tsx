import React from 'react';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import CircularProgress from '@mui/material/CircularProgress';
import IconButton from '@mui/material/IconButton';
import MenuItem from '@mui/material/MenuItem';
import Select from '@mui/material/Select';
import Stack from '@mui/material/Stack';
import Tooltip from '@mui/material/Tooltip';
import {ThemeProvider} from '@mui/material/styles';
import ChecklistIcon from '@mui/icons-material/Checklist';
import DownloadIcon from '@mui/icons-material/Download';
import TerminalIcon from '@mui/icons-material/Terminal';
import {BsFillSendFill,BsStopFill} from 'react-icons/bs';
import {AgentColor as Color,agentTheme} from './agent-theme';

const CONTEXT_USAGE_LOW_COLOR='rgba(255,255,255,0.42)';

export type AgentModelChoice={id:string|number;name:string};
export type AgentActualUsage={inputTokens:number;outputTokens:number;cachedInputTokens?:number;requestCount?:number};
export type AgentComposerLabels={
  promptPlaceholder:string;planPromptPlaceholder:string;send:string;stop:string;stopping:string;
  planMode:string;planModeInactive:string;planModeToggle:string;networkAccess:string;networkToolsToggle:string;
  executeCommand:string;executeCommandToggle:string;selectModel:string;modelForNextRun:string;
  contextUsage:(used:string,max:string,percent:number)=>string;actualUsage:(usage:AgentActualUsage)=>string;
};

const defaultLabels:AgentComposerLabels={
  promptPlaceholder:'继续描述你希望修改的玩法…',planPromptPlaceholder:'描述目标，让 Agent 先制定计划…',send:'发送',stop:'停止',stopping:'正在停止',
  planMode:'计划',planModeInactive:'计划',planModeToggle:'切换计划模式',networkAccess:'网络',networkToolsToggle:'切换网络访问',executeCommand:'命令',executeCommandToggle:'切换命令执行',
  selectModel:'选择模型',modelForNextRun:'下一轮使用的模型',contextUsage:(used,max,percent)=>`上下文估算：${used} / ${max}（${percent}%）`,
  actualUsage:usage=>`实际用量：输入 ${formatCompactNumber(usage.inputTokens)}，输出 ${formatCompactNumber(usage.outputTokens)}${usage.cachedInputTokens===undefined?'':`，缓存 ${formatCompactNumber(usage.cachedInputTokens)}`}`,
};

export interface SharedAgentComposerProps{
  compact?:boolean;prompt:string;loading:boolean;running:boolean;stopping?:boolean;canStop?:boolean;disabled?:boolean;status?:string;
  contextRatio?:number;usedTokens?:number;maxTokens?:number;actualUsage?:AgentActualUsage;
  fetchUrlEnabled?:boolean;executeCommandEnabled?:boolean;planMode?:boolean;models?:AgentModelChoice[];modelId?:string|number;
  labels?:Partial<AgentComposerLabels>;ariaLabel?:string;maxLength?:number;
  onPromptChange:(value:string)=>void;onSend:()=>void;onStop?:()=>void;
  onFetchUrlEnabledChange?:(value:boolean)=>void;onExecuteCommandEnabledChange?:(value:boolean)=>void;
  onPlanModeChange?:(value:boolean)=>void;onModelChange?:(value:string|number)=>void;
}

function formatCompactNumber(value:number){
  if(!Number.isFinite(value))return'0';
  if(value>=1_000_000)return`${(value/1_000_000).toFixed(1)}m`;
  if(value>=1_000)return`${(value/1_000).toFixed(1)}k`;
  return String(Math.max(0,Math.round(value)));
}

function ContextUsageRing({compact=false,contextRatio,usedTokens=0,maxTokens=64000,actualUsage,labels}:Pick<SharedAgentComposerProps,'compact'|'contextRatio'|'usedTokens'|'maxTokens'|'actualUsage'|'labels'>){
  const copy={...defaultLabels,...labels};
  const ratio=Math.max(0,Math.min(1,contextRatio??(maxTokens>0?usedTokens/maxTokens:0)));
  const percent=Math.round(ratio*100),hasUsage=usedTokens>0||contextRatio!==undefined;
  const color=hasUsage?Color.Theme+'cc':CONTEXT_USAGE_LOW_COLOR;
  const trackColor=hasUsage?'rgba(255,255,255,0.12)':'rgba(255,255,255,0.08)';
  const contextTitle=copy.contextUsage(formatCompactNumber(usedTokens),formatCompactNumber(maxTokens),percent);
  const actualTitle=actualUsage?copy.actualUsage(actualUsage):'';
  const title=actualTitle?`${contextTitle}\n${actualTitle}`:contextTitle;
  const outerSize=compact?26:28,innerSize=compact?20:22;
  return <Tooltip title={<span style={{whiteSpace:'pre-line'}}>{title}</span>}><Box aria-label={title} sx={{width:outerSize,height:outerSize,borderRadius:'50%',background:`conic-gradient(${color} ${percent*3.6}deg, ${trackColor} 0deg)`,display:'grid',placeItems:'center',cursor:'default'}}><Box sx={{width:innerSize,height:innerSize,borderRadius:'50%',backgroundColor:Color.BackgroundDark,display:'grid',placeItems:'center',border:`1px solid ${Color.Line}`,color,fontSize:8,fontWeight:700,lineHeight:1,userSelect:'none'}}>{percent}%</Box></Box></Tooltip>;
}

export function AgentContextUsage(props:Pick<SharedAgentComposerProps,'compact'|'contextRatio'|'usedTokens'|'maxTokens'|'actualUsage'|'labels'>){
  return <ThemeProvider theme={agentTheme}><ContextUsageRing {...props}/></ThemeProvider>;
}

function ComposerContent(props:SharedAgentComposerProps){
  const copy={...defaultLabels,...props.labels};
  const compact=props.compact??false,prompt=props.prompt,loading=props.loading||props.disabled===true,running=props.running;
  const stopping=props.stopping??false,canStop=props.canStop??true,maxLength=props.maxLength??12000;
  const fetchUrlEnabled=props.fetchUrlEnabled??false,executeCommandEnabled=props.executeCommandEnabled??false,planMode=props.planMode??false;
  const models=props.models??[],selectedModel=models.find(item=>String(item.id)===String(props.modelId));
  const disabledInput=loading||running,actionDisabled=running?!canStop:loading||prompt.trim()==='',toolToggleDisabled=loading||running;
  const textAreaRef=React.useRef<HTMLTextAreaElement|null>(null),isComposingRef=React.useRef(false);
  const [modelMenuOpen,setModelMenuOpen]=React.useState(false),[modelTooltipOpen,setModelTooltipOpen]=React.useState(false),[inputFocused,setInputFocused]=React.useState(false);
  React.useLayoutEffect(()=>{const textarea=textAreaRef.current;if(!textarea)return;textarea.style.height='0px';const maxHeight=compact?160:220;textarea.style.height=`${Math.max(compact?44:64,Math.min(textarea.scrollHeight,maxHeight))}px`;textarea.style.overflowY=textarea.scrollHeight>maxHeight?'auto':'hidden';},[compact,prompt]);
  const toolButtonSx=(enabled:boolean)=>({height:compact?28:30,minWidth:0,px:1,borderRadius:1.5,backgroundColor:enabled?Color.ThemeMuted:'transparent',color:enabled?Color.Theme:Color.TextSecondary,'&:hover':{backgroundColor:enabled?`${Color.Theme}2a`:Color.SurfaceHover},'&.Mui-disabled':{backgroundColor:enabled?Color.ThemeMuted:'transparent',color:enabled?`${Color.Theme}aa`:'rgba(255,255,255,0.3)',opacity:1}});
  const submit=()=>{if(actionDisabled)return;if(running)props.onStop?.();else props.onSend();};
  return <Box data-agent-composer-compact={compact?'true':'false'} sx={{px:compact?1.25:2,pt:compact?0.5:1,pb:compact?0.75:2,backgroundColor:Color.Background,flexShrink:0}}>
    <Box sx={{width:'100%',maxWidth:980,mx:'auto',border:`1px solid ${inputFocused?`${Color.Theme}88`:Color.Line}`,borderRadius:compact?2:3,backgroundColor:Color.BackgroundDark,overflow:'hidden',transition:'border-color 140ms ease'}}>
      <textarea ref={textAreaRef} aria-label={props.ariaLabel??'Agent 描述'} value={prompt} maxLength={maxLength} disabled={disabledInput} onFocus={()=>setInputFocused(true)} onBlur={()=>setInputFocused(false)} onChange={event=>props.onPromptChange(event.target.value.slice(0,maxLength))} onCompositionStart={()=>{isComposingRef.current=true;}} onCompositionEnd={event=>{isComposingRef.current=false;props.onPromptChange(event.currentTarget.value);}} onKeyDown={event=>{if(isComposingRef.current||event.nativeEvent.isComposing)return;if(event.key==='Enter'&&!event.shiftKey){event.preventDefault();submit();}}} placeholder={planMode?copy.planPromptPlaceholder:copy.promptPlaceholder} style={{display:'block',width:'100%',minHeight:compact?44:64,maxHeight:compact?160:220,padding:compact?'8px 10px 4px':'14px 16px 8px',border:'none',outline:'none',resize:'none',overflow:'hidden',backgroundColor:'transparent',color:Color.TextPrimary,font:'inherit',lineHeight:'1.65',boxSizing:'border-box'}}/>
      <Stack direction="row" spacing={1} alignItems="center" justifyContent="space-between" sx={{px:compact?0.75:1,pb:compact?0.5:1,minHeight:compact?32:38,flexWrap:'wrap',rowGap:compact?0.25:0.75}}>
        <Stack direction="row" spacing={0.25} alignItems="center" sx={{minWidth:0,flexShrink:0,flexWrap:'wrap',rowGap:0.25,'& .MuiButton-root':{whiteSpace:'nowrap'}}}>
          {props.onPlanModeChange?<Tooltip title={copy.planModeToggle}><span><Button size="small" startIcon={<ChecklistIcon sx={{fontSize:'16px !important'}}/>} onClick={()=>props.onPlanModeChange?.(!planMode)} disabled={toolToggleDisabled} aria-pressed={planMode} sx={toolButtonSx(planMode)}>{planMode?copy.planMode:copy.planModeInactive}</Button></span></Tooltip>:null}
          {props.onFetchUrlEnabledChange&&!planMode?<Tooltip title={copy.networkToolsToggle}><span><Button size="small" startIcon={<DownloadIcon sx={{fontSize:'16px !important'}}/>} onClick={()=>props.onFetchUrlEnabledChange?.(!fetchUrlEnabled)} disabled={toolToggleDisabled} aria-pressed={fetchUrlEnabled} sx={toolButtonSx(fetchUrlEnabled)}>{copy.networkAccess}</Button></span></Tooltip>:null}
          {props.onExecuteCommandEnabledChange&&!planMode?<Tooltip title={copy.executeCommandToggle}><span><Button size="small" startIcon={<TerminalIcon sx={{fontSize:'16px !important'}}/>} onClick={()=>props.onExecuteCommandEnabledChange?.(!executeCommandEnabled)} disabled={toolToggleDisabled} aria-pressed={executeCommandEnabled} sx={toolButtonSx(executeCommandEnabled)}>{copy.executeCommand}</Button></span></Tooltip>:null}
        </Stack>
        <Stack direction="row" spacing={1} alignItems="center" sx={{flexShrink:0}}>
          {props.status?<Box component="span" sx={{maxWidth:220,overflow:'hidden',textOverflow:'ellipsis',whiteSpace:'nowrap',color:'#888',fontSize:10}}>{props.status}</Box>:null}
          <ContextUsageRing compact={compact} {...(props.contextRatio===undefined?{}:{contextRatio:props.contextRatio})} {...(props.usedTokens===undefined?{}:{usedTokens:props.usedTokens})} {...(props.maxTokens===undefined?{}:{maxTokens:props.maxTokens})} {...(props.actualUsage===undefined?{}:{actualUsage:props.actualUsage})} {...(props.labels===undefined?{}:{labels:props.labels})}/>
          <Tooltip title={copy.modelForNextRun} disableFocusListener open={modelTooltipOpen&&!modelMenuOpen} onOpen={()=>{if(!modelMenuOpen)setModelTooltipOpen(true);}} onClose={()=>setModelTooltipOpen(false)}><Select value={selectedModel?String(selectedModel.id):''} displayEmpty disabled={!models.length||!props.onModelChange} onOpen={()=>{setModelTooltipOpen(false);setModelMenuOpen(true);}} onClose={()=>setModelMenuOpen(false)} onChange={event=>{const item=models.find(model=>String(model.id)===String(event.target.value));if(item)props.onModelChange?.(item.id);}} renderValue={()=>selectedModel?.name??copy.selectModel} variant="standard" disableUnderline size="small" MenuProps={{PaperProps:{sx:{minWidth:120,borderRadius:'6px',backgroundColor:Color.Background,backgroundImage:'none',border:`1px solid ${Color.Line}`}}}} inputProps={{'aria-label':copy.modelForNextRun}} sx={{maxWidth:compact?140:180,minWidth:compact?76:96,fontSize:12,color:Color.TextSecondary,'& .MuiSelect-select':{py:0.25,pr:'22px !important'},'& .MuiSelect-icon':{color:Color.TextSecondary}}}>{models.map(item=><MenuItem key={String(item.id)} value={String(item.id)}>{item.name}</MenuItem>)}</Select></Tooltip>
          <Tooltip title={stopping?copy.stopping:running?copy.stop:copy.send}><span><IconButton aria-label={stopping?copy.stopping:running?copy.stop:copy.send} onClick={submit} disabled={actionDisabled} sx={{width:compact?30:32,height:compact?30:32,borderRadius:1.75,backgroundColor:running?`${Color.Warning}20`:Color.Theme,color:running?Color.Warning:Color.BackgroundDark,'&:hover':{backgroundColor:running?`${Color.Warning}32`:'#ffd15f'},'&.Mui-disabled':{backgroundColor:stopping?`${Color.Theme}14`:Color.DisabledBackground,color:stopping?Color.Theme:Color.DisabledText}}}>{stopping?<CircularProgress color="inherit" size={18} thickness={5}/>:running?<BsStopFill size={18}/>:<BsFillSendFill size={16}/>}</IconButton></span></Tooltip>
        </Stack>
      </Stack>
    </Box>
  </Box>;
}

export function SharedAgentComposer(props:SharedAgentComposerProps){
  return <ThemeProvider theme={agentTheme}><ComposerContent {...props}/></ThemeProvider>;
}
