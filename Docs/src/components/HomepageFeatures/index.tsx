import React, {JSX, useEffect, useRef, useState} from 'react';
import clsx from 'clsx';
import Translate from '@docusaurus/Translate';
import styles from './styles.module.css';

const pixDora = require('@site/static/img/art/pixel/dora.png');
const pixToto = require('@site/static/img/art/pixel/toto.png');
const featureImgOne = require('@site/static/img/art/casual/1.png');
const featureImgTwo = require('@site/static/img/art/casual/2.png');
const featureImgThree = require('@site/static/img/art/casual/3.png');

type FeatureItem = {
	title: JSX.Element;
	image: React.ReactNode;
	description: JSX.Element;
};

function LazyImage({src, alt, className}: {src: string; alt: string; className?: string}) {
	const imgRef = useRef<HTMLDivElement>(null);
	const [isLoaded, setIsLoaded] = useState(false);

	useEffect(() => {
		const observer = new IntersectionObserver((entries) => {
			if (entries.some((entry) => entry.isIntersecting)) {
				setIsLoaded(true);
				observer.disconnect();
			}
		}, {rootMargin: '160px', threshold: 0.05});
		if (imgRef.current) observer.observe(imgRef.current);
		return () => observer.disconnect();
	}, []);

	return (
		<div ref={imgRef} className={clsx(styles.imageFrame, className)}>
			{isLoaded
				? <img src={src} alt={alt} loading="lazy"/>
				: <span className={styles.imagePlaceholder}/>
			}
		</div>
	);
}

const PromotionFeatureList: FeatureItem[] = [
	{
		title: <Translate id="feature_title_two">Game Dev Freedom</Translate>,
		image: <LazyImage src={featureImgTwo.default} alt="Portable game development" className={styles.promotionImage}/>,
		description: <Translate id="feature_description_two">Developing Games on Portable Devices Anywhere, with Lightning Speed!</Translate>,
	},
	{
		title: <Translate id="feature_title_three">Multilingual Playground</Translate>,
		image: <LazyImage src={featureImgThree.default} alt="Multilingual game development" className={styles.promotionImage}/>,
		description: <Translate id="feature_description_three">Satisfy your coding cravings with versatile language support!</Translate>,
	},
	{
		title: <Translate id="feature_title_one">Play as You Create</Translate>,
		image: <LazyImage src={featureImgOne.default} alt="Live game creation" className={styles.promotionImage}/>,
		description: <Translate id="feature_description_one">Making Game Development a New Gaming.</Translate>,
	},
];

const CoreFeatureList: FeatureItem[] = [
	{
		title: <Translate id="core_feature_title_web_ide">A Web IDE Connected to the Runtime</Translate>,
		image: <LazyImage src={require('@site/static/img/showcase/web-ide-retina.jpg').default} alt="Dora SSR Web IDE editing an FPSDemo TypeScript project"/>,
		description: <Translate id="core_feature_description_web_ide">Edit typed game code, browse project assets, inspect logs, build, and run without leaving the browser. The engine stays on the target device, so every iteration happens against the real runtime.</Translate>,
	},
	{
		title: <Translate id="engine_feature_title_dora_agent">Coding Agent</Translate>,
		image: <LazyImage src={require('@site/static/img/showcase/dora-agent-retina.jpg').default} alt="Coding Agent completing a project analysis task inside Dora SSR"/>,
		description: <Translate id="engine_feature_description_dora_agent">Coding Agent brings LLM AI assisted coding right into the engine, combining project skills, persistent memory, safe edits, build checks, runtime validation, and sub-agent delegation for multi-step development tasks.</Translate>,
	},
	{
		title: <Translate id="core_feature_title_3d">Lightweight 3D, Ready for Gameplay</Translate>,
		image: <LazyImage src={require('@site/static/img/showcase/dora-3d-model.jpg').default} alt="Detailed 3D helmet model and asynchronous loading diagnostics in Dora SSR"/>,
		description: <Translate id="core_feature_description_3d">Build playable 3D scenes with glTF, PBR and IBL, skeletal and morph animation, real-time lights and shadows, Jolt physics, picking, and 2D interfaces placed directly in 3D worlds.</Translate>,
	},
	{
		title: <Translate id="engine_feature_title_cross_platform_game_dev_support">Develop on the Device You Ship</Translate>,
		image: <LazyImage src={require('@site/static/img/article/dora-on-android.jpg').default} alt="Dora SSR Web IDE connected to a phone running the engine"/>,
		description: <Translate id="engine_feature_description_cross_platform_game_dev_support">Run Dora SSR on phones, open-source handhelds, desktops, and tablets, then connect from a browser on the same device or across the local network for a fast, direct development loop.</Translate>,
	},
];

const ToolFeatureList: FeatureItem[] = [
	{
		title: <Translate id="engine_feature_title_dora_animation_editor">Animation Editor</Translate>,
		image: <LazyImage src={require('@site/static/img/showcase/dora-animation-editor.jpg').default} alt="Dora SSR animation editor"/>,
		description: <Translate id="engine_feature_description_dora_animation_editor">Create and edit 2D model animations with a visual tree, key frames, clips, playback, and transform tools in one workflow.</Translate>,
	},
	{
		title: <Translate id="engine_feature_title_physics_editor">Physics Editor</Translate>,
		image: <LazyImage src={require('@site/static/img/showcase/dora-physics-editor.jpg').default} alt="Dora SSR Web IDE physics body editor"/>,
		description: <Translate id="engine_feature_description_physics_editor">Build 2D rigid bodies and joints visually, edit collision shapes and physical properties, preview motion, and save reusable .b.lua definitions without leaving the Web IDE.</Translate>,
	},
	{
		title: <Translate id="engine_feature_title_particle_editor">Particle Editor</Translate>,
		image: <LazyImage src={require('@site/static/img/showcase/dora-particle-editor.jpg').default} alt="Dora SSR Web IDE particle editor with live effect preview"/>,
		description: <Translate id="engine_feature_description_particle_editor">Tune emission, lifetime, color, size, rotation, texture, blend mode, gravity, and ready-made presets with a live preview, then save runtime-ready .par effects.</Translate>,
	},
	{
		title: <Translate id="engine_feature_title_yarn_spinner_editor">Yarn Story Editor</Translate>,
		image: <LazyImage src={require('@site/static/img/showcase/dora-yarn-editor.jpg').default} alt="Yarn story editor with script and node graph views"/>,
		description: <Translate id="engine_feature_description_yarn_spinner_editor">Design branching dialogue and game narrative with an integrated visual node editor and a runtime-ready Yarn workflow.</Translate>,
	},
	{
		title: <Translate id="engine_feature_title_visual_script_editor">Visual Script Editor</Translate>,
		image: <LazyImage src={require('@site/static/img/showcase/dora-visual-script-editor.jpg').default} alt="Dora SSR visual script editor with connected logic nodes"/>,
		description: <Translate id="engine_feature_description_visual_script_editor">The built-in Visual Script editor lowers the programming barrier with graphical programming while fostering logical thinking and problem-solving skills.</Translate>,
	},
	{
		title: <Translate id="engine_feature_title_blockly">Blockly Scripting</Translate>,
		image: <LazyImage src={require('@site/static/img/showcase/blockly.jpg').default} alt="Blockly scripting in Dora SSR"/>,
		description: <Translate id="engine_feature_description_blockly">Create game behavior with approachable puzzle-like blocks, useful for teaching, prototyping, and first-time creators.</Translate>,
	},
	{
		title: <Translate id="engine_feature_title_skeletal_animation">2D Animation Ecosystem</Translate>,
		image: <LazyImage src={require('@site/static/img/showcase/dora-spine-animation.jpg').default} alt="Spine skeletal animation preview in Dora SSR Web IDE"/>,
		description: <Translate id="engine_feature_description_skeletal_animation">Use Spine2D, DragonBones, and Dora's built-in skeletal animation format with integrated preview, skin switching, and playback.</Translate>,
	},
	{
		title: <Translate id="engine_feature_title_tsx_reactive_ui">Declarative TSX Scenes and Reactive UI</Translate>,
		image: <LazyImage src={require('@site/static/img/showcase/dora-tsx-reactive-ui.jpg').default} alt="Dora SSR TSX code alongside its reactive UI running in the native runtime"/>,
		description: <Translate id="engine_feature_description_tsx_reactive_ui">Build game scenes and interfaces with TypeScript and TSX components. Built-in ReactJS-style APIs bring a modern frontend workflow to the native game runtime.</Translate>,
	},
	{
		title: <Translate id="engine_feature_title_tiled_map">Tiled Map Rendering</Translate>,
		image: <LazyImage src={require('@site/static/img/showcase/5.jpg').default} alt="Tiled map rendered in Dora SSR"/>,
		description: <Translate id="engine_feature_description_tiled_map">Load and render Tiled maps with a compact engine API for fast construction of layered 2D worlds.</Translate>,
	},
	{
		title: <Translate id="engine_feature_title_tic80">Built-in TIC-80 Runtime and Editor</Translate>,
		image: <LazyImage src={require('@site/static/img/showcase/dora-tic80-editor.jpg').default} alt="TIC-80 sprite editor running inside Dora SSR Web IDE"/>,
		description: <Translate id="engine_feature_description_tic80">Open, run, and edit TIC-80 fantasy-console cartridges directly in the Web IDE, with the bundled runtime and creative tools for code, sprites, maps, sound, and music. Embed a retro game terminal inside your modern 2D or 3D game creations.</Translate>,
	},
	{
		title: <Translate id="engine_feature_platformer_game_support">Platformer Game Support</Translate>,
		image: <LazyImage src={require('@site/static/img/showcase/LoliWar.gif').default} alt="Platformer game built with Dora SSR"/>,
		description: <Translate id="engine_feature_description_platformer_game_support">Use dedicated physics, collision detection, and action-system modules to create smooth and expressive platformer games.</Translate>,
	},
	{
		title: <Translate id="engine_feature_ml_and_ai_framework">Built-in ML and AI Framework</Translate>,
		image: <LazyImage src={require('@site/static/img/showcase/ZombieEscape.jpg').default} alt="Game using Dora SSR machine learning and AI frameworks"/>,
		description: <Translate id="engine_feature_description_ml_and_ai_framework">Build intelligent game behavior and advanced data processing with integrated machine-learning algorithms and AI development frameworks.</Translate>,
	},
	{
		title: <Translate id="engine_feature_profiling_and_debugging_tools">Profiling and Debugging</Translate>,
		image: <LazyImage src={require('@site/static/img/showcase/dora-3d-debugging.jpg').default} alt="Dora SSR runtime performance profiler and debugging console"/>,
		description: <Translate id="engine_feature_description_profiling_and_debugging_tools">Inspect frame time, rendering work, resident resources, physics state, lights, frustums, and bounding boxes while the real scene is running.</Translate>,
	},
	{
		title: <Translate id="engine_feature_title_git_client">Built-in Git Client</Translate>,
		image: <LazyImage src={require('@site/static/img/showcase/dora-git-client.jpg').default} alt="Dora SSR built-in Git client showing commit history, remotes, and file changes"/>,
		description: <Translate id="engine_feature_description_git_client">Review local changes, commit history, and line-by-line diffs; manage branches, remotes, and tags; then fetch, pull, and push without leaving the project.</Translate>,
	},
	{
		title: <Translate id="engine_feature_open_art_assets_and_game_ip">Open Art Assets and Game IP</Translate>,
		image: <LazyImage src={require('@site/static/img/showcase/LuvSenseDigital.jpg').default} alt="Luv Sense Digital open game assets"/>,
		description: <Translate id="engine_feature_description_open_art_assets_and_game_ip">Start faster with the open Luv Sense Digital art assets and game IP, available for creating your own game experiences.</Translate>,
	},
];

const languages = [
	{src: require('@site/static/img/lang/lua.png').default, alt: 'Lua'},
	{src: require('@site/static/img/lang/typescript.png').default, alt: 'TypeScript'},
	{src: require('@site/static/img/lang/teal.png').default, alt: 'Teal'},
	{src: require('@site/static/img/lang/yuescript.png').default, alt: 'YueScript'},
	{src: '/img/lang/wa.svg', alt: 'Wa'},
	{src: require('@site/static/img/lang/rust.png').default, alt: 'Rust', wide: true},
	{src: '/img/lang/csharp.svg', alt: 'C#'},
];

function PromotionFeature({title, image, description}: FeatureItem) {
	return (
		<article className={styles.promotionFeature}>
			{image}
			<div className={styles.cardText}><h3>{title}</h3><p>{description}</p></div>
		</article>
	);
}

function FeatureCard({title, image, description, featured = false}: FeatureItem & {featured?: boolean}) {
	return (
		<div className={clsx('col', featured ? 'col--6' : 'col--4', styles.cardColumn)}>
			<article className={clsx(styles.featureCard, featured && styles.featureCardLarge)}>
				{image}
				<div className={styles.featureCardBody}><h3>{title}</h3><p>{description}</p></div>
			</article>
		</div>
	);
}

function SectionHeading({id, children, mascot}: {id: string; children: React.ReactNode; mascot?: 'dora' | 'toto'}) {
	return (
		<div className={styles.sectionHeading}>
			{mascot && (
				<img src={(mascot === 'dora' ? pixDora : pixToto).default} alt="" className={styles.pixImg}/>
			)}
			<h2><Translate id={id}>{children}</Translate></h2>
		</div>
	);
}

export default function HomepageFeatures(): JSX.Element {
	return (
		<section className={styles.features}>
			<div className="container">
				<section className={styles.featureSection}>
					<SectionHeading id="promotion_section_title" mascot="dora">Why Dora SSR</SectionHeading>
					<div className={styles.promotionGrid}>{PromotionFeatureList.map((item, index) => <PromotionFeature key={index} {...item}/>)}</div>
				</section>

				<section className={styles.featureSection}>
					<SectionHeading id="core_feature_section_title" mascot="toto">A Complete Game-Making Loop</SectionHeading>
					<p className={styles.sectionLead}><Translate id="core_feature_section_description">Code, ask an agent for help, run on the target device, inspect the result, and iterate—all inside one connected workflow.</Translate></p>
					<div className="row">{CoreFeatureList.map((item, index) => <FeatureCard key={index} {...item} featured/>)}</div>
				</section>

				<section className={styles.featureSection}>
					<SectionHeading id="tool_feature_section_title">Built-in Tools for Real Projects</SectionHeading>
					<div className="row">{ToolFeatureList.map((item, index) => <FeatureCard key={index} {...item}/>)}</div>
				</section>

				<section className={styles.languageSection}>
					<SectionHeading id="language_feature_section_title">Choose the Language That Fits</SectionHeading>
					<p className={styles.sectionLead}><Translate id="language_feature_section_description">Use lightweight Lua-family scripting, typed TypeScript and TSX, WebAssembly languages, or native-style C# bindings without leaving the Dora ecosystem.</Translate></p>
					<div className={styles.languageGrid}>
						{languages.map((language) => (
							<div className={styles.languageItem} key={language.alt}>
								<img src={language.src} alt="" className={clsx(styles.languageLogo, language.wide && styles.languageLogoWide)}/>
								<span>{language.alt}</span>
							</div>
						))}
					</div>
				</section>
			</div>
		</section>
	);
}
