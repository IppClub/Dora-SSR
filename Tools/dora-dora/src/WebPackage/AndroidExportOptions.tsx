import {Button, Dialog, DialogActions, DialogContent, DialogTitle, Stack, TextField, Typography} from '@mui/material';
import {useState} from 'react';
import {useTranslation} from 'react-i18next';
import type {AndroidGameInfo} from '../Service';

export interface AndroidExportOptions extends AndroidGameInfo {
  password: string;
  keyFile?: File;
}

export default function AndroidExportForm({title, close, submit}: {
  title: string;
  close: () => void;
  submit: (options: AndroidExportOptions) => void;
}) {
  const {t} = useTranslation();
  const [gameTitle, setGameTitle] = useState(title);
  const [packageName, setPackageName] = useState('');
  const [versionName, setVersionName] = useState('1.0.0');
  const [versionCode, setVersionCode] = useState('1');
  const [password, setPassword] = useState('');
  const [keyFile, setKeyFile] = useState<File>();
  const validPackage = packageName.length <= 200 && /^[A-Za-z][A-Za-z0-9_]*(\.[A-Za-z][A-Za-z0-9_]*)+$/.test(packageName);
  const validVersion = /^[1-9][0-9]*$/.test(versionCode) && Number(versionCode) <= 2147483647;
  return <Dialog open onClose={close} fullWidth maxWidth="xs">
    <DialogTitle>{t('export.android')}</DialogTitle>
    <DialogContent dividers>
      <Stack spacing={2}>
        <TextField required label={t('export.androidTitle')} value={gameTitle} onChange={event => setGameTitle(event.target.value)} />
        <TextField required label={t('export.androidPackage')} placeholder="org.example.game" value={packageName}
          error={!!packageName && !validPackage} onChange={event => setPackageName(event.target.value.trim())} />
        <TextField required label={t('export.androidVersionName')} value={versionName} onChange={event => setVersionName(event.target.value)} />
        <TextField required label={t('export.androidVersionCode')} value={versionCode}
          error={!validVersion} onChange={event => setVersionCode(event.target.value)} />
        <Button component="label" variant="outlined">
          {keyFile?.name ?? t('export.androidImportKey')}
          <input hidden type="file" accept=".p12,.pfx" onChange={event => setKeyFile(event.target.files?.[0])} />
        </Button>
        <TextField required label={t('export.androidPassword')} type="password" autoComplete="off"
          value={password} onChange={event => setPassword(event.target.value)} />
        {!keyFile && <Typography variant="body2">{t('export.androidNewKey')}</Typography>}
      </Stack>
    </DialogContent>
    <DialogActions>
      <Button onClick={close}>{t('actionEditor.cancel')}</Button>
      <Button variant="contained" disabled={!gameTitle.trim() || !validPackage || !versionName.trim() || !validVersion || !password}
        onClick={() => submit({title: gameTitle.trim(), packageName, versionName: versionName.trim(), versionCode: Number(versionCode), password, keyFile})}>
        {t('export.android')}
      </Button>
    </DialogActions>
  </Dialog>;
}
