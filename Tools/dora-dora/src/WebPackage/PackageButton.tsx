import {useState} from 'react';
import {CircularProgress, IconButton, Tooltip, type SxProps, type Theme} from '@mui/material';
import {BsBoxSeam} from 'react-icons/bs';
import {useTranslation} from 'react-i18next';
import {StyledMenu, StyledMenuItem} from '../Menu';
import type {WebPackageFormat} from './Archive';

export interface PackageAction {
  onClick: (format: WebPackageFormat) => void;
  busy: boolean;
}

export default function PackageButton({action, sx}: {action: PackageAction; sx: SxProps<Theme>}) {
  const {t} = useTranslation();
  const [anchor, setAnchor] = useState<HTMLElement | null>(null);
  return <>
    <Tooltip title={t(action.busy ? 'webPackage.busy' : 'webPackage.package')}>
      <span>
        <IconButton aria-label={t('webPackage.package')} aria-haspopup="menu" aria-expanded={Boolean(anchor)}
          disabled={action.busy} onClick={event => setAnchor(event.currentTarget)} sx={sx}>
          {action.busy ? <CircularProgress size={16} color="inherit" /> : <BsBoxSeam />}
        </IconButton>
      </span>
    </Tooltip>
    <StyledMenu anchorEl={anchor} open={Boolean(anchor)} onClose={() => setAnchor(null)}
      anchorOrigin={{vertical: 'top', horizontal: 'right'}} transformOrigin={{vertical: 'bottom', horizontal: 'right'}}>
      <StyledMenuItem disabled={action.busy} onClick={() => {setAnchor(null); action.onClick('html');}}>Web (HTML)</StyledMenuItem>
      <StyledMenuItem disabled={action.busy} onClick={() => {setAnchor(null); action.onClick('http');}}>Web (HTTP Server)</StyledMenuItem>
    </StyledMenu>
  </>;
}
