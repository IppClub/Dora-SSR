import { ImportResourcePath } from './ImportResourcePath';
import path from 'path';
export class DependencyParser {
  //private REGEX_CLEAN = /[\n|\r]/g;
  private REGEX_DETECT_IMPORT =
    /(?:(?:(?:import)|(?:export))(?:.)*?from\s+["']([^"']+)["'])|(?:require|import)\s*\(["']([^"']+)["']\)|(?:require|import)\s+["']([^"']+)["']|(?:\/+\s*<reference\s+path=["']([^"']+)["']\s*\/>)/g;
  private REGEX_NODE_MODULE = /^node:([\w\W/]+)$/;

  public parseDependencies(source: string, parent: ImportResourcePath | string): ImportResourcePath[] {
    const cleaned = source; // source.replace(this.REGEX_CLEAN, '');
    return [...cleaned.matchAll(this.REGEX_DETECT_IMPORT)]
      .map(x => x[1] ?? x[2] ?? x[3])
      .filter(x => !!x)
      .map(imp => this.resolvePath(imp, parent));
  }

  private resolvePath(importPath: string, parent: ImportResourcePath | string): ImportResourcePath {
    const nodeImport = importPath.match(this.REGEX_NODE_MODULE);
    if (nodeImport) {
      return {
        kind: 'relative-in-package',
        packageName: '@types/node',
        importPath: `${nodeImport[1]}.d.ts`,
        sourcePath: '',
      };
    }

    if (typeof parent === 'string') {
      if (importPath.startsWith('.')) {
        return {
          kind: 'relative',
          importPath,
          sourcePath: parent,
        };
      } else if (importPath.startsWith('@')) {
        const segments = importPath.split('/');
        return {
          kind: 'package',
          packageName: `${segments[0]}/${segments[1]}`,
          importPath: segments.slice(2).join('/'),
        };
      } else {
        const segments = importPath.split('/');
        return {
          kind: 'package',
          packageName: segments[0],
          importPath: segments.slice(1).join('/'),
        };
      }
    } else {
      switch (parent.kind) {
        case 'package':
          throw Error('TODO?');
        case 'relative':
          throw Error('TODO2?');
        case 'relative-in-package':
          if (importPath.startsWith('.')) {
            return {
              kind: 'relative-in-package',
              packageName: parent.packageName,
              sourcePath: path.join(parent.sourcePath, parent.importPath),
              importPath: importPath,
            };
          } else if (importPath.startsWith('@')) {
            const segments = importPath.split('/');
            return {
              kind: 'package',
              packageName: `${segments[0]}/${segments[1]}`,
              importPath: segments.slice(2).join('/'),
            };
          } else {
            const segments = importPath.split('/');
            return {
              kind: 'package',
              packageName: segments[0],
              importPath: segments.slice(1).join('/'),
            };
          }
      }
    }
  }
}
