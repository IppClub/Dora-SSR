local ActionDef = require("Action").Def

-- 用于创建一个帧动画，可以指定每个动画帧的持续帧数。只能在 Sprite 节点上使用。
-- @param clipStr (string) 包含加载纹理文件格式的字符串，可以是 "Image/file.png" 和 "Image/items.clip|itemA"，支持的图片文件格式有：jpg、png、dds、pvr、ktx。
-- @param duration (number) 动画的持续时间。
-- @param frames ({integer}) [可选] 每个动画帧的持续帧数。每个动画帧的持续帧数应该与图片序列中的帧数相匹配。
-- @return (ActionDef) 返回新的动作定义。
local frame: function(clipStr: string, duration: number, frames?: {integer}): ActionDef

return frame
