package org.ippclub.dorassr;

import org.libsdl.app.SDLActivity;

import android.app.DownloadManager;
import android.animation.ValueAnimator;
import android.content.ActivityNotFoundException;
import android.content.BroadcastReceiver;
import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.graphics.Insets;
import android.graphics.drawable.GradientDrawable;
import android.media.AudioManager;
import android.media.MediaScannerConnection;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Looper;
import android.os.VibrationEffect;
import android.os.Vibrator;
import android.provider.MediaStore;
import android.provider.OpenableColumns;
import android.database.Cursor;
import android.provider.Settings;
import android.os.Build;
import android.util.Base64;
import android.util.Log;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;
import android.view.WindowManager;
import android.view.WindowInsets;
import android.view.WindowInsetsController;
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
import androidx.annotation.Keep;

import java.io.File;
import java.io.InputStream;
import java.io.FileInputStream;
import java.util.concurrent.Executors;
import java.util.concurrent.ExecutorService;
import android.content.ClipData;
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
	private static final int REQUEST_GAME_FILE = 2002;
	private static final int REQUEST_SAVE_GAME = 2003;
	private static final long MAX_GAME_BYTES = 256L * 1024 * 1024;
	private static final ExecutorService gameFileWorker = Executors.newSingleThreadExecutor();
	private static native void nativeReceiveFile(String path, boolean picked);
	private String pendingGameExport;

	private static native void nativeSetPath(String path);
	private static native void nativeSetScreenDensity(float density);
	private static native String nativeGetInstallFile();
	private static native void nativeSetMainActivityClass(Class<?> cls);
	private Button sideHandleButton;
	private LinearLayout sideMenu;
	private Button switchModeButton;
	private Button stopIdeButton;
	private Button reloadButton;
	private FrameLayout ideContainer;
	private WebView ideWebView;
	private WebView compilerWebView;
	private String compilerWebViewPath;
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
	private Vibrator vibrator;
	private volatile float safeInsetLeft;
	private volatile float safeInsetTop;
	private volatile float safeInsetRight;
	private volatile float safeInsetBottom;
	public static String waBuild(String path) { return Wa.waBuild(path); }
	public static String waFormat(String path) { return Wa.waFormat(path); }
	public static long waGitStartClone(String url, String path, String branch, String token, long depth) { return Wa.waGitStartClone(url, path, branch, token, depth); }
	public static long waGitStartPull(String path, String branch, String token, boolean force) { return Wa.waGitStartPull(path, branch, token, force); }
	public static long waGitRun(String repoPath, String command, String optionsJSON) { return Wa.waGitRun(repoPath, command, optionsJSON); }
	public static String waGitPoll(long jobId) { return Wa.waGitPoll(jobId); }
	public static boolean waGitCancel(long jobId) { return Wa.waGitCancel(jobId); }
	public static boolean waGitDispose(long jobId) { return Wa.waGitDispose(jobId); }
	@Override
	protected void onCreate(final Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		vibrator = (Vibrator) getSystemService(Context.VIBRATOR_SERVICE);
		configureEdgeToEdgeWindow();
		IntentFilter downloadFilter = new IntentFilter(DownloadManager.ACTION_DOWNLOAD_COMPLETE);
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
			registerReceiver(downloadCompleteReceiver, downloadFilter, Context.RECEIVER_NOT_EXPORTED);
		} else {
			registerReceiver(downloadCompleteReceiver, downloadFilter);
		}
		MainActivity.nativeSetPath(this.getApplicationInfo().sourceDir);
		MainActivity.nativeSetScreenDensity(this.getResources().getDisplayMetrics().density);
		MainActivity.nativeSetMainActivityClass(MainActivity.class);
		installIdeSwitcher();
		hideSystemUI();
		receiveGameIntent(getIntent());
	}

	@Override
	protected void onNewIntent(Intent intent) {
		super.onNewIntent(intent);
		setIntent(intent);
		receiveGameIntent(intent);
	}

	private void receiveGameIntent(Intent intent) {
		if (intent == null) return;
		Uri uri = null;
		if (Intent.ACTION_VIEW.equals(intent.getAction())) uri = intent.getData();
		else if (Intent.ACTION_SEND.equals(intent.getAction())) uri = intent.getParcelableExtra(Intent.EXTRA_STREAM);
		if (uri != null && ("content".equals(uri.getScheme()) || "file".equals(uri.getScheme()))) {
			copyGameFile(uri, false);
			// Do not replay the original delivery after activity recreation.
			setIntent(new Intent(this, MainActivity.class));
		}
	}

	private String gameText(String zh, String en) {
		return Locale.getDefault().getLanguage().equals("zh") ? zh : en;
	}

	private void copyGameFile(Uri uri, boolean picked) {
		gameFileWorker.execute(() -> {
			File target = null;
			try {
				File directory = new File(getCacheDir(), "game-inbox");
				if (!directory.isDirectory() && !directory.mkdirs()) throw new IOException("inbox");
				File[] oldDeliveries = directory.listFiles();
				if (oldDeliveries != null) for (File old : oldDeliveries) {
					if (old.lastModified() < System.currentTimeMillis() - 7L * 86400000L) {
						File[] children = old.listFiles();
						if (children != null) for (File child : children) child.delete();
						old.delete();
					}
				}
				String name = uri.getLastPathSegment();
				try (Cursor cursor = getContentResolver().query(uri, new String[] {OpenableColumns.DISPLAY_NAME}, null, null, null)) {
					if (cursor != null && cursor.moveToFirst()) name = cursor.getString(0);
				} catch (Exception ignored) { /* A provider may not expose a display name. */ }
				if (name == null || name.isEmpty()) name = "Game.zip";
				name = name.replaceAll("[\\\\/:*?\"<>|\\p{Cntrl}]", "_");
				File delivery = new File(directory, java.util.UUID.randomUUID().toString());
				if (!delivery.mkdir()) throw new IOException("delivery");
				target = new File(delivery, name);
				try (InputStream input = getContentResolver().openInputStream(uri);
					 OutputStream output = new FileOutputStream(target)) {
					if (input == null) throw new IOException("empty input");
					byte[] buffer = new byte[65536];
					long total = 0;
					int count;
					while ((count = input.read(buffer)) != -1) {
						total += count;
						if (total > MAX_GAME_BYTES) throw new IOException("package too large");
						output.write(buffer, 0, count);
					}
				}
				nativeReceiveFile(target.getAbsolutePath(), picked);
			} catch (Exception error) {
				if (target != null) target.delete();
				if (picked) nativeReceiveFile("", true);
				showToast(gameText("无法读取作品包（最大 256 MB）", "Could not read game package (maximum 256 MB)"));
			}
		});
	}

	@Keep
	public void pickGameFile(String unused) {
		runOnUiThread(() -> {
			try {
				Intent intent = new Intent(Intent.ACTION_OPEN_DOCUMENT);
				intent.addCategory(Intent.CATEGORY_OPENABLE);
				intent.setType("application/zip");
				intent.putExtra(Intent.EXTRA_MIME_TYPES, new String[] {"application/zip", "application/x-zip-compressed", "application/octet-stream"});
				startActivityForResult(intent, REQUEST_GAME_FILE);
			} catch (ActivityNotFoundException error) {
				nativeReceiveFile("", true);
				showToast(gameText("无法打开文件选择器", "Could not open file picker"));
			}
		});
	}

	@Keep
	public void shareGameFile(String path) {
		runOnUiThread(() -> {
			try {
				Uri uri = FileProvider.getUriForFile(this, getPackageName() + ".FileProvider", new File(path));
				Intent intent = new Intent(Intent.ACTION_SEND);
				intent.setType("application/zip");
				intent.putExtra(Intent.EXTRA_STREAM, uri);
				intent.setClipData(ClipData.newRawUri("Game package", uri));
				intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
				startActivity(Intent.createChooser(intent, gameText("分享作品", "Share game")));
			} catch (Exception error) {
				showToast(gameText("无法打开分享面板，请尝试保存作品包", "Could not share; try saving the package"));
			}
		});
	}

	@Keep
	public void saveGameFile(String path) {
		runOnUiThread(() -> {
			if (pendingGameExport != null) return;
			try {
				pendingGameExport = path;
				Intent intent = new Intent(Intent.ACTION_CREATE_DOCUMENT);
				intent.addCategory(Intent.CATEGORY_OPENABLE);
				intent.setType("application/zip");
				intent.putExtra(Intent.EXTRA_TITLE, new File(path).getName());
				startActivityForResult(intent, REQUEST_SAVE_GAME);
			} catch (ActivityNotFoundException error) {
				pendingGameExport = null;
				showToast(gameText("无法打开保存面板", "Could not open save dialog"));
			}
		});
	}

	private void configureEdgeToEdgeWindow() {
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
			WindowManager.LayoutParams attributes = getWindow().getAttributes();
			attributes.layoutInDisplayCutoutMode =
				WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES;
			getWindow().setAttributes(attributes);
		}
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
			getWindow().setDecorFitsSystemWindows(false);
		} else {
			getWindow().addFlags(WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS);
		}
		View decorView = getWindow().getDecorView();
		decorView.setOnApplyWindowInsetsListener((view, windowInsets) -> {
			if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
				Insets bars = windowInsets.getInsets(
					WindowInsets.Type.systemBars()
						| WindowInsets.Type.displayCutout()
						| WindowInsets.Type.mandatorySystemGestures());
				safeInsetLeft = bars.left;
				safeInsetTop = bars.top;
				safeInsetRight = bars.right;
				safeInsetBottom = bars.bottom;
			} else {
				safeInsetLeft = windowInsets.getSystemWindowInsetLeft();
				safeInsetTop = windowInsets.getSystemWindowInsetTop();
				safeInsetRight = windowInsets.getSystemWindowInsetRight();
				safeInsetBottom = windowInsets.getSystemWindowInsetBottom();
			}
			return windowInsets;
		});
		decorView.requestApplyInsets();
	}

	@Keep
	public float[] getSafeAreaInsets() {
		return new float[] {safeInsetLeft, safeInsetTop, safeInsetRight, safeInsetBottom};
	}

	@Keep
	public boolean isReducedMotion() {
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
			return !ValueAnimator.areAnimatorsEnabled();
		}
		return Settings.Global.getFloat(
			getContentResolver(), Settings.Global.ANIMATOR_DURATION_SCALE, 1.0f) == 0.0f;
	}

	@Keep
	public void setAppWebView(String path, boolean visible) {
		runOnUiThread(() -> {
			if (!"/compiler.html".equals(path)) {
				Log.w(TAG, "ignored unsupported AppWebView path: " + path);
				return;
			}
			if (!visible) {
				if (path.equals(compilerWebViewPath)) {
					destroyCompilerWebView();
				}
				return;
			}
			if (compilerWebView != null && path.equals(compilerWebViewPath)) {
				return;
			}
			destroyCompilerWebView();
			View content = SDLActivity.getContentView();
			if (!(content instanceof RelativeLayout)) {
				Log.e(TAG, "failed to attach compiler WebView: SDL content is not a RelativeLayout");
				return;
			}
			WebView webView = new WebView(this);
			WebSettings settings = webView.getSettings();
			settings.setJavaScriptEnabled(true);
			settings.setDomStorageEnabled(true);
			settings.setAllowFileAccess(false);
			settings.setAllowContentAccess(false);
			webView.setBackgroundColor(Color.TRANSPARENT);
			webView.setAlpha(0.0f);
			webView.setClickable(false);
			webView.setFocusable(false);
			webView.setFocusableInTouchMode(false);
			webView.setWebChromeClient(new WebChromeClient() {
				@Override
				public boolean onConsoleMessage(ConsoleMessage consoleMessage) {
					Log.d(TAG, "compiler: " + consoleMessage.message()
						+ " @" + consoleMessage.lineNumber());
					return true;
				}
			});
			webView.setWebViewClient(new WebViewClient() {
				private boolean isCompilerUrl(String url) {
					return url != null && (url.equals(WEB_IDE_URL + "/compiler.html")
						|| url.startsWith(WEB_IDE_URL + "/compiler/"));
				}

				@Override
				public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {
					return !isCompilerUrl(request.getUrl().toString());
				}

				@Override
				@SuppressWarnings("deprecation")
				public boolean shouldOverrideUrlLoading(WebView view, String url) {
					return !isCompilerUrl(url);
				}

				@Override
				public void onPageFinished(WebView view, String url) {
					Log.d(TAG, "compiler page finished: " + url);
				}

				@Override
				public void onReceivedError(WebView view, WebResourceRequest request, WebResourceError error) {
					Log.e(TAG, "compiler load failed: " + request.getUrl() + ": " + error);
				}
			});
			RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(1, 1);
			params.addRule(RelativeLayout.ALIGN_PARENT_LEFT);
			params.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
			((RelativeLayout) content).addView(webView, params);
			compilerWebView = webView;
			compilerWebViewPath = path;
			Log.d(TAG, "loading compiler WebView: " + WEB_IDE_URL + path);
			webView.loadUrl(WEB_IDE_URL + path);
		});
	}

	private void destroyCompilerWebView() {
		if (compilerWebView == null) {
			compilerWebViewPath = null;
			return;
		}
		Log.d(TAG, "destroying compiler WebView: " + compilerWebViewPath);
		compilerWebView.stopLoading();
		compilerWebView.loadUrl("about:blank");
		ViewParent parent = compilerWebView.getParent();
		if (parent instanceof ViewGroup) {
			((ViewGroup) parent).removeView(compilerWebView);
		}
		compilerWebView.destroy();
		compilerWebView = null;
		compilerWebViewPath = null;
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
		if (compilerWebView != null) {
			compilerWebView.onResume();
		}
		hideSystemUI();
	}

	@Override
	protected void onPause() {
		if (vibrator != null) {
			vibrator.cancel();
		}
		if (ideWebView != null) {
			ideWebView.onPause();
		}
		if (compilerWebView != null) {
			compilerWebView.onPause();
		}
		super.onPause();
	}

	@Override
	protected void onDestroy() {
		if (vibrator != null) {
			vibrator.cancel();
		}
		if (ideWebView != null) {
			ideWebView.destroy();
			ideWebView = null;
		}
		destroyCompilerWebView();
		try {
			unregisterReceiver(downloadCompleteReceiver);
		} catch (IllegalArgumentException ignored) {
		}
		uiHandler.removeCallbacks(autoHideSideMenu);
		super.onDestroy();
	}

	@Keep
	public void vibrate(double seconds) {
		if (vibrator == null) {
			return;
		}
		long duration = (long) (seconds * 1000.0);
		if (duration <= 0) {
			return;
		}
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
			vibrator.vibrate(VibrationEffect.createOneShot(duration, VibrationEffect.DEFAULT_AMPLITUDE));
		} else {
			vibrator.vibrate(duration);
		}
	}

	@Keep
	public boolean hasBackgroundMusic() {
		AudioManager audioManager = (AudioManager) getSystemService(Context.AUDIO_SERVICE);
		return audioManager != null && audioManager.isMusicActive();
	}

	private void hideSystemUI() {
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
			WindowInsetsController controller = getWindow().getInsetsController();
			if (controller != null) {
				controller.hide(WindowInsets.Type.systemBars());
				controller.setSystemBarsBehavior(
					WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE);
			}
			return;
		}
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
		if (requestCode == REQUEST_GAME_FILE) {
			if (resultCode == RESULT_OK && data != null && data.getData() != null) copyGameFile(data.getData(), true);
			else nativeReceiveFile("", true);
			return;
		}
		if (requestCode == REQUEST_SAVE_GAME) {
			String source = pendingGameExport;
			pendingGameExport = null;
			if (resultCode == RESULT_OK && source != null && data != null && data.getData() != null) {
				Uri destination = data.getData();
				gameFileWorker.execute(() -> {
					try (InputStream input = new FileInputStream(source);
						 OutputStream output = getContentResolver().openOutputStream(destination, "wt")) {
						if (output == null) throw new IOException("empty output");
						byte[] buffer = new byte[65536];
						int count;
						while ((count = input.read(buffer)) != -1) output.write(buffer, 0, count);
						showToast(gameText("作品包已保存", "Game package saved"));
					} catch (Exception error) {
						showToast(gameText("作品包保存失败", "Could not save game package"));
					}
				});
			}
			return;
		}
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
