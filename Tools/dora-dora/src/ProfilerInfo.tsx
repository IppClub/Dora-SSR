// To parse this data:
//
// import { Convert, ProfilerInfo } from "./file";
//
// const profilerInfo = Convert.toProfilerInfo(json);

export interface ProfilerInfo {
	readonly renderer: string;
	readonly multiThreaded: boolean;
	readonly backBufferX: number;
	readonly backBufferY: number;
	readonly drawCall: number;
	readonly tri: number;
	readonly line: number;
	readonly visualSizeX: number;
	readonly visualSizeY: number;
	readonly vSync: boolean;
	readonly fpsLimited: boolean;
	readonly targetFPS: number;
	readonly maxTargetFPS: number;
	readonly fixedFPS: number;
	readonly currentFPS: number;
	readonly avgCPU: number;
	readonly avgGPU: number;
	readonly cpuTimePeeks: number[];
	readonly gpuTimePeeks: number[];
	readonly deltaTimePeeks: number[];
	readonly updateCosts: UpdateCost[];
	readonly cppObject: number;
	readonly luaObject: number;
	readonly luaCallback: number;
	readonly memoryPool: number;
	readonly luaMemory: number;
	readonly wasmMemory: number;
	readonly textureMemory: number;
	readonly loaderCosts?: LoaderCost[];
}

export interface LoaderCost {
	readonly order: number;
	readonly time: number;
	readonly depth: number;
	readonly moduleName: string;
}

export interface UpdateCost {
	readonly name: string;
	readonly value: number;
}

// Converts JSON strings to/from your types
export class Convert {
	public static toProfilerInfo(json: string): ProfilerInfo {
		return JSON.parse(json);
	}

	public static profilerInfoToJson(value: ProfilerInfo): string {
		return JSON.stringify(value);
	}
}
