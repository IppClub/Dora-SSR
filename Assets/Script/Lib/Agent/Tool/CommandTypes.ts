// @preview-file off clear
export type ExecuteCommandMode = "lua" | "git";

export type ExecuteCommandProgress = {
	state: "pending" | "running";
	mode: ExecuteCommandMode;
	operationId: string;
	progress?: number;
	message?: string;
	stage?: string;
	jobId?: number;
	gitState?: string;
	gitKind?: string;
};

export type ExecuteCommandResult = {
	success: true;
	mode: ExecuteCommandMode;
	output: string;
	cwd?: string;
} | {
	success: false;
	mode?: ExecuteCommandMode;
	output?: string;
	cwd?: string;
	message: string;
	phase?: "compile" | "execute" | "timeout" | "validate";
	interrupted?: boolean;
	cleanupError?: string;
};
