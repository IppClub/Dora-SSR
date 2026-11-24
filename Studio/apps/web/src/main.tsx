import { createRoot } from 'react-dom/client';
import { StudioApp } from './StudioApp';
import { StudioI18nProvider } from './i18n';
import './style.css';
createRoot(document.getElementById('root')!).render(<StudioI18nProvider><StudioApp /></StudioI18nProvider>);
