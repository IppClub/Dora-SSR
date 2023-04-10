import ReactMarkdown from 'react-markdown';
import "./github-markdown-dark.css";

import {PrismLight as SyntaxHighlighter} from 'react-syntax-highlighter';
import {vscDarkPlus} from 'react-syntax-highlighter/dist/esm/styles/prism';
import prismYuescript from './languages/yuescript-prism';
import prismTeal from './languages/teal-prism';
import prismLua from 'react-syntax-highlighter/dist/esm/languages/prism/lua';

SyntaxHighlighter.registerLanguage('yuescript', prismYuescript);
SyntaxHighlighter.registerLanguage('lua', prismLua);
SyntaxHighlighter.registerLanguage('tl', prismTeal);

vscDarkPlus["code[class*=\"language-\"]"].fontSize = '16px';

export interface MarkdownProps {
	content: string;
	path: string;
	onClick: (link: string) => void;
};

const Markdown = (props: MarkdownProps) => {
	return <ReactMarkdown
		className='markdown-body'
		children={props.content}
		components={{
			img({node, src, ...iprops}) {
				const {path} = props;
				return <img src={path === "" ? src : path + "/" + src} {...iprops}/>;
			},
			a({node, href, ...aprops}) {
				if (href?.match("^http")) {
					// eslint-disable-next-line
					return <a href={href} target="_blank" rel="noreferrer" {...aprops}/>;
				}
				// eslint-disable-next-line
				return <a href='#!' onClick={(e)=> {
					e.preventDefault();
					if (node.properties !== undefined && node.properties.href !== undefined && typeof(node.properties.href) === "string") {
						props.onClick(node.properties.href);
					}
				}} {...aprops}/>;
			},
			code({node, inline, className, children, ...props}) {
				const match = /language-(\w+)/.exec(className || '');
				return !inline && match ? (
					<SyntaxHighlighter
						children={String(children).replace(/\n$/, '')}
						style={vscDarkPlus as any}
						customStyle={{
							backgroundColor: '#161b22'
						}}
						language={match[1]}
						PreTag="div"
						{...props}
					/>
				) : (
					<code className={className} {...props}>
						{children}
					</code>
				);
			}
		}}
	/>;
};

export default Markdown;
