import {Node, GodotNode} from 'Dora';

declare module 'GodotPlayer' {
    interface Options {
        scene?: string;
        width?: number;
        height?: number;
        buffers?: 2 | 3 | 4;
        timeout?: number;
    }
    type Callback = (this: void, ok: boolean, game: GodotNode.Type | undefined, error: string) => void;
    interface Player {
        readonly current: GodotNode.Type | undefined;
        readonly state: 'idle' | 'loading' | 'running' | 'unloading' | 'faulted' | 'closed';
        readonly pending: number;
        /** FIFO; waits for native unload before opening the next project. */
        switchAsync(project: string, options?: Options, callback?: Callback): LuaMultiReturn<[number, undefined]> | LuaMultiReturn<[undefined, string]>;
        unloadAsync(callback?: Callback): LuaMultiReturn<[number, undefined]> | LuaMultiReturn<[undefined, string]>;
        /** Drains accepted requests, unloads, then closes. New requests are rejected. */
        closeAsync(callback?: (this: void, ok: boolean, error: string) => void): void;
    }
    interface Factory { (this: void, parent?: Node.Type): Player; }
    const factory: Factory;
    export = factory;
}
