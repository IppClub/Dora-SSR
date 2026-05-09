import { Font } from "./font";
import * as ImGui from "./imgui";
export declare let canvas: HTMLCanvasElement | null;
export declare let canvas_scale: number;
export declare let font_scale: number;
export declare function setCanvasScale(scale: number): void;
export declare function setFontScale(scale: number): void;
export declare let gl: WebGL2RenderingContext | WebGLRenderingContext | null;
export declare let g_compressed_ext: any;
export declare let g_ctx_alpha: boolean;
export declare let ctx: CanvasRenderingContext2D | null;
export declare function any_pointerdown(): boolean;
export declare class ITouch {
    x: number;
    y: number;
}
export declare let multi_touch: {
    [key: number]: ITouch;
};
export declare let is_contextlost: boolean;
export declare function add_key_event(): void;
export declare function remove_key_event(): void;
export declare function add_pointer_event(): void;
export declare function remove_pointer_event(): void;
export declare function Init(value: HTMLCanvasElement | WebGL2RenderingContext | WebGLRenderingContext | CanvasRenderingContext2D | null): void;
export declare function Shutdown(): void;
export declare function ClearBuffer(color: ImGui.ImVec4, bufferBit?: number): void;
export declare function NewFrame(time: number): void;
export declare let dom_font: Font | undefined;
export declare let scroll_acc: ImGui.ImVec2;
export declare function RenderDrawData(draw_data?: ImGui.DrawData | null): void;
export declare function CreateFontsTexture(): void;
export declare function DestroyFontsTexture(): void;
export declare function CreateDeviceObjects(): void;
export declare function DestroyDeviceObjects(): void;
export interface ITextureParam {
    internalFormat?: number;
    srcFormat?: number;
    srcType?: number;
    width?: number;
    height?: number;
    level?: number;
    blocksize?: number[];
    datasize?: number[];
    dataoffset?: number;
    compressed?: boolean;
}
export declare class Texture {
    _texture?: WebGLTexture;
    _internalFormat: number;
    _srcFormat: number;
    _srcType: number;
    _wrapS: number;
    _wrapT: number;
    _minFilter: number;
    _magFilter: number;
    _width: number;
    _height: number;
    _level: number;
    _compressed: boolean;
    _blockSize?: number[];
    constructor(param?: ITextureParam);
    Destroy(): void;
    Bind(index?: number): void;
    Update(src: TexImageSource | Uint8Array | Uint16Array | ArrayBuffer | null, param?: any): void;
}
export declare class TextureCache {
    constructor();
    Destroy(): void;
    Load(name: string, src: string): Promise<Texture>;
    cache: {
        [key: string]: Texture;
    };
}
export declare class FrameBufferObject {
    constructor();
    Destroy(): void;
    Create(width: number, height: number, format?: number, depth?: number): void;
    Bind(use?: boolean): void;
    get_texture(): WebGLTexture | undefined;
    _fbo?: WebGLFramebuffer;
    _target?: Texture;
    _depth?: WebGLRenderbuffer;
    width: number;
    height: number;
    format: number;
    depth_format: number;
}
export declare class Shader {
    constructor();
    Destroy(): void;
    Create(vsCode: string[], psCode: string[]): void;
    _program: WebGLProgram | null;
    _vs: WebGLShader | null;
    _ps: WebGLShader | null;
}
