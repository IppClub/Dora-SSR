import {HttpClient, Path, thread, HttpServer, Content, loop, App, Vec2, Buffer, Node} from 'Dora';
import * as ImGui from 'ImGui';
import {SetCond, WindowFlag} from 'ImGui';

let url = `http://${HttpServer.localIP}:8866/Doc/zh-Hans/welcome.md`;
const targetFile = Path(Content.writablePath, ".download", "testDownloadFile");
let cancelDownload = false;
let progress = 0;

function download(this: void) {
	thread(() => {
		progress = 0;
		Content.mkdir(Path(Content.writablePath, ".download"));
		const success = HttpClient.downloadAsync(
			url,
			targetFile,
			10,
			(current, total) => {
				if (cancelDownload) {
					return true;
				}
				if (total > 1024 * 1024) {
					print("file larger than 1MB, canceled");
					return true;
				}
				progress = current / total;
				return false;
			}
		);
		if (success) {
			print(`Downloaded: ${url}`);
		} else {
			print(`Download failed: ${url}`);
		}
		if (Content.remove(targetFile)) {
			print(`${targetFile} is deleted`);
		}
	});
}

download();

const downloadFlags = [
	WindowFlag.NoResize,
	WindowFlag.NoSavedSettings,
	WindowFlag.NoTitleBar,
	WindowFlag.NoMove,
	WindowFlag.AlwaysAutoResize,
];
const buffer = Buffer(256);
const node = Node();
node.onCleanup(() => {
	cancelDownload = true;
	if (Content.remove(targetFile)) {
		print(`${targetFile} is deleted`);
	}
});
node.schedule(loop(() => {
	const {width, height} = App.visualSize;
	ImGui.SetNextWindowPos(Vec2(width / 2 - 180, height / 2 - 100));
	ImGui.SetNextWindowSize(Vec2(300, 100), SetCond.FirstUseEver);
	ImGui.Begin("Download", downloadFlags, () => {
		ImGui.SameLine();
		ImGui.TextWrapped(url);
		ImGui.ProgressBar(progress, Vec2(-1, 30));
		ImGui.Separator();
		ImGui.Text("URL to download");
		ImGui.InputText("URL", buffer);
		if (ImGui.Button("Download")) {
			url = buffer.text;
			download();
		}
	});
	return false;
}));