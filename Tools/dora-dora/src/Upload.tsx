/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import { Box, Container } from '@mui/material';
import { ConfigProvider, theme, UploadProps } from 'antd';
import { AiOutlineUpload } from 'react-icons/ai';
import * as Service from './Service';
import { useTranslation } from 'react-i18next';
import { UploadOutlined, DownloadOutlined, LinkOutlined, FileTextOutlined } from '@ant-design/icons';
import { Button, App, Upload, Input, Progress, Space, Typography, Collapse } from 'antd';
import type { RcFile, UploadFile } from 'antd/es/upload/interface';
import { memo, useState, useEffect, useCallback, useRef } from 'react';
import { Color } from './Theme';
import Info from './Info';
import { checkUploadSize, uploadFile, UploadError, type UploadPhase } from './UploadFile';
import UploadProgressList, { type UploadProgressFile } from './UploadProgressList';
import { FolderUploadQueue } from './FolderUploadQueue';

const { Dragger } = Upload;
const { TextArea } = Input;
const { Text } = Typography;

export interface DoraUploadProp {
	title: string;
	path: string;
	onUploaded: (path: string, file: string, open: boolean) => void;
	hideTitle?: boolean;
};

interface FolderUploadJob {
	uid: string;
	file: File;
	name: string;
	path: string;
}

const DoraUploadInner = (prop: DoraUploadProp) => {
	const { t } = useTranslation();
	const { message, notification } = App.useApp();

	// 下载相关状态
	const [downloadUrl, setDownloadUrl] = useState('');
	const [downloadFileName, setDownloadFileName] = useState('');
	const [downloadStatus, setDownloadStatus] = useState<'idle' | 'downloading' | 'completed' | 'failed'>('idle');
	const [downloadProgress, setDownloadProgress] = useState(0);
	const [downloadError, setDownloadError] = useState('');

	// 下载监听器
	useEffect(() => {
		const handleDownload = (url: string, status: 'downloading' | 'completed' | 'failed', progress: number) => {
			if (url === downloadUrl) {
				setDownloadStatus(status);
				setDownloadProgress(progress);
				if (status === 'completed') {
					message.success(t('download.completed'));
					// 下载完成后刷新文件列表
					prop.onUploaded(prop.path, downloadFileName, true);
				} else if (status === 'failed') {
					setDownloadError(t('download.failed'));
					message.error(t('download.failed'));
				}
			}
		};

		Service.addDownloadListener(handleDownload);
		return () => Service.removeDownloadListener(handleDownload);
	}, [downloadUrl, downloadFileName, prop, message, t]);

	// 从URL提取文件名
	const extractFileNameFromUrl = useCallback((url: string) => {
		try {
			const urlObj = new URL(url);
			const pathname = urlObj.pathname;
			const fileName = pathname.split('/').pop() || 'downloaded_file';
			return fileName;
		} catch (_error) {
			return 'downloaded_file';
		}
	}, []);

	// 处理URL输入变化
	const handleUrlChange = (e: React.ChangeEvent<HTMLTextAreaElement>) => {
		const url = e.target.value;
		setDownloadUrl(url);
		if (url) {
			const fileName = extractFileNameFromUrl(url);
			setDownloadFileName(fileName);
		}
	};

	// 开始下载
	const handleStartDownload = async () => {
		if (!downloadUrl.trim()) {
			message.error(t('download.urlRequired'));
			return;
		}
		if (!downloadFileName.trim()) {
			message.error(t('download.fileNameRequired'));
			return;
		}

		try {
			setDownloadStatus('downloading');
			setDownloadProgress(0);
			setDownloadError('');

			const response = await Service.download({
				url: downloadUrl.trim(),
				target: `${prop.path}/${downloadFileName.trim()}`
			});

			if (response.success) {
				message.success(t('download.startDownload'));
			} else {
				setDownloadStatus('failed');
				setDownloadError(t('download.startFailed'));
				message.error(t('download.startFailed'));
			}
		} catch (_error) {
			setDownloadStatus('failed');
			setDownloadError(t('download.startFailed'));
			message.error(t('download.startFailed'));
		}
	};

	// 重置下载状态
	const resetDownload = () => {
		setDownloadUrl('');
		setDownloadFileName('');
		setDownloadStatus('idle');
		setDownloadProgress(0);
		setDownloadError('');
	};

	const reportUploadError = useCallback((error: unknown, name: string) => {
		const failure = error instanceof UploadError ? error : new UploadError(name, 'unexpectedError');
		notification.error({
			title: t('upload.failed'),
			description: `${failure.fileName ? failure.fileName + ': ' : ''}${t(`upload.${failure.reason}`, { status: failure.status })}`,
			duration: 0,
			placement: 'top',
		});
	}, [notification, t]);
	const acceptUploadSize = (file: RcFile) => {
		try { checkUploadSize(file); return true; }
		catch (error) { reportUploadError(error, file.name); return false; }
	};

	const folderQueueRef = useRef<FolderUploadQueue<FolderUploadJob> | null>(null);
	const folderCallbacksRef = useRef({ onUploaded: prop.onUploaded, reportError: reportUploadError });
	useEffect(() => {
		folderCallbacksRef.current = { onUploaded: prop.onUploaded, reportError: reportUploadError };
	}, [prop.onUploaded, reportUploadError]);

	useEffect(() => {
		const finish = (job: FolderUploadJob, status: 'done' | 'error') => {
			const entry = draggerFilesRef.current.get(job.uid);
			if (!entry) return;
			draggerFilesRef.current.set(job.uid, { ...entry, status, percent: status === 'done' ? 100 : entry.percent });
			draggerExpiryRef.current.set(job.uid, Date.now() + (status === 'done' ? 2000 : 3000));
			draggerDirtyRef.current = true;
		};
		const queue = new FolderUploadQueue<FolderUploadJob>({
			admit(job) {
				if (job.file.name === '.DS_Store') return false;
				job.name = job.file.webkitRelativePath || job.file.name;
				draggerFilesRef.current.set(job.uid, { uid: job.uid, name: job.name, status: 'uploading', percent: 0 });
				draggerDirtyRef.current = true;
			},
			async upload(job, signal) {
				// Only active uploads need a renamed File, a promise and progress callbacks.
				const file = new File([job.file], job.name);
				const action = Service.addr(`/upload?path=${encodeURIComponent(job.path)}&name=${encodeURIComponent(job.name)}`);
				await uploadFile(action, file, signal, (percent, phase) => {
					const entry = draggerFilesRef.current.get(job.uid);
					if (entry && (entry.percent !== percent || entry.phase !== phase)) {
						draggerFilesRef.current.set(job.uid, { ...entry, percent, phase });
						draggerDirtyRef.current = true;
					}
				});
				if (signal.aborted) return;
				finish(job, 'done');
				folderCallbacksRef.current.onUploaded(job.path, job.name, false);
			},
			error(job, error) {
				finish(job, 'error');
				folderCallbacksRef.current.reportError(error, job.name);
			},
		});
		folderQueueRef.current = queue;
		return () => {
			queue.dispose();
			if (folderQueueRef.current === queue) folderQueueRef.current = null;
		};
	}, []);

	const props: UploadProps = {
		name: 'file', directory: true, multiple: true, showUploadList: false,
		beforeUpload(file: RcFile) {
			// Read names/relative paths in admission batches; File.size is validated
			// by uploadFile in a worker. Selecting a folder only queues references.
			folderQueueRef.current?.enqueue({ uid: file.uid, file, name: '', path: prop.path });
			// The picker must not create an antd-managed list or a request per queued file.
			return Upload.LIST_IGNORE;
		},
	};
	const [fileList, setFileList] = useState<UploadFile[]>([]);
	const [uploading, setUploading] = useState(false);
	const [uploadProgress, setUploadProgress] = useState({ percent: 0, phase: 'hashing' as UploadPhase });

	// 文本创建文件相关状态
	const [textContent, setTextContent] = useState('');
	const [textFileName, setTextFileName] = useState('');
	const [textCreating, setTextCreating] = useState(false);

	const [draggerFileList, setDraggerFileList] = useState<UploadProgressFile[]>([]);
	const draggerFilesRef = useRef(new Map<string, UploadProgressFile>());
	const draggerExpiryRef = useRef(new Map<string, number>());
	const draggerDirtyRef = useRef(false);

	// Coalesce a folder's start/progress/completion events into at most 5 renders/s.
	// The same timer retires completed rows instead of scheduling one per file.
	useEffect(() => {
		const interval = setInterval(() => {
			const now = Date.now();
			for (const [uid, expiry] of draggerExpiryRef.current) {
				if (expiry > now) continue;
				draggerFilesRef.current.delete(uid);
				draggerExpiryRef.current.delete(uid);
				draggerDirtyRef.current = true;
			}
			if (!draggerDirtyRef.current) return;
			draggerDirtyRef.current = false;
			setDraggerFileList([...draggerFilesRef.current.values()]);
		}, 200);
		return () => clearInterval(interval);
	}, []);

	const handleUpload = async () => {
		setUploading(true);
		try {
			// Send sequentially: the server admits two disk uploads at a time.
			// Remove each success immediately so a retry sends only pending files.
			for (const selectedFile of fileList) {
				const file = selectedFile as RcFile;
				const uploadPath = Service.addr(`/upload?path=${encodeURIComponent(prop.path)}&name=${encodeURIComponent(file.name)}`);
				await uploadFile(uploadPath, file, undefined, (percent, phase) => setUploadProgress({ percent, phase }));
				prop.onUploaded(prop.path, file.name, false);
				setFileList(prev => prev.filter(item => item.uid !== file.uid));
			}
			message.success(t('upload.success'));
		} catch (error) {
			reportUploadError(error, '');
		} finally {
			setUploading(false);
		}
	};

	const uprops: UploadProps = {
		onRemove: (file) => {
			const index = fileList.indexOf(file);
			const newFileList = fileList.slice();
			newFileList.splice(index, 1);
			setFileList(newFileList);
		},
		beforeUpload: (file) => {
			if (!acceptUploadSize(file)) return Upload.LIST_IGNORE;
			setFileList(prev => [...prev, file]);
			return false;
		},
		fileList,
	};

	// 处理文本创建文件
	const handleCreateTextFile = async () => {
		if (!textContent.trim()) {
			message.error(t('upload.textContentRequired'));
			return;
		}
		if (!textFileName.trim()) {
			message.error(t('upload.textFileNameRequired'));
			return;
		}

		try {
			setTextCreating(true);
			const result = await Service.newFile({
				path: Info.path.join(prop.path, textFileName),
				content: textContent,
				folder: false,
			});

			if (result.success) {
				prop.onUploaded(prop.path, textFileName, true);
				message.success(t('upload.textFileCreated'));
				// 清空输入
				setTextContent('');
				setTextFileName('');
			} else {
				message.error(t('upload.textFileCreationFailed'));
			}
		} catch (_error) {
			message.error(t('upload.textFileCreationFailed'));
		} finally {
			setTextCreating(false);
		}
	};

	return (
		<Container maxWidth="md">
			{prop.hideTitle ? null : (
				<p className="dora-upload-title" style={{ color: Color.TextPrimary }}>
					{prop.title}
				</p>
			)}
			<Box sx={{ mb: 2.5 }}>
				<Typography.Title level={4} style={{ color: Color.TextPrimary, margin: 0, fontWeight: 600 }}>
					{t("upload.addFilesTitle")}
				</Typography.Title>
				<Text type="secondary">
					{t("upload.addFilesDescription")}
				</Text>
			</Box>

			{/* 本地文件上传区域 */}
			<Collapse
				defaultActiveKey='1'
				accordion
				expandIconPlacement="end"
				style={{
					marginBottom: 20,
					backgroundColor: Color.BackgroundDark,
					borderColor: Color.Line,
					borderRadius: 10,
					overflow: "hidden",
				}}
				items={[
					{
						key: '1',
						label: (
							<Space>
								<UploadOutlined />
								{t('upload.localFiles')}
							</Space>
						),
						children: (
							<Space orientation="vertical" size={16} style={{ width: '100%' }}>
								<Dragger {...props} style={{ minHeight: 220, backgroundColor: Color.Background }}>
									<p className="dora-upload-drag-icon" style={{ color: Color.Theme, marginBottom: 14 }}>
										<AiOutlineUpload style={{ fontSize: '42px' }} />
									</p>
									<p className="dora-upload-text" style={{ color: Color.TextPrimary, fontSize: 16, fontWeight: 500, marginBottom: 8 }}>
										{t("upload.text")}
									</p>
									<p className="dora-upload-hint" style={{ color: Color.TextSecondary, marginBottom: 0 }}>
										{t("upload.hint")}
									</p>
								</Dragger>
								<Space wrap>
									<Upload {...uprops}>
										<Button type="primary" icon={<UploadOutlined />}>{t("upload.selectFile")}</Button>
									</Upload>
									{fileList.length > 0 ? (
										<Button
											onClick={handleUpload}
											loading={uploading}
										>
											{uploading ? `${t(`upload.${uploadProgress.phase}`)} ${uploadProgress.percent.toFixed(0)}%` : `${t('upload.startUpload')} (${fileList.length})`}
										</Button>
									) : null}
								</Space>

								{/* 上传文件列表展示 */}
								{draggerFileList.length > 0 && (
									<div style={{
										marginTop: 16,
										padding: 12,
										backgroundColor: Color.Background,
										border: `1px solid ${Color.Line}`,
										borderRadius: 6,
									}}>
										<Text type="secondary" style={{ display: 'block', marginBottom: 12, fontSize: 14 }}>
											{t('upload.uploadingFiles')} ({draggerFileList.length})
										</Text>
										<UploadProgressList files={draggerFileList} />
									</div>
								)}
							</Space>
						),
					},
					{
						key: '2',
						label: (
							<Space>
								<LinkOutlined />
								{t('download.networkResource')}
							</Space>
						),
						children: (
							<Space orientation="vertical" style={{ width: '100%' }}>
								<Text type="secondary">{t('download.url')}</Text>
								<TextArea
									placeholder={t('download.urlPlaceholder')}
									value={downloadUrl}
									onChange={handleUrlChange}
									rows={2}
								/>

								<Text type="secondary">{t('download.fileName')}</Text>
								<Input
									placeholder={t('download.fileNamePlaceholder')}
									value={downloadFileName}
									onChange={(e) => setDownloadFileName(e.target.value)}
								/>

								<Space>
									<Button
										type="primary"
										icon={<DownloadOutlined />}
										onClick={handleStartDownload}
										disabled={!downloadUrl.trim() || !downloadFileName.trim() || downloadStatus === 'downloading'}
										loading={downloadStatus === 'downloading'}
									>
										{downloadStatus === 'downloading' ? t('download.downloading') : t('download.startDownload')}
									</Button>
									<Button onClick={resetDownload} disabled={downloadStatus === 'downloading'}>
										{t('download.reset')}
									</Button>
								</Space>

								{/* 下载进度和状态显示 */}
								{downloadStatus !== 'idle' && (
									<div>
										<Text type="secondary">{t('download.status')}: </Text>
										<Text type={downloadStatus === 'completed' ? 'success' : downloadStatus === 'failed' ? 'danger' : undefined}>
											{t(`download.${downloadStatus}`)}
										</Text>

										{downloadStatus === 'downloading' && (
											<Progress
												percent={Math.round(downloadProgress * 100)}
												status="active"
												style={{ marginTop: 8 }}
											/>
										)}

										{downloadStatus === 'failed' && downloadError && (
											<Text type="danger" style={{ display: 'block', marginTop: 8 }}>
												{t('download.error')}: {downloadError}
											</Text>
										)}
									</div>
								)}
							</Space>
						),
					},
					{
						key: '3',
						label: (
							<Space>
								<FileTextOutlined />
								{t('upload.createTextFile')}
							</Space>
						),
						children: (
							<Space orientation="vertical" style={{ width: '100%' }}>
								<div>
									<Text type="secondary" style={{ display: 'block', marginBottom: 8 }}>
										{t('upload.fileName')}:
									</Text>
									<Input
										placeholder={t('upload.fileNamePlaceholder')}
										value={textFileName}
										onChange={(e) => setTextFileName(e.target.value)}
										style={{ marginBottom: 16 }}
									/>
								</div>

								<div>
									<Text type="secondary" style={{ display: 'block', marginBottom: 8 }}>
										{t('upload.textContent')}:
									</Text>
									<TextArea
										placeholder={t('upload.textContentPlaceholder')}
										value={textContent}
										onChange={(e) => setTextContent(e.target.value)}
										rows={6}
										style={{ marginBottom: 16 }}
									/>
								</div>

								<Button
									type="primary"
									onClick={handleCreateTextFile}
									loading={textCreating}
									disabled={!textContent.trim() || !textFileName.trim()}
									icon={<FileTextOutlined />}
								>
									{textCreating ? t('upload.creating') : t('upload.createFile')}
								</Button>
							</Space>
						),
					},
				]}
			/>
		</Container>
	);
};

const DoraUpload = memo((prop: DoraUploadProp) => {
	return (
		<ConfigProvider
			theme={{
				algorithm: theme.darkAlgorithm,
				token: {
					colorPrimary: Color.Theme,
					colorPrimaryHover: "#ffd15f",
					colorTextLightSolid: Color.BackgroundDark,
					colorBgContainer: Color.Background,
					borderRadius: 8,
				},
				components: {
					Input: {
						activeBorderColor: Color.Primary,
						hoverBorderColor: Color.Primary,
					},
				},
			}}
		>
			<App>
				<DoraUploadInner {...prop} />
			</App>
		</ConfigProvider>
	);
});

export default DoraUpload;
