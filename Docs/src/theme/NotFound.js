import React from 'react';
import Translate from '@docusaurus/Translate';
import Link from '@docusaurus/Link';
import Layout from '@theme/Layout';
import clsx from 'clsx';
import styles from './not-found.module.css';

const pixDora = require('@site/static/img/art/pixel/dora.png');
const pixToto = require('@site/static/img/art/pixel/toto.png');

export default function NotFound(): JSX.Element {
	return (
		<Layout title="Page Not Found">
			<main className={clsx('container', styles.notFound)}>
				<div className={styles.mascots}>
					<img src={pixDora.default} alt="" className={styles.pix}/>
					<img src={pixToto.default} alt="" className={styles.pix}/>
				</div>
				<h1 className={styles.title}>
					<Translate id="not_found_title">Page Not Found</Translate>
				</h1>
				<p className={styles.description}>
					<Translate id="not_found_description">Dora and Toto could not find this page—it may have been moved or removed.</Translate>
				</p>
				<Link className="button button--primary button--lg" to="/">
					<Translate id="not_found_back_home">Back to Home</Translate>
				</Link>
			</main>
		</Layout>
	);
}
