import { Color } from "Dora";
import * as nvg from "nvg";
import type { PaintContext } from "UIX/paint/PaintNode";
import type { ProgressVariant, Rect, UiVariant } from "UIX/types";
import { clamp } from "UIX/types";
import { withAlpha } from "UIX/paint/color";

export function rect(this: void, width: number, height: number): Rect {
	return { x: 0, y: 0, width, height };
}

export function roundedPanel(this: void, ctx: PaintContext, r: Rect, options?: {
	variant?: "default" | "glass" | "solid";
	radius?: number;
	elevated?: boolean;
}): void {
	const theme = ctx.theme;
	const radius = options?.radius ?? theme.radius.md;
	const elevated = options?.elevated !== false;
	if (elevated) {
		nvg.BeginPath();
		nvg.RoundedRect(r.x + 2, r.y + 3, r.width, r.height, radius);
		nvg.FillColor(Color(withAlpha(0xff000000, theme.painter.shadowAlpha * ctx.opacity)));
		nvg.Fill();
	}
	const fill = options?.variant === "solid" ? theme.colors.surface.base : theme.colors.surface.raised;
	nvg.BeginPath();
	nvg.RoundedRect(r.x, r.y, r.width, r.height, radius);
	nvg.FillColor(Color(withAlpha(fill, ctx.opacity)));
	nvg.Fill();
	nvg.BeginPath();
	nvg.RoundedRect(r.x + 0.5, r.y + 0.5, r.width - 1, r.height - 1, radius);
	nvg.StrokeWidth(theme.stroke.hairline);
	nvg.StrokeColor(Color(withAlpha(theme.colors.line.normal, ctx.opacity)));
	nvg.Stroke();
}

export function buttonSurface(this: void, ctx: PaintContext, r: Rect, options?: {
	variant?: UiVariant;
	radius?: number;
}): void {
	const theme = ctx.theme;
	const state = ctx.state;
	const variant = options?.variant ?? "primary";
	const radius = options?.radius ?? theme.radius.md;
	let fill = theme.colors.surface.raised;
	let stroke = theme.colors.line.normal;
	if (variant === "primary") stroke = theme.colors.accent.primary;
	if (variant === "secondary") stroke = theme.colors.accent.secondary;
	if (variant === "danger") stroke = theme.colors.state.danger;
	if (variant === "glass") fill = withAlpha(theme.colors.surface.raised, 0.78);
	if (variant === "ghost") fill = withAlpha(theme.colors.surface.raised, state.hovered || state.pressed ? 0.45 : 0.08);
	if (state.selected) fill = withAlpha(theme.colors.accent.primary, 0.35);
	if (state.pressed) fill = theme.colors.surface.sunken;
	if (state.disabled) {
		fill = withAlpha(theme.colors.surface.sunken, theme.painter.disabledAlpha);
		stroke = theme.colors.line.subtle;
	}
	nvg.BeginPath();
	nvg.RoundedRect(r.x, r.y, r.width, r.height, radius);
	nvg.FillColor(Color(withAlpha(fill, ctx.opacity)));
	nvg.Fill();
	if (!state.disabled && (state.hovered || state.selected)) {
		nvg.BeginPath();
		nvg.RoundedRect(r.x + 1, r.y + 1, r.width - 2, r.height - 2, radius);
		nvg.FillColor(Color(withAlpha(theme.colors.accent.primary, 0.12 * ctx.opacity)));
		nvg.Fill();
	}
	nvg.BeginPath();
	nvg.RoundedRect(r.x + 0.5, r.y + 0.5, r.width - 1, r.height - 1, radius);
	nvg.StrokeWidth(state.focused ? theme.stroke.normal : theme.stroke.hairline);
	nvg.StrokeColor(Color(withAlpha(stroke, state.disabled ? 0.45 : ctx.opacity)));
	nvg.Stroke();
}

export function progressTrack(this: void, ctx: PaintContext, r: Rect): void {
	const theme = ctx.theme;
	nvg.BeginPath();
	nvg.RoundedRect(r.x, r.y, r.width, r.height, math.min(theme.radius.sm, r.height / 2));
	nvg.FillColor(Color(withAlpha(theme.colors.surface.sunken, ctx.opacity)));
	nvg.Fill();
	nvg.StrokeWidth(theme.stroke.hairline);
	nvg.StrokeColor(Color(withAlpha(theme.colors.line.subtle, ctx.opacity)));
	nvg.Stroke();
}

export function progressFill(this: void, ctx: PaintContext, r: Rect, progress: number, variant: ProgressVariant): void {
	const theme = ctx.theme;
	const p = clamp(progress, 0, 1);
	if (p <= 0) return;
	let color = theme.colors.accent.primary;
	if (variant === "health") color = theme.colors.state.danger;
	if (variant === "mana") color = theme.colors.state.mana;
	if (variant === "shield") color = theme.colors.state.shield;
	if (variant === "warm") color = theme.colors.accent.warm;
	const width = math.max(1, r.width * p);
	nvg.BeginPath();
	nvg.RoundedRect(r.x, r.y, width, r.height, math.min(theme.radius.sm, r.height / 2));
	nvg.FillColor(Color(withAlpha(color, ctx.opacity)));
	nvg.Fill();
}

export function focusRing(this: void, ctx: PaintContext, r: Rect, options?: {
	inset?: number;
	radius?: number;
	color?: number;
}): void {
	if (!ctx.state.focused || ctx.state.disabled) return;
	const theme = ctx.theme;
	const inset = options?.inset ?? -2;
	const radius = options?.radius ?? theme.radius.md + 2;
	nvg.BeginPath();
	nvg.RoundedRect(r.x + inset, r.y + inset, r.width - inset * 2, r.height - inset * 2, radius);
	nvg.StrokeWidth(theme.stroke.focus);
	nvg.StrokeColor(Color(withAlpha(options?.color ?? theme.colors.focus.ring, ctx.opacity)));
	nvg.Stroke();
}

export function cooldownMask(this: void, ctx: PaintContext, r: Rect, progress: number): void {
	const p = clamp(progress, 0, 1);
	if (p <= 0) return;
	const height = r.height * p;
	nvg.BeginPath();
	nvg.RoundedRect(r.x, r.y, r.width, height, ctx.theme.radius.md);
	nvg.FillColor(Color(withAlpha(ctx.theme.colors.accent.primary, 0.34 * ctx.opacity)));
	nvg.Fill();
}

function itemQualityColor(this: void, ctx: PaintContext, quality: string): number {
	if (quality === "rare") return ctx.theme.colors.accent.secondary;
	if (quality === "epic") return 0xffb85cff;
	if (quality === "legendary") return ctx.theme.colors.accent.warm;
	if (quality === "common") return ctx.theme.colors.line.strong;
	return ctx.theme.colors.line.subtle;
}

export function itemSlotSurface(this: void, ctx: PaintContext, r: Rect, quality: string, selected?: boolean): void {
	const theme = ctx.theme;
	const radius = theme.radius.md;
	const state = ctx.state;
	const fill = state.disabled ? withAlpha(theme.colors.surface.sunken, theme.painter.disabledAlpha) : theme.colors.surface.sunken;
	let stroke = itemQualityColor(ctx, quality);
	if (state.pressed) stroke = theme.colors.text.primary;
	if (selected === true || state.selected) stroke = theme.colors.accent.primary;
	nvg.BeginPath();
	nvg.RoundedRect(r.x, r.y, r.width, r.height, radius);
	nvg.FillColor(Color(withAlpha(fill, ctx.opacity)));
	nvg.Fill();
	if (quality !== "empty" && !state.disabled) {
		nvg.BeginPath();
		nvg.RoundedRect(r.x + 3, r.y + 3, r.width - 6, r.height - 6, math.max(1, radius - 2));
		nvg.FillColor(Color(withAlpha(stroke, selected === true || state.selected ? 0.24 : 0.12)));
		nvg.Fill();
	}
	nvg.BeginPath();
	nvg.RoundedRect(r.x + 0.5, r.y + 0.5, r.width - 1, r.height - 1, radius);
	nvg.StrokeWidth(selected === true || state.selected ? theme.stroke.normal : theme.stroke.hairline);
	nvg.StrokeColor(Color(withAlpha(stroke, state.disabled ? 0.38 : ctx.opacity)));
	nvg.Stroke();
}
