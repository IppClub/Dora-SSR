import type {AgentComposerLabels, SharedAgentQuestionnaireLabels} from '@dora-studio/agent-ui';
import {createInstance} from 'i18next';
import {I18nextProvider, useTranslation} from 'react-i18next';
import {useEffect, type ReactNode} from 'react';
import {studioResources, type StudioMessageKey} from './locales';

type StudioLocale = 'zh' | 'en';
const preference = 'dora-studio-interface-language';

function initialLocale(): StudioLocale {
  try {
    const stored = localStorage.getItem(preference);
    if (stored === 'en' || stored === 'zh') return stored;
  } catch { /* Keep Studio usable with browser storage disabled. */ }
  return 'zh';
}

const studioI18n = createInstance();
void studioI18n.init({
  resources: studioResources,
  lng: initialLocale(),
  fallbackLng: 'zh',
  supportedLngs: ['zh', 'en'],
  initAsync: false,
  interpolation: {escapeValue: false},
});

export function StudioI18nProvider({children}: {children: ReactNode}) {
  const {i18n} = useTranslation(undefined, {i18n: studioI18n, useSuspense: false});
  const locale = i18n.resolvedLanguage === 'en' ? 'en' : 'zh';
  useEffect(() => {
    document.documentElement.lang = locale === 'zh' ? 'zh-CN' : 'en';
    try { localStorage.setItem(preference, locale); } catch { /* Locale remains valid for this session. */ }
  }, [locale]);
  return <I18nextProvider i18n={studioI18n}>{children}</I18nextProvider>;
}

export type StudioMessage = [key: StudioMessageKey, values?: Record<string, string | number | Date>];
export type StudioTranslate = (key: StudioMessageKey | 'you', values?: StudioMessage[1]) => string;

export function useStudioI18n() {
  const {t, i18n} = useTranslation(undefined, {useSuspense: false});
  const locale = i18n.resolvedLanguage === 'en' ? 'en' : 'zh';
  const date = (value: number, showSeconds = false) => new Date(value).toLocaleString(locale === 'zh' ? 'zh-CN' : 'en', {
    year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit',
    ...(showSeconds ? {second: '2-digit'} : {}),
  });
  const translate: StudioTranslate = (key, values) => {
    if (!values) return t(key);
    const formatted = Object.fromEntries(Object.entries(values).map(([name, value]) =>
      [name, value instanceof Date ? date(value.getTime()) : value]));
    return t(key, formatted);
  };
  return {
    locale,
    date,
    setLocale: (locale: StudioLocale) => { void i18n.changeLanguage(locale); },
    t: translate,
    toolName: (tool: string) => Object.hasOwn(studioResources.en.translation.agentTool, tool)
      ? t(`agentTool.${tool}`, {defaultValue: tool}) : tool,
  };
}

type AgentStatus = Extract<StudioMessageKey, Uppercase<StudioMessageKey>>;
export function agentStatusLabel(t: (key: StudioMessageKey) => string, status: string): string {
  return Object.hasOwn(studioResources.en.translation, status) && status === status.toUpperCase() ? t(status as AgentStatus) : status;
}

export function useStudioAgentLabels() {
  const {t, i18n} = useTranslation(undefined, {useSuspense: false});
  const number = new Intl.NumberFormat(i18n.resolvedLanguage ?? 'zh', {notation: 'compact', maximumFractionDigits: 1});
  const composerLabels = {
    attachFiles: t('composer.attachFiles'),
    attachmentList: t('composer.attachmentList'),
    removeAttachment: name => t('composer.removeAttachment', {name}),
    sendFailed: t('composer.sendFailed'),
    attachmentContext: t('composer.attachmentContext'),
    planPromptPlaceholder: t('composer.planPromptPlaceholder'),
    stop: t('composer.stop'),
    stopping: t('composer.stopping'),
    planMode: t('composer.planMode'),
    planModeInactive: t('composer.planMode'),
    planModeToggle: t('composer.planModeToggle'),
    selectModel: t('composer.selectModel'),
    modelForNextRun: t('composer.modelForNextRun'),
    contextUsage: (used, max, percent) => t('composer.contextUsage', {used, max, percent}),
    actualUsage: ({inputTokens, outputTokens, cachedInputTokens}) =>
      t('composer.actualUsage', {input: number.format(inputTokens), output: number.format(outputTokens)}) +
      (cachedInputTokens === undefined ? '' : t('composer.cachedUsage', {cached: number.format(cachedInputTokens)})),
  } satisfies Partial<AgentComposerLabels>;
  const questionnaireLabels = t('questionnaire', {returnObjects: true}) as SharedAgentQuestionnaireLabels;
  return {composerLabels, questionnaireLabels};
}
