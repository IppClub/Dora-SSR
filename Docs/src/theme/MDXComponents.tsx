import React from 'react';
// Importing the original mapper + our components according to the Docusaurus doc
import MDXComponents from '@theme-original/MDXComponents';
import Card from '@site/src/components/Card';
import CardBody from '@site/src/components/Card/CardBody';
import CardFooter from '@site/src/components/Card/CardFooter';
import CardHeader from '@site/src/components/Card/CardHeader';
import CardImage from '@site/src/components/Card/CardImage';
import Columns from '@site/src/components/Column/Columns';
import Column from '@site/src/components/Column';
import Collapse from '@site/src/components/Collapse';
import Dropdown from '@site/src/components/Dropdown';

export default {
	// Reusing the default mapping
	...MDXComponents,
	Card,
	CardHeader,
	CardBody,
	CardFooter,
	CardImage,
	Columns,
	Column,
	Collapse,
	Dropdown,
};
