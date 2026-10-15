import { MASCOT_CELL_SIZE, MASCOT_FRAME_PIVOT_X, MASCOT_PIVOT_Y } from "Dev/Mobile/MascotFrames";
export { MASCOT_CELL_SIZE, MASCOT_PIVOT_Y } from "Dev/Mobile/MascotFrames";
export const MASCOT_FRAME_COUNT = 4;

export const mascotFramePivotX = (row: number, frame: number) => MASCOT_FRAME_PIVOT_X[row * MASCOT_FRAME_COUNT + frame];

export const mascotLayout = (size: number) => {
	// Preserve the requested UI size, without pixel-art quantization.
	const scale = size / MASCOT_CELL_SIZE;
	return {
		scale,
		width: MASCOT_CELL_SIZE * scale,
		feetY: (MASCOT_CELL_SIZE / 2 - MASCOT_PIVOT_Y) * scale,
	};
};

export const mascotFrameAt = (elapsed: number, interval: number) => math.floor(elapsed / interval) % MASCOT_FRAME_COUNT;
export const mascotAnimationTime = (elapsed: number, dt: number, reducedMotion: boolean) => reducedMotion ? 0 : elapsed + dt;
