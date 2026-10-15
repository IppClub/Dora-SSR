import { SourceCache } from './SourceCache';

export class DummySourceCache implements SourceCache {
  public getFile(uri: string): Promise<string | undefined> {
    return Promise.resolve(undefined);
  }

  public isFileAvailable(uri: string): Promise<boolean> {
    return Promise.resolve(false);
  }
}
