use dora_ssr::*;

pub fn test() {
	let mut sprite = match Sprite::with_file("Image/logo.png") {
		Some(sprite) => sprite,
		None => return,
	};
	sprite.set_scale_x(0.5);
	sprite.set_scale_y(0.5);
	sprite.set_touch_enabled(true);
	let mut sp = sprite.clone();
	sprite.slot("TapMoved", Box::new(move |stack| {
		if let Some(touch) = stack.pop_cast::<Touch>() {
			if !touch.is_first() {
				return;
			}
			sp.set_position(&(sp.get_position() + touch.get_delta()));
		}
	}));

	let windows_flags =
		ImGuiWindowFlag::NoSavedSettings |
		ImGuiWindowFlag::NoResize;
	let mut imgui_node = Node::new();
	let mut sp = sprite.clone();
	imgui_node.schedule(Box::new(move |_| {
		let width = App::get_visual_size().width;
		ImGui::set_next_window_bg_alpha(0.35);
		ImGui::set_next_window_pos_opts(&Vec2::new(width - 10.0, 10.0), ImGuiCond::FirstUseEver, &Vec2::new(1.0, 0.0));
		ImGui::set_next_window_size_opts(&Vec2::new(240.0, 520.0), ImGuiCond::Always);
		ImGui::begin_opts("Sprite", windows_flags, || {
			ImGui::text("Sprite (Rust)");
			ImGui::begin_child_opts("SpriteSetting", &Vec2::new(-1.0, -40.0), BitFlags::default(), BitFlags::default(), || {
				let (changed, z) = ImGui::drag_float_ret_opts("Z", sp.get_z(), 1.0, -1000.0, 1000.0, "%.2f", ImGuiSliderFlag::AlwaysClamp.into());
				if changed {
					sprite.set_z(z);
				}
				let Vec2{x, y} = sprite.get_anchor();
				let (changed, x, y) = ImGui::drag_float2_ret_opts("Anchor", x, y, 0.01, 0.0, 1.0, "%.2f", BitFlags::default());
				if changed {
					sprite.set_anchor(&Vec2::new(x, y));
				}
				let Size{width, height} = sprite.get_size();
				let (changed, width, height) = ImGui::drag_float2_ret_opts("Size", width, height, 0.1, 0.0, 1000.0, "%.f", BitFlags::default());
				if changed {
					sprite.set_size(&Size::new(width, height));
				}
				let (changed, scale_x, scale_y) = ImGui::drag_float2_ret_opts("Scale", sp.get_scale_x(), sp.get_scale_y(), 0.01, -2.0, 2.0, "%.2f", BitFlags::default());
				if changed {
					sp.set_scale_x(scale_x);
					sp.set_scale_y(scale_y);
				}
				ImGui::push_item_width(-60.0, || {
					let (changed, angle) = ImGui::drag_int_ret_opts("Angle", sp.get_angle() as i32, 1.0, -360, 360, "%d", BitFlags::default());
					if changed {
						sp.set_angle(angle as f32);
					}
					let (changed, angle_x) = ImGui::drag_int_ret_opts("AngleX", sp.get_angle_x() as i32, 1.0, -360, 360, "%d", BitFlags::default());
					if changed {
						sp.set_angle_x(angle_x as f32);
					}
					let (changed, angle_y) = ImGui::drag_int_ret_opts("AngleY", sp.get_angle_y() as i32, 1.0, -360, 360, "%d", BitFlags::default());
					if changed {
						sp.set_angle_y(angle_y as f32);
					}
					let (changed, skew_x, skew_y) = ImGui::drag_int2_ret_opts("Skew", sp.get_skew_x() as i32, sp.get_skew_y() as i32, 1.0, -360, 360, "%d", BitFlags::default());
					if changed {
						sp.set_skew_x(skew_x as f32);
						sp.set_skew_y(skew_y as f32);
					}
				});
				ImGui::push_item_width(-70.0, || {
					let (changed, opacity) = ImGui::drag_float_ret_opts("Opacity", sp.get_opacity(), 0.01, 0.0, 1.0, "%.2f", ImGuiSliderFlag::AlwaysClamp.into());
					if changed {
						sp.set_opacity(opacity);
					}
				});
				ImGui::push_item_width(-1.0, || {
					let color3 = sp.get_color3();
					let (changed, color3) = ImGui::color_edit3_ret_opts("Color", &color3, ImGuiColorEditFlag::DisplayRGB.into());
					if changed {
						sp.set_color3(&color3);
					}
				});
			});
			if ImGui::button("Reset", &Vec2::new(140.0, 30.0)) {
				if let Some(mut parent) = sp.get_parent() {
					parent.remove_child(&sp, true);
					if let Some(sprite) = Sprite::with_file("Image/logo.png") {
						parent.add_child(&sprite);
						sp = sprite;
					}
				}
			}
		});
		false
	}));
}