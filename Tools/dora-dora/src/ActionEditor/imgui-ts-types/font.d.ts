import { ImFont, ImFontGlyph } from './imgui';
import { Texture } from './imgui_impl';
export declare class TexturePage {
    constructor(tex_size: number, font: ImFont);
    Destroy(): void;
    Create(glyph: ImFontGlyph, ctx: CanvasRenderingContext2D): ImFontGlyph;
    UpdateTexture(): void;
    get IsAvailable(): boolean;
    FontName: string;
    Scale: number;
    TextureSize: number;
    FontSize: number;
    FontImageSize: number;
    PixelData: Uint16Array;
    Current: number;
    MaxCharCount: number;
    CharsPerRow: number;
    Texure: Texture;
    Dirty: boolean;
    SpaceX: number[];
    Ascent: number;
    Descent: number;
}
export declare class Font {
    constructor();
    Destroy(): void;
    Create(glyph: ImFontGlyph, font: ImFont): ImFontGlyph;
    UpdateTexture(): Promise<void>;
    texturePage: TexturePage[];
    canvas: HTMLCanvasElement;
    ctx: CanvasRenderingContext2D;
    dirty: boolean;
}
