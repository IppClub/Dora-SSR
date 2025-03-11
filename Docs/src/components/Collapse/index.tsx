import React, { useState, ReactNode } from 'react';
import styles from './styles.module.css';

export interface CollapseProps {
	children: ReactNode;
	title: string;
	defaultOpen?: boolean;
	className?: string;
}

export default function Collapse({
	children,
	title,
	defaultOpen = false,
	className = '',
}: CollapseProps): React.ReactElement {
	const [isOpen, setIsOpen] = useState(defaultOpen);

	const toggleCollapse = () => {
		setIsOpen(!isOpen);
	};

	return (
		<div className={`${styles.collapse} ${className}`}>
			<button
				className={styles.collapseButton}
				onClick={toggleCollapse}
				aria-expanded={isOpen}
			>
				<span>{title}</span>
				<span className={`${styles.arrow} ${isOpen ? styles.arrowUp : styles.arrowDown}`}>
					{isOpen ? '▲' : '▼'}
				</span>
			</button>
			{isOpen && (
				<div className={styles.collapseContent}>
					{children}
				</div>
			)}
		</div>
	);
}