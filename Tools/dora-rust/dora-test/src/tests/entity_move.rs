use dora_ssr::*;

pub fn test() {
	let scene_group = Group::new(&vec!["scene"]);
	let position_group = Group::new(&vec!["position"]);

	Observer::new(EntityEvent::Add, &vec!["scene"]).watch(Box::new(move |stack| {
		stack.pop();
		if let Some(mut scene) = stack.pop_cast::<Node>() {
			let group = position_group.clone();
			scene.set_touch_enabled(true);
			scene.slot("TapEnded", Box::new(move |stack| {
				if let Some(touch) = stack.pop_cast::<Touch>() {
					let location = touch.get_location();
					group.each(Box::new(move |entity| {
						entity.clone().set("target", location);
						false
					}));
				}
			}));
		}
		false
	}));

	let get_scene = move || scene_group.get_first()?.get("scene")?.cast::<Node>();
	Observer::new(EntityEvent::Add, &vec!["image"]).watch(Box::new(move |stack| {
		if let (
			Some(mut entity),
			Some(image),
			Some(scene)
		) = (
			stack.pop_cast::<Entity>(),
			stack.pop_str(),
			get_scene()
		) {
			if let Some(mut sprite) = Sprite::with_file(&image) {
				sprite.add_to(&scene);
				sprite.run_action(&Action::scale(0.5, 0.0, 0.5, EaseType::OutBack));
				entity.set("sprite", sprite.obj());
			}
		}
		false
	}));

	Observer::new(EntityEvent::Remove, &vec!["sprite"]).watch(Box::new(|stack| {
		let mut get_old_sprite = move || stack.pop_cast::<Entity>()?.get_old("sprite")?.cast::<Sprite>();
		if let Some(mut sprite) = get_old_sprite() {
			sprite.remove_from_parent(true);
		}
		false
	}));

	Observer::new(EntityEvent::Remove, &vec!["target"]).watch(Box::new(|stack| {
		if let Some(entity) = stack.pop_cast::<Entity>() {
			p!("remove target from entity {}", entity.get_index());
		}
		false
	}));

	let mut group = Group::new(&vec!["position", "direction", "speed", "target"]);
	group.watch(Box::new(move |stack| {
		if let (
			Some(mut entity),
			Some(position),
			Some(_direction),
			Some(speed),
			Some(target)
		) = (
			stack.pop_cast::<Entity>(),
			stack.pop_vec2(),
			stack.pop_f32(),
			stack.pop_f32(),
			stack.pop_vec2()
		) {
			if target == position {
				return false;
			}
			let dir = (target - position).normalize();
			let angle = dir.x.atan2(dir.y).to_degrees();
			let new_pos = position + dir * speed;
			let new_pos = new_pos.clamp(&position, &target);
			entity.set("position", new_pos);
			entity.set("direction", angle);
			if new_pos == target {
				entity.remove("target");
			}
		}
		false
	}));

	Observer::new(EntityEvent::AddOrChange, &vec!["position", "direction", "sprite"]).watch(Box::new(move |stack| {
		if let (
			Some(entity),
			Some(position),
			Some(direction),
			Some(mut sprite)
		) = (
			stack.pop_cast::<Entity>(),
			stack.pop_vec2(),
			stack.pop_f32(),
			stack.pop_cast::<Sprite>()
		) {
			sprite.set_position(&position);
			let get_old_direction = move || entity.get_old("direction")?.into_f32();
			let last_direction = get_old_direction().unwrap_or(sprite.get_angle());
			if (direction - last_direction).abs() > 1.0 {
				sprite.run_action(&Action::roll(0.3, last_direction, direction, EaseType::InOutSine));
			}
		}
		false
	}));

	{
		let mut entity = Entity::new();
		entity.set("scene", Node::new().obj());
	}
	{
		let mut entity = Entity::new();
		entity.set("image", "Image/logo.png");
		entity.set("position", Vec2::zero());
		entity.set("direction", 45.0);
		entity.set("speed", 4.0);
	}
	{
		let mut entity = Entity::new();
		entity.set("image", "Image/logo.png");
		entity.set("position", Vec2::new(-100.0, 200.0));
		entity.set("direction", 90.0);
		entity.set("speed", 10.0);
	}

	let window_flags = ImGuiWindowFlag::NO_DECORATION |
		ImGuiWindowFlag::AlwaysAutoResize |
		ImGuiWindowFlag::NoSavedSettings |
		ImGuiWindowFlag::NoFocusOnAppearing |
		ImGuiWindowFlag::NO_NAV |
		ImGuiWindowFlag::NoMove;
	let mut imgui_node = Node::new();
	imgui_node.schedule(Box::new(move |_| {
		let width = App::get_visual_size().width;
		ImGui::set_next_window_bg_alpha(0.35);
		ImGui::set_next_window_pos_opts(&Vec2::new(width - 10.0, 10.0), ImGuiCond::Always, &Vec2::new(1.0, 0.0));
		ImGui::set_next_window_size_opts(&Vec2::new(240.0, 0.0), ImGuiCond::FirstUseEver);
		if ImGui::begin_opts("ECS System", window_flags) {
			ImGui::text("ECS System (Rust)");
			ImGui::separator();
			ImGui::text_wrapped("Tap any place to move entities.");
			if ImGui::button("Create Random Entity", &Vec2::zero()) {
				let mut entity = Entity::new();
				entity.set("image", "Image/logo.png");
				entity.set("position", Vec2::new(
					6.0 * (App::get_rand() % 100) as f32,
					6.0 * (App::get_rand() % 100) as f32));
				entity.set("direction", 1.0 * (App::get_rand() % 360) as f32);
				let speed = 1.0 * (App::get_rand() % 20 + 1) as f32;
				entity.set("speed", speed);
			}
			if ImGui::button("Destroy An Entity", &Vec2::zero()) {
				let group = Group::new(&vec!["sprite", "position"]);
				group.each(Box::new(|entity| {
					let mut entity = entity.clone();
					entity.remove("position");
					let get_sprite = |e: &Entity| e.get("sprite")?.cast::<Sprite>();
					if let Some(mut sprite) = get_sprite(&entity) {
						sprite.run_action(&Action::sequence(&vec![
							Action::scale(0.5, 0.5, 0.0, EaseType::InBack),
							Action::event("Destroy", "")
						]));
						sprite.slot("Destroy", Box::new(move |_| {
							entity.destroy();
						}));
					}
					true
				}));
			}
		}
		ImGui::end();
		false
	}));
}