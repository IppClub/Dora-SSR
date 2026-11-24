import {useStudioI18n} from './i18n';
import { useEffect, useState } from 'react';
import type { ProjectFile } from '@dora-studio/contracts';

const formats: Record<string, { type: 'image' | 'audio'; mime: string }> = {
  png: { type: 'image', mime: 'image/png' }, jpg: { type: 'image', mime: 'image/jpeg' },
  jpeg: { type: 'image', mime: 'image/jpeg' }, webp: { type: 'image', mime: 'image/webp' },
  gif: { type: 'image', mime: 'image/gif' }, wav: { type: 'audio', mime: 'audio/wav' },
  ogg: { type: 'audio', mime: 'audio/ogg' }, mp3: { type: 'audio', mime: 'audio/mpeg' },
};
export function ResourcePreview({ file }: { file: ProjectFile | undefined }) {
  const {t} = useStudioI18n();
  const [preview, setPreview] = useState<{ file: ProjectFile; url: string } | null>(null), [failed, setFailed] = useState(false);
  const url = preview && preview.file === file ? preview.url : '';
  const format = formats[file?.path.split('.').pop()?.toLowerCase() || ''];
  useEffect(() => {
    setPreview(null); setFailed(false);
    if (file?.kind !== 'binary' || !format) return;
    const url = URL.createObjectURL(new Blob([new Uint8Array(file.bytes)], { type: format.mime }));
    setPreview({ file, url });
    return () => URL.revokeObjectURL(url);
  }, [file, format]);
  if (!file) return <p className="hint">{t('projects.selectPreview')}</p>;
  return <section className="resource-preview" aria-label={t('projects.assetPreview')}><h3>{file.path}</h3>
    {failed ? <p role="alert">{t('projects.assetDecodeFailed')}</p> : url && format ?
      format.type === 'image' ? <img src={url} alt={file.path} onError={() => setFailed(true)}/> :
        <audio key={url} src={url} controls preload="metadata" onError={() => setFailed(true)}/> :
      <p className="hint">{file.kind === 'text' ? t('projects.textPreview') : t('projects.unsupportedPreview')}</p>}
  </section>;
}
