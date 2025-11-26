/* Copyright (c) 2017-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import ReactMarkdown from 'react-markdown';
import remarkGfm from 'remark-gfm';
import "./github-markdown-dark.css";

import {PrismLight as SyntaxHighlighter} from 'react-syntax-highlighter';
import {vscDarkPlus} from 'react-syntax-highlighter/dist/esm/styles/prism';
import prismYuescript from './languages/yuescript-prism';
import prismTeal from './languages/teal-prism';
import prismLua from './languages/lua-prism';
import { memo } from 'react';

SyntaxHighlighter.registerLanguage('yuescript', prismYuescript);
SyntaxHighlighter.registerLanguage('lua', prismLua);
SyntaxHighlighter.registerLanguage('tl', prismTeal);

vscDarkPlus["code[class*=\"language-\"]"].fontSize = '16px';

export interface MarkdownProps {
	fileKey: string;
	content: string;
	path: string;
	onClick: (link: string, key: string) => void;
};

const Markdown = memo((props: MarkdownProps) => {
	return <div className="markdown-body">
		<ReactMarkdown
			children={props.content}
			remarkPlugins={[remarkGfm]}
			components={{
				img({src, alt, ...iprops}) {
					const {path} = props;
					const tokens = (alt ?? "").split(':');
					let width: number | undefined = undefined;
					let height: number | undefined = undefined;
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
							props.onClick(node.properties.href, props.fileKey);
						}
					}} {...aprops}/>;
				},
				code({className, children, ...props}) {
					const match = /language-(\w+)/.exec(className || '');
					return match ? (
						<SyntaxHighlighter
							children={String(children).replace(/\n$/, '')}
							style={vscDarkPlus as any}
							customStyle={{
								backgroundColor: '#161b22'
							}}
							language={match[1]}
							PreTag="div"
						/>
					) : (
						<code className={className} {...props}>
							{children}
						</code>
					);
				}
			}}
		/>
	</div>;
});

export default Markdown;
