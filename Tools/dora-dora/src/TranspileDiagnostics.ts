import type { Diagnostic, DiagnosticCategory } from 'typescript';

/** Dora blocks Lua output on compiler warnings, so report them as errors too. */
export function promoteCompilerWarnings(
	diagnostics: readonly Diagnostic[],
	categories: { Warning: DiagnosticCategory; Error: DiagnosticCategory },
): Diagnostic[] {
	return diagnostics.map(diagnostic => diagnostic.category === categories.Warning
		? { ...diagnostic, category: categories.Error }
		: diagnostic);
}
