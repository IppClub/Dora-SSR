import React from 'react';
import { Alert, Button, Dialog, DialogActions, DialogContent, DialogTitle, MenuItem, Paper, Stack, TextField, Typography } from '@mui/material';
import AccountCircleOutlined from '@mui/icons-material/AccountCircleOutlined';
import OpenInNewOutlined from '@mui/icons-material/OpenInNewOutlined';
import { announceAccountChange, cancelAuthorization, isAccountChange, publisherRequest, pollAuthorization, readAccount, startAuthorization, type Account, type Grant } from './AtomPieClient';
import { draftKey, loadDraft, saveDraft, sendForReview, type PlatformFields, type SubmissionData } from './AtomPieDraft';
import { Color } from './Theme';
import { isNativeIDE } from './NativeIDERun';
import { showNativeIDE } from './Service';

interface Props {
	onRestore:(fields?:PlatformFields, keepEdits?:boolean)=>void;
	project:string; language:'zh'|'en'; active:boolean; loading:boolean; data:SubmissionData; cover?:File;
	label:(zh:string,en:string)=>string;
}
const message = (error:unknown) => error instanceof Error ? error.message : '原子派请求失败。';

export default function AtomPiePublish({project,language,active,loading,data,cover,label,onRestore}:Props) {
	const [account,setAccount] = React.useState<Account>();
	const [grant,setGrant] = React.useState<Grant>();
	const [organization,setOrganization] = React.useState<number | null>(null);
	const [busy,setBusy] = React.useState(false);
	const [checking,setChecking] = React.useState(true);
	const [error,setError] = React.useState('');
	const [notice,setNotice] = React.useState('');
	const [confirm,setConfirm] = React.useState(false);
	const scope = React.useRef('');
	const lastUser = React.useRef<number | undefined>(undefined);
	const baseline = React.useRef<string | null>(null);
	const timer = React.useRef(0);
	const native = isNativeIDE();
	const key = account ? draftKey(project,language,account.id,organization) : '';
	const draft = key ? loadDraft(key) : undefined;
	React.useLayoutEffect(() => {
		const cached = key ? loadDraft(key) : undefined;
		const fields = cached?.updateAttempt?.fields ?? cached?.fields ?? cached?.initial;
		if (fields || scope.current) onRestore(fields);
		scope.current = key;
		baseline.current = key ? localStorage.getItem(key) : null;
	},[key,onRestore]);
	const body = {...data,organization_id:organization};
	const canSave = Boolean(account?.can_publish && data.title && data.short_description && data.repository_url && data.game_metadata.engine);
	const ready = canSave && data.tags.length > 0 && data.game_metadata.play_modes.length > 0 && data.game_metadata.platforms.length > 0 &&
		Boolean(data.long_description.trim() && data.version.trim() && (cover || draft?.asset?.cover_file_id));
	React.useEffect(() => {
		if (!active || grant) return;
		let sequence = 0;
		const refresh = () => {
			const run = ++sequence;
			setChecking(true);
			void readAccount().then(user => {
				if (run !== sequence) return;
				const sameUser = user?.id === lastUser.current;
				lastUser.current = user?.id;
				setAccount(user);
				setOrganization(prev=>sameUser && user?.organizations.some(org=>org.id === prev) ? prev : null);
			}).catch(e=>{if (run === sequence) {setAccount(undefined);setError(message(e));}})
				.finally(()=>{if (run === sequence) setChecking(false);});
		};
		const changed = (event:StorageEvent) => {if (isAccountChange(event)) refresh();};
		refresh();
		window.addEventListener('atompie-account',refresh);
		window.addEventListener('storage',changed);
		return () => {
			sequence++;
			window.removeEventListener('atompie-account',refresh);
			window.removeEventListener('storage',changed);
		};
	},[active,grant]);
	React.useEffect(() => {
		setNotice('');
		setError('');
		setConfirm(false);
	},[key,active]);
	React.useEffect(() => {
		if (!grant) return;
		let current = true;
		let interval = grant.interval;
		let polling = false;
		let nextPoll = Date.now()+interval*1000;
		function schedule() {
			window.clearTimeout(timer.current);
			timer.current = window.setTimeout(poll,Math.max(0,nextPoll-Date.now()));
		}
		function resume() {
			if (!document.hidden && !polling) schedule();
		}
		async function poll() {
			if (!current || polling) return;
			if (Date.now() >= grant!.expires) {setGrant(undefined);setError(label('授权请求已过期，请重新连接。','Authorization expired. Connect again.'));return;}
			polling = true;
			try {
				const result = await pollAuthorization(grant!.user_code);
				if (!current) return;
				if (native && (result.status === 'authorized' || result.status === 'access_denied')) {
					void showNativeIDE().catch(() => {}); // Focus is best effort; the grant has already been decided.
				}
				if (result.status === 'authorized') {
					setGrant(undefined);setError('');announceAccountChange();return;
				}
				if (result.status === 'access_denied' || result.status === 'expired_token') {
					setGrant(undefined);setError(result.status === 'access_denied' ? label('已取消授权。','Authorization declined.') : label('授权请求已过期。','Authorization expired.'));return;
				}
				if (result.status === 'slow_down') interval = Math.max(interval+1,result.interval || 0);
			} catch (e) {if (current) setError(message(e));}
			polling = false;
			if (current) {nextPoll=Date.now()+interval*1000;schedule();}
		}
		schedule();
		window.addEventListener('focus',resume);
		document.addEventListener('visibilitychange',resume);
		return () => {
			current=false;window.clearTimeout(timer.current);
			window.removeEventListener('focus',resume);
			document.removeEventListener('visibilitychange',resume);
		};
	},[grant,native,label]); // The authorization continues while the author inspects another IDE tab.

	async function connect() {
		setBusy(true);setError('');setNotice('');
		const popup = native ? null : window.open('about:blank','_blank');
		if (popup) {popup.opener=null;popup.document.title='AtomPie';popup.document.body.textContent=label('正在打开原子派授权页…','Opening AtomPie authorization…');}
		try {
			const next = await startAuthorization();setGrant(next);
			if (native) window.location.assign(next.url);
			else if (popup && !popup.closed) popup.location.replace(next.url);
		} catch (e) {popup?.close();setError(message(e));}
		finally {setBusy(false);}
	}

	async function perform(action:'save'|'submit'|'disconnect') {
		if (busy || checking || !account) return;
		const request = publisherRequest(account.id,organization);
		setBusy(true);setConfirm(false);setError('');setNotice('');
		try {
			if (action==='disconnect') {
				await request('disconnect');setAccount(undefined);setOrganization(null);announceAccountChange();
			} else {
				await request<Account>('me');
				if (scope.current !== key) return;
				if (localStorage.getItem(key) !== baseline.current) {
					const cached = loadDraft(key);
					onRestore(cached.updateAttempt?.fields ?? cached.fields ?? cached.initial);
					throw new Error(label('草稿已在其他窗口更改，请核对后重试。','The draft changed in another window. Review the fields and retry.'));
				}
				if (action==='save' || !draft?.review) {
					if (cover && (cover.size > 5*1024*1024 || !['image/jpeg','image/png'].includes(cover.type))) throw new Error(label('请先裁剪封面，再保存稿件。','Crop the cover before saving.'));
					const result = await saveDraft(key,body,cover,request);
					if (result.restored) {
						if (scope.current === key) {
							onRestore(result.draft.fields,true);
							setNotice(label('已载入原子派草稿资料，请核对后再次保存或送审。','Draft details restored. Review them before saving or submitting.'));
						}
						return;
					}
				}
				if (action==='submit') {
					await sendForReview(key,request);
					setNotice(label('已提交审核，可在「我的稿件」查看进度。','Submitted for review. Check progress in My submissions.'));
				} else setNotice(label('草稿已保存到原子派。','Draft saved to AtomPie.'));
			}
		} catch (e) {setError(message(e));}
		finally {if (scope.current === key) baseline.current = localStorage.getItem(key);setBusy(false);}
	}

	return <Paper component="section" variant="outlined" sx={{p:2.5,bgcolor:Color.SurfaceRaised,borderColor:Color.Line}}>
		<Stack spacing={2}>
			<Stack direction="row" alignItems="center" justifyContent="space-between" gap={1} flexWrap="wrap">
				<Stack direction="row" alignItems="center" spacing={1}>
					<AccountCircleOutlined sx={{color:Color.Theme}} />
					<Typography component="h3" variant="subtitle1">{label('原子派账号','AtomPie account')}</Typography>
				</Stack>
				{account ? <Stack direction="row" alignItems="center" spacing={1}>
					<Typography variant="body2">{account.full_name || account.email}</Typography>
					<Button size="small" disabled={busy} onClick={()=>void perform('disconnect')}>{label('断开连接','Disconnect')}</Button>
				</Stack> : !grant && <Button variant="contained" disabled={busy || checking} onClick={connect}>{label('连接原子派','Connect to AtomPie')}</Button>}
			</Stack>
			{grant && <Stack spacing={1} alignItems="flex-start" role="status">
				<Typography variant="body2">{label('请在原子派授权页核对匹配码','Match this code on the AtomPie authorization page')}</Typography>
				<Typography variant="h6" sx={{letterSpacing:2}}>{grant.user_code}</Typography>
				<Stack direction="row" spacing={1}>
					<Button component="a" href={grant.url} target={native ? '_self' : '_blank'} rel="noopener noreferrer" variant="outlined">{label('打开授权页','Open authorization page')}</Button>
					<Button onClick={async()=>{try {await cancelAuthorization(grant.user_code);setGrant(undefined);}catch(e){setError(message(e));}}}>{label('取消','Cancel')}</Button>
				</Stack>
			</Stack>}
			{account && <>
				{!account.can_publish && <Alert severity="info">{label('此账号需先在原子派开通开发者身份。','Enable developer access on AtomPie to submit a game.')}</Alert>}
				{account.can_publish && <TextField select label={label('发布归属','Publisher')} size="small" value={organization ?? ''} disabled={busy}
					slotProps={{inputLabel:{shrink:true},select:{displayEmpty:true}}} onChange={e=>{setOrganization(Number(e.target.value)||null);setNotice('');}}>
					<MenuItem value="">{label('个人作品','Personal project')}</MenuItem>
					{account.organizations.map(org=><MenuItem key={org.id} value={org.id}>{org.name}</MenuItem>)}
				</TextField>}
				<Stack direction="row" spacing={1} useFlexGap flexWrap="wrap" alignItems="center">
					<Button component="a" href="https://atompie.osgame.org/my-assets?view=mine" target={native ? '_self' : '_blank'}
						rel="noopener noreferrer" size="small" endIcon={<OpenInNewOutlined />}>{label('我的稿件','My submissions')}</Button>
				</Stack>
				<Stack direction="row" spacing={1} flexWrap="wrap" useFlexGap>
					<Button variant="outlined" disabled={checking || busy || loading || !canSave || !!draft?.review} onClick={()=>void perform('save')}>{label('保存原子派草稿','Save AtomPie draft')}</Button>
					<Button variant="contained" disabled={checking || busy || loading || !account.can_publish || (!ready && !draft?.review)} onClick={()=>setConfirm(true)}>
						{draft?.review ? label('重试送审','Retry submission') : language==='zh' ? label('提交中文稿审核','Submit Chinese for review') : label('提交英文稿审核','Submit English for review')}
					</Button>
				</Stack>
			</>}
			{notice && <Typography role="status" variant="body2">{notice}</Typography>}
			{error && <Alert severity="error" onClose={()=>setError('')}>{error}</Alert>}
		</Stack>
		<Dialog open={confirm} onClose={()=>setConfirm(false)}>
			<DialogTitle>{label('确认提交审核','Submit for review?')}</DialogTitle>
			<DialogContent>{data.title} · {language==='zh'?'中文':'English'} · {account?.organizations.find(org=>org.id===organization)?.name || account?.full_name || account?.email}</DialogContent>
			<DialogActions><Button onClick={()=>setConfirm(false)}>{label('返回编辑','Keep editing')}</Button>
				<Button variant="contained" onClick={()=>void perform('submit')}>{label('确认送审','Confirm submission')}</Button></DialogActions>
		</Dialog>
	</Paper>;
}
