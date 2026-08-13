import { Button, Checkbox as MuiCheckbox, Dialog, DialogActions, DialogContent, DialogContentText, DialogTitle, FormControlLabel, IconButton, InputAdornment, MenuItem, Stack, TextField, Tooltip, Typography } from '@mui/material';
import { useCallback, useEffect, useMemo, useState } from 'react';
import type { CSSProperties } from 'react';
import { useTranslation } from 'react-i18next';
import AddIcon from '@mui/icons-material/Add';
import DeleteIcon from '@mui/icons-material/Delete';
import EditIcon from '@mui/icons-material/Edit';
import VisibilityIcon from '@mui/icons-material/Visibility';
import VisibilityOffIcon from '@mui/icons-material/VisibilityOff';
import * as Service from './Service';
import { Color } from './Theme';
import { Table, ConfigProvider, theme } from 'antd';
import type { ColumnsType } from 'antd/es/table';
import { MacScrollbar } from 'mac-scrollbar';
import 'mac-scrollbar/dist/mac-scrollbar.css';

interface LLMConfigDialogProps {
	open: boolean;
	onClose: () => void;
}

type Mode = 'create' | 'edit';

type LLMTemplate = {
	id: string;
	label: string;
	url: string;
	model: string;
	contextWindow?: number;
	maxTokens?: number;
	customOptions?: string;
};

type LLMConfigFormState = Omit<Service.LLMConfigItem, "contextWindow" | "temperature" | "maxTokens"> & {
	contextWindow: number | string;
	temperature: number | string;
	maxTokens: number | string;
};

const DEFAULT_CONTEXT_WINDOW = 128000;
const DEFAULT_TEMPERATURE = 0.1;
const DEFAULT_MAX_TOKENS = 8192;
const DEFAULT_AUXILIARY_MAX_TOKENS = 8192;
const DEEPSEEK_CONTEXT_WINDOW = 1_000_000;
const DEEPSEEK_MAX_TOKENS = 64_000;

const customOptionsWithAuxiliary = (
	auxiliaryOptions: Record<string, unknown>,
	customOptions: Record<string, unknown> = {},
) => JSON.stringify({
	...customOptions,
	auxiliaryOptions,
}, null, 2);

const emptyForm: LLMConfigFormState = {
	id: 0,
	name: '',
	url: '',
	model: '',
	key: '',
	contextWindow: DEFAULT_CONTEXT_WINDOW,
	temperature: DEFAULT_TEMPERATURE,
	maxTokens: DEFAULT_MAX_TOKENS,
	reasoningEffort: '',
	customOptions: '',
	supportsFunctionCalling: true,
};

const inputStyle = {
	"& .MuiInputBase-root": {
		backgroundColor: Color.BackgroundDark,
	},
};

const normalizeFormNumber = (value: unknown, fallback: number) => {
	if (value === null || value === undefined || value === '') return fallback;
	const numberValue = Number(value);
	return Number.isFinite(numberValue) ? numberValue : fallback;
};

const normalizeCustomOptions = (value: unknown) => typeof value === 'string' ? value : '';

const validateCustomOptions = (value: string) => {
	const trimmed = value.trim();
	if (trimmed === '') return true;
	try {
		const parsed = JSON.parse(trimmed);
		return parsed !== null && typeof parsed === 'object' && !Array.isArray(parsed);
	} catch {
		return false;
	}
};

const parseCustomOptionsObject = (value: string): Record<string, unknown> | undefined => {
	const trimmed = value.trim();
	if (trimmed === '') return {};
	try {
		const parsed = JSON.parse(trimmed);
		return parsed !== null && typeof parsed === 'object' && !Array.isArray(parsed)
			? parsed as Record<string, unknown>
			: undefined;
	} catch {
		return undefined;
	}
};

const hasNonEmptyAuxiliaryOptions = (value: string) => {
	const parsed = parseCustomOptionsObject(value);
	if (!parsed) return false;
	const auxiliaryOptions = parsed.auxiliaryOptions;
	return auxiliaryOptions !== null
		&& typeof auxiliaryOptions === 'object'
		&& !Array.isArray(auxiliaryOptions)
		&& Object.keys(auxiliaryOptions).length > 0;
};

const BUILTIN_TEMPLATES: LLMTemplate[] = [
	{
		id: 'deepseek',
		label: 'DeepSeek',
		url: 'https://api.deepseek.com/v1/chat/completions',
		model: 'deepseek-v4-pro',
		contextWindow: DEEPSEEK_CONTEXT_WINDOW,
		maxTokens: DEEPSEEK_MAX_TOKENS,
		customOptions: customOptionsWithAuxiliary({
			max_tokens: DEFAULT_AUXILIARY_MAX_TOKENS,
			reasoning_effort: null,
			thinking: { type: 'disabled' },
		}),
	},
	{
		id: 'moonshot',
		label: 'Moonshot',
		url: 'https://api.moonshot.cn/v1/chat/completions',
		model: 'kimi-k3',
		// Kimi K3 cannot disable thinking; low is its smallest supported effort.
		customOptions: customOptionsWithAuxiliary({
			max_tokens: DEFAULT_AUXILIARY_MAX_TOKENS,
			reasoning_effort: 'low',
		}),
	},
	{
		id: 'qwen',
		label: 'Qwen',
		url: 'https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions',
		model: 'qwen3.7-max',
		customOptions: customOptionsWithAuxiliary({
			max_tokens: DEFAULT_AUXILIARY_MAX_TOKENS,
			reasoning_effort: null,
			enable_thinking: false,
		}),
	},
	{
		id: 'openrouter',
		label: 'OpenRouter',
		url: 'https://openrouter.ai/api/v1/chat/completions',
		model: '~anthropic/claude-sonnet-latest',
		customOptions: customOptionsWithAuxiliary({
			max_tokens: DEFAULT_AUXILIARY_MAX_TOKENS,
			reasoning_effort: null,
			reasoning: { effort: 'none' },
		}),
	},
	{
		id: 'openai',
		label: 'OpenAI',
		url: 'https://api.openai.com/v1/chat/completions',
		model: 'gpt-5.6',
		customOptions: customOptionsWithAuxiliary({
			max_tokens: null,
			max_completion_tokens: DEFAULT_AUXILIARY_MAX_TOKENS,
			reasoning_effort: 'none',
		}),
	},
	{
		id: 'aihubmix',
		label: 'AiHubMix',
		url: 'https://aihubmix.com/v1/chat/completions',
		model: 'gpt-5.6-luna',
		customOptions: customOptionsWithAuxiliary({
			max_tokens: null,
			max_completion_tokens: DEFAULT_AUXILIARY_MAX_TOKENS,
			reasoning_effort: 'none',
		}),
	},
	{
		id: 'siliconflow',
		label: 'SiliconFlow',
		url: 'https://api.siliconflow.cn/v1/chat/completions',
		model: 'deepseek-ai/DeepSeek-V4-Pro',
		customOptions: customOptionsWithAuxiliary({
			max_tokens: DEFAULT_AUXILIARY_MAX_TOKENS,
			reasoning_effort: null,
			enable_thinking: false,
		}),
	},
	{
		id: 'volcengine',
		label: 'VolcEngine',
		url: 'https://ark.cn-beijing.volces.com/api/v3/chat/completions',
		model: 'doubao-seed-2-0-pro-260215',
		customOptions: customOptionsWithAuxiliary({
			max_tokens: DEFAULT_AUXILIARY_MAX_TOKENS,
			reasoning_effort: null,
			thinking: { type: 'disabled' },
		}),
	},
	{
		id: 'volcengine-coding-plan',
		label: 'VolcEngine Coding Plan',
		url: 'https://ark.cn-beijing.volces.com/api/coding/v3/chat/completions',
		model: 'ark-code-latest',
		customOptions: customOptionsWithAuxiliary({
			max_tokens: DEFAULT_AUXILIARY_MAX_TOKENS,
			reasoning_effort: null,
			thinking: { type: 'disabled' },
		}),
	},
	{
		id: 'byteplus',
		label: 'BytePlus',
		url: 'https://ark.ap-southeast.bytepluses.com/api/v3/chat/completions',
		model: 'dola-seed-2-1-turbo-260628',
		customOptions: customOptionsWithAuxiliary({
			max_tokens: DEFAULT_AUXILIARY_MAX_TOKENS,
			reasoning_effort: null,
			thinking: { type: 'disabled' },
		}),
	},
	{
		id: 'byteplus-coding-plan',
		label: 'BytePlus Coding Plan',
		url: 'https://ark.ap-southeast.bytepluses.com/api/coding/v3/chat/completions',
		model: 'ark-code-latest',
		customOptions: customOptionsWithAuxiliary({
			max_tokens: DEFAULT_AUXILIARY_MAX_TOKENS,
			reasoning_effort: null,
			thinking: { type: 'disabled' },
		}),
	},
	{
		id: 'minimax',
		label: 'MiniMax',
		url: 'https://api.minimax.io/v1/chat/completions',
		model: 'MiniMax-M2.7',
		// MiniMax M2.7 does not expose a supported switch for disabling reasoning.
		customOptions: customOptionsWithAuxiliary({
			max_tokens: DEFAULT_AUXILIARY_MAX_TOKENS,
			reasoning_effort: null,
		}),
	},
	{
		id: 'minimax-cn',
		label: 'MiniMax (CN)',
		url: 'https://api.minimaxi.com/v1/chat/completions',
		model: 'MiniMax-M2.7',
		customOptions: customOptionsWithAuxiliary({
			max_tokens: DEFAULT_AUXILIARY_MAX_TOKENS,
			reasoning_effort: null,
		}),
	},
	{
		id: 'mimo',
		label: 'Xiaomi MiMo',
		url: 'https://api.xiaomimimo.com/v1/chat/completions',
		model: 'mimo-v2.5-pro',
		customOptions: customOptionsWithAuxiliary({
			max_tokens: null,
			max_completion_tokens: DEFAULT_AUXILIARY_MAX_TOKENS,
			reasoning_effort: null,
			thinking: { type: 'disabled' },
		}, {
			max_tokens: null,
			max_completion_tokens: DEFAULT_MAX_TOKENS,
			top_p: 0.95,
		})
	},
	{
		id: 'zai',
		label: 'ZAI',
		url: 'https://open.bigmodel.cn/api/paas/v4/chat/completions',
		model: 'glm-5.2',
		customOptions: customOptionsWithAuxiliary({
			max_tokens: DEFAULT_AUXILIARY_MAX_TOKENS,
			reasoning_effort: null,
			thinking: { type: 'disabled' },
		})
	},
	{
		id: 'zai-coding-plan',
		label: 'ZAI Coding Plan',
		url: 'https://open.bigmodel.cn/api/coding/paas/v4/chat/completions',
		model: 'glm-5.2',
		customOptions: customOptionsWithAuxiliary({
			max_tokens: DEFAULT_AUXILIARY_MAX_TOKENS,
			reasoning_effort: null,
			thinking: { type: 'disabled' },
		})
	},
	{
		id: 'ollama',
		label: 'Ollama',
		url: 'http://localhost:11434/v1/chat/completions',
		model: 'llama3.2',
		customOptions: customOptionsWithAuxiliary({
			max_tokens: DEFAULT_AUXILIARY_MAX_TOKENS,
			reasoning_effort: 'none',
		}),
	},
	{
		id: 'vllm',
		label: 'vLLM',
		url: 'http://localhost:8000/v1/chat/completions',
		model: 'meta-llama/Llama-3.1-8B-Instruct',
		customOptions: customOptionsWithAuxiliary({
			max_tokens: DEFAULT_AUXILIARY_MAX_TOKENS,
			reasoning_effort: 'none',
			chat_template_kwargs: { enable_thinking: false },
		}),
	},
];

const getDefaultAuxiliaryOptions = (config?: Pick<Service.LLMConfigItem, 'url'>): Record<string, unknown> => {
	const template = config
		? BUILTIN_TEMPLATES.find((item) => item.url === config.url.trim())
		: undefined;
	const templateOptions = parseCustomOptionsObject(template?.customOptions ?? '');
	const auxiliaryOptions = templateOptions?.auxiliaryOptions;
	if (auxiliaryOptions !== null && typeof auxiliaryOptions === 'object' && !Array.isArray(auxiliaryOptions)) {
		return auxiliaryOptions as Record<string, unknown>;
	}
	return { max_tokens: DEFAULT_AUXILIARY_MAX_TOKENS };
};

const ensureAuxiliaryOptions = (
	value: unknown,
	config?: Pick<Service.LLMConfigItem, 'url'>,
) => {
	const normalized = normalizeCustomOptions(value);
	const parsed = parseCustomOptionsObject(normalized);
	if (!parsed || Object.prototype.hasOwnProperty.call(parsed, 'auxiliaryOptions')) return normalized;
	return JSON.stringify({
		...parsed,
		auxiliaryOptions: getDefaultAuxiliaryOptions(config),
	}, null, 2);
};

const LLMConfigDialog = ({ open, onClose }: LLMConfigDialogProps) => {
	const { t } = useTranslation();
	const [items, setItems] = useState<Service.LLMConfigItem[]>([]);
	const [loading, setLoading] = useState(false);
	const [error, setError] = useState<string | null>(null);
	const [formOpen, setFormOpen] = useState(false);
	const [mode, setMode] = useState<Mode>('create');
	const [form, setForm] = useState<LLMConfigFormState>(emptyForm);
	const [templateId, setTemplateId] = useState('deepseek');
	const [showApiKey, setShowApiKey] = useState(false);
	const [pendingDelete, setPendingDelete] = useState<Service.LLMConfigItem | null>(null);

	const templates = useMemo(() => [
		...BUILTIN_TEMPLATES,
		{
			id: 'custom',
			label: t('llm.custom'),
			url: '',
			model: ''
		}
	], [t]);

	const loadItems = useCallback(async () => {
		setLoading(true);
		setError(null);
		try {
			const res = await Service.listLLMConfigs();
			if (res.success) {
				const normalized = (res.items ?? []).map((item) => ({
					...item,
					contextWindow: Number(item.contextWindow) > 0 ? Number(item.contextWindow) : DEFAULT_CONTEXT_WINDOW,
					temperature: normalizeFormNumber(item.temperature, DEFAULT_TEMPERATURE),
					maxTokens: Number(item.maxTokens) > 0 ? Number(item.maxTokens) : DEFAULT_MAX_TOKENS,
					reasoningEffort: typeof item.reasoningEffort === 'string' ? item.reasoningEffort : '',
					customOptions: ensureAuxiliaryOptions(item.customOptions, item),
					supportsFunctionCalling: item.supportsFunctionCalling === undefined ? true : Boolean(item.supportsFunctionCalling),
				}));
				setItems(normalized);
			} else {
				setError(res.message ?? t('llm.loadFailed'));
			}
		} catch {
			setError(t('llm.loadFailed'));
		} finally {
			setLoading(false);
		}
	}, [t]);

	const applyTemplate = useCallback((id: string) => {
		const template = templates.find((item) => item.id === id);
		if (!template) return;
		setTemplateId(id);
		setForm({
			...emptyForm,
			name: template.label,
			url: template.url,
			model: template.model,
			key: '',
			supportsFunctionCalling: true,
			contextWindow: template.contextWindow ?? DEFAULT_CONTEXT_WINDOW,
			temperature: DEFAULT_TEMPERATURE,
			maxTokens: template.maxTokens ?? DEFAULT_MAX_TOKENS,
			reasoningEffort: '',
			customOptions: template.customOptions ?? '',
		});
	}, [templates]);

	useEffect(() => {
		if (open) {
			loadItems();
			setMode('create');
			applyTemplate('deepseek');
		} else {
			setItems([]);
			setError(null);
			setMode('create');
			setForm(emptyForm);
			setFormOpen(false);
			setShowApiKey(false);
			setPendingDelete(null);
		}
	}, [open, loadItems, applyTemplate]);

	const openCreateForm = () => {
		setError(null);
		setMode('create');
		applyTemplate(templateId);
		setShowApiKey(false);
		setFormOpen(true);
	};

	const openEditForm = (item: Service.LLMConfigItem) => {
		setMode('edit');
		setForm({
			...item,
			contextWindow: Number(item.contextWindow) > 0 ? Number(item.contextWindow) : DEFAULT_CONTEXT_WINDOW,
			temperature: normalizeFormNumber(item.temperature, DEFAULT_TEMPERATURE),
			maxTokens: Number(item.maxTokens) > 0 ? Number(item.maxTokens) : DEFAULT_MAX_TOKENS,
			reasoningEffort: typeof item.reasoningEffort === 'string' ? item.reasoningEffort : '',
			customOptions: ensureAuxiliaryOptions(item.customOptions, item),
			supportsFunctionCalling: item.supportsFunctionCalling === undefined ? true : Boolean(item.supportsFunctionCalling),
		});
		setShowApiKey(false);
		setFormOpen(true);
	};

	const onDelete = async (id: number) => {
		const res = await Service.deleteLLMConfig(id);
		if (!res.success) {
			setError(res.message ?? t('llm.saveFailed'));
			return;
		}
		window.dispatchEvent(new Event('llm-configs-changed'));
		loadItems();
	};

	const onSave = async () => {
		const payload = {
			name: form.name.trim(),
			url: form.url.trim(),
			model: form.model.trim(),
			key: form.key.trim(),
			contextWindow: Math.floor(normalizeFormNumber(form.contextWindow, DEFAULT_CONTEXT_WINDOW)),
			temperature: normalizeFormNumber(form.temperature, DEFAULT_TEMPERATURE),
			maxTokens: Math.floor(normalizeFormNumber(form.maxTokens, DEFAULT_MAX_TOKENS)),
			reasoningEffort: (form.reasoningEffort ?? '').trim(),
			customOptions: normalizeCustomOptions(form.customOptions).trim(),
			supportsFunctionCalling: form.supportsFunctionCalling !== false,
		};
		if (!payload.name || !payload.url || !payload.model || !payload.key) {
			setError(t('llm.validationFailed'));
			return;
		}
		if (!validateCustomOptions(payload.customOptions)) {
			setError(t('llm.customOptionsInvalid'));
			return;
		}
		if (!hasNonEmptyAuxiliaryOptions(payload.customOptions)) {
			setError(t('llm.auxiliaryOptionsRequired'));
			return;
		}
		const res = mode === 'create'
			? await Service.createLLMConfig(payload)
			: await Service.updateLLMConfig({ ...payload, id: form.id });
		if (!res.success) {
			setError(res.message ?? t('llm.saveFailed'));
			return;
		}
		window.dispatchEvent(new Event('llm-configs-changed'));
		await loadItems();
		setFormOpen(false);
		setMode('create');
		applyTemplate('deepseek');
	};

	const columns: ColumnsType<Service.LLMConfigItem> = [
		{ title: t('llm.name'), dataIndex: 'name', key: 'name' },
		{ title: t('llm.model'), dataIndex: 'model', key: 'model' },
		{ title: t('llm.contextWindow'), dataIndex: 'contextWindow', key: 'contextWindow', width: 120 },
		{
			title: t('llm.functionCalling'),
			key: 'supportsFunctionCalling',
			width: 130,
			render: (_, record) => record.supportsFunctionCalling ? t('llm.supported') : t('llm.unsupported'),
		},
		{ title: t('llm.url'), dataIndex: 'url', key: 'url' },
		{
			title: t('llm.actions'),
			key: 'actions',
			render: (_, record) => (
				<Stack
					direction="row"
					spacing={0}
					alignItems="center"
					justifyContent="flex-end"
				>
					<Tooltip title={t('llm.edit')}>
						<IconButton
							size="small"
							onClick={() => openEditForm(record)}
							sx={{
								color: Color.Secondary,
								"&:hover": {
									backgroundColor: Color.Theme + '22',
								},
							}}
						>
							<EditIcon fontSize="small" />
						</IconButton>
					</Tooltip>
					<Tooltip title={t('llm.delete')}>
						<IconButton
							size="small"
							onClick={() => setPendingDelete(record)}
							sx={{
								color: Color.Secondary,
								"&:hover": {
									backgroundColor: Color.Theme + '22',
								},
							}}
						>
							<DeleteIcon fontSize="small" />
						</IconButton>
					</Tooltip>
				</Stack>
			)
		}
	];

	const isEditing = mode === 'edit';

	return (
		<Dialog open={open} onClose={onClose} fullWidth maxWidth="md">
			<DialogTitle>{t('llm.title')}</DialogTitle>
			<DialogContent>
				<Stack spacing={2}>
					<Stack direction="row" spacing={1} alignItems="center" justifyContent="space-between">
						<Typography color={Color.TextSecondary}>{t('llm.list')}</Typography>
						<Button size="small" startIcon={<AddIcon />} onClick={openCreateForm}>
							{t('llm.add')}
						</Button>
					</Stack>
					<ConfigProvider
						theme={{
							algorithm: [theme.darkAlgorithm, theme.compactAlgorithm],
							components: {
								Radio: {
									colorPrimary: Color.Theme + 'aa',
								},
								Checkbox: {
									colorPrimary: Color.Theme + 'aa',
									colorPrimaryHover: Color.Theme,
								}
							}
						}}
					>
						<MacScrollbar skin="dark" style={{ maxHeight: 360 }}>
							<div style={{ minWidth: 720 }}>
								<Table
									rowKey="id"
									columns={columns}
									dataSource={items}
									loading={loading}
									pagination={false}
									size="small"
									locale={{ emptyText: t('llm.empty') }}
								/>
							</div>
						</MacScrollbar>
					</ConfigProvider>
				</Stack>
			</DialogContent>
			<DialogActions>
				<Button onClick={onClose}>{t('action.close')}</Button>
			</DialogActions>
			<Dialog open={pendingDelete !== null} onClose={() => setPendingDelete(null)} fullWidth maxWidth="xs">
				<DialogTitle>{t('llm.deleteTitle')}</DialogTitle>
				<DialogContent>
					<DialogContentText color={Color.TextPrimary}>
						{t('llm.deleteConfirm', { name: pendingDelete?.name ?? '' })}
					</DialogContentText>
				</DialogContent>
				<DialogActions>
					<Button onClick={() => setPendingDelete(null)}>{t('action.cancel')}</Button>
					<Button
						color="error"
						variant="contained"
						onClick={async () => {
							const target = pendingDelete;
							setPendingDelete(null);
							if (target) {
								await onDelete(target.id);
							}
						}}
					>
						{t('action.confirm')}
					</Button>
				</DialogActions>
			</Dialog>
			<Dialog open={formOpen} onClose={() => setFormOpen(false)} fullWidth maxWidth="sm">
				<DialogTitle>{isEditing ? t('llm.editTitle') : t('llm.createTitle')}</DialogTitle>
				<DialogContent>
					<Stack spacing={2} sx={{ marginTop: 1 }}>
						{isEditing ? null : (
							<TextField
								select
								label={t('llm.template')}
								value={templateId}
								onChange={(event) => applyTemplate(event.target.value)}
								fullWidth
								size="small"
								sx={inputStyle}
							>
								{templates.map((template) => (
									<MenuItem key={template.id} value={template.id}>{template.label}</MenuItem>
								))}
							</TextField>
						)}
						<Stack direction="row" spacing={2}>
							<TextField
								label={t('llm.name')}
								value={form.name}
								onChange={(event) => setForm({ ...form, name: event.target.value })}
								fullWidth
								autoComplete="off"
								size="small"
								sx={inputStyle}
							/>
						</Stack>
						<TextField
							label={t('llm.url')}
							value={form.url}
							onChange={(event) => setForm({ ...form, url: event.target.value })}
							fullWidth
							autoComplete="off"
							size="small"
							sx={inputStyle}
						/>
						<Stack direction="row" spacing={2}>
							<TextField
								label={t('llm.model')}
								value={form.model}
								onChange={(event) => setForm({ ...form, model: event.target.value })}
								fullWidth
								autoComplete="off"
								size="small"
								sx={inputStyle}
							/>
							<TextField
								label={t('llm.contextWindow')}
								value={form.contextWindow}
								onChange={(event) => setForm({ ...form, contextWindow: event.target.value })}
								fullWidth
								autoComplete="off"
								size="small"
								type="number"
								slotProps={{ htmlInput: { min: DEFAULT_CONTEXT_WINDOW, step: 1000 } }}
								sx={inputStyle}
							/>
						</Stack>
						<Stack direction="row" spacing={2}>
							<TextField
								label={t('llm.temperature')}
								value={form.temperature}
								onChange={(event) => setForm({ ...form, temperature: event.target.value })}
								fullWidth
								autoComplete="off"
								size="small"
								type="number"
								slotProps={{ htmlInput: { min: 0, max: 2, step: 0.1 } }}
								sx={inputStyle}
							/>
							<TextField
								label={t('llm.maxTokens')}
								value={form.maxTokens}
								onChange={(event) => setForm({ ...form, maxTokens: event.target.value })}
								fullWidth
								autoComplete="off"
								size="small"
								type="number"
								slotProps={{ htmlInput: { min: 1, step: 256 } }}
								sx={inputStyle}
							/>
							<TextField
								label={t('llm.reasoningEffort')}
								value={form.reasoningEffort ?? ''}
								onChange={(event) => setForm({ ...form, reasoningEffort: event.target.value })}
								fullWidth
								autoComplete="off"
								size="small"
								sx={inputStyle}
							/>
						</Stack>
						<FormControlLabel
							control={
								<MuiCheckbox
									checked={form.supportsFunctionCalling !== false}
									onChange={(event) => setForm({ ...form, supportsFunctionCalling: event.target.checked })}
								/>
							}
							label={t('llm.functionCalling')}
						/>
						<TextField
							label={t('llm.customOptions')}
							value={form.customOptions ?? ''}
							onChange={(event) => setForm({ ...form, customOptions: event.target.value })}
							fullWidth
							autoComplete="off"
							size="small"
							multiline
							minRows={4}
							placeholder={'{\n  "max_tokens": null,\n  "top_p": 0.95\n}'}
							sx={inputStyle}
						/>
						<Stack direction="row" spacing={2}>
							<TextField
								label={t('llm.key')}
								value={form.key}
								onChange={(event) => setForm({ ...form, key: event.target.value })}
								fullWidth
								autoComplete="off"
								size="small"
								type="text"
								slotProps={{
									input: {
										endAdornment: (
											<InputAdornment position="end">
												<IconButton
													edge="end"
													size="small"
													onClick={() => setShowApiKey((value) => !value)}
												>
													{showApiKey ? <VisibilityOffIcon fontSize="small" /> : <VisibilityIcon fontSize="small" />}
												</IconButton>
											</InputAdornment>
										),
									},
									htmlInput: {
										style: showApiKey ? undefined : {
											WebkitTextSecurity: 'disc',
										} as CSSProperties,
									},
								}}
								sx={inputStyle}
							/>
						</Stack>
						{error ? <Typography color={Color.Error}>{error}</Typography> : null}
					</Stack>
				</DialogContent>
				<DialogActions>
					<Button onClick={() => setFormOpen(false)}>{t('action.close')}</Button>
					<Button onClick={onSave} variant="contained" disabled={loading}>
						{isEditing ? t('llm.save') : t('llm.create')}
					</Button>
				</DialogActions>
			</Dialog>
		</Dialog>
	);
};

export default LLMConfigDialog;
