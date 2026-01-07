/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

use dora_ssr::*;

pub fn test() {
	let model_file = "Model/xiaoli.model";

	let mut looks = Model::get_looks(model_file);
	if looks.len() == 0 {
		looks.push("".to_string());
	}

	let mut animations = Model::get_animations(model_file);
	if animations.len() == 0 {
		animations.push("".to_string());
	}

	let mut current_look = looks.iter().position(|x| x == "happy").unwrap_or(0);
	current_look = current_look.max(0);
	let mut current_anim = animations.iter().position(|x| x == "idle").unwrap_or(0);
	current_anim = current_anim.max(0);

	let mut model = match Model::new(model_file) {
		Some(model) => model,
		None => return,
	};
	model.set_recovery(0.2);
	model.set_look(&looks[current_look]);
	model.play(&animations[current_anim], true);
	Slot::on_animation_end(&mut model, |name, _| {
		p!("{} end", name);
	});

	let mut loop_ = true;
	let window_flags =
		ImGuiWindowFlag::NoResize |
		ImGuiWindowFlag::NoSavedSettings;
	let mut imgui_node = Node::new();
	let mut model = model.clone();
	imgui_node.schedule(Box::new(move |_| {
		let width = App::get_visual_size().width;
		ImGui::set_next_window_pos_opts(&Vec2::new(width - 250.0, 10.0), ImGuiCond::FirstUseEver, &Vec2::zero());
		ImGui::set_next_window_size_opts(&Vec2::new(240.0, 325.0), ImGuiCond::FirstUseEver);
		ImGui::begin_opts("Model", window_flags, || {
			ImGui::text("Model (Rust)");
			let looks_str: Vec<&str> = looks.iter().map(AsRef::as_ref).collect();
			let (changed, current_look_temp) = ImGui::combo_ret("Look", current_look as i32, &looks_str);
			if changed {
				current_look = current_look_temp as usize;
				model.set_look(&looks[current_look as usize]);
			}
			let animations_str: Vec<&str> = animations.iter().map(AsRef::as_ref).collect();
			let (changed, current_anim_temp) = ImGui::combo_ret("Anim", current_anim as i32, &animations_str);
			if changed {
				current_anim = current_anim_temp as usize;
				model.play(&animations[current_anim as usize], loop_);
			}
			let (changed, loop_temp) = ImGui::checkbox_ret("Loop", loop_);
			loop_ = loop_temp;
			if changed {
				model.play(&animations[current_anim as usize], loop_);
			}
			ImGui::same_line(0.0, 10.0);
			let (changed, reversed) = ImGui::checkbox_ret("Reversed", model.is_reversed());
			if changed {
				model.set_reversed(reversed);
				model.play(&animations[current_anim as usize], loop_);
			}
			ImGui::push_item_width(-70.0, || {
				let (changed, speed) = ImGui::drag_float_ret_opts("Speed", model.get_speed(), 0.01, 0.0, 10.0, "%.2f", ImGuiSliderFlag::ALWAYS_CLAMP.into());
				if changed {
					model.set_speed(speed);
				}
				let (changed, recovery) = ImGui::drag_float_ret_opts("Recovery", model.get_recovery(), 0.01, 0.0, 10.0, "%.2f", ImGuiSliderFlag::ALWAYS_CLAMP.into());
				if changed {
					model.set_recovery(recovery);
				}
				let (changed, scale) = ImGui::drag_float_ret_opts("Scale", model.get_scale_x(), 0.01, 0.5, 2.0, "%.2f", ImGuiSliderFlag::ALWAYS_CLAMP.into());
				if changed {
					model.set_scale_x(scale);
					model.set_scale_y(scale);
				}
			});
			if ImGui::button("Play", &Vec2::new(140.0, 30.0)) {
				model.play(&animations[current_anim as usize], loop_);
			}
		});
		false
	}));
}