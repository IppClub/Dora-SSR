import { Container } from '@mui/material';
import { ConfigProvider, theme, UploadProps } from 'antd';
import { Upload } from 'antd';
import { AiOutlineUpload } from 'react-icons/ai';
import { Addr } from './Post';

const { Dragger } = Upload;

export interface DoraUploadProp {
	title: string;
	path: string;
	onUploaded: (path: string, file: string) => void;
};

const DoraUpload = (prop: DoraUploadProp) => {
	const props: UploadProps = {
		name: 'file',
		multiple: true,
		action: Addr(`/upload?path=${prop.path}`),
		onChange(info) {
			const { status } = info.file;
			if (status === 'done') {
				prop.onUploaded(prop.path, info.file.name);
			}
		},
	};
	return (
		<Container maxWidth="sm">
			<ConfigProvider
				theme={{
					algorithm: theme.darkAlgorithm
				}}
			>
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
			</ConfigProvider>
		</Container>
	);
};

export default DoraUpload;