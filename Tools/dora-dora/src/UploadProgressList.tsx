/* Copyright (c) 2026 Li Jin <dragon-fly@qq.com>
 * SPDX-License-Identifier: MIT */
import { memo, useState } from 'react';
import { CheckCircleOutlined, CloseCircleOutlined, LoadingOutlined, UploadOutlined } from '@ant-design/icons';
import { Progress } from 'antd';
import { useTranslation } from 'react-i18next';
import { Color } from './Theme';
import type { UploadPhase } from './UploadFile';

export interface UploadProgressFile {
	uid: string;
	name: string;
	status: 'uploading' | 'done' | 'error';
	percent: number;
	phase?: UploadPhase;
}

const ROW_HEIGHT = 64;
const VISIBLE_ROWS = 5;
const OVERSCAN = 2;

const UploadProgressRow = memo(({ file, index, total }: { file: UploadProgressFile; index: number; total: number }) => {
	const { t } = useTranslation();
	const uploading = file.status === 'uploading';
	return <div role="listitem" aria-posinset={index + 1} aria-setsize={total} style={{
		position: 'absolute', top: index * ROW_HEIGHT, height: ROW_HEIGHT, width: '100%',
		boxSizing: 'border-box', padding: '8px 0', borderBottom: `1px solid ${Color.Line}`,
	}}>
		<div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 6 }}>
			{file.status === 'done' ? <CheckCircleOutlined style={{ color: '#52c41a' }} />
				: file.status === 'error' ? <CloseCircleOutlined style={{ color: '#ff4d4f' }} />
					: file.phase ? <LoadingOutlined style={{ color: Color.Primary }} /> : <UploadOutlined />}
			{/* CSS ellipsis avoids measuring every filename on each progress update. */}
			<span title={file.name} style={{
				flex: 1, minWidth: 0, overflow: 'hidden', whiteSpace: 'nowrap',
				textOverflow: 'ellipsis', color: Color.TextPrimary, fontSize: 13,
			}}>{file.name}{uploading && file.phase ? ` · ${t(`upload.${file.phase}`)}` : ''}</span>
			{uploading && <span style={{ color: Color.TextSecondary, fontSize: 12 }}>{Math.round(file.percent)}%</span>}
		</div>
		{uploading && <Progress percent={Math.round(file.percent)} status={file.phase ? 'active' : 'normal'}
			strokeColor={Color.Primary} showInfo={false} size="small" />}
	</div>;
});

// Keep every file in the queue, but mount only the rows near the viewport.
const UploadProgressList = memo(({ files }: { files: UploadProgressFile[] }) => {
	const { t } = useTranslation();
	const [scrollTop, setScrollTop] = useState(0);
	const visibleStart = Math.min(Math.floor(scrollTop / ROW_HEIGHT), Math.max(0, files.length - VISIBLE_ROWS));
	const start = Math.max(0, visibleStart - OVERSCAN);
	const end = Math.min(files.length, visibleStart + VISIBLE_ROWS + OVERSCAN);
	return <div className="dora-upload-progress-list" role="list" aria-label={t('upload.uploadingFiles')} tabIndex={0}
		onScroll={event => setScrollTop(event.currentTarget.scrollTop)} style={{
			height: Math.min(files.length, VISIBLE_ROWS) * ROW_HEIGHT, overflowY: 'auto',
			overflowAnchor: 'none', position: 'relative',
		}}>
		<div style={{ height: files.length * ROW_HEIGHT, position: 'relative' }}>
			{files.slice(start, end).map((file, offset) =>
				<UploadProgressRow key={file.uid} file={file} index={start + offset} total={files.length} />)}
		</div>
	</div>;
});

export default UploadProgressList;
