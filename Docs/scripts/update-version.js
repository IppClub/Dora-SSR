/**
 * Script to update version number in translation JSON files
 * This script reads the version from version.js and updates all translation files
 */

const fs = require('fs');
const path = require('path');
const { getVersionLabelZh } = require('../src/version');

const translationFile = path.join(__dirname, '../i18n/zh-Hans/docusaurus-plugin-content-docs/current.json');

if (fs.existsSync(translationFile)) {
	const content = fs.readFileSync(translationFile, 'utf8');
	const json = JSON.parse(content);

	// Update version label
	if (json['version.label']) {
		json['version.label'].message = getVersionLabelZh();
		console.log(`✓ Updated version in ${translationFile}`);
		console.log(`  Current version: ${getVersionLabelZh()}`);
	} else {
		console.warn(`⚠ Warning: 'version.label' key not found in ${translationFile}`);
	}

	fs.writeFileSync(translationFile, JSON.stringify(json, null, 2) + '\n', 'utf8');
} else {
	console.warn(`⚠ Warning: Translation file not found: ${translationFile}`);
}

