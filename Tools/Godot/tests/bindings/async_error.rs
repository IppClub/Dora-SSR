//! Actual Wasm3 -> generated Rust binding asynchronous error propagation.
use dora_ssr::*;
fn main() {
    assert!(GodotNode::get_unsupported_reason().is_empty());
    let mut node = GodotNode::new(env!("DORA_GODOT_BINDING_PROJECT"), env!("DORA_GODOT_BINDING_ERROR_SCENE"), 640, 360, 3).expect("Asynchronous request must be accepted");
    assert!(node.get_last_error().is_empty());
    assert!(!node.is_running());
    node.add_to(&Director::get_ui());
    let mut control = Node::new();
    control.add_to(&Director::get_ui());
    p!("GODOT_BINDING_ASYNC Rust accepted=1 running=0 error_empty=1");
    let mut elapsed = 0.0;
    control.schedule(Box::new(move |dt| {
        elapsed += dt;
        assert!(elapsed < 20.0, "Asynchronous error did not reach generated binding");
        let error = node.get_last_error();
        if error.is_empty() { return false; }
        assert!(!node.is_running());
        assert!(error.contains(env!("DORA_GODOT_BINDING_EXPECTED_ERROR")), "Unexpected error: {}", error);
        p!("GODOT_BINDING_ASYNC Rust error={}", error);
        node.remove_from_parent(true);
        emit("GodotBindingAsyncError", args!("Rust", error.as_str()));
        true
    }));
}
