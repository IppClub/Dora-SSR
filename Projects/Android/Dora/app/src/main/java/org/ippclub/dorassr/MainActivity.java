package org.ippclub.dorassr;

import org.libsdl.app.SDLActivity;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.provider.Settings;
import android.view.View;

import androidx.core.content.FileProvider;

import java.io.File;

import wa.JavaCallbackInterface;
import wa.Wa;
public class MainActivity extends SDLActivity {
	private static native void nativeSetPath(String path);
	private static native void nativeSetScreenDensity(float density);
	private static native String nativeGetInstallFile();
	private static native void nativeWaEmit(String event, String message);
	public static boolean waBuild(String path) {
		if (waCallback == null) {
			waCallback = new WaDone();
			Wa.setCallback(waCallback);
		}
		return Wa.waBuild(path);
	}
	public static boolean waFormat(String path) {
		if (waCallback == null) {
			waCallback = new WaDone();
			Wa.setCallback(waCallback);
		}
		return Wa.waFormat(path);
	}
	public static boolean waPullOrClone(String url, String path, long depth) {
		if (waCallback == null) {
			waCallback = new WaDone();
			Wa.setCallback(waCallback);
		}
		return Wa.waPullOrClone(url, path, depth);
	}

	private static WaDone waCallback;

	public static class WaDone implements JavaCallbackInterface {
		@Override
		public void build(String s) {
			MainActivity.nativeWaEmit("Build", s);
		}
		@Override
		public void format(String s) {
			MainActivity.nativeWaEmit("Format", s);
		}

		@Override
		public void gitProgress(String s) { MainActivity.nativeWaEmit("GitProgress", s); }

		@Override
		public void gitPullOrClone(String s) { MainActivity.nativeWaEmit("GitPullOrClone", s); }
	}

	@Override
	protected void onCreate(final Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		MainActivity.nativeSetPath(this.getApplicationInfo().sourceDir);
		MainActivity.nativeSetScreenDensity(this.getResources().getDisplayMetrics().density);
		hideSystemUI();
	}

	@Override
	public void onWindowFocusChanged(boolean hasFocus) {
		super.onWindowFocusChanged(hasFocus);
		if (hasFocus) {
			hideSystemUI();
		}
	}

	@Override
	protected void onResume() {
		super.onResume();
		hideSystemUI();
	}

	private void hideSystemUI() {
		// Enables regular immersive mode.
		// For "lean back" mode, remove SYSTEM_UI_FLAG_IMMERSIVE.
		// Or for "sticky immersive," replace it with SYSTEM_UI_FLAG_IMMERSIVE_STICKY
		View decorView = getWindow().getDecorView();
		decorView.setSystemUiVisibility(
			View.SYSTEM_UI_FLAG_IMMERSIVE
				// Set the content to appear under the system bars so that the
				// content doesn't resize when the system bars hide and show.
				| View.SYSTEM_UI_FLAG_LAYOUT_STABLE
				| View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
				| View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
				// Hide the nav bar and status bar
				| View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
				| View.SYSTEM_UI_FLAG_FULLSCREEN);
	}

	static final int COMMAND_INSTALL = COMMAND_USER;

	@Override
	protected boolean onUnhandledMessage(int command, Object param) {
		if (command == COMMAND_INSTALL) {
			String apkFile = MainActivity.nativeGetInstallFile();
			if (apkFile.isEmpty()) {
				return true;
			}
			File file = new File(apkFile);
			if (!file.exists()) {
				return true;
			}
			// Check for installation from unknown sources
			if (!getPackageManager().canRequestPackageInstalls()) {
				// If not, request permission from the user
				Intent intent = new Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
						Uri.parse("package:" + getPackageName()));
				startActivityForResult(intent, 1234);
				return true;
			}
			Uri apkUri = FileProvider.getUriForFile(this, getPackageName() + ".FileProvider", file);
			Intent intent = new Intent(Intent.ACTION_VIEW);
			intent.setDataAndType(apkUri, "application/vnd.android.package-archive");
			intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
			intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
			startActivity(intent);
			return true;
		}
		return false;
	}
}
