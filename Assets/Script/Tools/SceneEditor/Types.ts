import { Buffer, Node } from 'Dora';

export type EditorMode = '2D' | 'Script';
export type SceneNodeKind = 'Root' | 'Node' | 'Sprite' | 'Label' | 'Camera';

export interface SceneNodeData {
	id: string;
	kind: SceneNodeKind;
	name: string;
	parentId?: string;
	children: string[];
	x: number;
	y: number;
	scaleX: number;
	scaleY: number;
	rotation: number;
	visible: boolean;
	texture: string;
	text: string;
	script: string;
	nameBuffer: Buffer.Type;
	textureBuffer: Buffer.Type;
	textBuffer: Buffer.Type;
	scriptBuffer: Buffer.Type;
}

export interface ViewportState {
	x: number;
	y: number;
	width: number;
	height: number;
}

export interface EditorState {
	nextId: number;
	selectedId: string;
	mode: EditorMode;
	zoom: number;
	showGrid: boolean;
	leftWidth: number;
	rightWidth: number;
	bottomHeight: number;
	status: string;
	console: string[];
	nodes: Record<string, SceneNodeData>;
	order: string[];
	preview: ViewportState;
	previewDirty: boolean;
	previewRoot?: Node.Type;
	previewContent?: Node.Type;
	runtimeNodes: Record<string, Node.Type>;
	runtimeLabels: Record<string, unknown>;
	assetImportBuffer: Buffer.Type;
	scriptPathBuffer: Buffer.Type;
	scriptContentBuffer: Buffer.Type;
	activeScriptNodeId?: string;
	selectedAsset: string;
	assets: string[];
}
