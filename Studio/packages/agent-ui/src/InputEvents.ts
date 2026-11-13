/** Some IMEs end composition before delivering the confirming keydown.
 * keyCode 229 still identifies that event even when isComposing is false. */
export function isImeKeyEvent(event: Pick<KeyboardEvent, 'isComposing' | 'keyCode'>): boolean {
  return event.isComposing || event.keyCode === 229;
}

/** Prevent an IME confirmation Enter from implicitly submitting a native form. */
export function preventImeSubmit(event: {
  key: string;
  nativeEvent: Pick<KeyboardEvent, 'isComposing' | 'keyCode'>;
  preventDefault(): void;
}): void {
  if (event.key === 'Enter' && isImeKeyEvent(event.nativeEvent)) event.preventDefault();
}
