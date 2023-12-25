import ReactDOM from 'react-dom/client';
import './index.css';
import reportWebVitals from './reportWebVitals';
import React from 'react';
import * as Service from './Service';
import i18n from './i18n';
import Info from './Info';
import Path from './Path';

const App = React.lazy(() => Service.info().then((res) => {
	const {locale} = res;
	Info.locale = locale;
	Info.platform = res.platform;
	Info.path = res.platform === "Windows" ? Path.win32 : Path.posix;
	Info.version = res.version;

	Path.setPath(Info.path);

	(window as any).getLanguageSetting = () => {
		if (locale.match(/^zh/)) {
			return "zh-cn";
		}
		return "en";
	};
	i18n.changeLanguage(locale.match(/^zh/) ? "zh" : "en");
	return import('./App')
}).catch(() => import('./App')));

const root = ReactDOM.createRoot(
	document.getElementById('root') as HTMLElement
);
root.render(<App/>);

// If you want to start measuring performance in your app, pass a function
// to log results (for example: reportWebVitals(console.log))
// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
reportWebVitals();
