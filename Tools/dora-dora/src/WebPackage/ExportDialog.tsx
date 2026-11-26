import {useState} from 'react';
import AndroidExportForm from './AndroidExportOptions';
import {downloadBlob} from './Download';
import {Button, Dialog, DialogActions, DialogContent, DialogTitle, List, ListItemButton, ListItemText} from '@mui/material';
import {useTranslation} from 'react-i18next';
import type {ExportFormat, ProjectExportAction} from './useWebPackage';

export default function ExportDialog({action}: {action: ProjectExportAction}) {
  const {t} = useTranslation();
  const [showAndroidForm, setShowAndroidForm] = useState(false);
  const choices: Array<{format: ExportFormat; primary: string; secondary: string}> = [
    {format: 'zip', primary: t('export.zip'), secondary: t('export.zipHint')},
    {format: 'obfuscated', primary: t('export.obfuscated'), secondary: t('export.obfuscatedHint')},
  ];
  if (action.dialog?.web) {
    choices.push(
      {format: 'html', primary: t('export.html'), secondary: t('export.htmlHint')},
      {format: 'http', primary: t('export.serverHtml'), secondary: t('export.serverHtmlHint')},
    );
  }
  if (action.dialog?.native?.includes('windows')) {
    choices.push({format: 'windows', primary: t('export.windows'), secondary: t('export.windowsHint')});
  }
  if (action.dialog?.native?.includes('android')) {
    choices.push({format: 'android', primary: t('export.android'), secondary: t(action.dialog.androidOnDevice ? 'export.androidHint' : 'export.androidBrowserHint')});
  }
  if (action.androidDownloads) {
    const {apk, store, packageName, versionCode} = action.androidDownloads;
    return <Dialog open onClose={action.closeAndroidDownloads} fullWidth maxWidth="xs">
      <DialogTitle>{t('export.androidReady')}</DialogTitle>
      {store && <DialogContent>{t('export.androidSaveKeyHint')}</DialogContent>}
      <DialogActions>
        <Button onClick={action.closeAndroidDownloads}>{t('actionEditor.cancel')}</Button>
        {store && <Button onClick={() => downloadBlob(store, `${packageName}.p12`)}>{t('export.androidSaveKey')}</Button>}
        <Button variant="contained" onClick={() => downloadBlob(apk, `${packageName}-${versionCode}.apk`)}>{t('export.androidSaveApk')}</Button>
      </DialogActions>
    </Dialog>;
  }
  if (showAndroidForm && action.dialog) {
    return <AndroidExportForm title={action.dialog.target.title} close={() => setShowAndroidForm(false)}
      submit={options => {setShowAndroidForm(false); action.export('android', options);}} />;
  }
  return <Dialog open={action.dialog !== null} onClose={action.close} fullWidth maxWidth="xs">
    <DialogTitle>{t('export.dialogTitle', {title: action.dialog?.target.title ?? ''})}</DialogTitle>
    <DialogContent dividers sx={{p: 0}}>
      <List disablePadding>
        {choices.map(choice => <ListItemButton key={choice.format} disabled={action.busy}
          onClick={() => {
            if (choice.format === 'android' && !action.dialog?.androidOnDevice) setShowAndroidForm(true);
            else action.export(choice.format);
          }} sx={{px: 3, py: 1.5}}>
          <ListItemText primary={choice.primary} secondary={choice.secondary} />
        </ListItemButton>)}
      </List>
    </DialogContent>
    <DialogActions><Button onClick={action.close}>{t('actionEditor.cancel')}</Button></DialogActions>
  </Dialog>;
}
