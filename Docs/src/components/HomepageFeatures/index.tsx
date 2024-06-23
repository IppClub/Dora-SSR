import React from 'react';
import clsx from 'clsx';
import styles from './styles.module.css';
import Translate from '@docusaurus/Translate';

const feature_img_one = require('@site/static/img/1.png');
const feature_img_two = require('@site/static/img/2.png');
const feature_img_three = require('@site/static/img/3.png');

type FeatureItem = {
	title: JSX.Element;
	Svg?: React.ComponentType<React.ComponentProps<'svg'>>;
	image?: React.ReactNode;
	description: JSX.Element;
};

const PromotionFeatureList: FeatureItem[] = [
	{
		title: (
			<Translate
				id="feature_title_one"
				description='The feature title one in front page'>
				Play as You Create
			</Translate>
		),
		image: <img src={feature_img_one.default} alt='feature_title_one' className={styles.featureImg}/>,
		description: (
			<Translate
				id="feature_description_one"
				description='The feature description one in front page'>
				What Dora SSR is for: Making Game Development a New Gaming.
			</Translate>
		),
	},
	{
		title: (
			<Translate
				id='feature_title_two'
				description='The feature title two in front page'>
				Game Dev Freedom
			</Translate>
		),
		image: <img src={feature_img_two.default} alt='feature_title_two' className={styles.featureImg}/>,
		description: (
			<Translate
				id='feature_description_two'
				description='The feature description two in front page'>
				Start Developing on Portable Devices Anywhere, with Lightning Speed!
			</Translate>
		),
	},
	{
		title: (
			<Translate id='feature_title_three' description='The feature title three in front page'>
				Multilingual Playground
			</Translate>
		),
		image: <img src={feature_img_three.default} alt='feature_title_three' className={styles.featureImg}/>,
		description: (
			<Translate
				id='feature_description_three'
				description='The feature description three in front page'>
				Satisfy your coding cravings with Dora SSR's versatile language support!
			</Translate>
		),
	},
];

function PromotionFeature({title, Svg, image, description}: FeatureItem) {
	return (
		<div className={clsx('col col--4')}>
			<div className="text--center">
				{Svg ? <Svg className={styles.featureImg} role="img"/> : image}
			</div>
			<div className="text--center padding-horiz--md">
				<h3>{title}</h3>
				<p>{description}</p>
			</div>
		</div>
	);
}

const EngineFeatureList: FeatureItem[] = [
	{
		title: (
			<Translate
				id='engine_feature_title_code_editor'
				description='The engine feature title Powerful Code Editor in front page'>
				Powerful Code Editor
			</Translate>
		),
		image: <img src={require('@site/static/img/showcase1.jpg').default} alt='Powerful Code Editor' className={styles.featureImgFixed}/>,
		description: (
			<Translate
				id='engine_feature_description_code_editor'
				description='The engine feature description Powerful Code Editor in front page'>
				The Web IDE of Dora SSR supports multiple programming languages and file types, featuring syntax highlighting, auto-completion, and document navigation.
			</Translate>
		),
	},
	{
		title: (
			<Translate
				id='engine_feature_title_yarn_spinner_editor'
				description='The engine feature description Intuitive Yarn Spinner Script Editor in front page'>
				Intuitive Yarn Spinner Script Editor
			</Translate>
		),
		image: <img src={require('@site/static/img/showcase2.jpg').default} alt='Intuitive Yarn Spinner Script Editor' className={styles.featureImgFixed}/>,
		description: (
			<Translate
				id='engine_feature_description_yarn_spinner_editor'
				description='The engine feature description Intuitive Yarn Spinner Script Editor'>
				The integrated Yarn Spinner script editor offers intuitive storytelling tools, allowing complex plot design and management through visual node diagrams.
			</Translate>
		),
	},
	{
		title: (
			<Translate
				id='engine_feature_title_visual_script_editor'
				description='The engine feature title Visual Script Editor for Beginners in front page'>
				Visual Script Editor for Beginners
			</Translate>
		),
		image: <img src={require('@site/static/img/showcase3.jpg').default} alt='Visual Script Editor for Beginners' className={styles.featureImgFixed}/>,
		description: (
			<Translate
				id='engine_feature_description_visual_script_editor'
				description='The engine feature description Visual Script Editor for Beginners in front page'>
				The Visual Script editor, designed for beginners, lowers the programming barrier with graphical programming methods, fostering logical thinking and problem-solving skills.
			</Translate>
		),
	},
	{
		title: (
			<Translate
				id='engine_feature_title_skeletal_animation'
				description='The engine feature title Skeletal Animation Support in front page'>
				Skeletal Animation Support
			</Translate>
		),
		image: <img src={require('@site/static/img/showcase4.jpg').default} alt='Skeletal Animation Support' className={styles.featureImgFixed}/>,
		description: (
			<Translate
				id='engine_feature_description_skeletal_animation'
				description='The engine feature description Skeletal Animation Support in front page'>
				Built-in support for Spine2D, DragonBones and a self implemented 2D skeletal animation system. Integrated Spine2D preview feature allows skin switching and animation playback.
			</Translate>
		),
	},
	{
		title: (
			<Translate
				id='engine_feature_title_tiled_map'
				description='The engine feature title Tiled Map Rendering Support in front page'>
				Tiled Map Rendering Support
			</Translate>
		),
		image: <img src={require('@site/static/img/showcase5.jpg').default} alt='Tiled Map Rendering Support' className={styles.featureImgFixed}/>,
		description: (
			<Translate
				id='engine_feature_description_tiled_map'
				description='The engine feature description Tiled Map Rendering Support in front page'>
				Dora SSR supports tile maps created with Tiled Map Editor. With simple loading functions, developers can easily render complex tile maps in the engine.
			</Translate>
		),
	},
	{
		title: (
			<Translate
			 id='engine_feature_platformer_game_support'
			 description='The engine feature title Platformer Game Support in front page'>
				Platformer Game Support
			</Translate>
		),
		image: <img src={require('@site/static/img/LoliWar.gif').default} alt='Platformer Game Support' className={styles.featureImgFixed}/>,
		description: (
			<Translate
				id='engine_feature_description_platformer_game_support'
				description='The engine feature description Platformer Game Support in front page'>
				Dora SSR offers dedicated modules for platformer game development, including physics engine, collision detection, and action systems to easily create smooth and expressive platformer games.
			</Translate>
		),
	},
	{
		title: (
			<Translate
				id='engine_feature_ml_and_ai_framework'
				description='The engine feature title Built-in ML and AI Framework in front page'>
				Built-in ML and AI Framework
			</Translate>
		),
		image: <img src={require('@site/static/img/ZombieEscape.png').default} alt='Built-in ML and AI Framework' className={styles.featureImgFixed}/>,
		description: (
			<Translate
				id='engine_feature_description_ml_and_ai_framework'
				description='The engine feature description Built-in ML and AI Framework in front page'>
				Dora SSR includes built-in machine learning algorithm frameworks and AI development frameworks for easily implementing intelligent behaviors and advanced data processing in games, making them more interactive and smart.
			</Translate>
		),
	},
	{
		title: (
			<Translate
				id='engine_feature_open_art_assets_and_game_ip'
				description='The engine feature title Open Art Assets and Game IP in front page'>
				Open Art Assets and Game IP
			</Translate>
		),
		image: <img src={require('@site/static/img/LuvSenseDigital.png').default} alt='Open Art Assets and Game IP' className={styles.featureImgFixed}/>,
		description: (
			<Translate
				id='engine_feature_description_open_art_assets_and_game_ip'
				description='The engine feature description Open Art Assets and Game IP in front page'>
				Dora SSR offers open art assets and game IP—'Luv Sense Digital'—for creating your own games. Developers can freely use these resources to quickly build compelling game experiences.
			</Translate>
		),
	},
	{
		title: (
			<Translate
				id='engine_feature_lua_scripting_support'
				description='The engine feature title Lua Scripting Support in front page'>
				Lua Scripting Support
			</Translate>
		),
		image: <img src={require('@site/static/img/lua.png').default} alt='Lua Scripting Support' className={styles.featureImgFixed}/>,
		description: (
			<Translate
				id='engine_feature_description_lua_scripting_support'
				description='The engine feature description Lua Scripting Support in front page'>
				Dora SSR provides upgraded Lua binding with support for inheriting and extending low-level C++ objects.
			</Translate>
		),
	},
	{
		title: (
			<Translate
				id='engine_feature_yuescript_scripting_support'
				description='The engine feature title YueScript Scripting Support in front page'>
				YueScript Scripting Support
			</Translate>
		),
		image: <img src={require('@site/static/img/yuescript.png').default} alt='YueScript Scripting Support' className={styles.featureImgFixed} style={{padding: 40}}/>,
		description: (
			<Translate
				id='engine_feature_description_yuescript_scripting_support'
				description='The engine feature description YueScript Scripting Support in front page'>
				Dora SSR supports YueScript, a strong expressive and concise Lua dialect.
			</Translate>
		),
	},
	{
		title: (
			<Translate
				id='engine_feature_teal_scripting_support'
				description='The engine feature title Teal Scripting Support in front page'>
				Teal Scripting Support
			</Translate>
		),
		image: <img src={require('@site/static/img/teal.png').default} alt='Teal Scripting Support' className={styles.featureImgFixed} style={{padding: 40}}/>,
		description: (
			<Translate
				id='engine_feature_description_teal_scripting_support'
				description='The engine feature description Teal Scripting Support in front page'>
				Dora SSR supports Teal language, a statically typed dialect for Lua with full API documentation.
			</Translate>
		),
	},
	{
		title: (
			<Translate
				id='engine_feature_typescript_scripting_support'
				description='The engine feature title TypeScript Scripting Support in front page'>
				TypeScript Scripting Support
			</Translate>
		),
		image: <img src={require('@site/static/img/typescript.png').default} alt='TypeScript Scripting Support' className={styles.featureImgFixed} style={{padding: 40}}/>,
		description: (
			<Translate
				id='engine_feature_description_typescript_scripting_support'
				description='The engine feature description TypeScript Scripting Support in front page'>
				Dora SSR supports TypeScript, a statically typed superset of JavaScript that adds powerful type checking and embedding XML/HTML-like text within scripts named TSX.
			</Translate>
		),
	},
	{
		title: (
			<Translate
				id='engine_feature_rust_scripting_support'
				description='The engine feature title Rust Scripting Support in front page'>
				Rust Scripting Support
			</Translate>
		),
		image: <img src={require('@site/static/img/rust.png').default} alt='Rust Scripting Support' className={styles.featureImgFixed} style={{padding: 40}}/>,
		description: (
			<Translate
				id='engine_feature_description_rust_scripting_support'
				description='The engine feature description Rust Scripting Support in front page'>
				Dora SSR supports the Rust language, running on the built-in WASM runtime with Rust bindings.
			</Translate>
		),
	},
];

function Feature({title, Svg, image, description}: FeatureItem) {
	return (
		<div className={clsx('col col--4')} style={{marginBottom: '2em'}}>
			<div className={styles.featureCard}>
				<div className="text--center">
					{Svg ? <Svg className={styles.featureImg} role="img"/> : image}
				</div>
				<div className="text--center">
					<h3>{title}</h3>
					<p>{description}</p>
				</div>
			</div>
		</div>
	);
}

export default function HomepageFeatures(): JSX.Element {
	return (
		<section className={styles.features}>
			<div className="container">
				<div className={styles.featureSection}>
					<h2 className="text--center">
						<Translate
							id='promotion_section_title'
							description='The promotion section title in front page'>
							Why Dora SSR?
						</Translate>
					</h2>
					<div className="row">
						{PromotionFeatureList.map((props, idx) => (
							<PromotionFeature key={idx} {...props} />
						))}
					</div>
				</div>
				<div className={styles.featureSection}>
					<h2 className="text--center">
						<Translate
							id='feature_section_title'
							description='The feature section title in front page'>
							Game Engine Features
						</Translate>
					</h2>
					<div className="row">
						{EngineFeatureList.map((props, idx) => (
							<Feature key={idx} {...props} />
						))}
					</div>
				</div>
			</div>
		</section>
	);
}
