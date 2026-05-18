import { ImGui, ImGui_Impl, ImVec4 } from "@zhobo63/imgui-ts";

const doraFontLocalSources = [
	"local(\"Sarasa Mono SC\")",
	"local(\"Sarasa Mono SC Regular\")",
	"local(\"Sarasa Mono SC CL\")",
	"local(\"Sarasa Mono SC CL Regular\")",
	"local(\"Noto Sans Mono CJK SC\")",
	"local(\"Noto Sans Mono CJK SC Regular\")",
	"local(\"Source Han Mono SC\")",
	"local(\"Source Han Mono SC Regular\")",
	"local(\"Microsoft YaHei Mono\")",
	"local(\"NSimSun\")",
	"local(\"Droid Sans Mono\")",
	"local(\"Droid Sans Fallback\")",
	"local(\"WenQuanYi Micro Hei Mono\")",
	"local(\"WenQuanYi Zen Hei Mono\")",
];
const doraFontSize = 16;

export type ActionImGuiFrame = typeof ImGui;

export type ActionImGuiRuntimeStatus = {
	ready: boolean;
	diagnostics: string[];
};

const setVec2 = (target: { x: number; y: number }, x: number, y: number) => {
	target.x = x;
	target.y = y;
};

const vec4 = (x: number, y: number, z: number, w: number) => ({ x, y, z, w });

const applyDoraThemeColors = () => {
	const themeColor = vec4(0xfa / 0xff, 0xc0 / 0xff, 0x3d / 0xff, 1);
	const hi = (v: number) => vec4(themeColor.x * 0.7, themeColor.y * 0.7, themeColor.z * 0.7, themeColor.w * v);
	const med = (v: number) => vec4(themeColor.x * 0.5, themeColor.y * 0.5, themeColor.z * 0.5, themeColor.w * v);
	const low = (v: number) => vec4(0.204, 0.204, 0.204, v);
	const bg = (v: number) => vec4(0.102, 0.102, 0.102, v);
	const text = (v: number) => vec4(0.860, 0.860, 0.860, v);
	const button = vec4(0.77, 0.77, 0.77, 0.14);
	const transparent = vec4(0, 0, 0, 0);
	const colors = ImGui.GetStyle().Colors;
	const col = ImGui.Col as any;
	const set = (name: string, color: { x: number; y: number; z: number; w: number }) => {
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
	const rounding = 6;
	style.Alpha = 1;
	setVec2(style.WindowPadding, 5, 5);
	setVec2(style.WindowMinSize, 100, 32);
	style.WindowRounding = rounding;
	style.WindowBorderSize = 0;
	setVec2(style.WindowTitleAlign, 0.5, 0.5);
	style.ChildRounding = rounding;
	style.ChildBorderSize = 0;
	setVec2(style.FramePadding, 5, 5);
	style.FrameRounding = rounding;
	style.FrameBorderSize = 0;
	setVec2(style.ItemSpacing, 10, 10);
	setVec2(style.ItemInnerSpacing, 5, 5);
	setVec2(style.TouchExtraPadding, 5, 5);
	style.IndentSpacing = 10;
	style.ColumnsMinSpacing = 5;
	style.ScrollbarSize = 25;
	style.ScrollbarRounding = rounding;
	style.GrabMinSize = 20;
	style.GrabRounding = rounding;
	style.TabRounding = rounding;
	style.TabBorderSize = 0;
	style.PopupRounding = rounding;
	style.PopupBorderSize = 0;
	setVec2(style.ButtonTextAlign, 0.5, 0.5);
	setVec2(style.DisplayWindowPadding, 50, 50);
	setVec2(style.DisplaySafeAreaPadding, 5, 5);
	style.AntiAliasedLines = true;
	style.AntiAliasedFill = true;
	style.CurveTessellationTol = 1;
	applyDoraThemeColors();
};

const loadDoraFont = async () => {
	const io = ImGui.GetIO();

	const fontSource = doraFontLocalSources.join(", ");
	const fontFace = new FontFace("sarasa-mono-sc-regular", fontSource);
	await fontFace.load();
	document.fonts.add(fontFace);

	const font = io.Fonts.AddFontDefault(null);
	font.setFont({
		name: "sarasa-mono-sc-regular",
		fontsize: doraFontSize,
	});
	font.FontStyle = "normal";
	io.FontDefault = font;
};

const loadBrowserDefaultFont = () => {
	const io = ImGui.GetIO();
	const font = io.Fonts.AddFontDefault(null);
	font.setFont({
		name: "monospace",
		fontsize: doraFontSize,
	});
	font.FontStyle = "normal";
	io.FontDefault = font;
};

export class ActionImGuiRuntime {
	private static moduleReady: Promise<void> | null = null;
	private static activeRuntime: ActionImGuiRuntime | null = null;
	private static backendRuntime: ActionImGuiRuntime | null = null;
	private static initQueue: Promise<void> = Promise.resolve();
	private context: any = null;
	private canvas: HTMLCanvasElement | null = null;
	private renderingContext: WebGL2RenderingContext | WebGLRenderingContext | null = null;
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

	async init(canvas: HTMLCanvasElement): Promise<ActionImGuiRuntimeStatus> {
		let result: ActionImGuiRuntimeStatus = { ready: false, diagnostics: this.diagnostics };
		const run = ActionImGuiRuntime.initQueue.then(async () => {
			result = await this.initNow(canvas);
		});
		ActionImGuiRuntime.initQueue = run.catch(() => undefined);
		await run;
		return result;
	}

	private async initNow(canvas: HTMLCanvasElement): Promise<ActionImGuiRuntimeStatus> {
		if (this.initialized) {
			return { ready: true, diagnostics: this.diagnostics };
		}
		if (this.disposed) {
			return { ready: false, diagnostics: this.diagnostics };
		}
		this.canvas = canvas;
		await ActionImGuiRuntime.loadModule();
		if (this.disposed) {
			this.canvas = null;
			return { ready: false, diagnostics: this.diagnostics };
		}
		ImGui.CHECKVERSION();
		this.context = ImGui.CreateContext();
		ImGui.SetCurrentContext(this.context);
		setDoraStyle();
		try {
			await loadDoraFont();
		} catch (error) {
			const message = error instanceof Error ? error.message : "sarasa-mono-sc-regular load failed";
			this.diagnostics.push(message);
			loadBrowserDefaultFont();
		}
		if (this.disposed) {
			if (this.context) {
				ImGui.SetCurrentContext(this.context);
				ImGui.DestroyContext(this.context);
				this.context = null;
			}
			this.canvas = null;
			return { ready: false, diagnostics: this.diagnostics };
		}
		ImGui.SetCurrentContext(this.context);
		if (ActionImGuiRuntime.activeRuntime && ActionImGuiRuntime.activeRuntime !== this) {
			ActionImGuiRuntime.activeRuntime.dispose();
			ImGui.SetCurrentContext(this.context);
		}
		const renderingContext = canvas.getContext("webgl2") || canvas.getContext("webgl");
		if (!renderingContext) {
			this.diagnostics.push("ActionEditor requires WebGL, but the browser did not provide a WebGL context.");
			if (this.context) {
				ImGui.SetCurrentContext(this.context);
				ImGui.DestroyContext(this.context);
				this.context = null;
			}
			this.canvas = null;
			return { ready: false, diagnostics: this.diagnostics };
		}
		this.renderingContext = renderingContext;
		ActionImGuiRuntime.activeRuntime = this;
		ImGui_Impl.Init(renderingContext);
		ActionImGuiRuntime.backendRuntime = this;
		this.backendInitialized = true;
		this.initialized = true;
		return { ready: true, diagnostics: this.diagnostics };
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
		if (!this.initialized || this.rendering || this.disposed || ActionImGuiRuntime.activeRuntime !== this) return;
		this.rendering = true;
		let frameStarted = false;
		try {
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
		if (this.backendInitialized && ActionImGuiRuntime.backendRuntime === this) {
			ImGui.SetCurrentContext(this.context);
			ImGui_Impl.Shutdown();
			ActionImGuiRuntime.backendRuntime = null;
		}
		this.backendInitialized = false;
		if (this.context) {
			ImGui.SetCurrentContext(this.context);
			ImGui.DestroyContext(this.context);
			this.context = null;
		}
		this.renderingContext = null;
		this.canvas = null;
		this.initialized = false;
		this.rendering = false;
		if (ActionImGuiRuntime.activeRuntime === this) {
			ActionImGuiRuntime.activeRuntime = null;
		}
	}
}
