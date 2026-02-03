import { createTheme } from '@mui/material/styles';

// eslint-disable-next-line @typescript-eslint/no-namespace
export namespace Color {
	export const Background = '#1f1f1f';
	export const BackgroundDark = '#181818';

	export const Primary = '#ccc';
	export const Secondary = '#ccca';

	export const TextPrimary = '#eee';
	export const TextSecondary = '#eee8';

	export const Theme = '#fac03d';

	export const Line = '#ffffff20';

	export const Error = '#f44336';
	export const Warning = '#ff9800';
	export const Info = '#abb85d';
};

export const theme = createTheme({
	palette: {
		background: {
			default: Color.Background,
			paper: Color.BackgroundDark,
		},
		primary: {
			main: Color.Primary,
		},
		secondary: {
			main: Color.Secondary,
		},
		text: {
			primary: Color.TextPrimary,
			secondary: Color.TextSecondary,
		},
		action: {
			hover: Color.Theme + '66',
			focus: Color.Theme + '44',
			active: Color.Theme + '22',
		}
	}
});