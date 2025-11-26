/* Copyright (c) 2017-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import { Container } from '@mui/material';
import { ConfigProvider, theme, UploadProps } from 'antd';
import { AiOutlineUpload } from 'react-icons/ai';
import * as Service from './Service';
import { useTranslation } from 'react-i18next';
import { UploadOutlined, DownloadOutlined, LinkOutlined, FileTextOutlined, CheckCircleOutlined, CloseCircleOutlined, LoadingOutlined } from '@ant-design/icons';
import { Button, App, Upload, Input, Progress, Space, Typography, Collapse } from 'antd';
import type { RcFile, UploadFile } from 'antd/es/upload/interface';
import { memo, useState, useEffect, useCallback, useRef } from 'react';
import { Color } from './Frame';
import Info from './Info';

const { Dragger } = Upload;
const { TextArea } = Input;
const { Text } = Typography;

export interface DoraUploadProp {
	title: string;
	path: string;
	onUploaded: (path: string, file: string, open: boolean) => void;
};

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

	const props: UploadProps = {
		name: 'file',
		directory: true,
		multiple: true,
		showUploadList: false,
		action: Service.addr(`/upload?path=${prop.path}`),
		beforeUpload(file: RcFile, fileList: RcFile[]) {
			if (fileList.length > 501) {
				notification.error({
					title: t('upload.exceeded'),
					key: "upload-exceeded-error",
					message: t('upload.failed'),
					placement: "top"
				});
				return Upload.LIST_IGNORE;
			}

			if (file.name === ".DS_Store") {
				return Upload.LIST_IGNORE;
			}

			// 添加到上传文件列表（使用文件名作为临时标识，antd 会在 onChange 中分配 uid）
			const processedFile = new File([file], file.webkitRelativePath !== "" ? file.webkitRelativePath : file.name);
			const fileName = processedFile.name;

			setDraggerFileList(prevList => {
				// 检查是否已存在同名且正在上传的文件（避免重复添加）
				const existingFile = prevList.find(f => f.name === fileName && f.status === 'uploading');
				if (existingFile) {
					return prevList;
				}
				const tempUid = `temp-${Date.now()}-${Math.random()}-${fileName}`;
				return [...prevList, {
					uid: tempUid,
					name: fileName,
					status: 'uploading',
					percent: 0,
				}];
			});

			return processedFile;
		},
		onChange(info) {
			const { status, percent, uid, name } = info.file;

			// 更新进度缓存（使用 antd 分配的 uid）
			if (percent !== undefined && uid) {
				draggerProgressCacheRef.current.set(uid, percent);
			}

			// 更新文件状态
			setDraggerFileList(prevList => {
				// 先尝试通过 uid 匹配（如果之前已经更新过）
				let fileIndex = prevList.findIndex(f => f.uid === uid);
				// 如果没找到，通过文件名和上传状态匹配（临时文件）
				if (fileIndex === -1) {
					fileIndex = prevList.findIndex(f => f.name === name && f.status === 'uploading' && f.uid.startsWith('temp-'));
				}

				// 如果找不到匹配的文件，说明 beforeUpload 中已经添加了，这里不应该再添加
				// 只有在 beforeUpload 没有添加的情况下才添加（这种情况不应该发生）
				if (fileIndex === -1) {
					return prevList;
				}

				const updatedList = [...prevList];
				if (status === 'done') {
					updatedList[fileIndex] = {
						...updatedList[fileIndex],
						uid: uid, // 更新为 antd 的 uid
						status: 'done',
						percent: 100,
					};
					draggerProgressCacheRef.current.set(uid, 100);
					draggerDisplayProgressRef.current.set(uid, 100);
					// 完成后延迟移除
					setTimeout(() => {
						setDraggerFileList(prev => prev.filter(f => f.uid !== uid));
						draggerProgressCacheRef.current.delete(uid);
						draggerDisplayProgressRef.current.delete(uid);
					}, 2000);
					prop.onUploaded(prop.path, name, false);
				} else if (status === 'error') {
					updatedList[fileIndex] = {
						...updatedList[fileIndex],
						uid: uid,
						status: 'error',
					};
					// 错误后延迟移除
					setTimeout(() => {
						setDraggerFileList(prev => prev.filter(f => f.uid !== uid));
						if (uid) {
							draggerProgressCacheRef.current.delete(uid);
							draggerDisplayProgressRef.current.delete(uid);
						}
					}, 3000);
				} else if (status === 'uploading') {
					updatedList[fileIndex] = {
						...updatedList[fileIndex],
						uid: uid, // 更新为 antd 的 uid
						status: 'uploading',
					};
				}
				return updatedList;
			});
		},
	};
	const [fileList, setFileList] = useState<UploadFile[]>([]);
	const [uploading, setUploading] = useState(false);

	// 文本创建文件相关状态
	const [textContent, setTextContent] = useState('');
	const [textFileName, setTextFileName] = useState('');
	const [textCreating, setTextCreating] = useState(false);

	// Dragger 上传文件列表相关状态
	interface DraggerUploadFile {
		uid: string;
		name: string;
		status: 'uploading' | 'done' | 'error';
		percent: number;
	}
	const [draggerFileList, setDraggerFileList] = useState<DraggerUploadFile[]>([]);
	const draggerProgressCacheRef = useRef<Map<string, number>>(new Map());
	const draggerDisplayProgressRef = useRef<Map<string, number>>(new Map());

	// 定时更新显示进度（每0.2秒）
	useEffect(() => {
		const interval = setInterval(() => {
			setDraggerFileList(prevList => {
				let hasChanges = false;
				const updatedList = prevList.map(file => {
					// 只更新正在上传的文件
					if (file.status === 'uploading') {
						const cachedPercent = draggerProgressCacheRef.current.get(file.uid);
						if (cachedPercent !== undefined) {
							const currentDisplayPercent = draggerDisplayProgressRef.current.get(file.uid);
							if (cachedPercent !== currentDisplayPercent) {
								hasChanges = true;
								draggerDisplayProgressRef.current.set(file.uid, cachedPercent);
								return { ...file, percent: cachedPercent };
							}
						}
					}
					return file;
				});
				return hasChanges ? updatedList : prevList;
			});
		}, 200);

		return () => clearInterval(interval);
	}, []);

	const handleUpload = () => {
		const formData = new FormData();
		fileList.forEach(file => {
			formData.append('file', file as RcFile);
		});
		setUploading(true);
		fetch(Service.addr(`/upload?path=${prop.path}`), {
			method: 'POST',
			body: formData,
		})
		.then(() => {
			fileList.forEach(file => {
				const f = file as RcFile;
				prop.onUploaded(prop.path, f.name, false);
			});
			setFileList([]);
			message.success(t('upload.success'));
		})
		.catch(() => {
			message.error(t('upload.failed'));
		})
		.finally(() => {
			setUploading(false);
		});
	};

	const uprops: UploadProps = {
		onRemove: (file) => {
			const index = fileList.indexOf(file);
			const newFileList = fileList.slice();
			newFileList.splice(index, 1);
			setFileList(newFileList);
		},
		beforeUpload: (file) => {
			setFileList([...fileList, file]);
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
			<p className="dora-upload-title" style={{color: Color.TextPrimary}}>
				{prop.title}
			</p>

			{/* 本地文件上传区域 */}
			<Collapse
				defaultActiveKey='1'
				accordion
				expandIconPlacement="end"
				style={{ marginBottom: 20, backgroundColor: Color.Background, borderColor: Color.Line }}
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
							<Space orientation="vertical" style={{ width: '100%' }}>
								<Upload {...uprops} style={{marginBottom: 10}}>
									<Button icon={<UploadOutlined/>}>{t("upload.selectFile")}</Button>
								</Upload>
								<Button
									onClick={handleUpload}
									disabled={fileList.length === 0}
									loading={uploading}
								>
									{uploading ? t('upload.uploading') : t('upload.startUpload')}
								</Button>
								<div style={{padding: 10}}/>
								<Dragger {...props}>
									<p className="dora-upload-drag-icon" style={{color: Color.Primary}}>
										<AiOutlineUpload style={{fontSize: '40px'}}/>
									</p>
									<p className="dora-upload-text" style={{color: Color.TextPrimary}}>
										{t("upload.text")}
									</p>
									<p className="dora-upload-hint" style={{color: Color.TextSecondary}}>
										{t("upload.hint")}
									</p>
								</Dragger>

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
										<div>
											{draggerFileList.map((file, index) => (
												<div
													key={file.uid}
													style={{
														padding: '8px 0',
														borderBottom: index < draggerFileList.length - 1 ? `1px solid ${Color.Line}` : 'none',
													}}
												>
													<div style={{ width: '100%' }}>
														<div style={{
															display: 'flex',
															alignItems: 'center',
															justifyContent: 'space-between',
															marginBottom: 6,
														}}>
															<div style={{
																display: 'flex',
																alignItems: 'center',
																flex: 1,
																minWidth: 0,
															}}>
																{file.status === 'done' && (
																	<CheckCircleOutlined style={{
																		color: '#52c41a',
																		marginRight: 8,
																		fontSize: 16,
																	}} />
																)}
																{file.status === 'error' && (
																	<CloseCircleOutlined style={{
																		color: '#ff4d4f',
																		marginRight: 8,
																		fontSize: 16,
																	}} />
																)}
																{file.status === 'uploading' && (
																	<LoadingOutlined style={{
																		color: Color.Primary,
																		marginRight: 8,
																		fontSize: 16,
																	}} />
																)}
																<Text
																	ellipsis
																	style={{
																		color: Color.TextPrimary,
																		fontSize: 13,
																		flex: 1,
																		minWidth: 0,
																	}}
																	title={file.name}
																>
																	{file.name}
																</Text>
															</div>
															{file.status === 'uploading' && (
																<Text
																	type="secondary"
																	style={{
																		marginLeft: 12,
																		fontSize: 12,
																		minWidth: 45,
																		textAlign: 'right',
																	}}
																>
																	{Math.round(file.percent)}%
																</Text>
															)}
														</div>
														{file.status === 'uploading' && (
															<Progress
																percent={Math.round(file.percent)}
																status="active"
																strokeColor={Color.Primary}
																showInfo={false}
																size="small"
																style={{ marginTop: 4 }}
															/>
														)}
													</div>
												</div>
											))}
										</div>
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
							<Space direction="vertical" style={{ width: '100%' }}>
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
							<Space direction="vertical" style={{ width: '100%' }}>
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
					colorBgContainer: Color.Background,
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
				<DoraUploadInner {...prop}/>
			</App>
		</ConfigProvider>
	);
});

export default DoraUpload;