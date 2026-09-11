import React, {useEffect, useRef, useState} from 'react';
import Layout from '@theme/Layout';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import styles from './play.module.css';

type Game = {id: string; title: string; cover: string | null; source: string};
type Catalog = {player: string; games: Game[]};
export default function Play() {
	const {siteConfig, i18n} = useDocusaurusContext();
	// Share runtime URLs and browser cache across all documentation locales.
	const base = String(siteConfig.customFields?.galleryBaseUrl ?? '/play/');
	const zh = i18n.currentLocale === 'zh-Hans';
	const [catalog, setCatalog] = useState<Catalog | null>(null);
	const [error, setError] = useState('');
	const [active, setActive] = useState<Game | null>(null);
	const [generation, setGeneration] = useState(0);
	const frame = useRef<HTMLIFrameElement>(null);
	const stage = useRef<HTMLElement>(null);
	useEffect(() => {
		const controller = new AbortController();
		fetch(`${base}catalog.json`, {signal: controller.signal, cache: 'no-cache'})
			.then(response => {if (!response.ok) throw new Error('catalog'); return response.json();})
			.then(setCatalog).catch(error => {if (error.name !== 'AbortError') setError(zh ? '试玩暂时不可用，请稍后重试。' : 'Games are temporarily unavailable. Please try again later.');});
		return () => controller.abort();
	}, [base, zh]);
	useEffect(() => {
		if (!active) return;
		let secondFrame = 0;
		const firstFrame = window.requestAnimationFrame(() => {
			secondFrame = window.requestAnimationFrame(() => stage.current?.scrollIntoView({
				behavior: window.matchMedia('(prefers-reduced-motion: reduce)').matches ? 'auto' : 'smooth',
				block: 'start',
			}));
		});
		return () => {
			window.cancelAnimationFrame(firstFrame);
			window.cancelAnimationFrame(secondFrame);
		};
	}, [active]);
	const url = active && catalog ? `${base}${catalog.player}?game=${encodeURIComponent(active.id)}` : '';
	return <Layout title={zh ? '在线试玩' : 'Play'}>
		<main className={`container ${styles.gallery}`}>
			<h1>{zh ? '在线试玩' : 'Play Dora games'}</h1>
			<p>{zh ? '选择一款游戏开始。点击游戏画面获取键盘焦点，操作方式见游戏内提示。' : 'Choose a game to start. Click the game to focus the keyboard; follow its in-game controls.'}</p>
			{error && <p role="alert">{error}</p>}
			{!catalog && !error && <p role="status">{zh ? '加载游戏列表…' : 'Loading games…'}</p>}
			{active && <section ref={stage} className={styles.stage}>
				<div className={styles.toolbar}><h2>{active.title}</h2>
					<button className={styles.stageAction} onClick={() => setGeneration(value => value+1)}>{zh ? '重新开始' : 'Restart'}</button>
					<button className={styles.stageAction} onClick={() => frame.current?.requestFullscreen().catch(() => setError(zh ? '请使用独立窗口打开游戏。' : 'Please open the game in a new window.'))}>{zh ? '全屏' : 'Fullscreen'}</button>
					<a className={styles.stageAction} href={url} target="_blank" rel="noopener noreferrer">{zh ? '独立窗口' : 'New window'}</a>
					<button className={styles.stageAction} onClick={() => setActive(null)}>{zh ? '关闭游戏' : 'Close'}</button>
				</div>
				<iframe key={`${active.id}-${generation}`} ref={frame} title={active.title} src={url} allow="fullscreen; autoplay" allowFullScreen />
			</section>}
			<div className={styles.cards}>{catalog?.games.map(game => <article key={game.id}>
				{game.cover && <img src={`${base}${game.cover}`} alt="" loading="lazy" />}
				<h2>{game.title}</h2><div className={styles.toolbar}>
				<button className="button button--primary" onClick={() => {setActive(game); setGeneration(0);}}>{zh ? '开始游戏' : 'Play'}</button>
				<a href={game.source} target="_blank" rel="noopener noreferrer">{zh ? '查看源码' : 'Source'}</a>
				</div></article>)}</div>
		</main>
	</Layout>;
}
