import path from 'path';

export interface ImportResourcePathPackage {
  kind: 'package';
  packageName: string;
  importPath?: string;
}

export interface ImportResourcePathRelative {
  kind: 'relative';
  importPath: string;
  sourcePath: string;
}

export interface ImportResourcePathRelativeInPackage {
  kind: 'relative-in-package';
  packageName: string;
  importPath: string;
  sourcePath: string;
}

export type ImportResourcePath =
  | ImportResourcePathPackage
  | ImportResourcePathRelative
  | ImportResourcePathRelativeInPackage;

export const importResourcePathToString = (p: ImportResourcePath) => {
  switch (p.kind) {
    case 'package':
      return path.join(p.packageName, p.importPath ?? '', 'package.json');
    case 'relative':
      return path.join(p.sourcePath, p.importPath);
    case 'relative-in-package':
      return path.join(p.packageName, p.sourcePath, p.importPath);
  }
};
