#!/usr/bin/env node
import path from 'node:path';
import process from 'node:process';
import { evaluateImageSprite, writeAlignedImageSprite } from './image-sprite-quality.mjs';

const printUsage = () => {
	console.log(`Usage:
  node scripts/evaluate-image-sprite.mjs <file.sprite.json> [options]

Options:
  --action <id|index>         Evaluate a specific action. Defaults to selectedAction.
  --image <png>               Override action.image for evaluation.
  --json                      Print full JSON report.
  --fix <png>                 Write an aligned PNG using suggested per-frame shifts.
  --alpha <n>                 Alpha threshold for visible pixels. Default: 8.
  --pass-bottom <px>          Pass threshold for foot/bottom jitter. Default: 0.
  --pass-anchor-x <px>        Pass threshold for lower-body X jitter. Default: 1.5.
  --fixable-shift <px>        Max suggested shift considered auto-fixable. Default: 3.
  --fail-bottom <px>          Hard fail threshold for foot/bottom jitter. Default: 4.
  --fail-anchor-x <px>        Hard fail threshold for lower-body X jitter. Default: 6.
  --duplicate-score <n>       Motion score under this is treated as a near-duplicate transition. Default: 0.05.
  --min-motion-score <n>      Only enforce temporal checks when max motion reaches this score. Default: 0.12.
  --max-motion-imbalance <n>  Hard fail threshold for uneven transition motion. Default: 6.
  --max-loop-spike <n>        Hard fail threshold for first/last loop discontinuity. Default: 2.5.
  --help                      Show this help.

Exit codes:
  0 pass
  2 fixable, auto-alignment or regeneration required
  3 fail, regeneration recommended
  1 invalid input or script error
`);
};

const args = process.argv.slice(2);
if (args.length === 0 || args.includes('--help') || args.includes('-h')) {
	printUsage();
	process.exit(args.length === 0 ? 1 : 0);
}

const options = {};
let spriteJsonPath;
let json = false;
let fixPath;
for (let i = 0; i < args.length; i += 1) {
	const arg = args[i];
	if (arg === '--json') json = true;
	else if (arg === '--action') options.action = args[++i];
	else if (arg === '--image') options.imagePath = args[++i];
	else if (arg === '--fix') fixPath = args[++i];
	else if (arg === '--alpha') options.alphaThreshold = Number(args[++i]);
	else if (arg === '--pass-bottom') options.passBottomJitterPx = Number(args[++i]);
	else if (arg === '--pass-anchor-x') options.passAnchorXJitterPx = Number(args[++i]);
	else if (arg === '--fixable-shift') options.fixableShiftPx = Number(args[++i]);
	else if (arg === '--fail-bottom') options.failBottomJitterPx = Number(args[++i]);
	else if (arg === '--fail-anchor-x') options.failAnchorXJitterPx = Number(args[++i]);
	else if (arg === '--duplicate-score') options.duplicateMotionScore = Number(args[++i]);
	else if (arg === '--min-motion-score') options.minNonStaticMotionScore = Number(args[++i]);
	else if (arg === '--max-motion-imbalance') options.maxMotionImbalanceRatio = Number(args[++i]);
	else if (arg === '--max-loop-spike') options.maxLoopSpikeRatio = Number(args[++i]);
	else if (arg.startsWith('--')) throw new Error(`unknown option: ${arg}`);
	else if (!spriteJsonPath) spriteJsonPath = arg;
	else throw new Error(`unexpected argument: ${arg}`);
}

try {
	if (!spriteJsonPath) throw new Error('missing .sprite.json path');
	let report = evaluateImageSprite(spriteJsonPath, options);
	let exitStatusReport;
	if (fixPath) {
		const resolvedFixPath = path.resolve(process.cwd(), fixPath);
		report = writeAlignedImageSprite(spriteJsonPath, resolvedFixPath, options);
		report.fixedEvaluation = evaluateImageSprite(spriteJsonPath, { ...options, imagePath: resolvedFixPath });
		exitStatusReport = report.fixedEvaluation;
	} else {
		exitStatusReport = report;
	}
	if (json) {
		console.log(JSON.stringify(report, undefined, 2));
	} else {
		console.log(`image-sprite quality: ${report.status}`);
		console.log(`sprite: ${report.spriteJsonPath}`);
		console.log(`image:  ${report.imagePath}`);
		console.log(`action: ${report.action.id} (${report.action.name}) frames=${report.metrics.frameCount} fps=${report.action.fps}`);
		console.log(`bottom jitter: ${report.metrics.bottomJitterPx.toFixed(2)}px`);
		console.log(`anchor X jitter: ${report.metrics.anchorXJitterPx.toFixed(2)}px`);
		console.log(`max suggested shift: ${report.metrics.maxSuggestedShiftPx}px`);
		console.log(`temporal motion: min=${report.metrics.temporalMinMotionScore.toFixed(4)} median=${report.metrics.temporalMedianMotionScore.toFixed(4)} max=${report.metrics.temporalMaxMotionScore.toFixed(4)} imbalance=${report.metrics.temporalMotionImbalanceRatio.toFixed(2)}x`);
		console.log(`loop motion: score=${report.metrics.loopMotionScore.toFixed(4)} spike=${report.metrics.loopSpikeRatio.toFixed(2)}x`);
		if (report.temporalPairs?.length > 0) {
			const pairs = report.temporalPairs.map((pair) => `F${pair.fromFrameIndex + 1}->F${pair.toFrameIndex + 1}:${pair.motionScore.toFixed(4)}`).join(', ');
			console.log(`temporal transitions: ${pairs}`);
		}
		for (const warning of report.warnings) console.log(`warning: ${warning}`);
		for (const issue of report.issues) console.log(`issue: ${issue}`);
		if (report.outputImagePath) console.log(`fixed image: ${report.outputImagePath}`);
		if (report.fixedEvaluation) console.log(`fixed image quality: ${report.fixedEvaluation.status}`);
	}
	process.exit(exitStatusReport.status === 'pass' ? 0 : (exitStatusReport.status === 'fixable' ? 2 : 3));
} catch (error) {
	console.error(error instanceof Error ? error.message : String(error));
	process.exit(1);
}
