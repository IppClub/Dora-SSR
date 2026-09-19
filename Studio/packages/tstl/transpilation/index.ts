import * as ts from "typescript";
import { CompilerOptions } from "../CompilerOptions";
import { normalizeSlashes } from "../utils";
import { createEmitOutputCollector, TranspiledFile } from "./output-collector";
import { EmitResult, Transpiler } from "./transpiler";

export * from "./transpile";
export * from "./transpiler";
export type { EmitHost } from "./utils";
export type { TranspiledFile };

export function transpileFiles(
    rootNames: string[],
    options: CompilerOptions = {},
    writeFile?: ts.WriteFileCallback
): EmitResult {
    const program = ts.createProgram(rootNames, options);
    const preEmitDiagnostics = ts.getPreEmitDiagnostics(program);
    const { diagnostics: transpileDiagnostics, emitSkipped } = new Transpiler().emit({ program, writeFile });
    const diagnostics = ts.sortAndDeduplicateDiagnostics([...preEmitDiagnostics, ...transpileDiagnostics]);

    return { diagnostics: [...diagnostics], emitSkipped };
}

/** @internal */
export function createVirtualProgram(input: Record<string, string>, options: CompilerOptions = {}): ts.Program {
    const normalizedFiles: Record<string, string> = {};
    for (const [path, file] of Object.entries(input)) {
        normalizedFiles[normalizeSlashes(path)] = file;
    }
    const compilerHost: ts.CompilerHost = {
        fileExists: fileName => fileName in normalizedFiles,
        getCanonicalFileName: fileName => fileName,
        getCurrentDirectory: () => "",
        getDefaultLibFileName: ts.getDefaultLibFileName,
        readFile: () => "",
        getNewLine: () => "\n",
        useCaseSensitiveFileNames: () => false,
        writeFile() {},

        getSourceFile(fileName) {
            if (fileName in normalizedFiles) {
                return ts.createSourceFile(fileName, normalizedFiles[fileName], ts.ScriptTarget.Latest, false);
            }
        },
    };
    return ts.createProgram(Object.keys(normalizedFiles), options, compilerHost);
}

export interface TranspileVirtualProjectResult {
    diagnostics: ts.Diagnostic[];
    transpiledFiles: TranspiledFile[];
}

export function transpileVirtualProject(
    files: Record<string, string>,
    options: CompilerOptions = {}
): TranspileVirtualProjectResult {
    const program = createVirtualProgram(files, options);
    const preEmitDiagnostics = ts.getPreEmitDiagnostics(program);
    const collector = createEmitOutputCollector();
    const { diagnostics: transpileDiagnostics } = new Transpiler().emit({ program, writeFile: collector.writeFile });
    const diagnostics = ts.sortAndDeduplicateDiagnostics([...preEmitDiagnostics, ...transpileDiagnostics]);

    return { diagnostics: [...diagnostics], transpiledFiles: collector.files };
}

export interface TranspileStringResult {
    diagnostics: ts.Diagnostic[];
    file?: TranspiledFile;
}

export function transpileString(main: string, options: CompilerOptions = {}): TranspileStringResult {
    const { diagnostics, transpiledFiles } = transpileVirtualProject({ "main.tsx": main }, options);
    return {
        diagnostics,
        file: transpiledFiles.find(({ sourceFiles }) => sourceFiles.some(f => f.fileName === "main.tsx")),
    };
}
