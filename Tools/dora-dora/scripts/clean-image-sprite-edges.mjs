#!/usr/bin/env node
import process from 'node:process';
import { cleanImageSpriteEdges, readPngRgba, writePngRgba } from './image-sprite-quality.mjs';

const printUsage = () => {
	console.log(`Usage:
  node scripts/clean-image-sprite-edges.mjs <input.png> <output.png> [options]

Options:
  --green-dark-cutoff <n>  Green fringe pixels darker than this are removed. Default: 72.
  --help                  Show this help.

This removes green-screen edge spill from exported sprite sheets and bleeds
nearby foreground RGB into transparent pixels to avoid texture-filtering halos.
`);
};

const args = process.argv.slice(2);
if (args.length === 0 || args.includes('--help') || args.includes('-h')) {
	printUsage();
	process.exit(args.length === 0 ? 1 : 0);
}

let inputPath;
let outputPath;
const options = {};
for (let index = 0; index < args.length; index += 1) {
	const arg = args[index];
	if (arg === '--green-dark-cutoff') options.greenFringeDarkCutoff = Number(args[++index]);
	else if (arg.startsWith('--')) throw new Error(`unknown option: ${arg}`);
	else if (inputPath === undefined) inputPath = arg;
	else if (outputPath === undefined) outputPath = arg;
	else throw new Error(`unexpected argument: ${arg}`);
}

try {
	if (inputPath === undefined || outputPath === undefined) {
		throw new Error('missing input or output PNG path');
	}
	const image = readPngRgba(inputPath);
	const stats = cleanImageSpriteEdges(image, options);
	writePngRgba(outputPath, image);
	console.log(JSON.stringify({
		success: true,
		inputPath,
		outputPath,
		...stats,
	}, undefined, 2));
} catch (error) {
	console.error(error instanceof Error ? error.message : String(error));
	process.exit(1);
}
