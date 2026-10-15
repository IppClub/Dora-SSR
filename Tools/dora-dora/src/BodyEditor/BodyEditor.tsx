import { memo, useCallback, useEffect, useMemo, useRef, useState } from "react";
import { useTranslation } from "react-i18next";
import * as Service from "../Service";
import { parseLegacyClip } from "../ActionEditor/ActionClip";
import BodyEditorCanvas from "./BodyEditorCanvas";
import { BodyCreateJointRefs, BodyCreateJointType, BodyCreateShapeType, BodyCreateSubShapeType, BodyStateResult, createBodyJoint, createBodyShape, createBodySubShape, deleteBodyItem, duplicateBodyItem, translateBodySelection, updateBodyItemField } from "./BodyEditorState";
import { BodyDiagnostic, BodyLoadResult, loadBodyDocumentFromJson, validateBodyDocument, writeBodyDocumentToLua } from "./BodyLuaJsonFormat";
import { BodyDocument, BodyLuaValue } from "./BodyDocument";
import { BodyFacePreviewAsset, bodyResourceToServedUrl, getBodyFaceLabel, isBodyFaceImageSource, parseBodyFace, resolveBodyFaceResourcePath } from "./BodyResource";

type BodyEditorAlertType = "success" | "info" | "warning" | "error";

const getDiagnosticItemName = (document: BodyDocument, item: BodyDiagnostic) => {
	const match = /^\$\[(\d+)\]/.exec(item.path);
	if (!match) return "";
	const index = Number(match[1]) - 1;
	const bodyItem = document.items[index];
	const name = bodyItem?.fields.name;
	return typeof name === "string" && name.length > 0 ? name : "";
};

const formatDiagnosticMessage = (document: BodyDocument, item: BodyDiagnostic) => {
	const name = getDiagnosticItemName(document, item);
	return name ? `${name}: ${item.message}` : item.message;
};

export type BodyEditorProps = {
	filePath: string;
	resourceBasePath: string;
	sourceContent: string;
	width: number;
	height: number;
	active: boolean;
	readOnly: boolean;
	refreshKey?: number;
	onOpenAsText: () => void;
	addAlert?: (msg: string, type: BodyEditorAlertType, openLog?: boolean) => void;
	onChange?: (content: string) => void;
};

const loadImageAsset = async (filePath: string, servedResourceBasePath: string) => {
	const response = await fetch(Service.addr(bodyResourceToServedUrl(filePath, servedResourceBasePath)));
	if (!response.ok) throw new Error(`Failed to load image: ${filePath}`);
	const objectUrl = URL.createObjectURL(await response.blob());
	try {
		const image = await new Promise<HTMLImageElement>((resolve, reject) => {
			const element = new Image();
			element.onload = () => resolve(element);
			element.onerror = () => reject(new Error(`Failed to decode image: ${filePath}`));
			element.src = objectUrl;
		});
		return {
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

export default memo(function BodyEditor(props: BodyEditorProps) {
	const { t } = useTranslation();
	const { filePath, resourceBasePath, sourceContent, width, height, active, readOnly, refreshKey, addAlert, onChange } = props;
	const [loadState, setLoadState] = useState<BodyLoadResult | null>(null);
	const [faceAssets, setFaceAssets] = useState<ReadonlyMap<string, BodyFacePreviewAsset>>(new Map());
	const [faceResourceBasePath, setFaceResourceBasePath] = useState(resourceBasePath);
	const [undoStack, setUndoStack] = useState<BodyDocument[]>([]);
	const [redoStack, setRedoStack] = useState<BodyDocument[]>([]);
	const sourceContentRef = useRef(sourceContent);
	const loadStateRef = useRef<BodyLoadResult | null>(null);
	const dragUndoDocumentRef = useRef<BodyDocument | null>(null);
	const valueUndoDocumentRef = useRef<BodyDocument | null>(null);
	const loadCanSaveRef = useRef(false);

	useEffect(() => {
		sourceContentRef.current = sourceContent;
	}, [sourceContent]);

	useEffect(() => {
		let cancelled = false;
		Service.projectRoot({ path: filePath, isDir: false }).then((response) => {
			if (cancelled) return;
			setFaceResourceBasePath(response.success && response.found && response.projectRoot ? response.projectRoot : resourceBasePath);
		}).catch(() => {
			if (!cancelled) setFaceResourceBasePath(resourceBasePath);
		});
		return () => {
			cancelled = true;
		};
	}, [filePath, resourceBasePath]);

	const faceValues = useMemo(() => {
		const values = new Set<string>();
		for (const item of loadState?.document.items ?? []) {
			const face = item.fields.face;
			if (typeof face === "string" && face !== "") values.add(face);
		}
		return [...values].sort();
	}, [loadState?.document]);

	useEffect(() => {
		let cancelled = false;
		const loadedObjectUrls: string[] = [];
		const loadFace = async (face: string): Promise<BodyFacePreviewAsset> => {
			const parsed = parseBodyFace(face);
			if (parsed.kind === "sprite" && isBodyFaceImageSource(parsed.source)) {
				const imagePath = resolveBodyFaceResourcePath(parsed.source, faceResourceBasePath);
				const loaded = await loadImageAsset(imagePath, resourceBasePath);
				if (cancelled) {
					URL.revokeObjectURL(loaded.objectUrl);
					return { kind: "placeholder", label: getBodyFaceLabel(face) };
				}
				loadedObjectUrls.push(loaded.objectUrl);
				return { kind: "image", ...loaded };
			}
			if (parsed.kind === "clip" && parsed.clipName) {
				const clipPath = resolveBodyFaceResourcePath(parsed.source, faceResourceBasePath);
				const res = await Service.read({ path: clipPath });
				if (!res.success) return { kind: "placeholder", label: getBodyFaceLabel(face) };
				const clip = parseLegacyClip(res.content, clipPath);
				const rect = clip.rects[parsed.clipName];
				if (!rect) return { kind: "placeholder", label: getBodyFaceLabel(face) };
				const loaded = await loadImageAsset(clip.texturePath, resourceBasePath);
				if (cancelled) {
					URL.revokeObjectURL(loaded.objectUrl);
					return { kind: "placeholder", label: getBodyFaceLabel(face) };
				}
				loadedObjectUrls.push(loaded.objectUrl);
				return {
					kind: "clip",
					image: loaded.image,
					x: rect.x,
					y: rect.y,
					width: rect.width,
					height: rect.height,
					objectUrl: loaded.objectUrl,
				};
			}
			return { kind: "placeholder", label: getBodyFaceLabel(face) };
		};
		Promise.all(faceValues.map(async (face) => {
			try {
				return [face, await loadFace(face)] as const;
			} catch {
				return [face, { kind: "placeholder", label: getBodyFaceLabel(face) } as BodyFacePreviewAsset] as const;
			}
		})).then((entries) => {
			if (!cancelled) setFaceAssets(new Map(entries));
		});
		return () => {
			cancelled = true;
			for (const objectUrl of loadedObjectUrls) URL.revokeObjectURL(objectUrl);
		};
	}, [faceResourceBasePath, faceValues, refreshKey, resourceBasePath]);

	const alertDiagnostics = useCallback((diagnostics: BodyDiagnostic[]) => {
		const currentDocument = loadStateRef.current?.document ?? { version: 1, source: "b.lua", items: [], dirty: false };
		for (const item of diagnostics) {
			addAlert?.(formatDiagnosticMessage(currentDocument, item), item.severity === "error" ? "error" : "warning");
		}
	}, [addAlert]);

	useEffect(() => {
		let cancelled = false;
		Service.parseBodyFile({ file: filePath, content: sourceContentRef.current }).then((response) => {
			if (cancelled) return;
			if (response.success) {
				const result = loadBodyDocumentFromJson(response.json);
				loadStateRef.current = result;
				alertDiagnostics(result.diagnostics);
				loadCanSaveRef.current = true;
				setLoadState(result);
				setUndoStack([]);
				setRedoStack([]);
			} else {
				const diagnostics: BodyDiagnostic[] = [{
					severity: "error",
					path: response.phase ?? "request",
					message: response.message ?? t("bodyEditor.failedLoadBody", "Failed to load body file."),
				}];
				alertDiagnostics(diagnostics);
				loadCanSaveRef.current = false;
				const nextLoadState: BodyLoadResult = {
					document: { version: 1, source: "b.lua", items: [], dirty: false },
					diagnostics,
					canSave: false,
				};
				loadStateRef.current = nextLoadState;
				setLoadState(nextLoadState);
			}
		}).catch((error) => {
			if (cancelled) return;
			const diagnostics: BodyDiagnostic[] = [{
				severity: "error",
				path: "network",
				message: error instanceof Error ? error.message : t("bodyEditor.failedLoadBody", "Failed to load body file."),
			}];
			alertDiagnostics(diagnostics);
			loadCanSaveRef.current = false;
			const nextLoadState: BodyLoadResult = {
				document: { version: 1, source: "b.lua", items: [], dirty: false },
				diagnostics,
				canSave: false,
			};
			loadStateRef.current = nextLoadState;
			setLoadState(nextLoadState);
		});
		return () => {
			cancelled = true;
		};
	}, [alertDiagnostics, filePath, refreshKey, t]);

	const applyStateResult = (result: BodyStateResult, previous?: BodyDocument) => {
		alertDiagnostics(result.diagnostics);
		const structureDiagnostics = validateBodyDocument(result.document);
		if (previous && result.diagnostics.length === 0) {
			setUndoStack((items) => [...items, previous]);
			setRedoStack([]);
		}
		const current = loadStateRef.current;
		if (!current) return;
		const nextLoadState = {
			...current,
			document: result.document,
			diagnostics: structureDiagnostics,
			canSave: loadCanSaveRef.current && result.diagnostics.length === 0 && structureDiagnostics.every((item) => item.severity !== "error"),
		};
		loadStateRef.current = nextLoadState;
		setLoadState(nextLoadState);
	};

	const writeResultIfClean = (result: BodyStateResult) => {
		if (
			loadCanSaveRef.current &&
			result.diagnostics.length === 0 &&
			validateBodyDocument(result.document).every((item) => item.severity !== "error")
		) {
			onChange?.(writeBodyDocumentToLua(result.document));
		}
	};

	const onCreateShape = (shapeType: BodyCreateShapeType, position: [number, number]) => {
		if (readOnly || !loadState) return;
		const result = createBodyShape(loadState.document, shapeType, position);
		applyStateResult(result, loadState.document);
		writeResultIfClean(result);
	};

	const onDeleteSelected = (selectedId: string | null) => {
		if (readOnly || !loadState) return;
		const result = deleteBodyItem(loadState.document, selectedId);
		applyStateResult(result, loadState.document);
		writeResultIfClean(result);
	};

	const onDuplicateSelected = (selectedId: string | null) => {
		if (readOnly || !loadState) return;
		const result = duplicateBodyItem(loadState.document, selectedId);
		applyStateResult(result, loadState.document);
		writeResultIfClean(result);
	};

	const onCreateSubShape = (subShapeType: BodyCreateSubShapeType, selectedId: string | null, position: [number, number]) => {
		if (readOnly || !loadState) return;
		const result = createBodySubShape(loadState.document, selectedId, subShapeType, position);
		applyStateResult(result, loadState.document);
		writeResultIfClean(result);
	};

	const onCreateJoint = (jointType: BodyCreateJointType, position: [number, number], refs?: BodyCreateJointRefs) => {
		if (readOnly || !loadState) return;
		const result = createBodyJoint(loadState.document, jointType, position, refs);
		applyStateResult(result, loadState.document);
		writeResultIfClean(result);
	};

	const onUpdateField = (selectedId: string, fieldName: string, value: BodyLuaValue, recordUndo = true) => {
		const current = loadStateRef.current;
		if (readOnly || !current) return;
		const result = updateBodyItemField(current.document, selectedId, fieldName, value);
		applyStateResult(result, recordUndo ? current.document : undefined);
		writeResultIfClean(result);
	};

	const onBeginValueEdit = () => {
		const current = loadStateRef.current;
		valueUndoDocumentRef.current = readOnly || !current ? null : current.document;
	};

	const onEndValueEdit = (changed: boolean) => {
		const startDocument = valueUndoDocumentRef.current;
		valueUndoDocumentRef.current = null;
		if (!changed || !startDocument) return;
		setUndoStack((items) => [...items, startDocument]);
		setRedoStack([]);
	};

	const onBeginTranslateSelection = () => {
		const current = loadStateRef.current;
		dragUndoDocumentRef.current = readOnly || !current ? null : current.document;
	};

	const onTranslateSelection = (selectedId: string | null, delta: [number, number]) => {
		const current = loadStateRef.current;
		if (readOnly || !current) return;
		const result = translateBodySelection(current.document, selectedId, delta);
		applyStateResult(result);
		writeResultIfClean(result);
	};

	const onEndTranslateSelection = (changed: boolean) => {
		const startDocument = dragUndoDocumentRef.current;
		dragUndoDocumentRef.current = null;
		if (!changed || !startDocument) return;
		setUndoStack((items) => [...items, startDocument]);
		setRedoStack([]);
	};

	const undo = () => {
		if (!loadState || undoStack.length === 0) return;
		const previous = undoStack[undoStack.length - 1];
		setUndoStack((items) => items.slice(0, -1));
		setRedoStack((items) => [...items, loadState.document]);
		const nextLoadState = { ...loadState, document: previous };
		loadStateRef.current = nextLoadState;
		setLoadState(nextLoadState);
		if (loadCanSaveRef.current) onChange?.(writeBodyDocumentToLua(previous));
	};

	const redo = () => {
		if (!loadState || redoStack.length === 0) return;
		const next = redoStack[redoStack.length - 1];
		setRedoStack((items) => items.slice(0, -1));
		setUndoStack((items) => [...items, loadState.document]);
		const nextLoadState = { ...loadState, document: next };
		loadStateRef.current = nextLoadState;
		setLoadState(nextLoadState);
		if (loadCanSaveRef.current) onChange?.(writeBodyDocumentToLua(next));
	};

	return (
		<div
			style={{
				width,
				height,
				display: active ? "flex" : "none",
				flexDirection: "column",
				background: "#1f1f1f",
				color: "#cccccc",
				overflow: "hidden",
			}}
		>
			<div style={{ flex: 1, minHeight: 0, background: "#1f1f1f" }}>
				{loadState && loadState.diagnostics.length > 0 ? (
					<div style={{
						maxHeight: 92,
						overflow: "auto",
						borderBottom: "1px solid #4a2b2b",
						background: "#2a1f1f",
						color: "#f0b7b7",
						fontSize: 12,
						padding: "8px 12px",
					}}>
						{loadState.diagnostics.map((item, index) => (
							<div key={`${item.path}:${index}`}>{formatDiagnosticMessage(loadState.document, item)}</div>
						))}
					</div>
				) : null}
				{loadState ? (
					<BodyEditorCanvas
						document={loadState.document}
						faceAssets={faceAssets}
						resourceBasePath={faceResourceBasePath}
						servedResourceBasePath={resourceBasePath}
						width={width}
						height={height - (loadState.diagnostics.length > 0 ? 92 : 0)}
						active={active}
						readOnly={readOnly}
						canUndo={undoStack.length > 0}
						canRedo={redoStack.length > 0}
						addAlert={addAlert}
						onUndo={undo}
						onRedo={redo}
						onCreateShape={onCreateShape}
						onCreateSubShape={onCreateSubShape}
						onCreateJoint={onCreateJoint}
						onDeleteSelected={onDeleteSelected}
						onDuplicateSelected={onDuplicateSelected}
						onUpdateField={onUpdateField}
						onBeginValueEdit={onBeginValueEdit}
						onEndValueEdit={onEndValueEdit}
						onBeginTranslateSelection={onBeginTranslateSelection}
						onTranslateSelection={onTranslateSelection}
						onEndTranslateSelection={onEndTranslateSelection}
					/>
				) : (
					<div style={{ padding: 16, color: "#8f9aa6" }}>{t("bodyEditor.loading", "Loading BodyEditor...")}</div>
				)}
			</div>
		</div>
	);
});
