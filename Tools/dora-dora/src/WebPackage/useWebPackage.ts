import {useCallback, useRef, useState} from 'react';
import {useTranslation} from 'react-i18next';
import * as Service from '../Service';
import Info from '../Info';
import type {TreeDataType} from '../FileTree';
import type {WebPackageFormat} from './Archive';

export type ExportFormat = 'zip' | 'obfuscated' | WebPackageFormat | Service.NativeGameFormat;

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
  native?: Service.NativeGameFormat;
}

export interface ProjectExportAction {
  busy: boolean;
  dialog: ExportDialogState | null;
  open: (target?: ExportTarget) => void;
  close: () => void;
  export: (format: ExportFormat) => void;
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

export function useWebPackage(options: Options): ProjectExportAction {
  const {t} = useTranslation();
  const locked = useRef(false);
  const [busy, setBusy] = useState(false);
  const [dialog, setDialog] = useState<ExportDialogState | null>(null);

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
      setDialog({target, web, native: web ? root.nativeExport : undefined});
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
      native: root.nativeExport,
    });
  }, [canStart, options, t]);

  const run = useCallback(async (target: ExportTarget, format: ExportFormat) => {
    if (!canStart()) return;
    locked.current = true;
    setBusy(true);
    options.setBuilding(true);
    const formatLabel = t(exportFormatLabels[format]);
    try {
      const {downloadWebArchive, packageDirectory, packageNativeProject, packageWebProject} = await import('./Service');
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
        if (format === 'windows' || format === 'android') {
          await packageNativeProject(target.key, options.writablePath, format);
          if (format === 'android') {
            options.notify(t('export.androidContinue'), 'info');
            return;
          }
        } else {
          downloadWebArchive(await packageWebProject(target.key, options.writablePath, format), target.title, format);
        }
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

  const exportTarget = useCallback((format: ExportFormat) => {
    if (dialog === null) return;
    const target = dialog.target;
    setDialog(null);
    void run(target, format);
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
    export: exportTarget,
    downloadFile,
  };
}
