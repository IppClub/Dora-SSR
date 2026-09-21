import {CircularProgress, IconButton, Tooltip, type SxProps, type Theme} from '@mui/material';
import {BsBoxSeam} from 'react-icons/bs';
import {useTranslation} from 'react-i18next';

export interface PackageAction {
  open: () => void;
  busy: boolean;
}

export default function PackageButton({action, sx}: {action: PackageAction; sx: SxProps<Theme>}) {
  const {t} = useTranslation();
  return <Tooltip title={t(action.busy ? 'export.busy' : 'export.title')}>
      <span>
        <IconButton aria-label={t('export.title')} disabled={action.busy} onClick={() => action.open()} sx={sx}>
          {action.busy ? <CircularProgress size={16} color="inherit" /> : <BsBoxSeam />}
        </IconButton>
      </span>
    </Tooltip>;
}
