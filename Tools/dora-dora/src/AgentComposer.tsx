/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import React from 'react';
import {useTranslation} from 'react-i18next';
import {SharedAgentComposer,type AgentActualUsage} from '@dora-studio/agent-ui';
import '@dora-studio/agent-ui/style.css';

interface AgentComposerProps {
	compact?:boolean;prompt:string;loading:boolean;running:boolean;stopping?:boolean;canStop?:boolean;
	contextRatio?:number;usedTokens?:number;maxTokens?:number;actualUsage?:AgentActualUsage;
	fetchUrlEnabled?:boolean;executeCommandEnabled?:boolean;planMode?:boolean;
	llmConfigs?:Array<{id:number;name:string}>;llmConfigId?:number;
	onPromptChange:(value:string)=>void;onSend:()=>void;onStop:()=>void;
	onFetchUrlEnabledChange?:(value:boolean)=>void;onExecuteCommandEnabledChange?:(value:boolean)=>void;
	onPlanModeChange?:(value:boolean)=>void;onLLMConfigChange?:(value:number)=>void;
}

function compactNumber(value:number){if(value>=1_000_000)return`${(value/1_000_000).toFixed(1)}m`;if(value>=1_000)return`${(value/1_000).toFixed(1)}k`;return String(Math.max(0,Math.round(value)));}

/** The Web IDE and Studio share the original MUI composer; this wrapper only adapts i18n and numeric model IDs. */
export default function AgentComposer(props:AgentComposerProps){
	const {t}=useTranslation();
	return <SharedAgentComposer
		compact={props.compact??false} prompt={props.prompt} loading={props.loading} running={props.running}
		stopping={props.stopping??false} canStop={props.canStop??true}
		contextRatio={props.contextRatio??0} usedTokens={props.usedTokens??0} maxTokens={props.maxTokens??64000}
		{...(props.actualUsage?{actualUsage:props.actualUsage}:{})}
		fetchUrlEnabled={props.fetchUrlEnabled??false} executeCommandEnabled={props.executeCommandEnabled??false} planMode={props.planMode??false}
		models={props.llmConfigs??[]} {...(props.llmConfigId===undefined?{}:{modelId:props.llmConfigId})}
		labels={{
			promptPlaceholder:t('agent.promptPlaceholder'),planPromptPlaceholder:t('agent.planPromptPlaceholder'),send:t('agent.send'),stop:t('menu.stop'),stopping:t('agent.stopping'),
			planMode:t('agent.planMode'),planModeInactive:t('agent.planModeInactive'),planModeToggle:t('agent.planModeToggle'),networkAccess:t('agent.networkAccess'),networkToolsToggle:t('agent.networkToolsToggle'),executeCommand:t('agent.executeCommand'),executeCommandToggle:t('agent.executeCommandToggle'),
			selectModel:t('agent.selectModel'),modelForNextRun:t('agent.modelForNextRun'),contextUsage:(used,max,percent)=>t('agent.contextEstimateTitle',{used,max,percent}),
			actualUsage:usage=>t(usage.cachedInputTokens===undefined?'agent.actualUsageTitle':'agent.actualUsageWithCacheTitle',{input:compactNumber(usage.inputTokens),output:compactNumber(usage.outputTokens),cached:compactNumber(usage.cachedInputTokens??0),cachePercent:usage.inputTokens>0?Math.round(((usage.cachedInputTokens??0)/usage.inputTokens)*100):0,requests:compactNumber(usage.requestCount??0)}),
		}}
		onPromptChange={props.onPromptChange} onSend={props.onSend} onStop={props.onStop}
		{...(props.onFetchUrlEnabledChange?{onFetchUrlEnabledChange:props.onFetchUrlEnabledChange}:{})}
		{...(props.onExecuteCommandEnabledChange?{onExecuteCommandEnabledChange:props.onExecuteCommandEnabledChange}:{})}
		{...(props.onPlanModeChange?{onPlanModeChange:props.onPlanModeChange}:{})}
		{...(props.onLLMConfigChange?{onModelChange:(value:string|number)=>props.onLLMConfigChange?.(Number(value))}:{})}
	/>;
}
