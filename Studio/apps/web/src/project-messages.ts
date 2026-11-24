import type {StudioMessage} from './i18n';
import type {ProjectMessageKey} from './locales';

export class ProjectMessageError extends Error {
  readonly notice: StudioMessage;

  constructor(key: ProjectMessageKey, values?: StudioMessage[1]) {
    super(key);
    this.notice = values ? [key, values] : [key];
  }
}
