#!/usr/bin/env node

/**
 * Dora SSR Tutorial Documentation Generator
 * 
 * This script extracts tutorial documents and splits them by programming language.
 * It generates separate documentation files for each language (Lua, Teal, TypeScript, TSX, YueScript, Wa).
 * 
 * Rules:
 * 1. Only generates files for languages that have actual code examples in the source document
 * 2. Removes leading number prefixes from filenames
 * 3. TSX directory also includes TypeScript documents (TSX is a superset of TypeScript)
 * 4. Documents with no programming language code examples are copied to all language directories
 * 5. Single-language tutorials (without language-select tabs) are only generated to their primary language directory
 * 
 * Usage: node generate-language-docs.js
 * 
 * Output structure:
 *   Assets/Doc/en/Tutorial/[language]/*.md
 *   Assets/Doc/zh-Hans/Tutorial/[language]/*.md
 */

const fs = require('fs');
const path = require('path');

// Configuration
const CONFIG = {
	docsRoot: path.join(__dirname, '..'),
	outputRoot: path.join(__dirname, '..', '..', 'Assets', 'Doc'),
	
	// Source directories for different languages
	sources: {
		en: 'docs/tutorial',
		'zh-Hans': 'i18n/zh-Hans/docusaurus-plugin-content-docs/current/tutorial'
	},
	
	// Supported programming languages and their display names
	programmingLanguages: {
		lua: 'Lua',
		tl: 'Teal',
		ts: 'TypeScript',
		tsx: 'TSX',
		yue: 'YueScript',
		wa: 'Wa'
	},
	
	// Code block language mapping
	codeBlockLangMap: {
		'lua': 'lua',
		'teal': 'tl',
		'ts': 'ts',
		'typescript': 'ts',
		'tsx': 'tsx',
		'yue': 'yue',
		'moon': 'yue',
		'wa': 'wa',
		'go': 'wa'
	},
	
// Language compatibility map - which languages can include which other languages' code
// TSX can include TypeScript code since TSX is a superset
languageCompatibility: {
tsx: ['ts']  // TSX directories can also include TypeScript documents
	},
	
	// Path-based language tutorial classification
	// Maps path patterns to target programming languages for correct categorization
	// This ensures language-specific tutorials go to the right directories
	languageTutorialPaths: {
		// Pattern: path substring -> target language
		'Language Tutorial/1.teal-tutorial': 'tl',
		'Language Tutorial/2.yuescript-15min': 'yue',
		'Language Tutorial/3.Using TypeScript in Dora': 'ts',
		'Language Tutorial/4.using-tsx': 'tsx'
	}
};

/**
 * Pre-process content to remove JSX and import statements
 * Only removes imports outside of code blocks
 */
function preprocessContent(content) {
	const lines = content.split('\n');
	const result = [];
	let inCodeBlock = false;
	
	for (const line of lines) {
		const trimmed = line.trim();
		
		// Track code blocks
		if (trimmed.startsWith('```')) {
			inCodeBlock = !inCodeBlock;
			result.push(line);
			continue;
		}
		
		// If in code block, keep everything
		if (inCodeBlock) {
			result.push(line);
			continue;
		}
		
		// Outside code blocks: filter out import statements
		if (/^import\s+.*?;?\s*$/.test(line) ||
			/^import\s*\{[^}]*\}\s+from\s+['"][^'"]+['"];?\s*$/.test(line)) {
			// Skip this line (remove import)
			continue;
		}
		
		// Remove Dropdown components (will be multi-line, handle separately)
		if (trimmed.startsWith('<Dropdown')) {
			// Skip Dropdown lines - they will be removed by the multiline regex below
			continue;
		}
		
		result.push(line);
	}
	
	// Rejoin and handle multi-line patterns
	content = result.join('\n');
	
	// Remove Dropdown components (multi-line) - for any remaining
	content = content.replace(/<Dropdown[\s\S]*?\/>/g, '');
	
	// Remove standalone JSX fragments
	content = content.replace(/^\s*\]\/>\s*$/gm, '');
	content = content.replace(/^\s*\}\s*\/>\s*$/gm, '');
	
	// Remove frontmatter if present
	content = content.replace(/^---\n[\s\S]*?\n---\n/, '');
	
	return content;
}

/**
 * Check if content has language-select tabs (multi-language tutorial)
 */
function hasLanguageSelectTabs(content) {
	return /<Tabs\s+groupId\s*=\s*["']language-select["']/.test(content);
}

/**
 * Parse MDX content using regex-based approach for better accuracy
 */
function parseMdxContent(content) {
	// Pre-process content
	content = preprocessContent(content);
	
	// Track all content sections
	const sections = [];
	let currentSection = {
		type: 'common',
		content: [],
		language: null
	};
	
	// Parse the content
	const lines = content.split('\n');
	let i = 0;
	
	while (i < lines.length) {
		const line = lines[i];
		const trimmedLine = line.trim();
		
		// Check for Tabs with language-select groupId
		const tabsMatch = trimmedLine.match(/<Tabs\s+groupId\s*=\s*["']language-select["']/);
		if (tabsMatch) {
			// Save current section
			if (currentSection.content.length > 0 && hasContent(currentSection.content)) {
				sections.push(currentSection);
			}
			
			// Process language tabs
			const tabResults = processLanguageTabs(lines, i);
			tabResults.sections.forEach(s => sections.push(s));
			i = tabResults.endIndex;
			
			currentSection = {
				type: 'common',
				content: [],
				language: null
			};
			continue;
		}
		
		// Check for other Tabs (platform-select, etc.) - keep them as is but simplify
		const otherTabsMatch = trimmedLine.match(/<Tabs\s+groupId\s*=\s*["']([^"']+)["']/);
		if (otherTabsMatch && otherTabsMatch[1] !== 'language-select') {
			// Save current section
			if (currentSection.content.length > 0 && hasContent(currentSection.content)) {
				sections.push(currentSection);
			}
			
			// Process platform tabs - convert to simple list
			const tabResults = processPlatformTabs(lines, i);
			tabResults.content.forEach(c => {
				if (hasContent(c)) {
					sections.push({
						type: 'common',
						content: c,
						language: null
					});
				}
			});
			i = tabResults.endIndex;
			
			currentSection = {
				type: 'common',
				content: [],
				language: null
			};
			continue;
		}
		
		// Skip empty Dropdown remnants
		if (trimmedLine.match(/^\s*\{?\s*label\s*:/) ||
			trimmedLine.match(/^\s*items\s*:\s*\[/) ||
			trimmedLine.match(/^\s*to\s*:\s*['"]/) ||
			trimmedLine.match(/^\s*target\s*:/) ||
			trimmedLine.match(/^\s*\]\s*\/?>?\s*$/) ||
			trimmedLine.match(/^\s*\}\s*\/>\s*$/)) {
			i++;
			continue;
		}
		
		// Regular line
		currentSection.content.push(line);
		i++;
	}
	
	// Save last section
	if (currentSection.content.length > 0 && hasContent(currentSection.content)) {
		sections.push(currentSection);
	}
	
	return sections;
}

/**
 * Check if content array has actual content (not just empty lines)
 */
function hasContent(contentLines) {
	return contentLines.some(line => line.trim() !== '');
}

/**
 * Process language-select Tabs and extract content for each language
 */
function processLanguageTabs(lines, startIndex) {
	const sections = [];
	let i = startIndex;
	let currentTabContent = {};
	let currentLang = null;
	let inCodeBlock = false;
	
	// Initialize for all languages
	Object.keys(CONFIG.programmingLanguages).forEach(lang => {
		currentTabContent[lang] = [];
	});
	
	// Skip the Tabs opening tag
	i++;
	
	while (i < lines.length) {
		const line = lines[i];
		const trimmedLine = line.trim();
		
		// Track code blocks
		if (trimmedLine.startsWith('```')) {
			inCodeBlock = !inCodeBlock;
		}
		
		// Only process JSX tags if not in code block
		if (!inCodeBlock) {
			// Check for TabItem start
			const tabItemMatch = trimmedLine.match(/<TabItem\s+value\s*=\s*["']([^"']+)["']/);
			if (tabItemMatch) {
				currentLang = tabItemMatch[1];
				if (CONFIG.programmingLanguages[currentLang]) {
					currentTabContent[currentLang] = [];
				}
				i++;
				continue;
			}
			
			// Check for TabItem end
			if (trimmedLine === '</TabItem>') {
				currentLang = null;
				i++;
				continue;
			}
			
			// Check for Tabs end
			if (trimmedLine === '</Tabs>') {
				break;
			}
		}
		
		// Add content to current language
		if (currentLang && CONFIG.programmingLanguages[currentLang]) {
			currentTabContent[currentLang].push(line);
		}
		
		i++;
	}
	
	// Create sections for each language
	Object.keys(CONFIG.programmingLanguages).forEach(lang => {
		if (currentTabContent[lang].length > 0 && hasContent(currentTabContent[lang])) {
			sections.push({
				type: 'language',
				language: lang,
				content: currentTabContent[lang]
			});
		}
	});
	
	return { sections, endIndex: i + 1 };
}

/**
 * Process platform-select Tabs and convert to simple list
 */
function processPlatformTabs(lines, startIndex) {
	const content = [[]];
	let i = startIndex;
	let inCodeBlock = false;
	let currentPlatform = null;
	let platformContent = [];
	
	// Skip the Tabs opening tag
	i++;
	
	while (i < lines.length) {
		const line = lines[i];
		const trimmedLine = line.trim();
		
		// Track code blocks
		if (trimmedLine.startsWith('```')) {
			inCodeBlock = !inCodeBlock;
		}
		
		// Only process JSX tags if not in code block
		if (!inCodeBlock) {
			// Check for TabItem start
			const tabItemMatch = trimmedLine.match(/<TabItem\s+value\s*=\s*["']([^"']+)["']\s+label\s*=\s*["']([^"']+)["']/);
			if (tabItemMatch) {
				if (platformContent.length > 0 && currentPlatform && hasContent(platformContent)) {
					// Add platform header
					content[0].push(`**${currentPlatform}:**`);
					content[0].push('');
					content[0].push(...platformContent);
					content[0].push('');
				}
				currentPlatform = tabItemMatch[2];
				platformContent = [];
				i++;
				continue;
			}
			
			// Check for TabItem end
			if (trimmedLine === '</TabItem>') {
				i++;
				continue;
			}
			
			// Check for Tabs end
			if (trimmedLine === '</Tabs>') {
				break;
			}
			
			// Skip Dropdown and JSX expressions
			if (trimmedLine.startsWith('<Dropdown') ||
				trimmedLine.match(/label\s*=\s*["']/) ||
				trimmedLine.match(/items\s*=\s*\{/) ||
				trimmedLine.match(/^\s*items\s*:\s*\[/) ||
				trimmedLine.match(/^\s*\{\s*label\s*:/) ||
				trimmedLine.match(/^\s*\]\s*\/?>?\s*$/) ||
				trimmedLine.match(/^\s*\}\\s*\/>\s*$/)) {
				i++;
				continue;
			}
		}
		
		// Add content
		if (!trimmedLine.startsWith('<TabItem')) {
			platformContent.push(line);
		}
		
		i++;
	}
	
	// Add last platform content
	if (platformContent.length > 0 && currentPlatform && hasContent(platformContent)) {
		content[0].push(`**${currentPlatform}:**`);
		content[0].push('');
		content[0].push(...platformContent);
	}
	
	return { content, endIndex: i + 1 };
}

/**
 * Count code blocks for each language in content
 */
function countCodeBlocksByLanguage(content) {
	const counts = {};
	let inCodeBlock = false;
	let currentCodeLang = null;
	
	for (const line of content) {
		const trimmed = line.trim();
		
		if (trimmed.startsWith('```')) {
			if (!inCodeBlock) {
				inCodeBlock = true;
				const langPart = trimmed.slice(3).trim();
				currentCodeLang = langPart.split(/\s+/)[0].toLowerCase();
			} else {
				// End of code block - count it
				if (currentCodeLang) {
					const mappedLang = CONFIG.codeBlockLangMap[currentCodeLang.toLowerCase()];
					if (mappedLang) {
						counts[mappedLang] = (counts[mappedLang] || 0) + 1;
					}
				}
				inCodeBlock = false;
				currentCodeLang = null;
			}
		}
	}
	
	return counts;
}

/**
 * Get the primary language of a single-language tutorial
 * Returns the language with the most code blocks
 */
function getPrimaryLanguage(sections) {
	const totalCounts = {};
	
	for (const section of sections) {
		if (section.type === 'common') {
			const counts = countCodeBlocksByLanguage(section.content);
			for (const [lang, count] of Object.entries(counts)) {
				totalCounts[lang] = (totalCounts[lang] || 0) + count;
			}
		}
	}
	
	// Find the language with the most code blocks
	let maxCount = 0;
	let primaryLang = null;
	
	for (const [lang, count] of Object.entries(totalCounts)) {
		if (count > maxCount) {
			maxCount = count;
			primaryLang = lang;
		}
	}
	
	return primaryLang;
}

/**
 * Check if sections contain code examples for a specific language
 * Also checks compatible languages (e.g., tsx can include ts)
 */
function hasLanguageExamples(sections, targetLanguage) {
	// Get compatible languages for this target
	const compatibleLangs = CONFIG.languageCompatibility[targetLanguage] || [];
	const languagesToCheck = [targetLanguage, ...compatibleLangs];
	
	for (const section of sections) {
		// Check if this is a language section for any of the compatible languages
		if (section.type === 'language' && languagesToCheck.includes(section.language)) {
			return true;
		}
		
		// Check common sections for code blocks in any of the compatible languages
		if (section.type === 'common') {
			for (const lang of languagesToCheck) {
				if (containsLanguageCodeBlock(section.content, lang)) {
					return true;
				}
			}
		}
	}
	return false;
}

/**
 * Check if document has ANY programming language code examples
 * Returns the set of languages found, or empty set if none
 */
function getLanguagesWithExamples(sections) {
	const foundLanguages = new Set();
	
	for (const langKey of Object.keys(CONFIG.programmingLanguages)) {
		// Check language sections
		for (const section of sections) {
			if (section.type === 'language' && section.language === langKey) {
				foundLanguages.add(langKey);
				break;
			}
			
			// Check common sections for code blocks
			if (section.type === 'common' && containsLanguageCodeBlock(section.content, langKey)) {
				foundLanguages.add(langKey);
				break;
			}
		}
	}
	
	return foundLanguages;
}

/**
 * Check if content contains code blocks for a specific language
 */
function containsLanguageCodeBlock(contentLines, targetLanguage) {
	let inCodeBlock = false;
	let currentCodeLang = null;
	
	for (const line of contentLines) {
		const trimmed = line.trim();
		
		if (trimmed.startsWith('```')) {
			if (!inCodeBlock) {
				inCodeBlock = true;
				const langPart = trimmed.slice(3).trim();
				currentCodeLang = langPart.split(/\s+/)[0].toLowerCase();
			} else {
				inCodeBlock = false;
				currentCodeLang = null;
			}
			continue;
		}
		
		// Check if current code block is target language
		if (inCodeBlock && currentCodeLang) {
			const mappedLang = CONFIG.codeBlockLangMap[currentCodeLang.toLowerCase()];
			if (mappedLang === targetLanguage) {
				return true;
			}
		}
	}
	
	return false;
}

/**
 * Generate document for a specific programming language
 */
function generateLanguageDocument(sections, targetLanguage) {
	const lines = [];
	
	// Get compatible languages for filtering
	const compatibleLangs = CONFIG.languageCompatibility[targetLanguage] || [];
	const languagesToInclude = [targetLanguage, ...compatibleLangs];
	
	for (const section of sections) {
		if (section.type === 'common') {
			// Process common content - filter code blocks
			const processedContent = filterCodeBlocks(section.content, targetLanguage, languagesToInclude);
			if (processedContent.length > 0) {
				if (lines.length > 0 && lines[lines.length - 1] !== '') {
					lines.push('');
				}
				lines.push(...processedContent);
			}
		} else if (section.type === 'language' && languagesToInclude.includes(section.language)) {
			// Add language-specific content (including compatible languages)
			if (lines.length > 0 && lines[lines.length - 1] !== '') {
				lines.push('');
			}
			lines.push(...section.content);
		}
	}
	
	// Clean up empty lines
	const cleanedLines = cleanEmptyLines(lines);
	
	return cleanedLines.join('\n');
}

/**
 * Filter code blocks to keep only the target language and compatible languages
 */
function filterCodeBlocks(contentLines, targetLanguage, languagesToInclude) {
	const result = [];
	let inCodeBlock = false;
	let currentCodeLang = null;
	let codeBuffer = [];
	
	for (let i = 0; i < contentLines.length; i++) {
		const line = contentLines[i];
		const trimmed = line.trim();
		
		// Check for code block start
		if (trimmed.startsWith('```')) {
			if (!inCodeBlock) {
				inCodeBlock = true;
				const langPart = trimmed.slice(3).trim();
				currentCodeLang = langPart.split(/\s+/)[0].toLowerCase();
				codeBuffer = [line];
			} else {
				// End of code block
				inCodeBlock = false;
				codeBuffer.push(line);
				
				// Decide whether to include this code block
				const shouldInclude = shouldIncludeCodeBlock(currentCodeLang, targetLanguage, languagesToInclude);
				if (shouldInclude) {
					result.push(...codeBuffer);
				}
				
				codeBuffer = [];
				currentCodeLang = null;
			}
			continue;
		}
		
		if (inCodeBlock) {
			codeBuffer.push(line);
			continue;
		}
		
		result.push(line);
	}
	
	// Handle case where code block is not properly closed
	if (codeBuffer.length > 0) {
		result.push(...codeBuffer);
	}
	
	return result;
}

/**
 * Determine if a code block should be included based on target language and compatible languages
 */
function shouldIncludeCodeBlock(codeLang, targetLanguage, languagesToInclude) {
	if (!codeLang) return true;
	
	// Common languages that should always be included
	const commonLangs = ['sh', 'bash', 'shell', 'mermaid', 'json', 'xml', 'html', 'css', 'yaml', 'yml', 'text', 'plaintext', ''];
	if (commonLangs.includes(codeLang.toLowerCase())) {
		return true;
	}
	
	// Map code block language to our language keys
	const mappedLang = CONFIG.codeBlockLangMap[codeLang.toLowerCase()];
	
	// If language is not in our map, include it
	if (mappedLang === undefined) {
		return true;
	}
	
	// Include if it matches target language or any compatible language
	return languagesToInclude.includes(mappedLang);
}

/**
 * Clean up excessive empty lines
 */
function cleanEmptyLines(lines) {
	const result = [];
	let prevEmpty = false;
	
	for (let i = 0; i < lines.length; i++) {
		const line = lines[i];
		const isEmpty = line.trim() === '';
		
		if (isEmpty) {
			if (!prevEmpty) {
				result.push(line);
			}
			prevEmpty = true;
		} else {
			result.push(line);
			prevEmpty = false;
		}
	}
	
	// Remove leading/trailing empty lines
	while (result.length > 0 && result[0].trim() === '') {
		result.shift();
	}
	while (result.length > 0 && result[result.length - 1].trim() === '') {
		result.pop();
	}
	
	return result;
}

/**
 * Clean filename by removing leading number prefix
 * Example: "10.quick-start.md" -> "quick-start.md"
 * Example: "1.using-sprite.md" -> "using-sprite.md"
 */
function cleanFileName(fileName) {
	// Remove leading number followed by dot (e.g., "10." or "1.")
	return fileName.replace(/^\d+\./, '');
}

/**
 * Check if file path matches a language tutorial pattern
 * Returns the target language if match found, null otherwise
 */
function getLanguageTutorialTarget(filePath) {
	// Normalize path separators
	const normalizedPath = filePath.replace(/\\/g, '/');
	
	// Check each pattern
	for (const [pattern, targetLang] of Object.entries(CONFIG.languageTutorialPaths)) {
		if (normalizedPath.includes(pattern)) {
			return targetLang;
		}
	}
	
	return null;
}
/**
 * Process a single document file
 */
function processDocument(filePath, docLanguage, outputDir) {
	console.log(`Processing: ${filePath}`);
	
	const rawContent = fs.readFileSync(filePath, 'utf-8');
	const sections = parseMdxContent(rawContent);
	
	const results = [];
	
	// Check if this is a multi-language tutorial (has language-select tabs)
	const isMultiLanguageTutorial = hasLanguageSelectTabs(rawContent);
	
	// Check which languages have examples in this document
	const languagesWithExamples = getLanguagesWithExamples(sections);
	
	// Determine if this document has no programming language examples at all
	const hasNoLanguageExamples = languagesWithExamples.size === 0;
	
	// Check if this file should be classified by path (language tutorial)
	const pathTargetLanguage = getLanguageTutorialTarget(filePath);
	
	// Generate documents for each programming language
	for (const langKey of Object.keys(CONFIG.programmingLanguages)) {
		let shouldGenerate = false;
		
		// Priority 1: Path-based classification (for language tutorials)
		if (pathTargetLanguage !== null) {
			if (langKey === pathTargetLanguage) {
				shouldGenerate = true;
			} else {
				// Check compatibility (e.g., tsx can include ts docs)
				const compatibleLangs = CONFIG.languageCompatibility[langKey] || [];
				if (compatibleLangs.includes(pathTargetLanguage)) {
					shouldGenerate = true;
				}
			}
		} else if (hasNoLanguageExamples) {
			// Rule 4: Documents with no programming language code examples go to all directories
			shouldGenerate = true;
		} else if (isMultiLanguageTutorial) {
			// Multi-language tutorial: check if this document has examples for this language
			shouldGenerate = hasLanguageExamples(sections, langKey);
		} else {
			// Single-language tutorial: only generate to primary language directory
			const primaryLang = getPrimaryLanguage(sections);
			
			if (primaryLang === langKey) {
				shouldGenerate = true;
			} else {
				// Also check compatible languages (tsx can include ts)
				const compatibleLangs = CONFIG.languageCompatibility[langKey] || [];
				if (compatibleLangs.includes(primaryLang)) {
					shouldGenerate = true;
				}
			}
		}
		
		if (!shouldGenerate) {
			continue;
		}
		
		const docContent = generateLanguageDocument(sections, langKey);
		
		if (docContent && docContent.trim()) {
			const langDir = path.join(outputDir, langKey);
			fs.mkdirSync(langDir, { recursive: true });
			
			// Convert .mdx to .md and clean filename
			const originalFileName = path.basename(filePath).replace(/\.mdx?$/, '.md');
			const fileName = cleanFileName(originalFileName);
			const outputPath = path.join(langDir, fileName);
			
			fs.writeFileSync(outputPath, docContent, 'utf-8');
			results.push({ language: langKey, path: outputPath });
		}
	}
	
	return results;
}

/**
 * Recursively process all documents in a directory
 */
function processDirectory(sourceDir, docLanguage, outputBaseDir) {
	const results = [];
	
	if (!fs.existsSync(sourceDir)) {
		console.log(`Source directory not found: ${sourceDir}`);
		return results;
	}
	
	const entries = fs.readdirSync(sourceDir, { withFileTypes: true });
	
	for (const entry of entries) {
		const fullPath = path.join(sourceDir, entry.name);
		
		if (entry.isDirectory()) {
			// Process subdirectory
			const subResults = processDirectory(fullPath, docLanguage, outputBaseDir);
			results.push(...subResults);
		} else if (entry.isFile() && /\.(md|mdx)$/.test(entry.name)) {
			// Process markdown file
			const fileResults = processDocument(fullPath, docLanguage, outputBaseDir);
			results.push(...fileResults);
		}
	}
	
	return results;
}

/**
 * Main function
 */
function main() {
	console.log('='.repeat(60));
	console.log('Dora SSR Tutorial Documentation Generator');
	console.log('='.repeat(60));
	console.log('');
	
	let totalFiles = 0;
	
	// Process each document language
	for (const [docLang, sourcePath] of Object.entries(CONFIG.sources)) {
		console.log(`\nProcessing ${docLang} documentation...`);
		console.log('-'.repeat(40));
		
		const sourceDir = path.join(CONFIG.docsRoot, sourcePath);
		const outputDir = path.join(CONFIG.outputRoot, docLang, 'Tutorial');
		
		// Clean output directory before generating
		if (fs.existsSync(outputDir)) {
			fs.rmSync(outputDir, { recursive: true });
		}
		fs.mkdirSync(outputDir, { recursive: true });
		
		// Restore .gitkeep placeholder file
		fs.writeFileSync(path.join(outputDir, '.gitkeep'), '', 'utf-8');
		
		// Process all documents
		const results = processDirectory(sourceDir, docLang, outputDir);
		
		// Count unique files per language
		const filesByLang = {};
		results.forEach(r => {
			if (!filesByLang[r.language]) {
				filesByLang[r.language] = new Set();
			}
			filesByLang[r.language].add(r.path);
		});
		
		console.log(`\nGenerated files for ${docLang}:`);
		for (const [lang, files] of Object.entries(filesByLang)) {
			console.log(`  ${CONFIG.programmingLanguages[lang]}: ${files.size} files`);
			totalFiles += files.size;
		}
	}
	
	console.log('\n' + '='.repeat(60));
	console.log(`Generation complete! Total files generated: ${totalFiles}`);
	console.log('='.repeat(60));
}

// Run the script
main();
