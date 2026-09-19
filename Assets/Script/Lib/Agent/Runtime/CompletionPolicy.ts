// @preview-file off clear

export interface AuthoredCompletionState {
	unbuiltEdits?: boolean;
	hasBuilt?: boolean;
	lastBuildSucceeded?: boolean;
	buildRepairPending?: boolean;
}

/** Keep a main Agent working until authored changes have current, successful
 * compiler evidence. The caller feeds this message back as a decision error so
 * the model can build, repair, and retry inside the same task.
 */
export function getAuthoredCompletionBlocker(state: AuthoredCompletionState): string | undefined {
	if (state.unbuiltEdits === true) {
		return "authored source changes are still unbuilt; call build for the affected project before completing";
	}
	if (state.buildRepairPending === true || (state.hasBuilt === true && state.lastBuildSucceeded === false)) {
		return "the latest project build failed; repair the reported authored-file diagnostics and complete a successful build before completing";
	}
	return undefined;
}
