import { ImFont } from "./imgui";
import { ImGui } from "./index";
export declare enum EType {
    eInput = 0,
    eMultiLine = 1,
    ePassword = 2,
    eMax = 3
}
export declare class Input {
    constructor(type: EType, textCol: string, textBg: string);
    on_input?: ((this: Input, text: string) => any);
    on_visible?: ((this: Input, visible: boolean) => any);
    private onLostFocus;
    onKeydown(e: KeyboardEvent): void;
    isMe(id: ImGui.ImGuiID): boolean;
    get Text(): string | undefined;
    setRect(x: number, y: number, w: number, h: number): void;
    setText(text: string, id: ImGui.ImGuiID, font: ImFont): void;
    setVisible(b: boolean): void;
    _dom_input?: HTMLInputElement | HTMLTextAreaElement;
    _id: ImGui.ImGuiID;
    isVisible: boolean;
    isTab: boolean;
}
export declare let dom_input: any;
export declare function GetInput(type: EType, textColor: string, textBgColor: string): Input;
