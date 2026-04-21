package org.ippclub.dorassr;

import org.libsdl.app.SDLActivity;

import android.app.DownloadManager;
import android.content.ActivityNotFoundException;
import android.content.BroadcastReceiver;
import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.graphics.drawable.GradientDrawable;
import android.media.MediaScannerConnection;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Looper;
import android.provider.MediaStore;
import android.provider.Settings;
import android.os.Build;
import android.util.Base64;
import android.util.Log;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.webkit.ConsoleMessage;
import android.webkit.CookieManager;
import android.webkit.JavascriptInterface;
import android.webkit.WebChromeClient;
import android.webkit.ValueCallback;
import android.webkit.WebResourceError;
import android.webkit.WebResourceRequest;
import android.webkit.WebResourceResponse;
import android.webkit.WebSettings;
import android.webkit.URLUtil;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.core.content.FileProvider;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

import org.json.JSONObject;

import wa.Wa;

public class MainActivity extends SDLActivity {
	private static final String TAG = "DoraWebIDE";
	private static final String WEB_IDE_URL = "http://127.0.0.1:8866";
	private static final long SIDE_PANEL_AUTO_HIDE_MS = 3500L;
	private static final int REQUEST_FILE_CHOOSER = 2001;
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
	private ValueCallback<Uri[]> fileChooserCallback;
	private final Map<String, String> pendingBlobFileNames = new HashMap<>();
	private final Map<Long, String> pendingDownloadNames = new HashMap<>();
	private final BroadcastReceiver downloadCompleteReceiver = new BroadcastReceiver() {
		@Override
		public void onReceive(Context context, Intent intent) {
			if (intent == null || !DownloadManager.ACTION_DOWNLOAD_COMPLETE.equals(intent.getAction())) {
				return;
			}
			long downloadId = intent.getLongExtra(DownloadManager.EXTRA_DOWNLOAD_ID, -1L);
			String fileName = pendingDownloadNames.remove(downloadId);
			if (fileName != null) {
				showToast("Downloaded " + fileName);
			}
		}
	};
	private final Handler uiHandler = new Handler(Looper.getMainLooper());
	private final Runnable autoHideSideMenu = this::collapseSideMenu;
	public static String waBuild(String path) { return Wa.waBuild(path); }
	public static String waFormat(String path) { return Wa.waFormat(path); }
	@Override
	protected void onCreate(final Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		configureEdgeToEdgeWindow();
		IntentFilter downloadFilter = new IntentFilter(DownloadManager.ACTION_DOWNLOAD_COMPLETE);
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
			registerReceiver(downloadCompleteReceiver, downloadFilter, Context.RECEIVER_NOT_EXPORTED);
		} else {
			registerReceiver(downloadCompleteReceiver, downloadFilter);
		}
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
		try {
			unregisterReceiver(downloadCompleteReceiver);
		} catch (IllegalArgumentException ignored) {
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
		sideHandleButton.setTextSize(TypedValue.COMPLEX_UNIT_SP, 8);
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
			dp(60));
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
		settings.setSupportZoom(false);
		settings.setBuiltInZoomControls(false);
		settings.setDisplayZoomControls(false);
		settings.setSupportMultipleWindows(true);
		ideWebView.addJavascriptInterface(new BlobDownloadBridge(), "DoraBlobDownloader");
		WebView.setWebContentsDebuggingEnabled(false);
		ideWebView.setWebChromeClient(new WebChromeClient() {
			@Override
			public boolean onCreateWindow(WebView view, boolean isDialog, boolean isUserGesture,
				android.os.Message resultMsg) {
				WebView.HitTestResult hitTestResult = view.getHitTestResult();
				if (hitTestResult == null) {
					return false;
				}
				String extra = hitTestResult.getExtra();
				if (extra == null) {
					return false;
				}
				return openExternalLink(Uri.parse(extra));
			}

			@Override
			public boolean onShowFileChooser(WebView webView, ValueCallback<Uri[]> filePathCallback,
				FileChooserParams fileChooserParams) {
				if (fileChooserCallback != null) {
					fileChooserCallback.onReceiveValue(null);
				}
				fileChooserCallback = filePathCallback;
				Intent intent = fileChooserParams != null
					? fileChooserParams.createIntent()
					: new Intent(Intent.ACTION_GET_CONTENT);
				intent.addCategory(Intent.CATEGORY_OPENABLE);
				intent.setType("*/*");
				intent.putExtra(Intent.EXTRA_ALLOW_MULTIPLE,
					fileChooserParams != null && fileChooserParams.getMode() == FileChooserParams.MODE_OPEN_MULTIPLE);
				try {
					startActivityForResult(Intent.createChooser(intent, "Select file"), REQUEST_FILE_CHOOSER);
					return true;
				} catch (ActivityNotFoundException e) {
					Log.w(TAG, "No file chooser available", e);
					fileChooserCallback = null;
					return false;
				}
			}

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
			public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {
				Uri uri = request.getUrl();
				if (isInternalIdeUrl(uri)) {
					return false;
				}
				return openExternalLink(uri);
			}

			@Override
			public boolean shouldOverrideUrlLoading(WebView view, String url) {
				Uri uri = Uri.parse(url);
				if (isInternalIdeUrl(uri)) {
					return false;
				}
				return openExternalLink(uri);
			}

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
				injectBlobDownloadHook();
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
		ideWebView.setDownloadListener((url, userAgent, contentDisposition, mimeType, contentLength) -> {
			if (url == null || url.isEmpty()) {
				return;
			}
			if (url.startsWith("blob:")) {
				downloadBlobUrl(url, contentDisposition, mimeType);
				return;
			}
			DownloadManager downloadManager = (DownloadManager) getSystemService(DOWNLOAD_SERVICE);
			if (downloadManager == null) {
				Log.w(TAG, "DownloadManager unavailable for " + url);
				return;
			}
			DownloadManager.Request request = new DownloadManager.Request(Uri.parse(url));
			String cookies = CookieManager.getInstance().getCookie(url);
			if (cookies != null) {
				request.addRequestHeader("Cookie", cookies);
			}
			if (userAgent != null) {
				request.addRequestHeader("User-Agent", userAgent);
			}
			String guessedFileName = URLUtil.guessFileName(url, contentDisposition, mimeType);
			request.setTitle(guessedFileName);
			request.setDescription("Downloading file");
			request.setMimeType(mimeType);
			request.setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED);
			request.setDestinationInExternalPublicDir(android.os.Environment.DIRECTORY_DOWNLOADS, guessedFileName);
			try {
				long downloadId = downloadManager.enqueue(request);
				pendingDownloadNames.put(downloadId, guessedFileName);
			} catch (RuntimeException e) {
				Log.e(TAG, "Failed to enqueue download: " + url, e);
			}
		});
	}

	private void downloadBlobUrl(String blobUrl, String contentDisposition, String mimeType) {
		String rememberedFileName = pendingBlobFileNames.remove(blobUrl);
		String guessedFileName = rememberedFileName != null && !rememberedFileName.isEmpty()
			? rememberedFileName
			: URLUtil.guessFileName("download", contentDisposition, mimeType);
		String script = "(async function() {"
			+ "const url = " + JSONObject.quote(blobUrl) + ";"
			+ "const fallbackName = " + JSONObject.quote(guessedFileName) + ";"
			+ "const fallbackMime = " + JSONObject.quote(mimeType != null ? mimeType : "") + ";"
			+ "try {"
			+ "  const response = await fetch(url);"
			+ "  const blob = await response.blob();"
			+ "  const reader = new FileReader();"
			+ "  reader.onloadend = function() {"
			+ "    const result = typeof reader.result === 'string' ? reader.result : '';"
			+ "    const commaIndex = result.indexOf(',');"
			+ "    const base64 = commaIndex >= 0 ? result.substring(commaIndex + 1) : '';"
			+ "    window.DoraBlobDownloader.saveBase64File(base64, blob.type || fallbackMime, fallbackName);"
			+ "  };"
			+ "  reader.readAsDataURL(blob);"
			+ "} catch (error) {"
			+ "  console.error('blob download failed', error);"
			+ "  window.DoraBlobDownloader.notifyFailure(String(error), fallbackName);"
			+ "}"
			+ "})();";
		ideWebView.evaluateJavascript(script, null);
	}

	private void injectBlobDownloadHook() {
		String script = "(function() {"
			+ "if (window.__doraBlobDownloadHookInstalled) return;"
			+ "window.__doraBlobDownloadHookInstalled = true;"
			+ "const remember = function(anchor) {"
			+ "  if (!anchor || !anchor.href || !anchor.download) return;"
			+ "  if (!anchor.href.startsWith('blob:')) return;"
			+ "  window.DoraBlobDownloader.rememberBlobFileName(anchor.href, anchor.download);"
			+ "};"
			+ "document.addEventListener('click', function(event) {"
			+ "  const anchor = event.target && event.target.closest ? event.target.closest('a[download]') : null;"
			+ "  remember(anchor);"
			+ "}, true);"
			+ "const originalClick = HTMLAnchorElement.prototype.click;"
			+ "HTMLAnchorElement.prototype.click = function() {"
			+ "  remember(this);"
			+ "  return originalClick.apply(this, arguments);"
			+ "};"
			+ "})();";
		ideWebView.evaluateJavascript(script, null);
	}

	private void saveDownloadedFile(byte[] data, String fileName, String mimeType) throws IOException {
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
			ContentValues values = new ContentValues();
			values.put(MediaStore.Downloads.DISPLAY_NAME, fileName);
			values.put(MediaStore.Downloads.MIME_TYPE, mimeType);
			values.put(MediaStore.Downloads.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS);
			values.put(MediaStore.Downloads.IS_PENDING, 1);
			Uri uri = getContentResolver().insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values);
			if (uri == null) {
				throw new IOException("Failed to create download entry");
			}
			try (OutputStream outputStream = getContentResolver().openOutputStream(uri)) {
				if (outputStream == null) {
					throw new IOException("Failed to open download output stream");
				}
				outputStream.write(data);
			}
			values.clear();
			values.put(MediaStore.Downloads.IS_PENDING, 0);
			getContentResolver().update(uri, values, null, null);
			return;
		}

		File downloadsDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS);
		if (!downloadsDir.exists() && !downloadsDir.mkdirs()) {
			throw new IOException("Failed to create Downloads directory");
		}
		File outputFile = new File(downloadsDir, fileName);
		try (FileOutputStream outputStream = new FileOutputStream(outputFile)) {
			outputStream.write(data);
		}
		MediaScannerConnection.scanFile(this,
			new String[] { outputFile.getAbsolutePath() },
			new String[] { mimeType },
			null);
	}

	private boolean isInternalIdeUrl(Uri uri) {
		if (uri == null) {
			return false;
		}
		String scheme = uri.getScheme();
		if (scheme == null) {
			return false;
		}
		String normalizedScheme = scheme.toLowerCase(Locale.ROOT);
		if ("about".equals(normalizedScheme)) {
			return true;
		}
		if (!"http".equals(normalizedScheme) && !"https".equals(normalizedScheme)) {
			return false;
		}
		String host = uri.getHost();
		if (host == null) {
			return false;
		}
		return "127.0.0.1".equals(host) || "localhost".equals(host);
	}

	private boolean openExternalLink(Uri uri) {
		try {
			Intent intent = new Intent(Intent.ACTION_VIEW, uri);
			intent.addCategory(Intent.CATEGORY_BROWSABLE);
			startActivity(intent);
			return true;
		} catch (ActivityNotFoundException e) {
			Log.w(TAG, "No handler for external link: " + uri, e);
			return true;
		}
	}

	private void showToast(String message) {
		uiHandler.post(() -> Toast.makeText(MainActivity.this, message, Toast.LENGTH_SHORT).show());
	}

	private final class BlobDownloadBridge {
		@JavascriptInterface
		public void rememberBlobFileName(String blobUrl, String fileName) {
			if (blobUrl == null || blobUrl.isEmpty() || fileName == null || fileName.isEmpty()) {
				return;
			}
			pendingBlobFileNames.put(blobUrl, fileName);
		}

		@JavascriptInterface
		public void saveBase64File(String base64Data, String mimeType, String fileName) {
			if (base64Data == null || base64Data.isEmpty()) {
				Log.w(TAG, "Empty blob download payload for " + fileName);
				return;
			}
			String safeMimeType = mimeType == null || mimeType.isEmpty()
				? "application/octet-stream"
				: mimeType;
			String safeFileName = fileName == null || fileName.isEmpty()
				? URLUtil.guessFileName("download", null, safeMimeType)
				: fileName;
			try {
				byte[] data = Base64.decode(base64Data, Base64.DEFAULT);
				saveDownloadedFile(data, safeFileName, safeMimeType);
				showToast("Downloaded " + safeFileName);
			} catch (IllegalArgumentException | IOException e) {
				Log.e(TAG, "Failed to save blob download: " + safeFileName, e);
			}
		}

		@JavascriptInterface
		public void notifyFailure(String message, String fileName) {
			Log.e(TAG, "Blob download failed for " + fileName + ": " + message);
		}
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
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		if (requestCode == REQUEST_FILE_CHOOSER) {
			if (fileChooserCallback != null) {
				fileChooserCallback.onReceiveValue(
					WebChromeClient.FileChooserParams.parseResult(resultCode, data));
				fileChooserCallback = null;
			}
			return;
		}
		super.onActivityResult(requestCode, resultCode, data);
	}

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
