export interface SourceCache {
  isFileAvailable?: (uri: string) => Promise<boolean>;
  resolveFile?: (uri: string) => Promise<{ content: string; fullPath?: string } | undefined>;
  getFile: (uri: string) => Promise<string | undefined>;
}
