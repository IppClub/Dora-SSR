import { Container } from '@mui/material';
import { UploadProps } from 'antd';
import { message, Upload } from 'antd';
import { AiOutlineUpload } from 'react-icons/ai';

const { Dragger } = Upload;

export interface DoraUploadProp {
	title: string;
	path: string;
};

const DoraUpload = (prop: DoraUploadProp) => {
	const props: UploadProps = {
		name: 'file',
		multiple: true,
		action: `/upload?path=${prop.path}`,
		onChange(info) {
			const { status } = info.file;
			if (status !== 'uploading') {
				console.log(info.file, info.fileList);
			}
			if (status === 'done') {
				message.success(`${info.file.name} file uploaded successfully.`);
			} else if (status === 'error') {
				message.error(`${info.file.name} file upload failed.`);
			}
		},
		onDrop(e) {
			console.log('Dropped files', e.dataTransfer.files);
		},
	};
	return (
		<Container maxWidth="sm">
			<p className="dora-upload-title" style={{color: '#fff'}}>
				{prop.title}
			</p>
			<Dragger {...props}>
				<p className="dora-upload-drag-icon" style={{color: '#fff'}}>
					<AiOutlineUpload style={{fontSize: '40px'}}/>
				</p>
				<p className="dora-upload-text" style={{color: '#fff'}}>
					Click or drag files to this area to upload
				</p>
				<p className="dora-upload-hint" style={{color: '#fff8'}}>
					Uploading will start automatically.
				</p>
			</Dragger>
		</Container>
	);
};

export default DoraUpload;