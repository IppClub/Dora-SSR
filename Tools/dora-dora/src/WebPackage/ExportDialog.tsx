import {Button, Dialog, DialogActions, DialogContent, DialogTitle, List, ListItemButton, ListItemText} from '@mui/material';
import {useTranslation} from 'react-i18next';
import type {ExportFormat, ProjectExportAction} from './useWebPackage';

export default function ExportDialog({action}: {action: ProjectExportAction}) {
  const {t} = useTranslation();
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
  return <Dialog open={action.dialog !== null} onClose={action.close} fullWidth maxWidth="xs">
    <DialogTitle>{t('export.dialogTitle', {title: action.dialog?.target.title ?? ''})}</DialogTitle>
    <DialogContent dividers sx={{p: 0}}>
      <List disablePadding>
        {choices.map(choice => <ListItemButton key={choice.format} disabled={action.busy}
          onClick={() => action.export(choice.format)} sx={{px: 3, py: 1.5}}>
          <ListItemText primary={choice.primary} secondary={choice.secondary} />
        </ListItemButton>)}
      </List>
    </DialogContent>
    <DialogActions><Button onClick={action.close}>{t('actionEditor.cancel')}</Button></DialogActions>
  </Dialog>;
}
