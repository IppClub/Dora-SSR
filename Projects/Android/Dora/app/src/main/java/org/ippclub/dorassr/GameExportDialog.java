/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

package org.ippclub.dorassr;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.ActivityNotFoundException;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.Uri;
import android.text.InputType;
import android.util.AtomicFile;
import android.util.Log;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.ScrollView;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.security.KeyStore;
import java.util.Arrays;
import java.util.Locale;
import java.util.concurrent.Executor;

/** Owns the per-project release identity and its Android export UI. */
final class GameExportDialog {
	static final int REQUEST_SIGNING_KEY = 2004;
	private final MainActivity activity;
	private final Executor worker;
	private final SharedPreferences settings;
	private Request active;

	GameExportDialog(MainActivity activity, Executor worker) {
		this.activity = activity;
		this.worker = worker;
		settings = activity.getSharedPreferences("game-export", Activity.MODE_PRIVATE);
	}

	void open(String path, String id, String title) {
		File stage;
		try {
			stage = new File(path).getCanonicalFile();
			File root = new File(activity.getFilesDir(), ".native-export").getCanonicalFile();
			if (!root.equals(stage.getParentFile()) || !stage.getName().matches("android-[0-9-]+")
					|| !stage.isDirectory() || !id.matches("[0-9a-f]{32}")) {
				throw new IOException("Invalid export staging directory");
			}
		} catch (IOException error) {
			activity.showToast(text("无法读取导出项目", "Could not read the game snapshot"));
			return;
		}
		String[] splits = activity.getApplicationInfo().splitSourceDirs;
		if (active != null || (splits != null && splits.length > 0)) {
			removeStage(stage);
			activity.showToast(active != null ? text("正在处理另一项导出", "An export is already in progress")
					: text("请使用完整安装包版本的 Dora 导出", "Install the complete Dora APK to export games"));
			return;
		}
		active = new Request(stage, id, title);
		showOptions(active);
	}

	void onSigningKeyPicked(Uri uri) {
		if (active == null) return;
		if (uri != null) active.importedKey = uri;
		showOptions(active);
	}

	private void showOptions(Request request) {
		File keyFile = keyFile(request);
		boolean existingKey = keyFile.isFile();
		boolean existingRelease = settings.contains(request.id + ".package");
		int previousVersion = settings.getInt(request.id + ".versionCode", 0);
		LinearLayout form = new LinearLayout(activity);
		form.setOrientation(LinearLayout.VERTICAL);
		int padding = Math.round(24 * activity.getResources().getDisplayMetrics().density);
		form.setPadding(padding, 0, padding, 0);
		ScrollView scroll = new ScrollView(activity);
		scroll.addView(form);
		EditText packageName = field(form, text("包名", "Package name"),
				request.packageName, InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_URI);
		packageName.setEnabled(!existingRelease);
		EditText version = field(form, text("显示版本", "Display version"), request.version, InputType.TYPE_CLASS_TEXT);
		EditText versionCode = field(form, text("版本号", "Version code"), request.versionCode, InputType.TYPE_CLASS_NUMBER);
		EditText password = field(form, existingRelease || existingKey || request.importedKey != null
				? text("签名密钥密码", "Signing key password")
				: text("为新签名密钥设置密码", "Set a password for the new signing key"), "",
				InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_PASSWORD);
		password.setSaveEnabled(false);
		boolean selectKey = !existingKey;
		AlertDialog dialog = new AlertDialog.Builder(activity)
				.setTitle(text("导出 APK", "Export APK"))
				.setView(scroll)
				.setNegativeButton(text("取消", "Cancel"), (ignored, which) -> finish(request))
				.setNeutralButton(selectKey ? text("导入密钥", "Import key") : text("备份密钥", "Back up key"), null)
				.setPositiveButton(text("导出", "Export"), null)
				.create();
		dialog.setOnCancelListener(ignored -> finish(request));
		dialog.setOnShowListener(ignored -> {
			dialog.getButton(AlertDialog.BUTTON_POSITIVE).setOnClickListener(button -> {
				request.packageName = packageName.getText().toString().trim();
				request.version = version.getText().toString().trim();
				request.versionCode = versionCode.getText().toString();
				int code;
				try {
					code = Integer.parseInt(request.versionCode);
				} catch (NumberFormatException error) {
					code = 0;
				}
				if (code <= previousVersion || code < 1) {
					versionCode.setError(text("版本号必须大于上次导出的版本", "Use a higher version code than the last export"));
					return;
				}
				if (!GameApk.validPackageName(request.packageName, activity.getPackageName())) {
					packageName.setError(text("请输入独立游戏包名", "Enter a distinct game package name"));
					return;
				}
				if (request.version.isEmpty()) {
					version.setError(text("请输入显示版本", "Enter a display version"));
					return;
				}
				if (existingRelease && !existingKey && request.importedKey == null) {
					password.setError(text("请导入该游戏原来的签名密钥", "Import the original signing key for this game"));
					return;
				}
				int minLength = existingKey || request.importedKey != null ? 1 : 8;
				if (password.length() < minLength) {
					password.setError(minLength == 1 ? text("请输入签名密码", "Enter the signing password")
							: text("请至少输入 8 个字符", "Use at least eight characters"));
					return;
				}
				char[] secret = new char[password.length()];
				password.getText().getChars(0, secret.length, secret, 0);
				password.setText("");
				dialog.dismiss();
				export(request, code, secret);
			});
			dialog.getButton(AlertDialog.BUTTON_NEUTRAL).setOnClickListener(button -> {
				if (!selectKey) {
					activity.saveGameFile(keyFile.getAbsolutePath(), request.packageName + ".p12");
					return;
				}
				request.packageName = packageName.getText().toString().trim();
				request.version = version.getText().toString().trim();
				request.versionCode = versionCode.getText().toString();
				Intent pick = new Intent(Intent.ACTION_OPEN_DOCUMENT);
				pick.addCategory(Intent.CATEGORY_OPENABLE);
				pick.setType("*/*");
				try {
					activity.startActivityForResult(pick, REQUEST_SIGNING_KEY);
					dialog.dismiss();
				} catch (ActivityNotFoundException error) {
					activity.showToast(text("无法打开密钥选择器", "Could not open the key picker"));
				}
			});
		});
		dialog.show();
	}

	private void export(Request request, int versionCode, char[] password) {
		activity.showToast(text("正在生成并签名 APK…", "Building and signing the APK…"));
		worker.execute(() -> {
			try {
				File key = keyFile(request);
				File directory = key.getParentFile();
				if (!directory.isDirectory() && !directory.mkdirs()) throw new IOException("Could not create key storage");
				AtomicFile persistentKey = new AtomicFile(key);
				KeyStore store;
				if (key.isFile()) {
					try (InputStream input = persistentKey.openRead()) {
						store = GameApk.loadKeyStore(input, password);
					}
				} else if (request.importedKey != null) {
					try (InputStream input = activity.getContentResolver().openInputStream(request.importedKey)) {
						if (input == null) throw new IOException("Could not read the signing key");
						store = GameApk.loadKeyStore(input, password);
					}
				} else {
					store = GameApk.createKeyStore(password);
				}
				String fingerprint = GameApk.fingerprint(store, password);
				String current = settings.getString(request.id + ".certificate", fingerprint);
				if (!fingerprint.equals(current)) {
					throw new IOException(text("证书与该游戏原有签名不匹配", "The certificate differs from this game's existing signature"));
				}
				File unsigned = new File(request.stage, "unsigned.apk");
				File signed = new File(request.stage, "signed.apk");
				GameApk.export(new File(activity.getApplicationInfo().sourceDir), activity.getResources(), new File(request.stage, "assets"),
						unsigned, signed, activity.getPackageName(), request.packageName, request.title,
						versionCode, request.version, store, password);
				if (!key.isFile()) {
					FileOutputStream stream = persistentKey.startWrite();
					try {
						store.store(stream, password);
						persistentKey.finishWrite(stream);
					} catch (Exception error) {
						persistentKey.failWrite(stream);
						throw error;
					}
				}
				if (!settings.edit().putString(request.id + ".package", request.packageName)
						.putString(request.id + ".certificate", fingerprint)
						.putString(request.id + ".version", request.version)
						.putInt(request.id + ".versionCode", versionCode).commit()) {
					throw new IOException("Could not record the game's release settings");
				}
				File outputs = new File(activity.getCacheDir(), "game-export-apks");
				if (!outputs.isDirectory() && !outputs.mkdirs()) throw new IOException("Could not create APK output directory");
				File output = new File(outputs, request.packageName + "-" + versionCode + ".apk");
				Files.move(signed.toPath(), output.toPath(), StandardCopyOption.REPLACE_EXISTING);
				File ready = output;
				activity.runOnUiThread(() -> {
					finish(request);
					new AlertDialog.Builder(activity)
							.setTitle(text("APK 已生成", "APK ready"))
							.setMessage(request.packageName + "\n" + request.version + " (" + versionCode + ")")
							.setPositiveButton(text("保存 APK", "Save APK"), (d, w) -> activity.saveGameFile(ready.getAbsolutePath()))
							.setNeutralButton(text("分享 APK", "Share APK"), (d, w) -> activity.shareGameFile(ready.getAbsolutePath()))
							.setNegativeButton(text("关闭", "Close"), null)
							.show();
				});
			} catch (Exception error) {
				Log.w("DoraGameExport", "APK export failed", error);
				activity.runOnUiThread(() -> {
					activity.showToast(text("APK 导出失败：", "APK export failed: ") + error.getLocalizedMessage());
					if (active == request && !activity.isFinishing()) showOptions(request);
				});
			} finally {
				Arrays.fill(password, '\0');
			}
		});
	}

	private EditText field(LinearLayout parent, String label, String value, int type) {
		android.widget.TextView caption = new android.widget.TextView(activity);
		caption.setText(label);
		parent.addView(caption);
		EditText input = new EditText(activity);
		input.setSingleLine(true);
		input.setInputType(type);
		input.setText(value);
		parent.addView(input);
		return input;
	}

	private File keyFile(Request request) {
		return new File(new File(activity.getNoBackupFilesDir(), "game-export-keys"), request.id + ".p12");
	}

	private void finish(Request request) {
		if (active == request) active = null;
		removeStage(request.stage);
	}

	private void removeStage(File stage) {
		worker.execute(() -> deleteTree(stage));
	}

	private static void deleteTree(File file) {
		File[] children = Files.isSymbolicLink(file.toPath()) ? null : file.listFiles();
		if (children != null) for (File child : children) deleteTree(child);
		if (!file.delete() && file.exists()) Log.w("DoraGameExport", "Could not remove temporary export data");
	}

	private String text(String zh, String en) {
		return Locale.getDefault().getLanguage().equals("zh") ? zh : en;
	}

	private final class Request {
		final File stage;
		final String id;
		final String title;
		String packageName;
		String version;
		String versionCode;
		Uri importedKey;

		Request(File stage, String id, String title) {
			this.stage = stage;
			this.id = id;
			this.title = title;
			packageName = settings.getString(id + ".package", "org.ippclub.dora.game.g" + id);
			version = settings.getString(id + ".version", "1.0.0");
			versionCode = Long.toString(1L + settings.getInt(id + ".versionCode", 0));
		}
	}
}
