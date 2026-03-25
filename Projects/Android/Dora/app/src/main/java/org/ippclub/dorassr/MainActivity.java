package org.ippclub.dorassr;

import org.libsdl.app.SDLActivity;

import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.graphics.drawable.GradientDrawable;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.provider.Settings;
import android.os.Build;
import android.util.Log;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.webkit.ConsoleMessage;
import android.webkit.WebChromeClient;
import android.webkit.WebResourceError;
import android.webkit.WebResourceRequest;
import android.webkit.WebResourceResponse;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.core.content.FileProvider;

import java.io.File;

import wa.Wa;

public class MainActivity extends SDLActivity {
	private static final String TAG = "DoraWebIDE";
	private static final String WEB_IDE_URL = "http://127.0.0.1:8866";
	private static final long SIDE_PANEL_AUTO_HIDE_MS = 3500L;
	private static native void nativeSetPath(String path);
	private static native void nativeSetScreenDensity(float density);
	private static native String nativeGetInstallFile();
	private Button sideHandleButton;
	private LinearLayout sideMenu;
	private Button switchModeButton;
	private Button stopIdeButton;
	private Button reloadButton;
	private FrameLayout ideContainer;
	private WebView ideWebView;
	private TextView ideStatusView;
	private boolean ideLoaded = false;
	private boolean ideVisible = false;
	private boolean sideMenuExpanded = false;
	private final Handler uiHandler = new Handler(Looper.getMainLooper());
	private final Runnable autoHideSideMenu = this::collapseSideMenu;
	public static String waBuild(String path) { return Wa.waBuild(path); }
	public static String waFormat(String path) { return Wa.waFormat(path); }
	@Override
	protected void onCreate(final Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		configureEdgeToEdgeWindow();
		MainActivity.nativeSetPath(this.getApplicationInfo().sourceDir);
		MainActivity.nativeSetScreenDensity(this.getResources().getDisplayMetrics().density);
		installIdeSwitcher();
		hideSystemUI();
	}

	private void configureEdgeToEdgeWindow() {
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
			getWindow().setDecorFitsSystemWindows(false);
		} else {
			getWindow().addFlags(WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS);
		}
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
		if (ideWebView != null) {
			ideWebView.onResume();
		}
		hideSystemUI();
	}

	@Override
	protected void onPause() {
		if (ideWebView != null) {
			ideWebView.onPause();
		}
		super.onPause();
	}

	@Override
	protected void onDestroy() {
		if (ideWebView != null) {
			ideWebView.destroy();
			ideWebView = null;
		}
		uiHandler.removeCallbacks(autoHideSideMenu);
		super.onDestroy();
	}

	private void hideSystemUI() {
		// Enables regular immersive mode.
		// For "lean back" mode, remove SYSTEM_UI_FLAG_IMMERSIVE.
		// Or for "sticky immersive," replace it with SYSTEM_UI_FLAG_IMMERSIVE_STICKY
		View decorView = getWindow().getDecorView();
		decorView.setSystemUiVisibility(
			View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
				// Set the content to appear under the system bars so that the
				// content doesn't resize when the system bars hide and show.
				| View.SYSTEM_UI_FLAG_LAYOUT_STABLE
				| View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
				| View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
				// Hide the nav bar and status bar
				| View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
				| View.SYSTEM_UI_FLAG_FULLSCREEN);
	}

	private void installIdeSwitcher() {
		View content = SDLActivity.getContentView();
		if (!(content instanceof RelativeLayout)) {
			return;
		}
		RelativeLayout root = (RelativeLayout) content;

		ideContainer = new FrameLayout(this);
		ideContainer.setVisibility(View.GONE);
		ideContainer.setBackgroundColor(0x0);
		RelativeLayout.LayoutParams containerParams = new RelativeLayout.LayoutParams(
			RelativeLayout.LayoutParams.MATCH_PARENT,
			RelativeLayout.LayoutParams.MATCH_PARENT);
		root.addView(ideContainer, containerParams);

		ideStatusView = new TextView(this);
		ideStatusView.setTextColor(Color.WHITE);
		ideStatusView.setTextSize(TypedValue.COMPLEX_UNIT_SP, 13);
		ideStatusView.setPadding(dp(12), dp(8), dp(12), dp(8));
		ideStatusView.setBackgroundColor(0x66000000);
		ideStatusView.setText("Connecting to Web IDE...");
		FrameLayout.LayoutParams statusParams = new FrameLayout.LayoutParams(
			FrameLayout.LayoutParams.WRAP_CONTENT,
			FrameLayout.LayoutParams.WRAP_CONTENT);
		statusParams.topMargin = dp(12);
		statusParams.gravity = android.view.Gravity.TOP | android.view.Gravity.CENTER_HORIZONTAL;
		ideContainer.addView(ideStatusView, statusParams);

		ideWebView = new WebView(this);
		ideWebView.setBackgroundColor(0x0);
		configureIdeWebView();
		ideContainer.addView(ideWebView, new FrameLayout.LayoutParams(
			FrameLayout.LayoutParams.MATCH_PARENT,
			FrameLayout.LayoutParams.MATCH_PARENT));

		sideMenu = new LinearLayout(this);
		sideMenu.setOrientation(LinearLayout.VERTICAL);
		sideMenu.setGravity(Gravity.CENTER_VERTICAL);
		sideMenu.setVisibility(View.INVISIBLE);
		sideMenu.setPadding(dp(8), dp(8), dp(8), dp(8));
		sideMenu.setAlpha(0.0f);
		GradientDrawable menuBg = new GradientDrawable();
		menuBg.setColor(0x882B2B2B);
		menuBg.setCornerRadii(new float[] {
			dp(18), dp(18), 0, 0, 0, 0, dp(18), dp(18)
		});
		sideMenu.setBackground(menuBg);
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
			sideMenu.setElevation(dp(18));
		}
		RelativeLayout.LayoutParams menuParams = new RelativeLayout.LayoutParams(
			dp(94),
			RelativeLayout.LayoutParams.WRAP_CONTENT);
		menuParams.addRule(RelativeLayout.CENTER_VERTICAL);
		menuParams.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);

		switchModeButton = makeOverlayButton("IDE");
		switchModeButton.setOnClickListener(v -> {
			if (ideVisible) {
				showEngine();
			} else {
				showIde();
			}
			collapseSideMenu();
		});
		sideMenu.addView(switchModeButton);

		stopIdeButton = makeOverlayButton("Stop");
		stopIdeButton.setOnClickListener(v -> {
			stopIdeSession();
			collapseSideMenu();
		});
		sideMenu.addView(stopIdeButton);

		reloadButton = makeOverlayButton("Reload");
		reloadButton.setOnClickListener(v -> {
			if (ideWebView != null) {
				ideStatusView.setVisibility(View.VISIBLE);
				ideStatusView.setText("Reloading Web IDE...");
				ideWebView.reload();
			}
			collapseSideMenu();
		});
		sideMenu.addView(reloadButton);

		sideHandleButton = new Button(this);
		sideHandleButton.setId(View.generateViewId());
		sideHandleButton.setAllCaps(false);
		sideHandleButton.setText("I\nD\nE");
		sideHandleButton.setTextColor(0xE6FFFFFF);
		sideHandleButton.setTextSize(TypedValue.COMPLEX_UNIT_SP, 10);
		sideHandleButton.setPadding(dp(1), dp(10), dp(1), dp(10));
		sideHandleButton.setAlpha(0.24f);
		sideHandleButton.setGravity(Gravity.CENTER);
		sideHandleButton.setMinWidth(0);
		sideHandleButton.setMinimumWidth(0);
		sideHandleButton.setMinHeight(0);
		sideHandleButton.setMinimumHeight(0);
		sideHandleButton.setStateListAnimator(null);
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
			sideHandleButton.setLetterSpacing(0.08f);
		}
		GradientDrawable buttonBg = new GradientDrawable();
		buttonBg.setColor(0xCC353535);
		buttonBg.setCornerRadii(new float[] {
			dp(16), dp(16), 0, 0, 0, 0, dp(16), dp(16)
		});
		sideHandleButton.setBackground(buttonBg);
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
			sideHandleButton.setElevation(dp(12));
		}
		sideHandleButton.setOnClickListener(v -> {
			toggleSideMenu();
		});
		RelativeLayout.LayoutParams buttonParams = new RelativeLayout.LayoutParams(
			dp(20),
			dp(80));
		buttonParams.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
		buttonParams.addRule(RelativeLayout.CENTER_VERTICAL);
		buttonParams.rightMargin = 0;
		root.addView(sideHandleButton, buttonParams);
		menuParams.addRule(RelativeLayout.LEFT_OF, sideHandleButton.getId());
		menuParams.rightMargin = dp(2);
		root.addView(sideMenu, menuParams);
		updateSideControls();
	}

	private void configureIdeWebView() {
		WebSettings settings = ideWebView.getSettings();
		settings.setJavaScriptEnabled(true);
		settings.setDomStorageEnabled(true);
		settings.setAllowFileAccess(true);
		settings.setAllowContentAccess(true);
		settings.setMediaPlaybackRequiresUserGesture(false);
		WebView.setWebContentsDebuggingEnabled(true);
		ideWebView.setWebChromeClient(new WebChromeClient() {
			@Override
			public boolean onConsoleMessage(ConsoleMessage consoleMessage) {
				Log.d(TAG, "console[" + consoleMessage.messageLevel() + "] "
					+ consoleMessage.sourceId() + ":" + consoleMessage.lineNumber() + " "
					+ consoleMessage.message());
				return super.onConsoleMessage(consoleMessage);
			}
		});
		ideWebView.setWebViewClient(new WebViewClient() {
			@Override
			public void onPageStarted(WebView view, String url, Bitmap favicon) {
				Log.d(TAG, "page started: " + url);
				ideStatusView.setVisibility(View.VISIBLE);
				ideStatusView.setText("Loading Web IDE...");
			}

			@Override
			public void onPageFinished(WebView view, String url) {
				Log.d(TAG, "page finished: " + url);
				ideStatusView.setVisibility(View.GONE);
			}

			@Override
			public void onReceivedError(WebView view, WebResourceRequest request, WebResourceError error) {
				if (request.isForMainFrame()) {
					Log.d(TAG, "resource error: " + error.getDescription());
					ideStatusView.setVisibility(View.VISIBLE);
					ideStatusView.setText("Unable to reach Web IDE service.");
				}
			}

			@Override
			public void onReceivedHttpError(WebView view, WebResourceRequest request, WebResourceResponse errorResponse) {
				if (request.isForMainFrame()) {
					Log.d(TAG, "http error: " + errorResponse.getStatusCode() + " url=" + request.getUrl());
				}
			}
		});
	}

	private Button makeOverlayButton(String text) {
		Button button = new Button(this);
		button.setAllCaps(false);
		button.setText(text);
		button.setTextColor(0xF2FFFFFF);
		button.setTextSize(TypedValue.COMPLEX_UNIT_SP, 12);
		button.setGravity(Gravity.CENTER);
		button.setMinWidth(0);
		button.setMinimumWidth(0);
		button.setMinHeight(0);
		button.setMinimumHeight(0);
		button.setMinimumWidth(0);
		button.setIncludeFontPadding(false);
		button.setStateListAnimator(null);
		button.setPadding(dp(6), dp(10), dp(6), dp(10));
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
			button.setLetterSpacing(0.02f);
		}
		applyOverlayButtonStyle(button, false);
		LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(
			LinearLayout.LayoutParams.MATCH_PARENT,
			LinearLayout.LayoutParams.WRAP_CONTENT);
		params.topMargin = dp(4);
		params.bottomMargin = dp(4);
		button.setLayoutParams(params);
		return button;
	}

	private void applyOverlayButtonStyle(Button button, boolean primary) {
		GradientDrawable bg = new GradientDrawable();
		bg.setColor(primary ? 0xFF3B3B3B : 0xFF363636);
		bg.setCornerRadius(dp(6));
		button.setBackground(bg);
		button.setTextColor(0xF2FFFFFF);
	}

	private void toggleSideMenu() {
		if (sideMenuExpanded) {
			collapseSideMenu();
		} else {
			expandSideMenu();
		}
	}

	private void expandSideMenu() {
		if (sideMenu == null) {
			return;
		}
		sideMenuExpanded = true;
		uiHandler.removeCallbacks(autoHideSideMenu);
		updateSideControls();
		sideHandleButton.bringToFront();
		sideMenu.bringToFront();
		sideMenu.requestLayout();
		sideMenu.invalidate();
		sideMenu.setVisibility(View.VISIBLE);
		sideMenu.setTranslationX(dp(8));
		sideMenu.animate().cancel();
		sideMenu.animate()
			.alpha(1.0f)
			.translationX(0)
			.setDuration(150)
			.start();
		uiHandler.postDelayed(autoHideSideMenu, SIDE_PANEL_AUTO_HIDE_MS);
	}

	private void collapseSideMenu() {
		if (sideMenu == null) {
			return;
		}
		sideMenuExpanded = false;
		uiHandler.removeCallbacks(autoHideSideMenu);
		sideMenu.animate().cancel();
		sideMenu.setAlpha(0.0f);
		sideMenu.setTranslationX(dp(8));
		sideMenu.setVisibility(View.INVISIBLE);
		sideHandleButton.bringToFront();
	}

	private void showIde() {
		if (ideContainer == null) {
			return;
		}
		ideVisible = true;
		ideContainer.setVisibility(View.VISIBLE);
		if (!ideLoaded) {
			ideLoaded = true;
			ideStatusView.setVisibility(View.VISIBLE);
			ideStatusView.setText("Connecting to Web IDE...");
			Log.d(TAG, "load " + WEB_IDE_URL);
			ideWebView.loadUrl(WEB_IDE_URL);
		}
		updateSideControls();
	}

	private void showEngine() {
		ideVisible = false;
		if (ideContainer != null) {
			ideContainer.setVisibility(View.GONE);
		}
		updateSideControls();
	}

	private void stopIdeSession() {
		if (ideWebView != null) {
			ideWebView.stopLoading();
			ideWebView.loadUrl("about:blank");
		}
		ideLoaded = false;
		ideVisible = false;
		if (ideContainer != null) {
			ideContainer.setVisibility(View.GONE);
		}
		if (ideStatusView != null) {
			ideStatusView.setVisibility(View.GONE);
		}
		updateSideControls();
	}

	private void updateSideControls() {
		if (sideHandleButton == null || sideMenu == null) {
			return;
		}
		sideHandleButton.setText(ideVisible ? "M\nE\nN\nU" : "I\nD\nE");
		if (switchModeButton != null) {
			switchModeButton.setText(ideVisible ? "Engine" : "IDE");
			applyOverlayButtonStyle(switchModeButton, false);
		}
		if (stopIdeButton != null) {
			stopIdeButton.setVisibility(!ideVisible && ideLoaded ? View.VISIBLE : View.GONE);
			applyOverlayButtonStyle(stopIdeButton, false);
		}
		if (reloadButton != null) {
			reloadButton.setVisibility(ideVisible ? View.VISIBLE : View.GONE);
			applyOverlayButtonStyle(reloadButton, false);
		}
	}

	private int dp(int value) {
		return Math.round(value * getResources().getDisplayMetrics().density);
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
