import {useCallback, useRef, useState} from 'react';
import {useTranslation} from 'react-i18next';
import * as Service from '../Service';
import Info from '../Info';
import type {TreeDataType} from '../FileTree';
import type {AndroidDownloads} from './Service';
import type {AndroidExportOptions} from './AndroidExportOptions';

export type ExportFormat = 'zip' | 'obfuscated' | Service.GamePackageFormat;

const exportFormatLabels = {
  zip: 'export.format.zip',
  obfuscated: 'export.format.obfuscated',
  html: 'export.format.html',
  http: 'export.format.serverHtml',
  windows: 'export.format.windows',
  android: 'export.format.android',
} as const satisfies Record<ExportFormat, string>;

export interface ExportTarget {
  key: string;
  title: string;
  dir: boolean;
}

export interface ExportDialogState {
  target: ExportTarget;
  web: boolean;
  native?: Service.NativeGameFormat[];
  androidOnDevice?: boolean;
}

export interface ProjectExportAction {
  busy: boolean;
  dialog: ExportDialogState | null;
  open: (target?: ExportTarget) => void;
  close: () => void;
  androidDownloads: AndroidDownloads | null;
  closeAndroidDownloads: () => void;
  export: (format: ExportFormat, android?: AndroidExportOptions) => void;
  downloadFile: (target: ExportTarget) => void;
}

interface Options {
  currentFile?: {key: string; title: string; folder?: boolean};
  writablePath: string;
  isBusy: () => boolean;
  setBuilding: (busy: boolean) => void;
  save: () => Promise<boolean>;
  build: (target: TreeDataType) => Promise<boolean>;
  checkAgent: (root: string) => Promise<{success: boolean; message?: string; session?: unknown}>;
  notify: (message: string, severity: 'info' | 'success' | 'error') => void;
}

const nativeFormats = (root: {nativeExports?: Service.NativeGameFormat[]; nativeExport?: Service.NativeGameFormat}) =>
  root.nativeExports ?? (root.nativeExport ? [root.nativeExport] : []);
const androidOnDevice = (root: {androidExportOnDevice?: boolean; nativeExport?: Service.NativeGameFormat}) =>
  root.androidExportOnDevice ?? root.nativeExport === 'android';

export function useWebPackage(options: Options): ProjectExportAction {
  const {t} = useTranslation();
  const locked = useRef(false);
  const [busy, setBusy] = useState(false);
  const [dialog, setDialog] = useState<ExportDialogState | null>(null);
  const [androidDownloads, setAndroidDownloads] = useState<AndroidDownloads | null>(null);

  const canStart = useCallback(() => {
    if (!locked.current && !options.isBusy()) return true;
    options.notify(t('alert.waitForJob'), 'info');
    return false;
  }, [options, t]);

  const open = useCallback(async (target?: ExportTarget) => {
    if (!canStart()) return;
    if (target !== undefined) {
      const root = await Service.projectRoot({path: target.key, isDir: true});
      const web = root.success === true && root.found === true
        && root.projectRoot === target.key && root.projectRoot !== options.writablePath;
      setDialog({target, web, native: web ? nativeFormats(root) : undefined, androidOnDevice: androidOnDevice(root)});
      return;
    }
    if (!options.currentFile) {
      options.notify(t('webPackage.noProject'), 'info');
      return;
    }
    const root = await Service.projectRoot({
      path: options.currentFile.key,
      isDir: options.currentFile.folder ?? false,
    });
    if (!root.success || !root.found || !root.projectRoot || root.projectRoot === options.writablePath) {
      options.notify(t('webPackage.noProject'), 'info');
      return;
    }
    setDialog({
      target: {key: root.projectRoot, title: Info.path.basename(root.projectRoot), dir: true},
      web: true,
      native: nativeFormats(root),
      androidOnDevice: androidOnDevice(root),
    });
  }, [canStart, options, t]);

  const run = useCallback(async (target: ExportTarget, format: ExportFormat, android?: AndroidExportOptions) => {
    if (!canStart()) return;
    locked.current = true;
    setBusy(true);
    options.setBuilding(true);
    const formatLabel = t(exportFormatLabels[format]);
    try {
      const {packageDirectory, packageGame} = await import('./Service');
      if (format === 'zip' || format === 'obfuscated') {
        options.notify(t('export.formatBusy', {format: formatLabel}), 'info');
        await packageDirectory(target.key, options.writablePath, target.title, format === 'obfuscated');
      } else {
        const agent = await options.checkAgent(target.key);
        if (!agent.success) throw new Error(agent.message || 'export.failed');
        if (agent.session) throw new Error('webPackage.agentBusy');
        options.notify(t('export.formatBusy', {format: formatLabel}), 'info');
        if (!await options.save()) throw new Error('webPackage.saveFailed');
        if (!await options.build({key: target.key, title: target.title, dir: true})) throw new Error('webPackage.buildFailed');
        const result = await packageGame(target.key, options.writablePath, target.title, format, android);
        if (result === true) {
          options.notify(t('export.androidContinue'), 'info');
          return;
        }
        if (result) setAndroidDownloads(result);
      }
      options.notify(t('export.formatDone', {format: formatLabel}), 'success');
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      const detail = message.startsWith('webPackage.') || message.startsWith('export.') ? t(message) : message;
      options.notify(message === 'export.failed'
        ? t('export.formatFailed', {format: formatLabel})
        : t('export.formatFailedDetail', {format: formatLabel, detail}), 'error');
    } finally {
      locked.current = false;
      setBusy(false);
      options.setBuilding(false);
    }
  }, [canStart, options, t]);

  const exportTarget = useCallback((format: ExportFormat, android?: AndroidExportOptions) => {
    if (dialog === null) return;
    const target = dialog.target;
    setDialog(null);
    void run(target, format, android);
  }, [dialog, run]);

  const downloadFile = useCallback((target: ExportTarget) => {
    if (!canStart()) return;
    locked.current = true;
    setBusy(true);
    options.setBuilding(true);
    void import('./Service').then(({downloadWorkspaceFile}) => (
      downloadWorkspaceFile(target.key, options.writablePath, target.title)
    )).then(() => {
      options.notify(t('export.done'), 'success');
    }).catch((error: unknown) => {
      const message = error instanceof Error ? error.message : String(error);
      options.notify(`${t('export.failed')}: ${message}`, 'error');
    }).finally(() => {
      locked.current = false;
      setBusy(false);
      options.setBuilding(false);
    });
  }, [canStart, options, t]);

  return {
    busy,
    dialog,
    open: target => void open(target),
    close: () => setDialog(null),
    androidDownloads,
    closeAndroidDownloads: () => setAndroidDownloads(null),
    export: exportTarget,
    downloadFile,
  };
}
