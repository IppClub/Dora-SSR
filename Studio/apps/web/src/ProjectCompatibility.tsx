import {useStudioI18n} from './i18n';
import {useMemo} from 'react';
import type {ProjectSnapshot} from '@dora-studio/contracts';
import {inspectProjectCompatibility} from './project-compatibility';
import './project-compatibility.css';
export function ProjectCompatibility({snapshot}:{snapshot:ProjectSnapshot}) {
  const {t} = useStudioI18n();
  const report=useMemo(()=>inspectProjectCompatibility(snapshot),[snapshot]);
  return <details className="project-compatibility"><summary>{report.warnings.length?t('projects.compatibilityPending', {count: report.warnings.length}):t('projects.compatibilityUnverified')}</summary>
    <p>{t(report.entrySupported?'projects.entrySupported':'projects.entryUnsupported', {entry: snapshot.entry})}</p>
    {report.declaredEngine&&<p>{t('projects.declaredEngine', {version: report.declaredEngine})}</p>}
    {report.warnings.length>0&&<ul>{report.warnings.map(warning=><li key={warning[0]}>{t(...warning)}</li>)}</ul>}
    <p>{t('projects.compatibilityNote')}</p>
  </details>;
}
