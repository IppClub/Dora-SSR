import { Button, Dialog, DialogActions, DialogContent, DialogTitle, IconButton, MenuItem, Stack, TextField, Tooltip, Typography } from '@mui/material';
import { useCallback, useEffect, useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import AddIcon from '@mui/icons-material/Add';
import DeleteIcon from '@mui/icons-material/Delete';
import EditIcon from '@mui/icons-material/Edit';
import * as Service from './Service';
import { Color } from './Theme';
import { Checkbox, Table, ConfigProvider, theme } from 'antd';
import type { ColumnsType } from 'antd/es/table';
import { MacScrollbar } from 'mac-scrollbar';
import 'mac-scrollbar/dist/mac-scrollbar.css';

interface LLMConfigDialogProps {
	open: boolean;
	onClose: () => void;
}

type Mode = 'create' | 'edit';

const emptyForm = {
	id: 0,
	name: '',
	url: '',
	model: '',
	key: '',
	active: true,
};

const inputStyle = {
	"& .MuiInputBase-root": {
		backgroundColor: Color.BackgroundDark,
	},
	"& .MuiOutlinedInput-notchedOutline": {
		borderColor: Color.Line,
	},
	"&:hover .MuiOutlinedInput-notchedOutline": {
		borderColor: Color.TextSecondary,
	},
};

const LLMConfigDialog = ({open, onClose}: LLMConfigDialogProps) => {
	const {t} = useTranslation();
	const [items, setItems] = useState<Service.LLMConfigItem[]>([]);
	const [loading, setLoading] = useState(false);
	const [error, setError] = useState<string | null>(null);
	const [formOpen, setFormOpen] = useState(false);
	const [mode, setMode] = useState<Mode>('create');
	const [form, setForm] = useState<Service.LLMConfigItem>(emptyForm);
	const [templateId, setTemplateId] = useState('deepseek');
	const [savingActiveId, setSavingActiveId] = useState<number | null>(null);

	const templates = useMemo(() => [
		{
			id: 'deepseek',
			label: 'DeepSeek',
			url: 'https://api.deepseek.com/v1/chat/completions',
			model: 'deepseek-chat'
		},
		{
			id: 'moonshot',
			label: 'Moonshot',
			url: 'https://api.moonshot.cn/v1/chat/completions',
			model: 'moonshot-v1-auto'
		},
		{
			id: 'qwen',
			label: 'Qwen',
			url: 'https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions',
			model: 'qwen-coder-plus'
		},
		{
			id: 'openrouter',
			label: 'OpenRouter',
			url: 'https://openrouter.ai/api/v1/chat/completions',
			model: ''
		},
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
					active: item.active === undefined ? true : Boolean(item.active),
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
			active: true,
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
		}
	}, [open, loadItems, applyTemplate]);

	const openCreateForm = () => {
		setError(null);
		setMode('create');
		applyTemplate(templateId);
		setFormOpen(true);
	};

	const openEditForm = (item: Service.LLMConfigItem) => {
		setMode('edit');
		setForm({
			...item,
			active: item.active === undefined ? true : Boolean(item.active),
		});
		setFormOpen(true);
	};

	const onDelete = async (id: number) => {
		if (!window.confirm(t('llm.deleteConfirm'))) return;
		const res = await Service.deleteLLMConfig(id);
		if (!res.success) {
			setError(res.message ?? t('llm.saveFailed'));
			return;
		}
		loadItems();
	};

	const onSave = async () => {
		const payload = {
			name: form.name.trim(),
			url: form.url.trim(),
			model: form.model.trim(),
			key: form.key.trim(),
			active: form.active,
		};
		if (!payload.name || !payload.url || !payload.model || !payload.key) {
			setError(t('llm.validationFailed'));
			return;
		}
		const res = mode === 'create'
			? await Service.createLLMConfig(payload)
			: await Service.updateLLMConfig({...payload, id: form.id});
		if (!res.success) {
			setError(res.message ?? t('llm.saveFailed'));
			return;
		}
		await loadItems();
		setFormOpen(false);
		setMode('create');
		applyTemplate('deepseek');
	};

	const onToggleActive = async (record: Service.LLMConfigItem, nextActive: boolean) => {
		if (savingActiveId !== null) return;
		setSavingActiveId(record.id);
		setError(null);
		try {
			const res = await Service.updateLLMConfig({
				...record,
				active: nextActive,
			});
			if (!res.success) {
				setError(res.message ?? t('llm.saveFailed'));
			} else {
				setItems((prev) => prev.map((item) => (item.id === record.id ? {...item, active: nextActive} : item)));
			}
		} catch {
			setError(t('llm.saveFailed'));
		} finally {
			setSavingActiveId(null);
		}
	};

	const columns: ColumnsType<Service.LLMConfigItem> = [
		{title: t('llm.name'), dataIndex: 'name', key: 'name'},
		{title: t('llm.model'), dataIndex: 'model', key: 'model'},
		{title: t('llm.url'), dataIndex: 'url', key: 'url'},
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
					<Tooltip title={t('llm.active')}>
						<span>
							<Checkbox
								checked={Boolean(record.active)}
								disabled={savingActiveId === record.id}
								onChange={(event) => void onToggleActive(record, event.target.checked)}
								style={{paddingRight: 10}}
							/>
						</span>
					</Tooltip>
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
							<EditIcon fontSize="small"/>
						</IconButton>
					</Tooltip>
					<Tooltip title={t('llm.delete')}>
						<IconButton
							size="small"
							onClick={() => onDelete(record.id)}
							sx={{
								color: Color.Secondary,
								"&:hover": {
									backgroundColor: Color.Theme + '22',
								},
							}}
						>
							<DeleteIcon fontSize="small"/>
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
						<Button size="small" startIcon={<AddIcon/>} onClick={openCreateForm}>
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
						<MacScrollbar skin="dark" style={{maxHeight: 360}}>
							<div style={{minWidth: 720}}>
								<Table
									rowKey="id"
									columns={columns}
									dataSource={items}
									loading={loading}
									pagination={false}
									size="small"
									locale={{emptyText: t('llm.empty')}}
								/>
							</div>
						</MacScrollbar>
					</ConfigProvider>
				</Stack>
			</DialogContent>
			<DialogActions>
				<Button onClick={onClose}>{t('action.close')}</Button>
			</DialogActions>
			<Dialog open={formOpen} onClose={() => setFormOpen(false)} fullWidth maxWidth="sm">
				<DialogTitle>{isEditing ? t('llm.editTitle') : t('llm.createTitle')}</DialogTitle>
				<DialogContent>
					<Stack spacing={2} sx={{marginTop: 1}}>
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
								onChange={(event) => setForm({...form, name: event.target.value})}
								fullWidth
								autoComplete="off"
								size="small"
								sx={inputStyle}
							/>
						</Stack>
						<TextField
							label={t('llm.url')}
							value={form.url}
							onChange={(event) => setForm({...form, url: event.target.value})}
							fullWidth
							autoComplete="off"
							size="small"
							sx={inputStyle}
						/>
						<Stack direction="row" spacing={2}>
							<TextField
								label={t('llm.model')}
								value={form.model}
								onChange={(event) => setForm({...form, model: event.target.value})}
								fullWidth
								autoComplete="off"
								size="small"
								sx={inputStyle}
							/>
							<TextField
								label={t('llm.key')}
								value={form.key}
								onChange={(event) => setForm({...form, key: event.target.value})}
								fullWidth
								autoComplete="off"
								size="small"
								type="password"
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
