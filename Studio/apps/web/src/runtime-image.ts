import { isBoundedCapturePNG } from '@dora-studio/contracts';

/** Validate in the trusted Studio page, not just in the untrusted game page. */
export async function decodeGameCapture(png:Uint8Array, width:number, height:number,
  decode:(blob:Blob)=>Promise<Pick<ImageBitmap,'width'|'height'|'close'>> = createImageBitmap) {
  if (!isBoundedCapturePNG(png,width,height)) throw new Error('游戏截图格式或尺寸无效');
  const bytes = new Uint8Array(png);
  const bitmap = await decode(new Blob([bytes.buffer],{type:'image/png'}));
  try {
    if (bitmap.width !== width || bitmap.height !== height) throw new Error('游戏截图解码尺寸不一致');
    return bytes;
  } finally { bitmap.close(); }
}
