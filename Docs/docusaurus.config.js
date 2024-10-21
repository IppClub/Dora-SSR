// @ts-check
// Note: type annotations allow type checking and IDEs autocompletion

import { themes } from 'prism-react-renderer';

const github = true;

const darkCodeTheme = {
	plain: {
		color: '#D4D4D4',
		backgroundColor: '#212121',
	},
	styles: [
		...themes.vsDark.styles,
		{
			types: ['title'],
			style: {
				color: '#569CD6',
				fontWeight: 'bold',
			},
		},
		{
			types: ['property', 'parameter'],
			style: {
				color: '#9CDCFE',
			},
		},
		{
			types: ['script'],
			style: {
				color: '#D4D4D4',
			},
		},
		{
			types: ['boolean', 'arrow', 'atrule', 'tag'],
			style: {
				color: '#569CD6',
			},
		},
		{
			types: ['number', 'color', 'unit'],
			style: {
				color: '#B5CEA8',
			},
		},
		{
			types: ['font-matter'],
			style: {
				color: '#CE9178',
			},
		},
		{
			types: ['keyword', 'rule'],
			style: {
				color: '#C586C0',
			},
		},
		{
			types: ['regex'],
			style: {
				color: '#D16969',
			},
		},
		{
			types: ['maybe-class-name'],
			style: {
				color: '#4EC9B0',
			},
		},
		{
			types: ['constant'],
			style: {
				color: '#4FC1FF',
			},
		},
	],
};

const lightCodeTheme = {
	...themes.github,
	styles: [
		...themes.github.styles,
		{
			types: ['title'],
			style: {
				color: '#0550AE',
				fontWeight: 'bold',
			},
		},
		{
			types: ['parameter'],
			style: {
				color: '#953800',
			},
		},
		{
			types: ['boolean', 'rule', 'color', 'number', 'constant', 'property'],
			style: {
				color: '#005CC5',
			},
		},
		{
			types: ['atrule', 'tag'],
			style: {
				color: '#af893b',
			},
		},
		{
			types: ['script'],
			style: {
				color: '#24292E',
			},
		},
		{
			types: ['operator', 'unit', 'rule'],
			style: {
				color: '#D73A49',
			},
		},
		{
			types: ['font-matter', 'string', 'attr-value'],
			style: {
				color: '#C6105F',
			},
		},
		{
			types: ['class-name'],
			style: {
				color: '#af893b',
			},
		},
		{
			types: ['attr-name'],
			style: {
				color: '#0099CC',
			},
		},
		{
			types: ['keyword'],
			style: {
				color: '#CF222E',
			},
		},
		{
			types: ['function'],
			style: {
				color: '#c89c48',
			},
		},
		{
			types: ['selector'],
			style: {
				color: '#6F42C1',
			},
		},
		{
			types: ['variable'],
			style: {
				color: '#E36209',
			},
		},
		{
			types: ['comment'],
			style: {
				color: '#6B6B6B',
				fontStyle: 'normal',
			},
		},
	],
};

/** @type {import('@docusaurus/types').Config} */
const config = {
	title: 'Dora SSR',
	tagline: 'The Dora project, Special Super Rare edition.',
	favicon: 'img/favicon.ico',

	// Set the production url of your site here
	url: github ? 'https://dora-ssr.net' : 'https://ippclub.atomgit.net',
	// Set the /<baseUrl>/ pathname under which your site is served
	// For GitHub pages deployment, it is often '/<projectName>/'
	baseUrl: github ? '/' : '/Dora-SSR/',

	// GitHub pages deployment config.
	// If you aren't using GitHub pages, you don't need these.
	organizationName: 'ippclub', // Usually your GitHub org/user name.
	projectName: 'Dora-SSR', // Usually your repo name.

	onBrokenLinks: 'throw',
	onBrokenMarkdownLinks: 'warn',

	// Even if you don't use internalization, you can use this field to set useful
	// metadata like html lang. For example, if your site is Chinese, you may want
	// to replace "en" with "zh-Hans".
	i18n: {
		defaultLocale: 'en',
		locales: ['en', 'zh-Hans'],
	},

	presets: [
		[
			'classic',
			/** @type {import('@docusaurus/preset-classic').Options} */
			({
				docs: {
					sidebarPath: require.resolve('./sidebars.js'),
					// Please change this to your repo.
					// Remove this to remove the "edit this page" links.
					editUrl: github ?
						'https://github.com/ippclub/Dora-SSR/tree/main/Docs' :
						'https://atomgit.com/ippclub/Dora-SSR/blob/main/Docs',
					sidebarCollapsed: false,
					showLastUpdateAuthor: true,
					showLastUpdateTime: true,
					lastVersion: 'current',
					versions: {
						current: {
							label: 'v1.5.19',
						},
					},
				},
				blog: {
					showReadingTime: true,
					// Please change this to your repo.
					// Remove this to remove the "edit this page" links.
					editUrl: github ?
						'https://github.com/ippclub/Dora-SSR/tree/main/Docs' :
						'https://atomgit.com/ippclub/Dora-SSR/blob/main/Docs',
				},
				theme: {
					customCss: require.resolve('./src/css/custom.css'),
				},
			}),
		],
	],

	themeConfig:
	/** @type {import('@docusaurus/preset-classic').ThemeConfig} */
	({
		// Replace with your project's social card
		image: 'img/dora-ssr-social-card.jpg',
		navbar: {
			title: 'Dora SSR',
			logo: {
				alt: 'Dora SSR Logo',
				src: 'img/logo.svg',
			},
			items: [
				{
					type: 'docSidebar',
					sidebarId: 'tutorialSidebar',
					label: 'Tutorial',
					position: 'left',
				},
				{
					type: 'docSidebar',
					sidebarId: 'apiSidebar',
					label: 'Reference',
					position: 'left',
				},
				{
					to: '/blog',
					label: 'Blog',
					position: 'left'
				},
				{
					type: 'docsVersionDropdown',
					position: 'right',
				},
				{
					type: 'localeDropdown',
					position: 'right',
				},
				{
					href: github ?
						'https://github.com/ippclub/Dora-SSR' :
						'https://atomgit.com/ippclub/Dora-SSR',
					label:  github ? 'GitHub' : 'AtomGit',
					position: 'right',
				},
			],
		},
		footer: {
			style: 'dark',
			links: [
				{
					title: 'Docs',
					items: [
						{
							label: 'Tutorial',
							to: '/docs/tutorial/quick-start',
						},
						{
							label: 'API Reference',
							to: '/docs/api/intro',
						},
					],
				},
				{
					title: 'Community',
					items: [
						{
							label: 'Discord',
							href: 'https://discord.gg/ZfNBSKXnf9',
						},
						{
							label: 'QQ Group: 512620381',
							href: 'https://qm.qq.com/cgi-bin/qm/qr?k=7siAhjlLaSMGLHIbNctO-9AJQ0bn0G7i&jump_from=webapi&authKey=Kb6tXlvcJ2LgyTzHQzKwkMxdsQ7sjERXMJ3g10t6b+716pdKClnXqC9bAfrFUEWa',
						},
					],
				},
				{
					title: 'More',
					items: [
						{
							label: 'Blog',
							to: '/blog',
						},
						{
							label: github ? 'GitHub' : 'AtomGit',
							href: github ?
								'https://github.com/ippclub/Dora-SSR' :
								'https://atomgit.com/ippclub/Dora-SSR',
						},
					],
				},
			],
			copyright: `Copyright © ${new Date().getFullYear()} Dora SSR Community. Built with Docusaurus.`,
		},
		colorMode: {
			defaultMode: 'dark',
			disableSwitch: false,
		},
		prism: {
			theme: lightCodeTheme,
			darkTheme: darkCodeTheme,
			additionalLanguages: ['bash'],
		},
		docs: {
			sidebar: {
				hideable: true,
				autoCollapseCategories: true,
			},
		},
	}),
	themes: [
		[
			require.resolve("@easyops-cn/docusaurus-search-local"),
			({
				hashed: true,
				language: ["en", "zh"],
			}),
		]
	],
};

module.exports = config;
