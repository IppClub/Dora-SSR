/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

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
	Slot::on_tap_began(&mut root, move |touch| {
		sprite.perform_def(ActionDef::move_to(
			1.0, // 持续时间，单位为秒
			&sprite.get_position(), // 开始位置
			&touch.get_location(), // 结束位置
			EaseType::OutBack // 缓动函数
		), false);
	});
}