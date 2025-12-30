/**
 * Dora SSR version information
 * This file is the single source of truth for the version number.
 * Update this file when releasing a new version.
 */

module.exports = {
	version: '1.7.4',
	// Helper function to get version with 'v' prefix
	getVersionLabel: () => `v${module.exports.version}`,
	// Helper function to get version for Chinese translation
	getVersionLabelZh: () => `版本 ${module.exports.version}`,
};

