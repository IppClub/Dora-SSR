/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import ReactDOM from 'react-dom/client';
import './index.css';
import reportWebVitals from './reportWebVitals';
import React from 'react';
import * as Service from './Service';
import i18n from './i18n';
import Info from './Info';
import Path from './3rdParty/Path';

const App = React.lazy(() => Service.info().then((res) => {
	const {locale} = res;
	Info.locale = locale;
	Info.platform = res.platform;
	Info.path = res.platform === "Windows" ? Path.win32 : Path.posix;
	Info.version = res.version;
	Info.engineDev = res.engineDev;
	Info.webProfiler = res.webProfiler;
	Info.drawerWidth = res.drawerWidth;

	Path.setPath(Info.path);

	(window as any).getLanguageSetting = () => {
		if (locale.match(/^zh/)) {
			return "zh-cn";
		}
		return "en";
	};
	i18n.changeLanguage(locale.match(/^zh/) ? "zh" : "en");
	return import('./App');
}).catch(() => import('./App')));

const root = ReactDOM.createRoot(
	document.getElementById('root') as HTMLElement
);
root.render(<App/>);

// If you want to start measuring performance in your app, pass a function
// to log results (for example: reportWebVitals(console.log))
// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
reportWebVitals();
