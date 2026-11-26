/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

package org.ippclub.dorassr;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.ActivityNotFoundException;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageInfo;
import android.content.res.Resources;
import android.net.Uri;
import android.text.InputType;
import android.util.AtomicFile;
import android.util.Log;
import android.view.Gravity;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.Space;
import android.widget.TextView;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.security.KeyStore;
import java.util.Arrays;
import java.util.LinkedHashSet;
import java.util.Locale;
import java.util.Set;
import java.util.UUID;
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

	void open(String path, String id, String title, boolean needsGodot) {
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
		if (active != null) {
			removeStage(stage);
			activity.showToast(text("正在处理另一项导出", "An export is already in progress"));
			return;
		}
		File downloaded = new File(stage, "template.apk");
		File template = downloaded.isFile() ? downloaded : new File(activity.getApplicationInfo().sourceDir);
		Set<String> availableAbis;
		try {
			availableAbis = GameApk.availableAbis(template);
		} catch (IOException error) {
			removeStage(stage);
			activity.showToast(text("无法读取 Dora APK 的架构", "Could not read the ABIs from this Dora APK."));
			return;
		}
		if (availableAbis.isEmpty()) {
			removeStage(stage);
			activity.showToast(text("请使用完整安装包版本的 Dora 导出", "Install the complete Dora APK to export games"));
			return;
		}
		active = new Request(stage, id, title, template, availableAbis, needsGodot);
		if (settings.getBoolean(id + ".resetSigning", false)) {
			clearSigning(active);
		} else {
			showOptions(active);
		}
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
		TextView packageName;
		if (existingRelease) {
			caption(form, text("包名（长按复制）", "Package name (hold to copy)"));
			packageName = new TextView(activity);
			packageName.setTextAppearance(android.R.style.TextAppearance_Material_Subhead);
			packageName.setText(request.packageName);
			packageName.setPadding(0, padding / 3, 0, padding / 3);
			packageName.setOnLongClickListener(view -> {
				ClipboardManager clipboard = activity.getSystemService(ClipboardManager.class);
				if (clipboard == null) return false;
				clipboard.setPrimaryClip(ClipData.newPlainText("Package name", request.packageName));
				return true;
			});
			form.addView(packageName);
		} else {
			packageName = field(form, text("包名", "Package name"),
					request.packageName, InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_URI);
		}
		EditText version = field(form, text("显示版本", "Display version"), request.version, InputType.TYPE_CLASS_TEXT);
		EditText versionCode = field(form, text("版本号", "Version code"), request.versionCode, InputType.TYPE_CLASS_NUMBER);
		EditText password = field(form, existingRelease || existingKey || request.importedKey != null
				? text("签名密钥密码", "Signing key password")
				: text("为新签名密钥设置密码", "Set a password for the new signing key"), "",
				InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_PASSWORD);
		password.setSaveEnabled(false);
		caption(form, text("处理器架构（ABI）", "CPU architectures (ABIs)"));
		Button abiSelection = new Button(activity, null, android.R.attr.borderlessButtonStyle);
		abiSelection.setGravity(Gravity.START | Gravity.CENTER_VERTICAL);
		abiSelection.setAllCaps(false);
		abiSelection.setText(String.join(", ", request.selectedAbis));
		abiSelection.setOnClickListener(view -> chooseAbis(request, abiSelection));
		form.addView(abiSelection);
		LinearLayout content = new LinearLayout(activity);
		content.setOrientation(LinearLayout.VERTICAL);
		content.addView(scroll, new LinearLayout.LayoutParams(
				LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT, 1));
		LinearLayout keyActions = new LinearLayout(activity);
		Button keyAction = footerButton(keyActions, existingKey ? text("备份密钥", "Back up key") : text("导入密钥", "Import key"));
		LinearLayout exportActions = new LinearLayout(activity);
		Button cancel = footerButton(exportActions, text("取消", "Cancel"));
		Button export = footerButton(exportActions, text("导出", "Export"));
		addFooter(content, keyActions, exportActions, padding / 3);

		AlertDialog dialog = new AlertDialog.Builder(activity)
				.setTitle(text("导出 APK", "Export APK"))
				.setView(content)
				.create();
		keyAction.setOnClickListener(view -> {
			if (existingKey) {
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
		dialog.setOnCancelListener(ignored -> finish(request));
		cancel.setOnClickListener(view -> dialog.cancel());
		if (existingKey || existingRelease) {
			Button clearKey = footerButton(keyActions, text("清除密钥", "Clear key"));
			clearKey.setOnClickListener(view -> new AlertDialog.Builder(activity)
					.setTitle(text("清除此项目的签名密钥？", "Clear this project's signing key?"))
					.setMessage(text(
							"这将删除此项目在本机保存的签名密钥。使用新密钥导出的 APK 无法覆盖已安装的旧版。若还要发布旧版的更新，请先备份原密钥。",
							"This deletes the signing key saved on this device for this project. APKs signed with a new key cannot update existing installations. Back up the original key first if you still need to publish updates."))
					.setNegativeButton(text("取消", "Cancel"), null)
					.setPositiveButton(text("清除密钥", "Clear key"), (ignored, which) -> {
						password.setText("");
						dialog.dismiss();
						clearSigning(request);
					})
					.show());
		}
		export.setOnClickListener(button -> {
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
		dialog.show();
	}

	private void chooseAbis(Request request, Button summary) {
		String[] choices = request.availableAbis.toArray(new String[0]);
		Set<String> selection = new LinkedHashSet<>(request.selectedAbis);
		boolean[] checked = new boolean[choices.length];
		for (int i = 0; i < choices.length; i++) checked[i] = selection.contains(choices[i]);
		new AlertDialog.Builder(activity)
				.setTitle(text("选择至少一种架构", "Select at least one ABI"))
				.setMultiChoiceItems(choices, checked, (dialog, index, enabled) -> {
					if (enabled) selection.add(choices[index]);
					else selection.remove(choices[index]);
					((AlertDialog) dialog).getButton(AlertDialog.BUTTON_POSITIVE).setEnabled(!selection.isEmpty());
				})
				.setNegativeButton(text("取消", "Cancel"), null)
				.setPositiveButton(text("确定", "OK"), (dialog, which) -> {
					request.selectedAbis.clear();
					for (String abi : choices) {
						if (selection.contains(abi)) request.selectedAbis.add(abi);
					}
					summary.setText(String.join(", ", request.selectedAbis));
				})
				.show();
	}

	private Button footerButton(LinearLayout group, String label) {
		Button button = new Button(activity, null, android.R.attr.buttonBarButtonStyle);
		button.setText(label);
		int horizontalPadding = Math.round(8 * button.getResources().getDisplayMetrics().density);
		button.setPaddingRelative(horizontalPadding, button.getPaddingTop(), horizontalPadding, button.getPaddingBottom());
		group.addView(button, new LinearLayout.LayoutParams(
				LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT));
		return button;
	}

	private void addFooter(LinearLayout content, LinearLayout keyActions, LinearLayout exportActions, int padding) {
		Space spacer = new Space(activity);
		LinearLayout footer = new LinearLayout(activity) {
			@Override
			protected void onMeasure(int widthSpec, int heightSpec) {
				int unconstrained = MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED);
				keyActions.measure(unconstrained, unconstrained);
				exportActions.measure(unconstrained, unconstrained);
				int requiredWidth = keyActions.getMeasuredWidth() + exportActions.getMeasuredWidth()
						+ getPaddingStart() + getPaddingEnd();
				// Keep each pair together if the dialog is too narrow for a single row.
				boolean stacked = MeasureSpec.getMode(widthSpec) != MeasureSpec.UNSPECIFIED
						&& requiredWidth > MeasureSpec.getSize(widthSpec);
				setOrientation(stacked ? VERTICAL : HORIZONTAL);
				spacer.setVisibility(stacked ? GONE : INVISIBLE);
				super.onMeasure(widthSpec, heightSpec);
			}
		};
		footer.setPaddingRelative(padding, padding, padding, padding);
		footer.setBaselineAligned(false);
		footer.addView(keyActions, new LinearLayout.LayoutParams(
				LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT));
		footer.addView(spacer, new LinearLayout.LayoutParams(0, 0, 1));
		LinearLayout.LayoutParams exportLayout = new LinearLayout.LayoutParams(
				LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT);
		exportLayout.gravity = Gravity.END | Gravity.BOTTOM;
		footer.addView(exportActions, exportLayout);
		content.addView(footer, new LinearLayout.LayoutParams(
				LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT));
	}

	private void clearSigning(Request request) {
		worker.execute(() -> {
			try {
				String prefix = request.id + ".";
				// Record the reset before deleting the key so reopening can finish it after an interruption.
				if (!settings.edit().putBoolean(prefix + "resetSigning", true).commit()) {
					throw new IOException("Could not start signing key reset");
				}
				File key = keyFile(request);
				new AtomicFile(key).delete();
				if (key.exists() || new File(key.getPath() + ".new").exists() || new File(key.getPath() + ".bak").exists()) {
					throw new IOException("Could not delete the signing key");
				}
				String suggestion = defaultPackage(UUID.randomUUID().toString().replace("-", ""));
				if (!settings.edit()
						.remove(prefix + "certificate")
						.remove(prefix + "package")
						.remove(prefix + "versionCode")
						.putString(prefix + "suggestedPackage", suggestion)
						.remove(prefix + "resetSigning")
						.commit()) {
					throw new IOException("Could not clear the game's signing settings");
				}
				activity.runOnUiThread(() -> {
					if (active == request && !activity.isFinishing()) {
						active = new Request(request.stage, request.id, request.title, request.template, request.availableAbis, request.needsGodot);
						active.selectedAbis.retainAll(request.selectedAbis);
						showOptions(active);
					}
				});
			} catch (Exception error) {
				Log.w("DoraGameExport", "Signing key reset failed", error);
				activity.runOnUiThread(() -> {
					activity.showToast(text("清除密钥失败，请重新打开导出窗口重试", "Could not clear the key. Reopen export to retry."));
					finish(request);
				});
			}
		});
	}

	private String defaultPackage(String id) {
		return "org.ippclub.dora.game.g" + id;
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
				Resources resources = activity.getResources();
				String templatePackage = activity.getPackageName();
				if (!request.template.getAbsolutePath().equals(activity.getApplicationInfo().sourceDir)) {
					PackageInfo info = activity.getPackageManager().getPackageArchiveInfo(request.template.getAbsolutePath(), 0);
					if (info == null || info.applicationInfo == null) throw new IOException("Invalid Dora Android template");
					info.applicationInfo.sourceDir = request.template.getAbsolutePath();
					info.applicationInfo.publicSourceDir = request.template.getAbsolutePath();
					resources = activity.getPackageManager().getResourcesForApplication(info.applicationInfo);
					templatePackage = info.packageName;
				}
				try (InputStream policy = activity.getAssets().open("Script/Dev/ExportPolicy.json")) {
					GameApk.export(request.template, resources, new File(request.stage, "assets"),
							unsigned, signed, templatePackage, request.packageName, request.title,
							versionCode, request.version, request.selectedAbis, store, password, request.needsGodot, policy);
				}
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
		caption(parent, label);
		EditText input = new EditText(activity);
		input.setSingleLine(true);
		input.setInputType(type);
		input.setText(value);
		parent.addView(input);
		return input;
	}

	private void caption(LinearLayout parent, String label) {
		TextView caption = new TextView(activity);
		caption.setText(label);
		parent.addView(caption);
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
		final File template;
		final boolean needsGodot;
		final Set<String> availableAbis;
		final Set<String> selectedAbis;
		String packageName;
		String version;
		String versionCode;
		Uri importedKey;

		Request(File stage, String id, String title, File template, Set<String> availableAbis, boolean needsGodot) {
			this.stage = stage;
			this.id = id;
			this.title = title;
			this.template = template;
			this.needsGodot = needsGodot;
			this.availableAbis = availableAbis;
			selectedAbis = new LinkedHashSet<>(availableAbis);
			packageName = settings.getString(id + ".package",
					settings.getString(id + ".suggestedPackage", defaultPackage(id)));
			version = settings.getString(id + ".version", "1.0.0");
			versionCode = Long.toString(1L + settings.getInt(id + ".versionCode", 0));
		}
	}
}
