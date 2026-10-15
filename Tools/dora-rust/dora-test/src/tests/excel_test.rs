/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

use dora_ssr::*;

pub fn test() {
	const TERRAIN_LAYER: i32 = 0;
	const PLAYER_LAYER: i32 = 1;
	const ITEM_LAYER: i32 = 2;

	let player_group: i32 = platformer::Data::get_group_first_player();
	let item_group: i32 = platformer::Data::get_group_first_player() + 1;
	let terrain_group: i32 = platformer::Data::get_group_terrain();

	platformer::Data::set_should_contact(player_group, item_group, true);

	let theme_color: Color = App::get_theme_color();
	let fill_color: Color = Color {
		r: theme_color.r,
		g: theme_color.g,
		b: theme_color.b,
		a: 0x66
	};
	let border_color: Color = theme_color.clone();
	const DESIGN_WIDTH: f32 = 1000.0;

	let mut world = platformer::PlatformWorld::new();
	let mut camera = world.get_camera();
	camera.set_boundary(
		&Rect::new(&Vec2::new(-1250.0, -500.0),
		&Size::new(2500.0, 1000.0))
	);
	camera.set_follow_ratio(&Vec2::new(0.02, 0.02));
	camera.set_zoom(App::get_visual_size().width / DESIGN_WIDTH);
	let world_clone = world.clone();
	GSlot::on_app_change(&mut world, move |setting_name| {
		if setting_name == "Size" {
			world_clone.get_camera().set_zoom(
				App::get_visual_size().width / DESIGN_WIDTH
			);
		}
	});

	let mut terrain_def = BodyDef::new();
	terrain_def.set_type(BodyType::Static);
	terrain_def.attach_polygon_with_center(
		&Vec2::new(0.0, -500.0), 2500.0, 10.0,
		0.0, 1.0, 1.0, 0.0
	);
	terrain_def.attach_polygon_with_center(
		&Vec2::new(0.0, 500.0), 2500.0, 10.0,
		0.0, 1.0, 1.0, 0.0
	);
	terrain_def.attach_polygon_with_center(
		&Vec2::new(1250.0, 0.0), 10.0, 1000.0,
		0.0, 1.0, 1.0, 0.0
	);
	terrain_def.attach_polygon_with_center(
		&Vec2::new(-1250.0, 0.0), 10.0, 1000.0,
		0.0, 1.0, 1.0, 0.0
	);

	let mut terrain = Body::new(&terrain_def, &world, &Vec2::zero(), 0.0);
	terrain.set_order(TERRAIN_LAYER);
	terrain.set_group(terrain_group);

	let new_rectangle = |x: f32, y: f32, width: f32, height: f32, fill_color: &Color, border_color: &Color| -> DrawNode {
		let mut draw_node = DrawNode::new();
		let hh = height / 2.0;
		let hw = width / 2.0;
		draw_node.draw_polygon(&vec![
			Vec2::new(x - hw, y - hh),
			Vec2::new(x - hw, y + hh),
			Vec2::new(x + hw, y + hh),
			Vec2::new(x + hw, y - hh)
		], fill_color, 1.0, border_color);
		draw_node
	};

	terrain.add_child(&new_rectangle(
		0.0, -500.0, 2500.0, 10.0,
		&fill_color, &border_color
	));
	terrain.add_child(&new_rectangle(
		1250.0, 0.0, 10.0, 1000.0,
		&fill_color, &border_color
	));
	terrain.add_child(&new_rectangle(
		-1250.0, 0.0, 10.0, 1000.0,
		&fill_color, &border_color
	));
	world.add_child(&terrain);

	platformer::UnitAction::add("idle",
		1,
		2.0,
		0.2,
		false,
		Box::new(|unit, _| {
			unit.is_on_surface()
		}),
		Box::new(|unit, _| {
			let mut playable = unit.get_playable();
			playable.set_speed(1.0);
			playable.play("idle", true);
			let mut play_idle_special = once(move |mut co| async move {
				loop {
					sleep!(co, 3.0);
					sleep!(co, playable.play("idle1", false));
					playable.play("idle", true);
				}
			});
			platformer::ActionUpdate::new(Box::new(move |unit, _, dt| {
				play_idle_special(dt as f64);
				!unit.is_on_surface()
			}))
		}),
		Box::new(|_, _| { })
	);

	platformer::UnitAction::add("move",
		1,
		2.0,
		0.2,
		false,
		Box::new(|unit, _| {
			unit.is_on_surface()
		}),
		Box::new(|unit, _| {
			let mut playable = unit.get_playable();
			playable.set_speed(1.0);
			playable.play("fmove", true);
			platformer::ActionUpdate::new(Box::new(move |unit, action, _| {
				let elapsed_time = action.get_elapsed_time();
				let recovery = action.get_recovery() * 2.0;
				let get_movement = || unit.get_unit_def().get("move")?.into_f32();
				let movement = get_movement().unwrap_or(0.0);
				let mut move_speed = 1.0;
				if elapsed_time < recovery {
					move_speed = elapsed_time / recovery;
					move_speed = move_speed.min(1.0);
				}
				let mut unit = unit.clone();
				unit.set_velocity_x(move_speed * if unit.is_face_right() { movement } else { -movement });
				!unit.is_on_surface()
			}))
		}),
		Box::new(|_, _| { })
	);

	platformer::UnitAction::add("jump",
		3,
		2.0,
		0.1,
		true,
		Box::new(|unit, _| {
			unit.is_on_surface()
		}),
		Box::new(|unit, _| {
			let get_jump = || unit.get_unit_def().get("jump")?.into_f32();
			let jump = get_jump().unwrap_or(0.0);
			let mut unit = unit.clone();
			unit.set_velocity_y(jump);
			let mut playable = unit.get_playable();
			playable.set_speed(1.0);
			playable.play("jump", false);
			platformer::ActionUpdate::from_update(
				once(move |mut co| async move {
					sleep!(co, playable.play("jump", false));
				})
			)
		}),
		Box::new(|_, _| { })
	);

	platformer::UnitAction::add("fallOff",
		2,
		-1.0,
		0.3,
		false,
		Box::new(|unit, _| {
			!unit.is_on_surface()
		}),
		Box::new(|unit, _| {
			if unit.get_playable().get_current() != "jumping" {
				let mut playable = unit.get_playable();
				playable.set_speed(1.0);
				playable.play("jumping", true);
			}
			let unit = unit.clone();
			platformer::ActionUpdate::from_update(
				once(move |mut co| async move {
					loop {
						if unit.is_on_surface() {
							let mut playable = unit.get_playable();
							playable.set_speed(1.0);
							sleep!(co, playable.play("landing", false));
							return;
						}
						co.waiter().await;
					}
				})
			)
		}),
		Box::new(|_, _| { })
	);

	use platformer::decision::Tree as D;

	platformer::Data::get_store().set("AI:playerControl", D::sel(&vec![
		D::seq(&vec![
			D::con("fmove key down", Box::new(|unit| {
				let entity = unit.get_entity();
				let get_key = |key: &str| entity.get(key)?.into_bool();
				let key_left = get_key("keyLeft").unwrap_or(false);
				let key_right = get_key("keyRight").unwrap_or(false);
				(key_left != key_right) && (
					(key_left && unit.is_face_right()) ||
					(key_right && !unit.is_face_right())
				)
			})),
			D::act("turn")
		]),
		D::seq(&vec![
			D::con("is falling", Box::new(|unit| {
				!unit.is_on_surface()
			})),
			D::act("fallOff")
		]),
		D::seq(&vec![
			D::con("jump key down", Box::new(|unit| {
				let entity = unit.get_entity();
				let get_jump = || entity.get("keyJump")?.into_bool();
				get_jump().unwrap_or(false)
			})),
			D::act("jump")
		]),
		D::seq(&vec![
			D::con("fmove key down", Box::new(|unit| {
				let entity = unit.get_entity();
				let get_key = |key: &str| entity.get(key)?.into_bool();
				get_key("keyLeft").unwrap_or(false) || get_key("keyRight").unwrap_or(false)
			})),
			D::act("move")
		]),
		D::act("idle")
	]).obj());

	let mut unit_def = Dictionary::new();
	unit_def.set("linearAcceleration", Vec2::new(0.0, -15.0));
	unit_def.set("bodyType", "Dynamic");
	unit_def.set("scale", 1.0);
	unit_def.set("density", 1.0);
	unit_def.set("friction", 1.0);
	unit_def.set("restitution", 0.0);
	unit_def.set("playable", "spine:Spine/moling");
	unit_def.set("defaultFaceRight", true);
	unit_def.set("size", Size::new(60.0, 300.0));
	unit_def.set("sensity", 0);
	unit_def.set("move", 300.0);
	unit_def.set("jump", 1000.0);
	unit_def.set("detectDistance", 350.0);
	unit_def.set("hp", 5.0);
	unit_def.set("tag", "player");
	unit_def.set("decisionTree", "AI:playerControl");
	unit_def.set("usePreciseHit", false);
	let mut arr = Array::new();
	unit_def.set("actions", arr
		.add("idle")
		.add("turn")
		.add("move")
		.add("jump")
		.add("fallOff")
		.add("cancel")
		.obj()
	);

	let mut world_clone = world.clone();
	let mut observer = Observer::new(EntityEvent::Add, &vec!["player"]);
	observer.watch(Box::new(move |stack| {
		let entity = match stack.pop_cast::<Entity>() {
			Some(entity) => entity,
			None => return false
		};
		let mut unit = platformer::Unit::new(&unit_def, &world_clone, &entity, &Vec2::new(300.0, -350.0), 0.0);
		unit.set_order(PLAYER_LAYER);
		unit.set_group(player_group);
		unit.get_playable().set_position(&Vec2::new(0.0, -150.0));
		unit.get_playable().play("idle", true);
		world_clone.add_child(&unit);
		world_clone.get_camera().set_follow_target(&unit);
		false
	}));

	let mut observer = Observer::new(EntityEvent::Add, &vec!["x", "icon"]);
	let mut world_clone = world.clone();
	observer.watch(Box::new(move |stack| {
		let (mut entity, x, icon) = match (
			stack.pop_cast::<Entity>(),
			stack.pop_f32(),
			stack.pop_str()
		) {
			(Some(entity), Some(x), Some(icon)) => (entity, x, icon),
			_ => return false
		};
		let mut sprite = match Sprite::with_file(&icon) {
			Some(sprite) => sprite,
			None => return false
		};
		sprite.run_action_def(
			ActionDef::spawn(&vec![
				ActionDef::prop(5.0, 0.0, 360.0, Property::AngleY, EaseType::Linear),
				ActionDef::sequence(&vec![
					ActionDef::prop(2.5, 0.0, 40.0, Property::Y, EaseType::OutQuad),
					ActionDef::prop(2.5, 40.0, 0.0, Property::Y, EaseType::InQuad)
				])
			]), true);

		let mut body_def = BodyDef::new();
		body_def.set_type(BodyType::Dynamic);
		body_def.set_linear_acceleration(&Vec2::new(0.0, -10.0));
		body_def.attach_polygon(sprite.get_width() * 0.5, sprite.get_height(), 1.0, 1.0, 0.0);
		body_def.attach_polygon_sensor(0, sprite.get_width(), sprite.get_height());

		let mut body = Body::new(&body_def, &world_clone, &Vec2::new(x, 0.0), 0.0);
		body.set_order(ITEM_LAYER);
		body.set_group(item_group);
		body.add_child(&sprite);

		let mut body_clone = body.clone();
		let mut entity_clone = entity.clone();
		Slot::on_body_enter(&mut body, move |other, _| {
			if cast::<platformer::Unit>(&other).is_some() {
				body_clone.set_group(platformer::Data::get_group_hide());
				let mut body_clone_two = body_clone.clone();
				let mut sprite_clone = sprite.clone();
				entity_clone.set("picked", true);
				body_clone.schedule(once(move |mut co| async move {
					sleep!(co, sprite_clone.run_action_def(
						ActionDef::spawn(&vec![
							ActionDef::scale(0.2, 1.0, 1.3, EaseType::OutBack),
							ActionDef::prop(0.2, 1.0, 0.0, Property::Opacity, EaseType::Linear)
						]), false)
					);
					body_clone_two.set_group(platformer::Data::get_group_hide());
				}));
			}
		});

		world_clone.add_child(&body);
		entity.set("body", body.obj());
		false
	}));

	let mut observer = Observer::new(EntityEvent::Remove, &vec!["body"]);
	observer.watch(Box::new(|stack| {
		let entity = match stack.pop_cast::<Entity>() {
			Some(entity) => entity,
			None => return false
		};
		let get_body = || entity.get_old("body")?.cast::<Body>();
		let mut body = match get_body() {
			Some(body) => body,
			None => return false
		};
		body.remove_from_parent(true);
		false
	}));

	let load_excel = || {
		let item_group = Group::new(&vec!["item"]);
		item_group.each(Box::new(|entity| {
			entity.clone().destroy();
			false
		}));
		let mut work_book = Content::load_excel("Data/items.xlsx");
		let mut work_sheet = work_book.get_sheet("items");
		let arr = Array::new();
		while work_sheet.read(&arr) {
			let get_str = |arr: &Array, i: i32| arr.get(i)?.into_str();
			let get_f64 = |arr: &Array, i: i32| arr.get(i)?.into_f64();
			let mut entity = Entity::new();
			entity.set("item", true);
			for i in 0..arr.get_count() as i32 {
				match (i, get_str(&arr, i), get_f64(&arr, i)) {
					(1, None, Some(value)) => entity.set("no", value),
					(2, Some(value), None) => entity.set("name", value.as_str()),
					(3, None, Some(value)) => entity.set("x", value),
					(4, None, Some(value)) => entity.set("num", value),
					(5, Some(value), None) => entity.set("icon", value.as_str()),
					(6, Some(value), None) => entity.set("desc", value.as_str()),
					_ => { }
				}
			}
		}
	};

	let player_group = Group::new(&vec!["player"]);
	let player_group_clone = player_group.clone();
	let update_player_control = move |key: &str, flag: bool| {
		let key = key.to_string();
		player_group_clone.each(Box::new(move |entity| {
			let mut entity = entity.clone();
			entity.set(&key, flag);
			false
		}));
	};

	let mut node = Node::new();
	node.schedule(Box::new(move |_| {
		update_player_control("keyLeft", Keyboard::is_key_pressed(KeyName::A));
		update_player_control("keyRight", Keyboard::is_key_pressed(KeyName::D));
		update_player_control("keyJump", Keyboard::is_key_pressed(KeyName::J));
		false
	}));

	let picked_item_group = Group::new(&vec!["picked"]);
	let window_flags = ImGuiWindowFlag::NO_DECORATION |
		ImGuiWindowFlag::AlwaysAutoResize |
		ImGuiWindowFlag::NoSavedSettings |
		ImGuiWindowFlag::NoFocusOnAppearing |
		ImGuiWindowFlag::NO_NAV |
		ImGuiWindowFlag::NoMove;
	let mut imgui_node = Node::new();
	let player_group = player_group.clone();
	imgui_node.schedule(Box::new(move |_| {
		let size = App::get_visual_size();
		ImGui::set_next_window_bg_alpha(0.35);
		ImGui::set_next_window_pos_opts(&Vec2::new(size.width - 10.0, 10.0), ImGuiCond::Always, &Vec2::new(1.0, 0.0));
		ImGui::set_next_window_size_opts(&Vec2::new(100.0, 300.0), ImGuiCond::FirstUseEver);
		let picked_item_group = picked_item_group.clone();
		let player_group = player_group.clone();
		ImGui::begin_opts("BackPack", window_flags, || {
			if ImGui::button("重新加载Excel", &Vec2::zero()) {
				load_excel();
			}
			ImGui::separator();
			ImGui::text("背包 (Rust)");
			ImGui::text("左(A) 右(D) 跳(J)");
			ImGui::separator();
			ImGui::columns_opts(3, false, "BackPackColumns");
			picked_item_group.each(Box::new(move |entity| {
				let mut entity = entity.clone();
				let get_str = |key: &str| entity.get(key)?.into_str();
				let get_f32 = |key: &str| entity.get(key)?.into_f64();
				let (no, icon, num, name, desc) = match (
					get_f32("no"), get_str("icon"),
					get_f32("num"), get_str("name"), get_str("desc")
				) {
					(Some(no), Some(icon), Some(num), Some(name), Some(desc)) =>
					(no, icon, num, name, desc),
					_ => return false
				};
				if num > 0.0 {
					if ImGui::image_button(&format!("item{}", no), &icon, &Vec2::new(50.0, 50.0)) {
						entity.set("num", num - 1.0);
						let get_unit = || player_group
							.get_first()?
							.get("unit")?
							.cast::<platformer::Unit>();
						if let Some(mut unit) = get_unit() {
							let mut sprite = match Sprite::with_file(&icon) {
								Some(sprite) => sprite,
								None => return false
							};
							sprite.set_scale_x(0.5);
							sprite.set_scale_y(0.5);
							sprite.perform_def(ActionDef::spawn(&vec![
								ActionDef::prop(1.0, 1.0, 0.0, Property::Opacity, EaseType::Linear),
								ActionDef::prop(1.0, 150.0, 250.0, Property::Y, EaseType::Linear)
							]), false);
							Slot::on_action_end(&mut sprite, move |_action, mut node| {
								node.remove_from_parent(true);
							});
							unit.add_child(&sprite);
						}
					}
					if ImGui::is_item_hovered() {
						ImGui::begin_tooltip(|| {
							ImGui::text(&name);
							ImGui::text_colored(&theme_color, "数量：");
							ImGui::same_line(0.0, 10.0);
							ImGui::text(&num.to_string());
							ImGui::text_colored(&theme_color, "描述：");
							ImGui::same_line(0.0, 10.0);
							ImGui::text(&desc.to_string());
						});
					}
					ImGui::next_column();
				}
				false
			}));
		});
		false
	}));

	load_excel();

	let mut entity = Entity::new();
	entity.set("player", true);
}