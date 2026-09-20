import {useCallback, useRef, useState} from 'react';
import {useTranslation} from 'react-i18next';
import * as Service from '../Service';
import Info from '../Info';
import type {TreeDataType} from '../FileTree';
import type {PackageAction} from './PackageButton';
import type {WebPackageFormat} from './Archive';

interface Options {
  currentFile?: {key: string; folder?: boolean};
  writablePath: string;
  isBusy: () => boolean;
  setBuilding: (busy: boolean) => void;
  save: () => Promise<boolean>;
  build: (target: TreeDataType) => Promise<boolean>;
  checkAgent: (root: string) => Promise<{success: boolean; message?: string; session?: unknown}>;
  notify: (message: string, severity: 'info' | 'success' | 'error') => void;
}

export function useWebPackage(options: Options): PackageAction {
  const {t} = useTranslation();
  const locked = useRef(false);
  const [busy, setBusy] = useState(false);
  const onClick = useCallback(async (format: WebPackageFormat) => {
    if (locked.current || options.isBusy()) { options.notify(t('alert.waitForJob'), 'info'); return; }
    if (!options.currentFile) { options.notify(t('webPackage.noProject'), 'info'); return; }
    locked.current = true;
    setBusy(true);
    options.setBuilding(true);
    try {
      const root = await Service.projectRoot({path: options.currentFile.key, isDir: options.currentFile.folder ?? false});
      if (!root.success || !root.found || !root.projectRoot || root.projectRoot === options.writablePath) throw new Error('webPackage.noProject');
      const agent = await options.checkAgent(root.projectRoot);
      if (!agent.success) throw new Error(agent.message || 'webPackage.failed');
      if (agent.session) throw new Error('webPackage.agentBusy');
      options.notify(t('webPackage.busy'), 'info');
      if (!await options.save()) throw new Error('webPackage.saveFailed');
      const title = Info.path.basename(root.projectRoot);
      if (!await options.build({key: root.projectRoot, title, dir: true})) throw new Error('webPackage.buildFailed');
      const {packageWebProject, downloadWebArchive} = await import('./Service');
      downloadWebArchive(await packageWebProject(root.projectRoot, options.writablePath, format), title, format);
      options.notify(t('webPackage.done'), 'success');
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      options.notify(message.startsWith('webPackage.') ? t(message) : `${t('webPackage.failed')}: ${message}`, 'error');
    } finally {
      locked.current = false;
      setBusy(false);
      options.setBuilding(false);
    }
  }, [options, t]);
  return {busy, onClick: format => void onClick(format)};
}
