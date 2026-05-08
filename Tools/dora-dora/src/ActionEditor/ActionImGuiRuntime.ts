import {ImGui, ImGui_Impl, ImVec4} from "@zhobo63/imgui-ts";

const sarasaMonoScRegularUrl = new URL("../../../../Assets/Font/sarasa-mono-sc-regular.ttf", import.meta.url).href;

export type ActionImGuiFrame = typeof ImGui;

export type ActionImGuiRuntimeStatus = {
	ready: boolean;
	diagnostics: string[];
};

const setVec2 = (target: {x: number; y: number}, x: number, y: number) => {
	target.x = x;
	target.y = y;
};

const vec4 = (x: number, y: number, z: number, w: number) => ({x, y, z, w});

const applyDoraThemeColors = () => {
	const themeColor = vec4(0xfa / 0xff, 0xc0 / 0xff, 0x3d / 0xff, 1);
	const hi = (v: number) => vec4(themeColor.x * 0.9, themeColor.y * 0.9, themeColor.z * 0.9, themeColor.w * v);
	const med = (v: number) => vec4(themeColor.x * 0.6, themeColor.y * 0.6, themeColor.z * 0.6, themeColor.w * v);
	const low = (v: number) => vec4(0.204, 0.204, 0.204, v);
	const bg = (v: number) => vec4(0.102, 0.102, 0.102, v);
	const text = (v: number) => vec4(0.860, 0.860, 0.860, v);
	const button = vec4(0.77, 0.77, 0.77, 0.14);
	const transparent = vec4(0, 0, 0, 0);
	const colors = ImGui.GetStyle().Colors;
	const col = ImGui.Col as any;
	const set = (name: string, color: {x: number; y: number; z: number; w: number}) => {
		if (col[name] !== undefined) {
			colors[col[name]] = color;
		}
	};

	set("Text", text(1));
	set("TextDisabled", text(0.28));
	set("WindowBg", bg(1));
	set("ChildBg", transparent);
	set("PopupBg", bg(0.9));
	set("Border", transparent);
	set("BorderShadow", transparent);
	set("FrameBg", button);
	set("FrameBgHovered", med(0.78));
	set("FrameBgActive", med(1));
	set("TitleBg", low(1));
	set("TitleBgActive", med(1));
	set("TitleBgCollapsed", bg(0.75));
	set("MenuBarBg", bg(0.47));
	set("ScrollbarBg", transparent);
	set("ScrollbarGrab", low(0.5));
	set("ScrollbarGrabHovered", med(0.78));
	set("ScrollbarGrabActive", med(1));
	set("CheckMark", hi(1));
	set("SliderGrab", button);
	set("SliderGrabActive", hi(1));
	set("Button", button);
	set("ButtonHovered", med(0.86));
	set("ButtonActive", med(1));
	set("Header", button);
	set("HeaderHovered", med(0.86));
	set("HeaderActive", hi(1));
	set("Separator", low(1));
	set("SeparatorHovered", med(0.78));
	set("SeparatorActive", med(1));
	set("ResizeGrip", vec4(0.77, 0.77, 0.77, 0.04));
	set("ResizeGripHovered", med(0.78));
	set("ResizeGripActive", med(1));
	set("TabHovered", hi(0.9));
	set("Tab", med(0.8));
	set("TabActive", hi(0.9));
	set("TabUnfocused", med(0.8));
	set("TabUnfocusedActive", hi(0.9));
	set("PlotLines", text(0.63));
	set("PlotLinesHovered", med(1));
	set("PlotHistogram", text(0.33));
	set("PlotHistogramHovered", med(1));
	set("TableHeaderBg", vec4(0.19, 0.19, 0.19, 1));
	set("TableBorderStrong", vec4(0.31, 0.31, 0.31, 1));
	set("TableBorderLight", vec4(0.23, 0.23, 0.23, 1));
	set("TableRowBg", transparent);
	set("TableRowBgAlt", vec4(1, 1, 1, 0.06));
	set("TextSelectedBg", med(0.43));
	set("DragDropTarget", vec4(1, 1, 0, 0.9));
	set("NavHighlight", hi(1));
	set("NavWindowingHighlight", vec4(1, 1, 1, 0.7));
	set("NavWindowingDimBg", vec4(0.8, 0.8, 0.8, 0.2));
	set("ModalWindowDimBg", vec4(0.1, 0.1, 0.1, 0.8));
};

const setDoraStyle = () => {
	ImGui.StyleColorsDark();
	const style = ImGui.GetStyle();
	const anyStyle = style as any;
	const rounding = 6;
	anyStyle.Alpha = 0.9;
	setVec2(anyStyle.WindowPadding, 10, 10);
	setVec2(anyStyle.WindowMinSize, 100, 32);
	anyStyle.WindowRounding = rounding;
	anyStyle.WindowBorderSize = 0;
	setVec2(anyStyle.WindowTitleAlign, 0.5, 0.5);
	anyStyle.ChildRounding = rounding;
	anyStyle.ChildBorderSize = 0;
	setVec2(anyStyle.FramePadding, 5, 5);
	anyStyle.FrameRounding = rounding;
	anyStyle.FrameBorderSize = 0;
	setVec2(anyStyle.ItemSpacing, 10, 10);
	setVec2(anyStyle.ItemInnerSpacing, 5, 5);
	setVec2(anyStyle.TouchExtraPadding, 5, 5);
	anyStyle.IndentSpacing = 10;
	anyStyle.ColumnsMinSpacing = 5;
	anyStyle.ScrollbarSize = 25;
	anyStyle.ScrollbarRounding = rounding;
	anyStyle.GrabMinSize = 20;
	anyStyle.GrabRounding = rounding;
	anyStyle.TabRounding = rounding;
	anyStyle.TabBorderSize = 0;
	anyStyle.PopupRounding = rounding;
	anyStyle.PopupBorderSize = 0;
	setVec2(anyStyle.ButtonTextAlign, 0.5, 0.5);
	setVec2(anyStyle.DisplayWindowPadding, 50, 50);
	setVec2(anyStyle.DisplaySafeAreaPadding, 5, 5);
	anyStyle.AntiAliasedLines = true;
	anyStyle.AntiAliasedFill = true;
	anyStyle.CurveTessellationTol = 1;
	applyDoraThemeColors();
};

const loadDoraFont = async () => {
	const io = ImGui.GetIO();

	const fontSource = `local("sarasa-mono-sc-regular"), local("Sarasa Mono SC"), url(${sarasaMonoScRegularUrl}) format("truetype")`;
	const fontFace = new FontFace("sarasa-mono-sc-regular", fontSource);
	await fontFace.load();
	document.fonts.add(fontFace);

	const font = io.Fonts.AddFontDefault(null);
	font.setFont({
		name: "sarasa-mono-sc-regular",
		fontsize: 16,
	});
	font.FontStyle = "normal";
	io.FontDefault = font;
};

export class ActionImGuiRuntime {
	private static moduleReady: Promise<void> | null = null;
	private static activeRuntime: ActionImGuiRuntime | null = null;
	private static backendOwner: ActionImGuiRuntime | null = null;
	private static sharedContext: any = null;
	private static sharedDiagnostics: string[] = [];
	private static initQueue: Promise<void> = Promise.resolve();
	private context: any = null;
	private canvas: HTMLCanvasElement | null = null;
	private initialized = false;
	private backendInitialized = false;
	private rendering = false;
	private disposed = false;
	private diagnostics: string[] = [];

	static loadModule() {
		if (!ActionImGuiRuntime.moduleReady) {
			ActionImGuiRuntime.moduleReady = ImGui.default().then(() => undefined);
		}
		return ActionImGuiRuntime.moduleReady;
	}

	private static async ensureSharedContext(): Promise<string[]> {
		await ActionImGuiRuntime.loadModule();
		if (ActionImGuiRuntime.sharedContext) {
			ImGui.SetCurrentContext(ActionImGuiRuntime.sharedContext);
			return ActionImGuiRuntime.sharedDiagnostics;
		}
		ImGui.CHECKVERSION();
		ActionImGuiRuntime.sharedContext = ImGui.CreateContext();
		ImGui.SetCurrentContext(ActionImGuiRuntime.sharedContext);
		setDoraStyle();
		try {
			await loadDoraFont();
		} catch (error) {
			const message = error instanceof Error ? error.message : "sarasa-mono-sc-regular load failed";
			ActionImGuiRuntime.sharedDiagnostics.push(message);
			ImGui.GetIO().Fonts.AddFontDefault(null);
		}
		return ActionImGuiRuntime.sharedDiagnostics;
	}

	private static shutdownBackend() {
		const owner = ActionImGuiRuntime.backendOwner;
		if (!owner) return;
		if (ActionImGuiRuntime.sharedContext) {
			ImGui.SetCurrentContext(ActionImGuiRuntime.sharedContext);
		}
		try {
			ImGui_Impl.Shutdown();
		} catch {
			// imgui-ts backend shutdown is best-effort when switching canvases.
		}
		owner.backendInitialized = false;
		if (ActionImGuiRuntime.activeRuntime === owner) {
			ActionImGuiRuntime.activeRuntime = null;
		}
		ActionImGuiRuntime.backendOwner = null;
	}

	private static activateBackend(runtime: ActionImGuiRuntime) {
		if (!runtime.canvas || runtime.disposed) return false;
		if (!ActionImGuiRuntime.sharedContext) return false;
		if (ActionImGuiRuntime.backendOwner === runtime) {
			ActionImGuiRuntime.activeRuntime = runtime;
			runtime.backendInitialized = true;
			ImGui.SetCurrentContext(ActionImGuiRuntime.sharedContext);
			return true;
		}
		ActionImGuiRuntime.shutdownBackend();
		ImGui.SetCurrentContext(ActionImGuiRuntime.sharedContext);
		ImGui_Impl.Init(runtime.canvas);
		ActionImGuiRuntime.backendOwner = runtime;
		ActionImGuiRuntime.activeRuntime = runtime;
		runtime.backendInitialized = true;
		return true;
	}

	async init(canvas: HTMLCanvasElement): Promise<ActionImGuiRuntimeStatus> {
		let result: ActionImGuiRuntimeStatus = {ready: false, diagnostics: this.diagnostics};
		const run = ActionImGuiRuntime.initQueue.then(async () => {
			result = await this.initNow(canvas);
		});
		ActionImGuiRuntime.initQueue = run.catch(() => undefined);
		await run;
		return result;
	}

	private async initNow(canvas: HTMLCanvasElement): Promise<ActionImGuiRuntimeStatus> {
		if (this.initialized) {
			return {ready: true, diagnostics: this.diagnostics};
		}
		if (this.disposed) {
			return {ready: false, diagnostics: this.diagnostics};
		}
		this.canvas = canvas;
		const sharedDiagnostics = await ActionImGuiRuntime.ensureSharedContext();
		this.diagnostics = sharedDiagnostics;
		if (this.disposed) {
			this.canvas = null;
			return {ready: false, diagnostics: this.diagnostics};
		}
		this.context = ActionImGuiRuntime.sharedContext;
		ImGui.SetCurrentContext(this.context);
		ActionImGuiRuntime.activateBackend(this);
		this.initialized = true;
		return {ready: true, diagnostics: this.diagnostics};
	}

	private syncCanvasFramebuffer() {
		if (!this.canvas) return;
		const scale = Math.max(1, window.devicePixelRatio || 1);
		const width = Math.max(1, Math.floor(this.canvas.clientWidth * scale));
		const height = Math.max(1, Math.floor(this.canvas.clientHeight * scale));
		if (this.canvas.width !== width || this.canvas.height !== height) {
			this.canvas.width = width;
			this.canvas.height = height;
		}
	}

	render(time: number, draw: (imgui: ActionImGuiFrame) => void) {
		if (!this.initialized || this.rendering || this.disposed) return;
		this.rendering = true;
		let frameStarted = false;
		try {
			ActionImGuiRuntime.activateBackend(this);
			if (this.context) ImGui.SetCurrentContext(this.context);
			this.syncCanvasFramebuffer();
			ImGui_Impl.NewFrame(time);
			ImGui.NewFrame();
			frameStarted = true;
			draw(ImGui);
			ImGui.Render();
			frameStarted = false;
			ImGui_Impl.ClearBuffer(new ImVec4(0.12, 0.12, 0.12, 1));
			ImGui_Impl.RenderDrawData(ImGui.GetDrawData());
		} catch (error) {
			if (frameStarted) {
				try {
					ImGui.EndFrame();
				} catch {
					// Ignore cleanup errors so the original draw error remains visible to the editor.
				}
			}
			throw error;
		} finally {
			this.rendering = false;
		}
	}

	dispose() {
		this.disposed = true;
		if (!this.initialized && !this.context && !this.backendInitialized) return;
		if (ActionImGuiRuntime.backendOwner === this) {
			ActionImGuiRuntime.shutdownBackend();
		}
		this.backendInitialized = false;
		this.context = null;
		this.canvas = null;
		this.initialized = false;
		this.rendering = false;
		if (ActionImGuiRuntime.activeRuntime === this) {
			ActionImGuiRuntime.activeRuntime = null;
		}
	}
}
