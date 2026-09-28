/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import React from 'react';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import CircularProgress from '@mui/material/CircularProgress';
import Tooltip from '@mui/material/Tooltip';
import AddCommentOutlinedIcon from '@mui/icons-material/AddCommentOutlined';
import {useTranslation} from 'react-i18next';
import {SharedAgentComposer,type AgentActualUsage} from '@dora-studio/agent-ui';
import {Color} from './Theme';
import '@dora-studio/agent-ui/style.css';

interface AgentComposerProps {
	compact?:boolean;prompt:string;loading:boolean;running:boolean;stopping?:boolean;canStop?:boolean;
	contextRatio?:number;usedTokens?:number;maxTokens?:number;actualUsage?:AgentActualUsage;
	hideContextUsage?:boolean;
	fetchUrlEnabled?:boolean;executeCommandEnabled?:boolean;planMode?:boolean;
	llmConfigs?:Array<{id:string|number;name:string}>;llmConfigId?:string|number;
	status?:string;newSessionLabel?:string;newSessionLoading?:boolean;newSessionDisabled?:boolean;
	onPromptChange:(value:string)=>void;onSend:()=>void;onStop:()=>void;
	onNewSession?:()=>void;
	onFetchUrlEnabledChange?:(value:boolean)=>void;onExecuteCommandEnabledChange?:(value:boolean)=>void;
	onPlanModeChange?:(value:boolean)=>void;onLLMConfigChange?:(value:string|number)=>void;
}

function compactNumber(value:number){if(value>=1_000_000)return`${(value/1_000_000).toFixed(1)}m`;if(value>=1_000)return`${(value/1_000).toFixed(1)}k`;return String(Math.max(0,Math.round(value)));}

const hiddenContextUsageLabel="dora-hidden-context-usage";

/** The Web IDE and Studio share the original MUI composer; this wrapper only adapts i18n and numeric model IDs. */
export default function AgentComposer(props:AgentComposerProps){
	const {t}=useTranslation();
	const compact=props.compact??false;
	const hideContextUsage=props.hideContextUsage===true;
	return <Box sx={{position:'relative',...(hideContextUsage?{[`& [aria-label="${hiddenContextUsageLabel}"]`]:{display:'none'}}:{})}}><SharedAgentComposer
		compact={props.compact??false} prompt={props.prompt} loading={props.loading} running={props.running}
		stopping={props.stopping??false} canStop={props.canStop??true}
		{...(props.status?{status:props.status}:{})}
		{...(!hideContextUsage?{contextRatio:props.contextRatio??0,usedTokens:props.usedTokens??0,maxTokens:props.maxTokens??64000}:{})}
		{...(!hideContextUsage&&props.actualUsage?{actualUsage:props.actualUsage}:{})}
		fetchUrlEnabled={props.fetchUrlEnabled??false} executeCommandEnabled={props.executeCommandEnabled??false} planMode={props.planMode??false}
		models={props.llmConfigs??[]} {...(props.llmConfigId===undefined?{}:{modelId:props.llmConfigId})}
		labels={{
			promptPlaceholder:t('agent.promptPlaceholder'),planPromptPlaceholder:t('agent.planPromptPlaceholder'),send:t('agent.send'),stop:t('menu.stop'),stopping:t('agent.stopping'),
			planMode:t('agent.planMode'),planModeInactive:t('agent.planModeInactive'),planModeToggle:t('agent.planModeToggle'),networkAccess:t('agent.networkAccess'),networkToolsToggle:t('agent.networkToolsToggle'),executeCommand:t('agent.executeCommand'),executeCommandToggle:t('agent.executeCommandToggle'),
			selectModel:t('agent.selectModel'),modelForNextRun:t('agent.modelForNextRun'),contextUsage:(used,max,percent)=>hideContextUsage?hiddenContextUsageLabel:t('agent.contextEstimateTitle',{used,max,percent}),
			actualUsage:usage=>t(usage.cachedInputTokens===undefined?'agent.actualUsageTitle':'agent.actualUsageWithCacheTitle',{input:compactNumber(usage.inputTokens),output:compactNumber(usage.outputTokens),cached:compactNumber(usage.cachedInputTokens??0),cachePercent:usage.inputTokens>0?Math.round(((usage.cachedInputTokens??0)/usage.inputTokens)*100):0,requests:compactNumber(usage.requestCount??0)}),
		}}
		onPromptChange={props.onPromptChange} onSend={props.onSend} onStop={props.onStop}
		{...(props.onFetchUrlEnabledChange?{onFetchUrlEnabledChange:props.onFetchUrlEnabledChange}:{})}
		{...(props.onExecuteCommandEnabledChange?{onExecuteCommandEnabledChange:props.onExecuteCommandEnabledChange}:{})}
		{...(props.onPlanModeChange?{onPlanModeChange:props.onPlanModeChange}:{})}
		{...(props.onLLMConfigChange?{onModelChange:(value:string|number)=>props.onLLMConfigChange?.(value)}:{})}
	/>{props.onNewSession?<Box sx={{position:'absolute',left:'50%',bottom:compact?10:21,width:compact?'calc(100% - 20px)':'calc(100% - 32px)',maxWidth:compact?960:948,transform:'translateX(-50%)',display:'flex',justifyContent:'flex-start',boxSizing:'border-box',pointerEvents:'none'}}><Tooltip title={t('agent.newSessionHint')} arrow><span><Button
		data-agent-new-session="true"
		aria-label={props.newSessionLabel}
		size="small"
		variant="text"
		startIcon={!compact&&!props.newSessionLoading?<AddCommentOutlinedIcon sx={{fontSize:'15px !important'}}/>:undefined}
		disabled={props.newSessionDisabled===true||props.newSessionLoading===true}
		onClick={props.onNewSession}
		sx={{height:compact?28:30,minWidth:compact?28:0,px:compact?0.5:0.9,borderRadius:1.5,color:Color.TextSecondary,fontSize:12,fontWeight:400,textTransform:'none',pointerEvents:'auto','& .MuiButton-startIcon':{mr:0.5},'&:hover':{color:Color.Theme,backgroundColor:Color.ThemeMuted},'&.Mui-disabled':{color:Color.DisabledText}}}
	>{props.newSessionLoading?<CircularProgress size={14}/>:compact?<AddCommentOutlinedIcon sx={{fontSize:16}}/>:props.newSessionLabel}</Button></span></Tooltip></Box>:null}</Box>;
}
