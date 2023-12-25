export type ProgressUpdate =
  | {
      type: 'CodeChanged';
    }
  | {
      type: 'ResolveNewImports';
    }
  | {
      type: 'LookedUpTypeFile';
      path: string;
      success: boolean;
    }
  | {
      type: 'AttemptedLookUpFile';
      path: string;
      success: boolean;
    }
  | {
      type: 'LookedUpPackage';
      package: string;
      definitelyTyped: boolean;
      success: boolean;
    }
  | {
      type: 'LoadedFromCache';
      importPath: string;
    }
  | {
      type: 'StoredToCache';
      importPath: string;
    };
