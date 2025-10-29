// @ts-check
// Note: type annotations allow type checking and IDEs autocompletion

import { themes } from 'prism-react-renderer';

const github = process.env.ATOM === undefined;

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
		...themes.vsLight.styles,
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
				color: '#af803b',
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
	],
};

/** @type {import('@docusaurus/types').Config} */
const config = {
	title: 'Dora SSR',
	tagline: 'The Dora project, Special Super Rare edition.',
	favicon: 'img/site/favicon.ico',

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
					showLastUpdateAuthor: true,
					showLastUpdateTime: true,
					lastVersion: 'current',
					versions: {
						current: {
							label: 'v1.7.2',
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
		image: 'img/site/dora-ssr-social-card.jpg',
		navbar: {
			title: 'Dora SSR',
			logo: {
				alt: 'Dora SSR Logo',
				src: 'img/site/logo.svg',
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
					type: 'docSidebar',
					sidebarId: 'exampleSidebar',
					label: 'Example',
					position: 'left',
				},
				{
					to: '/blog',
					label: 'Blog',
					position: 'left'
				},
				{
					type: 'docSidebar',
					sidebarId: 'creativeSidebar',
					label: 'Creative',
					position: 'left',
				},
				{
					type: 'docsVersionDropdown',
					position: 'right',
				},
				{
					type: 'dropdown',
					label: 'Git',
					position: 'right',
					items: [
						{
							type: 'html',
							value: '<a href="https://github.com/ippclub/Dora-SSR" target="_blank"><div><div class="header-github-link"/></div></a>',
						},
						{
							type: 'html',
							value: '<a href="https://gitee.com/ippclub/Dora-SSR" target="_blank"><div><div class="header-gitee-link"/></div></a>',
						},
						{
							type: 'html',
							value: '<a href="https://atomgit.com/ippclub/Dora-SSR" target="_blank"><div><div class="header-atomgit-link"/></div></a>',
						},
						{
							type: 'html',
							value: '<a href="https://gitcode.com/ippclub/Dora-SSR" target="_blank"><div><div class="header-gitcode-link"/></div></a>',
						},
					]
				},
				{
					type: 'localeDropdown',
					position: 'right',
				},
			],
		},
		footer: {
			style: 'dark',
			links: [
				{
					title: 'Incubating by',
					items: [
						{
							html: '<div><a href="https://openatom.org/" class="footer-openatom" target="_blank"></a></div>',
						},
						{
							label: '  ',
							to: 'javascript:void(0)',
						}
					]
				},
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
						{
							label: 'Example',
							to: '/docs/example/First%20Game%20Tutorial/start',
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
							href: 'https://qm.qq.com/q/VnzYhvCDgy',
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
							label: 'Creative',
							to: '/docs/creative/art-i',
						},
					],
				},
			],
			logo: {
				alt: 'Dora SSR Logo',
				src: 'img/art/casual/cheer.png',
				height: 200,
				className: 'footer-logo',
			},
			copyright: `Copyright © ${new Date().getFullYear()} Dora SSR Community. Built with Docusaurus.`,
		},
		colorMode: {
			defaultMode: 'dark',
			disableSwitch: false,
		},
		prism: {
			theme: lightCodeTheme,
			darkTheme: darkCodeTheme,
			additionalLanguages: ['bash', 'yue', 'teal', 'lua',],
		},
		docs: {
			sidebar: {
				autoCollapseCategories: true,
			},
		},
	}),
	markdown: {
		mermaid: true,
		hooks: {
			onBrokenMarkdownLinks: 'warn',
		},
	},
	themes: [
		'@docusaurus/theme-mermaid',
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
