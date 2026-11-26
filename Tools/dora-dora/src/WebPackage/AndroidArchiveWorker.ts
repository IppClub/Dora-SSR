import {createAndroidArchive} from './AndroidArchive';
import type {AndroidGameInfo} from './AndroidManifest';

export interface AndroidArchiveRequest {
  template: Blob;
  project: Blob;
  game: AndroidGameInfo;
  password: string;
  key?: ArrayBuffer;
  needsGodot?: boolean;
}

export type AndroidArchiveResponse =
  | {apk: Blob; store?: Uint8Array<ArrayBuffer>}
  | {error: string};

self.onmessage = async ({data}: MessageEvent<AndroidArchiveRequest>) => {
  const {template, project, game, password, key, needsGodot} = data;
  try {
    const result = await createAndroidArchive(template, project, game, password,
      key ? new Uint8Array(key) : undefined, needsGodot);
    self.postMessage(result);
  } catch (error) {
    self.postMessage({error: error instanceof Error ? error.message : String(error)});
  }
};
