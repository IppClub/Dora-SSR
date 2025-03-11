import React, { JSX } from 'react';
import clsx from 'clsx';
import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Layout from '@theme/Layout';
import styles from './index.module.css';
import Translate from '@docusaurus/Translate';
import HomepageFeatures from '@site/src/components/HomepageFeatures';

function HomepageHeader() {
	return (
		<header className={clsx('hero hero--primary', styles.heroBanner)}>
			<div className="container">
				<h1 className={clsx('hero__title', styles.heroTitle)}>
					<Translate
						id='hero_title'
						description='The title in front page'>
						Dora SSR
					</Translate>
				</h1>
				<p className={clsx('hero__subtitle', styles.heroSubtitle)}><strong>Dora</strong> (<strong>S</strong>pecial <strong>S</strong>uper <strong>R</strong>are) <strong><Translate
					id='hero_subtitle'
					description='The subtitle in front page'>
					Game Engine
				</Translate></strong><br/><strong><Link
					to="/docs/tutorial/quick-start">
					<Translate
						id='dora_enter_tutorial_button'
						description='The tutorial button in front page'>
						[Start &lt;]
					</Translate>
				</Link></strong></p>
			</div>
		</header>
	);
}

export default function Home(): JSX.Element {
	const {siteConfig} = useDocusaurusContext();

	return (
		<Layout
			title={`${siteConfig.title}`}
			description="A game engine for rapid development across devices, featuring a built-in Web IDE with intuitive toolchain.">
			<HomepageHeader />
			<main>
				<HomepageFeatures />
			</main>
		</Layout>
	);
}
