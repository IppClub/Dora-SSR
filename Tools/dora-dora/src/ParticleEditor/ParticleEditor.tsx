import { memo, useCallback, useEffect, useRef, useState } from "react";
import { useTranslation } from "react-i18next";
import { ParticleDiagnostic, ParticleDocument, validateParticleDocument } from "./ParticleDocument";
import { ParticleLoadResult, loadParticleDocumentFromXml, writeParticleDocumentToXml } from "./ParticleXmlFormat";
import ParticleEditorCanvas from "./ParticleEditorCanvas";
import { ParticleResourceResult, loadParticleTexture } from "./ParticleResource";
import * as Service from "../Service";
import { ParticleFieldPath, applyParticleFieldUpdate } from "./ParticleEditorState";
import { ParticlePresetId, createParticlePresetFields } from "./ParticlePresets";

type ParticleEditorAlertType = "success" | "info" | "warning" | "error";
type ParticleColorPath = "startColor" | "startColorVariance" | "finishColor" | "finishColorVariance";
type ParticleRgba = { x: number; y: number; z: number; w: number };

export type ParticleEditorProps = {
	filePath: string;
	resourceBasePath: string;
	sourceContent: string;
	width: number;
	height: number;
	active: boolean;
	readOnly: boolean;
	refreshKey?: number;
	addAlert?: (msg: string, type: ParticleEditorAlertType, openLog?: boolean) => void;
	onOpenAsText: () => void;
	onChange?: (content: string) => void;
};

export default memo(function ParticleEditor(props: ParticleEditorProps) {
	const { filePath, resourceBasePath, sourceContent, width, height, active, readOnly, refreshKey, addAlert, onChange } = props;
	const { t } = useTranslation();
	const [loadState, setLoadState] = useState<ParticleLoadResult | null>(null);
	const [texture, setTexture] = useState<ParticleResourceResult>({ source: "default", label: "default particle texture" });
	const [textureResourceBasePath, setTextureResourceBasePath] = useState(resourceBasePath);
	const [undoStack, setUndoStack] = useState<ParticleDocument[]>([]);
	const [redoStack, setRedoStack] = useState<ParticleDocument[]>([]);
	const loadStateRef = useRef<ParticleLoadResult | null>(null);
	const valueUndoDocumentRef = useRef<ParticleDocument | null>(null);
	const sourceContentRef = useRef(sourceContent);

	useEffect(() => {
		sourceContentRef.current = sourceContent;
	}, [sourceContent]);

	useEffect(() => {
		let cancelled = false;
		Service.projectRoot({ path: filePath, isDir: false }).then((response) => {
			if (!cancelled) {
				setTextureResourceBasePath(response.success && response.found && response.projectRoot ? response.projectRoot : resourceBasePath);
			}
		}).catch(() => {
			if (!cancelled) setTextureResourceBasePath(resourceBasePath);
		});
		return () => {
			cancelled = true;
		};
	}, [filePath, resourceBasePath]);

	const alertDiagnostics = useCallback((diagnostics: ParticleDiagnostic[]) => {
		for (const item of diagnostics) {
			if (item.severity === "info") continue;
			addAlert?.(item.message, item.severity === "error" ? "error" : "warning");
		}
	}, [addAlert]);

	useEffect(() => {
		const result = loadParticleDocumentFromXml(sourceContentRef.current);
		loadStateRef.current = result;
		setLoadState(result);
		setUndoStack([]);
		setRedoStack([]);
		alertDiagnostics(result.diagnostics);
	}, [alertDiagnostics, filePath, refreshKey]);

	useEffect(() => {
		const document = loadStateRef.current?.document;
		if (!document) return;
		let cancelled = false;
		let objectUrl: string | undefined;
		loadParticleTexture(
			document.fields.textureName,
			document.fields.textureRect,
			textureResourceBasePath,
			resourceBasePath,
			refreshKey,
		).then((result) => {
			if (cancelled) {
				if (result.objectUrl) URL.revokeObjectURL(result.objectUrl);
				return;
			}
			objectUrl = result.objectUrl;
			setTexture(result);
		});
		return () => {
			cancelled = true;
			if (objectUrl) URL.revokeObjectURL(objectUrl);
		};
	}, [loadState?.document, refreshKey, resourceBasePath, textureResourceBasePath]);

	const writeIfClean = (document: ParticleDocument) => {
		const diagnostics = validateParticleDocument(document);
		if (diagnostics.every((item) => item.severity !== "error")) {
			onChange?.(writeParticleDocumentToXml(document));
		}
	};

	const applyDocument = (document: ParticleDocument, previous?: ParticleDocument) => {
		const diagnostics = validateParticleDocument(document);
		if (previous) {
			setUndoStack((items) => [...items, previous]);
			setRedoStack([]);
		}
		const nextLoadState: ParticleLoadResult = {
			document,
			diagnostics,
			canSave: diagnostics.every((item) => item.severity !== "error"),
		};
		loadStateRef.current = nextLoadState;
		setLoadState(nextLoadState);
		writeIfClean(document);
	};

	const onUpdateField = (path: ParticleFieldPath, value: number | string | boolean, recordUndo = true) => {
		const current = loadStateRef.current;
		if (readOnly || !current) return;
		if (valueUndoDocumentRef.current === null) {
			valueUndoDocumentRef.current = current.document;
		}
		const nextDocument = applyParticleFieldUpdate(current.document, path, value);
		applyDocument(nextDocument, recordUndo ? valueUndoDocumentRef.current ?? current.document : undefined);
		if (recordUndo) valueUndoDocumentRef.current = null;
	};

	const onUpdateColor = (basePath: ParticleColorPath, value: ParticleRgba, recordUndo = true) => {
		const current = loadStateRef.current;
		if (readOnly || !current) return;
		if (valueUndoDocumentRef.current === null) {
			valueUndoDocumentRef.current = current.document;
		}
		const nextDocument = ([
			["x", value.x],
			["y", value.y],
			["z", value.z],
			["w", value.w],
		] as const).reduce(
			(next, [channel, channelValue]) => applyParticleFieldUpdate(next, `${basePath}.${channel}` as ParticleFieldPath, channelValue),
			current.document,
		);
		applyDocument(nextDocument, recordUndo ? valueUndoDocumentRef.current ?? current.document : undefined);
		if (recordUndo) valueUndoDocumentRef.current = null;
	};

	const onSelectTexture = (textureName: string, resetRect = false) => {
		const current = loadStateRef.current;
		if (readOnly || !current) return;
		const updates: Array<[ParticleFieldPath, number | string]> = [["textureName", textureName]];
		if (resetRect) {
			updates.push(["textureRect.x", 0], ["textureRect.y", 0], ["textureRect.width", 0], ["textureRect.height", 0]);
		}
		const nextDocument = updates.reduce(
			(next, [path, value]) => applyParticleFieldUpdate(next, path, value),
			current.document,
		);
		applyDocument(nextDocument, current.document);
	};

	const onApplyPreset = (presetId: ParticlePresetId) => {
		const current = loadStateRef.current;
		if (readOnly || !current) return;
		const presetFields = createParticlePresetFields(presetId);
		const nextDocument: ParticleDocument = {
			...current.document,
			dirty: true,
			fields: {
				...presetFields,
				textureName: current.document.fields.textureName,
				textureRect: { ...current.document.fields.textureRect },
			},
		};
		applyDocument(nextDocument, current.document);
	};

	const undo = () => {
		const current = loadStateRef.current;
		if (!current || undoStack.length === 0) return;
		const previous = undoStack[undoStack.length - 1];
		setUndoStack((items) => items.slice(0, -1));
		setRedoStack((items) => [...items, current.document]);
		const nextLoadState = { ...current, document: previous, diagnostics: validateParticleDocument(previous) };
		loadStateRef.current = nextLoadState;
		setLoadState(nextLoadState);
		onChange?.(writeParticleDocumentToXml(previous));
	};

	const redo = () => {
		const current = loadStateRef.current;
		if (!current || redoStack.length === 0) return;
		const next = redoStack[redoStack.length - 1];
		setRedoStack((items) => items.slice(0, -1));
		setUndoStack((items) => [...items, current.document]);
		const nextLoadState = { ...current, document: next, diagnostics: validateParticleDocument(next) };
		loadStateRef.current = nextLoadState;
		setLoadState(nextLoadState);
		onChange?.(writeParticleDocumentToXml(next));
	};

	return (
		<div style={{ width, height, display: active ? "flex" : "none", flexDirection: "column", background: "#1f1f1f", color: "#cccccc", overflow: "hidden" }}>
			{loadState ? (
				<>
					{loadState.diagnostics.some((item) => item.severity === "error") ? (
						<div style={{ maxHeight: 92, overflow: "auto", borderBottom: "1px solid #4a2b2b", background: "#2a1f1f", color: "#f0b7b7", fontSize: 12, padding: "8px 12px" }}>
							{loadState.diagnostics.filter((item) => item.severity === "error").map((item, index) => (
								<div key={`${item.path}:${index}`}>{item.message}</div>
							))}
							<button onClick={props.onOpenAsText} style={{ marginTop: 6 }}>{t("particleEditor.openAsText", "Open as text")}</button>
						</div>
					) : null}
					<ParticleEditorCanvas
						document={loadState.document}
						width={width}
						height={height - (loadState.diagnostics.some((item) => item.severity === "error") ? 92 : 0)}
						resourceBasePath={textureResourceBasePath}
						servedResourceBasePath={resourceBasePath}
						active={active}
						readOnly={readOnly}
						texture={texture.texture}
						textureLabel={texture.label}
						textureWarning={texture.warning}
						canUndo={undoStack.length > 0}
						canRedo={redoStack.length > 0}
						onUndo={undo}
						onRedo={redo}
							onUpdateField={onUpdateField}
							onUpdateColor={onUpdateColor}
							onSelectTexture={onSelectTexture}
							onApplyPreset={onApplyPreset}
							addAlert={addAlert}
						/>
				</>
			) : (
				<div style={{ padding: 16, color: "#8f9aa6" }}>{t("particleEditor.loading", "Loading ParticleEditor...")}</div>
			)}
		</div>
	);
});
