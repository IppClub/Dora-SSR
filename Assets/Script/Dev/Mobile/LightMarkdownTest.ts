import { Content } from "Dora";
import { parseLightMarkdown } from "Dev/Mobile/LightMarkdown";

try {
	const blocks = parseLightMarkdown("# 标题\n## 二级\n- 项目\n- [x] 完成\n**重点**\n```ts\nconst x = 1\n```");
	if (blocks.map(item => item.kind).join(",") !== "heading1,heading2,list,task,paragraph,code") throw new Error("block kinds mismatch");
	if (blocks[4].text !== "重点") throw new Error("inline emphasis cleanup mismatch");
	Content.save("/tmp/dora-mobile-light-markdown.result", "passed");
} catch (error) {
	Content.save("/tmp/dora-mobile-light-markdown.result", `failed: ${error}`);
}
