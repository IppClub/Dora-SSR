// Shared project input, pause and scene-restart operations.
JoyButton joy_button(const char *raw) {
    const String name=String::utf8(raw?raw:"");
    if (name=="a") return JoyButton::A;if (name=="b") return JoyButton::B;
    if (name=="x") return JoyButton::X;if (name=="y") return JoyButton::Y;
    if (name=="back") return JoyButton::BACK;if (name=="guide") return JoyButton::GUIDE;
    if (name=="start") return JoyButton::START;if (name=="leftstick") return JoyButton::LEFT_STICK;
    if (name=="rightstick") return JoyButton::RIGHT_STICK;if (name=="leftshoulder") return JoyButton::LEFT_SHOULDER;
    if (name=="rightshoulder") return JoyButton::RIGHT_SHOULDER;if (name=="dpup") return JoyButton::DPAD_UP;
    if (name=="dpdown") return JoyButton::DPAD_DOWN;if (name=="dpleft") return JoyButton::DPAD_LEFT;
    if (name=="dpright") return JoyButton::DPAD_RIGHT;if (name=="misc1") return JoyButton::MISC1;
    if (name=="paddle1") return JoyButton::PADDLE1;if (name=="paddle2") return JoyButton::PADDLE2;
    if (name=="paddle3") return JoyButton::PADDLE3;if (name=="paddle4") return JoyButton::PADDLE4;
    if (name=="touchpad") return JoyButton::TOUCHPAD;return JoyButton::INVALID;
}
JoyAxis joy_axis(const char *raw) {
    const String name=String::utf8(raw?raw:"");
    if (name=="leftx") return JoyAxis::LEFT_X;if (name=="lefty") return JoyAxis::LEFT_Y;
    if (name=="rightx") return JoyAxis::RIGHT_X;if (name=="righty") return JoyAxis::RIGHT_Y;
    if (name=="lefttrigger") return JoyAxis::TRIGGER_LEFT;
    if (name=="righttrigger") return JoyAxis::TRIGGER_RIGHT;return JoyAxis::INVALID;
}
void release_inputs() {
    // Input::release_pressed_events clears key/action caches, but does not
    // release mouse buttons or deliver key-up events to Controls/scripts.
    // Dispatch releases for the bridge-owned keys and all held pointer buttons.
    const auto keys=runtime.held_keys;
    runtime.held_keys.clear();
    for (Key code:keys) {
        Ref<InputEventKey> key; key.instantiate(); key->set_keycode(code); key->set_pressed(false);
        Input::get_singleton()->parse_input_event(key);
        Input::get_singleton()->flush_buffered_events();
    }
    for (uint32_t button=1;button<=9;++button) {
        auto mask=Input::get_singleton()->get_mouse_button_mask();
        auto flag=MouseButtonMask(1u << (button-1));
        if (!mask.has_flag(flag)) continue;
        mask.clear_flag(flag);
        Ref<InputEventMouseButton> mouse; mouse.instantiate();
        mouse->set_button_index(MouseButton(button)); mouse->set_pressed(false); mouse->set_button_mask(mask);
        mouse->set_position(Input::get_singleton()->get_mouse_position()); mouse->set_global_position(mouse->get_position());
        Input::get_singleton()->parse_input_event(mouse);
        Input::get_singleton()->flush_buffered_events();
    }
    const auto joy_buttons=runtime.held_joy_buttons;runtime.held_joy_buttons.clear();
    for (const auto &[device,button]:joy_buttons) {
        Ref<InputEventJoypadButton> input;input.instantiate();input->set_device(device);
        input->set_button_index(button);input->set_pressed(false);input->set_pressure(0);Input::get_singleton()->parse_input_event(input);
    }
    const auto joy_axes=runtime.active_joy_axes;runtime.active_joy_axes.clear();
    for (const auto &[device,axis]:joy_axes) {
        Ref<InputEventJoypadMotion> input;input.instantiate();input->set_device(device);
        input->set_axis(axis);input->set_axis_value(0);Input::get_singleton()->parse_input_event(input);
    }
    if (!joy_buttons.empty() || !joy_axes.empty()) Input::get_singleton()->flush_buffered_events();
    Input::get_singleton()->release_pressed_events();
}
int input(void *handle, const DoraGodotInput *event) {
    if (!valid(handle) || !event || event->size < sizeof(*event)) return 0;
    Ref<InputEvent> native;
    switch (event->kind) {
        case DORA_GODOT_POINTER_BUTTON: {
            if (event->button<1 || event->button>9) return 0;
            Ref<InputEventMouseButton> mouse; mouse.instantiate();
            mouse->set_shift_pressed(event->shift); mouse->set_ctrl_pressed(event->ctrl); mouse->set_alt_pressed(event->alt); mouse->set_meta_pressed(event->meta);
            auto mask=Input::get_singleton()->get_mouse_button_mask();
            if (event->pressed) mask.set_flag(MouseButtonMask(1u << (event->button-1)));
            else mask.clear_flag(MouseButtonMask(1u << (event->button-1)));
            mouse->set_button_mask(mask);
            mouse->set_button_index(MouseButton(event->button)); mouse->set_pressed(event->pressed);
            mouse->set_position(Vector2(event->x,event->y)); mouse->set_global_position(mouse->get_position()); native = mouse;
        } break;
        case DORA_GODOT_POINTER_MOVE: {
            Ref<InputEventMouseMotion> mouse; mouse.instantiate(); mouse->set_position(Vector2(event->x,event->y)); mouse->set_global_position(mouse->get_position());
            mouse->set_shift_pressed(event->shift); mouse->set_ctrl_pressed(event->ctrl); mouse->set_alt_pressed(event->alt); mouse->set_meta_pressed(event->meta);
            mouse->set_relative(mouse->get_position()-Input::get_singleton()->get_mouse_position());
            mouse->set_button_mask(Input::get_singleton()->get_mouse_button_mask()); native = mouse;
        } break;
        case DORA_GODOT_KEY: {
            Ref<InputEventKey> key; key.instantiate(); key->set_pressed(event->pressed);
            key->set_keycode(find_keycode(String::utf8(event->text ? event->text : "")));
            if (key->get_keycode()==Key::NONE) return 0;
            if (event->pressed) runtime.held_keys.insert(key->get_keycode());
            else runtime.held_keys.erase(key->get_keycode());
            key->set_shift_pressed(event->shift); key->set_ctrl_pressed(event->ctrl); key->set_alt_pressed(event->alt); key->set_meta_pressed(event->meta); native = key;
        } break;
        case DORA_GODOT_TEXT: {
            String text = String::utf8(event->text ? event->text : "");
            for (int i=0;i<text.length();++i) { Ref<InputEventKey> key; key.instantiate(); key->set_pressed(true); key->set_unicode(text[i]); Input::get_singleton()->parse_input_event(key); Input::get_singleton()->flush_buffered_events(); }
            return 1;
        }
        case DORA_GODOT_FOCUS:
            if (event->pressed) runtime.instance->focus_in();
            else { release_inputs(); runtime.instance->focus_out(); }
            return 1;
        case DORA_GODOT_CONTROLLER_BUTTON: {
            const auto button=joy_button(event->text);if (button==JoyButton::INVALID) return 0;
            const int device=int(event->button);const auto key=std::make_pair(device,button);
            if (event->pressed) runtime.held_joy_buttons.insert(key);else runtime.held_joy_buttons.erase(key);
            Ref<InputEventJoypadButton> input;input.instantiate();input->set_device(device);
            input->set_button_index(button);input->set_pressed(event->pressed);input->set_pressure(event->pressed?1.0f:0.0f);native=input;
        } break;
        case DORA_GODOT_CONTROLLER_AXIS: {
            const auto axis=joy_axis(event->text);if (axis==JoyAxis::INVALID || event->x < -1.0 || event->x > 1.0) return 0;
            const int device=int(event->button);const auto key=std::make_pair(device,axis);
            if (event->x==0.0) runtime.active_joy_axes.erase(key);else runtime.active_joy_axes.insert(key);
            Ref<InputEventJoypadMotion> input;input.instantiate();input->set_device(device);
            input->set_axis(axis);input->set_axis_value(float(event->x));native=input;
        } break;
        default: return 0;
    }
    Input::get_singleton()->parse_input_event(native);
    Input::get_singleton()->flush_buffered_events();
    return 1;
}
int set_paused(void *handle, int value) {
    if (!valid(handle)) return 0;
    runtime.paused = value != 0; runtime.tree->set_pause(runtime.paused);
    return 1;
}
int restart_scene(void *handle, const char *path) {
    if (!valid(handle)) return 0;
    Error error = path && *path ? runtime.tree->change_scene_to_file(String::utf8(path)) : runtime.tree->reload_current_scene();
    if (error != OK) { runtime.error = "Godot scene restart failed"; return 0; }
    return 1;
}
