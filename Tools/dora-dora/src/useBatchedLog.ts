/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import { useEffect, useState } from "react";
import * as Service from "./Service";

export interface LogSnapshot {
	text: string;
	truncated: boolean;
};

const readSnapshot = (): LogSnapshot => ({
	text: Service.getLog(),
	truncated: Service.isLogTruncated(),
});

export const useBatchedLog = (active = true, interval = 80) => {
	const [snapshot, setSnapshot] = useState<LogSnapshot>(readSnapshot);

	useEffect(() => {
		if (!active) return;
		let timer: ReturnType<typeof setTimeout> | null = null;
		const flush = () => {
			timer = null;
			setSnapshot(readSnapshot());
		};
		const logListener = () => {
			if (timer !== null) return;
			timer = setTimeout(flush, interval);
		};
		setSnapshot(readSnapshot());
		Service.addLogListener(logListener);
		return () => {
			Service.removeLogListener(logListener);
			if (timer !== null) clearTimeout(timer);
		};
	}, [active, interval]);

	return snapshot;
};
