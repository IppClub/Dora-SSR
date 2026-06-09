import { createTheme } from '@mui/material/styles';

// eslint-disable-next-line @typescript-eslint/no-namespace
export namespace Color {
	export const Background = '#1f1f1f';
	export const BackgroundDark = '#181818';

	export const Primary = '#ccc';
	export const Secondary = '#ccca';

	export const TextPrimary = '#eee';
	export const TextSecondary = '#eee8';
	export const DisabledText = '#9a9a9a';
	export const DisabledBackground = '#292929';
	export const DisabledBorder = '#414141';

	export const Theme = '#fac03d';

	export const Line = '#ffffff20';

	export const Error = '#f44336';
	export const Warning = '#ff9800';
	export const Info = '#abb85d';
}; // namespace Color

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
			disabled: Color.DisabledText,
			disabledBackground: Color.DisabledBackground,
			disabledOpacity: 1,
		}
	},
	components: {
		MuiButtonBase: {
			defaultProps: {
				disableRipple: true,
			},
		},
		MuiOutlinedInput: {
			styleOverrides: {
				root: {
					'& .MuiOutlinedInput-notchedOutline': {
						borderColor: Color.Line,
					},
					'&:hover .MuiOutlinedInput-notchedOutline': {
						borderColor: Color.TextSecondary,
					},
					'&.Mui-focused .MuiOutlinedInput-notchedOutline': {
						borderColor: Color.TextPrimary,
					},
					'&.Mui-disabled': {
						backgroundColor: Color.DisabledBackground,
						color: Color.DisabledText,
					},
					'&.Mui-disabled .MuiOutlinedInput-notchedOutline': {
						borderColor: Color.DisabledBorder,
					},
					'& .MuiInputBase-input.Mui-disabled': {
						WebkitTextFillColor: Color.DisabledText,
					},
				},
			},
		},
		MuiInputLabel: {
			styleOverrides: {
				root: {
					'&.Mui-disabled': {
						color: Color.DisabledText,
					},
				},
			},
		},
		MuiButton: {
			styleOverrides: {
				root: {
					'&.Mui-disabled': {
						color: Color.DisabledText,
						borderColor: Color.DisabledBorder,
						backgroundColor: Color.DisabledBackground,
					},
				},
			},
		},
		MuiIconButton: {
			styleOverrides: {
				root: {
					'&.Mui-disabled': {
						color: Color.DisabledText,
						borderColor: Color.DisabledBorder,
						backgroundColor: Color.DisabledBackground,
					},
				},
			},
		},
		MuiFormControlLabel: {
			styleOverrides: {
				label: {
					'&.Mui-disabled': {
						color: Color.DisabledText,
					},
				},
			},
		},
	}
});
