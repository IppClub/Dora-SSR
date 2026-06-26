export function withAlpha(this: void, color: number, alpha: number): number {
	const a = math.floor(math.max(0, math.min(1, alpha)) * 255);
	return (color & 0x00ffffff) | (a << 24);
}

export function mixColor(this: void, a: number, b: number, t: number): number {
	const ratio = math.max(0, math.min(1, t));
	const aa = (a >>> 24) & 0xff;
	const ar = (a >>> 16) & 0xff;
	const ag = (a >>> 8) & 0xff;
	const ab = a & 0xff;
	const ba = (b >>> 24) & 0xff;
	const br = (b >>> 16) & 0xff;
	const bg = (b >>> 8) & 0xff;
	const bb = b & 0xff;
	const rr = math.floor(ar + (br - ar) * ratio);
	const rg = math.floor(ag + (bg - ag) * ratio);
	const rb = math.floor(ab + (bb - ab) * ratio);
	const ra = math.floor(aa + (ba - aa) * ratio);
	return (ra << 24) | (rr << 16) | (rg << 8) | rb;
}
