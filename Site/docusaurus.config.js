// @ts-check
// Note: type annotations allow type checking and IDEs autocompletion

const lightCodeTheme = require('prism-react-renderer/themes/vsLight');
const darkCodeTheme = require('prism-react-renderer/themes/vsDark');

/** @type {import('@docusaurus/types').Config} */
const config = {
	title: 'Dorothy SSR',
	tagline: 'The Dorothy project, Special Super Rare edition.',
	favicon: 'img/favicon.ico',

	// Set the production url of your site here
	url: 'https://dorothy-ssr.net',
	// Set the /<baseUrl>/ pathname under which your site is served
	// For GitHub pages deployment, it is often '/<projectName>/'
	baseUrl: '/',

	// GitHub pages deployment config.
	// If you aren't using GitHub pages, you don't need these.
	organizationName: 'ippclub', // Usually your GitHub org/user name.
	projectName: 'Dorothy-SSR', // Usually your repo name.

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
					editUrl:
						'https://github.com/pigpigyyy/Dorothy-SSR/tree/main/Site',
				},
				blog: {
					showReadingTime: true,
					// Please change this to your repo.
					// Remove this to remove the "edit this page" links.
					editUrl:
						'https://github.com/pigpigyyy/Dorothy-SSR/tree/main/Site',
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
		image: 'img/dorothy-ssr-social-card.jpg',
		navbar: {
			title: 'Dorothy SSR',
			logo: {
				alt: 'Dorothy SSR Logo',
				src: 'img/logo.svg',
			},
			items: [
				{
					type: 'localeDropdown',
				},
				{
					type: 'docSidebar',
					sidebarId: 'tutorialSidebar',
					position: 'left',
					label: 'Tutorial',
				},
				{
					type: 'docSidebar',
					sidebarId: 'apiSidebar',
					position: 'left',
					label: 'API',
				},
				{to: '/blog', label: 'Blog', position: 'left'},
				{
					href: 'https://github.com/pigpigyyy/Dorothy-SSR',
					label: 'GitHub',
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
						href: 'https://discord.gg/ydJVuZhh',
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
						label: 'GitHub',
						href: 'https://github.com/pigpigyyy/Dorothy-SSR',
					},
				],
			},
		],
		copyright: `Copyright © ${new Date().getFullYear()} Dorothy SSR Community. Built with Docusaurus.`,
		},
		prism: {
			theme: lightCodeTheme,
			darkTheme: darkCodeTheme,
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
