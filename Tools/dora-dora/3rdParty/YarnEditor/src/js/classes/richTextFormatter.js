import { BbcodeRichTextFormatter } from './richTextFormatterBbcode';

export const RichTextFormatter = function(app) {
	const addExtraPreviewerEmbeds = result => {
		return result;
	};
	return new BbcodeRichTextFormatter(app, addExtraPreviewerEmbeds);
};
