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

const FeatureList: FeatureItem[] = [
	{
		title: (
			<Translate
				id="feature_title_one"
				description='The feature title one in front page'>
				Play as You Create
			</Translate>
		),
		image: <img src={feature_img_one.default} alt='feature_title_one'/>,
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
		image: <img src={feature_img_two.default} alt='feature_title_two'/>,
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
		image: <img src={feature_img_three.default} alt='feature_title_three'/>,
		description: (
			<Translate
				id='feature_description_three'
				description='The feature description three in front page'>
				Satisfy your coding cravings with Dorothy SSR's versatile language support!
			</Translate>
		),
	},
];

function Feature({title, Svg, image, description}: FeatureItem) {
	return (
		<div className={clsx('col col--4')}>
			<div className="text--center">
				{Svg ? <Svg className={styles.featureSvg} role="img"/> : image}
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
