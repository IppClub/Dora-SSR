import React from 'react';
import { Box, Button, Checkbox, FormControl, FormControlLabel, FormGroup, FormLabel, MenuItem, Paper, Stack, TextField, Typography } from '@mui/material';
import { createTheme, ThemeProvider } from '@mui/material/styles';
import { Color, theme } from './Theme';
import { Separator } from './Frame';
import AtomPieGameDetails, {findReadme, type Language, type ProjectReadme} from './AtomPieGameDetails';
import AtomPieCoverCrop from './AtomPieCoverCrop';
import AtomPiePublish from './AtomPiePublish';
import type {PlatformFields} from './AtomPieDraft';
import SportsEsportsOutlined from '@mui/icons-material/SportsEsportsOutlined';
import ImageOutlined from '@mui/icons-material/ImageOutlined';
import LinkOutlined from '@mui/icons-material/LinkOutlined';
import AddPhotoAlternateOutlined from '@mui/icons-material/AddPhotoAlternateOutlined';
import Info from './Info';
import './AtomPieSubmission.css';
import { useTranslation } from 'react-i18next';
import * as Service from './Service';
import {findProjectCover, projectDescriptions, readProjectCard, ProjectCardWriter} from './AtomPieProjectCard';

const engines = {dora_ssr:'Dora SSR', godot:'Godot', love2d:'LÖVE2D', tic_80:'TIC-80'};
const submissionTheme = createTheme(theme, {
	palette: {action: {active:Color.Primary}},
	components: {
		MuiToggleButton: {styleOverrides: {root: {
			color:Color.Primary, borderColor:Color.LineStrong,
			'&:hover': {color:Color.TextPrimary, backgroundColor:Color.SurfaceHover},
			'&.Mui-selected, &.Mui-selected:hover': {color:Color.Theme, backgroundColor:Color.ThemeMuted},
		}}},
		MuiInputBase: {styleOverrides: {input: {'&::placeholder': {color:Color.DisabledText, opacity:1}}}},
		MuiFormHelperText: {styleOverrides: {root: {color:Color.Primary, '&.Mui-disabled': {color:Color.DisabledText}}}},
		MuiSelect: {styleOverrides: {icon: {color:Color.Primary, '&.Mui-disabled': {color:Color.DisabledText}}}},
		MuiButtonBase: {styleOverrides: {root: {'&.Mui-focusVisible': {outline:`2px solid ${Color.Theme}`, outlineOffset:-2}}}},
		MuiButton: {styleOverrides: {
			containedPrimary: {color:Color.BackgroundDark, backgroundColor:Color.Theme, '&:hover': {backgroundColor:Color.Theme}},
			textPrimary: {'&:hover': {backgroundColor:Color.SurfaceHover, color:Color.TextPrimary}},
		}},
	},
});

const emptyReadme: ProjectReadme = {path:'', text:'', exists:false};
const sectionStyle = {
	display:'grid', gap:2, minWidth:0, p:2.5, bgcolor:Color.SurfaceRaised, borderColor:Color.Line,
	'& h3':{display:'flex', alignItems:'center', gap:1, fontWeight:600},
	'& h3 svg':{color:Color.Theme, fontSize:18},
	'& summary':{cursor:'pointer', color:Color.Primary},
};

// Match the public repository roots accepted by AtomPie review. Construct
// the public URL from components so credentials never reach the form.
export function publicRepository(value: string) {
	const match = /^(?:https:\/\/|ssh:\/\/git@|git@)(github\.com|atomgit\.com|gitee\.com)([/:])([\w.-]+)\/([\w.-]+)\/?$/i.exec(value.trim());
	if (!match || (value.trim().startsWith('git@') ? match[2] !== ':' : match[2] !== '/')) return;
	const repo = match[4].replace(/\.git$/i, '');
	if (!repo || [match[3], repo].some(part => part === '.' || part === '..')) return;
	return `https://${match[1].toLowerCase()}/${match[3]}/${repo}`;
}

interface SubmissionProps {
	fileUrl: (path:string) => string;
	project: string; repository: string; active: boolean; onCardSaved: () => void;
	onOpenFile?: (file: string) => void; onGenerateReadme: (root: string, lang:Language) => void;
}
export default function AtomPieSubmission(props: SubmissionProps) {
	return <ThemeProvider theme={submissionTheme}><SubmissionForm {...props} /></ThemeProvider>;
}

function SubmissionForm({project, repository, active, fileUrl, onCardSaved, onOpenFile, onGenerateReadme}: SubmissionProps) {
	const {t, i18n} = useTranslation();
	const chinese = i18n.language.startsWith('zh');
	const label = React.useCallback((zh:string,en:string) => chinese ? zh : en,[chinese]);
	const [descriptions, setDescriptions] = React.useState({zh:'', en:''});
	const [language, setLanguage] = React.useState<Language>(i18n.language.startsWith('zh') ? 'zh' : 'en');
	const [details, setDetails] = React.useState({version:'1.0.0', tags:'', video_url:''});
	const [editing, setEditing] = React.useState({zh:false, en:false});
	const [modes, setModes] = React.useState<string[]>([]);
	const [platforms, setPlatforms] = React.useState<string[]>([]);
	const [detectedEngine, setDetectedEngine] = React.useState('');
	const [chosenEngine, setChosenEngine] = React.useState<string>();
	const engine = chosenEngine ?? detectedEngine;
	const [readmes, setReadmes] = React.useState({zh:emptyReadme, en:emptyReadme});
	const [readingReadme, setReadingReadme] = React.useState(false);
	const [remotes, setRemotes] = React.useState<Service.GitRemoteInfo[]>([]);
	const [loadingRemotes, setLoadingRemotes] = React.useState(true);
	const [stage, setStage] = React.useState<'project'|'platform'>('project');
	const [visitedPlatform, setVisitedPlatform] = React.useState(false);
	const [categories, setCategories] = React.useState('');
	const [saveState, setSaveState] = React.useState<'idle'|'pending'|'saved'|'error'|'conflict'>('idle');
	const writer = React.useRef<ProjectCardWriter | undefined>(undefined);
	const savedCallback = React.useRef(onCardSaved);
	savedCallback.current = onCardSaved;
	const [reload, setReload] = React.useState(0);
	const scroller = React.useRef<HTMLDivElement>(null);
	React.useEffect(() => {scroller.current?.scrollTo(0,0);}, [stage]);
	React.useEffect(() => () => {void writer.current?.flush();}, []);
	React.useEffect(() => {
		if (!active || stage !== 'platform') return;
		let current = true;
		setLoadingRemotes(true);
		void Service.gitRemotes({repoPath: repository}).then(result => {
			const list = result.status?.data?.remotes;
			if (current) setRemotes(result.success && Array.isArray(list) ? list : []);
		}).catch(() => { if (current) setRemotes([]); })
			.finally(() => { if (current) setLoadingRemotes(false); });
		return () => { current = false; };
	}, [active, repository, stage]);
	const repositories = remotes.flatMap(remote => (remote.urls ?? []).flatMap(raw => {
		const url = publicRepository(raw);
		return url ? [{name: remote.name, url}] : [];
	}));
	const urls = [...new Set(repositories.map(repo => repo.url))];
	const [choice, setChoice] = React.useState('');
	const selected = choice ? (urls.includes(choice) ? choice : '') : repositories.find(repo => repo.name === 'origin')?.url ?? urls[0] ?? '';
	const editedFields = React.useRef(new Set<string>());
	const restoreFields = React.useCallback((saved?:PlatformFields, keepEdits = false) => {
		if (!keepEdits) editedFields.current.clear();
		const edited = new Set(editedFields.current);
		setDetails(prev => ({
			version:edited.has('version') ? prev.version : saved?.version ?? '1.0.0',
			tags:edited.has('tags') ? prev.tags : saved?.tags.join(', ') ?? '',
			video_url:edited.has('video_url') ? prev.video_url : saved?.video_url ?? '',
		}));
		if (!edited.has('play_modes')) setModes(saved?.game_metadata.play_modes ?? []);
		if (!edited.has('platforms')) setPlatforms(saved?.game_metadata.platforms ?? []);
		if (!edited.has('engine')) setChosenEngine(saved?.game_metadata.engine || undefined);
		if (!edited.has('repository_url')) setChoice(saved?.repository_url ?? '');
	},[]);
	const [zh, setZh] = React.useState('');
	const [en, setEn] = React.useState('');
	const [cropSource, setCropSource] = React.useState<File | string>();
	const [sourceFile, setSourceFile] = React.useState<File>();
	const [coverPath, setCoverPath] = React.useState('');
	const [cover, setCover] = React.useState<File>();
	const [original, setOriginal] = React.useState<string>();
	const [cardRoot, setCardRoot] = React.useState('');
	const [notice, setNotice] = React.useState('');
	const projectImage = coverPath && fileUrl(Info.path.join(cardRoot, coverPath));
	const [projectCover, setProjectCover] = React.useState<File>();
	const [coverRevision, setCoverRevision] = React.useState(0);
	const [coverError, setCoverError] = React.useState(false);
	const [image, setImage] = React.useState('');
	const currentCover = cover ?? projectCover;
	const missingProjectFields = [
		!(language === 'zh' ? zh : en).trim() && label('作品标题','title'),
		!descriptions[language].trim() && label('简介','summary'),
		!readmes[language].text.trim() && label('详细介绍','description'),
	].filter(Boolean);
	React.useEffect(() => {
		const controller = new AbortController();
		setProjectCover(undefined);
		setCoverError(false);
		if (projectImage) {
			void (async () => {
				const response = await fetch(projectImage, {cache:'no-store', signal:controller.signal});
				if (!response.ok) throw new Error('cover');
				const blob = await response.blob();
				if (!controller.signal.aborted) setProjectCover(new File([blob], Info.path.basename(coverPath), {type:blob.type}));
			})().catch(() => {if (!controller.signal.aborted) setCoverError(true);});
		}
		return () => controller.abort();
	}, [projectImage, coverPath, coverRevision]);
	React.useEffect(() => {
		if (!currentCover) {setImage(''); return;}
		const url = URL.createObjectURL(currentCover);
		setImage(url);
		setCoverError(false);
		return () => URL.revokeObjectURL(url);
	}, [currentCover]);
	React.useEffect(() => {
		if (!active) {void writer.current?.flush(); return;}
		if (writer.current?.unsaved) return;
		setOriginal(undefined);
		let current = true;
		async function load() {
			const entry = await Service.projectRoot({path: project, isDir: true});
			if (!current) return;
			const godot = (await Service.exist({file: Info.path.join(project, 'project.godot')})).success;
			if (!current) return;
			const root = godot ? project : entry.projectRoot || project;
			const isGodot = godot || (root !== project && (await Service.exist({file:Info.path.join(root, 'project.godot')})).success);
			const hasFile = async (name: string) => (await Service.exist({file:Info.path.join(root, name)})).success;
			const [loveMain, loveConfig, entries] = await Promise.all([hasFile('main.lua'), hasFile('conf.lua'), Service.assetChildren(root)]);
			const hasCart = entries.success && entries.children.some(item => !item.dir && /\.tic$/i.test(item.title));
			if (!current) return;
			setCardRoot(root);
			setDetectedEngine(isGodot ? 'godot' : loveMain && loveConfig ? 'love2d' : hasCart && !entry.found ? 'tic_80' : entry.found ? 'dora_ssr' : '');
			const [card, path] = await Promise.all([readProjectCard(root), findProjectCover(root)]);
			if (!current) return;
			const next = new ProjectCardWriter(root,card.content,(state, savedCover) => {
				if (writer.current !== next) return;
				setSaveState(state);
				if (savedCover) {
					setCoverPath('.dora/banner.jpg');
					setCoverRevision(n => n + 1);
				}
				if (state === 'saved') savedCallback.current();
			});
			writer.current = next;
			setSaveState('idle');
			setNotice('');
			setOriginal(card.content);
			setCategories(Array.isArray(card.metadata.categories) ? card.metadata.categories.join(', ') : '');
			setCover(undefined);
			setSourceFile(undefined);
			setDescriptions(projectDescriptions(card.metadata));
			setZh(typeof card.metadata.title?.zh === 'string' ? card.metadata.title.zh : '');
			setEn(typeof card.metadata.title?.en === 'string' ? card.metadata.title.en : '');
			setCoverPath(path);
		}
		void load().catch(() => { if (current) setNotice('git.atomPieCardError'); });
		return () => { current = false; };
	}, [project, active, reload]);
	React.useEffect(() => {
		if (!active || !cardRoot) return;
		let current = true;
		setReadingReadme(true);
		async function load() {
			const [zh, en] = await Promise.all([findReadme(cardRoot, repository, 'zh'), findReadme(cardRoot, repository, 'en')]);
			if (current) setReadmes({zh,en});
		}
		void load().catch(() => { if (current) setNotice('agent.atomPieReadmeError'); })
			.finally(() => { if (current) setReadingReadme(false); });
		return () => { current = false; };
	}, [active, cardRoot, repository]);
	async function enterPlatform() {
		if (writer.current && await writer.current.flush()) {
			setVisitedPlatform(true);
			setStage('platform');
		}
	}
	function field(name: keyof typeof details, text: string, required = false, rows = 0, hint = '') {
		return <TextField label={text} size="small" fullWidth required={required} value={details[name]}
			multiline={rows > 0} rows={rows || undefined} placeholder={hint} slotProps={{ inputLabel: { shrink: true } }}
			onChange={event => {editedFields.current.add(name);setDetails({...details, [name]: event.target.value});}} />;
	}
	function choices(field: string, text: string, options: string[][], values: string[], set: (v: string[]) => void) {
		return <FormControl component="fieldset" required>
			<FormLabel component="legend">{text}</FormLabel>
			<FormGroup row>{options.map(([value, caption]) =>
				<FormControlLabel key={value} label={caption} control={<Checkbox size="small" checked={values.includes(value)}
					onChange={(_, checked) => {editedFields.current.add(field);set(checked ? [...values, value] : values.filter(v => v !== value));}} />} />
			)}</FormGroup>
		</FormControl>;
	}
	return <Box ref={scroller} className="ap-studio" sx={{height:'100%', overflow:'auto', containerType:'inline-size', color:'text.primary', bgcolor:'background.default'}}>
		<Stack spacing={2.5} className="ap-sheet">
			{stage === 'project' && <>
				<Stack direction="row" alignItems="center" justifyContent="space-between" gap={2} flexWrap="wrap">
					<Typography component="h2" variant="h5">{label('Dora 项目资料','Dora project details')}</Typography>
					<Button variant="contained" disabled={original === undefined || editing.zh || editing.en}
						onClick={() => void enterPlatform()}>{label('发布到原子派','Publish to AtomPie')}</Button>
				</Stack>
				<Separator />
				<div className="ap-columns" onBlur={() => void writer.current?.flush()}>
					<AtomPieGameDetails fileUrl={fileUrl} language={language} onLanguage={setLanguage} titles={{zh,en}} summaries={descriptions}
						onTitle={(lang, value) => {(lang === 'zh' ? setZh : setEn)(value); writer.current?.edit({title:{[lang]:value}});}}
						onSummary={(lang, value) => {setDescriptions(prev => ({...prev, [lang]:value})); writer.current?.edit({description:{[lang]:value}});}}
						readmes={readmes} onReadme={(lang, value) => setReadmes(prev => ({...prev, [lang]:value}))}
						onEditing={(lang, value) => setEditing(prev => ({...prev, [lang]:value}))}
						reading={readingReadme} disabled={original === undefined} label={label}
						onGenerate={lang => onGenerateReadme(cardRoot, lang)}
						onSettings={original !== undefined && (original || saveState === 'saved') && onOpenFile ? () => onOpenFile(Info.path.join(cardRoot, '.dora', 'repo.json')) : undefined} />
					<Stack spacing={2} sx={{minWidth:0}}>
						<Paper component="section" variant="outlined" sx={sectionStyle}>
							<Typography component="h3" variant="subtitle1"><ImageOutlined />{label('作品封面','Cover')}</Typography>
							<Button component="label" variant="outlined" disabled={original === undefined}
								aria-label={t('git.atomPieCover')} sx={{aspectRatio:'16/9', overflow:'hidden', flexDirection:'column', gap:1}}>
								{image && !coverError ? <Box component="img" src={image} onError={() => setCoverError(true)} alt={label('当前作品封面','Game cover')} sx={{position:'absolute', inset:0, width:'100%', height:'100%', objectFit:'cover'}} /> :
									<><AddPhotoAlternateOutlined />{label('选择封面图片','Choose cover image')}</>}
								<input hidden type="file" accept="image/jpeg,image/png" onChange={event => {
									const file = event.target.files?.[0]; if (file) setCropSource(file); event.target.value='';
								}} />
							</Button>
							<Stack direction="row" alignItems="center" justifyContent="space-between" gap={1}>
							<Typography variant="caption" color="text.secondary">JPG / PNG · 16:9
								{coverError ? label(' · 封面读取失败，请重新选图。',' · Could not load the cover. Choose another image.') : !image && label(' · 裁剪后自动保存为启动器封面。',' · Crop to save as the launcher cover.')}</Typography>
							{image && !coverError && <Button size="small" disabled={original === undefined} onClick={() => setCropSource(sourceFile || currentCover)}>{label('裁剪封面','Crop cover')}</Button>}
							</Stack>
						</Paper>
						<Paper component="section" variant="outlined" sx={sectionStyle}>
							<TextField size="small" label={label('启动器分类','Launcher categories')} value={categories} disabled={original === undefined}
								helperText={label('多个分类用逗号分隔。Tool 会将项目列入工具。','Separate categories with commas. Tool lists the project under Tools.')}
								onChange={event => {
									const value = event.target.value;
									setCategories(value);
									writer.current?.edit({categories:value.split(/[,，]/).map(item=>item.trim()).filter(Boolean)});
								}} />
						</Paper>
					</Stack>
				</div>
				<Stack direction="row" alignItems="center" gap={1} role="status">
					<Typography variant="body2" color={['error','conflict'].includes(saveState) ? 'error' : 'text.secondary'}>
						{saveState === 'pending' ? label('正在保存到项目…','Saving to project…') :
							saveState === 'saved' ? label('已自动保存到项目','Changes saved to project') :
							saveState === 'error' ? label('保存失败，请重试。','Could not save changes. Please retry.') :
							saveState === 'conflict' ? label('同一字段已在工程中更改。可重新载入磁盘版本。','The same field changed on disk. Reload the project copy.') :
							label('标题、简介、分类和封面会自动保存到 .dora。','Title, summary, categories and cover save automatically to .dora.')}
					</Typography>
					{saveState === 'error' && <Button onClick={()=>void writer.current?.flush()}>{label('重试保存','Retry save')}</Button>}
					{saveState === 'conflict' && <Button onClick={()=>{
						writer.current = undefined;setOriginal(undefined);setReload(n=>n+1);
					}}>{label('放弃本地修改并重新载入','Discard local edits and reload')}</Button>}
				</Stack>
				{notice && <Stack direction="row" alignItems="center" spacing={1}>
					<Typography role="alert" variant="body2">{t(notice)}</Typography>
					{original === undefined && <Button onClick={()=>setReload(n=>n+1)}>{label('重新读取项目','Reload project')}</Button>}
				</Stack>}
			</>}
			{visitedPlatform && <Stack spacing={2.5} sx={{display:stage === 'platform' ? 'flex' : 'none'}}>
				<Stack direction="row" alignItems="center" justifyContent="space-between" gap={2} flexWrap="wrap">
					<Stack spacing={0.5}>
						<Typography component="h2" variant="h5">{label('发布到原子派','Publish to AtomPie')}</Typography>
						<Typography variant="body2" color="text.secondary">{(language === 'zh' ? zh : en) || Info.path.basename(project)} · {language === 'zh' ? '中文' : 'English'}</Typography>
					</Stack>
					<Button variant="outlined" onClick={()=>setStage('project')}>{label('返回项目资料','Back to project details')}</Button>
				</Stack>
				{!readingReadme && missingProjectFields.length > 0 && <Typography variant="body2" color="text.secondary">
					{label('请返回项目资料补齐','Complete in project details')}{' · '}{missingProjectFields.join(label('、', ', '))}
				</Typography>}
				<Separator />
				<div className="ap-columns">
					<Paper component="section" variant="outlined" sx={sectionStyle}>
						<Typography component="h3" variant="subtitle1"><SportsEsportsOutlined />{label('游戏信息','Game information')}</Typography>
						<TextField select size="small" label={label('开发引擎','Engine')} value={engine}
							slotProps={{inputLabel:{shrink:true}}} onChange={event => {editedFields.current.add('engine');setChosenEngine(event.target.value);}}>
							<MenuItem value="">{label('请选择','Select')}</MenuItem>
							{Object.entries(engines).map(([value, name]) => <MenuItem key={value} value={value}>{name}</MenuItem>)}
						</TextField>
						{field('tags',label('标签','Tags'),true,0,label('至少一个，用逗号分隔','At least one, separated by commas'))}
						{choices('play_modes',label('游玩方式','Play modes'),[['single_player',label('单人','Single player')],['local_multiplayer',label('本地联机','Local multiplayer')]],modes,setModes)}
						{choices('platforms',label('适配平台','Platforms'),[['pc','PC'],['mobile',label('手机','Mobile')]],platforms,setPlatforms)}
						{field('version',label('版本','Version'),true)}
					</Paper>
					<Paper component="section" variant="outlined" sx={sectionStyle}>
						<Typography component="h3" variant="subtitle1"><LinkOutlined />{label('发布信息','Publication')}</Typography>
						<TextField select label={label('源码仓库地址','Source repository')} required size="small" value={selected}
							slotProps={{inputLabel:{shrink:true}, select:{displayEmpty:true}}} disabled={!urls.length || loadingRemotes} onChange={event => {editedFields.current.add('repository_url');setChoice(event.target.value);}}
							helperText={!loadingRemotes && (!urls.length ? t('git.atomPieNoRemote') : choice && !selected ? label('原远程仓库已移除，请重新选择。','The saved remote was removed. Select a repository.') : '')}>
							{!urls.length && <MenuItem value="">{label('选择远程仓库','Choose repository')}</MenuItem>}
							{urls.map(url => <MenuItem key={url} value={url}>{url}</MenuItem>)}
						</TextField>
						{field('video_url',label('视频链接（选填）','Video link (optional)'),false,0,'https://www.bilibili.com/video/…')}
					</Paper>
				</div>
				<AtomPiePublish onRestore={restoreFields} active={active && stage === 'platform'} project={project} language={language} label={label}
					loading={loadingRemotes || readingReadme || editing.zh || editing.en}
					cover={coverError ? undefined : currentCover}
					data={{
						title:(language === 'zh' ? zh : en).trim(), short_description:descriptions[language].trim(),
						long_description:readmes[language].text, repository_url:selected, version:details.version.trim(),
						video_url:details.video_url.trim() || null, tags:[...new Set(details.tags.split(/[,，]/).map(v => v.trim()).filter(Boolean))],
						game_metadata:{engine, play_modes:modes, platforms},
					}} />
			</Stack>}
		</Stack>
		{cropSource && <AtomPieCoverCrop source={cropSource} label={label} onClose={() => setCropSource(undefined)}
			onConfirm={file => {setSourceFile(typeof cropSource === 'string' ? undefined : cropSource); setCover(file); writer.current?.edit({cover:file}); setCropSource(undefined);}} />}
	</Box>;
}
