import type * as monaco from 'monaco-editor';
import { Options } from './Options';
import { SourceCache } from './SourceCache';
import { DependencyParser } from './DependencyParser';
import {
  ImportResourcePath,
  ImportResourcePathRelativeInPackage,
  importResourcePathToString,
} from './ImportResourcePath';
import path from 'path';
import { invokeUpdate } from './invokeUpdate';
import { RecursionDepth } from './RecursionDepth';

export class ImportResolver {
  private loadedFiles: string[];
  private dependencyParser: DependencyParser;
  private cache: SourceCache;
  private versions?: { [packageName: string]: string };
  private newImportsResolved: boolean;
  private monaco: typeof monaco;

  constructor(private options: Options) {
    this.loadedFiles = [];
    this.dependencyParser = new DependencyParser();
    this.cache = options.sourceCache;
    this.newImportsResolved = false;
    this.monaco = options.monaco!;

    if (options.preloadPackages && options.versions) {
      this.versions = options.versions;
      for (const [packageName] of Object.entries(options.versions)) {
        this.resolveImport(
          {
            kind: 'package',
            packageName: packageName,
            importPath: '',
          },
          new RecursionDepth(this.options)
        ).catch(e => {
          console.error(e);
        });
      }
    }
  }

  public wereNewImportsResolved() {
    return this.newImportsResolved;
  }

  public resetNewImportsResolved() {
    this.newImportsResolved = false;
  }

  public async resolveImportsInFile(source: string, parent: string | ImportResourcePath, depth: RecursionDepth) {
    if (depth.shouldStop()) {
      return;
    }

    const imports = this.dependencyParser.parseDependencies(source, parent);
    for (const importCall of imports) {
      try {
        await this.resolveImport(importCall, depth);
      } catch (e) {
        if (this.options.onError) {
          this.options.onError?.((e as Error).message ?? e);
        } else {
          console.error(e);
        }
      }
    }
  }

  private async resolveImport(importResource: ImportResourcePath, depth: RecursionDepth) {
    const hash = this.hashImportResourcePath(importResource);
    if (this.loadedFiles.includes(hash)) {
      return;
    }

    this.loadedFiles.push(hash);
    switch (importResource.kind) {
      case 'package': {
      const resource: ImportResourcePathRelativeInPackage = {
        kind: 'relative-in-package',
        packageName: "",
        importPath: importResource.packageName + (importResource.importPath ? "/" + importResource.importPath : ""),
        sourcePath: ""
      };
      return await this.resolveImportInPackage(resource, depth.nextFile());
    }
      case 'relative': {
      const resource: ImportResourcePathRelativeInPackage = {
        kind: 'relative-in-package',
        packageName: "",
        importPath: importResource.importPath,
        sourcePath: importResource.sourcePath
      };
      return await this.resolveImportInPackage(resource, depth.nextFile());
    }
      case 'relative-in-package':
        return await this.resolveImportInPackage(importResource, depth.nextFile());
    }
  }

  private async resolveImportInPackage(importResource: ImportResourcePathRelativeInPackage, depth: RecursionDepth) {
    const contents = await this.loadSourceFileContents(importResource);

    if (contents) {
      const { source, at } = contents;
      this.createModel(
        source,
        this.monaco.Uri.file(at)
      );
      await this.resolveImportsInFile(
        source,
        {
          kind: 'relative-in-package',
          packageName: importResource.packageName,
          sourcePath: path.dirname(at),
          importPath: '',
        },
        depth
      );
    }
  }

  private async loadSourceFileContents(
    importResource: ImportResourcePathRelativeInPackage
  ): Promise<{ source: string; at: string } | null> {
    const progressUpdatePath = path.join(
      importResource.packageName,
      importResource.sourcePath,
      importResource.importPath
    );
    const failedProgressUpdate = {
      type: 'LookedUpTypeFile',
      path: progressUpdatePath,
      definitelyTyped: false,
      success: false,
    } as const;

    const pkgName = importResource.packageName;
    const version = this.getVersion(importResource.packageName);

    let appends = ['.d.ts', '/index.d.ts', '.ts', '.tsx', '/index.ts', '/index.tsx'];

    if (appends.map(append => importResource.importPath.endsWith(append)).reduce((a, b) => a || b, false)) {
      const source = await this.resolveSourceFile(
        pkgName,
        version,
        path.join(importResource.sourcePath, importResource.importPath)
      );
      if (source) {
        return { source, at: path.join(importResource.sourcePath, importResource.importPath) };
      }
    } else {
      for (const append of appends) {
        const resourcePath = path.join(importResource.sourcePath, importResource.importPath);
        const fullPath =
          (append === '.d.ts' && resourcePath.endsWith('.js') ? resourcePath.slice(0, -3) : resourcePath) + append;
        const source = await this.resolveSourceFile(pkgName, version, fullPath);
        invokeUpdate(
          {
            type: 'AttemptedLookUpFile',
            path: path.join(pkgName, fullPath),
            success: !!source,
          },
          this.options
        );
        if (source) {
          invokeUpdate(
            {
              type: 'LookedUpTypeFile',
              path: path.join(pkgName, fullPath),
              success: true,
            },
            this.options
          );
          return { source, at: fullPath };
        }
      }
    }

    const pkgJson = await this.resolvePackageJson(
      pkgName,
      version,
      path.join(importResource.sourcePath, importResource.importPath)
    );

    if (pkgJson) {
      const { types } = JSON.parse(pkgJson);
      if (types) {
        const fullPath = path.join(importResource.sourcePath, importResource.importPath, types);
        const source = await this.resolveSourceFile(pkgName, version, fullPath);
        if (source) {
          invokeUpdate(
            {
              type: 'LookedUpTypeFile',
              path: path.join(pkgName, fullPath),
              success: true,
            },
            this.options
          );
          return { source, at: fullPath };
        }
      }
    }

    invokeUpdate(failedProgressUpdate, this.options);
    return null;
  }

  private getVersion(packageName: string) {
    return this.versions?.[packageName];
  }

  public setVersions(versions: { [packageName: string]: string }) {
    this.versions = versions;
    this.options.onUpdateVersions?.(versions);
    // TODO reload packages whose version has changed
  }

  private setVersion(packageName: string, version: string) {
    this.setVersions({
      ...this.versions,
      [packageName]: version,
    });
  }

  private createModel(source: string, uri: monaco.Uri) {
    if (!this.monaco.editor.getModel(uri)) {
      this.monaco.editor.createModel(source, 'typescript', uri);
      this.newImportsResolved = true;
    }
  }

  private hashImportResourcePath(p: ImportResourcePath) {
    return importResourcePathToString(p);
  }

  private async resolvePackageJson(
    packageName: string,
    version?: string,
    subPath?: string
  ): Promise<string | undefined> {
    const uri = path.join(packageName + (version ? `@${version}` : ''), subPath ?? '', 'package.json');
    let isAvailable = false;
    let content: string | undefined = undefined;

    if (this.cache.isFileAvailable) {
      isAvailable = await this.cache.isFileAvailable(uri);
    } else {
      content = await this.cache.getFile(uri);
      isAvailable = content !== undefined;
    }

    if (isAvailable) {
      return content ?? (await this.cache.getFile(uri));
    } else {
      return undefined;
    }
  }

  private async resolveSourceFile(
    packageName: string,
    version: string | undefined,
    filePath: string
  ): Promise<string | undefined> {
    const uri = path.join(packageName + (version ? `@${version}` : ''), filePath);
    let isAvailable = false;
    let content: string | undefined = undefined;

    if (this.cache.isFileAvailable) {
      isAvailable = await this.cache.isFileAvailable(uri);
    } else {
      content = await this.cache.getFile(uri);
      isAvailable = content !== undefined;
    }

    if (isAvailable) {
      invokeUpdate(
        {
          type: 'LoadedFromCache',
          importPath: uri,
        },
        this.options
      );
      return content ?? (await this.cache.getFile(uri));
    } else {
      return undefined;
    }
  }
}
