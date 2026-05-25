import { ParticleQuad } from "./ParticlePreviewRuntime";

export type ParticleTextureSource = {
	image: TexImageSource;
	width: number;
	height: number;
	uv?: {
		left: number;
		top: number;
		right: number;
		bottom: number;
	};
};

const vertexSource = `
attribute vec2 a_position;
attribute vec2 a_uv;
attribute vec4 a_color;
uniform vec2 u_resolution;
varying vec2 v_uv;
varying vec4 v_color;
void main() {
	vec2 zeroToOne = a_position / u_resolution;
	vec2 clipSpace = zeroToOne * 2.0 - 1.0;
	gl_Position = vec4(clipSpace * vec2(1.0, -1.0), 0.0, 1.0);
	v_uv = a_uv;
	v_color = a_color;
}`;

const fragmentSource = `
precision mediump float;
uniform sampler2D u_texture;
varying vec2 v_uv;
varying vec4 v_color;
void main() {
	vec4 texel = texture2D(u_texture, v_uv);
	float alpha = texel.a * v_color.a;
	gl_FragColor = vec4(texel.rgb * v_color.rgb * v_color.a, alpha);
}`;

const colorVertexSource = `
attribute vec2 a_position;
attribute vec4 a_color;
uniform vec2 u_resolution;
varying vec4 v_color;
void main() {
	vec2 zeroToOne = a_position / u_resolution;
	vec2 clipSpace = zeroToOne * 2.0 - 1.0;
	gl_Position = vec4(clipSpace * vec2(1.0, -1.0), 0.0, 1.0);
	v_color = a_color;
}`;

const colorFragmentSource = `
precision mediump float;
varying vec4 v_color;
void main() {
	gl_FragColor = v_color;
}`;

const compileShader = (gl: WebGLRenderingContext, type: number, source: string) => {
	const shader = gl.createShader(type);
	if (!shader) throw new Error("Failed to create shader.");
	gl.shaderSource(shader, source);
	gl.compileShader(shader);
	if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
		const message = gl.getShaderInfoLog(shader) ?? "Shader compile failed.";
		gl.deleteShader(shader);
		throw new Error(message);
	}
	return shader;
};

const createProgramFromSources = (gl: WebGLRenderingContext, vertexCode: string, fragmentCode: string) => {
	const vertex = compileShader(gl, gl.VERTEX_SHADER, vertexCode);
	const fragment = compileShader(gl, gl.FRAGMENT_SHADER, fragmentCode);
	const program = gl.createProgram();
	if (!program) throw new Error("Failed to create program.");
	gl.attachShader(program, vertex);
	gl.attachShader(program, fragment);
	gl.linkProgram(program);
	gl.deleteShader(vertex);
	gl.deleteShader(fragment);
	if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
		const message = gl.getProgramInfoLog(program) ?? "Program link failed.";
		gl.deleteProgram(program);
		throw new Error(message);
	}
	return program;
};

const createProgram = (gl: WebGLRenderingContext) => createProgramFromSources(gl, vertexSource, fragmentSource);

const blendFactor = (gl: WebGLRenderingContext, value: number) => {
	switch (value) {
		case 0x1000: return gl.ZERO;
		case 0x2000: return gl.ONE;
		case 0x3000: return gl.SRC_COLOR;
		case 0x4000: return gl.ONE_MINUS_SRC_COLOR;
		case 0x5000: return gl.SRC_ALPHA;
		case 0x6000: return gl.ONE_MINUS_SRC_ALPHA;
		case 0x7000: return gl.DST_ALPHA;
		case 0x8000: return gl.ONE_MINUS_DST_ALPHA;
		case 0x9000: return gl.DST_COLOR;
		case 0xa000: return gl.ONE_MINUS_DST_COLOR;
		default: return gl.ONE;
	}
};

const premultipliedSourceBlendFactor = (gl: WebGLRenderingContext, value: number) => {
	if (value === 0x5000) return gl.ONE;
	return blendFactor(gl, value);
};

export class ParticleWebGLRenderer {
	private gl: WebGLRenderingContext;
	private program: WebGLProgram;
	private colorProgram: WebGLProgram;
	private buffer: WebGLBuffer;
	private gridBuffer: WebGLBuffer;
	private texture: WebGLTexture;
	private defaultTextureCanvas: HTMLCanvasElement;
	private positionLocation: number;
	private uvLocation: number;
	private colorLocation: number;
	private resolutionLocation: WebGLUniformLocation | null;
	private gridPositionLocation: number;
	private gridColorLocation: number;
	private gridResolutionLocation: WebGLUniformLocation | null;
	private vertexData = new Float32Array(0);
	private gridData = new Float32Array(0);

	constructor(private canvas: HTMLCanvasElement) {
		const gl = canvas.getContext("webgl", { alpha: false, premultipliedAlpha: true });
		if (!gl) throw new Error("WebGL is not available.");
		this.gl = gl;
		this.program = createProgram(gl);
		this.colorProgram = createProgramFromSources(gl, colorVertexSource, colorFragmentSource);
		const buffer = gl.createBuffer();
		const gridBuffer = gl.createBuffer();
		const texture = gl.createTexture();
		if (!buffer || !gridBuffer || !texture) throw new Error("Failed to create WebGL resources.");
		this.buffer = buffer;
		this.gridBuffer = gridBuffer;
		this.texture = texture;
		this.positionLocation = gl.getAttribLocation(this.program, "a_position");
		this.uvLocation = gl.getAttribLocation(this.program, "a_uv");
		this.colorLocation = gl.getAttribLocation(this.program, "a_color");
		this.resolutionLocation = gl.getUniformLocation(this.program, "u_resolution");
		this.gridPositionLocation = gl.getAttribLocation(this.colorProgram, "a_position");
		this.gridColorLocation = gl.getAttribLocation(this.colorProgram, "a_color");
		this.gridResolutionLocation = gl.getUniformLocation(this.colorProgram, "u_resolution");
		this.defaultTextureCanvas = this.createDefaultTexture();
		this.setTexture({ image: this.defaultTextureCanvas, width: 32, height: 32 });
	}

	setTexture(source?: ParticleTextureSource) {
		const gl = this.gl;
		const image = source?.image ?? this.defaultTextureCanvas;
		gl.bindTexture(gl.TEXTURE_2D, this.texture);
		gl.pixelStorei(gl.UNPACK_PREMULTIPLY_ALPHA_WEBGL, true);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
		gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, image);
	}

	render(quads: ParticleQuad[], options: {
		width: number;
		height: number;
		zoom: number;
		offsetX: number;
		offsetY: number;
		sourceBlend: number;
		destinationBlend: number;
		depthWrite: boolean;
		texture?: ParticleTextureSource;
	}) {
		const gl = this.gl;
		const { width, height, zoom, offsetX, offsetY, sourceBlend, destinationBlend, depthWrite, texture } = options;
		if (this.canvas.width !== width || this.canvas.height !== height) {
			this.canvas.width = width;
			this.canvas.height = height;
		}
		gl.viewport(0, 0, width, height);
		gl.disable(gl.BLEND);
		gl.clearColor(0.12, 0.12, 0.12, 1);
		gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
		this.drawGrid(width, height, zoom, offsetX, offsetY);
		this.setTexture(texture);
		const uv = texture?.uv ?? { left: 0, top: 0, right: 1, bottom: 1 };
		this.ensureVertexCapacity(quads.length * 6 * 8);
		let vertexOffset = 0;
		const append = (vertex: ParticleQuad["rb"]) => {
			const screenX = width / 2 + offsetX + vertex.x * zoom;
			const screenY = height / 2 + offsetY - vertex.y * zoom;
			const u = uv.left + (uv.right - uv.left) * vertex.u;
			const v = uv.top + (uv.bottom - uv.top) * vertex.v;
			this.vertexData[vertexOffset++] = screenX;
			this.vertexData[vertexOffset++] = screenY;
			this.vertexData[vertexOffset++] = u;
			this.vertexData[vertexOffset++] = v;
			this.vertexData[vertexOffset++] = vertex.color.x;
			this.vertexData[vertexOffset++] = vertex.color.y;
			this.vertexData[vertexOffset++] = vertex.color.z;
			this.vertexData[vertexOffset++] = vertex.color.w;
		};
		for (const quad of quads) {
			append(quad.rb);
			append(quad.lb);
			append(quad.lt);
			append(quad.rb);
			append(quad.lt);
			append(quad.rt);
		}
		if (vertexOffset === 0) return;
		gl.useProgram(this.program);
		gl.bindBuffer(gl.ARRAY_BUFFER, this.buffer);
		gl.bufferData(gl.ARRAY_BUFFER, this.vertexData, gl.DYNAMIC_DRAW);
		const stride = 8 * 4;
		gl.enableVertexAttribArray(this.positionLocation);
		gl.vertexAttribPointer(this.positionLocation, 2, gl.FLOAT, false, stride, 0);
		gl.enableVertexAttribArray(this.uvLocation);
		gl.vertexAttribPointer(this.uvLocation, 2, gl.FLOAT, false, stride, 2 * 4);
		gl.enableVertexAttribArray(this.colorLocation);
		gl.vertexAttribPointer(this.colorLocation, 4, gl.FLOAT, false, stride, 4 * 4);
		gl.uniform2f(this.resolutionLocation, width, height);
		gl.activeTexture(gl.TEXTURE0);
		gl.bindTexture(gl.TEXTURE_2D, this.texture);
		gl.enable(gl.BLEND);
		gl.depthMask(depthWrite);
		gl.blendFunc(premultipliedSourceBlendFactor(gl, sourceBlend), blendFactor(gl, destinationBlend));
		gl.drawArrays(gl.TRIANGLES, 0, vertexOffset / 8);
		gl.depthMask(false);
	}

	dispose() {
		const gl = this.gl;
		gl.deleteBuffer(this.buffer);
		gl.deleteBuffer(this.gridBuffer);
		gl.deleteTexture(this.texture);
		gl.deleteProgram(this.program);
		gl.deleteProgram(this.colorProgram);
	}

	private drawGrid(width: number, height: number, zoom: number, offsetX: number, offsetY: number) {
		const gl = this.gl;
		this.ensureGridCapacity(512);
		let vertexOffset = 0;
		const append = (x: number, y: number, color: [number, number, number, number]) => {
			if (vertexOffset + 6 > this.gridData.length) this.ensureGridCapacity(vertexOffset + 6);
			this.gridData[vertexOffset++] = x;
			this.gridData[vertexOffset++] = y;
			this.gridData[vertexOffset++] = color[0];
			this.gridData[vertexOffset++] = color[1];
			this.gridData[vertexOffset++] = color[2];
			this.gridData[vertexOffset++] = color[3];
		};
		const minor: [number, number, number, number] = [0.145, 0.145, 0.145, 1];
		const major: [number, number, number, number] = [0.227, 0.227, 0.227, 1];
		const originX = width / 2 + offsetX;
		const originY = height / 2 + offsetY;
		const step = Math.max(12, 50 * zoom);
		for (let x = originX % step; x < width; x += step) {
			append(x, 0, minor);
			append(x, height, minor);
		}
		for (let y = originY % step; y < height; y += step) {
			append(0, y, minor);
			append(width, y, minor);
		}
		append(0, originY, major);
		append(width, originY, major);
		append(originX, 0, major);
		append(originX, height, major);
		gl.useProgram(this.colorProgram);
		gl.bindBuffer(gl.ARRAY_BUFFER, this.gridBuffer);
		gl.bufferData(gl.ARRAY_BUFFER, this.gridData, gl.DYNAMIC_DRAW);
		const stride = 6 * 4;
		gl.enableVertexAttribArray(this.gridPositionLocation);
		gl.vertexAttribPointer(this.gridPositionLocation, 2, gl.FLOAT, false, stride, 0);
		gl.enableVertexAttribArray(this.gridColorLocation);
		gl.vertexAttribPointer(this.gridColorLocation, 4, gl.FLOAT, false, stride, 2 * 4);
		gl.uniform2f(this.gridResolutionLocation, width, height);
		gl.drawArrays(gl.LINES, 0, vertexOffset / 6);
	}

	private ensureVertexCapacity(required: number) {
		if (this.vertexData.length >= required) return;
		let capacity = Math.max(1024, this.vertexData.length);
		while (capacity < required) capacity *= 2;
		this.vertexData = new Float32Array(capacity);
	}

	private ensureGridCapacity(required: number) {
		if (this.gridData.length >= required) return;
		let capacity = Math.max(512, this.gridData.length);
		while (capacity < required) capacity *= 2;
		this.gridData = new Float32Array(capacity);
	}

	private createDefaultTexture() {
		const canvas = document.createElement("canvas");
		canvas.width = 32;
		canvas.height = 32;
		const ctx = canvas.getContext("2d");
		if (ctx) {
			const gradient = ctx.createRadialGradient(16, 16, 0, 16, 16, 16);
			gradient.addColorStop(0, "rgba(255,255,255,1)");
			gradient.addColorStop(0.45, "rgba(255,235,180,0.85)");
			gradient.addColorStop(1, "rgba(255,255,255,0)");
			ctx.fillStyle = gradient;
			ctx.fillRect(0, 0, 32, 32);
		}
		return canvas;
	}
}
