/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import ReactMarkdown from 'react-markdown';
import remarkGfm from 'remark-gfm';
import "./github-markdown-dark.css";

import {PrismLight as SyntaxHighlighter} from 'react-syntax-highlighter';
import {vscDarkPlus} from 'react-syntax-highlighter/dist/esm/styles/prism';
import prismTypescript from 'react-syntax-highlighter/dist/esm/languages/prism/typescript';
import prismTsx from 'react-syntax-highlighter/dist/esm/languages/prism/tsx';
import prismJson from 'react-syntax-highlighter/dist/esm/languages/prism/json';
import prismYuescript from './languages/yuescript-prism';
import prismTeal from './languages/teal-prism';
import prismLua from './languages/lua-prism';
import { memo } from 'react';
import Box from '@mui/material/Box';

SyntaxHighlighter.registerLanguage('typescript', prismTypescript);
SyntaxHighlighter.registerLanguage('ts', prismTypescript);
SyntaxHighlighter.registerLanguage('tsx', prismTsx);
SyntaxHighlighter.registerLanguage('json', prismJson);
SyntaxHighlighter.registerLanguage('yuescript', prismYuescript);
SyntaxHighlighter.registerLanguage('yue', prismYuescript);
SyntaxHighlighter.registerLanguage('lua', prismLua);
SyntaxHighlighter.registerLanguage('teal', prismTeal);
SyntaxHighlighter.registerLanguage('tl', prismTeal);

export interface MarkdownProps {
	fileKey?: string;
	content: string;
	path?: string;
	onClick?: (link: string, key: string) => void;
	contentPadding?: string | number;
};

const Markdown = memo((props: MarkdownProps) => {
	const contentPadding = props.contentPadding ?? "32px 36px 40px";
	return <div
		className="markdown-body"
		style={{
			width: "100%",
			maxWidth: "100%",
			minWidth: 0,
			margin: 0,
			padding: contentPadding,
			minHeight: 0,
			overflowX: "hidden",
			overflowWrap: "anywhere",
			wordBreak: "break-word",
			backgroundColor: "transparent",
			fontSize: "inherit",
			lineHeight: "inherit",
			color: "inherit",
		}}
	>
		<ReactMarkdown
			children={props.content}
			remarkPlugins={[remarkGfm]}
			components={{
				img({src, alt, ...iprops}) {
					const path = props.path ?? "";
					const tokens = (alt ?? "").split(':');
					let width: number | undefined;
					let height: number | undefined;
					if (tokens.length === 2) {
						const size = tokens[tokens.length - 1].split('x');
						if (size.length === 1) {
							width = Number.parseFloat(size[0]);
						} else if (size.length === 2) {
							width = Number.parseFloat(size[0]);
							height = Number.parseFloat(size[1]);
						}
					}
					return <img src={path === "" ? src : path + "/" + src} alt={alt} width={width} height={height} {...iprops}/>;
				},
				a({node, href, ...aprops}) {
					if (href?.match("^http")) {
						return <a href={href} target="_blank" rel="noreferrer" {...aprops}/>;
					}
					return <a href='#!' onClick={(e)=> {
						e.preventDefault();
						if (node?.properties !== undefined && node.properties.href !== undefined && typeof(node.properties.href) === "string") {
							props.onClick?.(node.properties.href, props.fileKey ?? "");
						}
					}} {...aprops}/>;
				},
				table({children}) {
					return (
						<Box sx={{ width: '100%', maxWidth: '100%', overflowX: 'auto' }}>
							<table>{children}</table>
						</Box>
					);
				},
				code({className, children, ...props}) {
					const match = /language-(\w+)/.exec(className || '');
					return match ? (
						<SyntaxHighlighter
							children={String(children).replace(/\n$/, '')}
							style={vscDarkPlus as any}
							customStyle={{
								backgroundColor: '#161b22',
								margin: 0,
								padding: 0,
								width: '100%',
								minWidth: 0,
								maxWidth: '100%',
								boxSizing: 'border-box',
								fontSize: '1em',
								lineHeight: '1.45',
								overflowX: 'auto',
							}}
							codeTagProps={{
								style: {
									fontSize: 'inherit',
									lineHeight: '1.45',
								},
							}}
							language={match[1]}
							PreTag="div"
						/>
					) : (
						<code
							className={className}
							style={{
								whiteSpace: 'break-spaces',
								overflowWrap: 'anywhere',
								wordBreak: 'break-word',
							}}
							{...props}
						>
							{children}
						</code>
					);
				}
			}}
		/>
	</div>;
});

export default Markdown;
