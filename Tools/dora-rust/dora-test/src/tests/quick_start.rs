use dora_ssr::*;

pub fn test() {
	// 创建图片精灵
	let mut sprite = match Sprite::with_file("Image/logo.png") {
		Some(sprite) => sprite,
		None => return,
	};
	// 创建游戏场景树根节点
	let mut root = Node::new();
	// 挂载图片精灵到游戏场景树根节点
	root.add_child(&sprite);
	// 接收并处理点击事件移动图片精灵
	root.set_touch_enabled(true);
	root.slot(Slot::TAP_BEGAN, Box::new(move |stack| {
		let touch = match stack.pop_cast::<Touch>() {
			Some(touch) => touch,
			None => return,
		};
		sprite.perform_def(ActionDef::move_to(
			1.0, // 持续时间，单位为秒
			&sprite.get_position(), // 开始位置
			&touch.get_location(), // 结束位置
			EaseType::OutBack // 缓动函数
		), false);
	}));
}