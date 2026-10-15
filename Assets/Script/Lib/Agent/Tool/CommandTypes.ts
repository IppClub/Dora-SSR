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

export type ExecuteCommandVisionFields = {
	/** Capture attempts reserved by previewGame in this command. */
	visionCapture?: {batchCount: number; frameCount: number};
	/** Persisted task usage plus the current command's reserved captures. */
	visionBudget?: Record<string, unknown>;
	/** The most recent previewGame result, including validation failures that did not reserve capture budget. */
	previewGame?: {success: boolean; message?: string; files?: string[]; frameCount?: number};
};

export type ExecuteCommandResult = ({
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
}) & ExecuteCommandVisionFields;
