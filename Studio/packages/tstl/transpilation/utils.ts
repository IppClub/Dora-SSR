import path from "path";
import { SourceNode } from "source-map";
import * as ts from "typescript";
import * as lua from "../LuaAST";

export interface EmitHost {
    directoryExists(path: string): boolean;
    fileExists(path: string): boolean;
    getCurrentDirectory(): string;
    readFile(path: string): string | undefined;
    writeFile: ts.WriteFileCallback;
}

interface BaseFile {
    code: string;
    sourceMap?: string;
    sourceFiles?: ts.SourceFile[];
}

export interface ProcessedFile extends BaseFile {
    fileName: string;
    luaAst?: lua.File;
    sourceMapNode?: SourceNode;
}

export interface EmitFile extends BaseFile {
    outputPath: string;
}

export const getConfigDirectory = (options: ts.CompilerOptions) =>
    options.configFilePath ? path.dirname(options.configFilePath) : process.cwd();
