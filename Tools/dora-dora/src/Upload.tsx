import { Container } from '@mui/material';
import { ConfigProvider, theme, UploadProps } from 'antd';
import { AiOutlineUpload } from 'react-icons/ai';
import { addr } from './Service';
import { useTranslation } from 'react-i18next';
import { UploadOutlined } from '@ant-design/icons';
import { Button, message, Upload } from 'antd';
import type { RcFile, UploadFile } from 'antd/es/upload/interface';
import { useState } from 'react';

const { Dragger } = Upload;

export interface DoraUploadProp {
	title: string;
	path: string;
	onUploaded: (path: string, file: string) => void;
};

const DoraUpload = (prop: DoraUploadProp) => {
	const props: UploadProps = {
		name: 'file',
		directory: true,
		multiple: true,
		action: addr(`/upload?path=${prop.path}`),
		beforeUpload(file) {
			return new File([file], file.webkitRelativePath !== "" ? file.webkitRelativePath : file.name);
		},
		onChange(info) {
			const { status } = info.file;
			if (status === 'done') {
				prop.onUploaded(prop.path, info.file.name);
			}
		},
	};
	const {t} = useTranslation();
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
			<ConfigProvider
				theme={{
					algorithm: theme.darkAlgorithm,
					token: {
						colorPrimary: '#fbc400',
						colorBgContainer: '#3a3a3a'
					}
				}}
			>
			<p className="dora-upload-title" style={{color: '#fff'}}>
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
				<p className="dora-upload-drag-icon" style={{color: '#fff'}}>
					<AiOutlineUpload style={{fontSize: '40px'}}/>
				</p>
				<p className="dora-upload-text" style={{color: '#fff'}}>
					{t("upload.text")}
				</p>
				<p className="dora-upload-hint" style={{color: '#fff8'}}>
					{t("upload.hint")}
				</p>
			</Dragger>
			</ConfigProvider>
		</Container>
	);
};

export default DoraUpload;