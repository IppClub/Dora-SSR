/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import { memo, useEffect, useRef, useState } from "react";
import * as Service from "./Service";
import { AlertColor } from "@mui/material";
import { useTranslation } from 'react-i18next';
import Info from './Info';
import { toUrlPath } from './PathUtils';
import { uploadFile } from './UploadFile';
import { Color } from './Theme';

export interface TIC80EditorProps {
	title: string;
	width: number;
	height: number;
	filePath: string;
	resPath: string;
	defaultValue?: string;
	onKeydown: (event: KeyboardEvent) => void;
	onDirty?: () => void;
	onSaved?: () => void;
	addAlert: (msg: string, type: AlertColor) => void;
};

type CartStatus = 'loading' | 'ready' | 'modified' | 'saving' | 'saved' | 'loadFailed' | 'saveFailed';

const TIC80Editor = memo((props: TIC80EditorProps) => {
	const { t } = useTranslation();
	const iframeRef = useRef<HTMLIFrameElement>(null);
	const propsRef = useRef(props);
	const cleanupRef = useRef<(() => void) | null>(null);
	const dirtyRevisionRef = useRef(0);
	const saveQueueRef = useRef(Promise.resolve());
	const [status, setStatus] = useState<CartStatus>('loading');
	const [reload, setReload] = useState(0);
	const saveRequestRef = useRef(0);
	useEffect(() => { propsRef.current = props; }, [props]);
	useEffect(() => () => { cleanupRef.current?.(); }, []);
	useEffect(() => {
		iframeRef.current?.contentWindow?.postMessage({ type: 'TIC80_INIT', filePath: props.filePath }, window.location.origin);
	}, [props.filePath]);
	const basename = Info.path.basename(props.filePath);
	return <div style={{ width: props.width, height: props.height, display: 'flex', flexDirection: 'column', minHeight: 0 }}>
		<div role="note" style={{ padding: '6px 10px', fontSize: 12, color: Color.TextSecondary, background: Color.BackgroundDark, borderBottom: `1px solid ${Color.Line}` }}>
			<span>{basename} · {t('tic.workflow')}</span>
			<span role="status" aria-live="polite" style={{ marginLeft: 12, color: status === 'loadFailed' || status === 'saveFailed' ? Color.Error : undefined }}>{t(`tic.status.${status}`)}</span>
			{status === 'loadFailed' && <button onClick={() => { cleanupRef.current?.(); setStatus('loading'); setReload(value => value + 1); }} style={{ marginLeft: 12, background: 'transparent', color: 'inherit', border: `1px solid ${Color.Line}`, cursor: 'pointer', outline: 'none' }}>{t('tic.retryLoad')}</button>}
		</div>
		<iframe key={reload} ref={iframeRef} width={props.width} height={props.height} title={props.title}
		onLoad={event => {
			const win = event.currentTarget.contentWindow;
			if (!win) return;
			const doc = win.document;
			let active = true;
			const updateStatus = (value: CartStatus) => { if (active) setStatus(value); };
			const markDirty = () => {
				dirtyRevisionRef.current++;
				propsRef.current.onDirty?.();
				if (active) setStatus(value => ['loading', 'loadFailed', 'saveFailed', 'saving'].includes(value) ? value : 'modified');
			};
			const reply = (data: object) => {
				if (active && iframeRef.current?.contentWindow === win) win.postMessage(data, window.location.origin);
			};
			const handleMessage = async (message: MessageEvent) => {
				if (message.source !== win || message.origin !== window.location.origin) return;
				const current = propsRef.current;
				const requestId = message.data?.requestId;
				switch (message.data?.type) {
					case 'TIC80_LOADED':
						updateStatus('ready');
						break;
					case 'TIC80_LOAD_FAILED':
						updateStatus('loadFailed');
						current.addAlert(t('tic.loadFailed', { filename: Info.path.basename(current.filePath) }), 'error');
						break;
					case 'TIC80_READ_FILE':
						try {
							const resource = toUrlPath(current.resPath, Info.path).split('/').map(encodeURIComponent).join('/');
							const response = await fetch(Service.addr('/' + resource), { cache: 'no-store' });
							if (!response.ok) throw new Error(`HTTP ${response.status}`);
							const rom = new Uint8Array(await response.arrayBuffer());
							if (rom.length === 0) throw new Error('Empty cartridge');
							reply({ type: 'TIC80_READ_FILE_RESPONSE', requestId, success: true, rom });
						} catch (error) {
							console.error('Error loading TIC-80 cartridge:', error);
							updateStatus('loadFailed');
							reply({ type: 'TIC80_READ_FILE_RESPONSE', requestId, success: false });
							current.addAlert(t('tic.loadFailed', { filename: Info.path.basename(current.filePath) }), 'error');
						}
						break;
					case 'TIC80_WRITE_FILE': {
						const savingRevision = dirtyRevisionRef.current;
						const blob = message.data.rom;
						const saveRequest = ++saveRequestRef.current;
						updateStatus('saving');
						// Keep repeated saves ordered, and allow an explicitly requested write
						// to finish even if the editor tab closes while the request is pending.
						saveQueueRef.current = saveQueueRef.current.then(async () => {
							const basename = Info.path.basename(current.filePath);
							try {
								if (!(blob instanceof Blob) || blob.size === 0) throw new Error('Invalid cartridge');
								const directory = Info.path.dirname(current.filePath);
								await uploadFile(Service.addr(`/upload?path=${encodeURIComponent(directory)}&name=${encodeURIComponent(basename)}`), new File([blob], basename));
								if (dirtyRevisionRef.current === savingRevision) current.onSaved?.();
								if (saveRequest === saveRequestRef.current) updateStatus(dirtyRevisionRef.current === savingRevision ? 'saved' : 'modified');
								reply({ type: 'TIC80_WRITE_FILE_RESPONSE', requestId, success: true });
								current.addAlert(t('tic.updated', { filename: basename }), 'success');
							} catch (error) {
								console.error('Error saving TIC-80 cartridge:', error);
								if (saveRequest === saveRequestRef.current) updateStatus('saveFailed');
								reply({ type: 'TIC80_WRITE_FILE_RESPONSE', requestId, success: false });
								current.addAlert(t('tic.updateFailed', { basename }), 'error');
							}
						});
						break;
					}
				}
			};
			const handleKeydown = (event: KeyboardEvent) => {
				const command = event.ctrlKey || event.metaKey;
				if ((!command && !event.altKey && (event.key.length === 1 || ['Backspace', 'Delete', 'Enter'].includes(event.key))) || (command && ['x', 'v', 'z', 'y'].includes(event.key.toLowerCase()))) markDirty();
				if ((event.ctrlKey || event.altKey || event.metaKey) && ['n', 'w'].includes(event.key.toLowerCase())) {
					event.preventDefault();
					propsRef.current.onKeydown(event);
				}
			};
			const handlePointerDown = () => { markDirty(); };
			cleanupRef.current?.();
			window.addEventListener('message', handleMessage);
			doc.addEventListener('keydown', handleKeydown);
			doc.addEventListener('pointerdown', handlePointerDown);
			cleanupRef.current = () => {
				active = false;
				window.removeEventListener('message', handleMessage);
				doc.removeEventListener('keydown', handleKeydown);
				doc.removeEventListener('pointerdown', handlePointerDown);
			};
			reply({ type: 'TIC80_INIT', filePath: propsRef.current.filePath, defaultValue: propsRef.current.defaultValue });
		}}
		src="tic80/index.html" style={{ border: 'none', overflowY: 'hidden', flex: 1, minHeight: 0, outline: 'none' }} />
	</div>;
});

export default TIC80Editor;
