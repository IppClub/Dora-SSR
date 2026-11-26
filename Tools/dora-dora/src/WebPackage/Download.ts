export function downloadBlob(blob: Blob, filename: string) {
  const url = URL.createObjectURL(blob);
  const anchor = document.createElement('a');
  anchor.href = url;
  anchor.download = Array.from(filename, character => (
    character.charCodeAt(0) < 32 || '<>:"/\\|?*'.includes(character) ? '_' : character
  )).join('');
  document.body.appendChild(anchor);
  anchor.click();
  anchor.remove();
  setTimeout(() => URL.revokeObjectURL(url), 60000);
}
