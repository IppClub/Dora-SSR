export interface SourceCache {
  isFileAvailable?: (uri: string) => Promise<boolean>;
  getFile: (uri: string) => Promise<string | undefined>;
}
