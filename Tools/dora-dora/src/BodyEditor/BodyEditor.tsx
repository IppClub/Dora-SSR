import { memo, useEffect, useRef, useState } from "react";
import { useTranslation } from "react-i18next";
import * as Service from "../Service";
import BodyEditorCanvas from "./BodyEditorCanvas";
import { BodyCreateJointType, BodyCreateShapeType, BodyCreateSubShapeType, BodyStateResult, createBodyJoint, createBodyShape, createBodySubShape, deleteBodyItem, duplicateBodyItem, translateBodySelection, updateBodyItemField } from "./BodyEditorState";
import { BodyDiagnostic, BodyLoadResult, loadBodyDocumentFromJson, writeBodyDocumentToLua } from "./BodyLuaJsonFormat";
import { BodyDocument, BodyLuaValue } from "./BodyDocument";

export type BodyEditorProps = {
	filePath: string;
	sourceContent: string;
	width: number;
	height: number;
	active: boolean;
	readOnly: boolean;
	refreshKey?: number;
	onOpenAsText: () => void;
	onChange?: (content: string) => void;
};

export default memo(function BodyEditor(props: BodyEditorProps) {
	const { t } = useTranslation();
	const { filePath, sourceContent, width, height, active, readOnly, refreshKey, onChange } = props;
	const [loadState, setLoadState] = useState<BodyLoadResult | null>(null);
	const [undoStack, setUndoStack] = useState<BodyDocument[]>([]);
	const [redoStack, setRedoStack] = useState<BodyDocument[]>([]);
	const sourceContentRef = useRef(sourceContent);
	const loadStateRef = useRef<BodyLoadResult | null>(null);
	const dragUndoDocumentRef = useRef<BodyDocument | null>(null);
	const valueUndoDocumentRef = useRef<BodyDocument | null>(null);
	const loadCanSaveRef = useRef(false);
	const loadDiagnosticsRef = useRef<BodyDiagnostic[]>([]);

	useEffect(() => {
		sourceContentRef.current = sourceContent;
	}, [sourceContent]);

	useEffect(() => {
		let cancelled = false;
		Service.bodyLuaToJson({ file: filePath, content: sourceContentRef.current }).then((response) => {
			if (cancelled) return;
			if (response.success) {
				const result = loadBodyDocumentFromJson(response.json);
					loadCanSaveRef.current = result.canSave;
					loadDiagnosticsRef.current = result.diagnostics;
					loadStateRef.current = result;
					setLoadState(result);
				setUndoStack([]);
				setRedoStack([]);
			} else {
				const diagnostics: BodyDiagnostic[] = [{
					severity: "error",
					path: response.phase ?? "request",
					message: response.message ?? "Failed to load body lua.",
				}];
					loadCanSaveRef.current = false;
					loadDiagnosticsRef.current = diagnostics;
						const nextLoadState: BodyLoadResult = {
							document: { version: 1, source: "body.lua", items: [], dirty: false },
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
				message: error instanceof Error ? error.message : "Failed to load body lua.",
			}];
				loadCanSaveRef.current = false;
				loadDiagnosticsRef.current = diagnostics;
					const nextLoadState: BodyLoadResult = {
						document: { version: 1, source: "body.lua", items: [], dirty: false },
						diagnostics,
						canSave: false,
				};
				loadStateRef.current = nextLoadState;
				setLoadState(nextLoadState);
		});
		return () => {
			cancelled = true;
		};
	}, [filePath, refreshKey]);

	const applyStateResult = (result: BodyStateResult, previous?: BodyDocument) => {
		if (previous && result.diagnostics.length === 0) {
			setUndoStack((items) => [...items, previous]);
			setRedoStack([]);
		}
			const current = loadStateRef.current;
			if (!current) return;
			const nextLoadState = {
				...current,
				document: result.document,
				diagnostics: result.diagnostics.length > 0 ? [...loadDiagnosticsRef.current, ...result.diagnostics] : loadDiagnosticsRef.current,
				canSave: loadCanSaveRef.current && result.diagnostics.length === 0,
			};
			loadStateRef.current = nextLoadState;
			setLoadState(nextLoadState);
	};

	const onCreateShape = (shapeType: BodyCreateShapeType, position: [number, number]) => {
		if (readOnly || !loadState) return;
		const result = createBodyShape(loadState.document, shapeType, position);
		applyStateResult(result, loadState.document);
		if (loadCanSaveRef.current && result.diagnostics.length === 0) onChange?.(writeBodyDocumentToLua(result.document));
	};

	const onDeleteSelected = (selectedId: string | null) => {
		if (readOnly || !loadState) return;
		const result = deleteBodyItem(loadState.document, selectedId);
		applyStateResult(result, loadState.document);
		if (loadCanSaveRef.current && result.diagnostics.length === 0) onChange?.(writeBodyDocumentToLua(result.document));
	};

	const onDuplicateSelected = (selectedId: string | null) => {
		if (readOnly || !loadState) return;
		const result = duplicateBodyItem(loadState.document, selectedId);
		applyStateResult(result, loadState.document);
		if (loadCanSaveRef.current && result.diagnostics.length === 0) onChange?.(writeBodyDocumentToLua(result.document));
	};

	const onCreateSubShape = (subShapeType: BodyCreateSubShapeType, selectedId: string | null, position: [number, number]) => {
		if (readOnly || !loadState) return;
		const result = createBodySubShape(loadState.document, selectedId, subShapeType, position);
		applyStateResult(result, loadState.document);
		if (loadCanSaveRef.current && result.diagnostics.length === 0) onChange?.(writeBodyDocumentToLua(result.document));
	};

	const onCreateJoint = (jointType: BodyCreateJointType, position: [number, number]) => {
		if (readOnly || !loadState) return;
		const result = createBodyJoint(loadState.document, jointType, position);
		applyStateResult(result, loadState.document);
		if (loadCanSaveRef.current && result.diagnostics.length === 0) onChange?.(writeBodyDocumentToLua(result.document));
	};

	const onUpdateField = (selectedId: string, fieldName: string, value: BodyLuaValue, recordUndo = true) => {
		const current = loadStateRef.current;
		if (readOnly || !current) return;
		const result = updateBodyItemField(current.document, selectedId, fieldName, value);
		applyStateResult(result, recordUndo ? current.document : undefined);
		if (loadCanSaveRef.current && result.diagnostics.length === 0) onChange?.(writeBodyDocumentToLua(result.document));
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
		if (loadCanSaveRef.current && result.diagnostics.length === 0) onChange?.(writeBodyDocumentToLua(result.document));
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
							<div key={`${item.path}:${index}`}>{item.path}: {item.message}</div>
						))}
					</div>
				) : null}
				{loadState ? (
					<BodyEditorCanvas
							document={loadState.document}
							width={width}
							height={height - (loadState.diagnostics.length > 0 ? 92 : 0)}
							active={active}
							readOnly={readOnly}
							canUndo={undoStack.length > 0}
							canRedo={redoStack.length > 0}
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
