//! Real Wasm3 -> generated Rust bindings -> GodotNode GPU regression fixture.
use dora_ssr::*;
fn main() {
    assert!(GodotNode::get_unsupported_reason().is_empty(), "GodotNode GPU capability");
    if option_env!("DORA_GODOT_BINDING_REJECTIONS") == Some("1") {
        for (width, height, buffers) in [(0, 360, 3), (640, 0, 3), (8193, 360, 3), (640, 360, 1), (640, 360, 5)] {
            assert!(GodotNode::new(env!("DORA_GODOT_BINDING_PROJECT"), "", width, height, buffers).is_none());
        }
        assert!(GodotNode::new("/dora-godot-intentionally-missing-project", "", 640, 360, 3).is_none());
        p!("GODOT_BINDING Rust constructor_rejections=6");
    }
    let mut node = GodotNode::new(env!("DORA_GODOT_BINDING_PROJECT"), "res://main.tscn", 640, 360, 3).expect("GodotNode constructor");
    assert_eq!(node.get_project_path(), env!("DORA_GODOT_BINDING_PROJECT"));
    assert_eq!(node.get_scene_file(), "res://main.tscn");
    assert!(node.get_last_error().is_empty());
    assert_eq!(node.get_viewport_size().width, 640.0);
    assert_eq!(node.get_viewport_size().height, 360.0);
    node.pause();
    assert!(node.is_paused());
    node.set_scale_x(1.25); node.set_scale_y(1.25);
    node.set_tag("GodotBindingNode"); node.add_to(&Director::get_ui());
    let mut control = Node::new();
    control.set_tag("GodotBindingControl"); control.add_to(&Director::get_ui());
    control.gslot("GodotBindingTest", Box::new(move |stack| {
        let command = stack.pop_str().expect("binding command");
        match command.as_str() {
            "probe" => { node.send_key("F9", true); node.send_key("F9", false); }
            "resume" => { node.resume(); assert!(!node.is_paused()); }
            "pause" => { node.pause(); assert!(node.is_paused()); }
            "verify" => { assert!(node.is_running()); assert!(node.get_last_error().is_empty()); }
            "input" => {
                node.resume(); node.send_pointer_move(240.0,310.0);
                node.send_pointer(240.0,310.0,1,true); node.send_pointer(240.0,310.0,1,false);
                node.send_text("Dora"); node.send_key("Space",true); node.send_key("Space",false);
            }
            "held" => { node.send_key("F8",true); node.send_pointer(20.0,20.0,1,true); }
            "restart" => { assert!(node.restart("")); }
            "resize_large" => { assert!(node.resize_viewport(800,450)); assert!(!node.resize_viewport(801,450)); }
            "resize_small" => { assert!(node.resize_viewport(320,180)); assert!(!node.resize_viewport(321,180)); }
            "resize_restore" => { assert!(node.resize_viewport(640,360)); assert!(!node.resize_viewport(641,360)); }
            "verify_large" => { let s=node.get_viewport_size();assert_eq!((s.width,s.height),(800.0,450.0));assert!(node.resize_viewport(800,450)); }
            "verify_small" => { let s=node.get_viewport_size();assert_eq!((s.width,s.height),(320.0,180.0));assert!(node.resize_viewport(320,180)); }
            "verify_restore" => { let s=node.get_viewport_size();assert_eq!((s.width,s.height),(640.0,360.0));assert!(node.resize_viewport(640,360)); }
            "resize_pause" => { node.pause();assert!(node.is_paused()); }
            "resize_resume" => { node.resume();assert!(!node.is_paused()); }
            "resize_invalid" => { assert!(!node.resize_viewport(0,180));assert!(!node.resize_viewport(-1,360));assert!(!node.resize_viewport(640,8193));assert!(node.is_running()); }
            "resize_cancel" => { assert!(node.resize_viewport(1024,576)); }
            _ => panic!("unknown command"),
        }
        p!("GODOT_BINDING Rust command={}",command);
    }));
    p!("GODOT_BINDING Rust created=1");
}
