import { createTheme } from '@mui/material/styles';

// eslint-disable-next-line @typescript-eslint/no-namespace
export namespace Color {
	export const Background = '#1d1d1d';
	export const BackgroundDark = '#161616';
	export const SurfaceRaised = '#242424';
	export const SurfaceHover = '#ffffff0a';

	export const Primary = '#ccc';
	export const Secondary = '#ccca';

	export const TextPrimary = '#eee';
	export const TextSecondary = '#eee8';
	export const DisabledText = '#9a9a9a';
	export const DisabledBackground = '#292929';
	export const DisabledBorder = '#414141';

	export const Theme = '#fac03d';
	export const ThemeMuted = '#fac03d1f';

	export const Line = '#ffffff20';
	export const LineStrong = '#ffffff38';

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
		MuiDialog: {
			styleOverrides: {
				paper: {
					backgroundColor: Color.BackgroundDark,
					backgroundImage: 'none',
					border: `1px solid ${Color.Line}`,
					borderRadius: 10,
					boxShadow: '0 20px 60px rgba(0, 0, 0, 0.46)',
				},
			},
		},
		MuiDialogTitle: {
			styleOverrides: {
				root: {
					backgroundColor: 'inherit',
				},
			},
		},
		MuiDialogContent: {
			styleOverrides: {
				root: {
					backgroundColor: 'inherit',
				},
			},
		},
		MuiDialogActions: {
			styleOverrides: {
				root: {
					backgroundColor: 'inherit',
				},
			},
		},
		MuiButtonBase: {
			defaultProps: {
				disableRipple: true,
			},
		},
		MuiButton: {
			styleOverrides: {
				root: {
					borderRadius: 6,
					textTransform: 'none',
					'&.Mui-disabled': {
						color: Color.DisabledText,
						borderColor: Color.DisabledBorder,
						backgroundColor: Color.DisabledBackground,
					},
				},
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
