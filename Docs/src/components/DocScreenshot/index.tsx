import React from 'react';

type Props = {src: string; alt: string; width?: number; height?: number; caption?: string; maxWidth?: number};

export default function DocScreenshot({src, alt, width, height, caption, maxWidth = 1100}: Props) {
  return (
    <figure style={{margin: '1.5rem auto', width: '100%', maxWidth}}>
      <a href={src} target="_blank" rel="noopener noreferrer" title={alt}>
        <img src={src} alt={alt} width={width} height={height} loading="lazy" decoding="async"
          style={{display: 'block', width: '100%', height: 'auto', borderRadius: 8}} />
      </a>
      {caption && <figcaption style={{marginTop: '0.5rem', fontSize: '0.9em'}}>{caption}</figcaption>}
    </figure>
  );
}
