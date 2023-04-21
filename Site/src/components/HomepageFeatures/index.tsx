import React from 'react';
import clsx from 'clsx';
import styles from './styles.module.css';
import Translate from '@docusaurus/Translate';

type FeatureItem = {
	title: JSX.Element;
	Svg: React.ComponentType<React.ComponentProps<'svg'>>;
	description: JSX.Element;
};

const FeatureList: FeatureItem[] = [
	{
		title: (
			<Translate
				id="feature_title_one"
				description='The feature title one in front page'>
				Play as You Create
			</Translate>
		),
		Svg: require('@site/static/img/undraw_docusaurus_mountain.svg').default,
		description: (
			<Translate
				id="feature_description_one"
				description='The feature description one in front page'>
				What Dorothy SSR is for: Making Game Development a New Gaming.
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
		Svg: require('@site/static/img/undraw_docusaurus_tree.svg').default,
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
		Svg: require('@site/static/img/undraw_docusaurus_react.svg').default,
		description: (
			<Translate
				id='feature_description_three'
				description='The feature description three in front page'>
				Satisfy your coding cravings with Dorothy SSR's versatile language support!
			</Translate>
		),
	},
];

function Feature({title, Svg, description}: FeatureItem) {
	return (
		<div className={clsx('col col--4')}>
			<div className="text--center">
				<Svg className={styles.featureSvg} role="img" />
			</div>
			<div className="text--center padding-horiz--md">
				<h3>{title}</h3>
				<p>{description}</p>
			</div>
		</div>
	);
}

export default function HomepageFeatures(): JSX.Element {
	return (
		<section className={styles.features}>
			<div className="container">
				<div className="row">
					{FeatureList.map((props, idx) => (
						<Feature key={idx} {...props} />
					))}
				</div>
			</div>
		</section>
	);
}
