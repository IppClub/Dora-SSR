/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

use dora_ssr::*;

pub fn test() {
	let create_sprite = || -> Option<Sprite> {
		let mut sprite = match Sprite::with_file("Image/logo.png") {
			Some(sprite) => sprite,
			None => return None,
		};
		sprite.set_scale_x(0.5);
		sprite.set_scale_y(0.5);
		sprite.set_show_debug(true);
		sprite.set_touch_enabled(true);
		let mut sp = sprite.clone();
		sprite.slot(Slot::TAP_MOVED, Box::new(move |stack| {
			if let Some(touch) = stack.pop_cast::<Touch>() {
				if !touch.is_first() {
					return;
				}
				sp.set_position(&(sp.get_position() + touch.get_delta()));
			}
		}));
		Some(sprite)
	};
	let Some(mut sprite) = create_sprite() else {
		return;
	};

	let windows_flags =
		ImGuiWindowFlag::NoSavedSettings |
		ImGuiWindowFlag::NoResize;
	let mut imgui_node = Node::new();
	imgui_node.schedule(Box::new(move |_| {
		let width = App::get_visual_size().width;
		ImGui::set_next_window_bg_alpha(0.35);
		ImGui::set_next_window_pos_opts(&Vec2::new(width - 10.0, 10.0), ImGuiCond::FirstUseEver, &Vec2::new(1.0, 0.0));
		ImGui::set_next_window_size_opts(&Vec2::new(240.0, 520.0), ImGuiCond::Always);
		ImGui::begin_opts("Sprite", windows_flags, || {
			ImGui::text("Sprite (Rust)");
			ImGui::begin_child_opts("SpriteSetting", &Vec2::new(-1.0, -40.0), BitFlags::default(), BitFlags::default(), || {
				let (changed, z) = ImGui::drag_float_ret_opts("Z", sprite.get_z(), 1.0, -1000.0, 1000.0, "%.2f", ImGuiSliderFlag::ALWAYS_CLAMP.into());
				if changed {
					sprite.set_z(z);
				}
				let Vec2{x, y} = sprite.get_anchor();
				let (changed, x, y) = ImGui::drag_float2_ret_opts("Anchor", x, y, 0.01, 0.0, 1.0, "%.2f", BitFlags::default());
				if changed {
					sprite.set_anchor(&Vec2::new(x, y));
				}
				let Size{width, height} = sprite.get_size();
				let (changed, width, height) = ImGui::drag_float2_ret_opts("Size", width, height, 1.0, 0.0, 1500.0, "%.f", BitFlags::default());
				if changed {
					sprite.set_size(&Size::new(width, height));
				}
				let (changed, scale_x, scale_y) = ImGui::drag_float2_ret_opts("Scale", sprite.get_scale_x(), sprite.get_scale_y(), 0.01, -2.0, 2.0, "%.2f", BitFlags::default());
				if changed {
					sprite.set_scale_x(scale_x);
					sprite.set_scale_y(scale_y);
				}
				ImGui::push_item_width(-60.0, || {
					let (changed, angle) = ImGui::drag_int_ret_opts("Angle", sprite.get_angle() as i32, 1.0, -360, 360, "%d", BitFlags::default());
					if changed {
						sprite.set_angle(angle as f32);
					}
					let (changed, angle_x) = ImGui::drag_int_ret_opts("AngleX", sprite.get_angle_x() as i32, 1.0, -360, 360, "%d", BitFlags::default());
					if changed {
						sprite.set_angle_x(angle_x as f32);
					}
					let (changed, angle_y) = ImGui::drag_int_ret_opts("AngleY", sprite.get_angle_y() as i32, 1.0, -360, 360, "%d", BitFlags::default());
					if changed {
						sprite.set_angle_y(angle_y as f32);
					}
					let (changed, skew_x, skew_y) = ImGui::drag_int2_ret_opts("Skew", sprite.get_skew_x() as i32, sprite.get_skew_y() as i32, 1.0, -360, 360, "%d", BitFlags::default());
					if changed {
						sprite.set_skew_x(skew_x as f32);
						sprite.set_skew_y(skew_y as f32);
					}
				});
				ImGui::push_item_width(-70.0, || {
					let (changed, opacity) = ImGui::drag_float_ret_opts("Opacity", sprite.get_opacity(), 0.01, 0.0, 1.0, "%.2f", ImGuiSliderFlag::ALWAYS_CLAMP.into());
					if changed {
						sprite.set_opacity(opacity);
					}
				});
				ImGui::push_item_width(-1.0, || {
					let color3 = sprite.get_color3();
					let (changed, color3) = ImGui::color_edit3_ret_opts("Color", &color3, ImGuiColorEditFlag::DisplayRGB.into());
					if changed {
						sprite.set_color3(&color3);
					}
				});
			});
			if ImGui::button("Reset", &Vec2::new(140.0, 30.0)) {
				sprite.remove_from_parent(true);
				if let Some(new_sp) = create_sprite() {
					sprite = new_sp;
				}
			}
		});
		false
	}));
}