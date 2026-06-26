import type { UiSize } from "UIX/types";

export interface ThemeColors {
	surface: {
		base: number;
		raised: number;
		sunken: number;
		overlay: number;
	};
	line: {
		subtle: number;
		normal: number;
		strong: number;
	};
	accent: {
		primary: number;
		secondary: number;
		warm: number;
	};
	state: {
		danger: number;
		mana: number;
		shield: number;
		success: number;
		warning: number;
	};
	text: {
		primary: number;
		secondary: number;
		disabled: number;
		inverse: number;
	};
	focus: {
		ring: number;
		glow: number;
	};
}

export interface Theme {
	name: string;
	colors: ThemeColors;
	space: {
		xxs: number;
		xs: number;
		sm: number;
		md: number;
		lg: number;
		xl: number;
		xxl: number;
	};
	radius: {
		xs: number;
		sm: number;
		md: number;
		lg: number;
		xl: number;
	};
	stroke: {
		hairline: number;
		normal: number;
		strong: number;
		focus: number;
	};
	font: {
		name: string;
		sdf: boolean;
		size: {
			xs: number;
			sm: number;
			md: number;
			lg: number;
			xl: number;
		};
	};
	size: {
		control: Record<UiSize, number>;
		icon: Record<UiSize, number>;
	};
	motion: {
		fast: number;
		normal: number;
		slow: number;
	};
	painter: {
		shadowAlpha: number;
		bevelAlpha: number;
		disabledAlpha: number;
	};
}

export type PartialTheme = Partial<Theme>;

export const doraPrismTheme: Theme = {
	name: "Dora Prism",
	colors: {
		surface: {
			base: 0xff11161d,
			raised: 0xf01b2430,
			sunken: 0xcc080b10,
			overlay: 0xcc05070a,
		},
		line: {
			subtle: 0xaa2a3542,
			normal: 0xcc405062,
			strong: 0xddb9c7d8,
		},
		accent: {
			primary: 0xff35d0ff,
			secondary: 0xff4d7cff,
			warm: 0xffffc15a,
		},
		state: {
			danger: 0xffff4f5e,
			mana: 0xff4d7cff,
			shield: 0xff70e0ff,
			success: 0xff56d68a,
			warning: 0xffff9c3d,
		},
		text: {
			primary: 0xfff4f8ff,
			secondary: 0xff9eacbd,
			disabled: 0xaa637080,
			inverse: 0xff071017,
		},
		focus: {
			ring: 0xff35d0ff,
			glow: 0x6635d0ff,
		},
	},
	space: { xxs: 2, xs: 4, sm: 8, md: 12, lg: 16, xl: 24, xxl: 32 },
	radius: { xs: 3, sm: 4, md: 8, lg: 12, xl: 16 },
	stroke: { hairline: 1, normal: 2, strong: 3, focus: 3 },
	font: {
		name: "sarasa-mono-sc-regular",
		sdf: true,
		size: { xs: 11, sm: 13, md: 16, lg: 20, xl: 26 },
	},
	size: {
		control: { sm: 32, md: 44, lg: 56 },
		icon: { sm: 16, md: 22, lg: 30 },
	},
	motion: { fast: 0.08, normal: 0.14, slow: 0.22 },
	painter: {
		shadowAlpha: 0.28,
		bevelAlpha: 0.32,
		disabledAlpha: 0.42,
	},
};

export function mergeTheme(this: void, base: Theme, override?: PartialTheme): Theme {
	if (override === undefined) return base;
	return {
		name: override.name ?? base.name,
		colors: (override.colors as ThemeColors | undefined) ?? base.colors,
		space: override.space ?? base.space,
		radius: override.radius ?? base.radius,
		stroke: override.stroke ?? base.stroke,
		font: override.font ?? base.font,
		size: override.size ?? base.size,
		motion: override.motion ?? base.motion,
		painter: override.painter ?? base.painter,
	};
}
