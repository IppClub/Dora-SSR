/* Copyright (c) 2024 Li Jin, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import { Container } from '@mui/material';
import { ConfigProvider, theme, UploadProps } from 'antd';
import { AiOutlineUpload } from 'react-icons/ai';
import { addr } from './Service';
import { useTranslation } from 'react-i18next';
import { UploadOutlined } from '@ant-design/icons';
import { Button, App, Upload } from 'antd';
import type { RcFile, UploadFile } from 'antd/es/upload/interface';
import { useState } from 'react';
import { Color } from './Frame';

const { Dragger } = Upload;

export interface DoraUploadProp {
	title: string;
	path: string;
	onUploaded: (path: string, file: string) => void;
};

const DoraUploadInner = (prop: DoraUploadProp) => {
	const { t } = useTranslation();
	const { message, notification } = App.useApp();
	const props: UploadProps = {
		name: 'file',
		directory: true,
		multiple: true,
		action: addr(`/upload?path=${prop.path}`),
		beforeUpload(file: RcFile, fileList: RcFile[]) {
			if (fileList.length > 100) {
				notification.error({
					key: "upload-exceeded-error",
					message: t('upload.exceeded'),
					placement: "top"
				});
				return Upload.LIST_IGNORE;
			}
			if (file.name === ".DS_Store") {
				return Upload.LIST_IGNORE;
			}
			return new File([file], file.webkitRelativePath !== "" ? file.webkitRelativePath : file.name);
		},
		onChange(info) {
			const { status } = info.file;
			if (status === 'done') {
				prop.onUploaded(prop.path, info.file.name);
			}
		},
	};
	const [fileList, setFileList] = useState<UploadFile[]>([]);
	const [uploading, setUploading] = useState(false);

	const handleUpload = () => {
		const formData = new FormData();
		fileList.forEach(file => {
			formData.append('file', file as RcFile);
		});
		setUploading(true);
		fetch(addr(`/upload?path=${prop.path}`), {
			method: 'POST',
			body: formData,
		})
		.then(() => {
			fileList.forEach(file => {
				const f = file as RcFile;
				prop.onUploaded(prop.path, f.name);
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
	return (
		<Container maxWidth="sm">
			<p className="dora-upload-title" style={{color: Color.TextPrimary}}>
				{prop.title}
			</p>
			<div style={{display: 'flex'}}>
				<Upload {...uprops} style={{display: 'inline-block'}}>
					<Button icon={<UploadOutlined/>}>{t("upload.selectFile")}</Button>
				</Upload>
				<Button
					onClick={handleUpload}
					disabled={fileList.length === 0}
					loading={uploading}
					style={{marginLeft: 10}}
				>
					{uploading ? t('upload.uploading') : t('upload.startUpload')}
				</Button>
			</div>
			<div style={{padding: 20}}/>
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
		</Container>
	);
};

const DoraUpload = (prop: DoraUploadProp) => {
	return (
		<ConfigProvider
			theme={{
				algorithm: theme.darkAlgorithm,
				token: {
					colorPrimary: Color.Theme,
					colorBgContainer: Color.Background
				}
			}}
		>
			<App>
				<DoraUploadInner {...prop}/>
			</App>
		</ConfigProvider>
	);
};

export default DoraUpload;