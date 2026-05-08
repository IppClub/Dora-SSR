import React, {memo, useCallback, useEffect, useRef, useState} from "react";
import {
	ActionClipDocument,
	ActionDocument,
	ActionViewport,
	defaultActionViewport,
	getActionAnimationDuration,
	loadActionDocumentFromModelContent,
	parseLegacyClip,
	validateActionDocumentClips,
	writeLegacyModel,
} from "./index";
import * as Service from "../Service";
import ActionEditorCanvas from "./ActionEditorCanvas";
import type {ActionDocumentChangeOptions, ActionEditorMode} from "./ActionEditorCanvas";
import {chooseActionClipsDirectory, getActionAtlasPaths, getActionClipFiles, getActionClipsDirectories} from "./ActionPaths";
import {packActionClipsDirectory} from "./ActionAtlasPacker";

export type ActionEditorProps = {
	filePath: string;
	sourceContent: string;
	width: number;
	height: number;
	active: boolean;
	readOnly: boolean;
	onChange: (content: string) => void;
	onLoadFailed: (message: string) => void;
};

export type ActionAtlasImage = {
	path: string;
	image: HTMLImageElement;
	width: number;
	height: number;
	objectUrl: string;
};

const loadImageElement = (filePath: string, objectUrl: string): Promise<HTMLImageElement> => {
	return new Promise((resolve, reject) => {
		const image = new Image();
		image.onload = () => resolve(image);
		image.onerror = () => reject(new Error(`Failed to load atlas image: ${filePath}`));
		image.src = objectUrl;
	});
};

const loadAtlasImage = async (filePath: string): Promise<ActionAtlasImage> => {
	const response = await fetch(Service.addr(`/${filePath.replace(/\\/g, "/")}`));
	if (!response.ok) throw new Error(`Failed to load atlas image: ${filePath}`);
	const objectUrl = URL.createObjectURL(await response.blob());
	try {
		const image = await loadImageElement(filePath, objectUrl);
		return {
			path: filePath,
			image,
			width: image.naturalWidth || image.width,
			height: image.naturalHeight || image.height,
			objectUrl,
		};
	} catch (error) {
		URL.revokeObjectURL(objectUrl);
		throw error;
	}
};

export default memo(function ActionEditor(props: ActionEditorProps) {
	const {filePath, sourceContent, width, height, active, readOnly, onChange, onLoadFailed} = props;
	const fallbackKeyRef = useRef<string | null>(null);
	const selfEmittedKeyRef = useRef<string | null>(null);
	const processedSourceKeyRef = useRef(`${filePath}\n${sourceContent}`);
	const onChangeRef = useRef(onChange);
	const onLoadFailedRef = useRef(onLoadFailed);
	const [loadState, setLoadState] = useState(() => loadActionDocumentFromModelContent(sourceContent, filePath));
	const [clipsDirs, setClipsDirs] = useState<string[]>([]);
	const [clipFiles, setClipFiles] = useState<string[]>([]);
	const [selectedClipsDir, setSelectedClipsDir] = useState<string | undefined>(undefined);
	const [runtimeDiagnostics, setRuntimeDiagnostics] = useState<string[]>([]);
	const [clipDocument, setClipDocument] = useState<ActionClipDocument | null>(null);
	const [atlasImage, setAtlasImage] = useState<ActionAtlasImage | null>(null);
	const [clipDiagnostics, setClipDiagnostics] = useState<string[]>([]);
	const [packing, setPacking] = useState(false);
	const [selectedNodeId, setSelectedNodeId] = useState("root");
	const [editMode, setEditMode] = useState<ActionEditorMode>("pose");
	const [selectedLook, setSelectedLook] = useState<string | null>(null);
	const [selectedAnimation, setSelectedAnimation] = useState<string | null>(null);
	const [playbackTime, setPlaybackTime] = useState(0);
	const [playbackPlaying, setPlaybackPlaying] = useState(false);
	const [playbackLoop, setPlaybackLoop] = useState(true);
	const [viewport, setViewport] = useState<ActionViewport>(() => defaultActionViewport());
	const [undoStack, setUndoStack] = useState<ActionDocument[]>([]);
	const [redoStack, setRedoStack] = useState<ActionDocument[]>([]);

	useEffect(() => {
		onChangeRef.current = onChange;
		onLoadFailedRef.current = onLoadFailed;
	}, [onChange, onLoadFailed]);

	useEffect(() => {
		const sourceKey = `${filePath}\n${sourceContent}`;
		if (processedSourceKeyRef.current === sourceKey) {
			return;
		}
		if (selfEmittedKeyRef.current === sourceKey) {
			selfEmittedKeyRef.current = null;
			processedSourceKeyRef.current = sourceKey;
			return;
		}
		processedSourceKeyRef.current = sourceKey;
		const result = loadActionDocumentFromModelContent(sourceContent, filePath);
		setLoadState(result);
		setSelectedNodeId((current) => current || result.document.root.id);
		setUndoStack([]);
		setRedoStack([]);
		setEditMode("pose");
		setSelectedLook(null);
		setSelectedAnimation(null);
		setPlaybackTime(0);
		setPlaybackPlaying(false);
		if (result.dirty) {
			const fallbackKey = `${filePath}\n${sourceContent}`;
			if (fallbackKeyRef.current !== fallbackKey) {
				fallbackKeyRef.current = fallbackKey;
				onLoadFailedRef.current(result.diagnostics[0]?.message ?? "Failed to load .model");
				const emittedContent = writeLegacyModel(result.document);
				selfEmittedKeyRef.current = `${filePath}\n${emittedContent}`;
				onChangeRef.current(emittedContent);
			}
		}
	}, [filePath, sourceContent]);

	useEffect(() => {
		const clipFile = loadState.document.clipFile;
		if (!clipFile) {
			setClipDocument(null);
			setAtlasImage(null);
			setClipDiagnostics([]);
			return;
		}
		const dir = filePath.includes("/") ? filePath.slice(0, filePath.lastIndexOf("/")) : "";
		const clipPath = clipFile.includes("/") ? clipFile : `${dir}/${clipFile}`;
		let cancelled = false;
		Service.read({path: clipPath}).then((res) => {
			if (cancelled) return;
			if (!res.success) {
				setClipDocument(null);
				setClipDiagnostics([`Failed to read clip file: ${clipPath}`]);
				return;
			}
			try {
				const parsed = parseLegacyClip(res.content, clipPath);
				setClipDocument(parsed);
				setClipDiagnostics(validateActionDocumentClips(loadState.document, parsed).map((item) => item.message));
			} catch (error) {
				setClipDocument(null);
				setAtlasImage(null);
				setClipDiagnostics([error instanceof Error ? error.message : `Failed to parse clip file: ${clipPath}`]);
			}
		}).catch(() => {
			if (!cancelled) {
				setClipDocument(null);
				setClipDiagnostics([`Failed to read clip file: ${clipPath}`]);
			}
		});
		return () => {
			cancelled = true;
		};
	}, [filePath, loadState.document]);

	useEffect(() => {
		if (!clipDocument?.texturePath) {
			setAtlasImage(null);
			return;
		}
		let cancelled = false;
		let loadedUrl: string | null = null;
		loadAtlasImage(clipDocument.texturePath).then((loaded) => {
			loadedUrl = loaded.objectUrl;
			if (!cancelled) {
				setAtlasImage(loaded);
				setClipDiagnostics((items) => items.filter((item) => !item.startsWith("Failed to load atlas image:")));
			}
		}).catch((error) => {
			if (!cancelled) {
				setAtlasImage(null);
				setClipDiagnostics((items) => [
					...items.filter((item) => !item.startsWith("Failed to load atlas image:")),
					error instanceof Error ? error.message : `Failed to load atlas image: ${clipDocument.texturePath}`,
				]);
			}
		});
		return () => {
			cancelled = true;
			if (loadedUrl) URL.revokeObjectURL(loadedUrl);
		};
	}, [clipDocument]);

	useEffect(() => {
		return () => {
			if (atlasImage?.objectUrl) URL.revokeObjectURL(atlasImage.objectUrl);
		};
	}, [atlasImage]);

	useEffect(() => {
		const dir = filePath.includes("/") ? filePath.slice(0, filePath.lastIndexOf("/")) : "";
		let cancelled = false;
		Service.list({path: dir}).then((res) => {
			if (cancelled) return;
			if (!res.success) {
				setClipsDirs([]);
				setClipFiles([]);
				setSelectedClipsDir(undefined);
				return;
			}
			const dirs = getActionClipsDirectories(res.files);
			setClipsDirs(dirs);
			setClipFiles(getActionClipFiles(res.files));
			setSelectedClipsDir(chooseActionClipsDirectory(filePath, dirs));
		}).catch(() => {
			if (!cancelled) {
				setClipsDirs([]);
				setClipFiles([]);
				setSelectedClipsDir(undefined);
			}
		});
		return () => {
			cancelled = true;
		};
	}, [filePath]);

	const emitDocument = useCallback((document: ActionDocument, options?: ActionDocumentChangeOptions) => {
		if (options?.history !== "replace") {
			setUndoStack((items) => [...items, loadState.document]);
		}
		setRedoStack([]);
		setLoadState({document, diagnostics: [], dirty: true});
		if (document.looks.indexOf(selectedLook ?? "") < 0) {
			setSelectedLook(null);
		}
		if (document.animations.indexOf(selectedAnimation ?? "") < 0) {
			setSelectedAnimation(null);
			setPlaybackTime(0);
			setPlaybackPlaying(false);
		}
		const emittedContent = writeLegacyModel(document);
		selfEmittedKeyRef.current = `${filePath}\n${emittedContent}`;
		onChangeRef.current(emittedContent);
	}, [filePath, loadState.document, selectedAnimation, selectedLook]);

	const emitHistoryDocument = useCallback((document: ActionDocument) => {
		setLoadState({document, diagnostics: [], dirty: true});
		const emittedContent = writeLegacyModel(document);
		selfEmittedKeyRef.current = `${filePath}\n${emittedContent}`;
		onChangeRef.current(emittedContent);
	}, [filePath]);

	const undo = useCallback(() => {
		setUndoStack((items) => {
			if (items.length === 0) return items;
			const previous = items[items.length - 1];
			setRedoStack((redoItems) => [...redoItems, loadState.document]);
			emitHistoryDocument(previous);
			return items.slice(0, -1);
		});
	}, [emitHistoryDocument, loadState.document]);

	const redo = useCallback(() => {
		setRedoStack((items) => {
			if (items.length === 0) return items;
			const next = items[items.length - 1];
			setUndoStack((undoItems) => [...undoItems, loadState.document]);
			emitHistoryDocument(next);
			return items.slice(0, -1);
		});
	}, [emitHistoryDocument, loadState.document]);

	const handleClipsDirSelect = useCallback((clipsDir: string) => {
		setSelectedClipsDir(clipsDir);
		const paths = getActionAtlasPaths(filePath, clipsDir);
		const next: ActionDocument = {
			...loadState.document,
			clipFile: paths.modelClipReference,
		};
		emitDocument(next);
	}, [emitDocument, filePath, loadState.document]);

	const handleClipFileSelect = useCallback((clipFile: string) => {
		if (clipFile === loadState.document.clipFile) return;
		emitDocument({
			...loadState.document,
			clipFile,
		});
	}, [emitDocument, loadState.document]);

	const packSelectedClipsDir = useCallback(() => {
		if (!selectedClipsDir || packing) return;
		setPacking(true);
		packActionClipsDirectory(filePath, selectedClipsDir).then(({clip}) => {
			setClipDocument(clip);
			setClipDiagnostics([]);
		}).catch((error) => {
			setClipDiagnostics([error instanceof Error ? error.message : "Failed to pack clips directory"]);
		}).finally(() => {
			setPacking(false);
		});
	}, [filePath, packing, selectedClipsDir]);

	const handleEditModeChange = useCallback((mode: ActionEditorMode) => {
		setEditMode(mode);
		if (mode === "pose") {
			setSelectedLook(null);
			setSelectedAnimation(null);
			setPlaybackTime(0);
			setPlaybackPlaying(false);
		} else if (mode === "look") {
			setSelectedAnimation(null);
			setPlaybackTime(0);
			setPlaybackPlaying(false);
		}
	}, []);

	useEffect(() => {
		if (!playbackPlaying || selectedAnimation === null) return;
		let disposed = false;
		let last = performance.now();
		let frame = 0;
		const tick = (now: number) => {
			if (disposed) return;
			const delta = Math.max(0, (now - last) / 1000);
			last = now;
			setPlaybackTime((current) => {
				const duration = Math.max(0, getActionAnimationDuration(loadState.document, selectedAnimation));
				const next = current + delta;
				if (duration <= 0) return 0;
				if (next <= duration) return next;
				if (playbackLoop) return next % duration;
				setPlaybackPlaying(false);
				return duration;
			});
			frame = window.requestAnimationFrame(tick);
		};
		frame = window.requestAnimationFrame(tick);
		return () => {
			disposed = true;
			if (frame) window.cancelAnimationFrame(frame);
		};
	}, [loadState.document, playbackLoop, playbackPlaying, selectedAnimation]);

	return (
		<ActionEditorCanvas
			document={loadState.document}
			diagnostics={loadState.diagnostics}
			runtimeDiagnostics={runtimeDiagnostics}
			clipDocument={clipDocument}
			atlasImage={atlasImage}
			clipDiagnostics={clipDiagnostics}
			packing={packing}
			width={width}
			height={height}
			active={active}
			readOnly={readOnly}
			clipsDirs={clipsDirs}
			clipFiles={clipFiles}
			selectedClipsDir={selectedClipsDir}
			selectedNodeId={selectedNodeId}
			editMode={editMode}
			selectedLook={selectedLook}
			selectedAnimation={selectedAnimation}
			playbackTime={playbackTime}
			playbackPlaying={playbackPlaying}
			playbackLoop={playbackLoop}
			viewport={viewport}
			onDocumentChange={emitDocument}
			onClipFileSelect={handleClipFileSelect}
			onClipsDirSelect={handleClipsDirSelect}
			onPackClipsDir={packSelectedClipsDir}
			onSelectionChange={setSelectedNodeId}
			onEditModeChange={handleEditModeChange}
			onLookSelect={setSelectedLook}
			onAnimationSelect={setSelectedAnimation}
			onPlaybackTimeChange={setPlaybackTime}
			onPlaybackPlayingChange={setPlaybackPlaying}
			onPlaybackLoopChange={setPlaybackLoop}
			onViewportChange={setViewport}
			canUndo={undoStack.length > 0}
			canRedo={redoStack.length > 0}
			onUndo={undo}
			onRedo={redo}
			onRuntimeDiagnostics={setRuntimeDiagnostics}
		/>
	);
});
