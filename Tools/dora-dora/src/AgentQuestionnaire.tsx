import React from 'react';
import {useTranslation} from 'react-i18next';
import {SharedAgentQuestionnaire} from '@dora-studio/agent-ui';
import type * as Service from './Service';

/** Shared with Studio; this adapter preserves Web IDE translations and service types. */
export default function AgentQuestionnaire(props:{questionnaire:Service.AgentQuestionnaire;submitting:boolean;onSubmit:(answers:Service.AgentQuestionnaireAnswer[])=>void;onCancel:()=>void}){
	const {t}=useTranslation();
	return <SharedAgentQuestionnaire questionnaire={props.questionnaire} submitting={props.submitting} onCancel={props.onCancel}
		onSubmit={answers=>props.onSubmit(answers as Service.AgentQuestionnaireAnswer[])} labels={{
		questions:t('agent.questionnaire.questions'),single:t('agent.questionnaire.single'),multiple:t('agent.questionnaire.multiple'),text:t('agent.questionnaire.text'),recommended:t('agent.questionnaire.recommended'),other:t('agent.questionnaire.other'),cancel:t('agent.questionnaire.cancel'),previous:t('agent.questionnaire.previous'),skip:t('agent.questionnaire.skip'),next:t('agent.questionnaire.next'),submit:t('agent.questionnaire.submit'),
	}}/>;
}
