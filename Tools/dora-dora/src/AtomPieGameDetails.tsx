import { useState } from 'react';
import { Box, Button, FormLabel, Paper, Stack, TextField, ToggleButton, ToggleButtonGroup, Typography } from '@mui/material';
import DescriptionOutlined from '@mui/icons-material/DescriptionOutlined';
import EditOutlined from '@mui/icons-material/EditOutlined';
import Markdown from './Markdown';
import { Color } from './Theme';
import Info from './Info';
import * as Service from './Service';

export type Language = 'zh' | 'en';
export type ProjectReadme = {path:string; text:string; exists:boolean};
const languages: Language[] = ['zh', 'en'];

export async function findReadme(project: string, repository: string, lang: Language): Promise<ProjectReadme> {
	const names = lang === 'zh' ? ['README.zh-CN.md', 'README.zh.md', 'README.md', 'Readme.md', 'readme.md'] :
		['README.en.md', 'README.en-US.md', 'README_EN.md'];
	for (const dir of new Set([project, repository])) {
		for (const name of names) {
			const path = Info.path.join(dir, name);
			if (!(await Service.exist({file:path})).success) continue;
			const file = await Service.read({path});
			if (!file.success) throw new Error('readme');
			return {path, text:file.content, exists:true};
		}
	}
	return {path:Info.path.join(project, lang === 'zh' ? 'README.md' : 'README.en.md'), text:'', exists:false};
}

type Props = {
	fileUrl: (path:string) => string;
	language: Language; onLanguage: (lang: Language) => void;
	titles: Record<Language, string>; summaries: Record<Language, string>;
	onTitle: (lang: Language, value: string) => void; onSummary: (lang: Language, value: string) => void;
	readmes: Record<Language, ProjectReadme>; onReadme: (lang: Language, value: ProjectReadme) => void;
	onEditing: (lang:Language, editing:boolean) => void;
	disabled: boolean; reading: boolean; onGenerate: (lang: Language) => void; onSettings?: () => void;
	label: (zh:string, en:string) => string;
};

function DetailsPanel({lang, ...props}: Props & {lang:Language}) {
	const {label, language} = props;
	const readme = props.readmes[lang];
	const [edit, setEdit] = useState<ProjectReadme>();
	const [draft, setDraft] = useState('');
	const [saving, setSaving] = useState(false);
	const [error, setError] = useState('');
	const active = language === lang;
	async function save() {
		if (!edit || saving) return;
		setSaving(true);
		setError('');
		try {
			const exists = (await Service.exist({file:edit.path})).success;
			const current = exists ? await Service.read({path:edit.path}) : undefined;
			if (current && !current.success) throw new Error('read');
			if (exists !== edit.exists || (current?.success && current.content !== edit.text)) {
				setError(label('README 已在项目中更改，请取消编辑后重新打开。','The README changed on disk. Cancel and reopen the editor.'));
				props.onReadme(lang, {path:edit.path, text:current?.success ? current.content : '', exists});
				return;
			}
			const result = exists ? await Service.write({path:edit.path, content:draft}) :
				await Service.newFile({path:edit.path, content:draft, folder:false});
			if (!result.success) throw new Error('write');
			props.onReadme(lang, {path:edit.path, text:draft, exists:true});
			setEdit(undefined);
			props.onEditing(lang, false);
		} catch { setError(label('README 保存失败，请重试。','Could not save the README. Please retry.')); }
		finally { setSaving(false); }
	}
	return <div className="ap-language-panel" aria-hidden={!active} inert={!active} lang={lang}>
		<Stack spacing={2} sx={{minWidth:0}}>
			<TextField fullWidth size="small" label={label('作品标题','Title')} value={props.titles[lang]}
				disabled={props.disabled} slotProps={{inputLabel:{shrink:true}, htmlInput:{maxLength:120}}}
				onChange={e => props.onTitle(lang, e.target.value)} />
			<TextField fullWidth size="small" multiline minRows={2} label={label('简介','Summary')}
				value={props.summaries[lang]} disabled={props.disabled} slotProps={{inputLabel:{shrink:true}}}
				onChange={e => props.onSummary(lang, e.target.value)} />
			<Stack spacing={1}>
				<Stack direction="row" alignItems="center" justifyContent="space-between">
					<FormLabel>{label('详细介绍','Description')}</FormLabel>
					{!edit && <Button size="small" startIcon={<EditOutlined />} disabled={props.reading || !readme.path}
						onClick={() => {setEdit(readme); props.onEditing(lang, true); setDraft(readme.text); setError('');}}>{label('编辑','Edit')}</Button>}
				</Stack>
				{edit ? <>
					<TextField autoFocus fullWidth multiline minRows={5} maxRows={16} size="small" value={draft} label="Markdown"
						disabled={saving} onChange={e => setDraft(e.target.value)} />
					{error && <Typography color="error" role="alert">{error}</Typography>}
					<Stack direction="row" justifyContent="flex-end" spacing={1}>
						<Button disabled={saving} onClick={() => {setEdit(undefined); props.onEditing(lang, false);}}>{label('取消','Cancel')}</Button>
						<Button variant="outlined" disabled={saving} onClick={save}>{label('保存 README','Save README')}</Button>
					</Stack>
				</> : readme.text ? <Box sx={{maxHeight:360, overflow:'auto', borderLeft:1, borderColor:'divider', pl:1.5}}>
					<Markdown content={readme.text} path={props.fileUrl(Info.path.dirname(readme.path))} inheritTypography />
				</Box> : <Stack alignItems="flex-start" spacing={1}>
					<Typography variant="body2" color="text.secondary">{props.reading ? label('正在读取 README…','Reading README…') :
						label('尚无详细介绍','No description yet')} · {lang === 'zh' ? 'README.md' : 'README.en.md'}</Typography>
					{!readme.exists && <Button size="small" variant="outlined" disabled={props.reading || !readme.path} onClick={() => props.onGenerate(lang)}>
						{label('用 Dora 生成 README','Generate README with Dora')}</Button>}
				</Stack>}
			</Stack>
		</Stack>
	</div>;
}

export default function AtomPieGameDetails(props: Props) {
	const {label, language} = props;
	return <Paper component="section" variant="outlined" sx={{minWidth:0, bgcolor:Color.SurfaceRaised, borderColor:Color.Line, overflow:'hidden'}}>
		<Stack direction="row" alignItems="center" justifyContent="space-between" gap={1} sx={{px:2.5, pt:2}}>
			<Typography component="h3" variant="subtitle1" sx={{display:'flex',alignItems:'center',gap:1,fontWeight:600}}>
				<DescriptionOutlined sx={{color:Color.Theme}} fontSize="small" />{label('作品资料','Game details')}</Typography>
			<ToggleButtonGroup exclusive value={language} size="small" aria-label={label('作品资料语言','Game details language')}
				onChange={(_, lang:Language | null) => {if (lang) props.onLanguage(lang);}}>
				<ToggleButton value="zh">中文</ToggleButton><ToggleButton value="en" sx={{textTransform:'none'}}>English</ToggleButton>
			</ToggleButtonGroup>
		</Stack>
		<div className="ap-language-track" data-language={language}>
			{languages.map(lang => <DetailsPanel key={lang} lang={lang} {...props} />)}
		</div>
		{props.onSettings && <Button size="small" sx={{mx:2, mb:1.5}} onClick={props.onSettings}>
			{label('打开启动器配置','Open launcher settings')} ↗</Button>}
	</Paper>;
}
